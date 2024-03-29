defmodule Bson.Decoder do
  defstruct new_doc:
              Application.get_env(:bson, :decoder_new_doc, &Bson.Decoder.elist_to_keyword_list/1),
            new_bin: Application.get_env(:bson, :decoder_new_bin, &Bson.Bin.new/2)

  defmodule Error do
    defstruct what: nil, acc: [], rest: nil

    defimpl Inspect, for: Error do
      def inspect(e, _), do: inspect(what: e.what, acc: e.acc, rest: e.rest)
    end
  end

  def elist_to_keyword_list(elist) do
    elist
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  def elist_to_keyword(elist),
    do: elist |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

  def identity(elist), do: elist

  def document(bsonbuffer, opts \\ %Bson.Decoder{})

  def document(bsonbuffer, _opts) when byte_size(bsonbuffer) < 5 do
    %Error{
      what: :"document size is #{byte_size(bsonbuffer)}, must be > 4",
      rest: {byte_size(bsonbuffer), bsonbuffer}
    }
  end

  def document(<<size::32-signed-little, _::binary>> = bson, opts) do
    case value(0x03, bson, size, opts) do
      %Error{} = error -> error
      {0, rest, doc} -> {doc, rest}
    end
  end

  # Embeded document
  defp value(0x03, buffer, restsize, opts) do
    case buffer do
      <<size::32-signed-little, rest::binary>> when restsize >= size and size > 4 ->
        case elist(rest, size - 5, opts) do
          %Error{} = error -> error
          # if it's document fault and in the future it will be in normalorder
          # then remove the Enum.reverse
          {<<0, rest::binary>>, list} -> {restsize - size, rest, Enum.reverse(list)}
          {rest, doc} -> %Error{what: :"document trail", acc: doc, rest: {restsize - size, rest}}
        end

      _ ->
        %Error{what: :"document size", rest: {restsize, buffer}}
    end
  end

  # array
  defp value(0x04, buffer, restsize, opts) do
    case buffer do
      <<size::32-signed-little, rest::binary>> when restsize >= size ->
        case ilist(rest, size - 5, opts) do
          %Error{} = error -> error
          {<<0, rest::binary>>, list} -> {restsize - size, rest, list}
          {rest, array} -> %Error{what: :"array trail", acc: array, rest: {restsize - size, rest}}
        end

      _ ->
        %Error{what: :"array size", rest: {restsize, buffer}}
    end
  end

  # String
  defp value(0x02, buffer, restsize, _) do
    case buffer do
      <<size::32-little-signed, rest::binary>> when restsize > size + 3 ->
        case string(rest, size - 1, restsize - 4) do
          %Error{} = error -> error
          {restsize, rest, string} -> {restsize, rest, string}
        end

      _ ->
        %Error{what: [:string], rest: {restsize, buffer}}
    end
  end

  # Atom
  defp value(0x0E, buffer, restsize, _) do
    case buffer do
      <<size::32-little-signed, rest::binary>> when restsize > size + 3 ->
        case string(rest, size - 1, restsize - 4) do
          %Error{} = error -> error
          {restsize, rest, string} -> {restsize, rest, string |> String.to_atom()}
        end

      _ ->
        %Error{what: [:atom], rest: {restsize, buffer}}
    end
  end

  # Int32
  defp value(0x10, <<i::32-little-signed, rest::binary>>, restsize, _),
    do: {restsize - 4, rest, i}

  # Int64
  defp value(0x12, <<i::64-little-signed, rest::binary>>, restsize, _),
    do: {restsize - 8, rest, i}

  # Float
  defp value(0x01, <<rest::binary>>, restsize, _) when restsize > 7, do: float(rest, restsize)
  # Object Id
  defp value(0x07, <<oid::96, rest::binary>>, restsize, _),
    do: {restsize - 12, rest, %Bson.ObjectId{oid: <<oid::96>>}}

  # Boolean
  defp value(0x08, <<0, rest::binary>>, restsize, _), do: {restsize - 1, rest, false}
  defp value(0x08, <<1, rest::binary>>, restsize, _), do: {restsize - 1, rest, true}

  defp value(0x09, <<ms::64-little-signed, rest::binary>>, restsize, _) when restsize > 7,
    do: {restsize - 8, rest, %Bson.UTC{ms: ms}}

  # null
  defp value(0x06, <<rest::binary>>, restsize, _), do: {restsize, rest, nil}
  defp value(0x0A, <<rest::binary>>, restsize, _), do: {restsize, rest, nil}
  # Timestamp
  defp value(0x11, <<inc::32-little-signed, ts::32-little-signed, rest::binary>>, restsize, _),
    do: {restsize - 8, rest, %Bson.Timestamp{inc: inc, ts: ts}}

  # Constants
  defp value(0xFF, <<rest::binary>>, restsize, _), do: {restsize, rest, :min_key}
  defp value(0x7F, <<rest::binary>>, restsize, _), do: {restsize, rest, :max_key}
  # regex
  defp value(0x0B, buffer, restsize, _) when restsize > 1 do
    case cstring(buffer, restsize) do
      %Error{} ->
        %Error{what: [:regex_pattern], rest: {restsize, buffer}}

      {optsrestsize, optsrest, pattern} ->
        case cstring(optsrest, optsrestsize) do
          %Error{} -> %Error{what: [:regex_opts], acc: [pattern], rest: {optsrestsize, optsrest}}
          {restsize, rest, opts} -> {restsize, rest, %Bson.Regex{pattern: pattern, opts: opts}}
        end
    end
  end

  # javascript
  defp value(0x0D, buffer, restsize, _) do
    case buffer do
      <<size::32-little-signed, rest::binary>> when restsize >= size ->
        case string(rest, size - 1, restsize - 4) do
          %Error{} -> %Error{what: [:js_code], rest: {restsize, buffer}}
          {restsize, rest, jscode} -> {restsize, rest, %Bson.JS{code: jscode}}
        end

      _ ->
        %Error{what: [:js_size], rest: {restsize, buffer}}
    end
  end

  # javascript with scope
  defp value(0x0F, buffer, restsize, opts) do
    case buffer do
      <<size::32-little-signed, jssize::32-little-signed, rest::binary>> when restsize >= size ->
        case string(rest, jssize - 1, size - 8) do
          %Error{} ->
            %Error{what: [:js_code], rest: {restsize, buffer}}

          {scoperestsize, scopebuffer, jscode} ->
            case scopebuffer do
              <<scopesize::32-little-signed, scoperest::binary>>
              when scoperestsize > scopesize - 1 ->
                case elist(scoperest, scopesize - 5, opts) do
                  %Error{} = error ->
                    %Error{
                      error
                      | what: [:js_scope | error.what],
                        acc: [jscode | error.acc],
                        rest: {scoperestsize, scopebuffer}
                    }

                  {<<0, rest::binary>>, scope} ->
                    {restsize - size, rest, %Bson.JS{code: jscode, scope: scope}}

                  {rest, scope} ->
                    %Error{
                      what: [:js_scope_trail],
                      acc: [jscode, scope],
                      rest: {restsize - size, rest}
                    }
                end

              _ ->
                %Error{what: [:js_scope_size], acc: [jscode], rest: {restsize, buffer}}
            end
        end

      _ ->
        %Error{what: [:js_size], rest: {restsize, buffer}}
    end
  end

  # binary
  defp value(0x05, buffer, restsize, opts) do
    case buffer do
      <<size::32-little-signed, subtype, rest::binary>> when restsize > size + 4 ->
        bitsize = size * 8

        case rest do
          <<bin::size(bitsize), rest::binary>> when restsize > size + 3 ->
            {restsize - size - 5, rest, opts.new_bin.(<<bin::size(bitsize)>>, subtype)}

          _ ->
            %Error{what: [:bin], rest: {restsize, buffer}}
        end

      _ ->
        %Error{what: [:bin_size], rest: {restsize, buffer}}
    end
  end

  # not supported
  defp value(kind, buffer, restsize, _), do: %Error{what: [kind: kind], rest: {restsize, buffer}}

  # decodes a string
  defp string(buffer, size, restsize) when size >= 0 do
    bitsize = size * 8

    case buffer do
      <<s::size(bitsize), 0, rest::binary>> -> {restsize - (size + 1), rest, <<s::size(bitsize)>>}
      _ -> %Error{what: [:bytestring], rest: {restsize, buffer}}
    end
  end

  defp string(buffer, _, restsize), do: %Error{what: [:bytestring], rest: {restsize, buffer}}

  # Decodes a float from a binary at a given position. It will decode atoms nan, +inf and -inf as well
  defp float(<<0::48, 248, 127, rest::binary>>, max), do: {max - 8, rest, :nan}
  defp float(<<0::48, 248, 255, rest::binary>>, max), do: {max - 8, rest, :nan}
  defp float(<<0::48, 240, 127, rest::binary>>, max), do: {max - 8, rest, :"+inf"}
  defp float(<<0::48, 240, 255, rest::binary>>, max), do: {max - 8, rest, :"-inf"}
  defp float(<<f::64-float-little, rest::binary>>, max), do: {max - 8, rest, f}
  defp float(buffer, restsize), do: %Error{what: [:float], rest: {restsize, buffer}}

  defp cstring(buffer, max, acc \\ [])
  defp cstring(<<0, rest::binary>>, max, acc), do: {max - 1, rest, reverse_binof(acc)}
  defp cstring(<<c, rest::binary>>, max, acc), do: cstring(rest, max - 1, [c | acc])
  defp cstring(_, 0, _), do: %Error{}
  defp cstring(<<>>, _, _), do: %Error{}

  defp elist(buffer, 0, _), do: {buffer, %{}}
  defp elist(buffer, restsize, opts, elist \\ [])

  defp elist(<<kind, rest::binary>>, restsize, opts, elist) do
    case cstring(rest, restsize - 1) do
      %Error{} ->
        %Error{what: [:element], acc: Enum.reverse(elist), rest: {restsize, rest}}

      {restsize, rest, name} ->
        case value(kind, rest, restsize, opts) do
          %Error{} = error ->
            %Error{error | what: [name | error.what], acc: [Enum.reverse(elist) | error.acc]}

          {0, rest, value} ->
            {rest, opts.new_doc.([{name, value} | elist])}

          {restsize, buffer, value} ->
            elist(buffer, restsize, opts, [{name, value} | elist])
        end
    end
  end

  defp ilist(buffer, 0, _), do: {buffer, []}
  defp ilist(buffer, size, opts, ilist \\ [])

  defp ilist(<<kind, rest::binary>>, restsize, opts, ilist) do
    case skip_cstring(rest, restsize - 1) do
      %Error{} ->
        %Error{what: :item, acc: Enum.reverse(ilist), rest: {restsize, rest}}

      {restsize, rest} ->
        case value(kind, rest, restsize, opts) do
          %Error{} = error -> %Error{error | acc: [Enum.reverse(ilist) | error.acc]}
          {0, rest, value} -> {rest, [value | ilist] |> Enum.reverse()}
          {restsize, buffer, value} -> ilist(buffer, restsize, opts, [value | ilist])
        end
    end
  end

  defp skip_cstring(buffer, max)
  defp skip_cstring(<<0, rest::binary>>, max), do: {max - 1, rest}
  defp skip_cstring(<<_, rest::binary>>, max), do: skip_cstring(rest, max - 1)
  defp skip_cstring(_, 0), do: %Error{}
  defp skip_cstring(<<>>, _), do: %Error{}

  defp reverse_binof(iolist), do: iolist |> Enum.reverse() |> :erlang.iolist_to_binary()
end

defmodule Bson.Encoder do
  defprotocol BsonProtocol do
    def encode(term)
  end

  defmodule Error do
    defstruct what: nil, acc: [], term: nil

    defimpl Inspect, for: Error do
      def inspect(e, _), do: inspect(what: e.what, term: e.term, acc: e.acc)
    end
  end

  def document(element_list) do
    case Enumerable.reduce(element_list, {:cont, []}, fn
           {key, value}, acc when is_binary(key) ->
             accumulate_elist(key, value, acc)

           {key, value}, acc when is_atom(key) ->
             accumulate_elist(Atom.to_string(key), value, acc)

           element, acc ->
             {:halt, %Error{what: [:element], term: element, acc: acc |> Enum.reverse()}}
         end) do
      {:halted, error} ->
        error

      {:done, acc} ->
        acc |> Enum.reverse() |> IO.iodata_to_binary() |> wrap_document
    end
  end

  defimpl BsonProtocol, for: Integer do
    def encode(i) when -0x80000000 <= i and i <= 0x80000000,
      do: {<<0x10>>, <<i::32-signed-little>>}

    def encode(i) when -0x8000000000000000 <= i and i <= 0x8000000000000000,
      do: {<<0x12>>, <<i::64-signed-little>>}

    def encode(i), do: %Error{what: [Integer], term: i}
  end

  defimpl BsonProtocol, for: Float do
    def encode(f), do: {<<0x01>>, <<f::size(64)-float-little>>}
  end

  defimpl BsonProtocol, for: Atom do
    # predefind Bson value
    def encode(false), do: {<<0x08>>, <<0x00>>}
    def encode(true), do: {<<0x08>>, <<0x01>>}
    def encode(nil), do: {<<0x0A>>, <<>>}
    def encode(:nan), do: {<<0x01>>, <<0, 0, 0, 0, 0, 0, 248, 127>>}
    def encode(:"+inf"), do: {<<0x01>>, <<0, 0, 0, 0, 0, 0, 240, 127>>}
    def encode(:"-inf"), do: {<<0x01>>, <<0, 0, 0, 0, 0, 0, 240, 255>>}
    def encode(:min_key), do: {<<0xFF>>, <<>>}
    def encode(:max_key), do: {<<0x7F>>, <<>>}
    # other Elixir atom are encoded like strings ()
    def encode(atom), do: {<<0x0E>>, atom |> Atom.to_string() |> Bson.Encoder.wrap_string()}
  end

  defimpl BsonProtocol, for: Bson.UTC do
    def encode(%Bson.UTC{ms: ms}) when is_integer(ms), do: {<<0x09>>, <<ms::64-little-signed>>}
    def encode(utc), do: %Error{what: [Bson.UTC], term: utc}
  end

  defimpl BsonProtocol, for: Bson.Regex do
    def encode(%Bson.Regex{pattern: p, opts: o}) when is_binary(p) and is_binary(o),
      do: {<<0x0B>>, [p, <<0x00>>, o, <<0x00>>]}

    def encode(regex), do: %Error{what: [Bson.Regex], term: regex}
  end

  defimpl BsonProtocol, for: Bson.ObjectId do
    def encode(%Bson.ObjectId{oid: oid}) when is_binary(oid), do: {<<0x07>>, oid}
    def encode(oid), do: %Error{what: [Bson.ObjectId], term: oid}
  end

  defimpl BsonProtocol, for: Bson.JS do
    def encode(%Bson.JS{code: js, scope: nil}) when is_binary(js) do
      {<<0x0D>>, Bson.Encoder.wrap_string(js)}
    end

    def encode(%Bson.JS{code: js, scope: ctx}) when is_binary(js) and is_map(ctx) do
      case Bson.Encoder.document(ctx) do
        %Error{} = error ->
          %Error{error | what: {:js_context, error.what}}

        ctxBin ->
          {<<0x0F>>, [Bson.Encoder.wrap_string(js), ctxBin] |> IO.iodata_to_binary() |> js_ctx}
      end
    end

    def encode(js), do: %Error{what: [Bson.JS], term: js}

    defp js_ctx(jsctx), do: <<byte_size(jsctx) + 4::32-little-signed, jsctx::binary>>
  end

  defimpl BsonProtocol, for: Bson.Bin do
    def encode(%Bson.Bin{bin: bin, subtype: subtype}), do: encode(bin, subtype)

    def encode(bin, subtype)
        when is_binary(bin) and is_integer(subtype),
        do: {<<0x05>>, [<<byte_size(bin)::32-little-signed>>, subtype, bin]}

    def encode(bin, subtype), do: %Error{what: [Bson.Bin], term: {bin, subtype}}
  end

  defimpl BsonProtocol, for: Bson.Timestamp do
    def encode(%Bson.Timestamp{inc: i, ts: t})
        when is_integer(i) and -0x80000000 <= i and i <= 0x80000000 and
               is_integer(t) and -0x80000000 <= t and t <= 0x80000000,
        do: {<<0x11>>, <<i::32-signed-little, t::32-signed-little>>}

    def encode(ts), do: %Error{what: [Bson.Timestamp], term: ts}
  end

  defimpl BsonProtocol, for: BitString do
    @doc """
    iex> Bson.Encoder.BsonProtocol.encode("a")
    {<<2>>, [<<2, 0, 0, 0>>, "a", <<0>>]}
    """
    def encode(s) when is_binary(s), do: {<<0x02>>, Bson.Encoder.wrap_string(s)}
    def encode(bits), do: %Error{what: [BitString], term: bits}
  end

  defimpl BsonProtocol, for: List do
    def encode([{k, _} | _] = elist) when is_atom(k) or is_binary(k) do
      case Bson.Encoder.document(elist) do
        %Error{} = error -> error
        encoded_elist -> {<<0x03>>, encoded_elist}
      end
    end

    def encode(list) do
      case Bson.Encoder.array(list) do
        %Error{} = error -> error
        encoded_list -> {<<0x04>>, encoded_list}
      end
    end
  end

  defimpl BsonProtocol, for: [Map, HashDict, Keyword] do
    def encode(dict) do
      case Bson.Encoder.document(dict) do
        %Error{} = error -> error
        encoded_dict -> {<<0x03>>, encoded_dict}
      end
    end
  end

  def array(item_list) do
    case Enumerable.reduce(item_list, {:cont, {[], 0}}, fn item, {acc, i} ->
           case accumulate_elist(Integer.to_string(i), item, acc) do
             {:cont, acc} -> {:cont, {acc, i + 1}}
             {:halt, error} -> {:halt, error}
           end
         end) do
      {:halted, error} ->
        error

      {:done, {bufferAcc, _}} ->
        bufferAcc |> Enum.reverse() |> IO.iodata_to_binary() |> wrap_document
    end
  end

  def wrap_document(elist), do: <<byte_size(elist) + 5::32-little-signed>> <> elist <> <<0x00>>

  def wrap_string(string), do: [<<byte_size(string) + 1::32-little-signed>>, string, <<0x00>>]

  def accumulate_elist(name, value, elist) do
    case element(name, value) do
      %Error{} = error -> {:halt, %Error{error | acc: [Enum.reverse(elist) | error.acc]}}
      encoded_element -> {:cont, [encoded_element | elist]}
    end
  end

  def element(name, value) do
    case Bson.Encoder.BsonProtocol.encode(value) do
      %Error{} = error -> %Error{error | what: [name | error.what]}
      {kind, encoded_value} -> [kind, name, <<0x00>>, encoded_value]
    end
  end
end

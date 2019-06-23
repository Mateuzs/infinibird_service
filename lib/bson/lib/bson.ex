defmodule Bson do
  defmodule ObjectId do
    defstruct oid: nil

    defimpl Inspect, for: Bson.ObjectId do
      def inspect(%Bson.ObjectId{oid: nil}, _), do: "ObjectId()"

      def inspect(%Bson.ObjectId{oid: oid}, _) when is_binary(oid),
        do: "ObjectId(#{Bson.hex(oid) |> String.downcase()})"

      def inspect(%Bson.ObjectId{oid: oid}, _), do: "InvalidObjectId(#{inspect(oid)})"
    end

    defimpl String.Chars, for: Bson.ObjectId do
      def to_string(%Bson.ObjectId{oid: oid}) do
        Bson.hex(oid) |> String.downcase()
      end
    end

    def from_string(object_id) when is_bitstring(object_id) and byte_size(object_id) == 24,
      do: %Bson.ObjectId{
        oid:
          for(<<hex::16 <- object_id>>, into: <<>>, do: <<String.to_integer(<<hex::16>>, 16)::8>>)
      }
  end

  def hex(bin), do: for(<<h::4 <- bin>>, into: <<>>, do: <<Integer.to_string(h, 16)::binary>>)

  defmodule Regex do
    defstruct pattern: "", opts: ""
  end

  defmodule JS do
    defstruct code: "", scope: nil
  end

  defmodule Timestamp do
    defstruct inc: nil, ts: nil
  end

  defmodule UTC do
    defstruct ms: nil

    defimpl Inspect, for: Bson.UTC do
      def inspect(bson_utc, _) do
        {{y, mo, d}, {h, mi, s}} = :calendar.now_to_universal_time(Bson.UTC.to_now(bson_utc))
        "#{y}-#{mo}-#{d}T#{h}:#{mi}:#{s}"
      end
    end

    def from_now({a, s, o}), do: %UTC{ms: a * 1_000_000_000 + s * 1000 + div(o, 1000)}

    def to_now(%UTC{ms: ms}),
      do: {div(ms, 1_000_000_000), rem(div(ms, 1000), 1_000_000), rem(ms * 1000, 1_000_000)}
  end

  defmodule Bin do
    defstruct bin: "", subtype: <<0x00>>

    def subtyx(:binary), do: 0x00
    def subtyx(:function), do: 0x01
    def subtyx(:binary_old), do: 0x02
    def subtyx(:uuid_old), do: 0x03
    def subtyx(:uuid), do: 0x04
    def subtyx(:md5), do: 0x05
    def subtyx(:user), do: 0x80

    def xsubty(0x00), do: :binary
    def xsubty(0x01), do: :function
    def xsubty(0x02), do: :binary
    def xsubty(0x03), do: :uuid
    def xsubty(0x04), do: :uuid
    def xsubty(0x05), do: :md5
    def xsubty(0x80), do: :user

    def new(bin, subtype), do: %Bin{bin: bin, subtype: subtype}
  end

  defdelegate encode(term), to: Bson.Encoder, as: :document

  def decode(bson, opts \\ %Bson.Decoder{}) do
    case Bson.Decoder.document(bson, opts) do
      %Bson.Decoder.Error{} = error -> error
      {doc, <<>>} -> doc
      {doc, rest} -> %Bson.Decoder.Error{what: :buffer_not_empty, acc: doc, rest: rest}
    end
  end
end

defmodule InfinibirdService.TangoController do
  def handle_new_trip(device_id) do
    IO.puts(device_id)

    token = String.slice(device_id, (String.length(device_id) - 8)..String.length(device_id))

    unique_token =
      case check_token_existence(token) do
        nil -> token
        _else -> get_random_token(device_id)
      end

    unique_token
  end

  defp get_random_token(device_id) do
    normalized_device_id = String.replace(device_id, "-", "")
    IO.puts(normalized_device_id)

    random_token =
      Enum.take_random(0..(String.length(normalized_device_id) - 1), 8)
      |> Enum.map(fn e -> String.at(normalized_device_id, e) end)

    case check_token_existence(random_token) do
      nil -> random_token
      _else -> get_random_token(device_id)
    end
  end

  defp check_token_existence(token) do
    Enum.find(["7e8a31fa"], nil, fn x -> x === token end)
  end
end

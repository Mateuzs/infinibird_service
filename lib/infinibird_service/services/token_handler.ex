defmodule InfinibirdService.TokenHandler do
  import Ecto.Query
  alias InfinibirdDB.{User, Repo}

  def handle_token(device_id) do
    user =
      from(User, where: [device_id: ^device_id])
      |> Repo.one()

    case user do
      nil ->
        token = generate_token(device_id)
        Repo.insert(%User{device_id: device_id, token: token})

        token

      _not_nil ->
        user.token
    end
  end

  defp generate_token(device_id) do
    normalized_device_id = String.replace(device_id, "-", "")

    token =
      String.slice(
        normalized_device_id,
        (String.length(normalized_device_id) - 8)..String.length(normalized_device_id)
      )

    unique_token =
      case check_token_existence(token) do
        nil -> token
        _else -> get_random_token(normalized_device_id)
      end

    unique_token
  end

  defp get_random_token(device_id) do
    random_token =
      Enum.take_random(0..(String.length(device_id) - 1), 8)
      |> Enum.map(fn e -> String.at(device_id, e) end)

    case check_token_existence(random_token) do
      nil -> random_token
      _else -> get_random_token(device_id)
    end
  end

  defp check_token_existence(token) do
    from(User) |> Repo.all() |> Enum.find(nil, fn user -> user.token === token end)
  end
end

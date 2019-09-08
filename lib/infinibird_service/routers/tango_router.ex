defmodule InfinibirdService.TangoRouter do
  use Plug.Router
  alias InfinibirdService.TokenHandler
  alias InfinibirdService.RideHandler
  @device_id "deviceId"
  @ride_id "rideId"

  if System.get_env("MIX_ENV") === "prod" do
    plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
  end

  plug(BasicAuth,
    use_config: {:infinibird_service, :infinibird_service_basic_auth_config},
    custom_response: &InfinibirdService.Authentication.unauthorized_response/1
  )

  plug(:match)
  plug(:dispatch)

  post "/new-trip/" do
    validate_params(conn.body_params)
    |> handle_response(conn)
  end

  get _ do
    send_resp(conn, 404, "Not found!")
  end

  defp validate_params(params) do
    required_params = [@device_id, @ride_id]

    Enum.filter(required_params, fn required_param -> !Map.has_key?(params, required_param) end)
  end

  defp handle_response([], conn) do
    token = TokenHandler.handle_token(conn.body_params[@device_id])
    RideHandler.process_new_ride(conn.body_params[@device_id], conn.body_params[@ride_id])

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, ~s[{"token": "#{token}"}])
  end

  defp handle_response(missing_params, conn) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(
      400,
      ~s[{"Error": "400 - missing parameters: #{inspect(missing_params)}"}]
    )
  end
end

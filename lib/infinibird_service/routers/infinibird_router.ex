defmodule InfinibirdService.InfinibirdRouter do
  use Plug.Router
  alias InfinibirdService.RideHandler
  alias InfinibirdService.AuthService

  if System.get_env("MIX_ENV") === "prod" do
    plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
  end

  plug(BasicAuth,
    use_config: {:infinibird_service, :infinibird_service_basic_auth_config},
    custom_response: &InfinibirdService.Authentication.unauthorized_response/1
  )

  plug(:match)
  plug(:dispatch)

  get "/rides_metrics/:deviceId" do
    data = RideHandler.get_summary_data(deviceId)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(data))
  end

  get "/trips/:deviceId" do
    file_names = RideHandler.get_user_ride_file_names(deviceId)

    data =
      file_names
      |> Enum.chunk_every(10)

    chunked_conn =
      conn
      |> put_resp_content_type("text/bson")
      |> send_chunked(200)

    Enum.each(data, fn chunk ->
      rides_chunk = RideHandler.get_user_rides_data(deviceId, chunk)

      chunked_conn
      |> chunk(Bson.encode(rides_chunk))
    end)

    chunked_conn
  end

  post "/authorise" do
    password = conn.body_params["password"]

    case AuthService.authorise_user(password) do
      %{authorised: false} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, ~s[{"authorised": false}])

      %{authorised: true, device_id: device_id} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, ~s[{"authorised": true, "device_id": "#{device_id}"}])
    end
  end

  get _ do
    send_resp(conn, 404, "Not found!")
  end
end

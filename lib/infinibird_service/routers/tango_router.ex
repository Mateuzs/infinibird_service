defmodule InfinibirdService.TangoRouter do
  use Plug.Router
  alias InfinibirdService.TangoController

  if System.get_env("MIX_ENV") === "prod" do
    plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
  end

  plug(BasicAuth,
    use_config: {:infinibird_service, :infinibird_service_basic_auth_config},
    custom_response: &InfinibirdService.Authentication.unauthorized_response/1
  )

  plug(:match)
  plug(:dispatch)

  get "/new-trip/:device_id" do
    token = TangoController.handle_new_trip("#{device_id}")

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, ~s[{"token": "#{token}"}])
  end

  get _ do
    send_resp(conn, 404, "Not found!")
  end
end

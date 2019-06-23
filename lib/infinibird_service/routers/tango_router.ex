defmodule InfinibirdService.TangoRouter do
  use Plug.Router

  plug(BasicAuth,
    use_config: {:infinibird_service, :infinibird_service_basic_auth_config},
    custom_response: &InfinibirdService.Authentication.unauthorized_response/1
  )

  plug(:match)
  plug(:dispatch)

  get "/data" do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, ~s[{"message": "Tango response"}])
  end

  get _ do
    send_resp(conn, 404, "Not found!")
  end
end

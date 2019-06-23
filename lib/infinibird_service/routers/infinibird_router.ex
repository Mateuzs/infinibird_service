defmodule InfinibirdService.InfinibirdRouter do
  use Plug.Router
  @infinibird_server InfinibirdService.Constants.infinibird_server()

  plug(BasicAuth,
    use_config: {:infinibird_service, :infinibird_service_basic_auth_config},
    custom_response: &InfinibirdService.Authentication.unauthorized_response/1
  )

  plug(:match)
  plug(:dispatch)

  if MIX_ENV == "prod" do
    plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
  end

  get "/summary" do
    {:ok, data} = GenServer.call(@infinibird_server, {:get_summary_data})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Bson.encode(data))
  end

  get "/trips" do
    {:ok, data} = GenServer.call(@infinibird_server, {:get_trip_data})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Bson.encode(data))
  end

  get _ do
    send_resp(conn, 404, "Not found!")
  end
end

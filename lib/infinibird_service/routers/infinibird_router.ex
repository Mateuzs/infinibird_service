defmodule InfinibirdService.InfinibirdRouter do
  use Plug.Router
  alias InfinibirdService.InfinibirdController

  if System.get_env("MIX_ENV") === "prod" do
    plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
  end

  plug(BasicAuth,
    use_config: {:infinibird_service, :infinibird_service_basic_auth_config},
    custom_response: &InfinibirdService.Authentication.unauthorized_response/1
  )

  plug(:match)
  plug(:dispatch)

  get "/summary" do
    data = InfinibirdController.get_summary_data()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Bson.encode(data))
  end

  get "/trips" do
    data = InfinibirdController.get_rides_data("9bac2143-3f85-44f6-ad56-b575549af9e4")
    IO.inspect(data)

    conn
    |> put_resp_content_type("application/bson")
    |> send_resp(200, Bson.encode(data))
  end

  get _ do
    send_resp(conn, 404, "Not found!")
  end
end

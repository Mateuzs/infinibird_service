defmodule InfinibirdService.Endpoint do
  use Plug.Router
  alias InfinibirdService.NewDataProvider

  if System.get_env("MIX_ENV") === "prod" do
    plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
  end

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/infinibird", to: InfinibirdService.InfinibirdRouter)
  forward("/tango", to: InfinibirdService.TangoRouter)

  match "/health" do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, ~s[{"message": "service is running",
                                    "version": "#{Mix.Project.config()[:version]}"}])
  end

  match "/test/:device_id" do
    result = NewDataProvider.get_data(device_id)

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, Jason.encode!(result))
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts),
    do: Plug.Cowboy.http(__MODULE__, [], [])
end

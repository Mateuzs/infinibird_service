defmodule InfinibirdService.Application do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("Service started on port 4000")

    Supervisor.start_link(children(), opts())
  end

  defp children do
    [
      InfinibirdService.Endpoint
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: InfinibirdService.Supervisor
    ]
  end
end

defmodule InfinibirdService.Application do
  use Application

  def start(_type, _args),
    do: Supervisor.start_link(children(), opts())

  defp children do
    [
      InfinibirdService.Endpoint,
      InfinibirdService.ServerSupervisor
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: InfinibirdService.Supervisor
    ]
  end
end

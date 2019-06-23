defmodule InfinibirdService.ServerSupervisor do
  use Supervisor
  alias InfinibirdService.Server

  def start_link(_options), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(_init_arg) do
    children = [
      {Server, [:success]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

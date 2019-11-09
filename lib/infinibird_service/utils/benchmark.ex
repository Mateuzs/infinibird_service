defmodule InfinibirdService.Benchmark do
  @spec measure(fun, [any]) :: float
  def measure(function, params) do
    function
    |> :timer.tc(params)
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end


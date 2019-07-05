defmodule InfinibirdService.Server do
  use GenServer
  alias InfinibirdService.{DataProvider, Constants}
  @infinibird_server Constants.infinibird_server()

  def start_link(state),
    do: GenServer.start_link(__MODULE__, state, name: @infinibird_server)

  def init(data), do: {:ok, data}

  ############### CALLBACKS  ###############

  def handle_call({:get_summary_data}, _from, state) do
    summary = DataProvider.get_summary_mock_data()
    charts = DataProvider.get_chart_mock_data()

    reply_success(%{charts: charts, summary: summary}, :ok, state)
  end

  def handle_call({:get_trip_data}, _from, state) do
    trip1_path = Path.expand("./lib/data/20190202T125015_20190202T142542.bson") |> Path.absname()
    {:ok, bson_data1} = File.read(trip1_path)

    trip2_path = Path.expand("./lib/data/20190329T170520_20190329T224221.bson") |> Path.absname()
    {:ok, bson_data2} = File.read(trip2_path)

    data = [
      trip1: DataProvider.get_trip_data(bson_data1),
      trip2: DataProvider.get_trip_data(bson_data2)
    ]

    reply_success(data, :ok, state)
  end

  ############### HELPERS  ###############

  defp reply_success(data, reply, state) do
    {:reply, {reply, data}, state}
  end
end

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

    data = %{
      trip1: %{
        name: "Trasa 1",
        points: get_trip_points(bson_data1)
      },
      trip2: %{
        name: "Trasa 2",
        points: get_trip_points(bson_data2)
      }
    }

    reply_success(data, :ok, state)
  end

  ############### HELPERS  ###############

  defp decode_bson_data(file) do
    case Bson.decode(file) do
      %Bson.Decoder.Error{} = error ->
        IO.puts(error)
        %{}

      %Bson.Decoder.Error{what: :buffer_not_empty, acc: _doc, rest: _rest} = error ->
        IO.puts(error)
        %{}

      # for some reasons the decoder decodes list in reversed order, so we need to prepare it
      [tables: data, device_id: device_id] ->
        reversed_data =
          data
          |> Enum.map(fn {key, list} -> {key, Enum.reverse(list)} end)

        Enum.reduce(reversed_data, %{device_id: device_id}, fn {key, list}, map ->
          Map.put(map, key, list)
        end)
    end
  end

  defp get_trip_points(data) do
    decode_bson_data(data)
    |> Map.get(:"/GPS_LOCATION")
    |> Enum.map(fn {_timestamp, list} -> [Keyword.get(list, :lat), Keyword.get(list, :lon)] end)
  end

  defp reply_success(data, reply, state) do
    {:reply, {reply, data}, state}
  end
end

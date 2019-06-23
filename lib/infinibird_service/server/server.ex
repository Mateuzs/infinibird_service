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
    {:ok, bson_data1} =
      File.read(Path.absname("infinibird_service/lib/data/20190202T125015_20190202T142542.bson"))

    {:ok, bson_data2} =
      File.read(Path.absname("infinibird_service/lib/data/20190329T170520_20190329T224221.bson"))

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

      decoded_data ->
        decoded_data
    end
  end

  defp get_trip_points(data) do
    trip =
      decode_bson_data(data)
      |> Map.get(:tables)
      |> Map.get(:"/GPS_LOCATION")

    Map.keys(trip)
    |> Enum.map(fn key ->
      {num, _rest} = Atom.to_string(key) |> Integer.parse()
      num
    end)
    |> Enum.sort(&(&1 <= &2))
    |> Enum.map(fn key -> Integer.to_string(key, 10) |> String.to_atom() end)
    |> Enum.map(fn key ->
      [Map.get(trip, key)[:lat], Map.get(trip, key)[:lon]]
    end)
  end

  defp reply_success(data, reply, state) do
    {:reply, {reply, data}, state}
  end
end

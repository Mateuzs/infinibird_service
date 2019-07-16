defmodule InfinibirdService.InfinibirdController do
  alias InfinibirdService.DataProvider

  def get_summary_data() do
    summary = DataProvider.get_summary_mock_data()
    charts = DataProvider.get_chart_mock_data()

    %{charts: charts, summary: summary}
  end

  def get_trip_data() do
    trip1_path = Path.expand("./lib/data/20190202T125015_20190202T142542.bson") |> Path.absname()
    {:ok, bson_data1} = File.read(trip1_path)

    trip2_path = Path.expand("./lib/data/20190329T170520_20190329T224221.bson") |> Path.absname()
    {:ok, bson_data2} = File.read(trip2_path)

    data = [
      trip1: DataProvider.get_trip_data(bson_data1),
      trip2: DataProvider.get_trip_data(bson_data2)
    ]

    data
  end
end

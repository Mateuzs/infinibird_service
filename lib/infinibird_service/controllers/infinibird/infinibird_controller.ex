defmodule InfinibirdService.InfinibirdController do
  alias InfinibirdService.DataProvider

  @spec get_summary_data :: %{
          charts: %{
            area_chart_data: %{
              "2013-07-27 07:00:00 UTC": 2,
              "2013-07-27 07:01:00 UTC": 5,
              "2013-07-27 07:02:00 UTC": 3,
              "2013-07-27 07:03:00 UTC": 3,
              "2013-07-27 07:04:00 UTC": 2,
              "2013-07-27 07:05:00 UTC": 5,
              "2013-07-27 07:06:00 UTC": 1,
              "2013-07-27 07:07:00 UTC": 3,
              "2013-07-27 07:08:00 UTC": 4,
              "2013-07-27 07:09:00 UTC": 3,
              "2013-07-27 07:10:00 UTC": 2
            },
            column_chart_data: [[...], ...],
            geo_chart_data: [[...], ...],
            line_chart_data: %{
              "2013-02-10 00:00:00 -0800": 11,
              "2013-02-11 00:00:00 -0800": 6,
              "2013-02-12 00:00:00 -0800": 3,
              "2013-02-13 00:00:00 -0800": 2,
              "2013-02-14 00:00:00 -0800": 5,
              "2013-02-15 00:00:00 -0800": 3,
              "2013-02-16 00:00:00 -0800": 8,
              "2013-02-17 00:00:00 -0800": 6,
              "2013-02-18 00:00:00 -0800": 6,
              "2013-02-19 00:00:00 -0800": 12,
              "2013-02-20 00:00:00 -0800": 5,
              "2013-02-21 00:00:00 -0800": 5,
              "2013-02-22 00:00:00 -0800": 3,
              "2013-02-23 00:00:00 -0800": 1,
              "2013-02-24 00:00:00 -0800": 10,
              "2013-02-25 00:00:00 -0800": 1,
              "2013-02-26 00:00:00 -0800": 3,
              "2013-02-27 00:00:00 -0800": 2,
              "2013-02-28 00:00:00 -0800": 3,
              "2013-03-01 00:00:00 -0800": 2,
              "2013-03-02 00:00:00 -0800": 8
            },
            multilines_chart_data: [map, ...],
            pie_chart_data: [[...], ...]
          },
          summary: %{
            amount_of_km: 12583,
            average_speed: 67,
            number_of_trips: 218,
            safety_index: <<_::48>>
          }
        }
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

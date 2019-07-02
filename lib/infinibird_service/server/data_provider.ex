defmodule InfinibirdService.DataProvider do
  def get_trip_data(data) do
    decoded_data = decode_bson_data(data)

    start_timestamp =
      decoded_data
      |> Map.get(:"/GPS_LOCATION")
      |> List.first()
      |> elem(1)
      |> Keyword.get(:t)

    end_timestamp =
      decoded_data
      |> Map.get(:"/GPS_LOCATION")
      |> List.last()
      |> elem(1)
      |> Keyword.get(:t)

    travel_time_minutes =
      (DateTime.diff(
         DateTime.from_unix!(end_timestamp, :millisecond),
         DateTime.from_unix!(start_timestamp, :millisecond),
         1
       ) / 60)
      |> Kernel.trunc()

    start_time = format_time(start_timestamp)
    end_time = format_time(end_timestamp)

    points =
      decoded_data
      |> Map.get(:"/GPS_LOCATION")
      |> Enum.map(fn {_timestamp, list} -> [Keyword.get(list, :lat), Keyword.get(list, :lon)] end)

    distance_meters =
      points
      |> Enum.map(fn [lat, lon] -> {lon, lat} end)
      |> Distance.GreatCircle.distance()
      |> Kernel.trunc()

    %{
      name: start_time,
      start_time: start_time,
      end_time: end_time,
      travel_time_minutes: travel_time_minutes,
      distance_meters: distance_meters,
      points: points
    }
  end

  defp decode_bson_data(file) do
    case Bson.decode(file) do
      %Bson.Decoder.Error{} = error ->
        IO.puts(error)
        %{}

      %Bson.Decoder.Error{what: :buffer_not_empty, acc: _doc, rest: _rest} = error ->
        IO.puts(error)
        %{}

      # for some reasons the decoder decodes list in reversed order, so we need to prepare it
      [device_id: device_id, tables: data] ->
        Enum.reduce(data, %{device_id: device_id}, fn {key, list}, map ->
          Map.put(map, key, list)
        end)
    end
  end

  defp format_time(time) do
    time
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.to_string()
    |> String.split(".")
    |> List.first()
  end

  def get_chart_mock_data(),
    do: %{
      pie_chart_data: [
        ["Coconut", 50],
        ["Blueberry", 44],
        ["Strawberry", 23],
        ["Banana", 22],
        ["Apple", 21],
        ["Grape", 13]
      ],
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
      geo_chart_data: [
        ["United States", 101],
        ["Russia", 63],
        ["Germany", 65],
        ["China", 50],
        ["France", 37],
        ["Italy", 35],
        ["Australia", 41]
      ],
      multilines_chart_data: [
        %{
          name: "Workout",
          data: %{
            "2013-02-10 00:00:00 -0800": 3,
            "2013-02-17 00:00:00 -0800": 3,
            "2013-02-24 00:00:00 -0800": 3,
            "2013-03-03 00:00:00 -0800": 1,
            "2013-03-10 00:00:00 -0800": 4,
            "2013-03-17 00:00:00 -0700": 3,
            "2013-03-24 00:00:00 -0700": 2,
            "2013-03-31 00:00:00 -0700": 3
          }
        },
        %{
          name: "Eat breakfast",
          data: %{
            "2013-02-10 00:00:00 -0800": 3,
            "2013-02-17 00:00:00 -0800": 2,
            "2013-02-24 00:00:00 -0800": 1,
            "2013-03-03 00:00:00 -0800": 0,
            "2013-03-10 00:00:00 -0800": 2,
            "2013-03-17 00:00:00 -0700": 2,
            "2013-03-24 00:00:00 -0700": 3,
            "2013-03-31 00:00:00 -0700": 0
          }
        }
      ],
      column_chart_data: [[0, 32], [1, 46], [2, 28], [3, 21], [4, 20], [5, 13], [6, 27]]
    }

  def get_summary_mock_data() do
    %{
      amount_of_km: 12583,
      number_of_trips: 218,
      average_speed: 67,
      safety_index: "89/100"
    }
  end
end

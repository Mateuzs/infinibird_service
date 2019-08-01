defmodule InfinibirdService.RideDataExtractors do
  def extract_ride(device_id, ride_file) do
    Path.expand("./lib/rides/#{device_id}/maneuvers/#{ride_file}")
    |> Path.absname()
    |> File.read!()
    |> Jason.decode!()
  end

  def extract_start_time(ride) do
    List.first(ride)
    |> get_in(["timeRange", "beginning"])
    |> String.split(".")
    |> List.first()
    |> String.replace("T", " ")
  end

  def extract_end_time(ride) do
    List.last(ride)
    |> get_in(["timeRange", "end"])
    |> String.split(".")
    |> List.first()
    |> String.replace("T", " ")
  end

  def extract_travel_points(ride) do
    Enum.filter(ride, fn maneuver -> Map.get(maneuver, "beginningGpsPosition") !== nil end)
    |> Enum.map(fn maneuver ->
      [
        [
          get_in(maneuver, ["beginningGpsPosition", "latitude"]),
          get_in(maneuver, ["beginningGpsPosition", "longitude"])
        ],
        [
          get_in(maneuver, ["endGpsPosition", "latitude"]),
          get_in(maneuver, ["endGpsPosition", "longitude"])
        ]
      ]
    end)
    |> Enum.flat_map(fn [[a, b], [c, d]] -> [[a, b], [c, d]] end)
  end

  def count_distance_meters(points) do
    points
    |> Enum.map(fn [lat, lon] -> {lon, lat} end)
    |> Distance.GreatCircle.distance()
    |> Kernel.trunc()
  end

  def count_travel_time_minutes(ride) do
    (DateTime.diff(
       DateTime.from_iso8601(
         List.last(ride)
         |> get_in(["timeRange", "end"])
       )
       |> elem(1),
       DateTime.from_iso8601(
         List.first(ride)
         |> get_in(["timeRange", "beginning"])
       )
       |> elem(1),
       :second
     ) / 60)
    |> Kernel.trunc()
  end
end

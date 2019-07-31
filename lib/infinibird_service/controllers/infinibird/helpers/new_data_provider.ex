defmodule InfinibirdService.NewDataProvider do
  def get_data(device_id) do
    ride_files =
      Path.expand("./lib/rides/#{device_id}/maneuvers/")
      |> Path.absname()
      |> File.ls!()

    rides =
      Enum.map(ride_files, fn ride_file ->
        ride =
          Path.expand("./lib/rides/#{device_id}/maneuvers/#{ride_file}")
          |> Path.absname()
          |> File.read!()
          |> Jason.decode!()

        start_time =
          List.first(ride)
          |> get_in(["timeRange", "beginning"])
          |> String.split(".")
          |> List.first()
          |> String.replace("T", " ")

        end_time =
          List.last(ride)
          |> get_in(["timeRange", "end"])
          |> String.split(".")
          |> List.first()
          |> String.replace("T", " ")

        travel_time_minutes =
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

        points =
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

        distance_meters =
          points
          |> Enum.map(fn [lat, lon] -> {lon, lat} end)
          |> Distance.GreatCircle.distance()
          |> Kernel.trunc()

        {:"ride#{Enum.find_index(ride_files, &(&1 === ride_file))}",
         %{
           name: start_time,
           distance_meters: distance_meters,
           travel_time_minutes: travel_time_minutes,
           start_time: start_time,
           end_time: end_time,
           points: points
         }}
      end)
      |> Enum.into(%{})

    rides
  end
end

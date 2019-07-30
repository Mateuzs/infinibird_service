defmodule InfinibirdService.NewDataProvider do
  def get_data(device_id) do
    rides =
      Path.expand("./lib/rides/#{device_id}/maneuvers/")
      |> Path.absname()
      |> File.ls!()

    points =
      Enum.map(rides, fn ride ->
        Path.expand("./lib/rides/#{device_id}/maneuvers/#{ride}")
        |> Path.absname()
        |> File.read!()
        |> Jason.decode!()
        |> Enum.filter(fn maneuver -> Map.get(maneuver, "beginningGpsPosition") !== nil end)
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
      end)

    points
  end
end

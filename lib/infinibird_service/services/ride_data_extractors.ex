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
        lat: get_in(maneuver, ["beginningGpsPosition", "latitude"]),
        lon: get_in(maneuver, ["beginningGpsPosition", "longitude"]),
        alt: get_in(maneuver, ["beginningGpsPosition", "altitude"]),
        mps: get_in(maneuver, ["beginningGpsPosition", "speedInMps"]),
        tim: extract_time(get_in(maneuver, ["beginningGpsPosition", "timestamp"]))
      ]
    end)
  end

  def count_distance_meters(points) do
    points
    |> Enum.map(fn list -> {Keyword.get(list, :lon), Keyword.get(list, :lat)} end)
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

  def count_decelerations(ride) do
    ride
    |> Enum.count(fn e ->
      e["maneuverType"] === "deceleration" ||
        e["maneuverType"] === "decelerationFollowedByAcceleration"
    end)
  end

  def count_accelerations(ride) do
    ride
    |> Enum.count(fn e ->
      e["maneuverType"] === "acceleration" ||
        e["maneuverType"] === "accelerationFollowedByDeceleration"
    end)
  end

  def count_stoppings(ride) do
    ride
    |> Enum.count(fn e -> e["maneuverType"] === "stopping" end)
  end

  def count_left_turns(ride) do
    ride
    |> Enum.count(fn e -> e["maneuverType"] === "leftTurn" end)
  end

  def count_right_turns(ride) do
    ride
    |> Enum.count(fn e -> e["maneuverType"] === "rightTurn" end)
  end

  def find_max_speed(ride) do
    ride
    |> Enum.filter(fn maneuver -> Map.get(maneuver, "beginningGpsPosition") !== nil end)
    |> Enum.max_by(fn e -> get_in(e, ["beginningGpsPosition", "speedInMps"]) end)
    |> get_in(["beginningGpsPosition", "speedInMps"])
  end

  def count_speed_profile(ride) do
    Enum.filter(ride, fn maneuver ->
      Map.get(maneuver, "beginningGpsPosition") !== nil
    end)
    |> Enum.reduce(
      {0, 0, 0, 0, 0, 0},
      fn maneuver,
         {distance_in_speed_0_25, distance_in_speed_25_50, distance_in_speed_50_75,
          distance_in_speed_75_100, distance_in_speed_100_125, distance_in_speed_over_125} ->
        beginning_time = get_in(maneuver, ["beginningGpsPosition", "timestamp"])
        end_time = get_in(maneuver, ["endGpsPosition", "timestamp"])

        seconds =
          DateTime.diff(
            DateTime.from_iso8601(end_time) |> elem(1),
            DateTime.from_iso8601(beginning_time) |> elem(1),
            :second
          )

        distance_meters =
          [
            {get_in(maneuver, ["beginningGpsPosition", "longitude"]),
             get_in(maneuver, ["beginningGpsPosition", "latitude"])},
            {get_in(maneuver, ["endGpsPosition", "longitude"]),
             get_in(maneuver, ["endGpsPosition", "latitude"])}
          ]
          |> Distance.GreatCircle.distance()

        avg_speed_ms =
          case seconds do
            0 -> 0
            _more_than_0 -> distance_meters / seconds
          end

        case avg_speed_ms * 3.6 do
          speed when speed < 25 ->
            {distance_in_speed_0_25 + distance_meters, distance_in_speed_25_50,
             distance_in_speed_50_75, distance_in_speed_75_100, distance_in_speed_100_125,
             distance_in_speed_over_125}

          speed when speed < 50 ->
            {distance_in_speed_0_25, distance_in_speed_25_50 + distance_meters,
             distance_in_speed_50_75, distance_in_speed_75_100, distance_in_speed_100_125,
             distance_in_speed_over_125}

          speed when speed < 75 ->
            {distance_in_speed_0_25, distance_in_speed_25_50,
             distance_in_speed_50_75 + distance_meters, distance_in_speed_75_100,
             distance_in_speed_100_125, distance_in_speed_over_125}

          speed when speed < 100 ->
            {distance_in_speed_0_25, distance_in_speed_25_50, distance_in_speed_50_75,
             distance_in_speed_75_100 + distance_meters, distance_in_speed_100_125,
             distance_in_speed_over_125}

          speed when speed < 125 ->
            {distance_in_speed_0_25, distance_in_speed_25_50, distance_in_speed_50_75,
             distance_in_speed_75_100, distance_in_speed_100_125 + distance_meters,
             distance_in_speed_over_125}

          speed ->
            {distance_in_speed_0_25, distance_in_speed_25_50, distance_in_speed_50_75,
             distance_in_speed_75_100, distance_in_speed_100_125,
             distance_in_speed_over_125 + distance_meters}
        end
      end
    )
  end

  defp extract_time(timestamp) do
    timestamp
    |> String.split(".")
    |> List.first()
    |> String.split("T")
    |> List.last()
  end
end

defmodule InfinibirdService.RideHandler do
  import Ecto.Query
  alias InfinibirdDB.{RideMetrics, Repo}
  alias InfinibirdService.RideDataExtractors

  def process_new_ride(device_id, ride_id) do
    ride = RideDataExtractors.extract_ride(device_id, ride_id)
    start_time = RideDataExtractors.extract_start_time(ride)
    [date, time] = String.split(start_time, " ")

    decelerations = RideDataExtractors.count_decelerations(ride)
    accelerations = RideDataExtractors.count_accelerations(ride)
    stoppings = RideDataExtractors.count_stoppings(ride)
    left_turns = RideDataExtractors.count_left_turns(ride)
    right_turns = RideDataExtractors.count_right_turns(ride)
    travel_time_minutes = RideDataExtractors.count_travel_time_minutes(ride)
    max_speed_kmh = Kernel.trunc(RideDataExtractors.find_max_speed(ride) * 3.6)
    points = RideDataExtractors.extract_travel_points(ride)
    distance_meters = RideDataExtractors.count_distance_meters(points)

    {distance_in_speed_0_25, distance_in_speed_25_50, distance_in_speed_50_75,
     distance_in_speed_75_100, distance_in_speed_100_125,
     distance_in_speed_over_125} = RideDataExtractors.count_speed_profile(ride)

    avg_speed_kmh =
      case travel_time_minutes do
        0 -> 0
        _more_than_0 -> (distance_meters / 1000 / (travel_time_minutes / 60)) |> Kernel.trunc()
      end

    IO.inspect(
      {distance_in_speed_0_25, distance_in_speed_25_50, distance_in_speed_50_75,
       distance_in_speed_75_100, distance_in_speed_100_125, distance_in_speed_over_125}
    )

    IO.inspect(distance_meters)

    ride_metrics_id =
      Repo.insert(
        %RideMetrics{
          device_id: device_id,
          tavel_time_minutes: travel_time_minutes,
          max_speed_kmh: max_speed_kmh,
          avg_speed_kmh: avg_speed_kmh,
          accelerations: accelerations,
          decelerations: decelerations,
          stoppings: stoppings,
          right_turns: right_turns,
          left_turns: left_turns,
          distance_kmh: Kernel.trunc(distance_meters / 1000),
          distance_on_speed_below_25_kmh: Kernel.trunc(distance_in_speed_0_25 / 1000),
          distance_on_speed_between_25_and_50_kmh: Kernel.trunc(distance_in_speed_25_50 / 1000),
          distance_on_speed_between_50_and_75_kmh: Kernel.trunc(distance_in_speed_50_75 / 1000),
          distance_on_speed_between_75_and_100_kmh: Kernel.trunc(distance_in_speed_75_100 / 1000),
          distance_on_speed_between_100_and_125_kmh:
            Kernel.trunc(distance_in_speed_100_125 / 1000),
          distance_on_speed_over_125_kmh: Kernel.trunc(distance_in_speed_over_125 / 1000)
        },
        returning: [:ride_metrics_id]
      )

    IO.inspect(ride_metrics_id)
  end
end

defmodule InfinibirdService.RideHandler do
  import Ecto.Query
  alias InfinibirdDB.{RideMetrics, RideTimeCharacteristics, Repo}
  alias InfinibirdService.{RideDataExtractors}

  @spec process_new_ride(any, any) :: any
  def process_new_ride(device_id, ride_id) do
    # Ride Metrics
    ride = RideDataExtractors.extract_ride(device_id, ride_id)
    start_time = RideDataExtractors.extract_start_time(ride)
    [date, time] = String.split(start_time, " ")
    decelerations = RideDataExtractors.count_decelerations(ride)
    accelerations = RideDataExtractors.count_accelerations(ride)
    stoppings = RideDataExtractors.count_stoppings(ride)
    left_turns = RideDataExtractors.count_left_turns(ride)
    right_turns = RideDataExtractors.count_right_turns(ride)
    travel_time_minutes = RideDataExtractors.count_travel_time_minutes(ride)
    max_speed_kmh = Kernel.round(RideDataExtractors.find_max_speed(ride) * 3.6)
    points = RideDataExtractors.extract_travel_points(ride)
    distance_meters = RideDataExtractors.count_distance_meters(points)
    avg_speed_kmh = RideDataExtractors.get_avg_speed_kmh(distance_meters, travel_time_minutes)
    max_acceleration = RideDataExtractors.count_max_acceleration(ride)

    {distance_in_speed_0_25, distance_in_speed_25_50, distance_in_speed_50_75,
     distance_in_speed_75_100, distance_in_speed_100_125,
     distance_in_speed_over_125} = RideDataExtractors.count_speed_profile(ride)

    # Ride Time Charcetristics
    day_of_week = RideDataExtractors.get_day_of_week(ride)
    month_of_year = RideDataExtractors.get_month_of_year(ride)
    time_of_day = RideDataExtractors.get_time_of_day(ride)
    season = RideDataExtractors.get_season(ride)

    {:ok, inserted} =
      Repo.insert(
        %RideMetrics{
          device_id: device_id,
          travel_time_minutes: travel_time_minutes,
          max_speed_kmh: max_speed_kmh,
          avg_speed_kmh: avg_speed_kmh,
          max_acceleration: max_acceleration,
          accelerations: accelerations,
          decelerations: decelerations,
          stoppings: stoppings,
          right_turns: right_turns,
          left_turns: left_turns,
          distance_m: distance_meters,
          distance_m_speed_below_25_kmh: Kernel.round(distance_in_speed_0_25),
          distance_m_speed_25_50_kmh: Kernel.round(distance_in_speed_25_50),
          distance_m_speed_50_75_kmh: Kernel.round(distance_in_speed_50_75),
          distance_m_speed_75_100_kmh: Kernel.round(distance_in_speed_75_100),
          distance_m_speed_100_125_kmh: Kernel.round(distance_in_speed_100_125),
          distance_m_speed_over_125_kmh: Kernel.round(distance_in_speed_over_125)
        },
        returning: [:ride_metrics_id]
      )

    ride_metrics_id = inserted.ride_metrics_id

    Repo.insert(%RideTimeCharacteristics{
      ride_metrics_id: ride_metrics_id,
      date: Date.from_iso8601!(date),
      time: Time.from_iso8601!(time),
      day: day_of_week,
      month: month_of_year,
      time_of_day: time_of_day,
      season: season
    })
  end

  def get_user_ride_file_names(device_id) do
    case Path.expand("./lib/rides/#{device_id}/maneuvers/")
         |> Path.absname()
         |> File.ls() do
      {:ok, ride_files} -> ride_files
      {:error, _err} -> []
    end
  end

  def get_user_rides_data(device_id, ride_files) do
    rides =
      Enum.map(ride_files, fn ride_file ->
        ride = RideDataExtractors.extract_ride(device_id, ride_file)
        start_time = RideDataExtractors.extract_start_time(ride)
        end_time = RideDataExtractors.extract_end_time(ride)
        deceleration_amount = RideDataExtractors.count_decelerations(ride)
        acceleration_amount = RideDataExtractors.count_accelerations(ride)
        stoppings_amount = RideDataExtractors.count_stoppings(ride)
        left_turns_amount = RideDataExtractors.count_left_turns(ride)
        right_turns_amount = RideDataExtractors.count_right_turns(ride)
        travel_time_minutes = RideDataExtractors.count_travel_time_minutes(ride)
        points = RideDataExtractors.extract_travel_points(ride)
        max_speed = RideDataExtractors.find_max_speed(ride)
        distance_meters = RideDataExtractors.count_distance_meters(points)

        {:"#{ride_file}",
         %{
           name: start_time,
           distance_meters: distance_meters,
           travel_time_minutes: travel_time_minutes,
           start_time: start_time,
           end_time: end_time,
           points: points,
           deceleration_amount: deceleration_amount,
           acceleration_amount: acceleration_amount,
           stoppings_amount: stoppings_amount,
           left_turns_amount: left_turns_amount,
           right_turns_amount: right_turns_amount,
           max_speed: max_speed
         }}
      end)

    rides
  end

  def get_summary_data(device_id) do
    q =
      from(rd in "ride_metrics",
        join: rts in "ride_time_characteristics",
        on: rd.ride_metrics_id == rts.ride_metrics_id,
        where: rd.device_id == ^device_id,
        order_by: [rts.date, rts.time],
        select: %{
          travel_time_minutes: rd.travel_time_minutes,
          max_speed_kmh: rd.max_speed_kmh,
          avg_speed_kmh: rd.avg_speed_kmh,
          max_acceleration_ms: rd.max_acceleration,
          accelerations: rd.accelerations,
          decelerations: rd.decelerations,
          stoppings: rd.stoppings,
          right_turns: rd.right_turns,
          left_turns: rd.left_turns,
          distance_m: rd.distance_m,
          distance_m_speed_below_25_kmh: rd.distance_m_speed_below_25_kmh,
          distance_m_speed_25_50_kmh: rd.distance_m_speed_25_50_kmh,
          distance_m_speed_50_75_kmh: rd.distance_m_speed_50_75_kmh,
          distance_m_speed_75_100_kmh: rd.distance_m_speed_75_100_kmh,
          distance_m_speed_100_125_kmh: rd.distance_m_speed_100_125_kmh,
          distance_m_speed_over_125_kmh: rd.distance_m_speed_over_125_kmh,
          date: rts.date,
          time: rts.time,
          day: rts.day,
          month: rts.month,
          time_of_day: rts.time_of_day,
          season: rts.season
        }
      )

    rides_data = Repo.all(q)

    rides_data
  end
end

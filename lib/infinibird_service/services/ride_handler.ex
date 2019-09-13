defmodule InfinibirdService.RideHandler do
  import Ecto.Query
  alias InfinibirdDB.{RideMetrics, RideTimeCharacteristics, Repo}
  alias InfinibirdService.{RideDataExtractors, DataProvider}

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
    max_speed_kmh = Kernel.trunc(RideDataExtractors.find_max_speed(ride) * 3.6)
    points = RideDataExtractors.extract_travel_points(ride)
    distance_meters = RideDataExtractors.count_distance_meters(points)
    avg_speed_kmh = RideDataExtractors.get_avg_speed_kmh(distance_meters, travel_time_minutes)

    {distance_in_speed_0_25, distance_in_speed_25_50, distance_in_speed_50_75,
     distance_in_speed_75_100, distance_in_speed_100_125,
     distance_in_speed_over_125} = RideDataExtractors.count_speed_profile(ride)

    # Ride Time Charcetristics
    day_of_week = RideDataExtractors.get_day_of_week(ride)
    month_of_year = RideDataExtractors.get_month_of_year(ride)
    time_of_day = RideDataExtractors.get_time_of_day(ride)
    season = RideDataExtractors.get_season(ride)

    # debugging purposes
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

    Repo.insert(%RideTimeCharacteristics{
      ride_metrics_id: ride_metrics_id,
      date: date,
      time: time,
      day: day_of_week,
      month: month_of_year,
      time_of_day: time_of_day,
      season: season
    })

    IO.inspect(ride_metrics_id)
  end

  def get_user_rides_data(device_id) do
    ride_files =
      Path.expand("./lib/rides/#{device_id}/maneuvers/")
      |> Path.absname()
      |> File.ls!()

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

        {:"ride#{Enum.find_index(ride_files, &(&1 === ride_file))}",
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

  def get_summary_data() do
    summary = DataProvider.get_summary_mock_data()
    charts = DataProvider.get_chart_mock_data()

    %{charts: charts, summary: summary}
  end
end

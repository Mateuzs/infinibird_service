defmodule InfinibirdService.InfinibirdController do
  alias InfinibirdService.DataProvider
  alias InfinibirdService.RideDataExtractors

  def get_summary_data() do
    summary = DataProvider.get_summary_mock_data()
    charts = DataProvider.get_chart_mock_data()

    %{charts: charts, summary: summary}
  end

  def get_rides_data(device_id) do
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
end

defmodule InfinibirdDB.RideMetrics do
  use Ecto.Schema

  @primary_key {:ride_metrics_id, :id, []}
  schema "ride_metrics" do
    field(:device_id, :string)
    field(:tavel_time_minutes, :integer)
    field(:max_speed_kmh, :integer)
    field(:avg_speed_kmh, :integer)
    field(:accelerations, :integer)
    field(:decelerations, :integer)
    field(:stoppings, :integer)
    field(:right_turns, :integer)
    field(:left_turns, :integer)
    field(:distance_kmh, :integer)
    field(:distance_on_speed_below_25_kmh, :integer)
    field(:distance_on_speed_between_25_and_50_kmh, :integer)
    field(:distance_on_speed_between_50_and_75_kmh, :integer)
    field(:distance_on_speed_between_75_and_100_kmh, :integer)
    field(:distance_on_speed_between_100_and_125_kmh, :integer)
    field(:distance_on_speed_over_125_kmh, :integer)

    has_one(:ride_time_characteristics, InfinibirdDB.RideTimeCharacteristics)

    belongs_to(:user, InfinibirdDB.User, references: :device_id)
  end
end

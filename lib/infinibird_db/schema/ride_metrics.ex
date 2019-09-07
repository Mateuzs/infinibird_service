defmodule InfinibirdDB.RideMetrics do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ride_metrics" do
    field(:ride_metric_id, :id, primary_key: true)
    field(:device_id, :string)
    field(:tavel_time_minutes, :integer)
    field(:max_speed_kmh, :integer)
    field(:avg_speed_kmh, :integer)
    field(:accelerations, :integer)
    field(:decelerations, :integer)
    field(:stoppings, :integer)
    field(:rightTurns, :integer)
    field(:leftTurns, :integer)
    field(:distance_kmh, :integer)
    field(:distance_on_speed_below_25_kmh, :integer)
    field(:distance_on_speed_between_25_and_50_kmh, :integer)
    field(:distance_on_speed_between_50_and_75_kmh, :integer)
    field(:distance_on_speed_between_75_and_100_kmh, :integer)
    field(:distance_on_speed_between_100_and_125_kmh, :integer)
    field(:distance_on_speed_over_125_kmh, :integer)

    has_one(:ride_time_characteristics, InfinibirdDB.RideTimeCharacteristics)
    belongs_to(:users, InfinibirdDB.Users)
  end
end

defmodule InfinibirdDB.RideMetrics do
  use Ecto.Schema

  @primary_key {:ride_metrics_id, :id, []}
  schema "ride_metrics" do
    field(:device_id, :string)
    field(:travel_time_minutes, :integer)
    field(:max_speed_kmh, :integer)
    field(:avg_speed_kmh, :integer)
    field(:max_acceleration, :float)
    field(:accelerations, :integer)
    field(:decelerations, :integer)
    field(:stoppings, :integer)
    field(:right_turns, :integer)
    field(:left_turns, :integer)
    field(:distance_m, :integer)
    field(:distance_m_speed_below_25_kmh, :integer)
    field(:distance_m_speed_25_50_kmh, :integer)
    field(:distance_m_speed_50_75_kmh, :integer)
    field(:distance_m_speed_75_100_kmh, :integer)
    field(:distance_m_speed_100_125_kmh, :integer)
    field(:distance_m_speed_over_125_kmh, :integer)

    has_one(:ride_time_characteristics, InfinibirdDB.RideTimeCharacteristics,
      foreign_key: :ride_metrics_id
    )

    belongs_to(:user, InfinibirdDB.User, references: :device_id)
  end
end

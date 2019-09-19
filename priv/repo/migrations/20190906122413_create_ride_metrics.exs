defmodule Infinibird.Repo.Migrations.CreateRideMetrics do
  use Ecto.Migration

  def change do
    create table(:ride_metrics, primary_key: false) do
      add(:ride_metrics_id, :serial, primary_key: true)

      add(
        :device_id,
        references(:users, column: :device_id, type: :string, on_delete: :delete_all),
        null: false
      )

      add(:travel_time_minutes, :integer, null: false)
      add(:max_speed_kmh, :integer, null: false)
      add(:avg_speed_kmh, :integer, null: false)
      add(:max_acceleration, :float, null: false)
      add(:accelerations, :integer, null: false)
      add(:decelerations, :integer, null: false)
      add(:stoppings, :integer, null: false)
      add(:right_turns, :integer, null: false)
      add(:left_turns, :integer, null: false)
      add(:distance_m, :integer, null: false)
      add(:distance_m_speed_below_25_kmh, :integer, null: false)
      add(:distance_m_speed_25_50_kmh, :integer, null: false)
      add(:distance_m_speed_50_75_kmh, :integer, null: false)
      add(:distance_m_speed_75_100_kmh, :integer, null: false)
      add(:distance_m_speed_100_125_kmh, :integer, null: false)
      add(:distance_m_speed_over_125_kmh, :integer, null: false)
    end

    create(index("ride_metrics", :device_id))
  end
end

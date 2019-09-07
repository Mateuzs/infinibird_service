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

      add(:tavel_time_minutes, :integer, null: false)
      add(:max_speed_kmh, :integer, null: false)
      add(:avg_speed_kmh, :integer, null: false)
      add(:accelerations, :integer, null: false)
      add(:decelerations, :integer, null: false)
      add(:stoppings, :integer, null: false)
      add(:rightTurns, :integer, null: false)
      add(:leftTurns, :integer, null: false)
      add(:distance_kmh, :integer, null: false)
      add(:distance_on_speed_below_25_kmh, :integer, null: false)
      add(:distance_on_speed_between_25_and_50_kmh, :integer, null: false)
      add(:distance_on_speed_between_50_and_75_kmh, :integer, null: false)
      add(:distance_on_speed_between_75_and_100_kmh, :integer, null: false)
      add(:distance_on_speed_between_100_and_125_kmh, :integer, null: false)
      add(:distance_on_speed_over_125_kmh, :integer, null: false)
    end

    create(index("ride_metrics", :device_id))
  end
end

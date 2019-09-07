defmodule Infinibird.Repo.Migrations.CreateRideTimeCharacteristics do
  use Ecto.Migration

  def change do
    create table(:ride_time_characteristics, primary_key: false) do
      add(:ride_time_characteristics_id, :serial, primary_key: true)

      add(
        :ride_metrics_id,
        references(:ride_metrics, column: :ride_metrics_id, on_delete: :delete_all)
      )

      add(:date, :date, null: false)
      add(:time, :time, null: false)
      add(:day, :string, null: false)
      add(:month, :string, null: false)
      add(:time_of_day, :string, null: false)
      add(:season, :string, null: false)
    end

    create(index("ride_time_characteristics", :ride_time_characteristics_id))
    create(index("ride_time_characteristics", :ride_metrics_id))
  end
end

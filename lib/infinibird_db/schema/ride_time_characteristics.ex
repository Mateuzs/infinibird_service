defmodule InfinibirdDB.RideTimeCharacteristics do
  use Ecto.Schema

  schema "ride_time_characteristics" do
    field(:ride_time_characteristics_id, :id, primary_key: true)
    field(:ride_metrics_id, :id)
    field(:date, :date)
    field(:time, :time)
    field(:day, :string)
    field(:month, :string)
    field(:time_of_day, :string)
    field(:season, :string)
  end
end

defmodule InfinibirdDB.RideTimeCharacteristics do
  use Ecto.Schema

  @primary_key {:ride_time_characteristics_id, :id, []}
  schema "ride_time_characteristics" do
    field(:ride_metrics_id, :id)
    field(:date, :date)
    field(:time, :time)
    field(:day, :string)
    field(:month, :string)
    field(:time_of_day, :string)
    field(:season, :string)
  end
end

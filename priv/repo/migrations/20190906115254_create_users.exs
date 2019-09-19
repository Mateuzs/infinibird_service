defmodule Infinibird.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:device_id, :string, primary_key: true)
      add(:token, :string, null: false)
      add(:password, :string, null: false)
    end

    create(index("users", :device_id))
    create(index("users", :password))
  end
end

defmodule InfinibirdService.AuthService do
  import Ecto.Query, only: [from: 2]
  alias InfinibirdDB.{User, Repo}

  def authorise_user(params) do
    password = params["password"]

    case Repo.get_by(User, password: password) do
      nil -> %{authorised: false}
      record -> %{authorised: true, device_id: record.device_id}
    end
  end
end

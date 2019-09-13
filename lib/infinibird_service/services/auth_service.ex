defmodule InfinibirdService.AuthService do
  import Ecto.Query, only: [from: 2]
  alias InfinibirdDB.{User, Repo}

  def authorise_user(params) do
    password = params["password"]

    case Repo.exists?(from(u in User, where: u.password == ^password)) do
      true -> %{authorised: true}
      false -> %{authorised: false}
    end
  end
end

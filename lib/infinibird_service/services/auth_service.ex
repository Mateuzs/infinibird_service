defmodule InfinibirdService.AuthService do
  alias InfinibirdDB.{User, Repo}

  @spec authorise_user(any) :: %{:authorised => boolean, optional(:device_id) => any}
  def authorise_user(password) do
    case Repo.get_by(User, password: password) do
      nil -> %{authorised: false}
      record -> %{authorised: true, device_id: record.device_id}
    end
  end
end

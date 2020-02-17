defmodule Spendable.Notifcations.DeviceToken.Resolver do
  alias Spendable.Notifications.DeviceToken
  alias Spendable.Repo

  def register(params, %{context: %{current_user: user}}) do
    %DeviceToken{user_id: user.id}
    |> DeviceToken.changeset(params)
    |> Repo.insert()
  end
end

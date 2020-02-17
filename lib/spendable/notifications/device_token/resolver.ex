defmodule Spendable.Notifications.DeviceToken.Resolver do
  alias Spendable.Notifications.DeviceToken
  alias Spendable.Repo

  def get_or_create(%{device_token: device_token}, %{context: %{current_user: user}}) do
    case Repo.get_by(DeviceToken, user_id: user.id, device_token: device_token) do
      nil ->
        %DeviceToken{user_id: user.id}
        |> DeviceToken.changeset(%{device_token: device_token})
        |> Repo.insert()

      model ->
        {:ok, model}
    end
  end

  def update(args, %{context: %{model: model}}) do
    model
    |> DeviceToken.changeset(args)
    |> Repo.update()
  end
end

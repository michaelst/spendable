defmodule Spendable.Notifications.Settings.Resolver do
  alias Spendable.Notifications.Settings
  alias Spendable.Repo

  def get_or_create(%{device_token: device_token}, %{context: %{current_user: user}}) do
    case Repo.get_by(Settings, user_id: user.id, device_token: device_token) do
      nil ->
        %Settings{user_id: user.id}
        |> Settings.changeset(%{device_token: device_token, enabled: true})
        |> Repo.insert()

      model ->
        {:ok, model}
    end
  end

  def update(args, %{context: %{model: model}}) do
    model
    |> Settings.changeset(args)
    |> Repo.update()
  end
end

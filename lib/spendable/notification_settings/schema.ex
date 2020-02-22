defmodule Spendable.Notifications.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notification_settings" do
    field :device_token, :string
    field :enabled, :boolean, default: false
    field :provider, NotificationProvider

    belongs_to :user, Spendable.User

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:device_token, :user_id, :enabled])
    |> unique_constraint(:device_token, name: :notification_settings_user_id_device_token_index)
  end
end

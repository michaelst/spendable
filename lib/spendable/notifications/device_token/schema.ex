defmodule Spendable.Notifications.DeviceToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications__device_tokens" do
    field :device_token, :string
    field :enabled, :boolean, default: false

    belongs_to :user, Spendable.User

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:device_token, :user_id, :enabled])
    |> unique_constraint(:notifications__device_tokens, name: :notifications__device_tokens_user_id_device_token_index)
  end
end

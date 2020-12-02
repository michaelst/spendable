defmodule Spendable.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :apple_identifier, :string
    field :bank_limit, :integer, default: 0
    field :firebase_id, :string

    has_many :notification_settings, Spendable.Notifications.Settings

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:apple_identifier, :bank_limit, :firebase_id])
    |> unique_constraint(:email, name: :users_email_index)
    |> unique_constraint(:apple_identifier, name: :users_apple_identifier_index)
    |> unique_constraint(:firebase_id, name: :users_firebase_id_index)
  end
end

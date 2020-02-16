defmodule Spendable.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :apple_identifier, :string
    field :bank_limit, :integer
    field :email, :string
    field :password, :string

    has_many :device_tokens, Spendable.Notifications.DeviceToken

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:apple_identifier, :email, :password])
    |> hash_password()
    |> unique_constraint(:email, name: :users_email_index)
    |> unique_constraint(:apple_identifier, name: :users_apple_identifier_index)
  end

  defp hash_password(%{changes: %{password: plain_text}} = changeset) do
    put_change(changeset, :password, Bcrypt.hash_pwd_salt(plain_text))
  end

  defp hash_password(changeset), do: changeset
end

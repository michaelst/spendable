defmodule Spendable.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :bank_limit, :integer
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password, :bank_limit])
    |> validate_required([:email, :password])
    |> hash_password()
    |> unique_constraint(:email, name: :users_email_index)
  end

  defp hash_password(%{changes: %{password: plain_text}} = changeset) do
    put_change(changeset, :password, Bcrypt.hash_pwd_salt(plain_text))
  end

  defp hash_password(changeset), do: changeset
end

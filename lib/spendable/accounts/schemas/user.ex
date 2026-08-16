defmodule Spendable.Accounts.Schemas.User do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.UserIdentity

  @primary_key {:id, UXID, autogenerate: true, prefix: "usr"}
  schema "users" do
    field :bank_limit, :integer, default: 0
    field :email, :string
    field :image, :string

    has_many :user_identities, UserIdentity

    timestamps()
  end

  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:bank_limit, :email, :image])
    |> validate_required([:bank_limit])
    |> unique_constraint(:email)
  end
end

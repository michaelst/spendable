defmodule Spendable.Accounts.Schemas.User do
  @moduledoc false
  use Spendable.Schema

  @primary_key {:id, UXID, autogenerate: true, prefix: "usr"}
  schema "users" do
    field :bank_limit, :integer, default: 0
    field :external_id, :string
    field :image, :string
    field :provider, :string

    timestamps()
  end

  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:bank_limit, :external_id, :image, :provider])
    |> validate_required([:bank_limit, :external_id, :provider])
    |> unique_constraint(:external_id)
  end
end

defmodule Spendable.OAuth.Schemas.RefreshToken do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.OAuth.Schemas.Client

  @primary_key {:id, UXID, autogenerate: true, prefix: "ort"}
  schema "oauth_refresh_tokens" do
    field :family_id, :string
    field :selector, :binary, redact: true
    field :verify_hash, :binary, redact: true
    field :scope, :string
    field :resource, :string
    field :expires_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec
    field :replaced_by_id, :string

    belongs_to :client, Client
    belongs_to :user, User

    timestamps()
  end

  def changeset(token \\ %__MODULE__{}, attrs) do
    token
    |> cast(attrs, [
      :client_id,
      :family_id,
      :selector,
      :verify_hash,
      :scope,
      :resource,
      :expires_at,
      :revoked_at,
      :replaced_by_id
    ])
    |> validate_required([
      :client_id,
      :family_id,
      :selector,
      :verify_hash,
      :scope,
      :resource,
      :expires_at
    ])
    |> unique_constraint(:selector)
  end
end

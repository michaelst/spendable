defmodule Spendable.OAuth.Schemas.AccessToken do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.OAuth.Schemas.Client
  alias Spendable.OAuth.Schemas.RefreshToken

  @primary_key {:id, UXID, autogenerate: true, prefix: "oat"}
  schema "oauth_access_tokens" do
    field :family_id, :string
    field :selector, :binary, redact: true
    field :verify_hash, :binary, redact: true
    field :scope, :string
    field :resource, :string
    field :expires_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec

    belongs_to :client, Client
    belongs_to :refresh_token, RefreshToken
    belongs_to :user, User

    timestamps()
  end

  def changeset(token \\ %__MODULE__{}, attrs) do
    token
    |> cast(attrs, [
      :client_id,
      :refresh_token_id,
      :family_id,
      :selector,
      :verify_hash,
      :scope,
      :resource,
      :expires_at,
      :revoked_at
    ])
    |> validate_required([
      :client_id,
      :refresh_token_id,
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

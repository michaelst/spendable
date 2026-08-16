defmodule Spendable.OAuth.Schemas.AuthorizationCode do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.OAuth.Schemas.Client

  @primary_key {:id, UXID, autogenerate: true, prefix: "oac"}
  schema "oauth_authorization_codes" do
    field :selector, :binary, redact: true
    field :verify_hash, :binary, redact: true
    field :redirect_uri, :string
    field :scope, :string
    field :code_challenge, :string
    field :code_challenge_method, Ecto.Enum, values: [:S256]
    field :resource, :string
    field :expires_at, :utc_datetime_usec
    field :used_at, :utc_datetime_usec

    belongs_to :client, Client
    belongs_to :user, User

    timestamps()
  end

  def changeset(code \\ %__MODULE__{}, attrs) do
    code
    |> cast(attrs, [
      :client_id,
      :selector,
      :verify_hash,
      :redirect_uri,
      :scope,
      :code_challenge,
      :code_challenge_method,
      :resource,
      :expires_at,
      :used_at
    ])
    |> validate_required([
      :client_id,
      :selector,
      :verify_hash,
      :redirect_uri,
      :scope,
      :code_challenge,
      :code_challenge_method,
      :resource,
      :expires_at
    ])
  end
end

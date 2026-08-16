defmodule Spendable.Accounts.Schemas.ApiToken do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User

  @ttl_days 90
  @touch_after_seconds 86_400

  @primary_key {:id, UXID, autogenerate: true, prefix: "apt"}
  schema "api_tokens" do
    field :token_hash, :string, redact: true
    field :token, :string, virtual: true, redact: true
    field :device_name, :string
    field :apns_token, :string, redact: true
    field :last_used_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec

    belongs_to :user, User

    timestamps()
  end

  def changeset(api_token \\ %__MODULE__{}, attrs) do
    api_token
    |> cast(attrs, [:device_name, :apns_token])
    |> validate_required([:token_hash, :last_used_at, :expires_at])
    |> validate_length(:device_name, max: 100)
    |> unique_constraint(:token_hash)
  end

  @doc """
  The raw token is never stored. It is shown to the client once and matched by hash afterwards.
  """
  def build_token(), do: 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

  def hash(raw) when is_binary(raw),
    do: :sha256 |> :crypto.hash(raw) |> Base.encode16(case: :lower)

  def expires_at(), do: DateTime.add(DateTime.utc_now(), @ttl_days, :day)

  @doc """
  Expiry slides forward on use, but only once a day: a token used on every request would otherwise
  cost a write on every request.
  """
  def stale?(%__MODULE__{last_used_at: last_used_at}) do
    DateTime.diff(DateTime.utc_now(), last_used_at) >= @touch_after_seconds
  end
end

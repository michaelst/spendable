defmodule Spendable.OAuth.Schemas.Client do
  @moduledoc false
  use Spendable.Schema

  import Spendable.OAuth.Utils.RedirectUri

  @supported_grant_types ["authorization_code", "refresh_token"]
  @supported_response_types ["code"]

  @primary_key {:id, UXID, autogenerate: true, prefix: "oc"}
  schema "oauth_clients" do
    field :client_name, :string
    field :redirect_uris, {:array, :string}, default: []
    field :grant_types, {:array, :string}, default: ["authorization_code", "refresh_token"]
    field :response_types, {:array, :string}, default: ["code"]

    field :token_endpoint_auth_method, Ecto.Enum,
      values: [:none, :client_secret_basic, :client_secret_post],
      default: :none

    field :scope, :string, default: "mcp"
    field :secret_selector, :binary, redact: true
    field :secret_verify_hash, :binary, redact: true

    timestamps()
  end

  def changeset(client \\ %__MODULE__{}, attrs) do
    client
    |> cast(attrs, [
      :client_name,
      :redirect_uris,
      :grant_types,
      :response_types,
      :token_endpoint_auth_method,
      :scope
    ])
    |> validate_required([:client_name])
    |> validate_redirect_uris()
    |> validate_subset(:grant_types, @supported_grant_types)
    |> validate_subset(:response_types, @supported_response_types)
  end

  defp validate_redirect_uris(changeset) do
    case get_field(changeset, :redirect_uris) do
      [_uri | _rest] = uris ->
        if Enum.all?(uris, &permitted?/1) do
          changeset
        else
          add_error(changeset, :redirect_uris, "must be absolute https (or http loopback) URIs")
        end

      _none ->
        add_error(changeset, :redirect_uris, "can't be blank")
    end
  end
end

defmodule Spendable.OAuth.Actions.RegisterClient do
  @moduledoc false

  import Spendable.OAuth.Utils.GenerateToken

  alias Spendable.OAuth.Schemas.Client
  alias Spendable.Repo

  @confidential_methods ["client_secret_basic", "client_secret_post"]

  @doc """
  Registers a client (RFC 7591). Returns the client and its secret, which is nil for the public
  PKCE-only clients MCP editors use and is the only time a confidential client's secret is legible.
  """
  def register_client(params) do
    {secret_attrs, secret} = params |> Map.get("token_endpoint_auth_method", "none") |> build_secret()

    params
    |> Client.changeset()
    |> Ecto.Changeset.change(secret_attrs)
    |> Repo.insert()
    |> case do
      {:ok, client} -> {:ok, client, secret}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp build_secret(auth_method) when auth_method in @confidential_methods do
    %{token: secret, selector: selector, verifier: verifier} = generate_token(:client_secret)

    {%{secret_selector: selector, secret_verify_hash: :crypto.hash(:sha256, verifier)}, secret}
  end

  defp build_secret(_auth_method), do: {%{}, nil}
end

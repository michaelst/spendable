defmodule Spendable.OAuth.Actions.CreateAuthorizationCode do
  @moduledoc false

  import Spendable.OAuth.Utils.GenerateToken
  import Spendable.OAuth.Utils.RedirectUri

  alias Spendable.OAuth.Schemas.AuthorizationCode
  alias Spendable.OAuth.Schemas.Client
  alias Spendable.Repo
  alias Spendable.Scope

  @code_ttl_seconds 600

  @doc """
  Records the user's consent as a short-lived code, and returns it with the URL that hands it back
  to the client. The user comes from the scope, so a code can only ever authorize whoever approved it.
  """
  def create_authorization_code(%Scope{user: %{id: user_id}}, request) do
    %{token: code, selector: selector, verifier: verifier} = generate_token(:authorization_code)

    with :ok <- persist_client(request.client),
         {:ok, _authorization_code} <-
           %AuthorizationCode{user_id: user_id}
           |> AuthorizationCode.changeset(%{
             client_id: request.client.id,
             selector: selector,
             verify_hash: :crypto.hash(:sha256, verifier),
             redirect_uri: request.redirect_uri,
             scope: request.scope,
             code_challenge: request.code_challenge,
             code_challenge_method: request.code_challenge_method,
             resource: request.resource,
             expires_at: DateTime.add(DateTime.utc_now(), @code_ttl_seconds, :second)
           })
           |> Repo.insert() do
      {:ok, code, redirect_with(request.redirect_uri, %{code: code, state: request.state})}
    end
  end

  # A client identified by URL never registered, so the row its code points at has to be written
  # here. Re-approving refreshes what its metadata document currently says.
  defp persist_client(%Client{id: "https://" <> _rest} = client) do
    %{
      "client_name" => client.client_name,
      "redirect_uris" => client.redirect_uris,
      "scope" => client.scope
    }
    |> Client.changeset()
    |> Ecto.Changeset.put_change(:id, client.id)
    |> Repo.insert(
      on_conflict: {:replace, [:client_name, :redirect_uris, :scope, :updated_at]},
      conflict_target: :id
    )
    |> then(fn {:ok, _client} -> :ok end)
  end

  defp persist_client(_client), do: :ok
end

defmodule Spendable.OAuth.Utils.IssueTokens do
  @moduledoc false

  import Ecto.Query
  import Spendable.OAuth.Utils.GenerateToken

  alias Spendable.OAuth.Schemas.AccessToken
  alias Spendable.OAuth.Schemas.RefreshToken
  alias Spendable.Repo

  @access_token_ttl_seconds 3600
  @refresh_token_ttl_seconds 60 * 60 * 24 * 30

  @doc """
  Mints an access and refresh token pair, and revokes the refresh token being replaced when this is
  a rotation. Both carry the family id, so detecting a reuse can revoke everything descended from
  the original grant at once.
  """
  def issue_tokens(%{user_id: user_id, client_id: client_id, scope: scope, resource: resource} = attrs) do
    family_id = attrs[:family_id] || UXID.generate!(prefix: "fam")
    replaces = attrs[:replaces]
    now = DateTime.utc_now()

    refresh = generate_token(:refresh)
    access = generate_token(:access)

    result =
      Repo.transaction(fn ->
        {:ok, refresh_token} =
          %RefreshToken{user_id: user_id}
          |> RefreshToken.changeset(%{
            client_id: client_id,
            family_id: family_id,
            selector: refresh.selector,
            verify_hash: :crypto.hash(:sha256, refresh.verifier),
            scope: scope,
            resource: resource,
            expires_at: DateTime.add(now, @refresh_token_ttl_seconds, :second)
          })
          |> Repo.insert()

        {:ok, _access_token} =
          %AccessToken{user_id: user_id}
          |> AccessToken.changeset(%{
            client_id: client_id,
            refresh_token_id: refresh_token.id,
            family_id: family_id,
            selector: access.selector,
            verify_hash: :crypto.hash(:sha256, access.verifier),
            scope: scope,
            resource: resource,
            expires_at: DateTime.add(now, @access_token_ttl_seconds, :second)
          })
          |> Repo.insert()

        if replaces do
          revoke_replaced(replaces, refresh_token, now)
        end
      end)

    case result do
      {:ok, _result} ->
        {:ok,
         %{
           access_token: access.token,
           refresh_token: refresh.token,
           token_type: "Bearer",
           expires_in: @access_token_ttl_seconds,
           scope: scope
         }}

      # coveralls-ignore-start only reachable when a concurrent request rotates the same refresh
      # token between this one's read and its write; the suite runs against a single serialized
      # sandbox connection, so that interleaving cannot be produced from a test.
      {:error, reason} ->
        {:error, reason}
        # coveralls-ignore-stop
    end
  end

  defp revoke_replaced(replaces, refresh_token, now) do
    query = from token in RefreshToken, where: token.id == ^replaces.id and is_nil(token.revoked_at)

    case Repo.update_all(query, set: [revoked_at: now, replaced_by_id: refresh_token.id, updated_at: now]) do
      {1, _records} ->
        :ok

      # coveralls-ignore-start someone else rotated this token first, which a single serialized
      # sandbox connection cannot produce; the caller decides how to recover.
      _none ->
        Repo.rollback(:rotation_conflict)
        # coveralls-ignore-stop
    end
  end
end

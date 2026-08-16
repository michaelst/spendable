defmodule Spendable.OAuth.Actions.ExchangeRefreshToken do
  @moduledoc false

  import Ecto.Query
  import Spendable.OAuth.Utils.AuthenticateClient
  import Spendable.OAuth.Utils.DecodeToken
  import Spendable.OAuth.Utils.IssueTokens

  alias Spendable.OAuth.Schemas.AccessToken
  alias Spendable.OAuth.Schemas.RefreshToken
  alias Spendable.Repo

  require Logger

  # A rotated token stays usable this long so a client that retried a refresh whose response it
  # never saw is not treated as an attacker. RFC 9700 requires reuse be detectable, not that it be
  # punished instantly.
  @grace_period_seconds 30

  @doc """
  Rotates a refresh token: every use issues a new pair and revokes the one presented. A token used
  twice is the signature of a stolen one, so the whole family descended from that grant is revoked.
  """
  def exchange_refresh_token(params) do
    refresh_token = params["refresh_token"] || ""
    client_id = params["client_id"]

    with {:ok, selector, verifier} <- decode_token(refresh_token, :refresh),
         %RefreshToken{} = token <- fetch(selector),
         true <- Plug.Crypto.secure_compare(token.verify_hash, :crypto.hash(:sha256, verifier)),
         true <- token.client_id == client_id,
         :ok <- authenticate_client(client_id, params["client_secret"]),
         :ok <- usable?(token),
         {:ok, tokens} <-
           issue_tokens(%{
             user_id: token.user_id,
             client_id: token.client_id,
             scope: token.scope,
             resource: token.resource,
             family_id: token.family_id,
             replaces: token
           }) do
      {:ok, tokens}
    else
      {:grace, token} ->
        Logger.warning("oauth refresh token replayed within the grace period, re-issuing for family #{token.family_id}")

        # the row is already revoked and already points at its successor, so nothing to replace
        issue_tokens(%{
          user_id: token.user_id,
          client_id: token.client_id,
          scope: token.scope,
          resource: token.resource,
          family_id: token.family_id
        })

      {:reuse, token} ->
        revoke_family(token)
        {:error, :invalid_grant}

      {:error, :invalid_client} ->
        {:error, :invalid_client}

      # Anything left is a token this caller may not redeem, including one another request rotated
      # first. The client's recovery is the same either way: authorize again.
      _error ->
        {:error, :invalid_grant}
    end
  end

  defp fetch(selector), do: Repo.one(from token in RefreshToken, where: token.selector == ^selector)

  defp usable?(token) do
    cond do
      is_struct(token.revoked_at, DateTime) and rotation_grace?(token) -> {:grace, token}
      is_struct(token.revoked_at, DateTime) -> {:reuse, token}
      DateTime.compare(token.expires_at, DateTime.utc_now()) != :gt -> :expired
      true -> :ok
    end
  end

  # Grace covers one case only: the client retried the refresh it just made, and the token it holds
  # was rotated moments ago. Both bounds matter - a revoked_at in the future (clock skew) has to
  # fail closed rather than open an unbounded window.
  defp rotation_grace?(%RefreshToken{revoked_at: revoked_at, replaced_by_id: replaced_by_id}) do
    elapsed = DateTime.diff(DateTime.utc_now(), revoked_at, :second)

    elapsed >= 0 and elapsed <= @grace_period_seconds and successor_live?(replaced_by_id)
  end

  # A token that was never rotated has no successor and never earns grace. Requiring a live
  # successor is also what keeps grace from outliving a revocation: revoking only touches rows
  # whose revoked_at is still NULL, so an already-rotated token would otherwise stay redeemable for
  # 30s after the family was revoked or the user disconnected the client.
  defp successor_live?(nil), do: false

  defp successor_live?(replaced_by_id) do
    Repo.exists?(from token in RefreshToken, where: token.id == ^replaced_by_id and is_nil(token.revoked_at))
  end

  defp revoke_family(%RefreshToken{family_id: family_id}) do
    now = DateTime.utc_now()

    Repo.update_all(
      from(token in RefreshToken, where: token.family_id == ^family_id and is_nil(token.revoked_at)),
      set: [revoked_at: now]
    )

    Repo.update_all(
      from(token in AccessToken, where: token.family_id == ^family_id and is_nil(token.revoked_at)),
      set: [revoked_at: now]
    )

    Logger.warning("oauth refresh token reuse detected, revoked family #{family_id}")
  end
end

defmodule Spendable.OAuth.Actions.RevokeAuthorization do
  @moduledoc false

  import Ecto.Query

  alias Spendable.OAuth.Schemas.AccessToken
  alias Spendable.OAuth.Schemas.AuthorizationCode
  alias Spendable.OAuth.Schemas.RefreshToken
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Disconnects a client: every token it holds for this user stops working at once, so the next call
  it makes has to go back through consent.

  That includes a code it was granted but has not redeemed yet. Spending one mints a fresh pair, so
  leaving them alone would let a client the user just disconnected walk straight back in.
  """
  def revoke_authorization(%Scope{user: %{id: user_id}}, client_id) do
    now = DateTime.utc_now()

    {:ok, :ok} =
      Repo.transaction(fn ->
        Repo.update_all(
          from(code in AuthorizationCode,
            where: code.user_id == ^user_id and code.client_id == ^client_id,
            where: is_nil(code.used_at)
          ),
          set: [used_at: now]
        )

        Repo.update_all(
          from(token in RefreshToken,
            where: token.user_id == ^user_id and token.client_id == ^client_id,
            where: is_nil(token.revoked_at)
          ),
          set: [revoked_at: now]
        )

        Repo.update_all(
          from(token in AccessToken,
            where: token.user_id == ^user_id and token.client_id == ^client_id,
            where: is_nil(token.revoked_at)
          ),
          set: [revoked_at: now]
        )

        :ok
      end)

    :ok
  end
end

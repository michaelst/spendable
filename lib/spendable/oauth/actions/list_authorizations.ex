defmodule Spendable.OAuth.Actions.ListAuthorizations do
  @moduledoc false

  import Ecto.Query

  alias Spendable.OAuth.Schemas.RefreshToken
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  The clients currently able to act as this user, one row per client rather than per token, since
  a client that has refreshed a hundred times is still one connection to the person revoking it.
  """
  def list_authorizations(%Scope{user: %{id: user_id}}) do
    now = DateTime.utc_now()

    Repo.all(
      from token in RefreshToken,
        where: token.user_id == ^user_id,
        where: is_nil(token.revoked_at) and token.expires_at > ^now,
        join: client in assoc(token, :client),
        group_by: [token.client_id, client.client_name],
        order_by: [desc: max(token.inserted_at)],
        select: %{
          client_id: token.client_id,
          client_name: client.client_name,
          sessions: count(token.id),
          last_authorized_at: max(token.inserted_at)
        }
    )
  end
end

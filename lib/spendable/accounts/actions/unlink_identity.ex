defmodule Spendable.Accounts.Actions.UnlinkIdentity do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Accounts.Schemas.UserIdentity
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Removes a way of signing in, never the last one: an account with no identity is an account
  nobody can get back into.
  """
  def unlink_identity(
        %Scope{user: %{id: user_id}},
        %UserIdentity{user_id: user_id} = identity
      ) do
    count =
      Repo.aggregate(from(record in UserIdentity, where: record.user_id == ^user_id), :count, :id)

    if count > 1,
      do: Repo.delete(identity),
      else: {:error, :last_identity}
  end

  def unlink_identity(_scope, _identity), do: {:error, :not_authorized}
end

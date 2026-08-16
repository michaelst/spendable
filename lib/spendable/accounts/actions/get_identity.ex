defmodule Spendable.Accounts.Actions.GetIdentity do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Accounts.Schemas.UserIdentity
  alias Spendable.Repo
  alias Spendable.Scope

  def get_identity(%Scope{user: %{id: user_id}}, id) do
    query =
      from(identity in UserIdentity,
        where: identity.user_id == ^user_id,
        where: identity.id == ^id
      )

    case Repo.one(query) do
      %UserIdentity{} = identity -> {:ok, identity}
      nil -> {:error, :identity_not_found}
    end
  end
end

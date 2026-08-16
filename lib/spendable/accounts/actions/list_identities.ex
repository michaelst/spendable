defmodule Spendable.Accounts.Actions.ListIdentities do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Accounts.Schemas.UserIdentity
  alias Spendable.Repo
  alias Spendable.Scope

  @doc "The ways this account can be signed into, oldest first."
  def list_identities(%Scope{user: %{id: user_id}}) do
    from(identity in UserIdentity,
      where: identity.user_id == ^user_id,
      order_by: identity.inserted_at
    )
    |> Repo.all()
  end
end

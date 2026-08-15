defmodule Spendable.Transactions.Actions.UpdateTransaction do
  @moduledoc false

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  def update_transaction(
        %Scope{user: %{id: user_id}},
        %Transaction{user_id: user_id} = transaction,
        attrs
      ) do
    transaction
    |> Repo.preload(:budget_allocations)
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  def update_transaction(_scope, _transaction, _attrs), do: {:error, :not_authorized}
end

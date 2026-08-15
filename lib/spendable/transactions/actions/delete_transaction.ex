defmodule Spendable.Transactions.Actions.DeleteTransaction do
  @moduledoc false

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  @doc "Allocations go with it: the database cascades them off the transaction."
  def delete_transaction(
        %Scope{user: %{id: user_id}},
        %Transaction{user_id: user_id} = transaction
      ) do
    Repo.delete(transaction)
  end

  def delete_transaction(_scope, _transaction), do: {:error, :not_authorized}
end

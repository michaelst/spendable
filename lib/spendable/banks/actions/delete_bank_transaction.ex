defmodule Spendable.Banks.Actions.DeleteBankTransaction do
  @moduledoc false

  alias Spendable.Banks.Schemas.BankTransaction
  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions

  @doc """
  Removes a charge the bank has taken back - a reversed or declined authorization.

  The user's review and allocations go with it. That is right where updating in place is right
  for a charge that settled: this one did not happen at all. Plaid has no equivalent.
  """
  def delete_bank_transaction(
        %Scope{user: %{id: user_id}} = scope,
        %BankTransaction{user_id: user_id} = bank_transaction
      ) do
    Repo.transaction(fn ->
      %{transaction: transaction} = Repo.preload(bank_transaction, :transaction)

      {:ok, _gone} = Transactions.delete_transaction(scope, transaction)
      {:ok, deleted} = Repo.delete(bank_transaction)

      deleted
    end)
  end

  def delete_bank_transaction(_scope, _bank_transaction), do: {:error, :not_authorized}
end

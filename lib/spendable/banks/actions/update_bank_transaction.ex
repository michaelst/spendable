defmodule Spendable.Banks.Actions.UpdateBankTransaction do
  @moduledoc false

  alias Spendable.Banks.Schemas.BankTransaction
  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions

  @doc """
  Restates a charge the bank has revised - the usual one being an authorization that settled for
  a different amount under the same id.

  Plaid issues a new id instead, which is what `Transactions.replace_pending/3` is for. Updating
  in place means the user's own allocations survive and only the Spendable remainder moves.
  """
  def update_bank_transaction(
        %Scope{user: %{id: user_id}} = scope,
        %BankTransaction{user_id: user_id} = bank_transaction,
        attrs
      ) do
    Repo.transaction(fn ->
      {:ok, updated} = bank_transaction |> BankTransaction.changeset(attrs) |> Repo.update()
      %{transaction: transaction} = Repo.preload(updated, :transaction)

      {:ok, _restated} =
        Transactions.update_transaction(scope, transaction, %{
          "amount" => updated.amount,
          "date" => updated.date,
          "name" => updated.name
        })

      updated
    end)
  end

  def update_bank_transaction(_scope, _bank_transaction, _attrs), do: {:error, :not_authorized}
end

defmodule Spendable.Transactions do
  @moduledoc false

  alias Spendable.Transactions.Actions

  defdelegate list_transactions(scope, opts \\ []), to: Actions.ListTransactions
  defdelegate get_transaction(scope, by), to: Actions.GetTransaction
  defdelegate create_transaction(scope, attrs), to: Actions.CreateTransaction
  defdelegate update_transaction(scope, transaction, attrs), to: Actions.UpdateTransaction
  defdelegate delete_transaction(scope, transaction), to: Actions.DeleteTransaction
  defdelegate replace_pending(scope, pending, settled), to: Actions.ReplacePending
end

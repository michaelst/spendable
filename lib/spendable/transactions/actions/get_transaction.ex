defmodule Spendable.Transactions.Actions.GetTransaction do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  def get_transaction(%Scope{user: %{id: user_id}}, by) do
    query =
      from(transaction in Transaction,
        where: transaction.user_id == ^user_id,
        where: ^by,
        preload: [
          :budget_allocations,
          bank_transaction: [bank_account: :bank_member],
          transfer: [bank_transaction: :bank_account]
        ]
      )

    case Repo.one(query) do
      %Transaction{} = transaction -> {:ok, transaction}
      nil -> {:error, :transaction_not_found}
    end
  end
end

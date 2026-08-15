defmodule Spendable.Transactions.Actions.ReplacePending do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Budgets.Schemas.BudgetAllocation
  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  @doc """
  Moves a pending transaction's allocations onto the settled one that replaced it, then deletes
  the pending transaction.

  The user may already have allocated the pending charge, and being asked to do it again when the
  charge settles would be the same decision twice.
  """
  def replace_pending(
        %Scope{user: %{id: user_id}},
        %Transaction{user_id: user_id} = pending,
        %Transaction{user_id: user_id} = settled
      ) do
    Repo.transaction(fn ->
      from(allocation in BudgetAllocation,
        where: allocation.transaction_id == ^pending.id,
        where: allocation.user_id == ^user_id
      )
      |> Repo.update_all(set: [transaction_id: settled.id])

      Repo.delete!(pending)

      settled
    end)
  end

  def replace_pending(_scope, _pending, _settled), do: {:error, :not_authorized}
end

defmodule Spendable.Budgets.Actions.CalculateSpendable do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Budgets.Schemas.BudgetAllocation
  alias Spendable.Repo
  alias Spendable.Scope

  @zero Decimal.new("0.00")

  @doc """
  Money in synced accounts that no budget has claimed.

  Tracking budgets are skipped because they record spending without reserving anything, and a
  budget backed by a bank account is skipped because its balance is that account's, not a claim
  on the pool.
  """
  def calculate_spendable(%Scope{user: %{id: user_id}}) do
    balance =
      from(account in BankAccount,
        where: account.user_id == ^user_id,
        where: account.sync,
        where: is_nil(account.budget_id)
      )
      |> Repo.aggregate(:sum, :balance)
      |> Kernel.||(@zero)

    allocations =
      from(allocation in BudgetAllocation,
        where: allocation.user_id == ^user_id,
        select: %{budget_id: allocation.budget_id, allocated: sum(allocation.amount)},
        group_by: allocation.budget_id
      )

    allocated =
      from(allocation in subquery(allocations),
        full_join: budget in Budget,
        on: allocation.budget_id == budget.id,
        left_join: account in BankAccount,
        on: budget.id == account.budget_id,
        select: fragment("SUM(ABS(COALESCE(?, 0) + ?))", allocation.allocated, budget.adjustment),
        where: budget.user_id == ^user_id,
        where: budget.type != :tracking,
        where: is_nil(account.id)
      )
      |> Repo.one()
      |> Kernel.||(@zero)

    Decimal.sub(balance, allocated)
  end
end

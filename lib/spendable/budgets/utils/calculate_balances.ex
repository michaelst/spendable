defmodule Spendable.Budgets.Utils.CalculateBalances do
  @moduledoc "Import this module rather than aliasing it."

  import Ecto.Query

  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Budgets.Schemas.BudgetAllocation
  alias Spendable.Budgets.Schemas.Funding
  alias Spendable.Repo

  @zero Decimal.new("0.00")

  @doc """
  Fills in the virtual balance for a list of budgets in three queries rather than one per budget.

  A budget backed by a bank account reports that account's balance; every other budget reports
  what it has been funded, plus what its allocations add up to, plus its manual adjustment.
  Funding is what the budget was given and allocations are what it then spent, so a budget funded
  300 that spent 140 reads as 160 left, and one that spent 350 reads as 50 short.

  Allocations belonging to an excluded transaction or to a transfer are left out: neither is money
  the budget spent.
  """
  def calculate_balance(%Budget{} = budget) do
    [budget] = calculate_balances([budget])
    budget
  end

  def calculate_balances([]), do: []

  def calculate_balances(budgets) do
    budget_ids = Enum.map(budgets, & &1.id)

    bank_balances =
      from(account in BankAccount,
        select: {account.budget_id, sum(account.balance)},
        group_by: account.budget_id,
        where: account.budget_id in ^budget_ids
      )
      |> Repo.all()
      |> Map.new()

    allocated =
      from(allocation in BudgetAllocation,
        join: transaction in assoc(allocation, :transaction),
        select: {allocation.budget_id, sum(allocation.amount)},
        group_by: allocation.budget_id,
        where: allocation.budget_id in ^budget_ids,
        where: not transaction.excluded,
        where: is_nil(transaction.transfer_id)
      )
      |> Repo.all()
      |> Map.new()

    funded =
      from(funding in Funding,
        select: {funding.budget_id, sum(funding.amount)},
        group_by: funding.budget_id,
        where: funding.budget_id in ^budget_ids
      )
      |> Repo.all()
      |> Map.new()

    Enum.map(budgets, fn budget ->
      from_the_ledger =
        allocated
        |> Map.get(budget.id, @zero)
        |> Decimal.add(Map.get(funded, budget.id, @zero))
        |> Decimal.add(budget.adjustment)

      %{budget | balance: Map.get(bank_balances, budget.id, from_the_ledger)}
    end)
  end
end

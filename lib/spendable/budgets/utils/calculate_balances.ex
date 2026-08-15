defmodule Spendable.Budgets.Utils.CalculateBalances do
  @moduledoc "Import this module rather than aliasing it."

  import Ecto.Query

  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Budgets.Schemas.BudgetAllocation
  alias Spendable.Repo

  @zero Decimal.new("0.00")

  @doc """
  Fills in the virtual balance for a list of budgets in two queries rather than one per budget.

  A budget backed by a bank account reports that account's balance; every other budget reports
  what its allocations add up to, plus its manual adjustment.
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
        select: {allocation.budget_id, sum(allocation.amount)},
        group_by: allocation.budget_id,
        where: allocation.budget_id in ^budget_ids
      )
      |> Repo.all()
      |> Map.new()

    Enum.map(budgets, fn budget ->
      from_allocations = allocated |> Map.get(budget.id, @zero) |> Decimal.add(budget.adjustment)

      %{budget | balance: Map.get(bank_balances, budget.id, from_allocations)}
    end)
  end
end

defmodule Spendable.Factory do
  use ExMachina.Ecto, repo: Spendable.Repo
  use Spendable.Budgets.Budget.Factory
  use Spendable.Budgets.BudgetAllocationTemplate.Factory
  use Spendable.Budgets.BudgetAllocationTemplateLine.Factory
  use Spendable.Transaction.Factory
end

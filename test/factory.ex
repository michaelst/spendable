defmodule Spendable.Factory do
  use ExMachina.Ecto, repo: Spendable.Repo
  use Spendable.Budgets.Budget.Factory
  use Spendable.Budgets.BudgetTemplate.Factory
  use Spendable.Budgets.BudgetTemplateLine.Factory
end

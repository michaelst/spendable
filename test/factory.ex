defmodule Spendable.Factory do
  use ExMachina.Ecto, repo: Spendable.Repo
  use Spendable.Budgets.Allocation.Factory
  use Spendable.Budgets.AllocationTemplate.Factory
  use Spendable.Budgets.AllocationTemplateLine.Factory
  use Spendable.Budgets.Budget.Factory
  use Spendable.Transaction.Factory
end

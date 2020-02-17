defmodule Spendable.Factory do
  use ExMachina.Ecto, repo: Spendable.Repo
  use Spendable.Banks.Account.Factory
  use Spendable.Banks.Member.Factory
  use Spendable.Budgets.Allocation.Factory
  use Spendable.Budgets.AllocationTemplate.Factory
  use Spendable.Budgets.AllocationTemplateLine.Factory
  use Spendable.Budgets.Budget.Factory
  use Spendable.Notifications.Settings.Factory
  use Spendable.Transaction.Factory
end

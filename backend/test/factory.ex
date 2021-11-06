defmodule Spendable.Factory do
  use ExMachina.Ecto, repo: Spendable.Repo
  use Spendable.BankAccount.Factory
  use Spendable.BankMember.Factory
  use Spendable.Budget.Factory
  use Spendable.BudgetAllocation.Factory
  use Spendable.BudgetAllocationTemplate.Factory
  use Spendable.BudgetAllocationTemplateLine.Factory
  use Spendable.NotificationSettings.Factory
  use Spendable.Transaction.Factory
  use Spendable.User.Factory
end

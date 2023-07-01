defmodule Spendable.Registry do
  use Ash.Registry,
    extensions: [
      # This extension adds helpful compile time validations
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Spendable.BankAccount
    entry Spendable.BankMember
    entry Spendable.BankTransaction
    entry Spendable.Budget
    entry Spendable.BudgetAllocation
    entry Spendable.BudgetAllocationTemplate
    entry Spendable.BudgetAllocationTemplateLine
    entry Spendable.NotificationSettings
    entry Spendable.Transaction
    entry Spendable.User
  end
end

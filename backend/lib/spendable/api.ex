defmodule Spendable.Api do
  use Ash.Api,
    extensions: [
      AshGraphql.Api
    ]

  resources do
    resource Spendable.BankAccount
    resource Spendable.BankMember
    resource Spendable.BankTransaction
    resource Spendable.Transaction
    resource Spendable.User
    resource Spendable.User.SpentByMonth
  end
end

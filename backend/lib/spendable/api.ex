defmodule Spendable.Api do
  use Ash.Api,
    extensions: [AshGraphql.Api]

  resources do
    resource Spendable.BankAccount
    resource Spendable.BankMember
    resource Spendable.BankTransaction
    resource Spendable.Transaction
    resource Spendable.User
  end

  graphql do
    root_level_errors? true
    show_raised_errors? true
  end
end

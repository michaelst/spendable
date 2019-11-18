defmodule Spendable.Banks.Transaction.Types do
  use Absinthe.Schema.Notation

  object :bank_transaction do
    field :id, :id
    field :amount, :string
    field :date, :string
    field :name, :string
  end
end

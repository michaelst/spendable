defmodule Spendable.Banks.Transaction.Types do
  use Absinthe.Schema.Notation

  object :bank_transaction do
    field :amount, :string
    field :date, :string
    field :id, :id
    field :name, :string
    field :pending, :boolean
  end
end

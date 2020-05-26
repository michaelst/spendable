defmodule Spendable.Banks.Transaction.Types do
  use Absinthe.Schema.Notation

  object :bank_transaction do
    field :id, non_null(:id)
    field :amount, non_null(:decimal)
    field :date, non_null(:date)
    field :name, non_null(:string)
    field :pending, non_null(:boolean)
  end
end

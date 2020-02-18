defmodule Spendable.Budgets.Allocation.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :allocation do
    field :id, :id
    field :amount, :string
    field :budget, :budget, resolve: dataloader(Spendable)
    field :transaction, :transaction, resolve: dataloader(Spendable)
  end

  input_object :allocation_input_object do
    field :id, :id
    field :amount, non_null(:string)
    field :budget_id, non_null(:id)
  end
end

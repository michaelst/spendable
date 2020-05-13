defmodule Spendable.Budgets.AllocationTemplateLine.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :allocation_template_line do
    field :id, non_null(:id)
    field :amount, non_null(:decimal)
    field :budget, non_null(:budget), resolve: dataloader(Spendable)
    field :allocation_template, non_null(:allocation_template), resolve: dataloader(Spendable)
  end

  input_object :allocation_template_line_input_object do
    field :id, :id
    field :amount, :string
    field :budget_id, :id
  end
end

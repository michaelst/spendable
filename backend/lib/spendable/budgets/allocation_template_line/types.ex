defmodule Spendable.Budgets.AllocationTemplateLine.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Spendable.Budgets.AllocationTemplateLine
  alias Spendable.Budgets.AllocationTemplateLine.Resolver
  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Middleware.LoadModel

  object :allocation_template_line do
    field :id, non_null(:id)
    field :amount, non_null(:decimal)
    field :budget, non_null(:budget), resolve: dataloader(Spendable)
    field :allocation_template, non_null(:allocation_template), resolve: dataloader(Spendable)
  end

  input_object :allocation_template_line_input_object do
    field :id, :id
    field :amount, :decimal
    field :budget_id, :id
  end

  object :allocation_template_line_mutations do
    field :create_allocation_template_line, :allocation_template_line do
      middleware(CheckAuthentication)
      arg(:amount, non_null(:decimal))
      arg(:budget_allocation_template_id, non_null(:id))
      arg(:budget_id, non_null(:id))
      resolve(&Resolver.create/2)
    end

    field :update_allocation_template_line, :allocation_template_line do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: AllocationTemplateLine)
      arg(:id, non_null(:id))
      arg(:amount, :decimal)
      arg(:budget_allocation_template_id, :id)
      arg(:budget_id, :id)
      resolve(&Resolver.update/2)
    end

    field :delete_allocation_template_line, :allocation_template_line do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: AllocationTemplateLine)
      arg(:id, non_null(:id))
      resolve(&Resolver.delete/2)
    end
  end
end

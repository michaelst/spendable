defmodule Spendable.Budgets.BudgetAllocationTemplate.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Spendable.Budgets.BudgetAllocationTemplate.Resolver
  alias Spendable.Budgets.BudgetAllocationTemplate

  object :budget_allocation_template do
    field :id, :id
    field :name, :string
    field :lines, list_of(:budget_allocation_template_line), resolve: dataloader(Spendable)
  end

  object :budget_allocation_template_queries do
    field :budget_allocation_templates, list_of(:budget_allocation_template) do
      middleware(Spendable.Middleware.CheckAuthentication)
      resolve(&Resolver.list/3)
    end
  end

  object :budget_allocation_template_mutations do
    field :create_budget_allocation_template, :budget_allocation_template do
      middleware(Spendable.Middleware.CheckAuthentication)
      arg(:name, :string)
      arg(:lines, list_of(:budget_allocation_template_line_input_object))
      resolve(&Resolver.create/2)
    end

    field :update_budget_allocation_template, :budget_allocation_template do
      middleware(Spendable.Middleware.CheckAuthentication)
      middleware(Spendable.Middleware.LoadModel, module: BudgetAllocationTemplate)
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:lines, list_of(:budget_allocation_template_line_input_object))
      resolve(&Resolver.update/2)
    end
  end
end

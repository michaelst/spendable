defmodule Spendable.Budgets.BudgetTemplate.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Spendable.Budgets.BudgetTemplate.Resolver
  alias Spendable.Budgets.BudgetTemplate

  object :budget_template do
    field :id, :id
    field :name, :string
    field :lines, list_of(:budget_template_line), resolve: dataloader(Spendable)
  end

  object :budget_template_queries do
    field :budget_templates, list_of(:budget_template) do
      middleware(Spendable.Middleware.CheckAuthentication)
      resolve(&Resolver.list/3)
    end
  end

  object :budget_template_mutations do
    field :create_budget_template, :budget_template do
      middleware(Spendable.Middleware.CheckAuthentication)
      arg(:name, :string)
      arg(:lines, list_of(:budget_template_line_input_object))
      resolve(&Resolver.create/2)
    end

    field :update_budget_template, :budget_template do
      middleware(Spendable.Middleware.CheckAuthentication)
      middleware(Spendable.Middleware.LoadModel, module: BudgetTemplate)
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:lines, list_of(:budget_template_line_input_object))
      resolve(&Resolver.update/2)
    end
  end
end

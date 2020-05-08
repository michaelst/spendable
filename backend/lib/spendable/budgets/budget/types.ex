defmodule Spendable.Budgets.Budget.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  alias Spendable.Budgets.Budget
  alias Spendable.Budgets.Budget.Resolver
  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Middleware.LoadModel

  object :budget do
    field :id, :id
    field :name, :string
    field :goal, :string

    field :balance, :string do
      complexity(5)

      resolve(fn budget, _args, _resolution ->
        {:ok, Budget.balance(budget)}
      end)
    end

    field :recent_allocations, list_of(:allocation), resolve: dataloader(Spendable, :allocations, args: %{recent: true})
    field :allocation_template_lines, list_of(:allocation_template_line), resolve: dataloader(Spendable)
  end

  object :budget_queries do
    field :budget, :budget do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Budget)
      arg(:id, non_null(:id))
      resolve(&Resolver.get/2)
    end

    field :budgets, list_of(:budget) do
      middleware(CheckAuthentication)
      resolve(&Resolver.list/2)
    end
  end

  object :budget_mutations do
    field :create_budget, :budget do
      middleware(CheckAuthentication)
      arg(:balance, :string)
      arg(:name, :string)
      arg(:goal, :string)
      resolve(&Resolver.create/2)
    end

    field :update_budget, :budget do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Budget)
      arg(:id, non_null(:id))
      arg(:balance, :string)
      arg(:name, :string)
      arg(:goal, :string)
      resolve(&Resolver.update/2)
    end

    field :delete_budget, :budget do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Budget)
      arg(:id, non_null(:id))
      resolve(&Resolver.delete/2)
    end
  end
end

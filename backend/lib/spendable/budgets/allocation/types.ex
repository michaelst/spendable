defmodule Spendable.Budgets.Allocation.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Spendable.Budgets.Allocation
  alias Spendable.Budgets.Allocation.Resolver
  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Middleware.LoadModel

  object :allocation do
    field :id, non_null(:id)
    field :amount, non_null(:decimal)
    field :budget, non_null(:budget), resolve: dataloader(Spendable)
    field :transaction, non_null(:transaction), resolve: dataloader(Spendable)
  end

  input_object :allocation_input_object do
    field :id, :id
    field :amount, non_null(:string)
    field :budget_id, non_null(:id)
  end

  object :allocation_queries do
    field :allocation, non_null(:allocation) do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Allocation)
      arg(:id, non_null(:id))
      resolve(&Resolver.get/2)
    end
  end

  object :allocation_mutations do
    field :create_allocation, non_null(:allocation) do
      middleware(CheckAuthentication)
      arg(:amount, non_null(:decimal))
      arg(:budget_id, non_null(:id))
      arg(:transaction_id, non_null(:id))
      resolve(&Resolver.create/2)
    end

    field :update_allocation, non_null(:allocation) do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Allocation)
      arg(:id, non_null(:id))
      arg(:amount, :decimal)
      arg(:budget_id, :id)
      resolve(&Resolver.update/2)
    end

    field :delete_allocation, non_null(:allocation) do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Allocation)
      arg(:id, non_null(:id))
      resolve(&Resolver.delete/2)
    end
  end
end

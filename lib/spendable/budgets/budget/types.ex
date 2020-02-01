defmodule Spendable.Budgets.Budget.Types do
  use Absinthe.Schema.Notation
  import Ecto.Query, only: [from: 2]

  alias Spendable.Budgets.Budget.Resolver
  alias Spendable.Budgets.Budget
  alias Spendable.Budgets.Allocation
  alias Spendable.Repo

  object :budget do
    field :id, :id
    field :name, :string
    field :goal, :string

    field :balance, :string do
      complexity(5)

      resolve(fn budget, _, _ ->
        allocated =
          from(Allocation, where: [budget_id: ^budget.id])
          |> Repo.aggregate(:sum, :amount)

        {:ok, allocated || Decimal.new("0.00")}
      end)
    end
  end

  object :budget_queries do
    field :budgets, list_of(:budget) do
      middleware(Spendable.Middleware.CheckAuthentication)
      resolve(&Resolver.list/3)
    end
  end

  object :budget_mutations do
    field :create_budget, :budget do
      middleware(Spendable.Middleware.CheckAuthentication)
      arg(:name, :string)
      arg(:goal, :string)
      resolve(&Resolver.create/2)
    end

    field :update_budget, :budget do
      middleware(Spendable.Middleware.CheckAuthentication)
      middleware(Spendable.Middleware.LoadModel, module: Budget)
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:goal, :string)
      resolve(&Resolver.update/2)
    end

    field :delete_budget, :budget do
      middleware(Spendable.Middleware.CheckAuthentication)
      middleware(Spendable.Middleware.LoadModel, module: Budget)
      arg(:id, non_null(:id))
      resolve(&Resolver.delete/2)
    end
  end
end

defmodule Spendable.Transaction.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Spendable.Transaction.Resolver
  alias Spendable.Transaction

  object :transaction do
    field :id, :id
    field :amount, :string
    field :date, :string
    field :name, :string
    field :note, :string

    field :allocations, list_of(:allocation), resolve: dataloader(Spendable)
    field :bank_transaction, :bank_transaction, resolve: dataloader(Spendable)
    field :category, :category, resolve: dataloader(Spendable)
  end

  object :transaction_queries do
    field :transactions, list_of(:transaction) do
      middleware(Spendable.Middleware.CheckAuthentication)
      resolve(&Resolver.list/2)
    end

    field :transaction, :transaction do
      middleware(Spendable.Middleware.CheckAuthentication)
      middleware(Spendable.Middleware.LoadModel, module: Transaction)
      arg(:id, non_null(:id))
      resolve(&Resolver.get/2)
    end
  end

  object :transaction_mutations do
    field :update_transaction, :transaction do
      middleware(Spendable.Middleware.CheckAuthentication)
      middleware(Spendable.Middleware.LoadModel, module: Transaction)
      arg(:id, non_null(:id))
      arg(:amount, :string)
      arg(:category_id, :id)
      arg(:date, :string)
      arg(:name, :string)
      arg(:note, :string)
      arg(:allocations, list_of(:allocation_input_object))
      resolve(&Resolver.update/2)
    end
  end
end

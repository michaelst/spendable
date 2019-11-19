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
    field :category, :category, resolve: dataloader(Spendable)
    field :bank_transaction, :bank_transaction, resolve: dataloader(Spendable)
  end

  object :transaction_queries do
    field :transactions, list_of(:transaction) do
      middleware(Spendable.Middleware.CheckAuthentication)
      resolve(&Resolver.list/3)
    end
  end

  object :transaction_mutations do
    field :update_transaction, :transaction do
      middleware(Spendable.Middleware.CheckAuthentication)
      middleware(Spendable.Middleware.LoadModel, module: Transaction)
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:note, :string)
      arg(:category_id, :id)
      resolve(&Resolver.update/2)
    end
  end
end

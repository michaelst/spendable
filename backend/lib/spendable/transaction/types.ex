defmodule Spendable.Transaction.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Middleware.LoadModel
  alias Spendable.Transaction
  alias Spendable.Transaction.Resolver

  object :transaction do
    field :id, non_null(:id)
    field :amount, non_null(:decimal)
    field :date, non_null(:date)
    field :name, :string
    field :note, :string

    field :allocations, :allocation |> non_null |> list_of |> non_null, resolve: dataloader(Spendable)
    field :bank_transaction, :bank_transaction, resolve: dataloader(Spendable)
    field :category, :category, resolve: dataloader(Spendable)
    field :tags, :tag |> non_null |> list_of |> non_null, resolve: dataloader(Spendable)
  end

  object :transaction_queries do
    field :transactions, list_of(:transaction) do
      middleware(CheckAuthentication)
      arg(:offset, :integer)
      resolve(&Resolver.list/2)
    end

    field :transaction, :transaction do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Transaction)
      arg(:id, non_null(:id))
      resolve(&Resolver.get/2)
    end
  end

  object :transaction_mutations do
    field :create_transaction, :transaction do
      middleware(CheckAuthentication)
      arg(:amount, :string)
      arg(:category_id, :id)
      arg(:date, :string)
      arg(:name, :string)
      arg(:note, :string)
      arg(:allocations, list_of(:allocation_input_object))
      arg(:tag_ids, list_of(:id))
      resolve(&Resolver.create/2)
    end

    field :update_transaction, :transaction do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Transaction)
      arg(:id, non_null(:id))
      arg(:amount, :string)
      arg(:category_id, :id)
      arg(:date, :string)
      arg(:name, :string)
      arg(:note, :string)
      arg(:allocations, list_of(:allocation_input_object))
      arg(:tag_ids, list_of(:id))
      resolve(&Resolver.update/2)
    end

    field :delete_transaction, :transaction do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Transaction)
      arg(:id, non_null(:id))
      resolve(&Resolver.delete/2)
    end
  end
end

defmodule Spendable.Banks.Category.Types do
  use Absinthe.Schema.Notation

  alias Spendable.Banks.Category.Resolver
  alias Spendable.Middleware.CheckAuthentication

  object :category do
    field :id, :id
    field :name, :string
    field :parent_name, :string
  end

  object :category_queries do
    field :categories, list_of(:category) do
      middleware(CheckAuthentication)
      resolve(&Resolver.list/3)
    end
  end
end

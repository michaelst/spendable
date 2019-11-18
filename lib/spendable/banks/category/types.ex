defmodule Spendable.Banks.Category.Types do
  use Absinthe.Schema.Notation

  object :category do
    field :id, :id
    field :name, :string
    field :parent_name, :string
  end

  object :category_queries do
    field :categories, list_of(:category) do
      middleware(Spendable.Middleware.CheckAuthentication)
      resolve(&Spendable.Banks.Category.Resolver.list/3)
    end
  end
end

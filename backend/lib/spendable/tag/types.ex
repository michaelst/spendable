defmodule Spendable.Tag.Types do
  use Absinthe.Schema.Notation

  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Middleware.LoadModel
  alias Spendable.Tag
  alias Spendable.Tag.Resolver

  object :tag do
    field :id, :id
    field :name, :string
  end

  object :tag_queries do
    field :tags, list_of(:tag) do
      middleware(CheckAuthentication)
      resolve(&Resolver.list/2)
    end
  end

  object :tag_mutations do
    field :create_tag, :tag do
      middleware(CheckAuthentication)
      arg(:name, :string)
      resolve(&Resolver.create/2)
    end

    field :update_tag, :tag do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Tag)
      arg(:id, non_null(:id))
      arg(:name, :string)
      resolve(&Resolver.update/2)
    end

    field :delete_tag, :tag do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Tag)
      arg(:id, non_null(:id))
      resolve(&Resolver.delete/2)
    end
  end
end

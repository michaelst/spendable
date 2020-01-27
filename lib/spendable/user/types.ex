defmodule Spendable.User.Types do
  use Absinthe.Schema.Notation

  alias Spendable.User.Resolver

  object :user do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :token, :string
  end

  object :user_queries do
    field :current_user, :user do
      middleware(Spendable.Middleware.CheckAuthentication)
      resolve(&Resolver.current_user/2)
    end
  end

  object :user_mutations do
    field :create_user, :user do
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:email, :string)
      arg(:password, :string)
      resolve(&Resolver.create/2)
    end

    field :update_user, :user do
      middleware(Spendable.Middleware.CheckAuthentication)
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:email, :string)
      arg(:password, :string)
      resolve(&Resolver.update/2)
    end
  end
end

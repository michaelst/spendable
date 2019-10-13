defmodule Spendable.User.Types do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :token, :string
  end

  object :user_queries do
    field :create_user, :user do
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:email, :string)
      arg(:password, :string)
      resolve(&Spendable.User.Resolver.create/2)
    end

    field :update_user, :user do
      middleware(Spendable.Middleware.CheckAuthentication)
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:email, :string)
      arg(:password, :string)
      resolve(&Spendable.User.Resolver.update/2)
    end
  end
end

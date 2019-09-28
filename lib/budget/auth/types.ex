defmodule Budget.Auth.Types do
  use Absinthe.Schema.Notation

  object :auth_queries do
    field :login, type: :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Budget.Auth.Resolver.login/2)
    end
  end
end

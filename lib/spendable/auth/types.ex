defmodule Spendable.Auth.Types do
  use Absinthe.Schema.Notation

  alias Spendable.Auth.Resolver

  object :auth_mutations do
    field :login, type: :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolver.login/2)
    end
  end
end

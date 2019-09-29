defmodule Budget.Banks.Member.Types do
  use Absinthe.Schema.Notation

  object :bank_member do
    field :id, :id
    field :external_id, :string
    field :insitution_id, :string
    field :logo, :string
    field :name, :string
    field :plaid_token, :string
    field :provider, :string
    field :status, :string
  end

  object :bank_member_queries do
    field :create_bank_member, :bank_member do
      middleware(Budget.Middleware.CheckAuthentication)
      arg(:public_token, non_null(:string))
      resolve(&Budget.Banks.Member.Resolver.create/2)
    end
  end
end

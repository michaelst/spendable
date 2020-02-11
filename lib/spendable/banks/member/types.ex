defmodule Spendable.Banks.Member.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Spendable.Banks.Member.Resolver
  alias Spendable.Middleware.CheckAuthentication

  object :bank_member do
    field :id, :id
    field :external_id, :string
    field :institution_id, :string
    field :logo, :string
    field :name, :string
    field :provider, :string
    field :status, :string
    field :bank_accounts, list_of(:bank_account), resolve: dataloader(Spendable)
  end

  object :bank_member_queries do
    field :bank_members, list_of(:bank_member) do
      middleware(CheckAuthentication)
      resolve(&Resolver.list/3)
    end
  end

  object :bank_member_mutations do
    field :create_bank_member, :bank_member do
      middleware(CheckAuthentication)
      arg(:public_token, non_null(:string))
      resolve(&Resolver.create/2)
    end
  end
end

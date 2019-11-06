defmodule Spendable.Banks.Account.Types do
  use Absinthe.Schema.Notation

  alias Spendable.Banks.Account
  alias Spendable.Banks.Account.Resolver

  object :bank_account do
    field :id, :id
    field :external_id, :string
    field :available_balance, :string
    field :balance, :string
    field :name, :string
    field :number, :string
    field :sub_type, :string
    field :sync, :boolean
    field :type, :string
  end

  object :bank_account_mutations do
    field :update_bank_account, :bank_account do
      middleware(Spendable.Middleware.CheckAuthentication)
      middleware(Spendable.Middleware.LoadModel, module: Account)
      arg(:id, non_null(:id))
      arg(:sync, :boolean)
      resolve(&Resolver.update/2)
    end
  end
end

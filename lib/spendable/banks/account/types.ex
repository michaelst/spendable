defmodule Spendable.Banks.Account.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

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
    field :bank_member, :bank_member, resolve: dataloader(Spendable)
  end
end

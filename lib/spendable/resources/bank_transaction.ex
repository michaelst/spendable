defmodule Spendable.BankTransaction do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    repo(Spendable.Repo)
    table "bank_transactions"

    custom_indexes do
      index(["bank_account_id"])
      index(["user_id"])
    end
  end

  identities do
    identity :external_id, [:external_id, :bank_account_id]
  end

  attributes do
    attribute :id, :string,
      primary_key?: true,
      allow_nil?: false,
      default: fn -> UXID.generate!(prefix: "bkt") end

    attribute :amount, :decimal, allow_nil?: false
    attribute :date, :date, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :external_id, :string, allow_nil?: false, private?: true
    attribute :pending, :boolean, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, attribute_type: :string, allow_nil?: false
    belongs_to :bank_account, Spendable.BankAccount, attribute_type: :string, allow_nil?: false

    has_one :transaction, Spendable.Transaction
  end

  actions do
    defaults [:read, :create]
  end
end

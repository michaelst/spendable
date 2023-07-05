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
    identity :uuid, [:uuid]
    identity :external_id, [:external_id, :bank_account_id]
  end

  attributes do
    integer_primary_key :id

    attribute :uuid, :uuid do
      writable? false
      default &Ash.UUID.generate/0
      primary_key? false
      generated? true
    end

    attribute :amount, :decimal, allow_nil?: false
    attribute :date, :date, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :external_id, :string, allow_nil?: false, private?: true
    attribute :pending, :boolean, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, allow_nil?: false, attribute_type: :integer
    belongs_to :bank_account, Spendable.BankAccount, allow_nil?: false, attribute_type: :integer

    has_one :transaction, Spendable.Transaction
  end

  actions do
    defaults [:read, :create]
  end
end

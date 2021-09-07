defmodule Spendable.Transaction do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  postgres do
    repo(Spendable.Repo)
    table "transasctions"
  end

  attributes do
    integer_primary_key :id

    attribute :amount, :decimal, allow_nil?: false
    attribute :date, :date, allow_nil?: false
    attribute :name, :string # allow_nil?: false
    attribute :note, :string
    attribute :reviewed, :boolean, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :bank_transaction, Spendable.BankTransaction
    belongs_to :user, Spendable.User, required?: true

    # has_many :allocations, Spendable.Budgets.Allocation
  end

  graphql do
    type :transaction

    queries do
      get :get_transaction, :read, allow_nil?: false
      list :list_transactions, :read
    end

    mutations do
      create :create_transaction, :create
      update :update_transaction, :update
      destroy :delete_transaction, :destroy
    end
  end
end

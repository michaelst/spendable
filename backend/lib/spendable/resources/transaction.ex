defmodule Spendable.Transaction do
  use Ash.Resource,
    authorizers: [AshPolicyAuthorizer.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    repo(Spendable.Repo)
    table "transactions"
  end

  attributes do
    integer_primary_key :id

    attribute :amount, :decimal, allow_nil?: false
    attribute :date, :date, allow_nil?: false
    # allow_nil?: false
    attribute :name, :string
    attribute :note, :string
    attribute :reviewed, :boolean, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :bank_transaction, Spendable.BankTransaction, field_type: :integer
    belongs_to :user, Spendable.User, required?: true, field_type: :integer

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

  policies do
    policy always() do
      authorize_if attribute(:user_id, actor(:id))
    end
  end
end

defmodule Spendable.Transaction do
  use Ash.Resource,
    authorizers: [AshPolicyAuthorizer.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    repo(Spendable.Repo)
    table "transactions"

    custom_indexes do
      index ["bank_transaction_id"]
      index ["user_id"]
    end
  end

  attributes do
    integer_primary_key :id

    attribute :amount, :decimal, allow_nil?: false
    attribute :date, :date, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :note, :string
    attribute :reviewed, :boolean, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :bank_transaction, Spendable.BankTransaction, field_type: :integer
    belongs_to :user, Spendable.User, required?: true, field_type: :integer

    has_many :budget_allocations, Spendable.BudgetAllocation
  end

  actions do
    read :read do
      primary? true
      pagination offset?: true
    end

    create :create do
      primary? true
      change relate_actor(:user)
      argument :budget_allocations, {:array, :map}
      change manage_relationship(:budget_allocations, type: :direct_control)
    end

    create :private_create

    update :update do
      primary? true
      argument :budget_allocations, {:array, :map}
      change manage_relationship(:budget_allocations, type: :direct_control)
    end
  end

  graphql do
    type :transaction

    queries do
      get :transaction, :read, allow_nil?: false
      list :transactions, :read
    end

    mutations do
      create :create_transaction, :create
      update :update_transaction, :update
      destroy :delete_transaction, :destroy
    end

    managed_relationships do
      managed_relationship :create, :budget_allocations do
        types budget: :create_budget_allocation_budget_input
      end

      managed_relationship :update, :budget_allocations do
        types budget: :update_budget_allocation_budget_input
      end
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if attribute(:user_id, actor(:id))
    end
  end
end

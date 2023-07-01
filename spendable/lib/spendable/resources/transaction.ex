defmodule Spendable.Transaction do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  postgres do
    repo(Spendable.Repo)
    table "transactions"

    custom_indexes do
      index(["bank_transaction_id"])
      index(["user_id"])
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
    belongs_to :bank_transaction, Spendable.BankTransaction, attribute_type: :integer
    belongs_to :user, Spendable.User, allow_nil?: false, attribute_type: :integer

    has_many :budget_allocations, Spendable.BudgetAllocation
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true
      pagination offset?: true
    end

    create :create do
      primary? true
      change relate_actor(:user)
      argument :budget_allocations, {:array, :map}
      change Spendable.Transaction.Changes.AllocateSpendable
      change manage_relationship(:budget_allocations, type: :direct_control)
    end

    update :update do
      primary? true
      argument :budget_allocations, {:array, :map}
      change Spendable.Transaction.Changes.AllocateSpendable
      change manage_relationship(:budget_allocations, type: :direct_control)
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if expr(user_id == actor(:id))
    end
  end
end

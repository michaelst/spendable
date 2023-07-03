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
    attribute :name, :ci_string, allow_nil?: false
    attribute :note, :ci_string
    attribute :reviewed, :boolean, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :bank_transaction, Spendable.BankTransaction, attribute_type: :integer
    belongs_to :user, Spendable.User, allow_nil?: false, attribute_type: :integer

    has_many :budget_allocations, Spendable.BudgetAllocation
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if expr(user_id == actor(:id))
    end
  end
end

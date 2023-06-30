defmodule Spendable.BudgetAllocation do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    repo(Spendable.Repo)
    table "budget_allocations"

    custom_indexes do
      index(["budget_id"])
      index(["transaction_id"])
      index(["user_id"])
    end
  end

  attributes do
    integer_primary_key :id

    attribute :amount, :decimal, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :transaction, Spendable.Transaction, allow_nil?: false, attribute_type: :integer
    belongs_to :budget, Spendable.Budget, allow_nil?: false, attribute_type: :integer
    belongs_to :user, Spendable.User, allow_nil?: false, attribute_type: :integer
  end

  actions do
    read :read do
      primary? true
      prepare {Spendable.Preparations.Select, [fields: [:transaction_id]]}
      prepare Spendable.BudgetAllocation.Preparations.Sort
    end

    create :create do
      primary? true
      change relate_actor(:user)
      argument :budget, :map
      argument :transaction, :map
      change manage_relationship(:budget, type: :append_and_remove)
      change manage_relationship(:transaction, type: :append_and_remove)
      change Spendable.BudgetAllocation.Changes.AllocateSpendable
    end

    update :update do
      primary? true
      argument :budget, :map
      change manage_relationship(:budget, type: :append_and_remove)
      change Spendable.BudgetAllocation.Changes.AllocateSpendable
    end

    destroy :destroy do
      primary? true
      change Spendable.BudgetAllocation.Changes.AllocateSpendable
    end
  end

  graphql do
    type :budget_allocation

    queries do
      get :budget_allocation, :read, allow_nil?: false
    end

    mutations do
      create :create_budget_allocation, :create
      update :update_budget_allocation, :update
      destroy :delete_budget_allocation, :destroy
    end

    managed_relationships do
      managed_relationship :create, :budget do
        lookup_with_primary_key? true
      end

      managed_relationship :update, :budget do
        lookup_with_primary_key? true
      end

      managed_relationship :create, :transaction do
        lookup_with_primary_key? true
      end
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if expr(user_id == actor(:id))
    end
  end
end

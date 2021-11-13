defmodule Spendable.Budget do
  use Ash.Resource,
    authorizers: [AshPolicyAuthorizer.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    repo(Spendable.Repo)
    table "budgets"

    custom_indexes do
      index(["user_id"])
    end
  end

  attributes do
    integer_primary_key :id

    attribute :adjustment, :decimal, allow_nil?: false, default: Decimal.new("0.00")
    attribute :name, :string, allow_nil?: false
    attribute :track_spending_only, :boolean, allow_nil?: false, default: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, required?: true, field_type: :integer

    has_many :budget_allocations, Spendable.BudgetAllocation
    has_many :budget_allocation_template_lines, Spendable.BudgetAllocationTemplateLine
  end

  calculations do
    calculate :balance, :decimal, Spendable.Budget.Calculations.Balance do
      allow_nil? false
      select [:adjustment]
    end

    calculate :spent, :decimal, Spendable.Budget.Calculations.Spent do
      argument :month, :date
      allow_nil? false
    end
  end

  actions do
    create :create do
      primary? true
      change relate_actor(:user)
    end
  end

  graphql do
    type :budget

    queries do
      get :budget, :read, allow_nil?: false
      list :budgets, :read
    end

    mutations do
      create :create_budget, :create
      update :update_budget, :update
      destroy :delete_budget, :destroy
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if attribute(:user_id, actor(:id))
    end
  end
end

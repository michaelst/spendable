defmodule Spendable.Budget do
  use Ash.Resource,
    authorizers: [AshPolicyAuthorizer.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    repo(Spendable.Repo)
    table "budgets"
  end

  attributes do
    integer_primary_key :id

    attribute :adjustment, :decimal, allow_nil?: false, default: Decimal.new("0.00")
    attribute :name, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, required?: true, field_type: :integer

    has_many :allocations, Spendable.BudgetAllocation
    has_many :allocation_template_lines, Spendable.BudgetAllocationTemplateLine
  end

  calculations do
    calculate :balance, :string, Spendable.Budget.Calculations.Balance,
      allow_nil?: false,
      select: [:adjustment]
  end

  actions do
    read :read, do: primary? true

    read :list do
      prepare build(sort: [name: :asc])
    end

    create :create do
      primary? true
      change relate_actor(:user)
    end

    update :update, primary?: true
    destroy :destroy, primary?: true
  end

  graphql do
    type :budget

    queries do
      get :budget, :read, allow_nil?: false
      list :budgets, :list
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

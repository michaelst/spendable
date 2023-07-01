defmodule Spendable.Budget do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  alias Spendable.Budget.SpentByMonth

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
    attribute :name, :ci_string, allow_nil?: false
    attribute :track_spending_only, :boolean, allow_nil?: false, default: false
    attribute :archived_at, :utc_datetime

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, allow_nil?: false, attribute_type: :integer

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

    calculate :spent_by_month, {:array, SpentByMonth}, Spendable.Budget.Calculations.SpentByMonth do
      argument :number_of_months, :integer
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      change relate_actor(:user)
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if expr(user_id == actor(:id))
    end
  end
end

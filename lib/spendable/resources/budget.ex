defmodule Spendable.Budget do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  require Ash.Resource.Preparation.Builtins
  alias Spendable.Budget.SpentByMonth
  alias Spendable.Budget.Storage

  require Ash.Query

  postgres do
    repo(Spendable.Repo)
    table "budgets"

    custom_indexes do
      index(["user_id"])
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :adjustment, :decimal, allow_nil?: false, default: Decimal.new("0.00")
    attribute :name, :ci_string, allow_nil?: false
    attribute :track_spending_only, :boolean, allow_nil?: false, default: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, allow_nil?: false

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

    calculate :spent_by_month,
              {:array, SpentByMonth},
              Spendable.Budget.Calculations.SpentByMonth do
      argument :number_of_months, :integer
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]

    read :list do
      argument :search, :string
      argument :selected_month, :date

      filter expr(is_nil(archived_at))

      # search
      prepare fn query, _context ->
        search = query.arguments[:search]

        if is_bitstring(search) and byte_size(search) > 0 do
          Ash.Query.filter(query, contains(name, ^search))
        else
          query
        end
      end

      # sort
      prepare after_action(fn _query, results ->
                {:ok,
                 Enum.sort(results, fn a, b ->
                   to_string(b.name) != "Spendable" and
                     (to_string(a.name) == "Spendable" or a.name < b.name)
                 end)}
              end)

      # load
      prepare build(
                load: [
                  :balance,
                  spent: %{month: arg(:selected_month) || Date.utc_today()}
                ]
              )
    end

    create :create do
      primary? true
      change relate_actor(:user)
    end

    update :update do
      primary? true

      argument :balance, :decimal
      change Spendable.Budget.Changes.SetAdjustment
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if expr(user_id == ^actor(:id))
    end
  end

  def form_options(user_id) do
    Storage.form_options(user_id)
  end
end

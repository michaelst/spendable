defmodule Spendable.Budget do
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

    attribute :adjustment, :decimal, allow_nil?: false, default: Decimal.new("0.00")
    attribute :name, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, required?: true, field_type: :integer

    # has_many :allocations, Spendable.Budgets.Allocation
    # has_many :allocation_template_lines, Spendable.Budgets.AllocationTemplateLine
  end

  # |> prepare_changes(fn
  #   %{data: %{id: nil}, changes: %{balance: %Decimal{} = balance}} = changeset ->
  #     put_change(changeset, :adjustment, balance)
  #
  #   %{data: %{id: id}, changes: %{balance: %Decimal{} = balance}} = changeset ->
  #     put_change(changeset, :adjustment, Decimal.sub(balance, allocated(id)))
  #
  #   changeset ->
  #     changeset
  # end)

  calculations do
    calculate :balance, :string, Spendable.Budget.Calculations.Balance,
      allow_nil?: false,
      select: [:adjustment]
  end

  actions do
    read :read do
      primary? true
      prepare build(sort: [name: :asc])
    end

    create :create, primary?: true
    update :update, primary?: true
    destroy :destroy, primary?: true
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

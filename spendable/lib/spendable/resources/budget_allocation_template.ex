defmodule Spendable.BudgetAllocationTemplate do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  postgres do
    repo(Spendable.Repo)
    table "budget_allocation_templates"

    custom_indexes do
      index(["user_id"])
    end
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, allow_nil?: false, attribute_type: :integer

    has_many :budget_allocation_template_lines, Spendable.BudgetAllocationTemplateLine
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

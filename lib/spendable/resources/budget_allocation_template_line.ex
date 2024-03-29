defmodule Spendable.BudgetAllocationTemplateLine do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  postgres do
    repo Spendable.Repo
    table "budget_allocation_template_lines"

    custom_indexes do
      index ["budget_id"]
      index ["budget_allocation_template_id"]
      index ["user_id"]
    end

    references do
      reference :budget_allocation_template, on_delete: :delete
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :amount, :decimal, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :budget, Spendable.Budget, allow_nil?: false

    belongs_to :budget_allocation_template, Spendable.BudgetAllocationTemplate, allow_nil?: false

    belongs_to :user, Spendable.User, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      change relate_actor(:user)

      argument :budget_id, :string
      change manage_relationship(:budget_id, :budget, type: :append_and_remove)
    end

    update :update do
      primary? true

      argument :budget_id, :string
      change manage_relationship(:budget_id, :budget, type: :append_and_remove)
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if expr(user_id == ^actor(:id))
    end
  end
end

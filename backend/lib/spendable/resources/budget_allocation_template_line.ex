defmodule Spendable.BudgetAllocationTemplateLine do
  use Ash.Resource,
    authorizers: [AshPolicyAuthorizer.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    repo(Spendable.Repo)
    table "budget_allocation_template_lines"
  end

  attributes do
    integer_primary_key :id

    attribute :amount, :decimal, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :budget, Spendable.Budget, required?: true, field_type: :integer
    belongs_to :budget_allocation_template, Spendable.BudgetAllocationTemplate, required?: true, field_type: :integer
    belongs_to :user, Spendable.User, required?: true, field_type: :integer
  end

  graphql do
    type :budget_allocation_template_line

    queries do
      get :budget_allocation_template_line, :read, allow_nil?: false
      list :budget_allocation_template_lines, :read
    end

    mutations do
      create :create_budget_allocation_template_line, :create
      update :update_budget_allocation_template_line, :update
      destroy :delete_budget_allocation_template_line, :destroy
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if attribute(:user_id, actor(:id))
    end
  end
end

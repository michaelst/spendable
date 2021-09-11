defmodule Spendable.BudgetAllocationTemplate do
  use Ash.Resource,
    authorizers: [AshPolicyAuthorizer.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    repo(Spendable.Repo)
    table "budget_allocation_templates"
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, required?: true, field_type: :integer

    has_many :budget_allocation_template_lines, Spendable.BudgetAllocationTemplateLine
  end

  graphql do
    type :budget_allocation_template

    queries do
      get :budget_allocation_template, :read, allow_nil?: false
      list :budget_allocation_templates, :read
    end

    mutations do
      create :create_budget_allocation_template, :create
      update :update_budget_allocation_template, :update
      destroy :delete_budget_allocation_template, :destroy
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if attribute(:user_id, actor(:id))
    end
  end
end

defmodule Spendable.BudgetAllocationTemplate do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  alias Spendable.Budget
  alias Spendable.BudgetAllocationTemplate.Storage

  postgres do
    repo(Spendable.Repo)
    table "budget_allocation_templates"

    custom_indexes do
      index(["user_id"])
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :user, Spendable.User, allow_nil?: false

    has_many :budget_allocation_template_lines, Spendable.BudgetAllocationTemplateLine
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      change relate_actor(:user)

      argument :budget_allocation_template_lines, {:array, :map}
      change manage_relationship(:budget_allocation_template_lines, type: :create)
    end

    update :update do
      primary? true

      argument :budget_allocation_template_lines, {:array, :map}

      change manage_relationship(:budget_allocation_template_lines,
               on_lookup: :relate,
               on_no_match: :create,
               on_match: :update,
               on_missing: :destroy
             )
    end
  end

  policies do
    policy always() do
      authorize_if action(:create)
      authorize_if expr(user_id == ^actor(:id))
    end
  end

  def budget_form_options(user_id) do
    Budget.form_options(user_id)
  end

  def list(user_id, opts) do
    Storage.list(user_id, opts)
  end

  def form_options(user_id) do
    Storage.form_options(user_id)
  end

  def get_template(id) do
    Storage.get_template(id)
  end
end

defmodule Spendable.Transaction do
  use Ash.Resource,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  alias Spendable.Budget
  alias Spendable.BudgetAllocationTemplate
  alias Spendable.Transaction.Storage

  postgres do
    repo(Spendable.Repo)
    table "transactions"

    custom_indexes do
      # index(["bank_transaction_id"])
      # index(["user_id"])
    end
  end

  identities do
    identity :uuid, [:uuid]
  end

  attributes do
    integer_primary_key :id

    attribute :uuid, :uuid do
      writable? false
      default &Ash.UUID.generate/0
      primary_key? false
      generated? true
    end

    attribute :amount, :decimal, allow_nil?: false
    attribute :date, :date, allow_nil?: false
    attribute :name, :ci_string, allow_nil?: false
    attribute :note, :ci_string
    attribute :reviewed, :boolean, allow_nil?: false

    timestamps()
  end

  relationships do
    belongs_to :bank_transaction, Spendable.BankTransaction
    belongs_to :user, Spendable.User, allow_nil?: false

    has_many :budget_allocations, Spendable.BudgetAllocation
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      change relate_actor(:user)

      argument :budget_allocations, {:array, :map}
      change manage_relationship(:budget_allocations, type: :create)

      change Spendable.Transaction.Changes.AllocateSpendable
    end

    update :update do
      primary? true

      argument :budget_allocations, {:array, :map}

      change manage_relationship(:budget_allocations,
               on_lookup: :relate,
               on_no_match: :create,
               on_match: :update,
               on_missing: :destroy
             )

      change Spendable.Transaction.Changes.AllocateSpendable
    end

    update :update_allocations do
      argument :budget_allocations, {:array, :map}

      change manage_relationship(:budget_allocations,
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

  def template_form_options(user_id) do
    BudgetAllocationTemplate.form_options(user_id)
  end

  def get_template(id) do
    BudgetAllocationTemplate.get_template(id)
  end

  def list_transactions(user_id, opts) do
    Storage.list_transactions(user_id, opts)
  end
end

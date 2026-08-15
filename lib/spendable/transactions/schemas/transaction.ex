defmodule Spendable.Transactions.Schemas.Transaction do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets.Schemas.BudgetAllocation

  @primary_key {:id, UXID, autogenerate: true, prefix: "txn"}
  schema "transactions" do
    field :amount, :decimal
    field :date, :date
    field :name, :string
    field :note, :string
    field :reviewed, :boolean, default: false
    field :excluded, :boolean, default: false

    belongs_to :user, User
    belongs_to :bank_transaction, Spendable.Banks.Schemas.BankTransaction

    has_many :budget_allocations, BudgetAllocation, on_replace: :delete

    timestamps()
  end

  def changeset(transaction \\ %__MODULE__{}, attrs) do
    transaction
    |> cast(attrs, [:amount, :date, :name, :note, :reviewed, :excluded, :bank_transaction_id])
    |> validate_required([:amount, :date, :name, :reviewed])
    |> validate_relationships([:bank_transaction])
    # Stamp the owner onto each line so a posted budget_id is checked against it.
    |> cast_assoc(:budget_allocations,
      with: &BudgetAllocation.changeset(%{&1 | user_id: transaction.user_id}, &2),
      sort_param: :allocations_sort,
      drop_param: :allocations_drop
    )
  end
end

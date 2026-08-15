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

  @doc "Allocations are edited on the transaction's own form, so they are cast with it."
  def changeset(transaction \\ %__MODULE__{}, attrs) do
    transaction
    |> cast(attrs, [:amount, :date, :name, :note, :reviewed, :excluded])
    |> validate_required([:amount, :date, :name, :reviewed])
    |> cast_assoc(:budget_allocations,
      with: {BudgetAllocation, :changeset, []},
      sort_param: :allocations_sort,
      drop_param: :allocations_drop
    )
  end
end

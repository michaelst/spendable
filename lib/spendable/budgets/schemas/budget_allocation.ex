defmodule Spendable.Budgets.Schemas.BudgetAllocation do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Transactions.Schemas.Transaction

  @primary_key {:id, UXID, autogenerate: true, prefix: "bal"}
  schema "budget_allocations" do
    field :amount, :decimal

    belongs_to :budget, Budget
    belongs_to :transaction, Transaction
    belongs_to :user, User

    timestamps()
  end

  def changeset(allocation \\ %__MODULE__{}, attrs) do
    allocation
    |> cast(attrs, [:amount, :budget_id])
    |> validate_required([:amount, :budget_id])
    |> validate_relationships([:budget])
  end
end

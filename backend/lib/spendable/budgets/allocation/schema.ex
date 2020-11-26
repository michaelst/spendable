defmodule Spendable.Budgets.Allocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budget_allocations" do
    field :amount, :decimal

    belongs_to :budget, Spendable.Budgets.Budget
    belongs_to :transaction, Spendable.Transaction
    belongs_to :user, Spendable.User

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __schema__(:fields) -- [:id])
    |> validate_required([:budget_id, :amount])
  end
end

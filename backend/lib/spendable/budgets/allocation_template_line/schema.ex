defmodule Spendable.Budgets.AllocationTemplateLine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budget_allocation_template_lines" do
    field :amount, :decimal

    belongs_to :allocation_template, Spendable.Budgets.AllocationTemplate, foreign_key: :budget_allocation_template_id
    belongs_to :budget, Spendable.Budgets.Budget
    belongs_to :user, Spendable.User

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __schema__(:fields) -- [:id])
    |> validate_required([:budget_id, :amount])
  end
end

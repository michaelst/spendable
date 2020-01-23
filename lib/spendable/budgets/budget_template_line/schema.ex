defmodule Spendable.Budgets.BudgetTemplateLine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budget_template_lines" do
    field :amount, :decimal
    field :priority, :integer

    belongs_to :budget, Spendable.Budgets.Budget
    belongs_to :budget_template, Spendable.Budgets.BudgetTemplate

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __schema__(:fields) -- [:id])
    |> validate_required([:budget_id, :amount, :priority])
  end
end

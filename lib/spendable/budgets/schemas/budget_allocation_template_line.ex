defmodule Spendable.Budgets.Schemas.BudgetAllocationTemplateLine do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Budgets.Schemas.BudgetAllocationTemplate

  @primary_key {:id, UXID, autogenerate: true, prefix: "batl"}
  schema "budget_allocation_template_lines" do
    field :amount, :decimal

    belongs_to :budget, Budget
    belongs_to :budget_allocation_template, BudgetAllocationTemplate
    belongs_to :user, User

    timestamps()
  end

  def changeset(line, attrs, user_id) do
    line
    |> cast(attrs, [:amount, :budget_id])
    |> put_change(:user_id, user_id)
    |> validate_required([:amount, :budget_id])
    |> validate_relationships([:budget], user_id)
  end
end

defmodule Spendable.Repo.Migrations.RenameBudgetBalance do
  use Ecto.Migration

  def change do
    rename table(:budget_templates), to: table(:budget_allocation_templates)
    rename table(:budget_template_lines), to: table(:budget_allocation_template_lines)
    rename table(:budgets), :balance, to: :allocated
    rename table(:budget_allocation_template_lines), :budget_template_id, to: :budget_allocation_template_id
  end
end

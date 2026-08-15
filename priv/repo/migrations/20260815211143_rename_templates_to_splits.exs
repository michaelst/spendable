defmodule Spendable.Repo.Migrations.RenameTemplatesToSplits do
  use Ecto.Migration

  # Postgres truncates generated names at 63 characters, which is why the old foreign key and its
  # index both landed on this stem.
  @old_stem "budget_allocation_template_lines_budget_allocation_template_id_"

  def change do
    rename table(:budget_allocation_templates), to: table(:splits)
    rename table(:budget_allocation_template_lines), to: table(:split_lines)
    rename table(:split_lines), :budget_allocation_template_id, to: :split_id

    rename_constraint(:splits, "budget_allocation_templates_pkey", "splits_pkey")

    rename_constraint(
      :splits,
      "budget_allocation_templates_user_id_fkey",
      "splits_user_id_fkey"
    )

    rename_index("budget_allocation_templates_user_id_index", "splits_user_id_index")

    rename_constraint(:split_lines, "budget_allocation_template_lines_pkey", "split_lines_pkey")

    rename_constraint(
      :split_lines,
      "budget_allocation_template_lines_user_id_fkey",
      "split_lines_user_id_fkey"
    )

    rename_constraint(
      :split_lines,
      "budget_allocation_template_lines_budget_id_fkey",
      "split_lines_budget_id_fkey"
    )

    rename_constraint(:split_lines, @old_stem, "split_lines_split_id_fkey")

    rename_index("budget_allocation_template_lines_user_id_index", "split_lines_user_id_index")
    rename_index("budget_allocation_template_lines_budget_id_index", "split_lines_budget_id_index")
    rename_index(@old_stem, "split_lines_split_id_index")
  end

  defp rename_constraint(table, from, to) do
    execute ~s(ALTER TABLE #{table} RENAME CONSTRAINT "#{from}" TO "#{to}"),
            ~s(ALTER TABLE #{table} RENAME CONSTRAINT "#{to}" TO "#{from}")
  end

  defp rename_index(from, to) do
    execute ~s(ALTER INDEX "#{from}" RENAME TO "#{to}"),
            ~s(ALTER INDEX "#{to}" RENAME TO "#{from}")
  end
end

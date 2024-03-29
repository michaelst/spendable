defmodule Spendable.Repo.Migrations.AddBudgetUuids do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:budget_allocations) do
      add :budget_uuid_id,
          references(:budgets,
            column: :uuid,
            name: "budget_allocations_budget_uuid_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    alter table(:budget_allocation_template_lines) do
      add :budget_uuid_id,
          references(:budgets,
            column: :uuid,
            name: "budget_allocation_template_lines_budget_uuid_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    execute """
    UPDATE budget_allocations
    SET budget_uuid_id = budgets.uuid
    FROM budgets
    WHERE budget_allocations.budget_id = budgets.id
    """

    execute """
    UPDATE budget_allocation_template_lines
    SET budget_uuid_id = budgets.uuid
    FROM budgets
    WHERE budget_allocation_template_lines.budget_id = budgets.id
    """
  end

  def down do
    drop constraint(
           :budget_allocation_template_lines,
           "budget_allocation_template_lines_budget_uuid_id_fkey"
         )

    alter table(:budget_allocation_template_lines) do
      remove :budget_uuid_id
    end

    drop constraint(:budget_allocations, "budget_allocations_budget_uuid_id_fkey")

    alter table(:budget_allocations) do
      remove :budget_uuid_id
    end
  end
end

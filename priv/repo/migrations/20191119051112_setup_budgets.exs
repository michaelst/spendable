defmodule Spendable.Repo.Migrations.SetupBudgets do
  use Ecto.Migration

  def change do
    create table(:budgets) do
      add(:user_id, references(:users), null: false)
      add(:name, :string, null: false)
      add(:goal, :decimal, precision: 17, scale: 2)
      timestamps()
    end

    create table(:budget_allocation_templates) do
      add(:user_id, references(:users), null: false)
      add(:name, :string, null: false)
      timestamps()
    end

    create table(:budget_allocation_template_lines) do
      add(:budget_id, references(:budgets), null: false)
      add(:budget_allocation_template_id, references(:budget_allocation_templates), null: false)
      add(:amount, :decimal, precision: 17, scale: 2, null: false)
      timestamps()
    end
  end
end

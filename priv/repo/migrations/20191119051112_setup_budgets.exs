defmodule Spendable.Repo.Migrations.SetupBudgets do
  use Ecto.Migration

  def change do
    create table(:budgets) do
      add(:user_id, references(:users), null: false)
      add(:name, :string, null: false)
      add(:balance, :decimal, precision: 17, scale: 2, null: false)
      add(:goal, :decimal, precision: 17, scale: 2)
      timestamps()
    end

    create table(:budget_templates) do
      add(:user_id, references(:users), null: false)
      add(:name, :string, null: false)
      timestamps()
    end

    create table(:budget_template_lines) do
      add(:budget_id, references(:budgets), null: false)
      add(:budget_template_id, references(:budget_templates), null: false)
      add(:amount, :decimal, precision: 17, scale: 2, null: false)
      add(:priority, :smallint, null: false)
      timestamps()
    end
  end
end

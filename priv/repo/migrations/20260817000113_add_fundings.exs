defmodule Spendable.Repo.Migrations.AddFundings do
  use Ecto.Migration

  def change do
    create table(:fundings) do
      add :amount, :decimal, precision: 17, scale: 2, null: false
      add :month, :date, null: false
      add :user_id, references(:users), null: false
      add :budget_id, references(:budgets, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:fundings, [:user_id])

    # One row per budget per month is what makes funding a month safe to re-run.
    create unique_index(:fundings, [:budget_id, :month])

    alter table(:budgets) do
      add :funding_amount, :decimal
    end
  end
end

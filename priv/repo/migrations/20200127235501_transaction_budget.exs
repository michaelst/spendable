defmodule Spendable.Repo.Migrations.TransactionBudget do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add(:budget_id, references(:budgets))
    end
  end
end

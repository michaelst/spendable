defmodule Spendable.Repo.Migrations.AddBudgetRollover do
  use Ecto.Migration

  def change do
    # True keeps what every budget already does: a balance carries forward, so an overspend eats
    # into the next month rather than being topped back up.
    alter table(:budgets) do
      add :rollover, :boolean, null: false, default: true
    end
  end
end

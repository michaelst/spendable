defmodule Spendable.Repo.Migrations.CleanupUnsuedFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove(:first_name)
      remove(:last_name)
    end

    alter table(:bank_transactions) do
      remove(:location)
    end

    alter table(:budgets) do
      add(:adjustment, :decimal, precision: 17, scale: 2, null: false, default: 0)
    end
  end
end

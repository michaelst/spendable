defmodule Spendable.Repo.Migrations.ReviewedTransactions do
  use Ecto.Migration

  def change() do
    alter table(:transactions) do
      add :reviewed, :boolean, null: false, reviewed: false
    end
  end
end

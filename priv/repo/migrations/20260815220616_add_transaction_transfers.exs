defmodule Spendable.Repo.Migrations.AddTransactionTransfers do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :transfer_id, references(:transactions, on_delete: :nilify_all)
    end

    create index(:transactions, [:transfer_id])
  end
end

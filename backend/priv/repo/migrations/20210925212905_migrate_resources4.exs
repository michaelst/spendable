defmodule Spendable.Repo.Migrations.MigrateResources4 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:bank_transactions) do
      remove :category_id

      modify :updated_at, :utc_datetime_usec, default: fragment("now()")
      modify :inserted_at, :utc_datetime_usec, default: fragment("now()")
      modify :external_id, :text
      modify :name, :text
    end

    create index(:bank_transactions, [:bank_account_id], name: "bank_transactions_bank_account_id_index")

    execute(
      "ALTER INDEX bank_transactions_bank_account_id_external_id_index RENAME TO bank_transactions_external_id_index"
    )
  end

  def down do
    execute(
      "ALTER INDEX bank_transactions_external_id_index RENAME TO bank_transactions_bank_account_id_external_id_index"
    )

    drop index(:bank_transactions, [:user_id], name: "bank_transactions_bank_account_id_index")

    alter table(:bank_transactions) do
      modify :name, :string
      modify :external_id, :string
      modify :inserted_at, :utc_datetime, default: nil
      modify :updated_at, :utc_datetime, default: nil

      add :category_id, references(:categories, column: :id, name: "bank_transactions_category_id_fkey", type: :bigint)
    end
  end
end
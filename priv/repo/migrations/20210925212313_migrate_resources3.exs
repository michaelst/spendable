defmodule Spendable.Repo.Migrations.MigrateResources3 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:bank_members) do
      modify :updated_at, :utc_datetime_usec, default: fragment("now()")
      modify :inserted_at, :utc_datetime_usec, default: fragment("now()")
      modify :status, :text
      modify :provider, :text
      modify :plaid_token, :text, null: false
      modify :name, :text
      modify :institution_id, :text
      modify :external_id, :text
    end

    create index(:bank_members, [:user_id], name: "bank_members_user_id_index")

    execute(
      "ALTER INDEX bank_members_user_id_external_id_index RENAME TO bank_members_external_id_index"
    )
  end

  def down do
    execute(
      "ALTER INDEX bank_members_external_id_index RENAME TO bank_members_user_id_external_id_index"
    )

    create index(:bank_members, [:user_id], name: "bank_members_user_id_index")

    alter table(:bank_members) do
      modify :external_id, :string
      modify :institution_id, :string
      modify :name, :string
      modify :plaid_token, :string, null: true
      modify :provider, :string
      modify :status, :string
      modify :inserted_at, :utc_datetime, default: nil
      modify :updated_at, :utc_datetime, default: nil
    end
  end
end

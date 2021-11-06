defmodule Spendable.Repo.Migrations.MigrateResources6 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:budget_allocation_templates) do
      modify :updated_at, :utc_datetime_usec, default: fragment("now()")
      modify :inserted_at, :utc_datetime_usec, default: fragment("now()")
      modify :name, :text
    end
  end

  def down do
    alter table(:budget_allocation_templates) do
      modify :name, :string
      modify :inserted_at, :utc_datetime, default: nil
      modify :updated_at, :utc_datetime, default: nil
    end
  end
end
defmodule Spendable.Repo.Migrations.MigrateResources17 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:budgets) do
      modify :name, :citext
    end
  end

  def down do
    alter table(:budgets) do
      modify :name, :text
    end
  end
end
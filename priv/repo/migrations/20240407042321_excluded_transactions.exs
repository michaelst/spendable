defmodule Spendable.Repo.Migrations.ExcludedTransactions do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:transactions) do
      add :excluded, :boolean, null: false, default: false
    end
  end

  def down do
    alter table(:transactions) do
      remove :excluded
    end
  end
end

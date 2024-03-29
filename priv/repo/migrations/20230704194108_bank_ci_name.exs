defmodule Spendable.Repo.Migrations.BankCiName do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:bank_members) do
      modify :name, :citext
    end
  end

  def down do
    alter table(:bank_members) do
      modify :name, :text
    end
  end
end

defmodule Spendable.Repo.Migrations.ArchiveTemplates do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop_if_exists index(:budget_allocation_templates, ["user_id"],
                     name: "budget_allocation_templates_user_id_index"
                   )

    alter table(:budget_allocation_templates) do
      add :archived_at, :utc_datetime_usec
    end
  end

  def down do
    alter table(:budget_allocation_templates) do
      remove :archived_at
    end

    create index(:budget_allocation_templates, ["user_id"])
  end
end

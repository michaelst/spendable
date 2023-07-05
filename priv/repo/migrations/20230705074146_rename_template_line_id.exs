defmodule Spendable.Repo.Migrations.RenameTemplateLineId do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    rename table(:budget_allocation_template_lines), :uuid, to: :id
  end

  def down do
    rename table(:budget_allocation_template_lines), :id, to: :uuid
  end
end
defmodule Spendable.Repo.Migrations.MigrateResources7 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop_if_exists index(:budget_allocations, [:user_id],
                     name: "budget_allocations_user_id_index"
                   )

    drop_if_exists index(:budget_allocations, [:transaction_id],
                     name: "budget_allocations_transaction_id_index"
                   )

    drop_if_exists index(:budget_allocations, [:budget_id],
                     name: "budget_allocations_budget_id_index"
                   )

    create index(:budget_allocations, ["user_id"])

    create index(:budget_allocations, ["transaction_id"])

    create index(:budget_allocations, ["budget_id"])

    alter table(:budget_allocations) do
      modify :updated_at, :utc_datetime_usec, default: fragment("now()")
      modify :inserted_at, :utc_datetime_usec, default: fragment("now()")
    end
  end

  def down do
    alter table(:budget_allocations) do
      modify :inserted_at, :utc_datetime, default: nil
      modify :updated_at, :utc_datetime, default: nil
    end

    drop_if_exists index(:budget_allocations, ["budget_id"],
                     name: "budget_allocations_budget_id_index"
                   )

    drop_if_exists index(:budget_allocations, ["transaction_id"],
                     name: "budget_allocations_transaction_id_index"
                   )

    drop_if_exists index(:budget_allocations, ["user_id"],
                     name: "budget_allocations_user_id_index"
                   )
  end
end

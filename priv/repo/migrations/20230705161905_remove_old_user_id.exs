defmodule Spendable.Repo.Migrations.RemoveOldUserId do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop_if_exists unique_index(:users, [:uuid], name: "users_uuid_index")

    drop_if_exists index(:transactions, ["user_id"], name: "transactions_user_id_index")

    drop_if_exists index(:transactions, ["bank_transaction_id"],
                     name: "transactions_bank_transaction_id_index"
                   )

    alter table(:transactions) do
      remove :user_id
    end

    drop_if_exists index(:budgets, ["user_id"], name: "budgets_user_id_index")

    alter table(:budgets) do
      remove :user_id
    end

    drop_if_exists index(:budget_allocations, ["user_id"],
                     name: "budget_allocations_user_id_index"
                   )

    drop_if_exists index(:budget_allocations, ["transaction_id"],
                     name: "budget_allocations_transaction_id_index"
                   )

    drop_if_exists index(:budget_allocations, ["budget_id"],
                     name: "budget_allocations_budget_id_index"
                   )

    alter table(:budget_allocations) do
      remove :user_id
    end

    drop_if_exists index(:budget_allocation_templates, ["user_id"],
                     name: "budget_allocation_templates_user_id_index"
                   )

    alter table(:budget_allocation_templates) do
      remove :user_id
    end

    drop_if_exists index(:budget_allocation_template_lines, ["user_id"],
                     name: "budget_allocation_template_lines_user_id_index"
                   )

    drop_if_exists index(:budget_allocation_template_lines, ["budget_allocation_template_id"],
                     name: "budget_allocation_template_lines_budget_allocation_template_id_index"
                   )

    drop_if_exists index(:budget_allocation_template_lines, ["budget_id"],
                     name: "budget_allocation_template_lines_budget_id_index"
                   )

    alter table(:budget_allocation_template_lines) do
      remove :user_id
    end

    drop_if_exists index(:bank_transactions, ["user_id"], name: "bank_transactions_user_id_index")

    drop_if_exists index(:bank_transactions, ["bank_account_id"],
                     name: "bank_transactions_bank_account_id_index"
                   )

    alter table(:bank_transactions) do
      remove :user_id
    end

    drop_if_exists unique_index(:bank_transactions, [:bank_account_id, :external_id],
                     name: "bank_transactions_external_id_index"
                   )

    drop_if_exists index(:bank_members, ["user_id"], name: "bank_members_user_id_index")

    alter table(:bank_members) do
      remove :user_id
    end

    drop_if_exists index(:bank_accounts, ["user_id"], name: "bank_accounts_user_id_index")

    drop_if_exists index(:bank_accounts, ["bank_member_id"],
                     name: "bank_accounts_bank_member_id_index"
                   )

    alter table(:bank_accounts) do
      remove :user_id
    end

    drop_if_exists unique_index(:bank_accounts, [:external_id, :user_id],
                     name: "bank_accounts_external_id_index"
                   )

    drop constraint("users", "users_pkey")

    alter table(:users) do
      modify :uuid, :uuid, null: false, primary_key: true

      remove :id
    end
  end

  def down do
    drop constraint("users", "users_pkey")

    create unique_index(:bank_accounts, [:external_id, :user_id],
             name: "bank_accounts_external_id_index"
           )

    # alter table(:bank_accounts) do
    # This is the `down` migration of the statement:
    #
    #     remove :user_id
    #
    #
    # add :user_id, references(:users, column: :id, name: "bank_accounts_user_id_fkey", type: :bigint, prefix: "public"), null: false
    # end
    #
    create index(:bank_accounts, ["bank_member_id"])

    create index(:bank_accounts, ["user_id"])

    # alter table(:bank_members) do
    # This is the `down` migration of the statement:
    #
    #     remove :user_id
    #
    #
    # add :user_id, references(:users, column: :id, name: "bank_members_user_id_fkey", type: :bigint, prefix: "public"), null: false
    # end
    #
    create index(:bank_members, ["user_id"])

    create unique_index(:bank_transactions, [:bank_account_id, :external_id],
             name: "bank_transactions_external_id_index"
           )

    # alter table(:bank_transactions) do
    # This is the `down` migration of the statement:
    #
    #     remove :user_id
    #
    #
    # add :user_id, references(:users, column: :id, name: "bank_transactions_user_id_fkey", type: :bigint, prefix: "public"), null: false
    # end
    #
    create index(:bank_transactions, ["bank_account_id"])

    create index(:bank_transactions, ["user_id"])

    # alter table(:budget_allocation_template_lines) do
    # This is the `down` migration of the statement:
    #
    #     remove :user_id
    #
    #
    # add :user_id, references(:users, column: :id, name: "budget_allocation_template_lines_user_id_fkey", type: :bigint, prefix: "public"), null: false
    # end
    #
    create index(:budget_allocation_template_lines, ["budget_id"])

    create index(:budget_allocation_template_lines, ["budget_allocation_template_id"])

    create index(:budget_allocation_template_lines, ["user_id"])

    # alter table(:budget_allocation_templates) do
    # This is the `down` migration of the statement:
    #
    #     remove :user_id
    #
    #
    # add :user_id, references(:users, column: :id, name: "budget_allocation_templates_user_id_fkey", type: :bigint, prefix: "public"), null: false
    # end
    #
    create index(:budget_allocation_templates, ["user_id"])

    # alter table(:budget_allocations) do
    # This is the `down` migration of the statement:
    #
    #     remove :user_id
    #
    #
    # add :user_id, references(:users, column: :id, name: "budget_allocations_user_id_fkey", type: :bigint, prefix: "public"), null: false
    # end
    #
    create index(:budget_allocations, ["budget_id"])

    create index(:budget_allocations, ["transaction_id"])

    create index(:budget_allocations, ["user_id"])

    # alter table(:budgets) do
    # This is the `down` migration of the statement:
    #
    #     remove :user_id
    #
    #
    # add :user_id, references(:users, column: :id, name: "budgets_user_id_fkey", type: :bigint, prefix: "public"), null: false
    # end
    #
    create index(:budgets, ["user_id"])

    # alter table(:transactions) do
    # This is the `down` migration of the statement:
    #
    #     remove :user_id
    #
    #
    # add :user_id, references(:users, column: :id, name: "transactions_user_id_fkey", type: :bigint, prefix: "public"), null: false
    # end
    #
    create index(:transactions, ["bank_transaction_id"])

    create index(:transactions, ["user_id"])

    create unique_index(:users, [:uuid], name: "users_uuid_index")

    alter table(:users) do
      # This is the `down` migration of the statement:
      #
      #     remove :id
      #

      # add :id, :bigserial, null: false, primary_key: true
      modify :uuid, :uuid, null: true, primary_key: false
    end
  end
end

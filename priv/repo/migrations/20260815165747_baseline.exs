defmodule Spendable.Repo.Migrations.Baseline do
  use Ecto.Migration

  def change() do
    execute "CREATE EXTENSION IF NOT EXISTS citext", "DROP EXTENSION IF EXISTS citext"

    create table(:users) do
      add :bank_limit, :integer, null: false, default: 0
      add :external_id, :text, null: false
      add :image, :text
      add :provider, :text, null: false

      timestamps()
    end

    create unique_index(:users, [:external_id])

    create table(:budgets) do
      add :name, :citext, null: false
      add :adjustment, :decimal, null: false, default: 0.00
      add :budgeted_amount, :decimal
      add :type, :text, null: false, default: "envelope"
      add :archived_at, :utc_datetime_usec
      add :user_id, references(:users), null: false

      timestamps()
    end

    create index(:budgets, [:user_id])

    create table(:bank_members) do
      add :external_id, :text, null: false
      add :institution_id, :text
      add :logo, :text
      add :name, :citext, null: false
      add :provider, :text, null: false
      add :status, :text
      add :plaid_token, :text, null: false
      add :user_id, references(:users), null: false

      timestamps()
    end

    create unique_index(:bank_members, [:external_id])
    create index(:bank_members, [:user_id])

    create table(:bank_accounts) do
      add :external_id, :text, null: false
      add :balance, :decimal, null: false
      add :name, :text, null: false
      add :number, :text
      add :sub_type, :text, null: false
      add :type, :text, null: false
      add :sync, :boolean, null: false, default: true
      add :user_id, references(:users), null: false
      add :bank_member_id, references(:bank_members), null: false
      add :budget_id, references(:budgets)

      timestamps()
    end

    create unique_index(:bank_accounts, [:user_id, :external_id])
    create index(:bank_accounts, [:bank_member_id])

    create table(:bank_transactions) do
      add :external_id, :text, null: false
      add :amount, :decimal, precision: 17, scale: 2, null: false
      add :date, :date, null: false
      add :name, :text, null: false
      add :pending, :boolean, null: false
      add :user_id, references(:users), null: false
      add :bank_account_id, references(:bank_accounts), null: false

      timestamps()
    end

    create unique_index(:bank_transactions, [:external_id, :bank_account_id])
    create index(:bank_transactions, [:bank_account_id])
    create index(:bank_transactions, [:user_id])

    create table(:transactions) do
      add :amount, :decimal, null: false
      add :date, :date, null: false
      add :name, :citext, null: false
      add :note, :citext
      add :reviewed, :boolean, null: false, default: false
      add :excluded, :boolean, null: false, default: false
      add :user_id, references(:users), null: false
      add :bank_transaction_id, references(:bank_transactions)

      timestamps()
    end

    create index(:transactions, [:bank_transaction_id])
    create index(:transactions, [:user_id])

    create table(:budget_allocations) do
      add :amount, :decimal, precision: 17, scale: 2, null: false
      add :user_id, references(:users), null: false
      add :budget_id, references(:budgets), null: false
      add :transaction_id, references(:transactions, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:budget_allocations, [:budget_id])
    create index(:budget_allocations, [:transaction_id])
    create index(:budget_allocations, [:user_id])

    create table(:budget_allocation_templates) do
      add :name, :text, null: false
      add :archived_at, :utc_datetime_usec
      add :user_id, references(:users), null: false

      timestamps()
    end

    create index(:budget_allocation_templates, [:user_id])

    create table(:budget_allocation_template_lines) do
      add :amount, :decimal, precision: 17, scale: 2, null: false
      add :user_id, references(:users), null: false
      add :budget_id, references(:budgets), null: false

      add :budget_allocation_template_id,
          references(:budget_allocation_templates, on_delete: :delete_all),
          null: false

      timestamps()
    end

    create index(:budget_allocation_template_lines, [:budget_allocation_template_id])
    create index(:budget_allocation_template_lines, [:budget_id])
    create index(:budget_allocation_template_lines, [:user_id])
  end
end

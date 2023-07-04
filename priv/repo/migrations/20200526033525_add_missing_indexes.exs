defmodule Spendable.Repo.Migrations.AddMissingIndexes do
  use Ecto.Migration

  def change() do
    create index(:bank_accounts, [:bank_member_id])
    create index(:bank_transactions, [:user_id])
    create index(:bank_transactions, [:category_id])
    create index(:budget_allocation_template_lines, [:budget_id])
    create index(:budget_allocation_template_lines, [:budget_allocation_template_id])
    create index(:budget_allocation_templates, [:user_id])
    create index(:budget_allocations, [:transaction_id])
    create index(:budget_allocations, [:budget_id])
    create index(:budgets, [:user_id])
    create index(:transactions, [:user_id])
    create index(:transactions, [:bank_transaction_id])
    create index(:transactions, [:category_id])
  end
end

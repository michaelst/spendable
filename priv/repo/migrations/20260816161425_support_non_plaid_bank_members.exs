defmodule Spendable.Repo.Migrations.SupportNonPlaidBankMembers do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    alter table(:bank_members) do
      modify :plaid_token, :text, null: true, from: {:text, null: false}
      add :history_token, :text
    end

    # External ids are only unique within the provider that issued them, so the index that made
    # them unique across every user has to go. Added first, so uniqueness is never unenforced.
    create unique_index(:bank_members, [:user_id, :external_id], concurrently: true)
    drop unique_index(:bank_members, [:external_id], concurrently: true)
  end
end

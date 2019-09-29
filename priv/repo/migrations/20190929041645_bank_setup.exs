defmodule Budget.Repo.Migrations.BankSetup do
  use Ecto.Migration

  def change do
    create table(:bank_members) do
      add(:external_id, :string)
      add(:user_id, references(:users), null: false)
      add(:institution_id, :string)
      add(:logo, :string)
      add(:name, :string, null: false)
      add(:provider, :string)
      add(:status, :string)
      add(:plaid_token, :string)
    end

    create table(:bank_accounts) do
      add(:external_id, :string)
      add(:user_id, references(:users), null: false)
      add(:bank_member_id, references(:bank_members), null: false)
      add(:sub_type, :string)
      add(:type, :string)
      add(:available_balance, :decimal, precision: 19, scale: 4)
      add(:balance, :decimal, precision: 19, scale: 4)
      add(:name, :string, null: false)
      add(:number, :string)
    end

    create table(:categories) do
      add(:external_id, :string)
      add(:name, :string)
      add(:parent_id, references(:categories))
    end

    create table(:bank_tranasactions) do
      add(:external_id, :string)
      add(:user_id, references(:users), null: false)
      add(:bank_account_id, references(:bank_accounts), null: false)
      add(:category_id, references(:categories))
      add(:amount, :decimal, precision: 19, scale: 4)
      add(:date, :date)
      add(:location, :json)
      add(:name, :string)
      add(:pending, :boolean)
    end

    create table(:tranasactions) do
      add(:user_id, references(:users), null: false)
      add(:bank_account_id, references(:bank_accounts), null: false)
      add(:bank_transaction_id, references(:bank_tranasactions))
      add(:category_id, references(:categories))
      add(:amount, :decimal, precision: 19, scale: 4)
      add(:date, :date)
      add(:name, :string)
    end
  end
end

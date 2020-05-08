defmodule Spendable.Repo.Migrations.Tags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:name, :text, null: false)
      timestamps()
    end

    create(unique_index(:tags, [:user_id, :name]))

    create table(:transaction_tags, primary_key: false) do
      add(:transaction_id, references(:transactions, on_delete: :delete_all), null: false)
      add(:tag_id, references(:tags, on_delete: :delete_all), null: false)
    end

    create(unique_index(:transaction_tags, [:transaction_id, :tag_id]))
  end
end

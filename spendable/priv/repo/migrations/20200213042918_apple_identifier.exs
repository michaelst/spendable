defmodule Spendable.Repo.Migrations.AppleIdentifier do
  use Ecto.Migration

  def change() do
    alter table(:users) do
      add(:apple_identifier, :string)
      modify(:email, :citext, null: true)
      modify(:password, :string, null: true)
    end

    create(unique_index(:users, [:apple_identifier]))
  end
end

defmodule Spendable.Repo.Migrations.FirebaseAuth do
  use Ecto.Migration

  def change() do
    alter table(:users) do
      add :firebase_id, :text
      remove :email
      remove :password
    end

    create(unique_index(:users, [:firebase_id]))
  end
end

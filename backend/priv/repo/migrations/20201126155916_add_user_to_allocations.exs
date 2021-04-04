defmodule Spendable.Repo.Migrations.AddUserToAllocations do
  use Ecto.Migration

  def change() do
    alter table(:budget_allocations) do
      add :user_id, references(:users), null: false
    end
  end
end

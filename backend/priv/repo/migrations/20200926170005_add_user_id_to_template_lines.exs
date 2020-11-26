defmodule Spendable.Repo.Migrations.AddUserIdToTemplateLines do
  use Ecto.Migration

  def change do
    alter table(:budget_allocation_template_lines) do
      add :user_id, references(:users), null: false
    end
  end
end

defmodule Spendable.Repo.Migrations.NotificationSettings do
  use Ecto.Migration

  def change do
    create table(:notification_settings) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:device_token, :text, null: false)
      add(:enabled, :boolean, default: false)
      timestamps()
    end

    create(unique_index(:notification_settings, [:user_id, :device_token]))
  end
end

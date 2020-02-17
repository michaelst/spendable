defmodule Spendable.Repo.Migrations.NotificationDeviceTokens do
  use Ecto.Migration

  def change do
    create table(:notifications__device_tokens) do
      add(:user_id, references(:users), null: false)
      add(:device_token, :text, null: false)
      add(:enabled, :boolean, default: false)
      timestamps()
    end

    create(unique_index(:notifications__device_tokens, [:user_id, :device_token]))
  end
end

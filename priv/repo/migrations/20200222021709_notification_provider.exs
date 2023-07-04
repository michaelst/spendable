defmodule Spendable.Repo.Migrations.NotificationProvider do
  use Ecto.Migration

  def change() do
    alter table(:notification_settings) do
      add(:provider, :text, default: "apns", null: false)
    end
  end
end

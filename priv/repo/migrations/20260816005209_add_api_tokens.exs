defmodule Spendable.Repo.Migrations.AddApiTokens do
  use Ecto.Migration

  def change() do
    create table(:api_tokens) do
      add :token_hash, :text, null: false
      add :device_name, :text
      add :apns_token, :text
      add :last_used_at, :utc_datetime_usec, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :user_id, references(:users), null: false

      timestamps()
    end

    create unique_index(:api_tokens, [:token_hash])
    create index(:api_tokens, [:user_id])
  end
end

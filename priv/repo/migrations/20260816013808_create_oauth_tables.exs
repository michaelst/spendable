defmodule Spendable.Repo.Migrations.CreateOauthTables do
  use Ecto.Migration

  def change do
    create table(:oauth_clients) do
      add :client_name, :text, null: false
      add :redirect_uris, {:array, :text}, null: false, default: []
      add :grant_types, {:array, :text}, null: false, default: []
      add :response_types, {:array, :text}, null: false, default: []
      add :token_endpoint_auth_method, :text, null: false, default: "none"
      add :scope, :text, null: false, default: "mcp"
      add :secret_selector, :binary
      add :secret_verify_hash, :binary

      timestamps()
    end

    create unique_index(:oauth_clients, [:secret_selector])

    create table(:oauth_authorization_codes) do
      add :user_id, references(:users), null: false
      add :client_id, references(:oauth_clients), null: false
      add :selector, :binary, null: false
      add :verify_hash, :binary, null: false
      add :redirect_uri, :text, null: false
      add :scope, :text, null: false
      add :code_challenge, :text, null: false
      add :code_challenge_method, :text, null: false
      add :resource, :text, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :used_at, :utc_datetime_usec

      timestamps()
    end

    create unique_index(:oauth_authorization_codes, [:selector])
    create index(:oauth_authorization_codes, [:user_id])
    create index(:oauth_authorization_codes, [:client_id])

    create table(:oauth_refresh_tokens) do
      add :user_id, references(:users), null: false
      add :client_id, references(:oauth_clients), null: false
      add :family_id, :text, null: false
      add :selector, :binary, null: false
      add :verify_hash, :binary, null: false
      add :scope, :text, null: false
      add :resource, :text, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :revoked_at, :utc_datetime_usec
      add :replaced_by_id, :text

      timestamps()
    end

    create unique_index(:oauth_refresh_tokens, [:selector])
    create index(:oauth_refresh_tokens, [:user_id, :client_id])
    create index(:oauth_refresh_tokens, [:family_id])

    create table(:oauth_access_tokens) do
      add :user_id, references(:users), null: false
      add :client_id, references(:oauth_clients), null: false
      add :refresh_token_id, references(:oauth_refresh_tokens)
      add :family_id, :text, null: false
      add :selector, :binary, null: false
      add :verify_hash, :binary, null: false
      add :scope, :text, null: false
      add :resource, :text, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :revoked_at, :utc_datetime_usec

      timestamps()
    end

    create unique_index(:oauth_access_tokens, [:selector])
    create index(:oauth_access_tokens, [:user_id, :client_id])
    create index(:oauth_access_tokens, [:family_id])
  end
end

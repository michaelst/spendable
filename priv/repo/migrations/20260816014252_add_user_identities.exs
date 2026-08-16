defmodule Spendable.Repo.Migrations.AddUserIdentities do
  use Ecto.Migration

  @doc """
  A user can sign in with more than one provider, so the provider's subject moves off the user and
  onto its own row. Nothing identifies the person across providers - a second one is attached by
  hand from inside the account.
  """
  def up() do
    create table(:user_identities) do
      add :provider, :text, null: false
      add :external_id, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:user_identities, [:provider, :external_id])
    create index(:user_identities, [:user_id])

    flush()

    backfill_identities()

    alter table(:users) do
      remove :provider
      remove :external_id
    end
  end

  def down() do
    alter table(:users) do
      add :provider, :text
      add :external_id, :text
    end

    flush()

    execute """
    UPDATE users SET provider = identity.provider, external_id = identity.external_id
    FROM user_identities AS identity WHERE identity.user_id = users.id
    """

    drop table(:user_identities)
  end

  defp backfill_identities() do
    %{rows: rows} =
      repo().query!("SELECT id, provider, external_id, inserted_at, updated_at FROM users")

    Enum.each(rows, fn [user_id, provider, external_id, inserted_at, updated_at] ->
      repo().query!(
        """
        INSERT INTO user_identities (id, provider, external_id, user_id, inserted_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6)
        """,
        [UXID.generate!(prefix: "usi"), provider, external_id, user_id, inserted_at, updated_at]
      )
    end)
  end
end

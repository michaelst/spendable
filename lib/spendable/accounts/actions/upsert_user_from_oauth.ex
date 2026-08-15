defmodule Spendable.Accounts.Actions.UpsertUserFromOauth do
  @moduledoc false

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Repo

  @doc """
  The OAuth subject is the account, so a returning user is matched on external_id.
  Only the provider's own fields are refreshed - bank_limit is ours to set, not theirs.
  """
  def upsert_user_from_oauth(attrs) do
    attrs
    |> User.changeset()
    |> Repo.insert(
      on_conflict: {:replace, [:provider, :image, :updated_at]},
      conflict_target: :external_id,
      returning: true
    )
  end
end

defmodule Spendable.Accounts do
  @moduledoc false

  alias Spendable.Accounts.Actions

  defdelegate get_user(id), to: Actions.GetUser
  defdelegate upsert_user_from_oauth(attrs), to: Actions.UpsertUserFromOauth
end

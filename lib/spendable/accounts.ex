defmodule Spendable.Accounts do
  @moduledoc false

  alias Spendable.Accounts.Actions

  defdelegate authenticate_api_token(token), to: Actions.AuthenticateApiToken
  defdelegate create_api_token(scope, attrs), to: Actions.CreateApiToken
  defdelegate get_identity(scope, id), to: Actions.GetIdentity
  defdelegate get_user(id), to: Actions.GetUser
  defdelegate link_identity(scope, provider, id_token), to: Actions.LinkIdentity
  defdelegate list_identities(scope), to: Actions.ListIdentities
  defdelegate revoke_api_token(scope, api_token), to: Actions.RevokeApiToken
  defdelegate sign_in_with_oauth(provider, id_token), to: Actions.SignInWithOauth
  defdelegate unlink_identity(scope, identity), to: Actions.UnlinkIdentity
  defdelegate upsert_user_from_oauth(attrs), to: Actions.UpsertUserFromOauth
end

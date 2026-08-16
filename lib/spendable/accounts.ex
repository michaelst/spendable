defmodule Spendable.Accounts do
  @moduledoc false

  alias Spendable.Accounts.Actions

  defdelegate authenticate_api_token(token), to: Actions.AuthenticateApiToken
  defdelegate create_api_token(scope, attrs), to: Actions.CreateApiToken
  defdelegate get_user(id), to: Actions.GetUser
  defdelegate revoke_api_token(scope, api_token), to: Actions.RevokeApiToken
  defdelegate sign_in_with_apple(id_token), to: Actions.SignInWithApple
  defdelegate sign_in_with_google(id_token), to: Actions.SignInWithGoogle
  defdelegate upsert_user_from_oauth(attrs), to: Actions.UpsertUserFromOauth
end

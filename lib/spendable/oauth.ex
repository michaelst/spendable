defmodule Spendable.OAuth do
  @moduledoc false

  alias Spendable.OAuth.Actions

  defdelegate build_error_redirect(request, error), to: Actions.BuildErrorRedirect
  defdelegate create_authorization_code(scope, request), to: Actions.CreateAuthorizationCode
  defdelegate exchange_authorization_code(params), to: Actions.ExchangeAuthorizationCode
  defdelegate exchange_refresh_token(params), to: Actions.ExchangeRefreshToken
  defdelegate get_client(client_id), to: Actions.GetClient
  defdelegate list_authorizations(scope), to: Actions.ListAuthorizations
  defdelegate register_client(params), to: Actions.RegisterClient
  defdelegate revoke_authorization(scope, client_id), to: Actions.RevokeAuthorization
  defdelegate validate_authorization_request(params), to: Actions.ValidateAuthorizationRequest
  defdelegate verify_access_token(token, resource), to: Actions.VerifyAccessToken
end

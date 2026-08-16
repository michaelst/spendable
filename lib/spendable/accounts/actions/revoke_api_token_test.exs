defmodule Spendable.Accounts.Actions.RevokeApiTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "revokes a token", %{scope: scope} do
    {:ok, api_token} = Accounts.create_api_token(scope, %{})

    assert {:ok, %ApiToken{}} = Accounts.revoke_api_token(scope, api_token)
  end

  test "a revoked token no longer authenticates", %{scope: scope} do
    {:ok, api_token} = Accounts.create_api_token(scope, %{})
    {:ok, _revoked} = Accounts.revoke_api_token(scope, api_token)

    assert {:error, :invalid_token} = Accounts.authenticate_api_token(api_token.token)
  end

  test "errors if the token belongs to a different user", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, api_token} = Accounts.create_api_token(Scope.for_user(other_user), %{})

    assert {:error, :not_authorized} = Accounts.revoke_api_token(scope, api_token)
  end

  test "revoking one token leaves the user's others working", %{scope: scope} do
    {:ok, phone} = Accounts.create_api_token(scope, %{"device_name" => "iPhone"})
    {:ok, tablet} = Accounts.create_api_token(scope, %{"device_name" => "iPad"})
    {:ok, _revoked} = Accounts.revoke_api_token(scope, phone)

    assert {:ok, %ApiToken{device_name: "iPad"}} = Accounts.authenticate_api_token(tablet.token)
  end
end

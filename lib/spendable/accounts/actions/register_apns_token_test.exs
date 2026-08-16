defmodule Spendable.Accounts.Actions.RegisterApnsTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Scope

  @device_token String.duplicate("ab", 32)

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, api_token} = Accounts.create_api_token(scope, %{})

    %{api_token: api_token, scope: scope}
  end

  test "records the device token", %{api_token: api_token, scope: scope} do
    assert is_nil(api_token.apns_token)

    assert {:ok, %ApiToken{apns_token: @device_token}} =
             Accounts.register_apns_token(scope, api_token, @device_token)
  end

  test "replaces the token a device registered before", %{api_token: api_token, scope: scope} do
    {:ok, api_token} = Accounts.register_apns_token(scope, api_token, @device_token)

    reissued = String.duplicate("cd", 32)

    assert {:ok, %ApiToken{apns_token: ^reissued}} =
             Accounts.register_apns_token(scope, api_token, reissued)
  end

  test "rejects a token that is not a device token", %{api_token: api_token, scope: scope} do
    not_hex = String.duplicate("xy", 32)

    assert {:error, changeset} = Accounts.register_apns_token(scope, api_token, not_hex)

    assert %{apns_token: ["has invalid format"]} = errors_on(changeset)
  end

  test "rejects a token that is too short", %{api_token: api_token, scope: scope} do
    assert {:error, changeset} = Accounts.register_apns_token(scope, api_token, "abcd")

    assert %{apns_token: ["should be at least 64 character(s)"]} = errors_on(changeset)
  end

  test "refuses another user's token", %{api_token: api_token} do
    {:ok, other} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Accounts.register_apns_token(Scope.for_user(other), api_token, @device_token)
  end
end

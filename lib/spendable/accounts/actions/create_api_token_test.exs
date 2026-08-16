defmodule Spendable.Accounts.Actions.CreateApiTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Accounts.Schemas.User
  alias Spendable.Scope

  setup do
    {:ok, %User{id: user_id} = user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user), user_id: user_id}
  end

  test "creates a token for the scope's user", %{scope: scope, user_id: user_id} do
    assert {:ok, %ApiToken{device_name: "iPhone", user_id: ^user_id}} =
             Accounts.create_api_token(scope, %{"device_name" => "iPhone"})
  end

  test "returns the raw token once and stores only its hash", %{scope: scope} do
    {:ok, api_token} = Accounts.create_api_token(scope, %{})

    assert byte_size(api_token.token) == 43
    assert api_token.token_hash == ApiToken.hash(api_token.token)
    refute api_token.token_hash == api_token.token
  end

  test "the returned token authenticates", %{scope: scope} do
    {:ok, %ApiToken{id: id} = api_token} = Accounts.create_api_token(scope, %{})

    assert {:ok, %ApiToken{id: ^id}} = Accounts.authenticate_api_token(api_token.token)
  end

  test "rejects a device name too long to show in a list", %{scope: scope} do
    {:error, changeset} =
      Accounts.create_api_token(scope, %{"device_name" => String.duplicate("a", 101)})

    assert %{device_name: ["should be at most 100 character(s)"]} = errors_on(changeset)
  end

  test "each token is different", %{scope: scope} do
    {:ok, first} = Accounts.create_api_token(scope, %{})
    {:ok, second} = Accounts.create_api_token(scope, %{})

    refute first.token == second.token
  end

  test "expires ninety days out", %{scope: scope} do
    {:ok, api_token} = Accounts.create_api_token(scope, %{})

    assert DateTime.diff(api_token.expires_at, DateTime.utc_now(), :day) == 89
  end
end

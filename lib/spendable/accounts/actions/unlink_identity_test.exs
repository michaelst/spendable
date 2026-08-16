defmodule Spendable.Accounts.Actions.UnlinkIdentityTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.UserIdentity
  alias Spendable.Scope
  alias Spendable.TestData

  setup do
    stub(TeslaMock, :call, fn
      %{url: "https://www.googleapis.com/oauth2/v3/certs"}, _opts ->
        TeslaHelper.response(body: TestData.Google.certs())

      %{url: "https://appleid.apple.com/auth/keys"}, _opts ->
        TeslaHelper.response(body: TestData.Apple.certs())
    end)

    {:ok, %{id: user_id} = user} =
      Accounts.sign_in_with_oauth("google", TestData.Google.id_token())

    scope = Scope.for_user(user)

    {:ok, %{id: apple_id} = apple} =
      Accounts.link_identity(scope, "apple", TestData.Apple.id_token())

    %{scope: scope, apple: apple, apple_id: apple_id, user_id: user_id}
  end

  test "removes a way of signing in", %{scope: scope, apple: apple} do
    assert {:ok, %UserIdentity{}} = Accounts.unlink_identity(scope, apple)
    assert ["google"] = Enum.map(Accounts.list_identities(scope), & &1.provider)
  end

  test "the removed provider signs into a new account rather than the old one", %{
    scope: scope,
    apple: apple,
    user_id: user_id
  } do
    {:ok, _removed} = Accounts.unlink_identity(scope, apple)

    {:ok, %{id: new_id}} = Accounts.sign_in_with_oauth("apple", TestData.Apple.id_token())

    refute new_id == user_id
  end

  # An account with no identity is an account nobody can get back into.
  test "refuses to remove the last one", %{scope: scope, apple: apple} do
    {:ok, _removed} = Accounts.unlink_identity(scope, apple)
    [google] = Accounts.list_identities(scope)

    assert {:error, :last_identity} = Accounts.unlink_identity(scope, google)
  end

  test "errors if the identity belongs to a different user", %{apple: apple} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Accounts.unlink_identity(Scope.for_user(other_user), apple)
  end

  test "gets an identity by id", %{scope: scope, apple_id: apple_id} do
    assert {:ok, %UserIdentity{id: ^apple_id}} = Accounts.get_identity(scope, apple_id)
  end

  test "errors when no identity has that id", %{scope: scope} do
    assert {:error, :identity_not_found} = Accounts.get_identity(scope, "usi_nope")
  end

  test "another user's identity is not found", %{apple: apple} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :identity_not_found} =
             Accounts.get_identity(Scope.for_user(other_user), apple.id)
  end
end

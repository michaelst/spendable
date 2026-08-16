defmodule Spendable.Accounts.Actions.LinkIdentityTest do
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

    %{scope: Scope.for_user(user), user_id: user_id}
  end

  test "attaches a second provider to the account", %{scope: scope} do
    assert {:ok, %UserIdentity{provider: "apple"}} =
             Accounts.link_identity(scope, "apple", TestData.Apple.id_token())
  end

  test "the linked provider then signs into that same account", %{
    scope: scope,
    user_id: user_id
  } do
    {:ok, _linked} = Accounts.link_identity(scope, "apple", TestData.Apple.id_token())

    assert {:ok, %{id: ^user_id}} =
             Accounts.sign_in_with_oauth("apple", TestData.Apple.id_token())
  end

  test "both ways of signing in are listed afterwards", %{scope: scope} do
    {:ok, _linked} = Accounts.link_identity(scope, "apple", TestData.Apple.id_token())

    assert ["google", "apple"] = Enum.map(Accounts.list_identities(scope), & &1.provider)
  end

  test "linking the same provider twice is refused", %{scope: scope} do
    assert {:error, :identity_already_linked} =
             Accounts.link_identity(scope, "google", TestData.Google.id_token())
  end

  # Otherwise anyone holding a valid token for a provider could join themselves to the account
  # that token already belongs to.
  test "a provider already on another account is refused", %{scope: scope} do
    {:ok, _theirs} = Accounts.sign_in_with_oauth("apple", TestData.Apple.id_token())

    assert {:error, :identity_claimed} =
             Accounts.link_identity(scope, "apple", TestData.Apple.id_token())
  end

  test "an unverifiable token links nothing", %{scope: scope} do
    token = TestData.Apple.id_token(%{"aud" => "com.someone.else"})

    assert {:error, :invalid_id_token} = Accounts.link_identity(scope, "apple", token)
    assert [%UserIdentity{provider: "google"}] = Accounts.list_identities(scope)
  end
end

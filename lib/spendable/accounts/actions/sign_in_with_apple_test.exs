defmodule Spendable.Accounts.Actions.SignInWithAppleTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User
  alias Spendable.TestData

  setup do
    stub(TeslaMock, :call, fn %{url: "https://appleid.apple.com/auth/keys"}, _opts ->
      TeslaHelper.response(body: TestData.Apple.certs())
    end)

    :ok
  end

  test "creates a user on first sign-in" do
    assert {:ok, %User{email: "michael@dishbooks.com", image: nil}} =
             Accounts.sign_in_with_apple(TestData.Apple.id_token())
  end

  test "returns the existing user on a later sign-in" do
    {:ok, %User{id: id}} = Accounts.sign_in_with_apple(TestData.Apple.id_token())

    assert {:ok, %User{id: ^id}} = Accounts.sign_in_with_apple(TestData.Apple.id_token())
  end

  test "lands on the account a Google sign-in already made for that email" do
    stub(TeslaMock, :call, fn
      %{url: "https://appleid.apple.com/auth/keys"}, _opts ->
        TeslaHelper.response(body: TestData.Apple.certs())

      %{url: "https://www.googleapis.com/oauth2/v3/certs"}, _opts ->
        TeslaHelper.response(body: TestData.Google.certs())
    end)

    {:ok, %User{id: id}} = Accounts.sign_in_with_google(TestData.Google.id_token())

    assert {:ok, %User{id: ^id}} = Accounts.sign_in_with_apple(TestData.Apple.id_token())
  end

  # A user who chose Hide My Email arrives under a relay address, which cannot match the one their
  # Google sign-in recorded, so the two accounts stay separate.
  test "a hidden email does not link to the account behind the real one" do
    stub(TeslaMock, :call, fn
      %{url: "https://appleid.apple.com/auth/keys"}, _opts ->
        TeslaHelper.response(body: TestData.Apple.certs())

      %{url: "https://www.googleapis.com/oauth2/v3/certs"}, _opts ->
        TeslaHelper.response(body: TestData.Google.certs())
    end)

    {:ok, %User{id: id}} = Accounts.sign_in_with_google(TestData.Google.id_token())

    token = TestData.Apple.id_token(%{"email" => "abc123@privaterelay.appleid.com"})

    {:ok, %User{id: hidden_id}} = Accounts.sign_in_with_apple(token)

    refute hidden_id == id
  end

  test "rejects a token for another application" do
    token = TestData.Apple.id_token(%{"aud" => "com.someone.else"})

    assert {:error, :invalid_id_token} = Accounts.sign_in_with_apple(token)
  end

  test "rejects a token from another issuer" do
    token = TestData.Apple.id_token(%{"iss" => "https://accounts.google.com"})

    assert {:error, :invalid_id_token} = Accounts.sign_in_with_apple(token)
  end

  test "rejects an expired token" do
    expired = DateTime.utc_now() |> DateTime.add(-1, :hour) |> DateTime.to_unix()

    assert {:error, :invalid_id_token} =
             Accounts.sign_in_with_apple(TestData.Apple.id_token(%{"exp" => expired}))
  end

  test "rejects a value that is not a token" do
    assert {:error, :invalid_id_token} = Accounts.sign_in_with_apple(nil)
  end
end

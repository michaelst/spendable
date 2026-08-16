defmodule Spendable.Accounts.Actions.SignInWithOauthTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User
  alias Spendable.TestData

  setup do
    stub(TeslaMock, :call, fn
      %{url: "https://www.googleapis.com/oauth2/v3/certs"}, _opts ->
        TeslaHelper.response(body: TestData.Google.certs())

      %{url: "https://appleid.apple.com/auth/keys"}, _opts ->
        TeslaHelper.response(body: TestData.Apple.certs())
    end)

    :ok
  end

  test "creates a user on a first Google sign-in" do
    assert {:ok, %User{image: "https://lh3.googleusercontent.com/a/photo"}} =
             Accounts.sign_in_with_oauth("google", TestData.Google.id_token())
  end

  test "creates a user on a first Apple sign-in" do
    assert {:ok, %User{image: nil}} =
             Accounts.sign_in_with_oauth("apple", TestData.Apple.id_token())
  end

  test "returns the existing user on a later sign-in" do
    {:ok, %User{id: id}} = Accounts.sign_in_with_oauth("google", TestData.Google.id_token())

    assert {:ok, %User{id: ^id}} =
             Accounts.sign_in_with_oauth("google", TestData.Google.id_token())
  end

  test "lands on the account the browser already made" do
    {:ok, %User{id: id}} =
      Accounts.upsert_user_from_oauth(%{
        external_id: "104829376510394827561",
        provider: "google"
      })

    assert {:ok, %User{id: ^id}} =
             Accounts.sign_in_with_oauth("google", TestData.Google.id_token())
  end

  # Nothing is stored that identifies a person across providers, so the two cannot be matched up
  # on their own. Linking is a deliberate act from inside an account.
  test "the same person signing in with a second provider gets a second account" do
    {:ok, %User{id: id}} = Accounts.sign_in_with_oauth("google", TestData.Google.id_token())

    {:ok, %User{id: apple_id}} =
      Accounts.sign_in_with_oauth("apple", TestData.Apple.id_token())

    refute apple_id == id
  end

  test "rejects a token signed by a key the provider does not publish" do
    assert {:error, :invalid_id_token} =
             Accounts.sign_in_with_oauth("google", TestData.Google.id_token_from_unknown_key())
  end

  test "rejects a token for another application" do
    token = TestData.Google.id_token(%{"aud" => "someone-else.apps.googleusercontent.com"})

    assert {:error, :invalid_id_token} = Accounts.sign_in_with_oauth("google", token)
  end

  test "rejects a token minted by the wrong provider" do
    token = TestData.Apple.id_token()

    assert {:error, :invalid_id_token} = Accounts.sign_in_with_oauth("google", token)
  end

  test "rejects an expired token" do
    expired = DateTime.utc_now() |> DateTime.add(-1, :hour) |> DateTime.to_unix()

    assert {:error, :invalid_id_token} =
             Accounts.sign_in_with_oauth("apple", TestData.Apple.id_token(%{"exp" => expired}))
  end

  test "rejects a token missing its subject" do
    token = TestData.Google.id_token(%{"sub" => nil})

    assert {:error, :invalid_id_token} = Accounts.sign_in_with_oauth("google", token)
  end

  test "rejects a provider the app does not support" do
    assert {:error, :invalid_id_token} =
             Accounts.sign_in_with_oauth("myspace", TestData.Google.id_token())
  end

  test "rejects a value that is not a token" do
    assert {:error, :invalid_id_token} = Accounts.sign_in_with_oauth("google", nil)
  end

  # A provider answering with anything but a key set is a refused sign-in, not a crashed request.
  test "rejects a sign-in when the key set cannot be read" do
    stub(TeslaMock, :call, fn %{url: "https://www.googleapis.com/oauth2/v3/certs"}, _opts ->
      TeslaHelper.response(status: 503, body: %{"error" => "unavailable"})
    end)

    assert {:error, :invalid_id_token} =
             Accounts.sign_in_with_oauth("google", TestData.Google.id_token())
  end
end

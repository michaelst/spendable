defmodule Spendable.Accounts.Actions.SignInWithGoogleTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User
  alias Spendable.TestData

  setup do
    stub(TeslaMock, :call, fn %{url: "https://www.googleapis.com/oauth2/v3/certs"}, _opts ->
      TeslaHelper.response(body: TestData.Google.certs())
    end)

    :ok
  end

  test "creates a user on first sign-in" do
    assert {:ok, %User{email: "michael@dishbooks.com"}} =
             Accounts.sign_in_with_google(TestData.Google.id_token())
  end

  test "returns the existing user on a later sign-in" do
    {:ok, %User{id: id}} = Accounts.sign_in_with_google(TestData.Google.id_token())

    assert {:ok, %User{id: ^id}} = Accounts.sign_in_with_google(TestData.Google.id_token())
  end

  test "lands on the account the browser already made" do
    {:ok, %User{id: id}} =
      Accounts.upsert_user_from_oauth(%{
        external_id: "104829376510394827561",
        provider: "google"
      })

    assert {:ok, %User{id: ^id}} = Accounts.sign_in_with_google(TestData.Google.id_token())
  end

  test "refreshes the picture Google sends" do
    assert {:ok, %User{image: "https://lh3.googleusercontent.com/a/photo"}} =
             Accounts.sign_in_with_google(TestData.Google.id_token())
  end

  test "rejects a token signed by a key Google does not publish" do
    assert {:error, :invalid_id_token} =
             Accounts.sign_in_with_google(TestData.Google.id_token_from_unknown_key())
  end

  test "rejects a token for another application" do
    token = TestData.Google.id_token(%{"aud" => "someone-else.apps.googleusercontent.com"})

    assert {:error, :invalid_id_token} = Accounts.sign_in_with_google(token)
  end

  test "rejects a token from another issuer" do
    token = TestData.Google.id_token(%{"iss" => "https://evil.example.com"})

    assert {:error, :invalid_id_token} = Accounts.sign_in_with_google(token)
  end

  test "rejects an expired token" do
    expired = DateTime.utc_now() |> DateTime.add(-1, :hour) |> DateTime.to_unix()

    assert {:error, :invalid_id_token} =
             Accounts.sign_in_with_google(TestData.Google.id_token(%{"exp" => expired}))
  end

  test "rejects a token missing its subject" do
    token = TestData.Google.id_token(%{"sub" => nil})

    assert {:error, :invalid_id_token} = Accounts.sign_in_with_google(token)
  end

  # Google answering with anything but a key set is a refused sign-in, not a crashed request.
  test "rejects a sign-in when the key set cannot be read" do
    stub(TeslaMock, :call, fn %{url: "https://www.googleapis.com/oauth2/v3/certs"}, _opts ->
      TeslaHelper.response(status: 503, body: %{"error" => "unavailable"})
    end)

    assert {:error, :invalid_id_token} =
             Accounts.sign_in_with_google(TestData.Google.id_token())
  end

  test "rejects a value that is not a token" do
    assert {:error, :invalid_id_token} = Accounts.sign_in_with_google(nil)
    assert {:error, :invalid_id_token} = Accounts.sign_in_with_google("not-a-jwt")
  end
end

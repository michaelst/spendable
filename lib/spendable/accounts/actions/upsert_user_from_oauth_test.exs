defmodule Spendable.Accounts.Actions.UpsertUserFromOauthTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User

  test "creates a user with a prefixed id" do
    assert {:ok, %User{id: "usr_" <> _uxid, bank_limit: 0}} =
             Accounts.upsert_user_from_oauth(%{
               external_id: Ecto.UUID.generate(),
               provider: "google"
             })
  end

  test "refreshes the profile of a returning user rather than creating a second one" do
    external_id = Ecto.UUID.generate()

    {:ok, %{id: user_id}} =
      Accounts.upsert_user_from_oauth(%{
        external_id: external_id,
        provider: "google",
        image: "https://example.com/old.png"
      })

    assert {:ok, %User{id: ^user_id, image: "https://example.com/new.png"}} =
             Accounts.upsert_user_from_oauth(%{
               external_id: external_id,
               provider: "google",
               image: "https://example.com/new.png"
             })
  end

  test "leaves bank_limit alone when a user signs in again" do
    external_id = Ecto.UUID.generate()

    {:ok, _user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: external_id,
        provider: "google",
        bank_limit: 5
      })

    assert {:ok, %User{bank_limit: 5}} =
             Accounts.upsert_user_from_oauth(%{external_id: external_id, provider: "google"})
  end

  test "a second provider with the same email signs into the same account" do
    {:ok, %{id: user_id}} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        email: "michael@dishbooks.com"
      })

    assert {:ok, %User{id: ^user_id}} =
             Accounts.upsert_user_from_oauth(%{
               external_id: Ecto.UUID.generate(),
               provider: "apple",
               email: "michael@dishbooks.com"
             })
  end

  test "a second provider with a different email gets its own account" do
    {:ok, %{id: user_id}} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google",
        email: "michael@dishbooks.com"
      })

    {:ok, %User{id: other_id}} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "apple",
        email: "relay@privaterelay.appleid.com"
      })

    refute other_id == user_id
  end

  test "a sign-in with no email gets its own account" do
    {:ok, %{id: user_id}} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, %User{id: other_id}} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "apple"})

    refute other_id == user_id
  end

  # Apple sends the email on the first authorization and can leave it out later.
  test "a provider that omits the email does not erase the one on record" do
    external_id = Ecto.UUID.generate()

    {:ok, _first} =
      Accounts.upsert_user_from_oauth(%{
        external_id: external_id,
        provider: "apple",
        email: "michael@dishbooks.com"
      })

    assert {:ok, %User{email: "michael@dishbooks.com"}} =
             Accounts.upsert_user_from_oauth(%{external_id: external_id, provider: "apple"})
  end

  test "the same subject from two providers is two identities" do
    {:ok, %{id: user_id}} =
      Accounts.upsert_user_from_oauth(%{external_id: "shared-subject", provider: "google"})

    {:ok, %User{id: other_id}} =
      Accounts.upsert_user_from_oauth(%{external_id: "shared-subject", provider: "apple"})

    refute other_id == user_id
  end

  # Provider and subject come from our own code, never from user input, so a missing one is a bug.
  test "crashes without a provider and subject" do
    assert_raise FunctionClauseError, fn ->
      Accounts.upsert_user_from_oauth(%{provider: "google"})
    end
  end
end

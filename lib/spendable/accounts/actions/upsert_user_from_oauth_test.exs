defmodule Spendable.Accounts.Actions.UpsertUserFromOauthTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User

  test "creates a user with a prefixed id" do
    external_id = Ecto.UUID.generate()

    assert {:ok, %User{id: "usr_" <> _uxid, provider: "google", bank_limit: 0}} =
             Accounts.upsert_user_from_oauth(%{external_id: external_id, provider: "google"})
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

  test "errors without an external_id" do
    assert {:error, changeset} = Accounts.upsert_user_from_oauth(%{provider: "google"})

    assert %{external_id: ["can't be blank"]} = errors_on(changeset)
  end

  test "errors without a provider" do
    assert {:error, changeset} =
             Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate()})

    assert %{provider: ["can't be blank"]} = errors_on(changeset)
  end
end

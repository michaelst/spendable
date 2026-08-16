defmodule Spendable.Accounts.Actions.GetUserTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.User

  test "returns the user" do
    {:ok, %{id: user_id}} =
      Accounts.upsert_user_from_oauth(%{
        external_id: Ecto.UUID.generate(),
        provider: "google"
      })

    assert {:ok, %User{id: ^user_id}} = Accounts.get_user(user_id)
  end

  test "errors when no user has that id" do
    assert {:error, :user_not_found} = Accounts.get_user("usr_01M036GTQ48JXS0A2AXFNV6H5P")
  end

  # The id comes off the session, so a request carrying a stale or hand-edited one must not crash.
  test "errors when the id is not a string" do
    assert {:error, :user_not_found} = Accounts.get_user(nil)
  end
end

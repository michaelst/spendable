defmodule Spendable.ScopeTest do
  use ExUnit.Case, async: true

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Scope

  test "wraps a user" do
    user = %User{id: "usr_01M036GTQ48JXS0A2AXFNV6H5P"}

    assert %Scope{user: ^user, system: false} = Scope.for_user(user)
  end

  # The session may name no user at all, and a caller has to be able to tell that apart from a scope.
  test "returns nil without a user" do
    assert is_nil(Scope.for_user(nil))
  end

  test "marks a system scope while keeping the owner" do
    user = %User{id: "usr_01M036GTQ48JXS0A2AXFNV6H5P"}

    assert %Scope{user: ^user, system: true} = Scope.for_system(user)
  end
end

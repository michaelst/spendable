defmodule Spendable.Auth.GuardianTest do
  use Spendable.DataCase, async: true

  alias Spendable.Auth.Guardian

  describe "resource_from_claims" do
    test "look up existing user" do
      %{firebase_id: firebase_id} = Factory.insert(Spendable.User)

      assert {:ok, %Spendable.User{bank_limit: 10, firebase_id: ^firebase_id}} =
               Guardian.resource_from_claims(%{"sub" => firebase_id})
    end

    test "create user if not found" do
      assert {:ok, %Spendable.User{bank_limit: 0, firebase_id: "new"}} =
               Guardian.resource_from_claims(%{"sub" => "new"})
    end
  end
end

defmodule Spendable.User.Resolver.CurrentUserTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "current user" do
    user = Spendable.TestUtils.create_user()

    insert(:bank_account, user: user, balance: 100)
    budget = insert(:budget, user: user)
    insert(:allocation, user: user, budget: budget, amount: -25.55)
    budget = insert(:budget, user: user, adjustment: "0.01")
    insert(:allocation, user: user, budget: budget, amount: 10)

    query = """
      query {
        currentUser {
          bankLimit
          spendable
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "currentUser" => %{
                  "bankLimit" => 10,
                  "spendable" => "64.44"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end

  test "new current user" do
    user = Spendable.TestUtils.create_user()

    query = """
      query {
        currentUser {
          bankLimit
          spendable
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "currentUser" => %{
                  "bankLimit" => 10,
                  "spendable" => "0.00"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end

  test "plaid link token" do
    token = "link-sandbox-961de9b2-d8f3-43ac-9e9d-c108a555a6ae"

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://sandbox.plaid.com/link/token/create"} ->
        %Tesla.Env{status: 200, body: %{"link_token" => token}}
    end)

    user = Spendable.TestUtils.create_user()

    doc = """
      query {
        currentUser {
          plaidLinkToken
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "currentUser" => %{
                  "plaidLinkToken" => token
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{current_user: user})
  end
end

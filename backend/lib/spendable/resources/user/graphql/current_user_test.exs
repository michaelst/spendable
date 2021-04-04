defmodule Spendable.User.Resolver.CurrentUserTest do
  use Spendable.DataCase, async: true

  test "current user" do
    user = Spendable.TestUtils.create_user()

    query = """
      query {
        currentUser {
          bankLimit
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "currentUser" => %{
                  "bankLimit" => 10
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "unauthenticated" do
    doc = """
      query {
        currentUser {
          plaidLinkToken
        }
      }
    """

    assert {:ok,
            %{
              data: %{"currentUser" => nil},
              errors: [
                %{
                  locations: [%{column: 5, line: 2}],
                  message: "\n\n* \": Read action requires actor\"",
                  path: ["currentUser"]
                }
              ]
            }} == Absinthe.run(doc, Spendable.Web.Schema)
  end
end

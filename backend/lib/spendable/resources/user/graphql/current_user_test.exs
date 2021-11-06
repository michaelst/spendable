defmodule Spendable.User.Resolver.CurrentUserTest do
  use Spendable.DataCase, async: true

  test "current user" do
    user = insert(:user)

    query = """
      query {
        currentUser {
          bankLimit
          spentByMonth {
            month
            spent
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "currentUser" => %{
                  "bankLimit" => 10,
                  "spentByMonth" => [
                    %{
                      "month" => Calendar.strftime(Date.utc_today(), "%b %Y"),
                      "spent" => "0"
                    }
                  ]
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
              data: nil,
              errors: [
                %{locations: [%{column: 5, line: 2}], message: "Forbidden", path: ["currentUser"], code: "forbidden"}
              ]
            }} == Absinthe.run(doc, Spendable.Web.Schema)
  end
end

defmodule Spendable.User.Resolver.CurrentUserTest do
  use Spendable.DataCase, async: true

  test "current user" do
    user = Factory.insert(Spendable.User)

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
                      "month" => Date.utc_today() |> Timex.beginning_of_month() |> to_string(),
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

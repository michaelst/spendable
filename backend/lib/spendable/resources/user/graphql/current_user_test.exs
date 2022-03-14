defmodule Spendable.User.Resolver.CurrentUserTest do
  use Spendable.DataCase, async: true

  test "current user" do
    user = Factory.insert(Spendable.User)

    query = """
      query {
        currentUser {
          id
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
                  "id" => "#{user.id}",
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
end

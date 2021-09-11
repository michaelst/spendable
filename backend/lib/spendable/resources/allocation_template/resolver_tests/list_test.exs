defmodule Spendable.Budgets.AllocationTemplate.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true

  test "update" do
    user = insert(:user)

    template1 = insert(:allocation_template, user_id: user.id)
    template2 = insert(:allocation_template, user_id: user.id)

    query = """
      query {
        allocationTemplates {
          name
          lines {
            amount
            budget {
              name
            }
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "allocationTemplates" => [
                  %{
                    "lines" => [
                      %{
                        "amount" => "#{template1.lines |> List.first() |> Map.get(:amount)}",
                        "budget" => %{"name" => "Food"}
                      },
                      %{
                        "amount" => "#{template1.lines |> List.last() |> Map.get(:amount)}",
                        "budget" => %{"name" => "Food"}
                      }
                    ],
                    "name" => "Payday"
                  },
                  %{
                    "lines" => [
                      %{
                        "amount" => "#{template2.lines |> List.first() |> Map.get(:amount)}",
                        "budget" => %{"name" => "Food"}
                      },
                      %{
                        "amount" => "#{template2.lines |> List.last() |> Map.get(:amount)}",
                        "budget" => %{"name" => "Food"}
                      }
                    ],
                    "name" => "Payday"
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

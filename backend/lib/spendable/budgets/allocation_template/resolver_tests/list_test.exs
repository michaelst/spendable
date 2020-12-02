defmodule Spendable.Budgets.AllocationTemplate.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update" do
    user = Spendable.TestUtils.create_user()

    template1 = insert(:allocation_template, user: user)
    template2 = insert(:allocation_template, user: user)

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

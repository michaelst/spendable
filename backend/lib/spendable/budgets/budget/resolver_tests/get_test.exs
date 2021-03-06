defmodule Spendable.Budgets.Budget.Resolver.GetTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update" do
    user = Spendable.TestUtils.create_user()

    budget = insert(:budget, user: user)
    deposit = insert(:allocation, user: user, budget: budget, amount: 100)
    expense = insert(:allocation, user: user, budget: budget, amount: -25.55)

    %{lines: [line]} =
      insert(:allocation_template,
        user: user,
        lines: [
          build(:allocation_template_line, user: user, budget: budget)
        ]
      )

    query = """
    query {
      budget(id: "#{budget.id}") {
        id
        name
        balance
        goal
        recentAllocations {
          id
          amount
          transaction {
            name
            date
            bankTransaction {
              pending
            }
          }
        }
        allocationTemplateLines {
          id
          amount
          allocationTemplate {
            name
          }
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "budget" => %{
                  "id" => "#{budget.id}",
                  "name" => "Food",
                  "balance" => "#{Decimal.new("74.45")}",
                  "goal" => nil,
                  "allocationTemplateLines" => [
                    %{
                      "amount" => "#{line.amount}",
                      "id" => "#{line.id}",
                      "allocationTemplate" => %{"name" => "Payday"}
                    }
                  ],
                  "recentAllocations" => [
                    %{
                      "amount" => "100.00",
                      "id" => "#{deposit.id}",
                      "transaction" => %{
                        "name" => "test",
                        "bankTransaction" => nil,
                        "date" => "#{Date.utc_today()}"
                      }
                    },
                    %{
                      "amount" => "-25.55",
                      "id" => "#{expense.id}",
                      "transaction" => %{
                        "name" => "test",
                        "bankTransaction" => nil,
                        "date" => "#{Date.utc_today()}"
                      }
                    }
                  ]
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

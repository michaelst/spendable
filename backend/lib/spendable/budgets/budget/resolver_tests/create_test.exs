defmodule Spendable.Budgets.Budget.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true

  test "create budget" do
    user = Spendable.TestUtils.create_user()

    query = """
      mutation {
        createBudget(name: "test budget", balance: "0.05") {
          name
          balance
          goal
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "createBudget" => %{
                  "name" => "test budget",
                  "balance" => "0.05",
                  "goal" => nil
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end

  test "create goal" do
    user = Spendable.TestUtils.create_user()

    query = """
      mutation {
        createBudget(name: "test budget", goal: "1000.25") {
          name
          balance
          goal
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "createBudget" => %{
                  "name" => "test budget",
                  "balance" => "0.00",
                  "goal" => "1000.25"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

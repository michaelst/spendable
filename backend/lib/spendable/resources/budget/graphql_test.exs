defmodule Spendable.Budget.GraphQLTests do
  use Spendable.DataCase, async: true

  test "get budget" do
    user = insert(:user)

    budget = insert(:budget, user_id: user.id)
    insert(:budget_allocation, user_id: user.id, budget_id: budget.id, amount: 100)
    insert(:budget_allocation, user_id: user.id, budget_id: budget.id, amount: -25.55)

    query = """
    query {
      budget(id: "#{budget.id}") {
        id
        name
        balance
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "budget" => %{
                  "id" => "#{budget.id}",
                  "name" => "Food",
                  "balance" => "#{Decimal.new("74.45")}"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "list budgets" do
    user = insert(:user)

    budget = insert(:budget, user_id: user.id)
    insert(:budget_allocation, user_id: user.id, budget_id: budget.id, amount: 100)
    insert(:budget_allocation, user_id: user.id, budget_id: budget.id, amount: -25.55)

    query = """
      query {
        budgets {
          id
          name
          balance
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "budgets" => [
                  %{
                    "id" => "#{budget.id}",
                    "name" => "Food",
                    "balance" => "#{Decimal.new("74.45")}"
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "create budget" do
    user = insert(:user)

    query = """
      mutation {
        createBudget(input: { name: "test budget", adjustment: "0.05" }) {
          result {
            name
            balance
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "createBudget" => %{
                  "result" => %{
                    "name" => "test budget",
                    "balance" => "0.05"
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  test "update budget" do
    user = insert(:user)

    budget = insert(:budget, user_id: user.id)
    insert(:allocation, user_id: user.id, budget_id: budget.id, amount: 10)

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, name: "new name") {
          id
          name
          balance
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "id" => "#{budget.id}",
                  "name" => "new name",
                  "balance" => "10.00"
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, name: "new name", balance: "10.05") {
          id
          name
          balance
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "id" => "#{budget.id}",
                  "name" => "new name",
                  "balance" => "10.05"
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})

    assert Repo.get(Spendable.Budgets.Budget, budget.id).adjustment |> Decimal.eq?("0.05")

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, name: "new name", balance: "0.00") {
          id
          name
          balance
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "id" => "#{budget.id}",
                  "name" => "new name",
                  "balance" => "0.00"
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})

    assert Repo.get(Spendable.Budgets.Budget, budget.id).adjustment |> Decimal.eq?("-10.00")
  end

  test "update budget balance with no allocations" do
    user = insert(:user)

    budget = insert(:budget, user: user)

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, balance: "10.00") {
          id
          balance
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "id" => "#{budget.id}",
                  "balance" => "10.00"
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})

    assert Repo.get(Spendable.Budgets.Budget, budget.id).adjustment |> Decimal.eq?("10.00")
  end

  test "delete budget" do
    user = insert(:user)

    budget = insert(:budget, user: user)

    query = """
    mutation {
      deleteBudget(id: #{budget.id}) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "deleteBudget" => %{
                  "id" => "#{budget.id}"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end
end

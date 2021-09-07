defmodule Spendable.Budgets.Budget.Resolver.UpdateTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory

  alias Spendable.Repo

  test "update budget" do
    user = insert(:user)

    budget = insert(:budget, user: user)
    insert(:allocation, user: user, budget: budget, amount: 10)

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, name: "new name") {
          id
          name
          balance
          goal
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "id" => "#{budget.id}",
                  "name" => "new name",
                  "balance" => "10.00",
                  "goal" => nil
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{current_user: user})

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, name: "new name", balance: "10.05") {
          id
          name
          balance
          goal
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "id" => "#{budget.id}",
                  "name" => "new name",
                  "balance" => "10.05",
                  "goal" => nil
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{current_user: user})

    assert Repo.get(Spendable.Budgets.Budget, budget.id).adjustment |> Decimal.eq?("0.05")

    doc = """
      mutation {
        updateBudget(id: #{budget.id}, name: "new name", balance: "0.00") {
          id
          name
          balance
          goal
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBudget" => %{
                  "id" => "#{budget.id}",
                  "name" => "new name",
                  "balance" => "0.00",
                  "goal" => nil
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{current_user: user})

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
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{current_user: user})

    assert Repo.get(Spendable.Budgets.Budget, budget.id).adjustment |> Decimal.eq?("10.00")
  end
end

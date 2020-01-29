defmodule Spendable.Budgets.Budget.Resolver.AllocateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Repo
  alias Spendable.Budgets.Budget

  test "allocate budget", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget1 = insert(:budget, user_id: user.id)
    budget2 = insert(:budget, user_id: user.id)

    query = """
      mutation {
        allocate (allocations: [{amount: "10", budgetId: "#{budget1.id}"}, {amount: "10", budgetId: "#{budget2.id}"}])
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "allocate" => 2
             }
           } == response

    assert Repo.get(Budget, budget1.id).allocated == Decimal.add(budget1.allocated, Decimal.new("10"))
    assert Repo.get(Budget, budget2.id).allocated == Decimal.add(budget2.allocated, Decimal.new("10"))
  end

  test "can't allocate budget that doesn't exist", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    budget = insert(:budget, user_id: user.id)

    query = """
      mutation {
        allocate (allocations: [{amount: "10", budgetId: "#{budget.id}"}, {amount: "10", budgetId: "999999999"}])
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{"allocate" => nil},
             "errors" => [
               %{
                 "locations" => [%{"column" => 5, "line" => 2}],
                 "message" => "update failed",
                 "path" => ["allocate"]
               }
             ]
           } == response

    assert Repo.get(Budget, budget.id).allocated == budget.allocated
  end

  test "can't allocate budget user doesn't own", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    {other_user, _token} = Spendable.TestUtils.create_user()

    budget = insert(:budget, user_id: user.id)
    other_budget = insert(:budget, user_id: other_user.id)

    query = """
      mutation {
        allocate (allocations: [{amount: "10", budgetId: "#{budget.id}"}, {amount: "10", budgetId: "#{other_budget.id}"}])
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{"allocate" => nil},
             "errors" => [
               %{
                 "locations" => [%{"column" => 5, "line" => 2}],
                 "message" => "update failed",
                 "path" => ["allocate"]
               }
             ]
           } == response

    assert Repo.get(Budget, budget.id).allocated == budget.allocated
    assert Repo.get(Budget, other_budget.id).allocated == other_budget.allocated
  end
end

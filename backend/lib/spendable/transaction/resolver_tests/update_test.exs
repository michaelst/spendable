defmodule Spendable.Transaction.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Banks.Category
  alias Spendable.Repo

  test "update transaction", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    category_id = Repo.get_by!(Category, external_id: "22006001").id
    budget = insert(:budget, user: user)
    transaction = insert(:transaction, user: user)
    allocation = insert(:allocation, transaction: transaction, budget: budget, amount: 25.24)

    query = """
      mutation {
        updateTransaction(
          id: #{transaction.id}
          name: "new name"
          categoryId: "#{category_id}"
          allocations: [
            {
              id: #{allocation.id}
              amount: "26.25"
              budgetId: "#{budget.id}"
            }
            {
              amount: "100"
              budgetId: "#{budget.id}"
            }
          ]
        ) {
          id
          name
          category {
            id
          }
          allocations {
            amount
            budget {
              id
            }
          }
        }
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "updateTransaction" => %{
                 "id" => "#{transaction.id}",
                 "name" => "new name",
                 "category" => %{
                   "id" => "#{category_id}"
                 },
                 "allocations" => [
                   %{
                     "amount" => "26.25",
                     "budget" => %{
                       "id" => "#{budget.id}"
                     }
                   },
                   %{
                     "amount" => "100.00",
                     "budget" => %{
                       "id" => "#{budget.id}"
                     }
                   }
                 ]
               }
             }
           } == response
  end

  test "update tags", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    transaction = insert(:transaction, user: user)
    tag_one = insert(:tag, user: user, name: "First tag")
    tag_two = insert(:tag, user: user, name: "Second tag")

    query = """
      mutation {
        updateTransaction(
          id: #{transaction.id}
          tagIds: ["#{tag_one.id}", "#{tag_two.id}"]
        ) {
          tags {
            id
            name
          }
        }
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "updateTransaction" => %{
                 "tags" => [
                   %{"id" => "#{tag_one.id}", "name" => "First tag"},
                   %{"id" => "#{tag_two.id}", "name" => "Second tag"}
                 ]
               }
             }
           } == response

    query = """
      mutation {
        updateTransaction(
          id: #{transaction.id}
          tagIds: []
        ) {
          tags {
            id
            name
          }
        }
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "updateTransaction" => %{
                 "tags" => []
               }
             }
           } == response
  end
end

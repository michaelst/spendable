defmodule Spendable.Transaction.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Transaction
  alias Spendable.Banks.Category
  alias Spendable.Repo

  test "update", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    category_id = Repo.get_by!(Category, external_id: "22006001").id

    transaction =
      %Transaction{}
      |> Transaction.changeset(%{
        user_id: user.id,
        amount: 10.01,
        name: "test",
        note: "some notes",
        date: Date.utc_today(),
        category_id: category_id
      })
      |> Repo.insert!()

    query = """
      query {
        transactions {
          id
          name
          note
          amount
          date
          category {
              id
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
               "transactions" => [
                 %{
                   "amount" => "#{transaction.amount}",
                   "category" => %{"id" => "#{category_id}"},
                   "date" => "#{transaction.date}",
                   "id" => "#{transaction.id}",
                   "name" => "test",
                   "note" => "some notes"
                 }
               ]
             }
           } == response
  end
end

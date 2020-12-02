defmodule Spendable.Transaction.Resolver.GetTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  alias Spendable.Banks.Category
  alias Spendable.Repo

  test "get transaction" do
    user = Spendable.TestUtils.create_user()
    category_id = Repo.get_by!(Category, external_id: "22006001").id

    transaction = insert(:transaction, user: user, category_id: category_id)

    query = """
    query {
      transaction(id: #{transaction.id}) {
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

    assert {:ok,
            %{
              data: %{
                "transaction" => %{
                  "amount" => "#{transaction.amount}",
                  "category" => %{"id" => "#{category_id}"},
                  "date" => "#{transaction.date}",
                  "id" => "#{transaction.id}",
                  "name" => "test",
                  "note" => "some notes"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

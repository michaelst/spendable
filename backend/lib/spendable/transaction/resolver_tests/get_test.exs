defmodule Spendable.Transaction.Resolver.GetTest do
  use Spendable.Web.ConnCase, async: true

  test "get transaction" do
    user = insert(:user)

    transaction = insert(:transaction, user: user)

    query = """
    query {
      transaction(id: #{transaction.id}) {
        id
        name
        note
        amount
        date
        reviewed
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "transaction" => %{
                  "amount" => "#{transaction.amount}",
                  "date" => "#{transaction.date}",
                  "id" => "#{transaction.id}",
                  "name" => "test",
                  "note" => "some notes",
                  "reviewed" => false
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

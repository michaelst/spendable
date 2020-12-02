defmodule Spendable.Transaction.Resolver.DeleteTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "delete transaction" do
    user = Spendable.TestUtils.create_user()

    transaction = insert(:transaction, user: user)

    query = """
    mutation {
      deleteTransaction(id: #{transaction.id}) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "deleteTransaction" => %{
                  "id" => "#{transaction.id}"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

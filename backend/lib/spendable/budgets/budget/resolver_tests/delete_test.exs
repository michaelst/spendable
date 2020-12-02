defmodule Spendable.Budgets.Budget.Resolver.DeleteTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "delete budget" do
    user = Spendable.TestUtils.create_user()

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
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

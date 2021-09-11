defmodule Spendable.Budgets.Budget.Resolver.DeleteTest do
  use Spendable.Web.ConnCase, async: true

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
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

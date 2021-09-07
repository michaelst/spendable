defmodule Spendable.Budgets.AllocationTemplate.Resolver.DeleteTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "delete budget" do
    user = insert(:user)

    template = insert(:allocation_template, user: user)

    query = """
    mutation {
      deleteAllocationTemplate(id: #{template.id}) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "deleteAllocationTemplate" => %{
                  "id" => "#{template.id}"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

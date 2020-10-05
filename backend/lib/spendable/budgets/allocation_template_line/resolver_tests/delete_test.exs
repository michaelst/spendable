defmodule Spendable.Budgets.AllocationTemplateLine.Resolver.DeleteTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory

  alias Spendable.Budgets.AllocationTemplateLine
  alias Spendable.Repo

  test "delete budget" do
    {user, _token} = Spendable.TestUtils.create_user()

    line = insert(:allocation_template, user: user) |> Map.get(:lines) |> List.first()

    query = """
    mutation {
      deleteAllocationTemplateLine(id: #{line.id}) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "deleteAllocationTemplateLine" => %{"id" => "#{line.id}"}
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})

    refute Repo.get(AllocationTemplateLine, line.id)
  end
end

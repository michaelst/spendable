defmodule Spendable.Budgets.Allocation.Resolver.DeleteTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory

  alias Spendable.Budgets.Allocation
  alias Spendable.Repo

  test "delete allocation" do
    user = insert(:user)

    %{id: id} = insert(:allocation, user: user)

    query = """
    mutation {
      deleteAllocation(id: #{id}) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "deleteAllocation" => %{"id" => "#{id}"}
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})

    refute Repo.get(Allocation, id)
  end
end

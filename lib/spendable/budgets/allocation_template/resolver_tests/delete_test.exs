defmodule Spendable.Budgets.AllocationTemplate.Resolver.DeleteTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "delete budget", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    template = insert(:allocation_template, user: user)

    query = """
      mutation {
        deleteAllocationTemplate(id: #{template.id}) {
          id
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
               "deleteAllocationTemplate" => %{
                 "id" => "#{template.id}"
               }
             }
           } == response
  end
end

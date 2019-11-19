defmodule Spendable.Banks.Category.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true

  test "update", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      query ListCategories{
        categories {
          id
          name
          parentName
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
               "categories" =>
                 [%{"id" => "589", "name" => "Accessories Store", "parentName" => "Outlet / Shops"} | _] = categories
             }
           } = response

    assert 602 == length(categories)
  end
end

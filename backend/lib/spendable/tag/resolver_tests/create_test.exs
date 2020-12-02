defmodule Spendable.Tag.Resolver.CreateTest do
  use Spendable.Web.ConnCase, async: true

  test "create tag" do
    user = Spendable.TestUtils.create_user()

    query = """
      mutation {
        createTag(name: "new tag") {
          name
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "createTag" => %{
                  "name" => "new tag"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

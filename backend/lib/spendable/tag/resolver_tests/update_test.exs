defmodule Spendable.Tag.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "update tag" do
    user = Spendable.TestUtils.create_user()
    tag = insert(:tag, user: user)

    query = """
      mutation {
        updateTag(id: #{tag.id} name: "new tag") {
          id
          name
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateTag" => %{
                  "id" => "#{tag.id}",
                  "name" => "new tag"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

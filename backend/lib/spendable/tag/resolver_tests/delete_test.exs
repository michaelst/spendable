defmodule Spendable.Tag.Resolver.DeleteTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "delete tag" do
    user = Spendable.TestUtils.create_user()

    tag = insert(:tag, user: user)

    query = """
    mutation {
      deleteTag(id: #{tag.id}) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "deleteTag" => %{
                  "id" => "#{tag.id}"
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

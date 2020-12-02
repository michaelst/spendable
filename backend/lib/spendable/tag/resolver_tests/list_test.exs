defmodule Spendable.Tag.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "list tags" do
    user = Spendable.TestUtils.create_user()
    tag_one = insert(:tag, user: user, name: "First tag")
    tag_two = insert(:tag, user: user, name: "Second tag")

    query = """
      query {
        tags {
          id
          name
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "tags" => [
                  %{
                    "id" => "#{tag_one.id}",
                    "name" => "First tag"
                  },
                  %{
                    "id" => "#{tag_two.id}",
                    "name" => "Second tag"
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

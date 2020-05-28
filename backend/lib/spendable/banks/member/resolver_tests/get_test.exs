defmodule Spendable.Banks.Member.Resolver.GetTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory

  test "get member" do
    {user, _token} = Spendable.TestUtils.create_user()
    member = insert(:bank_member, user: user)

    doc = """
    query {
      bankMember(id: "#{member.id}") {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "bankMember" => %{
                  "id" => "#{member.id}"
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{current_user: user})
  end
end

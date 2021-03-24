defmodule Spendable.Banks.Member.Resolver.GetTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory

  test "get member" do
    user = Spendable.TestUtils.create_user()
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

  test "plaid link token" do
    user = Spendable.TestUtils.create_user()
    %{plaid_token: access_token} = member = insert(:bank_member, user: user)
    token = "link-sandbox-961de9b2-d8f3-43ac-9e9d-c108a555a6ae"

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://sandbox.plaid.com/link/token/create", body: body} ->
        assert {:ok, %{"access_token" => ^access_token}} = Jason.decode(body)
        %Tesla.Env{status: 200, body: %{"link_token" => token}}
    end)

    doc = """
    query {
      bankMember(id: "#{member.id}") {
        plaidLinkToken
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "bankMember" => %{
                  "plaidLinkToken" => token
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{current_user: user})
  end
end

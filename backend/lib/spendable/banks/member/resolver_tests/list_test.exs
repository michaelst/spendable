defmodule Spendable.Banks.Member.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "list members", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()
    member = insert(:bank_member, user: user)
    checking_account = insert(:bank_account, user: user, bank_member: member, available_balance: 100, balance: 120)
    savings_account = insert(:bank_account, user: user, bank_member: member, available_balance: nil, balance: 500)

    credit_account = insert(:bank_account, user: user, bank_member: member, balance: 1025, type: "credit")

    query = """
      query {
        bankMembers {
        id
        name
        status
        bankAccounts {
          id
          name
          sync
          balance
        }
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
               "bankMembers" => [
                 %{
                   "bankAccounts" => [
                     %{"balance" => "-1025.00", "id" => "#{credit_account.id}", "name" => "Checking", "sync" => true},
                     %{"balance" => "500.00", "id" => "#{savings_account.id}", "name" => "Checking", "sync" => true},
                     %{"balance" => "100.00", "id" => "#{checking_account.id}", "name" => "Checking", "sync" => true}
                   ],
                   "id" => "#{member.id}",
                   "name" => "Plaid",
                   "status" => "Connected"
                 }
               ]
             }
           } == response
  end
end

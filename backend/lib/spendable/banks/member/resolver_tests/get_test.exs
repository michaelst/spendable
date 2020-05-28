defmodule Spendable.Banks.Member.Resolver.GetTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory

  test "get member" do
    {user, _token} = Spendable.TestUtils.create_user()
    member = insert(:bank_member, user: user)
    checking_account = insert(:bank_account, user: user, bank_member: member, available_balance: 100, balance: 120)
    savings_account = insert(:bank_account, user: user, bank_member: member, available_balance: nil, balance: 500)

    credit_account = insert(:bank_account, user: user, bank_member: member, balance: 1025, type: "credit")

    doc = """
    query {
      bankMember(id: "#{member.id}") {
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

    assert {:ok,
            %{
              data: %{
                "bankMember" => %{
                  "bankAccounts" => [
                    %{"balance" => "-1025.00", "id" => "#{credit_account.id}", "name" => "Checking", "sync" => true},
                    %{"balance" => "500.00", "id" => "#{savings_account.id}", "name" => "Checking", "sync" => true},
                    %{"balance" => "100.00", "id" => "#{checking_account.id}", "name" => "Checking", "sync" => true}
                  ],
                  "id" => "#{member.id}",
                  "name" => "Plaid",
                  "status" => "Connected"
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{current_user: user})
  end
end

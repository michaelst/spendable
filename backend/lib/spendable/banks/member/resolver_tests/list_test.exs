defmodule Spendable.Banks.Member.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true
  import Spendable.Factory

  test "list members" do
    user = Spendable.TestUtils.create_user()
    member = insert(:bank_member, user: user)

    checking_account =
      insert(:bank_account, user: user, bank_member: member, name: "Checking", available_balance: 100, balance: 120)

    savings_account =
      insert(:bank_account, user: user, bank_member: member, name: "Savings", available_balance: nil, balance: 500)

    credit_account =
      insert(:bank_account, user: user, bank_member: member, name: "Credit Card", balance: 1025, type: "credit")

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

    assert {:ok,
            %{
              data: %{
                "bankMembers" => [
                  %{
                    "bankAccounts" => [
                      %{"balance" => "100.00", "id" => "#{checking_account.id}", "name" => "Checking", "sync" => true},
                      %{
                        "balance" => "-1025.00",
                        "id" => "#{credit_account.id}",
                        "name" => "Credit Card",
                        "sync" => true
                      },
                      %{"balance" => "500.00", "id" => "#{savings_account.id}", "name" => "Savings", "sync" => true}
                    ],
                    "id" => "#{member.id}",
                    "name" => "Plaid",
                    "status" => "Connected"
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

defmodule Spendable.BanksAccount.GraphQLTests do
  use Spendable.Web.ConnCase, async: true

  test "get bank account" do
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)
    bank_member = Factory.insert(Spendable.BankMember, user_id: user.id)
    bank_account = Factory.insert(Spendable.BankAccount, user_id: user.id, bank_member_id: bank_member.id)

    doc = """
    query {
      bankAccount(id: "#{bank_account.id}") {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "bankAccount" => %{
                  "id" => "#{bank_account.id}"
                }
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})

    assert {:ok,
            %{
              data: nil,
              errors: [
                %{
                  code: "not_found",
                  fields: [:id],
                  locations: [%{column: 3, line: 2}],
                  message: "could not be found",
                  path: ["bankAccount"],
                  short_message: "could not be found",
                  vars: []
                }
              ]
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: other_user})
  end

  test "list bank accounts" do
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)
    bank_member = Factory.insert(Spendable.BankMember, user_id: user.id)

    bank_account_1 =
      Factory.insert(Spendable.BankAccount, user_id: user.id, bank_member_id: bank_member.id, name: "Checking")

    bank_account_2 =
      Factory.insert(Spendable.BankAccount, user_id: user.id, bank_member_id: bank_member.id, name: "Savings")

    Factory.insert(Spendable.BankAccount, user_id: other_user.id, bank_member_id: bank_member.id)

    doc = """
    query {
      bankAccounts(sort: [{ field: NAME }]) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "bankAccounts" => [
                  %{"id" => "#{bank_account_1.id}"},
                  %{"id" => "#{bank_account_2.id}"}
                ]
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})
  end

  test "update" do
    user = Factory.insert(Spendable.User)
    other_user = Factory.insert(Spendable.User)

    member = Factory.insert(Spendable.BankMember, user_id: user.id)
    account = Factory.insert(Spendable.BankAccount, user_id: user.id, bank_member_id: member.id, sync: false)

    query = """
      mutation {
        updateBankAccount(id: #{account.id}, input: {sync: true}) {
          result {
            id
            sync
          }
        }
      }
    """

    assert {:ok,
            %{
              data: %{
                "updateBankAccount" => %{
                  "result" => %{
                    "id" => "#{account.id}",
                    "sync" => true
                  }
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

    # can't update another user's bank account
    assert {
             :ok,
             %{
               data: %{"updateBankAccount" => nil},
               errors: [
                 %{
                   code: "not_found",
                   fields: [:id],
                   locations: [%{column: 5, line: 2}],
                   message: "could not be found",
                   path: ["updateBankAccount"],
                   short_message: "could not be found",
                   vars: []
                 }
               ]
             }
           } == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})
  end
end

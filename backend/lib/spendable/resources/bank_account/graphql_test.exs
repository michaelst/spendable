defmodule Spendable.BanksAccount.GraphQLTests do
  use Spendable.Web.ConnCase, async: true

  import Mock

  alias Google.PubSub
  alias Spendable.TestUtils

  setup_with_mocks([
    {
      PubSub,
      [],
      publish: fn data, _topic ->
        send(self(), data)
        {:ok, %{status: 200}}
      end
    }
  ]) do
    :ok
  end

  test "get bank account" do
    user = insert(:user)
    other_user = insert(:user)
    bank_member = insert(:bank_member, user_id: user.id)
    bank_account = insert(:bank_account, user_id: user.id, bank_member_id: bank_member.id)

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
              data: %{
                "bankAccount" => nil
              }
            }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: other_user})
  end

  test "list bank accounts" do
    user = insert(:user)
    other_user = insert(:user)
    bank_member = insert(:bank_member, user_id: user.id)
    bank_account_1 = insert(:bank_account, user_id: user.id, bank_member_id: bank_member.id)
    bank_account_2 = insert(:bank_account, user_id: user.id, bank_member_id: bank_member.id)
    insert(:bank_account, user_id: other_user.id, bank_member_id: bank_member.id)

    doc = """
    query {
      bankAccounts {
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
    user = insert(:user)
    other_user = insert(:user)

    member = insert(:bank_member, user_id: user.id)
    account = insert(:bank_account, user_id: user.id, bank_member_id: member.id, sync: false)

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

    TestUtils.assert_published(%SyncMemberRequest{member_id: member.id})

    # can't update another user's bank account
    assert {:ok,
            %{
              data: %{
                "updateBankAccount" => %{
                  "result" => nil
                }
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: other_user})
  end
end

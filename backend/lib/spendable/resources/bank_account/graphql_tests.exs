defmodule Spendable.BanksAccount.GraphQLTests do
  use Spendable.Web.ConnCase, async: false

  import Mock
  import Spendable.Factory

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

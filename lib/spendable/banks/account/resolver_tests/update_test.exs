defmodule Spendable.Banks.Account.Resolver.UpdateTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Banks.Member
  alias Spendable.Banks.Account
  alias Spendable.Repo

  test "update", %{conn: conn} do
    {user, token} = Spendable.TestUtils.create_user()

    member =
      %Member{}
      |> Member.changeset(%{
        external_id: Ecto.UUID.generate(),
        institution_id: "test_ins",
        logo: nil,
        name: "Capital One",
        provider: "Plaid",
        user_id: user.id,
        plaid_token: "test"
      })
      |> Repo.insert!()

    account =
      %Account{}
      |> Account.changeset(%{
        external_id: Ecto.UUID.generate(),
        bank_member_id: member.id,
        name: "Checking",
        type: "CHECKING",
        sub_type: "CHECKING",
        user_id: user.id,
        sync: false
      })
      |> Repo.insert!()

    query = """
      mutation {
        updateBankAccount(id: #{account.id}, sync: true) {
          id
          sync
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
               "updateBankAccount" => %{
                 "id" => "#{account.id}",
                 "sync" => true
               }
             }
           } == response

    Spendable.TestUtils.assert_job(Spendable.Jobs.Banks.SyncMember, [member.id])
  end
end

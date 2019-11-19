defmodule Spendable.Banks.Member.Resolver.ListTest do
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
      query {
        bankMembers {
          id
          name
          status
          bankAccounts {
            id
            name
            sync
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
                   "bankAccounts" => [%{"id" => "#{account.id}", "name" => "Checking", "sync" => false}],
                   "id" => "#{member.id}",
                   "name" => "Capital One",
                   "status" => nil
                 }
               ]
             }
           } == response
  end
end

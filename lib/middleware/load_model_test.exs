defmodule Spendable.Middleware.LoadModelTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Banks.Account
  alias Spendable.Banks.Member
  alias Spendable.Repo

  test "not found", %{conn: conn} do
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

    # wrong id
    query = """
      mutation {
        updateBankAccount(id: 999999, sync: true) {
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
             "data" => %{"updateBankAccount" => nil},
             "errors" => [
               %{
                 "locations" => [%{"column" => 5, "line" => 2}],
                 "message" => "not found",
                 "path" => ["updateBankAccount"]
               }
             ]
           } == response

    # wrong user
    {_other_user, other_token} = Spendable.TestUtils.create_user()

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
      |> put_req_header("authorization", "Bearer #{other_token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{"updateBankAccount" => nil},
             "errors" => [
               %{
                 "locations" => [%{"column" => 5, "line" => 2}],
                 "message" => "not found",
                 "path" => ["updateBankAccount"]
               }
             ]
           } == response

    # make sure it works when correct
    conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/graphql", %{query: query})
    |> json_response(200)
  end
end

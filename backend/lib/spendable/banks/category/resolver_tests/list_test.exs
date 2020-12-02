defmodule Spendable.Banks.Category.Resolver.ListTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Banks.Account
  alias Spendable.Banks.Member
  alias Spendable.Repo

  test "list categories" do
    user = Spendable.TestUtils.create_user()

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

    assert {:ok,
            %{
              data: %{
                "bankMembers" => [
                  %{
                    "bankAccounts" => [%{"id" => "#{account.id}", "name" => "Checking", "sync" => false}],
                    "id" => "#{member.id}",
                    "name" => "Capital One",
                    "status" => nil
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{current_user: user})
  end
end

defmodule Spendable.Middleware.LoadModelTest do
  use Spendable.Web.ConnCase, async: true

  alias Spendable.Banks.Account
  alias Spendable.Banks.Member
  alias Spendable.Repo

  defmodule Schema do
    use Absinthe.Schema

    object :bank_account do
      field :id, :id
    end

    query do
    end

    mutation do
      field :update_bank_account, :bank_account do
        middleware(Spendable.Middleware.LoadModel, module: Account)
        arg(:id, non_null(:id))
        arg(:sync, :boolean)
        resolve(fn _args, %{context: %{model: model}} -> {:ok, model} end)
      end
    end
  end

  test "successfully load model" do
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

    doc = """
    mutation {
      updateBankAccount(id: #{account.id}, sync: true) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "updateBankAccount" => %{
                  "id" => "#{account.id}"
                }
              }
            }} == Absinthe.run(doc, Schema, context: %{current_user: user})
  end

  test "model doesn't exist" do
    user = Spendable.TestUtils.create_user()

    doc = """
    mutation {
      updateBankAccount(id: 99999999, sync: true) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{"updateBankAccount" => nil},
              errors: [%{locations: [%{column: 3, line: 2}], message: "not found", path: ["updateBankAccount"]}]
            }} == Absinthe.run(doc, Schema, context: %{current_user: user})
  end

  test "wrong user" do
    user = Spendable.TestUtils.create_user()
    other_user = Spendable.TestUtils.create_user()

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

    doc = """
    mutation {
      updateBankAccount(id: #{account.id}, sync: true) {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{"updateBankAccount" => nil},
              errors: [%{locations: [%{column: 3, line: 2}], message: "not found", path: ["updateBankAccount"]}]
            }} == Absinthe.run(doc, Schema, context: %{current_user: other_user})
  end
end

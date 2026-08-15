defmodule Spendable.Banks.Actions.UpdateBankAccountTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Budgets
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: Ecto.UUID.generate(),
        name: "Plaid",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    {:ok, bank_account} =
      Repo.insert(%BankAccount{
        user_id: user.id,
        bank_member_id: bank_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Checking",
        balance: Decimal.new("100.00"),
        sub_type: "checking",
        type: "depository"
      })

    %{scope: Scope.for_user(user), bank_account: bank_account}
  end

  test "turns syncing off", %{scope: scope, bank_account: bank_account} do
    assert {:ok, %BankAccount{sync: false}} =
             Banks.update_bank_account(scope, bank_account, %{"sync" => false})
  end

  test "assigns a budget", %{scope: scope, bank_account: bank_account} do
    {:ok, %{id: budget_id}} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    assert {:ok, %BankAccount{budget_id: ^budget_id}} =
             Banks.update_bank_account(scope, bank_account, %{"budget_id" => budget_id})
  end

  test "refuses a budget belonging to another user", %{scope: scope, bank_account: bank_account} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, their_budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Theirs"})

    assert {:error, changeset} =
             Banks.update_bank_account(scope, bank_account, %{"budget_id" => their_budget.id})

    assert %{budget_id: ["does not exist"]} = errors_on(changeset)
  end

  test "refuses an account belonging to another user", %{bank_account: bank_account} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Banks.update_bank_account(Scope.for_user(other_user), bank_account, %{"sync" => false})
  end
end

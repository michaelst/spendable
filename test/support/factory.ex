defmodule Spendable.Factory do
  def user(opts \\ []) do
    params =
      build_params(
        %{
          provider: :google,
          external_id: Ecto.UUID.generate(),
          bank_limit: 10
        },
        opts
      )

    Spendable.User
    |> Ash.Changeset.new(params)
    |> Spendable.Api.create!()
  end

  def bank_member(user, opts \\ []) do
    params =
      build_params(
        %{
          external_id: Ecto.UUID.generate(),
          institution_id: "ins_1",
          name: "Plaid",
          plaid_token: "access-sandbox-898addd0-d983-45f8-a034-3b29d62794a7",
          provider: "Plaid",
          status: "CONNECTED"
        },
        opts
      )

    Spendable.BankMember
    |> Ash.Changeset.for_create(:factory, params)
    |> Ash.Changeset.manage_relationship(:user, user, type: :append_and_remove)
    |> Spendable.Api.create!()
  end

  def bank_account(bank_member, opts \\ []) do
    params =
      build_params(
        %{
          external_id: Ecto.UUID.generate(),
          name: "Checking",
          balance: Decimal.new("100.00"),
          type: "depository",
          sub_type: "checking",
          sync: true
        },
        opts
      )

    Spendable.BankAccount
    |> Ash.Changeset.new(params)
    |> Ash.Changeset.manage_relationship(:bank_member, bank_member, type: :append_and_remove)
    |> Ash.Changeset.manage_relationship(:user, bank_member.user, type: :append_and_remove)
    |> Spendable.Api.create!()
  end

  def transaction(user, opts \\ []) do
    params =
      build_params(
        %{
          amount: 10.25,
          date: Date.utc_today(),
          name: "test",
          note: "some notes",
          reviewed: false
        },
        opts
      )

    Spendable.Transaction
    |> Ash.Changeset.for_create(:create, params, actor: user)
    |> Spendable.Api.create!()
  end

  def budget(user, opts \\ []) do
    params =
      build_params(
        %{
          name: "Food"
        },
        opts
      )

    Spendable.Budget
    |> Ash.Changeset.for_create(:create, params, actor: user)
    |> Spendable.Api.create!()
  end

  def budget_allocation(budget, transaction, opts \\ []) do
    params =
      build_params(
        %{
          amount: Spendable.TestUtils.random_decimal(500..100_000)
        },
        opts
      )

    Spendable.BudgetAllocation
    |> Ash.Changeset.for_create(:create, params, actor: transaction.user)
    |> Ash.Changeset.manage_relationship(:budget, budget, type: :append_and_remove)
    |> Ash.Changeset.manage_relationship(:transaction, transaction, type: :append_and_remove)
    |> Spendable.Api.create!()
  end

  defp build_params(defaults, overrides) do
    Map.merge(defaults, Map.new(overrides))
  end
end

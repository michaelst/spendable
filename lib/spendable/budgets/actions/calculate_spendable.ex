defmodule Spendable.Budgets.Actions.CalculateSpendable do
  @moduledoc false

  import Ecto.Query
  import Spendable.Budgets.Utils.CalculateBalances

  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  @zero Decimal.new("0.00")

  @doc """
  Money in synced accounts that no budget has claimed.

  Tracking and income budgets are skipped because they record a month without holding anything,
  and a budget backed by a bank account is skipped because its balance is that account's, not a
  claim on the pool. What is left claims its balance, which is what the user has already spoken
  for - so an envelope filling itself shrinks this figure, and this figure going negative says
  the budgets promise more than the accounts hold.

  A claim is signed. An overspent envelope has already borrowed from the pool, and the money it
  overspent has already left the accounts, so its shortfall adds back rather than subtracting a
  second time. That keeps `accounts = budgets + spendable` true.
  """
  def calculate_spendable(%Scope{user: %{id: user_id}}) do
    balance =
      from(account in BankAccount,
        where: account.user_id == ^user_id,
        where: account.sync,
        where: is_nil(account.budget_id)
      )
      |> Repo.aggregate(:sum, :balance)
      |> Kernel.||(@zero)

    Decimal.sub(balance, claimed(user_id))
  end

  # Read through `calculate_balances/1` rather than re-summing here, so a budget's claim on the
  # pool and the balance the user is shown can never be computed two different ways.
  defp claimed(user_id) do
    from(budget in Budget,
      left_join: account in BankAccount,
      on: account.budget_id == budget.id,
      where: budget.user_id == ^user_id,
      where: budget.type not in [:tracking, :income],
      where: is_nil(account.id)
    )
    |> Repo.all()
    |> calculate_balances()
    |> Enum.reduce(@zero, &Decimal.add(&2, &1.balance))
  end
end

defmodule Spendable.Budgets.Actions.CalculateSpentByMonth do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  @zero Decimal.new("0")

  @doc """
  What the user spent per month, newest first, for the month picker.

  The current month is prepended when it has no spending yet, so the picker can always offer it.
  """
  def calculate_spent_by_month(%Scope{user: %{id: user_id}}) do
    current_month = Date.beginning_of_month(Date.utc_today())

    months =
      from(transaction in Transaction,
        select: %{
          month: fragment("TO_CHAR(?, 'YYYY-MM-01')::date", transaction.date),
          spent: coalesce(sum(transaction.amount), ^@zero)
        },
        where: transaction.user_id == ^user_id,
        where: transaction.amount < 0,
        where: not transaction.excluded,
        group_by: fragment("TO_CHAR(?, 'YYYY-MM-01')", transaction.date),
        order_by: [desc: fragment("TO_CHAR(?, 'YYYY-MM-01')", transaction.date)]
      )
      |> Repo.all()

    case months do
      [%{month: ^current_month} | _rest] -> months
      _no_spending_this_month -> [%{month: current_month, spent: @zero} | months]
    end
  end
end

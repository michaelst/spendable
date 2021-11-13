defmodule Spendable.User.Calculations.SpentByMonth do
  use Ash.Calculation, type: :decimal

  import Ecto.Query

  alias Spendable.Repo
  alias Spendable.Transaction

  @impl Ash.Calculation
  def calculate([user], _opts, _resolution) do
    query =
      from t in Transaction,
        select: %{
          month: fragment("TO_CHAR(?, 'YYYY-MM-01')::date", t.date),
          spent: sum(t.amount) |> coalesce(^Decimal.new(0))
        },
        where: t.user_id == ^user.id,
        where: t.amount < 0,
        group_by: fragment("TO_CHAR(?, 'YYYY-MM-01')", t.date),
        order_by: [desc: fragment("TO_CHAR(?, 'YYYY-MM-01')", t.date)]

    current_month = Date.utc_today() |> Timex.beginning_of_month()

    months =
      case Repo.all(query) do
        [%{month: ^current_month} | _rest] = months ->
          months

        months ->
          [%{month: current_month, spent: Decimal.new(0)} | months]
      end

    {:ok, [months]}
  end
end

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
          month: fragment("TO_CHAR(?, 'Mon YYYY')", t.date),
          spent: sum(t.amount) |> coalesce(^Decimal.new(0))
        },
        where: t.user_id == ^user.id,
        where: t.amount < 0,
        group_by: [fragment("TO_CHAR(?, 'Mon YYYY')", t.date), fragment("TO_CHAR(?, 'YYYY-MM')", t.date)],
        order_by: [desc: fragment("TO_CHAR(?, 'YYYY-MM')", t.date)]

    months = Repo.all(query)

    {:ok, [months]}
  end
end

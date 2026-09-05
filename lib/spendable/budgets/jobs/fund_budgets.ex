defmodule Spendable.Budgets.Jobs.FundBudgets do
  @moduledoc """
  Fills every user's self-funding budgets for the current month.

  Scheduled daily rather than on the first of the month, because funding a month is idempotent:
  the first run of the month does the work and the rest cost a query. That means a missed run
  heals itself the next day, and a budget created part-way through a month is funded without a
  path of its own.

  The month defaults to the UTC date. No user timezone is stored anywhere, so a user far enough
  west sees a new month begin before their own calendar turns over. Pass `month` in the job args
  to fund a different one, which is how a month missed while the queue was down gets filled in.
  """

  use Oban.Worker, queue: :budgets, max_attempts: 3

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Budgets
  alias Spendable.Repo
  alias Spendable.Scope

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    month = month(args)

    funded =
      User
      |> Repo.all()
      |> Enum.reduce(0, fn user, funded ->
        {:ok, count} = Budgets.fund_budgets(Scope.for_user(user), month)

        funded + count
      end)

    {:ok, funded}
  end

  defp month(%{"month" => month}), do: Date.from_iso8601!(month)
  defp month(_args), do: Date.utc_today()
end

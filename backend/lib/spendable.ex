defmodule Spendable do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Budgets.Allocation

  def data() do
    Dataloader.Ecto.new(Spendable.Repo, query: &query/2)
  end

  def query(Allocation, %{recent: true}) do
    from(a in Allocation,
      join: t in assoc(a, :transaction),
      where: t.date >= ^(Date.utc_today() |> Date.add(-60))
    )
  end

  def query(module, _args), do: from(module, order_by: :id)
end

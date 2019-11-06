defmodule Spendable do
  alias Spendable.Banks.Account
  import Ecto.Query, only: [from: 2]

  def data() do
    Dataloader.Ecto.new(Spendable.Repo, query: &query/2)
  end

  def query(Account, _) do
    from(Account, order_by: :name)
  end

  def query(queryable, _params) do
    queryable
  end
end

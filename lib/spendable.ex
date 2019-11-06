defmodule Spendable do
  def data() do
    Dataloader.Ecto.new(Spendable.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end

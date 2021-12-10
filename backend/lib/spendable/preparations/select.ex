defmodule Spendable.Preparations.Select do
  use Ash.Resource.Preparation

  @impl Ash.Resource.Preparation
  def prepare(query, opts, _context) do
    Ash.Query.select(query, opts[:fields])
  end
end

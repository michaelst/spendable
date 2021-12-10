defmodule Spendable.Preparations.Select do
  use Ash.Resource.Preparation

  @impl Ash.Resource.Preparation
  def prepare(query, opts, _context) do
    Ash.Query.ensure_selected(query, opts[:fields])
  end
end

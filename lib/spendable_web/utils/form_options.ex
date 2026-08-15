defmodule SpendableWeb.Utils.FormOptions do
  @moduledoc "Import this module rather than aliasing it."

  @doc """
  Turns records a LiveView already holds into `{label, id}` pairs for a select.

  Takes the list rather than the scope on purpose: the page has already loaded these, and a
  select should not cost a second query to render.
  """
  def form_options(records) do
    Enum.map(records, &{&1.name, &1.id})
  end
end

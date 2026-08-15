defmodule Spendable.Budgets.Actions.ListTemplates do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Budgets.Schemas.BudgetAllocationTemplate
  alias Spendable.Repo
  alias Spendable.Scope

  def list_templates(%Scope{user: %{id: user_id}}, opts \\ []) do
    from(template in BudgetAllocationTemplate,
      where: template.user_id == ^user_id,
      where: is_nil(template.archived_at),
      order_by: template.name
    )
    |> maybe_search(opts[:search])
    |> Repo.all()
  end

  defp maybe_search(query, search) when is_binary(search) and byte_size(search) > 0 do
    where(query, [template], ilike(template.name, ^"%#{search}%"))
  end

  defp maybe_search(query, _search), do: query
end

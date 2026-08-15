defmodule Spendable.Budgets.Actions.ArchiveBudget do
  @moduledoc false

  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  def archive_budget(_scope, %Budget{archived_at: %DateTime{}}), do: {:error, :already_archived}

  def archive_budget(%Scope{user: %{id: user_id}}, %Budget{user_id: user_id} = budget) do
    budget
    |> Budget.archive_changeset(%{archived_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def archive_budget(_scope, _budget), do: {:error, :not_authorized}
end

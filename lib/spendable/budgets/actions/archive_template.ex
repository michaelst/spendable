defmodule Spendable.Budgets.Actions.ArchiveTemplate do
  @moduledoc false

  alias Spendable.Budgets.Schemas.BudgetAllocationTemplate
  alias Spendable.Repo
  alias Spendable.Scope

  def archive_template(_scope, %BudgetAllocationTemplate{archived_at: %DateTime{}}) do
    {:error, :already_archived}
  end

  def archive_template(
        %Scope{user: %{id: user_id}},
        %BudgetAllocationTemplate{user_id: user_id} = template
      ) do
    template
    |> BudgetAllocationTemplate.archive_changeset(%{archived_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def archive_template(_scope, _template), do: {:error, :not_authorized}
end

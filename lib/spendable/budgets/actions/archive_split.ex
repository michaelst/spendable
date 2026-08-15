defmodule Spendable.Budgets.Actions.ArchiveSplit do
  @moduledoc false

  alias Spendable.Budgets.Schemas.Split
  alias Spendable.Repo
  alias Spendable.Scope

  def archive_split(_scope, %Split{archived_at: %DateTime{}}) do
    {:error, :already_archived}
  end

  def archive_split(
        %Scope{user: %{id: user_id}},
        %Split{user_id: user_id} = split
      ) do
    split
    |> Split.archive_changeset(%{archived_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def archive_split(_scope, _split), do: {:error, :not_authorized}
end

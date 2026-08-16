defmodule Spendable.Budgets.Actions.CreateSplit do
  @moduledoc false

  alias Spendable.Budgets.Schemas.Split
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Starts from an empty list of lines rather than an unloaded association, so a split created
  without any still comes back with `split_lines` a caller can read.
  """
  def create_split(%Scope{user: %{id: user_id}}, attrs) do
    %Split{user_id: user_id, split_lines: []}
    |> Split.changeset(attrs)
    |> Repo.insert()
  end
end

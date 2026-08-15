defmodule Spendable.Budgets.Actions.CreateSplit do
  @moduledoc false

  alias Spendable.Budgets.Schemas.Split
  alias Spendable.Repo
  alias Spendable.Scope

  def create_split(%Scope{user: %{id: user_id}}, attrs) do
    %Split{user_id: user_id}
    |> Split.changeset(attrs)
    |> Repo.insert()
  end
end

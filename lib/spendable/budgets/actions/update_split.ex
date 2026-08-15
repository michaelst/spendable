defmodule Spendable.Budgets.Actions.UpdateSplit do
  @moduledoc false

  alias Spendable.Budgets.Schemas.Split
  alias Spendable.Repo
  alias Spendable.Scope

  def update_split(
        %Scope{user: %{id: user_id}},
        %Split{user_id: user_id} = split,
        attrs
      ) do
    split
    |> Repo.preload(:split_lines)
    |> Split.changeset(attrs)
    |> Repo.update()
  end

  def update_split(_scope, _split, _attrs), do: {:error, :not_authorized}
end

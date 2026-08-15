defmodule Spendable.Budgets.Actions.GetSplit do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Budgets.Schemas.Split
  alias Spendable.Repo
  alias Spendable.Scope

  def get_split(%Scope{user: %{id: user_id}}, id) do
    query =
      from(split in Split,
        where: split.user_id == ^user_id,
        where: split.id == ^id,
        preload: [split_lines: :budget]
      )

    case Repo.one(query) do
      %Split{} = split -> {:ok, split}
      nil -> {:error, :split_not_found}
    end
  end
end

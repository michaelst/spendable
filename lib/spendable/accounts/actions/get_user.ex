defmodule Spendable.Accounts.Actions.GetUser do
  @moduledoc false

  alias Spendable.Accounts.Schemas.User
  alias Spendable.Repo

  def get_user(id) when is_binary(id) do
    case Repo.get(User, id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :user_not_found}
    end
  end

  def get_user(_id), do: {:error, :user_not_found}
end

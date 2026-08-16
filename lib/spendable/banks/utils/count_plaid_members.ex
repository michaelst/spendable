defmodule Spendable.Banks.Utils.CountPlaidMembers do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo

  @doc """
  How many of a user's connections count against their bank limit.

  Only Plaid ones do. The limit is about what a connection costs us, and FinanceKit reads from
  the device for nothing, so counting it would silently take a slot the user is paying for.
  """
  def count_plaid_members(user) do
    BankMember
    |> where([member], member.user_id == ^user.id and member.provider == "Plaid")
    |> Repo.aggregate(:count, :id)
  end
end

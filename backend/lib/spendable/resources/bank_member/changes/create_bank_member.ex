defmodule Spendable.BankMember.Changes.CreateBankMember do
  use Ash.Resource.Change

  import Ecto.Query

  alias Spendable.BankMember
  alias Spendable.Plaid.Adapter
  alias Spendable.Repo

  require Logger

  def change(changeset, _opts, %{actor: user}) do
    public_token = Ash.Changeset.get_argument(changeset, :public_token)

    Ash.Changeset.before_action(changeset, fn changeset ->
      case get_bank_member(public_token, user) do
        {:ok, bank_member_data} ->
          changeset
          |> Ash.Changeset.force_change_attributes(bank_member_data)
          |> Ash.Changeset.select(:plaid_token)


        {:error, error} ->
          Ash.Changeset.add_error(changeset, error)
      end
    end)
  end

  defp get_bank_member(public_token, user) do
    count = from(BankMember, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

    if count < user.bank_limit do
      {:ok, %{body: %{"access_token" => token}}} = Plaid.exchange_public_token(public_token)
      Logger.info("New plaid member token: #{token}")

      {:ok, %{body: details}} = Plaid.item(token)

      bank_member =
        details
        |> Adapter.bank_member()
        |> Map.put(:plaid_token, token)

      {:ok, bank_member}
    else
      {:error, "Bank limit reached"}
    end
  end
end

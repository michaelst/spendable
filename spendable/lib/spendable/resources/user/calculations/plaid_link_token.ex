defmodule Spendable.User.Calculations.PlaidLinkToken do
  use Ash.Calculation, type: :string

  import Ecto.Query

  alias Spendable.BankMember
  alias Spendable.Repo

  @impl Ash.Calculation
  def calculate([user], _opts, _resolution) do
    count = from(BankMember, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)

    if count < user.bank_limit do
      with {:ok, %{body: %{"link_token" => token}}} <- Plaid.create_link_token(user.id) do
        {:ok, [token]}
      end
    else
      {:error, [:no_connections_available]}
    end
  end

  def calculate([], _opts, _resolution), do: {:ok, []}
end

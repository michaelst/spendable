defmodule Spendable.Banks.Actions.QueueHistoricalSync do
  @moduledoc false

  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope

  @doc """
  A sync the user asks for by hand, reaching back as far as Plaid serves history.

  Plaid only. A FinanceKit connection is read on the device, so there is nothing the server can
  pull and the app backfills instead.
  """
  def queue_historical_sync(
        %Scope{user: %{id: user_id}},
        %BankMember{user_id: user_id, provider: "Plaid"} = bank_member
      ) do
    Banks.queue_sync(bank_member, historical: true)
  end

  def queue_historical_sync(%Scope{user: %{id: user_id}}, %BankMember{user_id: user_id}) do
    {:error, :not_supported}
  end

  def queue_historical_sync(%Scope{}, %BankMember{}), do: {:error, :not_authorized}
end

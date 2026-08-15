defmodule Spendable.Banks.Actions.QueueHistoricalSync do
  @moduledoc false

  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope

  @months 24

  @doc "A sync the user asks for by hand, reaching back as far as Plaid serves history."
  def queue_historical_sync(
        %Scope{user: %{id: user_id}},
        %BankMember{user_id: user_id} = bank_member
      ) do
    Banks.queue_sync(bank_member, start_date: Date.shift(Date.utc_today(), month: -@months))
  end

  def queue_historical_sync(%Scope{}, %BankMember{}), do: {:error, :not_authorized}
end

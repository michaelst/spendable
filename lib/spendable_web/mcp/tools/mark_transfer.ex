defmodule SpendableWeb.MCP.Tools.MarkTransfer do
  @moduledoc """
  Links two transactions as the two sides of a move between the user's own accounts. The pair has
  to be one transaction leaving an account and one arriving in another, since a transfer moves
  money rather than spending it. Both sides stop counting toward spending, their allocations are
  cleared onto Spendable where the opposite signs cancel, and both are marked reviewed.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: false}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Transactions

  schema do
    field :from_transaction_id, {:required, :string},
      description: "The id of the transaction the money left, whose amount is negative."

    field :to_transaction_id, {:required, :string},
      description: "The id of the transaction the money arrived in, whose amount is positive."
  end

  @impl true
  def execute(params, frame) do
    scope = frame.assigns.current_scope

    with {:ok, from} <- Transactions.get_transaction(scope, id: params.from_transaction_id),
         {:ok, to} <- Transactions.get_transaction(scope, id: params.to_transaction_id),
         {:ok, {linked_from, linked_to}} <- Transactions.mark_as_transfer(scope, from, to) do
      reply(frame, %{
        transactions:
          Enum.map(
            [linked_from, linked_to],
            &%{
              id: &1.id,
              name: &1.name,
              amount: Decimal.to_string(&1.amount),
              transfer_id: &1.transfer_id,
              reviewed: &1.reviewed
            }
          )
      })
    else
      {:error, reason} -> reply_error(frame, reason)
    end
  end
end

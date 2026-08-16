defmodule SpendableWeb.MCP.Tools.AllocateTransaction do
  @moduledoc """
  Divides a transaction across budgets. The allocations given replace whatever the transaction had
  before, so send the whole division every time, not just the part that changed. Amounts carry the
  transaction's sign - spending is negative - and whatever they do not add up to stays in the
  Spendable budget rather than being left undecided. Marking it reviewed says the user is done with
  it, which takes it out of the list of transactions still needing attention.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: false}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Transactions

  schema do
    field :transaction_id, {:required, :string}, description: "The id of the transaction to allocate."

    embeds_many :allocations,
      required: true,
      description:
        "How the transaction is divided across budgets. This replaces the division it already had, " <>
          "so send every part of it, and whatever these do not add up to stays in Spendable." do
      field :budget_id, {:required, :string}, description: "The id of the budget this part of the transaction goes to."

      field :amount, {:required, :string},
        description:
          "How much of the transaction this budget takes, signed the way the transaction is - negative " <>
            "for money spent. Decimal string, e.g. \"-40.00\"."
    end

    field :reviewed, :boolean,
      description:
        "Mark the transaction as one the user is done with, which takes it out of the list of " <>
          "transactions still needing attention."
  end

  @impl true
  def execute(params, frame) do
    scope = frame.assigns.current_scope

    allocations =
      Enum.map(params.allocations, &%{"budget_id" => &1.budget_id, "amount" => &1.amount})

    attrs = put_present(%{"budget_allocations" => allocations}, "reviewed", params[:reviewed])

    with {:ok, transaction} <- Transactions.get_transaction(scope, id: params.transaction_id),
         {:ok, transaction} <- Transactions.update_transaction(scope, transaction, attrs) do
      reply(frame, %{
        transaction: %{
          id: transaction.id,
          name: transaction.name,
          amount: Decimal.to_string(transaction.amount),
          reviewed: transaction.reviewed,
          allocations:
            Enum.map(
              transaction.budget_allocations,
              &%{budget_id: &1.budget_id, amount: Decimal.to_string(&1.amount)}
            )
        }
      })
    else
      {:error, reason} -> reply_error(frame, reason)
    end
  end

  defp put_present(attrs, _key, nil), do: attrs
  defp put_present(attrs, key, value), do: Map.put(attrs, key, value)
end

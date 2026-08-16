defmodule SpendableWeb.Api.Schemas.Transaction do
  @moduledoc false
  require OpenApiSpex

  import SpendableWeb.Utils.Money

  alias OpenApiSpex.Schema
  alias SpendableWeb.Api.Schemas.BudgetAllocation
  alias SpendableWeb.Api.Schemas.TransactionSource

  OpenApiSpex.schema(%{
    title: "Transaction",
    description: """
    A movement of money. Amounts are decimal strings, negative for money going out.

    `budget_allocations` is what the server settled on, not what was sent: any part of the amount
    left unallocated lands on the Spendable budget on every write. Render what comes back.
    """,
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      name: %Schema{type: :string},
      amount: %Schema{type: :string},
      date: %Schema{type: :string, format: :date},
      note: %Schema{type: :string, nullable: true},
      reviewed: %Schema{type: :boolean},
      excluded: %Schema{type: :boolean},
      transfer_id: %Schema{
        type: :string,
        nullable: true,
        description: "The other side of a move between the user's own accounts."
      },
      source: %Schema{oneOf: [TransactionSource], nullable: true},
      transfer_to: %Schema{
        oneOf: [TransactionSource],
        nullable: true,
        description: """
        The account a transfer arrived in, which is the source of its other side. The list carries
        only the side that left, so a row reads as one movement from its own account to this one.
        """
      },
      budget_allocations: %Schema{type: :array, items: BudgetAllocation}
    },
    required: [:id, :name, :amount, :date, :reviewed, :excluded, :budget_allocations]
  })

  def build(%Spendable.Transactions.Schemas.Transaction{} = transaction) do
    %__MODULE__{
      id: transaction.id,
      name: transaction.name,
      amount: amount(transaction.amount),
      date: transaction.date,
      note: transaction.note,
      reviewed: transaction.reviewed,
      excluded: transaction.excluded,
      transfer_id: transaction.transfer_id,
      source: TransactionSource.build(transaction.bank_transaction),
      transfer_to: TransactionSource.build(arriving_side(transaction)),
      budget_allocations: Enum.map(transaction.budget_allocations, &BudgetAllocation.build/1)
    }
  end

  defp arriving_side(%{transfer: %Spendable.Transactions.Schemas.Transaction{} = transfer}) do
    transfer.bank_transaction
  end

  defp arriving_side(_transaction), do: nil
end

defmodule SpendableWeb.MCP.Tools.CreateSplit do
  @moduledoc """
  Creates a split: a named set of lines, one budget and amount each, that pre-fills how a
  transaction gets divided. Amounts carry the sign the transaction will have, so spending lines are
  negative.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: false}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Budgets

  schema do
    field :name, {:required, :string}, description: "What the split is called."

    embeds_many :lines, required: true, description: "The budgets and amounts this split fills in." do
      field :budget_id, {:required, :string}, description: "The id of the budget this line fills."
      field :amount, {:required, :string}, description: "Decimal string, negative for spending, e.g. \"-40.00\"."
    end
  end

  @impl true
  def execute(params, frame) do
    lines = Enum.map(params.lines, &%{"budget_id" => &1.budget_id, "amount" => &1.amount})

    case Budgets.create_split(frame.assigns.current_scope, %{"name" => params.name, "split_lines" => lines}) do
      {:ok, split} ->
        reply(frame, %{
          split: %{
            id: split.id,
            name: split.name,
            lines:
              Enum.map(
                split.split_lines,
                &%{budget_id: &1.budget_id, amount: Decimal.to_string(&1.amount)}
              )
          }
        })

      {:error, changeset} ->
        reply_error(frame, changeset)
    end
  end
end

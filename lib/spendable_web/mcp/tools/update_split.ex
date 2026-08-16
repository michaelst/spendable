defmodule SpendableWeb.MCP.Tools.UpdateSplit do
  @moduledoc """
  Renames a split or changes its lines. The lines given replace the ones it had, so send the whole
  set every time, not just the line that changed. Leave `lines` out to rename it alone.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: false}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Budgets

  schema do
    field :split_id, {:required, :string}, description: "The id of the split to change."
    field :name, :string, description: "What the split is called."

    embeds_many :lines, description: "The budgets and amounts this split fills in, replacing the current ones." do
      field :budget_id, {:required, :string}, description: "The id of the budget this line fills."
      field :amount, {:required, :string}, description: "Decimal string, negative for spending, e.g. \"-40.00\"."
    end
  end

  @impl true
  def execute(params, frame) do
    scope = frame.assigns.current_scope

    attrs =
      %{}
      |> put_present("name", params[:name])
      |> put_present("split_lines", lines(params[:lines]))

    with {:ok, split} <- Budgets.get_split(scope, params.split_id),
         {:ok, split} <- Budgets.update_split(scope, split, attrs) do
      reply(frame, %{
        split: %{
          id: split.id,
          name: split.name,
          lines: Enum.map(split.split_lines, &%{budget_id: &1.budget_id, amount: Decimal.to_string(&1.amount)})
        }
      })
    else
      {:error, reason} -> reply_error(frame, reason)
    end
  end

  defp lines(nil), do: nil
  defp lines(lines), do: Enum.map(lines, &%{"budget_id" => &1.budget_id, "amount" => &1.amount})

  defp put_present(attrs, _key, nil), do: attrs
  defp put_present(attrs, key, value), do: Map.put(attrs, key, value)
end

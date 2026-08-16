defmodule SpendableWeb.MCP.Tools.ArchiveSplit do
  @moduledoc """
  Archives a split so it stops being offered, without erasing the transactions it already explains.
  There is no way to bring one back from here.
  """
  use Anubis.Server.Component, type: :tool, annotations: %{readOnlyHint: false}

  import SpendableWeb.Utils.ToolReply

  alias Spendable.Budgets

  schema do
    field :split_id, {:required, :string}, description: "The id of the split to archive."
  end

  @impl true
  def execute(params, frame) do
    scope = frame.assigns.current_scope

    with {:ok, split} <- Budgets.get_split(scope, params.split_id),
         {:ok, split} <- Budgets.archive_split(scope, split) do
      reply(frame, %{split: %{id: split.id, name: split.name, archived: true}})
    else
      {:error, reason} -> reply_error(frame, reason)
    end
  end
end

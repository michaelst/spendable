defmodule SpendableWeb.MCP.Server do
  @moduledoc """
  The Spendable MCP server: the tools an AI client can call over streamable HTTP.

  Each tool is a component module declaring its own schema, and runs as the user their bearer token
  was issued to - `SpendableWeb.Plugs.VerifyMcpToken` puts that scope on the conn, and Anubis
  carries the conn's assigns onto the frame. A tool therefore reaches data exactly as a signed-in
  person does, through the same context actions and the same ownership checks.
  """
  use Anubis.Server,
    name: "spendable",
    version: "0.1.0",
    capabilities: [:tools]

  component(SpendableWeb.MCP.Tools.AllocateTransaction)
  component(SpendableWeb.MCP.Tools.ArchiveSplit)
  component(SpendableWeb.MCP.Tools.CreateBudget)
  component(SpendableWeb.MCP.Tools.CreateSplit)
  component(SpendableWeb.MCP.Tools.FundBudget)
  component(SpendableWeb.MCP.Tools.ListBudgets)
  component(SpendableWeb.MCP.Tools.ListSplits)
  component(SpendableWeb.MCP.Tools.ListTransactions)
  component(SpendableWeb.MCP.Tools.MarkTransfer)
  component(SpendableWeb.MCP.Tools.UpdateBudget)
  component(SpendableWeb.MCP.Tools.UpdateSplit)
end

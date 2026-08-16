defmodule SpendableWeb.Api.Schemas.BulkResult do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias SpendableWeb.Api.Schemas.BulkFailure
  alias SpendableWeb.Api.Schemas.Transaction

  OpenApiSpex.schema(%{
    title: "BulkResult",
    description: """
    A bulk change is applied per transaction rather than all or nothing, so the ones that worked
    come back alongside the ones that did not.
    """,
    type: :object,
    properties: %{
      transactions: %Schema{type: :array, items: Transaction},
      failed: %Schema{type: :array, items: BulkFailure}
    },
    required: [:transactions, :failed]
  })

  def build(results) do
    {applied, failed} = Enum.split_with(results, &match?({:ok, _transaction}, &1))

    %__MODULE__{
      transactions: Enum.map(applied, fn {:ok, transaction} -> Transaction.build(transaction) end),
      failed: Enum.map(failed, fn {:error, id, code} -> BulkFailure.build(id, code) end)
    }
  end
end

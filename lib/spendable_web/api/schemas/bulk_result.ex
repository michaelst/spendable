defmodule SpendableWeb.Api.Schemas.BulkResult do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema
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
      failed: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :string},
            code: %Schema{type: :string}
          },
          required: [:id, :code]
        }
      }
    },
    required: [:transactions, :failed]
  })

  def build(results) do
    {applied, failed} = Enum.split_with(results, &match?({:ok, _transaction}, &1))

    %__MODULE__{
      transactions: Enum.map(applied, fn {:ok, transaction} -> Transaction.build(transaction) end),
      failed: Enum.map(failed, fn {:error, id, code} -> %{id: id, code: code} end)
    }
  end
end

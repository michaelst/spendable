defmodule SpendableWeb.Api.Schemas.MonthSpend do
  @moduledoc false
  require OpenApiSpex

  import SpendableWeb.Utils.Money

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "MonthSpend",
    description: "A month the user has spent in, for the month picker.",
    type: :object,
    properties: %{
      month: %Schema{type: :string, format: :date},
      spent: %Schema{type: :string}
    },
    required: [:month, :spent]
  })

  def build(%{month: month, spent: spent}) do
    %__MODULE__{month: month, spent: amount(spent)}
  end
end

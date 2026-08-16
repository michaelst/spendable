defmodule SpendableWeb.Utils.Money do
  @moduledoc "Import this module rather than aliasing it."

  @doc """
  Money crosses the wire as a string. A JSON number is a float to most clients, and a budgeting
  app that loses a cent in transit is worse than one that makes the client parse.
  """
  def amount(%Decimal{} = value), do: Decimal.to_string(value, :normal)
  def amount(nil), do: nil
end

defmodule Spendable.Utils do
  def format_currency(nil), do: "$0.00"

  def format_currency(decimal) do
    negative? = Decimal.negative?(decimal)

    string =
      decimal
      |> Decimal.abs()
      |> Decimal.round(2)
      |> Decimal.to_string()

    currency = if negative?, do: "-$", else: "$"

    formatted_dollars =
      string
      |> String.slice(0..-4//1)
      |> String.reverse()
      |> String.codepoints()
      |> Enum.chunk_every(3)
      |> Enum.join(",")
      |> String.reverse()

    decimals = String.slice(string, -3..-1)

    currency <> formatted_dollars <> decimals
  end
end

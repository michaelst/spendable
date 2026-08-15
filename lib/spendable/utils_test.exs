defmodule Spendable.UtilsTest do
  use ExUnit.Case, async: true

  alias Spendable.Utils

  test "formats a positive amount with thousands separators" do
    assert Utils.format_currency(Decimal.new("1234567.891")) == "$1,234,567.89"
  end

  test "formats a negative amount with the sign in front of the currency" do
    assert Utils.format_currency(Decimal.new("-12.5")) == "-$12.50"
  end

  # Balances come back nil before anything has been allocated.
  test "formats a missing amount as zero" do
    assert Utils.format_currency(nil) == "$0.00"
  end
end

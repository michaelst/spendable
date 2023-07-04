defmodule Spendable.UtilsTest do
  use Spendable.DataCase, async: true

  alias Spendable.Utils

  describe "format_currency/1" do
    test "formats positive numbers" do
      assert "$1,000.00" == Utils.format_currency(Decimal.new("1000"))
    end

    test "formats negative numbers" do
      assert "-$1,000.00" == Utils.format_currency(Decimal.new("-1000"))
    end

    test "formats numbers with decimals" do
      assert "$1,000.01" == Utils.format_currency(Decimal.new("1000.01"))
    end

    test "formats numbers with decimals and negative numbers" do
      assert "-$1,000.01" == Utils.format_currency(Decimal.new("-1000.01"))
    end
  end
end

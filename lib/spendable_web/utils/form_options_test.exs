defmodule SpendableWeb.Utils.FormOptionsTest do
  use ExUnit.Case, async: true

  import SpendableWeb.Utils.FormOptions

  alias Spendable.Budgets.Schemas.Budget

  test "pairs each record's name with its id, keeping the order it was given" do
    budgets = [
      %Budget{id: "bgt_01M036GTQ48JXS0A2AXFNV6H5P", name: "Spendable"},
      %Budget{id: "bgt_01M036GTQY10DHDKA4EK6YXHD9", name: "Groceries"}
    ]

    assert [
             {"Spendable", "bgt_01M036GTQ48JXS0A2AXFNV6H5P"},
             {"Groceries", "bgt_01M036GTQY10DHDKA4EK6YXHD9"}
           ] = form_options(budgets)
  end

  test "returns nothing for an empty list" do
    assert [] = form_options([])
  end
end

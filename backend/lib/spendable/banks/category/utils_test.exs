defmodule Spendable.Banks.Category.UtilsTest do
  use Spendable.DataCase, async: true
  import Tesla.Mock

  alias Spendable.Banks.Category.Utils

  setup do
    mock(fn
      %{method: :post, url: "https://sandbox.plaid.com/categories/get"} ->
        json(%{
          "categories" => [
            %{
              "category_id" => "10000000",
              "group" => "special",
              "hierarchy" => ["Bank Fees"]
            },
            %{
              "category_id" => "10001000",
              "group" => "special",
              "hierarchy" => ["Bank Fees", "Overdraft"]
            },
            %{
              "category_id" => "10002000",
              "group" => "special",
              "hierarchy" => ["Bank Fees", "ATM"]
            },
            %{
              "category_id" => "11000000",
              "group" => "special",
              "hierarchy" => ["Cash Advance"]
            }
          ]
        })
    end)

    :ok
  end

  test "import categories" do
    Utils.get_categories() |> Utils.import_categories()
  end
end

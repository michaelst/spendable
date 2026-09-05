defmodule Spendable.Banks.Utils.FormatBankMemberTest do
  use Spendable.DataCase, async: true

  import Spendable.Banks.Utils.FormatBankMember

  setup do
    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"} = env, _opts ->
        case Jason.decode!(env.body)["institution_id"] do
          "ins_error" ->
            {:error, :timeout}

          "ins_no_name" ->
            TeslaHelper.response(body: %{"institution" => %{"name" => nil, "logo" => "data:logo"}})

          _other ->
            TeslaHelper.response(body: %{"institution" => %{"name" => "Chase", "logo" => "data:logo"}})
        end
    end)

    :ok
  end

  test "formats bank member from plaid item with institution details" do
    item = %{
      "item" => %{
        "item_id" => "item_123",
        "institution_id" => "ins_chase",
        "error" => nil
      }
    }

    assert %{
             external_id: "item_123",
             institution_id: "ins_chase",
             name: "Chase",
             logo: "data:logo",
             provider: "Plaid",
             status: "CONNECTED"
           } = format_bank_member(item)
  end

  test "falls back to Bank when institution has no name" do
    item = %{
      "item" => %{
        "item_id" => "item_123",
        "institution_id" => "ins_no_name",
        "error" => nil
      }
    }

    assert %{
             name: "Bank",
             logo: "data:logo"
           } = format_bank_member(item)
  end

  test "falls back to Bank and nil logo when institution lookup fails" do
    item = %{
      "item" => %{
        "item_id" => "item_123",
        "institution_id" => "ins_error",
        "error" => nil
      }
    }

    assert %{
             external_id: "item_123",
             institution_id: "ins_error",
             name: "Bank",
             logo: nil,
             provider: "Plaid",
             status: "CONNECTED"
           } = format_bank_member(item)
  end

  test "falls back to Bank and nil logo when institution_id is missing" do
    item = %{
      "item" => %{
        "item_id" => "item_123",
        "institution_id" => nil,
        "error" => %{"error_code" => "ITEM_LOGIN_REQUIRED"}
      }
    }

    assert %{
             external_id: "item_123",
             institution_id: nil,
             name: "Bank",
             logo: nil,
             provider: "Plaid",
             status: "ITEM_LOGIN_REQUIRED"
           } = format_bank_member(item)
  end
end

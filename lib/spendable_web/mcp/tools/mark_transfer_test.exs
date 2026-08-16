defmodule SpendableWeb.MCP.Tools.MarkTransferTest do
  use Spendable.DataCase, async: true

  alias Anubis.Server.Frame
  alias Anubis.Server.Response
  alias Spendable.Accounts
  alias Spendable.Scope
  alias Spendable.Transactions
  alias SpendableWeb.MCP.Tools.MarkTransfer

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, %{id: from_id} = from} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer to savings",
        "amount" => "-500.00",
        "date" => "2026-08-15"
      })

    {:ok, %{id: to_id} = to} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer from checking",
        "amount" => "500.00",
        "date" => "2026-08-15"
      })

    %{
      frame: Frame.new(%{current_scope: scope}),
      from: from,
      from_id: from_id,
      to: to,
      to_id: to_id,
      scope: scope
    }
  end

  test "links both sides and marks them reviewed", %{frame: frame, from_id: from_id, to_id: to_id} do
    assert {:reply,
            %Response{
              structured_content: %{
                transactions: [
                  %{id: ^from_id, transfer_id: ^to_id, reviewed: true},
                  %{id: ^to_id, transfer_id: ^from_id, reviewed: true}
                ]
              }
            }, ^frame} =
             MarkTransfer.execute(%{from_transaction_id: from_id, to_transaction_id: to_id}, frame)
  end

  test "refuses a pair moving the same way", %{frame: frame, from: from, scope: scope} do
    {:ok, other} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.00",
        "date" => "2026-08-15"
      })

    assert {:reply, %Response{isError: true, content: [%{"text" => "transfer not allowed"}]}, ^frame} =
             MarkTransfer.execute(
               %{from_transaction_id: from.id, to_transaction_id: other.id},
               frame
             )
  end

  test "cannot reach a transaction belonging to another user", %{frame: frame, to: to} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, theirs} =
      Transactions.create_transaction(Scope.for_user(other_user), %{
        "name" => "Transfer to savings",
        "amount" => "-500.00",
        "date" => "2026-08-15"
      })

    assert {:reply, %Response{isError: true, content: [%{"text" => "transaction not found"}]}, ^frame} =
             MarkTransfer.execute(
               %{from_transaction_id: theirs.id, to_transaction_id: to.id},
               frame
             )
  end
end

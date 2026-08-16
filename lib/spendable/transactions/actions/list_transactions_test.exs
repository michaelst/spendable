defmodule Spendable.Transactions.Actions.ListTransactionsTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Scope
  alias Spendable.Transactions

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user), attrs: %{"amount" => "-5.00", "reviewed" => false}}
  end

  test "returns the newest first", %{scope: scope, attrs: attrs} do
    {:ok, _older} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Older", "date" => "2026-08-01"})
      )

    {:ok, _newer} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Newer", "date" => "2026-08-14"})
      )

    assert [%{name: "Newer"}, %{name: "Older"}] = Transactions.list_transactions(scope)
  end

  test "hides reviewed transactions unless asked for", %{scope: scope, attrs: attrs} do
    {:ok, _reviewed} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Reviewed", "date" => "2026-08-15", "reviewed" => true})
      )

    {:ok, _pending} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Pending", "date" => "2026-08-15"})
      )

    assert [%{name: "Pending"}] = Transactions.list_transactions(scope)
    assert [_reviewed, _pending] = Transactions.list_transactions(scope, show_reviewed: true)
  end

  test "hides excluded transactions unless asked for", %{scope: scope, attrs: attrs} do
    {:ok, _excluded} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Excluded", "date" => "2026-08-15", "excluded" => true})
      )

    {:ok, _counted} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Counted", "date" => "2026-08-15"})
      )

    assert [%{name: "Counted"}] = Transactions.list_transactions(scope)
    assert [_excluded, _counted] = Transactions.list_transactions(scope, show_excluded: true)
  end

  # A transfer is one movement of money, and nothing is hidden until the pair is made.
  test "carries a transfer once, as the side that left", %{scope: scope, attrs: attrs} do
    {:ok, out} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "To savings", "date" => "2026-08-15"})
      )

    {:ok, into} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "From checking", "date" => "2026-08-15", "amount" => "5.00"})
      )

    assert [_into, _out] = Transactions.list_transactions(scope, show_reviewed: true)

    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, into)

    assert [%{name: "To savings"}] = Transactions.list_transactions(scope, show_reviewed: true)
  end

  test "excludes other users' transactions", %{scope: scope, attrs: attrs} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, _theirs} =
      Transactions.create_transaction(
        Scope.for_user(other_user),
        Map.merge(attrs, %{"name" => "Theirs", "date" => "2026-08-15"})
      )

    {:ok, _mine} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Mine", "date" => "2026-08-15"})
      )

    assert [%{name: "Mine"}] = Transactions.list_transactions(scope)
  end

  test "searches the name and the note", %{scope: scope, attrs: attrs} do
    {:ok, _by_name} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Coffee", "date" => "2026-08-15"})
      )

    {:ok, _by_note} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Shop", "date" => "2026-08-15", "note" => "coffee beans"})
      )

    {:ok, _unrelated} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Rent", "date" => "2026-08-15"})
      )

    assert [_first, _second] = Transactions.list_transactions(scope, search: "coffee")
  end

  test "ignores a blank search term", %{scope: scope, attrs: attrs} do
    {:ok, _coffee} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Coffee", "date" => "2026-08-15"})
      )

    assert [%{name: "Coffee"}] = Transactions.list_transactions(scope, search: "")
  end

  test "limits a page and offsets the next one", %{scope: scope, attrs: attrs} do
    {:ok, _older} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Older", "date" => "2026-08-01"})
      )

    {:ok, _newer} =
      Transactions.create_transaction(
        scope,
        Map.merge(attrs, %{"name" => "Newer", "date" => "2026-08-14"})
      )

    assert [%{name: "Newer"}] = Transactions.list_transactions(scope, per_page: 1)
    assert [%{name: "Older"}] = Transactions.list_transactions(scope, per_page: 1, page: 2)
  end
end

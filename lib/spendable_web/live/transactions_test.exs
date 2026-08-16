defmodule SpendableWeb.Live.TransactionsTest do
  use SpendableWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Spendable.Accounts
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Banks.Schemas.BankTransaction
  alias Spendable.Budgets
  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)
    {:ok, %{id: budget_id} = budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:current_user_id, user.id)

    attrs = %{"amount" => "-5.00", "date" => "2026-08-15", "reviewed" => false}

    %{conn: conn, scope: scope, budget: budget, budget_id: budget_id, attrs: attrs}
  end

  test "renders the transaction list", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, _transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, _view, html} = live(conn, ~p"/transactions")

    assert html =~ "Coffee"
  end

  test "edits a transaction", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element("#open-#{transaction.id}") |> render_click()

    view
    |> element(~s(form[phx-submit="submit"]))
    |> render_submit(%{
      transaction: %{"name" => "Espresso", "amount" => "-5.00", "date" => "2026-08-15"}
    })

    assert [%{name: "Espresso"}] = Transactions.list_transactions(scope)
  end

  test "keeps the form open and reports the error when the name is blank", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element("#open-#{transaction.id}") |> render_click()

    html =
      view
      |> element(~s(form[phx-submit="submit"]))
      |> render_submit(%{transaction: %{"name" => "", "amount" => "-5.00", "date" => "2026-08-15"}})

    assert html =~ "can&#39;t be blank"
  end

  test "deletes the selected transactions", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    render_click(view, "delete", %{})

    assert [] = Transactions.list_transactions(scope)
  end

  test "keeps a transaction that is selected and then deselected", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    render_click(view, "toggle_select_transaction", %{"id" => transaction.id})
    render_click(view, "delete", %{})

    assert [%{name: "Coffee"}] = Transactions.list_transactions(scope)
  end

  test "applies a split's lines to the open transaction", %{
    conn: conn,
    scope: scope,
    budget: budget,
    attrs: attrs
  } do
    {:ok, split} =
      Budgets.create_split(scope, %{
        "name" => "Paycheck",
        "split_lines" => %{
          "0" => %{"amount" => "-3.00", "budget_id" => budget.id}
        }
      })

    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element("#open-#{transaction.id}") |> render_click()

    html = render_click(view, "apply_split", %{"split" => split.id})

    assert html =~ "-3.00"
  end

  test "hides reviewed transactions when the option is toggled off", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, _reviewed} =
      Transactions.create_transaction(
        scope,
        attrs |> Map.put("name", "Reviewed") |> Map.put("reviewed", true)
      )

    {:ok, view, _html} = live(conn, ~p"/transactions")

    assert render(view) =~ "Reviewed"

    refute render_click(view, "change_reviewed_option", %{}) =~ "Reviewed"
  end

  # Splitting posts every line's own amount, so the transaction's amount no longer stands in.
  test "splits a transaction across two budgets", %{
    conn: conn,
    scope: scope,
    budget: budget,
    attrs: attrs
  } do
    {:ok, other} = Budgets.create_budget(scope, %{"name" => "Rent"})

    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element("#open-#{transaction.id}") |> render_click()

    params = %{
      "name" => "Coffee",
      "amount" => "-5.00",
      "date" => "2026-08-15",
      "allocations_sort" => ["0", "1"],
      "budget_allocations" => %{
        "0" => %{"amount" => "-3.00", "budget_id" => budget.id},
        "1" => %{"amount" => "-2.00", "budget_id" => other.id}
      }
    }

    view |> element(~s(form[phx-submit="submit"])) |> render_change(%{transaction: params})
    view |> element(~s(form[phx-submit="submit"])) |> render_submit(%{transaction: params})

    {:ok, transaction} = Transactions.get_transaction(scope, id: transaction.id)
    assert [%{amount: first}, %{amount: second}] = transaction.budget_allocations
    assert Decimal.eq?(first, "-3.00")
    assert Decimal.eq?(second, "-2.00")
  end

  test "closes the details form", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element("#open-#{transaction.id}") |> render_click()
    html = render_click(view, "close", %{})

    refute html =~ ~s(phx-submit="submit")
  end

  test "shows excluded transactions when the option is toggled on", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Refund"))

    {:ok, _excluded} =
      Transactions.update_transaction(scope, transaction, %{"excluded" => true})

    {:ok, view, _html} = live(conn, ~p"/transactions")

    refute render(view) =~ "Refund"

    assert render_click(view, "change_excluded_option", %{}) =~ "Refund"
  end

  # The list pages as it is scrolled, so the page moves with the viewport rather than a button.
  test "pages through the list as it is scrolled", %{conn: conn, scope: scope, attrs: attrs} do
    # One more than a page, so the last one only appears once the list has been paged.
    for number <- 1..101 do
      {:ok, _transaction} =
        Transactions.create_transaction(
          scope,
          attrs
          |> Map.put("name", "Txn-#{String.pad_leading(to_string(number), 3, "0")}")
          |> Map.put("date", Date.to_iso8601(Date.add(~D[2026-08-15], -number)))
        )
    end

    {:ok, view, html} = live(conn, ~p"/transactions")

    assert html =~ "Txn-001"
    refute html =~ "Txn-101"

    html = render_click(view, "next-page", %{})
    assert html =~ "Txn-101"

    assert render_click(view, "prev-page", %{}) =~ "Txn-001"
  end

  # Scrolling past the last page must leave the rows alone rather than emptying the list.
  test "keeps the list when scrolled past the end", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, _coffee} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    assert render_click(view, "next-page", %{}) =~ "Coffee"
    assert render_click(view, "prev-page", %{}) =~ "Coffee"
  end

  # The row can be gone by the time the delete lands, and deleting the rest still has to work.
  test "deletes what is left when a selected transaction is already gone", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} =
      Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    {:ok, _deleted} = Transactions.delete_transaction(scope, transaction)

    render_click(view, "delete", %{})

    assert [] = Transactions.list_transactions(scope)
  end

  test "toggles reviewed from the row", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_reviewed", %{"id" => transaction.id})
    assert {:ok, %{reviewed: true}} = Transactions.get_transaction(scope, id: transaction.id)

    render_click(view, "toggle_reviewed", %{"id" => transaction.id})
    assert {:ok, %{reviewed: false}} = Transactions.get_transaction(scope, id: transaction.id)
  end

  test "sets what a transaction is spent from with the row's select", %{
    conn: conn,
    scope: scope,
    budget: budget,
    budget_id: budget_id,
    attrs: attrs
  } do
    {:ok, transaction} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view
    |> element("#spend-from-#{transaction.id}")
    |> render_change(%{"budget_id" => budget.id})

    {:ok, transaction} = Transactions.get_transaction(scope, id: transaction.id)

    assert [%{budget_id: ^budget_id, amount: amount}] = transaction.budget_allocations
    assert Decimal.eq?(amount, "-5.00")
  end

  # Saying where the whole of a transaction went is the decision the queue is asking for, so
  # making it is what finishes the row.
  test "marks a transaction reviewed once the row says what it was spent from", %{
    conn: conn,
    scope: scope,
    budget: budget,
    attrs: attrs
  } do
    {:ok, transaction} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    refute transaction.reviewed

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view
    |> element("#spend-from-#{transaction.id}")
    |> render_change(%{"budget_id" => budget.id})

    assert {:ok, %{reviewed: true}} = Transactions.get_transaction(scope, id: transaction.id)
  end

  # A transfer is settled rather than set aside, so it reads like any other finished row.
  test "does not dim a transaction that is part of a transfer", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, out} = Transactions.create_transaction(scope, Map.put(attrs, "name", "To savings"))

    {:ok, into} =
      Transactions.create_transaction(
        scope,
        attrs |> Map.put("name", "From checking") |> Map.put("amount", "5.00")
      )

    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, into)

    {:ok, view, _html} = live(conn, ~p"/transactions")

    assert has_element?(view, "#transactions-#{out.id}")
    refute has_element?(view, "#transactions-#{out.id}.opacity-40")
  end

  # A split has no single budget to offer, so the row sends the user to the drawer instead.
  test "offers no select for a split transaction", %{
    conn: conn,
    scope: scope,
    budget: budget,
    attrs: attrs
  } do
    {:ok, _transaction} =
      Transactions.create_transaction(
        scope,
        attrs
        |> Map.put("name", "Shopping")
        |> Map.put("budget_allocations", %{
          "0" => %{"amount" => "-2.00", "budget_id" => budget.id}
        })
      )

    {:ok, view, _html} = live(conn, ~p"/transactions")

    assert has_element?(view, "button", "Split")
    refute has_element?(view, ~s(form[phx-change="set_spend_from"]))
  end

  test "shows which account a transaction came from", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: scope.user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token",
        logo: Base.encode64(<<137, 80, 78, 71>>)
      })

    {:ok, bank_account} =
      Repo.insert(%BankAccount{
        user_id: scope.user.id,
        bank_member_id: bank_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Checking",
        number: "1234",
        balance: Decimal.new("100.00"),
        sub_type: "checking",
        type: "depository"
      })

    {:ok, bank_transaction} =
      Repo.insert(%BankTransaction{
        user_id: scope.user.id,
        bank_account_id: bank_account.id,
        external_id: Ecto.UUID.generate(),
        amount: Decimal.new("5.00"),
        date: ~D[2026-08-15],
        name: "Coffee",
        pending: false
      })

    {:ok, transaction} =
      Transactions.create_transaction(
        scope,
        attrs
        |> Map.put("name", "Coffee")
        |> Map.put("bank_transaction_id", bank_transaction.id)
      )

    {:ok, view, html} = live(conn, ~p"/transactions")

    assert html =~ "Checking"
    assert html =~ "••••1234"
    assert html =~ "/banks/#{bank_member.id}/logo"

    # A row is re-rendered from what the write returned, so the account has to survive an edit.
    html = render_click(view, "toggle_reviewed", %{"id" => transaction.id})

    assert html =~ "Checking"
    assert html =~ "••••1234"
    assert html =~ "/banks/#{bank_member.id}/logo"
  end

  # Wallet is not an institution Plaid has a logo for, so Apple's own mark stands in.
  test "marks a transaction read out of Wallet with Apple's own mark", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: scope.user.id,
        external_id: Ecto.UUID.generate(),
        name: "Apple",
        provider: "FinanceKit"
      })

    {:ok, bank_account} =
      Repo.insert(%BankAccount{
        user_id: scope.user.id,
        bank_member_id: bank_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Apple Card",
        balance: Decimal.new("-100.00"),
        sub_type: "credit card",
        type: "credit"
      })

    {:ok, bank_transaction} =
      Repo.insert(%BankTransaction{
        user_id: scope.user.id,
        bank_account_id: bank_account.id,
        external_id: Ecto.UUID.generate(),
        amount: Decimal.new("-5.00"),
        date: ~D[2026-08-15],
        name: "Coffee",
        pending: false
      })

    {:ok, _transaction} =
      Transactions.create_transaction(
        scope,
        attrs |> Map.put("name", "Coffee") |> Map.put("bank_transaction_id", bank_transaction.id)
      )

    {:ok, _view, html} = live(conn, ~p"/transactions")

    assert html =~ "Apple Card"
    assert html =~ ~s(viewBox="0 0 1261 1551")
    refute html =~ "/banks/#{bank_member.id}/logo"
  end

  # A transfer is one movement of money, so the list says it once and says where it went.
  test "reads a transfer as one row from one account to the other", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: scope.user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    [out, into] =
      for {account_name, number, amount, name} <- [
            {"Checking", "1234", "-5.00", "To savings"},
            {"Savings", "9876", "5.00", "From checking"}
          ] do
        {:ok, bank_account} =
          Repo.insert(%BankAccount{
            user_id: scope.user.id,
            bank_member_id: bank_member.id,
            external_id: Ecto.UUID.generate(),
            name: account_name,
            number: number,
            balance: Decimal.new("100.00"),
            sub_type: "checking",
            type: "depository"
          })

        {:ok, bank_transaction} =
          Repo.insert(%BankTransaction{
            user_id: scope.user.id,
            bank_account_id: bank_account.id,
            external_id: Ecto.UUID.generate(),
            amount: Decimal.new(amount),
            date: ~D[2026-08-15],
            name: name,
            pending: false
          })

        {:ok, transaction} =
          Transactions.create_transaction(
            scope,
            attrs
            |> Map.put("name", name)
            |> Map.put("amount", amount)
            |> Map.put("bank_transaction_id", bank_transaction.id)
          )

        transaction
      end

    {:ok, view, _html} = live(conn, ~p"/transactions")

    html = render_click(view, "toggle_select_transaction", %{"id" => out.id, "value" => "on"})
    assert html =~ "Savings"

    render_click(view, "toggle_select_transaction", %{"id" => into.id, "value" => "on"})
    html = render_click(view, "bulk_transfer", %{})

    # The row that arrived leaves the list as the pair is made, and the one that left says where.
    refute has_element?(view, "#transactions-#{into.id}")
    assert html =~ "Checking"
    assert html =~ "Savings"
    assert html =~ "→"

    {:ok, _reloaded, html} = live(conn, ~p"/transactions")

    refute html =~ ~s(id="transactions-#{into.id}")
    assert html =~ "→"
  end

  test "marks the selected transactions reviewed", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    render_click(view, "bulk_review", %{})

    assert {:ok, %{reviewed: true}} = Transactions.get_transaction(scope, id: transaction.id)
  end

  test "excludes the selected transactions", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    render_click(view, "bulk_exclude", %{})

    assert {:ok, %{excluded: true}} = Transactions.get_transaction(scope, id: transaction.id)
  end

  test "sets what the selected transactions are spent from", %{
    conn: conn,
    scope: scope,
    budget: budget,
    budget_id: budget_id,
    attrs: attrs
  } do
    {:ok, transaction} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    render_click(view, "bulk_spend_from", %{"budget" => budget.id})

    {:ok, transaction} = Transactions.get_transaction(scope, id: transaction.id)

    assert [%{budget_id: ^budget_id}] = transaction.budget_allocations
  end

  test "marks two selected transactions as a transfer", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, out} = Transactions.create_transaction(scope, Map.put(attrs, "name", "To savings"))

    {:ok, %{id: into_id} = into} =
      Transactions.create_transaction(
        scope,
        attrs |> Map.put("name", "From checking") |> Map.put("amount", "5.00")
      )

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => out.id, "value" => "on"})
    render_click(view, "toggle_select_transaction", %{"id" => into.id, "value" => "on"})
    html = render_click(view, "bulk_transfer", %{})

    assert html =~ "Transfer"

    assert {:ok, %{transfer_id: ^into_id}} = Transactions.get_transaction(scope, id: out.id)

    # A hand-entered counterpart has no account, so the drawer falls back to naming it.
    assert view |> element("#open-#{out.id}") |> render_click() =~ "Transfer with From checking"
  end

  test "reports why two transactions cannot be a transfer", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, one} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))
    {:ok, two} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Tea"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => one.id, "value" => "on"})
    render_click(view, "toggle_select_transaction", %{"id" => two.id, "value" => "on"})

    assert render_click(view, "bulk_transfer", %{}) =~ "one transaction leaving an account"
  end

  test "reports a transaction that is already part of a transfer", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, out} = Transactions.create_transaction(scope, Map.put(attrs, "name", "To savings"))

    {:ok, into} =
      Transactions.create_transaction(
        scope,
        attrs |> Map.put("name", "From checking") |> Map.put("amount", "5.00")
      )

    {:ok, other} =
      Transactions.create_transaction(
        scope,
        attrs |> Map.put("name", "Refund") |> Map.put("amount", "5.00")
      )

    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, into)

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => out.id, "value" => "on"})
    render_click(view, "toggle_select_transaction", %{"id" => other.id, "value" => "on"})

    assert render_click(view, "bulk_transfer", %{}) =~ "already part of a transfer"
  end

  test "does nothing when a transfer is asked for without a pair", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    render_click(view, "bulk_transfer", %{})

    assert {:ok, %{transfer_id: nil}} = Transactions.get_transaction(scope, id: transaction.id)
  end

  test "does nothing when asked to remove a transfer that is not one", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, transaction} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    view |> element("#open-#{transaction.id}") |> render_click()

    assert render_click(view, "remove_transfer", %{"id" => transaction.id}) =~ "Coffee"
  end

  # A selected row can be gone by the time a bulk action lands, and the rest still has to apply.
  test "skips a selected transaction that is already gone", %{
    conn: conn,
    scope: scope,
    attrs: attrs
  } do
    {:ok, gone} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))
    {:ok, kept} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Tea"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => gone.id, "value" => "on"})
    render_click(view, "toggle_select_transaction", %{"id" => kept.id, "value" => "on"})
    {:ok, _deleted} = Transactions.delete_transaction(scope, gone)

    render_click(view, "bulk_review", %{})

    assert {:ok, %{reviewed: true}} = Transactions.get_transaction(scope, id: kept.id)
  end

  test "removes a transfer from the details form", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: scope.user.id,
        external_id: Ecto.UUID.generate(),
        name: "Tartan Bank",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    {:ok, bank_account} =
      Repo.insert(%BankAccount{
        user_id: scope.user.id,
        bank_member_id: bank_member.id,
        external_id: Ecto.UUID.generate(),
        name: "Checking",
        number: "1234",
        balance: Decimal.new("100.00"),
        sub_type: "checking",
        type: "depository"
      })

    {:ok, bank_transaction} =
      Repo.insert(%BankTransaction{
        user_id: scope.user.id,
        bank_account_id: bank_account.id,
        external_id: Ecto.UUID.generate(),
        amount: Decimal.new("5.00"),
        date: ~D[2026-08-15],
        name: "From checking",
        pending: false
      })

    {:ok, out} = Transactions.create_transaction(scope, Map.put(attrs, "name", "To savings"))

    {:ok, into} =
      Transactions.create_transaction(
        scope,
        attrs
        |> Map.put("name", "From checking")
        |> Map.put("amount", "5.00")
        |> Map.put("bank_transaction_id", bank_transaction.id)
      )

    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, into)

    {:ok, view, _html} = live(conn, ~p"/transactions")

    # The drawer names the account the money went to, not the counterpart's own name.
    assert view |> element("#open-#{out.id}") |> render_click() =~ "Checking ••••1234"

    render_click(view, "remove_transfer", %{"id" => out.id})

    assert {:ok, %{transfer_id: nil}} = Transactions.get_transaction(scope, id: out.id)
    assert {:ok, %{transfer_id: nil}} = Transactions.get_transaction(scope, id: into.id)
  end

  test "clears the selection", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, transaction} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    render_click(view, "toggle_select_transaction", %{"id" => transaction.id, "value" => "on"})
    render_click(view, "clear_selection", %{})
    render_click(view, "delete", %{})

    assert [%{name: "Coffee"}] = Transactions.list_transactions(scope)
  end

  test "filters the list by the search box", %{conn: conn, scope: scope, attrs: attrs} do
    {:ok, _coffee} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Coffee"))
    {:ok, _rent} = Transactions.create_transaction(scope, Map.put(attrs, "name", "Rent"))

    {:ok, view, _html} = live(conn, ~p"/transactions")

    html = render_change(view, "search", %{"search" => "coff"})

    assert html =~ "Coffee"
    refute html =~ "Rent"
  end
end

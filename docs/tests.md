# Good and Bad Tests

## Setup

- Tests for code under `lib/spendable/...` use `Spendable.DataCase, async: true` (defined in [test/support/data_case.ex](../test/support/data_case.ex)). It pulls in Hammox, `errors_on/1`, `Spendable.Support.TeslaHelper`, and `verify_on_exit!`.
- Tests for LiveViews and controllers under `lib/spendable_web/...` use `SpendableWeb.ConnCase, async: true` (defined in [test/support/conn_case.ex](../test/support/conn_case.ex)). Note it hands you a bare `conn` - it does **not** build an authenticated session for you. Authenticate by putting the user's id in the session the way the auth controller does: `init_test_session(conn, %{"current_user_id" => user.id})`.
- API controllers under `lib/spendable_web/api/...` authenticate with a bearer token instead. Mint a real one through the context - the same path the sign-in endpoint takes - rather than forging a header:

  ```elixir
  {:ok, api_token} = Accounts.create_api_token(Scope.for_user(user), %{})
  conn = put_req_header(conn, "authorization", "Bearer " <> api_token.token)
  ```

  Assert every API response against the spec with `OpenApiSpex.TestAssertions.assert_schema(response, "Budget", @api_spec)`. The Dart client is generated from that spec, so an unasserted response is a contract that can drift without CI noticing.
- Authentication comes from **scopes**, not tags. Build one the way production does - create the user through `Accounts`, then wrap it:

  ```elixir
  {:ok, user} = Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})
  scope = Scope.for_user(user)
  ```

  Build it inline, or in `setup` when every test in the file needs the same one. The rule that rules out factories rules out a scope-building helper too: two visible lines beat a helper that hides which creation path the test exercised.

## Arranging test data

**There are no factories.** Every record a test needs is created through the context function that
owns it, exactly the way production code creates it. A factory that inserts around the changeset
can build a row the application itself could never produce, and then the test proves nothing about
the real path. Going through the context also means the test breaks when the real creation path
breaks, which is the point.

```elixir
# GOOD: the budget is created the way the app creates budgets
{:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

# BAD: inserts a row the changeset would have rejected, and skips every invariant on the way in
budget = Repo.insert!(%Budget{name: "Groceries", user_id: scope.user.id})
```

Where an arrangement lives, in order of preference. **A test file must not define its own
functions** - no `def`/`defp` helpers in a `*_test.exs`. A per-file helper doesn't compose across
files and stops a test from being readable top-to-bottom. This is enforced by the
[`SpendableCredo.Checks.NoFunctionsInTests`](../credo/lib/spendable_credo/checks/no_functions_in_tests.ex) lint.

1. **`setup_all` block** - for context every test in the file shares (typically a `scope` and a
   budget or two), built once per module. It requires `@moduletag :shared_sandbox`, which shares
   **one** DB sandbox across the whole module, so use it only for data tests read in common, never
   when a test asserts on a result set that must exclude other tests' rows.
2. **`setup` block** - for context that must be isolated per test: data a test mutates, or rows a
   test creates and then asserts are the only ones returned (a list action, an ownership scoping
   check, where `setup_all`'s shared sandbox would leak sibling tests' rows into the result).
3. **`test/support`** - for genuinely cross-cutting machinery: the case templates, response builders
   for mocked HTTP, canned external payloads. This is the only home for a named helper, and it is
   not a home for test *data* - arranging records is what context functions are for.
4. **Inline** - for what makes the test distinct, above all the variable the test changes to prove
   its behavior.

### Where an arrangement belongs

- If it's the **variable the test changes to prove behavior**, it stays **inline and visible** in
  the test body. A reader should see the condition under test without opening another function.
- Context that **every** test in the file needs *identically* belongs in `setup_all`; context that
  must be isolated per test belongs in `setup`.
- **Never hide the call to the function under test.** Setup may arrange data, but the invocation of
  the public API being tested - and the assertion on its result - stays inline and visible in the
  test body.

## Test conventions

- Tests are located directly next to the file they test, not in a separate `test/` tree. The `test/` folder is only for supporting code.
- All tests should use `async: true` (with very rare exceptions).
- We aim for 100% coverage. When true 100% is not possible, use `coveralls` comments to ignore a line or block, including a reason.
- Test actions through the context module (`Spendable.Budgets.get_budget`), never through the action module directly.
- Ownership checks must use the actual valid record ID with a wrong scope. You're testing the authorization check, not the "not found" path.
- Use `Decimal.eq?/2` when comparing Decimals: `assert Decimal.eq?(budget.balance, "10.00")`.
- Assert `is_nil(value)` before and `is_binary(value)` after, rather than just `assert value`.
- Inspect changeset errors with `errors_on(changeset)`, not by reaching into `changeset.errors`.
- Enforce invariants: fix invalid test setups rather than weakening validation to accommodate them.

### The four-test template for an action

Every action that takes a scope and a record gets the same shape:

The scope every test shares is built once in `setup`, through `Accounts` - the only test that builds
a second one is the ownership test, and it builds it inline because the *second user is the variable
under test*.

```elixir
defmodule Spendable.Budgets.Actions.ArchiveBudgetTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Scope

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    %{scope: Scope.for_user(user)}
  end

  test "archives a budget", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    assert {:ok, %Budget{archived_at: %DateTime{}}} = Budgets.archive_budget(scope, budget)
  end

  test "errors if the budget is already archived", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, budget} = Budgets.archive_budget(scope, budget)

    assert {:error, :already_archived} = Budgets.archive_budget(scope, budget)
  end

  test "errors if the budget belongs to a different user", %{scope: scope} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, budget} = Budgets.create_budget(Scope.for_user(other_user), %{"name" => "Groceries"})

    assert {:error, :not_authorized} = Budgets.archive_budget(scope, budget)
  end

  test "archived budgets are excluded from the list", %{scope: scope} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
    {:ok, _archived} = Budgets.archive_budget(scope, budget)

    refute budget.id in Enum.map(Budgets.list_budgets(scope), & &1.id)
  end
end
```

## LiveView test conventions

- Use element-based `render_click`, not event-based, except in specific JS-limited scenarios:

  ```elixir
  # preferred
  view |> element("button[phx-click=action]") |> render_click()

  # not preferred
  render_click(view, "action", %{})
  ```

- Clicking an element already asserts its existence. A separate `has_element?` assertion is redundant.
- If the LiveView has a `phx-change="validate"` handler, `render_submit` alone won't cover it. You need a separate `render_change` call to exercise the validate path.
- Test create flow: click new -> render_change with invalid -> render_submit assert error -> render_change with valid -> render_submit -> refute the form.
- Test edit flow: click edit -> assert the form -> render_change with valid -> render_submit -> refute the form.
- Include `Repo.get` calls to verify things are persisted. Repo calls in tests are the only exception to the "no Repo in LiveViews" rule.
- `render_async(view, 1000)` - pass a timeout value since the wait is not guaranteed.
- Ownership tests don't belong in LiveView tests; they belong on the action.

## Good Tests

**Integration-style**: Test through real interfaces, not mocks of internal parts.

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```elixir
# BAD: mocks an internal function
test "create_budget calls Repo.insert" do
  Hammox.expect(Spendable.Repo, :insert, fn _changeset -> {:ok, %Budget{}} end)
  Budgets.create_budget(scope, %{"name" => "X"})
end
```

```elixir
# BAD: asserts on raw HTML the template happens to render
assert render(view) =~ ~s(<button class="btn-primary" phx-click="edit">Edit</button>)

# GOOD: asserts the element exists by its semantic ID/selector
assert has_element?(view, "button[phx-click=edit]")
```

Red flags:

- Mocking internal collaborators
- Testing private functions
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of the interface

```elixir
# BAD: bypasses the interface to verify
test "create_budget writes to budgets table" do
  Budgets.create_budget(scope, %{"name" => "Groceries"})
  [row] = Repo.all(from b in "budgets", where: b.name == "Groceries", select: %{id: b.id})
  assert row
end

# GOOD: verify through the same public API a caller would use
test "created budget is listable" do
  {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
  assert budget.id in Enum.map(Budgets.list_budgets(scope), & &1.id)
end
```

## Mocking external boundaries

Mock at the *edges* of the system - outbound HTTP and Google Pub/Sub - never collaborators inside
the context under test.

**External HTTP** goes through Tesla, behind the `Spendable.Behaviour.Tesla` behaviour. Set
expectations on `TeslaMock` (Hammox) and build responses with `TeslaHelper.response/1`. Canned
Plaid payloads live in `test/support/test_data/`.

```elixir
# GOOD: mocks the outbound Plaid call at the Tesla boundary
expect(TeslaMock, :call, fn %{url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
  TeslaHelper.response(body: TestData.accounts())
end)
```

**Google Pub/Sub** publishing goes through `Spendable.Behaviour.PubSub`; set expectations on
`PubSubMock`.

Rules of thumb:

- Mock external HTTP via `TeslaMock`; lean on `test/support/test_data/` for realistic payloads.
- Never mock `Spendable.Repo`, action modules directly, or anything else inside the context under test.

## Assert on the shape inside the pattern match

When checking the structure of a return value, put the expected fields directly into the `assert`'s
pattern rather than binding intermediates and asserting on them afterward. The pattern doubles as
the spec for the expected response.

```elixir
# GOOD: the pattern itself is the spec
assert [%Budget{name: "Groceries"}, %Budget{name: "Rent"}] = Budgets.list_budgets(scope)
```

```elixir
# BAD: bind via underscore placeholders, then re-assert on the bound list
assert [_first, _second] = budgets = Budgets.list_budgets(scope)
assert Enum.map(budgets, & &1.name) == ["Groceries", "Rent"]
```

This rule is enforced for the most common form by the
[`SpendableCredo.Checks.InlineListShapeInAssert`](../credo/lib/spendable_credo/checks/inline_list_shape_in_assert.ex)
lint, which flags `[_x, _y] = var` placeholder lists inside `assert`.

Decimal values are the legitimate exception. `Decimal.new("30.0")` and `Decimal.new("30.00")` are
numerically equal but won't pattern-match each other, so bind the decimal field in the pattern and
assert with `Decimal.eq?` afterward.

## Module-level fixtures with `setup_all`

For action tests that need a non-trivial graph of records (budgets, transactions, allocations) to
exercise a single function under different inputs, build the fixture **once per module** with
`@moduletag :shared_sandbox` + `setup_all`, and write each `test` block as a single call to the
function under test.

Only reach for this when the tests **read** the shared fixtures. `@moduletag :shared_sandbox` drops
per-test transaction isolation, so every row inserted is visible to every test in the module. A test
that creates its own rows and then asserts they are the only ones returned belongs in a per-test
`setup` block or inline setup, not here.

Rules:

- All record creation lives in `setup_all`. Tests do not create their own data - they pattern-match what they need from the context map.
- `setup_all` returns only the handles tests need to call the function under test.
- Each `test` block calls the function under test **exactly once** and asserts on the slice of the result it cares about. If you need a different scenario, write a new `test` block.

Why:

- A single `setup_all` runs once per module instead of once per test, so a fixture-heavy module stays fast as you add scenarios.
- Reading a test becomes "what input, what assertion".
- One call per test means a failure points at exactly one scenario.

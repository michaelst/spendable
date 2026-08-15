# Standards

This file contains the standards for how we write code for Spendable. All standards are listed here but may link out to additional files for more detailed information. Test-specific standards live in [docs/tests.md](tests.md).

## Mise

We use Mise to manage our development environment and ensure all developers are running on the same version of all tools.

## Contexts

- We organize all functionality into contexts that are logically related. Spendable has four: `Accounts`, `Budgets`, `Transactions`, and `Banks`.
- Contexts can only call to the top level of other contexts. Anything outside of the banks context must call functions available on the `Spendable.Banks` module, never reaching into another context's internals.
- Never `import` or `alias` another context's internal modules (its actions, utils, clients, etc.). Reach another context only through its top-level module, then go through its public API. Schemas are the one exception: a schema may be aliased from any context. This is enforced by the custom Credo check `SpendableCredo.Checks.NoActionOrUtilAlias`.
- The context module uses `defdelegate` to expose action functions, and does nothing else. Never alias an action module from another context - that means you are calling the action directly instead of through the context.
- Utils are never added to the context module. The context module only exposes functions to other contexts; utils are internal and imported directly into action modules.

### Scope

- `Spendable.Scope` carries the caller. It is built one of two ways: `Scope.for_user/1` for a signed-in user, and `Scope.for_system/1` for work the user did not initiate - the bank sync pipeline and inbound Plaid webhooks.
- Spendable has no roles or permissions. Authorization is ownership: every row belongs to exactly one user, and an action is authorized when the record's `user_id` matches the scope's.

### Actions

- Actions are the functions that we expose to other contexts and are located in the actions folder of the context. Each action lives in its own file and is exposed via `defdelegate` on the context module.
- Actions contain all of the code necessary to perform the action, including database calls.
- The action's module name, the function it exposes, and its file name must all match the action (e.g. `Actions.CreateBudget`, `create_budget/2`, `create_budget.ex`). This is enforced by the custom Credo check `SpendableCredo.Checks.ActionModuleNaming`.
- User facing actions should always accept scope as the first argument.
- When an action takes a scope and a record, pin `user_id` between them in the function head to enforce ownership. A mismatch returns `{:error, :not_authorized}`:

  ```elixir
  def update_budget(
        %Scope{user: %{id: user_id}} = scope,
        %Budget{user_id: user_id} = budget,
        attrs
      ) do
  ```

- Never use the `user_id` from attrs. Always take it from the scope.
- Always include `user_id` in queries even when pattern matching already validates it. Pattern matching guards the gate (no DB hit if unauthorized); the query filter ensures index usage and guarantees the database only touches rows for that user.
- Create dedicated actions with required inputs instead of overloading a generic action with optional params. Build required filters into the base query to keep actions straightforward.
- When a listing differs only by a filter, add the filter to the existing `list_*` action rather than creating a near-duplicate action. Reserve dedicated actions for distinct operations with their own required inputs.
- Return the post-operation record. After an action mutates a record, return the updated struct, not the pre-mutation one, so callers don't read stale fields.
- Avoid per-row database calls in loops and sync callbacks. Load what you need up front (preload, or one query) instead of hitting the DB inside an `Enum` iteration - a large Plaid sync can otherwise issue hundreds of queries.
- Wrap related operations in a single Ecto transaction so that a partial failure rolls back the whole thing.
- Use `build_*` as the function name when not persisting to the DB.
- Below is an example of a context module and an action module and the formatting they should follow.

```elixir
defmodule Spendable.Budgets do
  alias Spendable.Budgets.Actions

  defdelegate create_budget(scope, attrs), to: Actions.CreateBudget
end

defmodule Spendable.Budgets.Actions.CreateBudget do
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo

  def create_budget(scope, attrs) do
    %Budget{user_id: scope.user.id}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end
end
```

### Schemas

- The schema file is the source of truth for everything about a data model.
- Schemas contain the ecto schema and changeset for each data model.
- Schemas may also contain functions for working directly with the schema.
- Schemas can be referenced directly from other contexts.
- Schemas should define a custom primary key using the `UXID` type.
- Schemas should `use Spendable.Schema`.
- Fields that should not be user defined such as `user_id` are set from scope and not castable in a changeset. For example: `%Budget{user_id: scope.user.id} |> Budget.changeset(attrs)`.
- Fields containing secrets such as Plaid access tokens must be redacted and never cast from user input: `field :plaid_token, :string, redact: true`.
- Put field logic (casting, nilifying related fields) in changesets, not ad-hoc in action code. This prevents future callers from bypassing the logic.
- When values come from user input, use `validate_relationships/2` in changesets so a foreign key cannot point at another user's record.
- Prefer Ecto's built-in validators (`validate_format`, `validate_length`, `validate_number`, ...) over hand-rolled validation logic.
- `cast_assoc` is for children resources. Use with caution - it's a way to bypass actions.
- Don't auto-nilify foreign keys on delete (`on_delete: :nilify_all`) without thinking through the product implications.
- Enforce invariants, don't hack around invalid state. When validation seems to break things, fix the invalid data/tests rather than weakening the validation. Don't stack hacks.
- Don't build a schema's changeset + `Repo` from outside its owning context to persist data - that bypasses authorization and business logic. Always go through the context's public API. Building a changeset for form display in a LiveView is fine; the boundary is `Repo` calls.

```elixir
defmodule Spendable.Accounts.Schemas.User do
  use Spendable.Schema

  @primary_key {:id, UXID, autogenerate: true, prefix: "usr"}
  schema "users" do
    ...
  end

  def changeset(user \\ %__MODULE__{}, attrs) do
    ...
  end
end
```

### Utils

- Utils follow a similar pattern as actions, except they are not exposed and can be referenced only from inside the context.
- To use a util it should be imported into the action module and called directly.
- Utils are for **complex logic that needs to be reused**. Both halves have to hold: used by one action only, it is a private function in that action; simple enough to read inline, it stays inline no matter how many actions repeat it. A `where: is_nil(record.archived_at)` is not a util however often it appears - a multi-query batch calculation is.

```elixir
defmodule Spendable.Banks.Actions.SyncTransaction do
  import Spendable.Banks.Utils.FormatTransaction

  def sync_transaction(transaction) do
    transaction
    |> format_transaction()
    |> do_sync()
  end
end
```

## Code Style

### Elixir conventions

- Use `and` for boolean expressions, `&&` for truthy values. `and` is stricter.
- Never use `{}` grouped aliases. One alias per line.
- Never use the em-dash character. Always use `-` instead.
- Private functions go after public functions in a module. This is enforced by the custom Credo check `SpendableCredo.Checks.PrivateFunctionsLast`.
- Use standard, consistent error tuples: `{:error, :not_authorized}`, `{:error, :not_found}`, etc. See the "Pattern matching" section below for how to match expected shapes.
- `with` clauses with only one clause should use `then/2` instead, but only when already in a pipe chain.
- Prefer `%{struct | key: value}` over `Map.put/3` for updates. The update syntax enforces existing keys and preserves struct integrity.
- Pure functions that compute a value should have `calculate` in the name (not `compute`).
- Prefer letting unexpected errors crash rather than silently handling them. Don't handle errors you don't know you have.
- Prefer `cond` over extracting functions or multiple nested case/if.
- Never nest a `case` inside another `case`. When chaining pattern matches that depend on the previous one succeeding, use `with` instead.
- Pass structs down, not IDs, when the caller already has the full struct. Favor structs as arguments for clarity, and use the structs being matched on in function clauses.
- Don't add empty lines unnecessarily. Let the formatter handle spacing.
- Use the standard library for dates and times (`Date.beginning_of_month/1`, `Date.shift/2`, `Calendar.strftime/2`). We do not depend on Timex.

### Prefer inline logic over private functions

- Default to writing logic inline in the function that uses it. Don't extract a private function just because a block of code "could" be named - naming has a cost (extra indirection, harder to read top-to-bottom).
- Reach for a private function when it genuinely simplifies a larger function. The canonical case: the body of an `Enum.reduce/3` (or similar) callback - pulling the per-element logic into a named private function makes the reduce itself readable at a glance.
- If a function is only used once, consider inlining it.

### Pattern matching

- Match the exact shapes you expect and let anything else crash (`CaseClauseError` / `FunctionClauseError`). An unexpected shape is a bug - crashing surfaces it instead of letting `{:ok, garbage}` flow downstream.
- The crash-on-unexpected-shape rule is for *internal* invariants - values your own code produced. For values crossing an external boundary (Plaid payloads, request params), expect variability: match the shape you want first, then fall through a general clause to a safe default instead of crashing.
- Prefer positive type guards (`is_binary`, `is_integer`, `is_map`, `is_struct(x, DateTime)`, ...) over negative ones (`not is_nil`). This is enforced by the custom Credo check `SpendableCredo.Checks.PreferPositiveTypeGuard` (Ecto queries, where `not is_nil(field)` means `IS NOT NULL`, are exempt).
- Order `case`/function clauses specific -> general. A variable-binding pattern matches anything, so it must come last (or be constrained with a guard); otherwise it shadows the clauses below it. This is enforced by the custom Credo check `SpendableCredo.Checks.NilsLastInCase`, and CI compiles with `--warnings-as-errors`.

```elixir
# GOOD: each clause matches an expected shape
case Repo.get_by(Budget, user_id: user_id, name: "Spendable") do
  %Budget{} = budget -> {:ok, budget}
  nil -> {:error, :not_found}
end
```

### Comments

- Don't write comments that describe *what* the code is doing - the code already says that, and such comments rot as the code changes.
- Only add a comment to explain *why* a decision was made, and only when that reasoning isn't intuitive from the code itself (a non-obvious workaround, a deliberate deviation, or a constraint that isn't visible locally).
- **Anything said about a function goes in its `@doc`, not a `#` comment above it.** `#` is for a line or block *inside* a function body.
- Never `@doc` a `defdelegate`. The context module is a delegate table and nothing else; what there is to say about an action belongs on the action itself.
- Keep every comment to one or two lines. Never a paragraph. This includes `@moduledoc` and `@doc` bodies.
- Exceptions, where a `#` comment is the only option: private functions (`@doc` on a `defp` warns), and controllers and LiveViews, which get no `@doc`/`@moduledoc` at all (see below).
- Changesets get no `@doc`. What a changeset casts and validates is the code itself; if one line of it is genuinely surprising, comment that line.

## Integrating with External Services

- When storing ids from external services we should use the `external_id` field in the schema.
- If a table can be used for multiple services a `provider` field should be used to differentiate between the different services.
- A separate module should be created to handle the API calls to the external service, this module should contain minimal logic. These client modules live in the context's `clients/` folder and handle API communication, not business logic.
- Never log a secret. Access tokens, API keys and public tokens do not go into `Logger` calls at any level.

## LiveViews

- Reserve `handle_params` for `patch` navigation (same LiveView). Use `mount` for full navigations.
- Don't use `@impl true` in LiveViews. We don't do that even though we could.
- Repo calls should never exist in LiveViews (the only exception is in tests).
- Business logic doesn't live in LiveViews. Abstract complexity out and push it to actions. `handle_event` should ideally call a single action and then change some assigns.
- Use changesets to keep state when possible. Rarely do you not need a changeset. If you start handling errors manually in a LiveView, you are likely missing a chance to use a changeset.
- Don't wrap changesets in `to_form`. Assign the changeset directly and let `<.form>` handle the conversion internally.
- When `Repo.update` or `Repo.insert` fails validation, the returned changeset already has its action set. Only set the action manually for client-side-only validation in `phx-change` handlers.
- Nested rows (a transaction's allocations, a split's lines) use `inputs_for` with `sort_param`/`drop_param` rather than hand-rolled add/remove event handlers.
- In `for` loops, extract a function for the element and pass the assigns down. If a private function is only used once, inline it.
- Modals go outside the app layout. When deleting, use a modal for confirmation.
- Use `:if={}` syntax, not `<%= if @condition do %>`.
- Don't put `cond`/`case` branching in HEEx templates - it makes them hard to read. Encode the variants as assigns (or pattern-match the assigns in a function component) and render off those.
- Use clear `show_*` conditions, not implicit conditions.
- Use underscores in `phx-value-*` attributes: `phx-value-budget_id`, not `phx-value-budget-id`.
- "Errors only show on submit", but `phx-change` should still be used to allow recovery on reconnect; use `phx-debounce` to save on bandwidth/unnecessary work.
- Follow existing patterns on the same page/module.

## Components

- We create all components as their own file, the component function name and file name should match for easy searching.
- Components `use SpendableWeb, :html` and declare their inputs with `attr/3` (and `slot/2` where needed) so the API is explicit at the call site.
- Components are exposed by using defdelegate in the `core_components.ex` file, which is automatically imported in our live views.
- Always check for existing components before creating new ones (especially SVGs).
- Use struct types instead of `:map` in component attr declarations for better type checking.
- Lists should always be sortable.
- Use a toggle input for on/off state (enabled, active). Use a checkbox for inclusion in a set/selection.

## Controllers

- Focus on authentication, authorization, and input validation.
- Never use `user_id` from user input. Always take it from the scope.
- Don't add `@doc`/`@moduledoc` to controllers or LiveViews. They aren't a documented public API, and the route plus action name already convey intent.

## Migrations

- Always use the `text` or `citext` types for strings.
- Don't specify `type:` on references. We have that as a default in our config (`migration_primary_key: [type: :text]`).
- Don't specify `primary_key` when adding a table. We have that as a default in our config.
- Build indexes on existing tables with `concurrently: true`, plus `@disable_ddl_transaction true` and `@disable_migration_lock true` in the migration. A plain `CREATE INDEX` takes a `SHARE` lock that blocks every write to the table until it finishes. An index created alongside its table in the same migration doesn't need this.

## Hooks

- Each hook should be in its own file inside the `assets/js/hooks` folder.
- Hooks are then imported into the `assets/js/app.js` file.

## Tests and Coverage

See [docs/tests.md](tests.md) for the full test standards. In summary:

- The `test` folder is only used for supporting code, not actual tests.
- Tests should be located directly next to the file they are testing.
- All code should be covered by tests, we aim for 100% coverage. True 100% coverage is not always possible, and in those cases we use `coveralls` comments to ignore a line or block, with a reason describing why it is not possible to test.
- `async: true` should be used for all tests (with very rare exceptions).
- Testing actions should test through the interface of the context, not by calling the action function directly.
- **There are no factories.** Tests create every record through context functions, the same way production code does.

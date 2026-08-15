defmodule SpendableCredo.Checks.NoFunctionsInTests do
  @moduledoc """
  Disallows `def`/`defp` helpers defined directly in a test module
  (`*_test.exs`).

  A test module should read top-to-bottom without jumping to a helper. Arrange
  data with the most shared mechanism that fits instead of a per-file function:

    * shared context every test needs -> `setup_all` (or `setup` when a test
      needs per-test isolation);
    * cross-cutting machinery reused across *multiple* files (case templates,
      mocked HTTP payloads) -> `test/support`;
    * whatever makes a single test distinct -> inline in the test body.

  A private helper defined in the test module itself is never the right home: if
  only one test uses it, inline it; if several do, it belongs in `setup`.

      # bad - per-file helper hides which creation path the test exercised
      defp budget_with_allocation(scope) do
        {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
        {:ok, _transaction} = Transactions.create_transaction(scope, allocating_to(budget))
        budget
      end

      # good - shared context in setup, construction inline through the context
      setup do
        {:ok, user} =
          Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

        %{scope: Scope.for_user(user)}
      end

      test "...", %{scope: scope} do
        {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})
        {:ok, transaction} = Transactions.create_transaction(scope, allocating_to(budget))
        # ...
      end

  Functions inside a **nested** module declared in the test file (a test-double
  LiveView, an embedded schema for changeset tests, a module exercising a
  decorator) are allowed - those fixtures genuinely need functions and have no
  setup/inline alternative. Only helpers in the test module body are flagged.
  """

  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      Test modules (`*_test.exs`) must not define `def`/`defp` helpers in their
      body. Move shared setup into `setup_all`/`setup`, lift cross-cutting
      machinery into `test/support`, or inline whatever is distinct to a single
      test. Functions inside a nested fixture module are allowed.

          # bad
          defp build_scope, do: Scope.for_user(create_user())

          # good - shared across every test in the module
          setup do
            {:ok, user} =
              Accounts.upsert_user_from_oauth(%{
                external_id: Ecto.UUID.generate(),
                provider: "google"
              })

            %{scope: Scope.for_user(user)}
          end
      """
    ]

  @impl true
  def run(%SourceFile{filename: filename} = source_file, params) do
    if test_file?(filename) do
      ctx = Context.build(source_file, params, __MODULE__, %{})

      result =
        source_file
        |> SourceFile.ast()
        |> unwrap_block()
        |> Enum.filter(&match?({:defmodule, _meta, [_alias, [do: _body]]}, &1))
        |> Enum.reduce(ctx, &check_module_body(&1, &2))

      result.issues
    else
      []
    end
  end

  defp test_file?(filename), do: String.ends_with?(filename, "_test.exs")

  # The statements of a `__block__`, or the lone node wrapped in a list. Used for
  # both the file's top-level nodes and a module's body.
  defp unwrap_block({:__block__, _meta, statements}), do: statements
  defp unwrap_block(node), do: [node]

  # Flag the `def`/`defp` statements in a top-level module's own body. We
  # deliberately do not recurse into nested modules - a nested fixture module
  # (test-double LiveView, embedded schema, decorator target) may define
  # functions.
  defp check_module_body({:defmodule, _meta, [_alias, [do: body]]}, ctx) do
    body
    |> unwrap_block()
    |> Enum.reduce(ctx, &check_statement(&1, &2))
  end

  defp check_statement({:def, meta, [head | _rest]}, ctx),
    do: add_issue(ctx, meta, "def", name(head))

  defp check_statement({:defp, meta, [head | _rest]}, ctx),
    do: add_issue(ctx, meta, "defp", name(head))

  defp check_statement(_other, ctx), do: ctx

  defp name({:when, _meta, [head | _guards]}), do: name(head)
  defp name({function_name, _meta, _args}) when is_atom(function_name), do: function_name
  defp name(_other), do: nil

  defp add_issue(ctx, meta, keyword, function_name) do
    label = if function_name, do: "`#{keyword} #{function_name}`", else: "`#{keyword}`"

    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Test modules must not define helper functions. Remove #{label} and move the logic to " <>
            "`setup_all`/`setup` (shared context), `test/support` (a fixture reused across " <>
            "files, e.g. `user_scope`), or inline it into the test that needs it.",
        trigger: keyword,
        line_no: meta[:line]
      )
    )
  end
end

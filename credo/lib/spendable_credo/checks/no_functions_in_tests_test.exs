defmodule SpendableCredo.Checks.NoFunctionsInTestsTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.NoFunctionsInTests

  test "allows setup_all for shared context" do
    """
    defmodule Spendable.FooTest do
      use Spendable.DataCase, async: true

      setup_all do
        %{scope: Scope.for_user(user)}
      end

      test "does a thing", %{scope: scope} do
        assert scope
      end
    end
    """
    |> to_source_file("lib/spendable/foo_test.exs")
    |> run_check(NoFunctionsInTests)
    |> refute_issues()
  end

  test "allows setup blocks" do
    """
    defmodule Spendable.FooTest do
      use Spendable.DataCase, async: true

      setup do
        %{scope: Scope.for_user(user)}
      end

      test "does a thing", %{scope: scope} do
        assert scope
      end
    end
    """
    |> to_source_file("lib/spendable/foo_test.exs")
    |> run_check(NoFunctionsInTests)
    |> refute_issues()
  end

  test "flags a private helper in a test file" do
    """
    defmodule Spendable.FooTest do
      use Spendable.DataCase, async: true

      test "does a thing" do
        assert build_scope()
      end

      defp build_scope, do: Scope.for_user(user)
    end
    """
    |> to_source_file("lib/spendable/foo_test.exs")
    |> run_check(NoFunctionsInTests)
    |> assert_issue(fn issue ->
      assert issue.trigger == "defp"
      assert issue.message =~ "build_scope"
      assert issue.message =~ "setup_all"
    end)
  end

  test "flags a public helper in a test file" do
    """
    defmodule Spendable.FooTest do
      use Spendable.DataCase, async: true

      def budget_with_allocation(scope) do
        Budgets.create_budget(scope, %{"name" => "Groceries"})
      end

      test "does a thing", %{scope: scope} do
        assert budget_with_allocation(scope)
      end
    end
    """
    |> to_source_file("lib/spendable/foo_test.exs")
    |> run_check(NoFunctionsInTests)
    |> assert_issue(fn issue ->
      assert issue.trigger == "def"
      assert issue.message =~ "budget_with_allocation"
    end)
  end

  test "flags a helper defined with a guard" do
    """
    defmodule Spendable.FooTest do
      use Spendable.DataCase, async: true

      defp normalize(value) when is_binary(value), do: value

      test "does a thing" do
        assert normalize("x")
      end
    end
    """
    |> to_source_file("lib/spendable/foo_test.exs")
    |> run_check(NoFunctionsInTests)
    |> assert_issue(fn issue ->
      assert issue.message =~ "normalize"
    end)
  end

  test "flags each helper separately" do
    """
    defmodule Spendable.FooTest do
      use Spendable.DataCase, async: true

      defp one, do: 1
      defp two, do: 2

      test "does a thing" do
        assert one() + two() == 3
      end
    end
    """
    |> to_source_file("lib/spendable/foo_test.exs")
    |> run_check(NoFunctionsInTests)
    |> assert_issues(fn issues ->
      assert length(issues) == 2
    end)
  end

  test "allows functions inside a nested fixture module" do
    """
    defmodule Spendable.FooTest do
      use Spendable.DataCase, async: true

      defmodule TestLive do
        use Phoenix.LiveView

        def mount(_params, _session, socket), do: {:ok, socket}
        def render(assigns), do: ~H"<div></div>"
      end

      test "does a thing" do
        assert TestLive
      end
    end
    """
    |> to_source_file("lib/spendable/foo_test.exs")
    |> run_check(NoFunctionsInTests)
    |> refute_issues()
  end

  test "flags a body helper while allowing a sibling nested fixture module" do
    """
    defmodule Spendable.FooTest do
      use Spendable.DataCase, async: true

      defmodule TestSchema do
        use Ecto.Schema

        def changeset(transaction, attrs), do: cast(transaction, attrs, [])
      end

      defp build_scope, do: Scope.for_user(user)

      test "does a thing" do
        assert build_scope()
      end
    end
    """
    |> to_source_file("lib/spendable/foo_test.exs")
    |> run_check(NoFunctionsInTests)
    |> assert_issue(fn issue ->
      assert issue.trigger == "defp"
      assert issue.message =~ "build_scope"
    end)
  end

  test "flags a dynamically named def without crashing on the name" do
    """
    defmodule Spendable.FooTest do
      use Spendable.DataCase, async: true

      def unquote(:generated)(), do: :ok

      test "does a thing" do
        assert generated() == :ok
      end
    end
    """
    |> to_source_file("lib/spendable/foo_test.exs")
    |> run_check(NoFunctionsInTests)
    |> assert_issue(fn issue ->
      assert issue.trigger == "def"
      assert issue.message =~ "must not define"
    end)
  end

  test "ignores functions in non-test support files" do
    """
    defmodule Spendable.TestSupport do
      def user_scope(opts), do: build_scope(opts)

      defp build_scope(opts), do: opts
    end
    """
    |> to_source_file("test/support/test_support.ex")
    |> run_check(NoFunctionsInTests)
    |> refute_issues()
  end

  test "ignores functions in production code" do
    """
    defmodule Spendable.Foo do
      def bar, do: :ok

      defp baz, do: :ok
    end
    """
    |> to_source_file("lib/spendable/foo.ex")
    |> run_check(NoFunctionsInTests)
    |> refute_issues()
  end
end

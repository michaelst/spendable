defmodule SpendableCredo.Checks.PrivateFunctionsLastTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.PrivateFunctionsLast

  describe "PrivateFunctionsLast" do
    test "reports a public function defined after a private one" do
      """
      defmodule Test do
        def a, do: helper()
        defp helper, do: :ok
        def b, do: :ok
      end
      """
      |> to_source_file()
      |> run_check(PrivateFunctionsLast)
      |> assert_issue()
    end

    test "does not report when all public functions come first" do
      """
      defmodule Test do
        def a, do: helper()
        def b, do: :ok
        defp helper, do: :ok
      end
      """
      |> to_source_file()
      |> run_check(PrivateFunctionsLast)
      |> refute_issues()
    end

    test "does not report a module with only public functions" do
      """
      defmodule Test do
        def a, do: :ok
        def b, do: :ok
      end
      """
      |> to_source_file()
      |> run_check(PrivateFunctionsLast)
      |> refute_issues()
    end

    test "does not report a module with only private functions" do
      """
      defmodule Test do
        defp a, do: :ok
        defp b, do: :ok
      end
      """
      |> to_source_file()
      |> run_check(PrivateFunctionsLast)
      |> refute_issues()
    end

    test "does not report a module whose body is a single function" do
      """
      defmodule Test do
        def a, do: :ok
      end
      """
      |> to_source_file()
      |> run_check(PrivateFunctionsLast)
      |> refute_issues()
    end

    test "does not report multiple clauses of one public function before privates" do
      """
      defmodule Test do
        def a(:x), do: 1
        def a(:y), do: 2
        defp helper, do: :ok
      end
      """
      |> to_source_file()
      |> run_check(PrivateFunctionsLast)
      |> refute_issues()
    end

    test "reports each public clause defined after a private function" do
      """
      defmodule Test do
        def a, do: :ok
        defp helper, do: :ok
        def b(:x), do: 1
        def b(:y), do: 2
      end
      """
      |> to_source_file()
      |> run_check(PrivateFunctionsLast)
      |> assert_issues(fn issues -> length(issues) == 2 end)
    end

    test "evaluates nested modules independently" do
      """
      defmodule Outer do
        def a, do: :ok
        defp helper, do: :ok
        def c, do: :ok

        defmodule Inner do
          def b, do: :ok
          defp inner_helper, do: :ok
        end
      end
      """
      |> to_source_file()
      |> run_check(PrivateFunctionsLast)
      |> assert_issue(fn issue ->
        # Only Outer.c (a public function after a private one) is flagged; the
        # clean Inner module is unaffected, proving state does not leak between
        # module bodies.
        match?(%{line_no: 4, scope: "Outer.c"}, issue)
      end)
    end
  end
end

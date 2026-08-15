defmodule SpendableCredo.Checks.NilsLastInCaseTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.NilsLastInCase

  describe "NilsLastInCase" do
    test "reports issue when nil is first pattern" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            nil -> :nothing
            result -> {:ok, result}
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> assert_issue()
    end

    test "reports issue when nil is in the middle" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            :error -> :handle_error
            nil -> :nothing
            result -> {:ok, result}
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> assert_issue()
    end

    test "does not report when nil is last pattern" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            result -> {:ok, result}
            nil -> :nothing
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> refute_issues()
    end

    test "does not report when nil is the only pattern" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            nil -> :nothing
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> refute_issues()
    end

    test "does not report when there is no nil pattern" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            %{name: name} -> {:ok, name}
            _ -> :error
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> refute_issues()
    end

    test "reports issue when nil is first with struct patterns" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            nil -> %__MODULE__{user: user}
            user -> %__MODULE__{user: user}
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> assert_issue()
    end

    test "reports issue when nil is first in inline case" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            nil -> 1
            number -> number + 1
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> assert_issue()
    end

    test "allows nil last with guard" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            id when is_binary(id) -> {:ok, id}
            nil -> :error
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> refute_issues()
    end

    test "reports nil first even with guards on other clauses" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            nil -> :create
            id when is_binary(id) -> :update
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> assert_issue()
    end

    test "reports issue when nil pattern with guard is first" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            nil when is_atom(value) -> :nothing
            result -> {:ok, result}
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> assert_issue()
    end

    test "does not report when nil pattern with guard is last" do
      """
      defmodule Test do
        def foo(value) do
          case value do
            result -> {:ok, result}
            nil when is_atom(value) -> :nothing
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(NilsLastInCase)
      |> refute_issues()
    end
  end

  test "does not report with pipe into case" do
    """
    defmodule Test do
      def foo(value) do
        value
        |> case do
          result -> {:ok, result}
          nil when is_atom(value) -> :nothing
        end
      end
    end
    """
    |> to_source_file()
    |> run_check(NilsLastInCase)
    |> refute_issues()
  end

  test "does report with pipe into case" do
    """
    defmodule Test do
      def foo(value) do
        value
        |> case do
          nil when is_atom(value) -> :nothing
          result -> {:ok, result}
        end
      end
    end
    """
    |> to_source_file()
    |> run_check(NilsLastInCase)
    |> refute_issues()
  end
end

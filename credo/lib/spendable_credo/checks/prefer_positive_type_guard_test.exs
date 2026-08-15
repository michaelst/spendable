defmodule SpendableCredo.Checks.PreferPositiveTypeGuardTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.PreferPositiveTypeGuard

  describe "PreferPositiveTypeGuard" do
    test "reports `not is_nil` in an if" do
      """
      defmodule Test do
        def foo(value) do
          if not is_nil(value) do
            value
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> assert_issue()
    end

    test "reports `not is_nil` in a boolean expression" do
      """
      defmodule Test do
        def foo(record) do
          not is_nil(record.bank_transaction) && delete(record.bank_transaction)
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> assert_issue()
    end

    test "reports `not is_nil` in a guard" do
      """
      defmodule Test do
        def foo(value) when not is_nil(value), do: value
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> assert_issue()
    end

    test "does not report a positive type guard" do
      """
      defmodule Test do
        def foo(value) do
          if is_struct(value, DateTime) do
            value
          end
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> refute_issues()
    end

    test "does not report a bare is_nil" do
      """
      defmodule Test do
        def foo(value) do
          if is_nil(value), do: :missing
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> refute_issues()
    end

    test "does not report `not is_nil` inside a keyword-form Ecto query" do
      """
      defmodule Test do
        import Ecto.Query

        def query do
          from budget in Budget, where: not is_nil(budget.archived_at)
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> refute_issues()
    end

    test "does not report `not is_nil` inside a piped Ecto where" do
      """
      defmodule Test do
        import Ecto.Query

        def query(query) do
          where(query, [je], not is_nil(je.approved_at))
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> refute_issues()
    end

    test "does not report `not is_nil` inside a dynamic" do
      """
      defmodule Test do
        import Ecto.Query

        def filter do
          dynamic([jel, je], not is_nil(je.approved_at))
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> refute_issues()
    end

    test "still reports a non-query `not is_nil` in the same module as a query" do
      """
      defmodule Test do
        import Ecto.Query

        def query do
          from budget in Budget, where: not is_nil(budget.archived_at)
        end

        def check(record) do
          if not is_nil(record.deleted_at), do: :deleted
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> assert_issue()
    end

    test "does not report `not is_nil` inside a qualified Ecto.Query.where call" do
      """
      defmodule Test do
        def query(query) do
          Ecto.Query.where(query, [je], not is_nil(je.approved_at))
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> refute_issues()
    end

    test "does not report `not is_nil` in a query when Ecto.Query is in scope via use Spendable.Schema" do
      """
      defmodule Test do
        use Spendable.Schema

        def query(query) do
          where(query, [je], not is_nil(je.approved_at))
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> refute_issues()
    end

    test "reports `not is_nil` passed to a local function named like a query DSL" do
      """
      defmodule Test do
        def where(value), do: value

        def check(value) do
          where(not is_nil(value))
        end
      end
      """
      |> to_source_file()
      |> run_check(PreferPositiveTypeGuard)
      |> assert_issue()
    end
  end
end

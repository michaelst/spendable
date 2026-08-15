defmodule SpendableCredo.Checks.InlineListShapeInAssertTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.InlineListShapeInAssert

  test "flags `[_first, _second] = var` inside assert with map wrapper" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert %{metrics: [_first, _second] = metrics} = call()
        assert Enum.map(metrics, & &1.name) == ["A", "B"]
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> assert_issue(fn issue ->
      assert issue.message =~ "expected element shape"
      assert issue.message =~ "spec"
    end)
  end

  test "flags `[_first, _second] = var` inside assert with map wrapper - different lines" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert %{metrics: [_first, _second] = metrics} = call()

        assert true
        refute false

        assert Enum.map(metrics, & &1.name) == ["A", "B"]
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> assert_issue(fn issue ->
      assert issue.message =~ "expected element shape"
      assert issue.message =~ "spec"
    end)
  end

  test "flags inside a tuple wrapper too" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, [_a, _b] = list} = call()
        assert length(list) == 2
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> assert_issue()
  end

  test "flags single-element placeholder lists too" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert %{rows: [_only] = rows} = call()
        assert rows == [%{id: 1}]
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> assert_issue()
  end

  test "ignores mixed lists where at least one element has a real shape" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert %{rows: [%{id: 1}, _second] = rows} = call()
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> refute_issues()
  end

  test "ignores good patterns that already inline the shape" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert %{metrics: [%{name: "A"}, %{name: "B"}]} = call()
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> refute_issues()
  end

  test "ignores empty-list bindings like `[] = var`" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert %{rows: [] = rows} = call()
        assert rows == []
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> refute_issues()
  end

  test "ignores cons patterns like `[_a | _rest] = var`" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert [_first | _rest] = list = call()
        assert is_list(list)
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> refute_issues()
  end

  test "ignores placeholder lists outside an `assert`" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        [_a, _b] = call()
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> refute_issues()
  end

  test "skips non-test files" do
    """
    defmodule Foo do
      def split([_a, _b] = pair), do: pair
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(InlineListShapeInAssert)
    |> refute_issues()
  end

  test "flags multiple occurrences in the same test file" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "one" do
        assert %{a: [_x, _y] = a} = call()
        assert a
      end

      test "two" do
        assert %{b: [_x, _y] = b} = call()
        assert b
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlineListShapeInAssert)
    |> assert_issues(fn issues ->
      assert length(issues) == 2
    end)
  end
end

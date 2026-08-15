defmodule SpendableCredo.Checks.InlinePinnedFieldsInAssertTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.InlinePinnedFieldsInAssert

  test "flags `assert var.field == expected` after `assert {:ok, var} = call()`" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, fetched} = call()
        assert fetched.budget.id == budget_id
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> assert_issue(fn issue ->
      assert issue.message =~ "Fold"
      assert issue.trigger == "assert fetched."
    end)
  end

  test "flags each follow-up dot-chain assertion on a bound var" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, fetched} = call()
        assert fetched.budget.id == budget_id
        assert fetched.bank_account.id == bank_account_id
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> assert_issues(fn issues ->
      assert length(issues) == 2
    end)
  end

  test "flags the bare-binding form `assert var = call()`" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert fetched = call()
        assert fetched.id == 1
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> assert_issue()
  end

  test "flags when the bound var is on the RHS of `==`" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, fetched} = call()
        assert expected == fetched.id
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> assert_issue()
  end

  test "flags `assert bound_var == expected` after the var is bound bare in a pattern" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, %Client{id: id}} = call()
        assert id == client.id
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> assert_issue(fn issue ->
      assert issue.trigger == "assert id =="
    end)
  end

  test "flags `assert expected == bound_var` (bound var on RHS, bare)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, %Client{id: id}} = call()
        assert client.id == id
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> assert_issue(fn issue ->
      assert issue.trigger == "assert id =="
    end)
  end

  test "flags `assert bound_var === expected` (strict equality)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, %Client{id: id}} = call()
        assert id === client.id
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> assert_issue()
  end

  test "ignores `assert bound_var == expected` when the var isn't bound by a previous assert" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        id = 1
        assert id == 1
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> refute_issues()
  end

  test "flags within a nested block (e.g. inside `if`)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        if true do
          assert {:ok, fetched} = call()
          assert fetched.id == 1
        end
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> assert_issue()
  end

  test "ignores when the bound var is used as a whole (not field access)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, fetched} = call()
        assert is_map(fetched)
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> refute_issues()
  end

  test "ignores follow-up dot access on an unrelated local var" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        budget = create_budget()
        assert budget.id == 1
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> refute_issues()
  end

  test "ignores patterns that already inline the shape with pins" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, %{budget: %{id: ^budget_id}}} = call()
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> refute_issues()
  end

  test "does not treat a pinned var as a binding" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, %{id: ^budget_id}} = call()
        assert budget_id.something == :nope
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> refute_issues()
  end

  test "ignores dot-access where the chain root isn't a bare var (e.g. function call)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, fetched} = call()
        assert get_other().field == 1
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> refute_issues()
  end

  test "ignores function calls like `fetched.compute(arg)` on a bound var" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, fetched} = call()
        assert fetched.compute(1) == 2
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> refute_issues()
  end

  test "skips non-test files" do
    """
    defmodule Foo do
      def go do
        x = bar()
        assert x.field == 1
      end
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(InlinePinnedFieldsInAssert)
    |> refute_issues()
  end

  test "flags multiple occurrences across separate tests" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "one" do
        assert {:ok, a} = call()
        assert a.id == 1
      end

      test "two" do
        assert {:ok, b} = call()
        assert b.id == 2
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(InlinePinnedFieldsInAssert)
    |> assert_issues(fn issues ->
      assert length(issues) == 2
    end)
  end
end

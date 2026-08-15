defmodule SpendableCredo.Checks.BindFieldsAtOriginTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.BindFieldsAtOrigin

  test "flags map destructure of a bare variable" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        {:ok, rule} = create_rule()
        %{id: rule_id} = rule
        assert {:ok, %BankRule{id: ^rule_id}} = delete_rule(rule)
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> assert_issue(fn issue ->
      assert issue.trigger == "%{...} = rule"
      assert issue.message =~ "Bind the field"
    end)
  end

  test "flags struct destructure of a bare variable" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        {:ok, rule} = create_rule()
        %BankRule{id: rule_id} = rule
        assert {:ok, %BankRule{id: ^rule_id}} = delete_rule(rule)
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> assert_issue(fn issue ->
      assert issue.trigger == "%{...} = rule"
    end)
  end

  test "allows destructure of a function-call result" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        %{id: id} = Repo.reload(thing)
        assert id
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> refute_issues()
  end

  test "allows nested pattern match inside assert" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        assert {:ok, %BankRule{id: rule_id} = rule} = create_rule()
        assert {:ok, %BankRule{id: ^rule_id}} = delete_rule(rule)
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> refute_issues()
  end

  test "allows destructure binding the variable itself (top-level pattern, RHS = call)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        {:ok, %BankRule{id: rule_id} = rule} = create_rule()
        assert {:ok, %BankRule{id: ^rule_id}} = delete_rule(rule)
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> refute_issues()
  end

  test "skips non-test files" do
    """
    defmodule Foo do
      def do_thing(rule) do
        %{id: id} = rule
        do_more(id)
      end
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(BindFieldsAtOrigin)
    |> refute_issues()
  end

  test "ignores _ prefixed variables on rhs" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        %{id: id} = _ignored
        assert id
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> refute_issues()
  end

  test "flags `var_id = var.id` dot-access extraction" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        {:ok, full_transaction} = create_full_transaction()
        full_transaction_id = full_transaction.id
        assert %{id: ^full_transaction_id, budget_id: ^budget1_id} = Repo.reload(full_transaction)
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> assert_issue(fn issue ->
      assert issue.trigger == "full_transaction_id = full_transaction."
      assert issue.message =~ "extract"
    end)
  end

  test "flags nested dot chain like `id = thing.assoc.id`" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        {:ok, transaction} = create_transaction()
        budget_id = transaction.budget.id
        assert %{budget_id: ^budget_id} = Repo.reload(transaction)
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> assert_issue(fn issue ->
      assert issue.trigger == "budget_id = transaction."
    end)
  end

  test "allows `var = func_call().field` (no original site)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        id = create_thing().id
        assert id
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> refute_issues()
  end

  test "allows `var = Module.func(args)` (function call, not field access)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        thing = build()
        result = Repo.reload(thing)
        assert result
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> refute_issues()
  end

  test "allows `var = other_var` (no field access)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        a = build()
        b = a
        assert b
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> refute_issues()
  end

  test "ignores `_var = thing.id` (underscore prefix)" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        thing = build()
        _id = thing.id
        assert thing
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> refute_issues()
  end

  test "flags multiple standalone destructures" do
    """
    defmodule SomeTest do
      use ExUnit.Case

      test "..." do
        {:ok, budget} = create_budget()
        {:ok, allocation} = create_allocation()
        %{id: budget_id} = budget
        %{id: allocation_id} = allocation
        assert {:ok, %{budget_id: ^budget_id, allocation_id: ^allocation_id}} = build(budget, allocation)
      end
    end
    """
    |> to_source_file("test/some_test.exs")
    |> run_check(BindFieldsAtOrigin)
    |> assert_issues(fn issues ->
      assert length(issues) == 2
    end)
  end
end

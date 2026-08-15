defmodule SpendableCredo.Checks.NoSigilWordListsTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.NoSigilWordLists

  test "allows explicit list of strings" do
    """
    defmodule Foo do
      def methods, do: ["amex", "discover", "visa"]
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(NoSigilWordLists)
    |> refute_issues()
  end

  test "allows explicit list of atoms" do
    """
    defmodule Foo do
      def statuses, do: [:pending, :paid, :void]
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(NoSigilWordLists)
    |> refute_issues()
  end

  test "flags ~w() string list" do
    """
    defmodule Foo do
      def methods, do: ~w(amex discover visa)
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(NoSigilWordLists)
    |> assert_issue(fn issue ->
      assert issue.trigger == "~w"
      assert issue.message =~ "explicitly"
    end)
  end

  test "flags ~w()a atom list" do
    """
    defmodule Foo do
      def statuses, do: ~w(pending paid void)a
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(NoSigilWordLists)
    |> assert_issue(fn issue ->
      assert issue.trigger == "~w"
    end)
  end

  test "flags ~W() uppercase variant" do
    """
    defmodule Foo do
      def methods, do: ~W(amex discover visa)
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(NoSigilWordLists)
    |> assert_issue(fn issue ->
      assert issue.trigger == "~W"
    end)
  end

  test "flags ~w() in module attributes" do
    """
    defmodule Foo do
      @statuses ~w(pending paid void)a

      def statuses, do: @statuses
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(NoSigilWordLists)
    |> assert_issue()
  end

  test "flags multiple ~w() usages" do
    """
    defmodule Foo do
      def methods, do: ~w(amex discover visa)
      def statuses, do: ~w(pending paid void)a
    end
    """
    |> to_source_file("lib/foo.ex")
    |> run_check(NoSigilWordLists)
    |> assert_issues(fn issues ->
      assert length(issues) == 2
    end)
  end
end

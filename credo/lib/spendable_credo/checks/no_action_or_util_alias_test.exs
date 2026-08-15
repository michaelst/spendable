defmodule SpendableCredo.Checks.NoActionOrUtilAliasTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.NoActionOrUtilAlias

  test "allows aliasing the Actions namespace itself" do
    """
    defmodule Spendable.Foo do
      alias Spendable.Banks.Actions
    end
    """
    |> to_source_file("lib/spendable/foo.ex")
    |> run_check(NoActionOrUtilAlias)
    |> refute_issues()
  end

  test "allows aliasing the Utils namespace itself" do
    """
    defmodule SpendableWeb.Helpers do
      alias SpendableWeb.Utils
    end
    """
    |> to_source_file("lib/spendable_web/helpers.ex")
    |> run_check(NoActionOrUtilAlias)
    |> refute_issues()
  end

  test "allows aliases unrelated to Actions or Utils" do
    """
    defmodule Spendable.Foo do
      alias Spendable.Banks.Schemas.BankConnection
      alias Spendable.Repo
    end
    """
    |> to_source_file("lib/spendable/foo.ex")
    |> run_check(NoActionOrUtilAlias)
    |> refute_issues()
  end

  test "flags an alias of a leaf Action module" do
    """
    defmodule Spendable.Foo do
      alias Spendable.Budgets.Actions.CreateBudget
    end
    """
    |> to_source_file("lib/spendable/foo.ex")
    |> run_check(NoActionOrUtilAlias)
    |> assert_issue(fn issue ->
      assert issue.message =~ "Spendable.Budgets.Actions.CreateBudget"
      assert issue.message =~ "context"
    end)
  end

  test "flags an alias of a leaf Util module with import guidance" do
    """
    defmodule Spendable.Foo do
      alias Spendable.Budgets.Utils.CalculateBalances
    end
    """
    |> to_source_file("lib/spendable/foo.ex")
    |> run_check(NoActionOrUtilAlias)
    |> assert_issue(fn issue ->
      assert issue.message =~ "Spendable.Budgets.Utils.CalculateBalances"
      assert issue.message =~ "import"
    end)
  end

  test "flags an Action alias inside a .exs test file" do
    """
    defmodule Spendable.Shared.Actions.SumDecimalsTest do
      alias Spendable.Shared.Actions.SumDecimals
    end
    """
    |> to_source_file("lib/spendable/shared/actions/sum_decimals_test.exs")
    |> run_check(NoActionOrUtilAlias)
    |> assert_issue(fn issue ->
      assert issue.message =~ "Spendable.Shared.Actions.SumDecimals"
    end)
  end

  test "flags an alias when Actions appears mid-path with submodule" do
    """
    defmodule Spendable.Foo do
      alias Spendable.Budgets.Actions.CreateBudget.Inner
    end
    """
    |> to_source_file("lib/spendable/foo.ex")
    |> run_check(NoActionOrUtilAlias)
    |> assert_issue(fn issue ->
      assert issue.message =~ "Spendable.Budgets.Actions.CreateBudget.Inner"
    end)
  end

  test "flags both Actions and Utils aliases in the same file" do
    """
    defmodule Spendable.Foo do
      alias Spendable.Budgets.Actions.CreateBudget
      alias Spendable.Budgets.Utils.CalculateBalances
    end
    """
    |> to_source_file("lib/spendable/foo.ex")
    |> run_check(NoActionOrUtilAlias)
    |> assert_issues(fn issues ->
      assert length(issues) == 2
    end)
  end
end

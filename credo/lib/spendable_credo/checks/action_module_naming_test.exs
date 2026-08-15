defmodule SpendableCredo.Checks.ActionModuleNamingTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.ActionModuleNaming

  test "allows valid action module with matching function and filename" do
    """
    defmodule Spendable.Budgets.Actions.CreateBudget do
      def create_budget(scope, attrs) do
        :ok
      end
    end
    """
    |> to_source_file("lib/spendable/banks/actions/create_budget.ex")
    |> run_check(ActionModuleNaming)
    |> refute_issues()
  end

  test "allows predicate function with ? suffix" do
    """
    defmodule Spendable.Users.Actions.Can do
      def can?(scope, resource, action) do
        true
      end
    end
    """
    |> to_source_file("lib/spendable/users/actions/can.ex")
    |> run_check(ActionModuleNaming)
    |> refute_issues()
  end

  test "allows bang function with ! suffix" do
    """
    defmodule Spendable.Sales.Actions.UpsertOrderCategory do
      def upsert_order_category!(scope, attrs) do
        :ok
      end
    end
    """
    |> to_source_file("lib/spendable/sales/actions/upsert_order_category.ex")
    |> run_check(ActionModuleNaming)
    |> refute_issues()
  end

  test "handles acronyms like OAuth gracefully" do
    """
    defmodule Spendable.Users.Actions.RegisterOAuthUser do
      def register_oauth_user(attrs) do
        :ok
      end
    end
    """
    |> to_source_file("lib/spendable/users/actions/register_oauth_user.ex")
    |> run_check(ActionModuleNaming)
    |> refute_issues()
  end

  test "allows function with guard clause" do
    """
    defmodule Spendable.AuditLog.Actions.ForDelete do
      def for_delete(resource, scope) when is_struct(resource) do
        :ok
      end
    end
    """
    |> to_source_file("lib/spendable/audit_log/actions/for_delete.ex")
    |> run_check(ActionModuleNaming)
    |> refute_issues()
  end

  test "does not check non-action modules" do
    """
    defmodule Spendable.Banks.Schemas.BankConnection do
      def some_unrelated_function do
        :ok
      end
    end
    """
    |> to_source_file("lib/spendable/banks/schemas/bank_member.ex")
    |> run_check(ActionModuleNaming)
    |> refute_issues()
  end

  test "skips .exs files" do
    """
    defmodule Spendable.Budgets.Actions.CreateBudgetTest do
      def wrong_function do
        :ok
      end
    end
    """
    |> to_source_file("lib/spendable/banks/actions/create_budget_test.exs")
    |> run_check(ActionModuleNaming)
    |> refute_issues()
  end

  test "flags action module missing the expected public function" do
    """
    defmodule Spendable.Budgets.Actions.CreateBudget do
      def wrong_function(scope, attrs) do
        :ok
      end
    end
    """
    |> to_source_file("lib/spendable/banks/actions/create_budget.ex")
    |> run_check(ActionModuleNaming)
    |> assert_issue(fn issue ->
      assert issue.message =~ "create_budget"
    end)
  end

  test "flags action module with wrong filename" do
    """
    defmodule Spendable.Shared.Actions.ParseTemplate do
      def parse_template(arg) do
        :ok
      end
    end
    """
    |> to_source_file("lib/spendable/shared/actions/chart_of_accounts_preview.ex")
    |> run_check(ActionModuleNaming)
    |> assert_issue(fn issue ->
      assert issue.message =~ "parse_template.ex"
      assert issue.message =~ "chart_of_accounts_preview.ex"
    end)
  end
end

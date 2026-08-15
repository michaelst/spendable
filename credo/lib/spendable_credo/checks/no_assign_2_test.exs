defmodule SpendableCredo.Checks.NoAssign2Test do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.NoAssign2

  test "allows assign/3" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket) do
        socket =
          socket
          |> assign(:foo, 1)
          |> assign(:bar, 2)

        {:ok, socket}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> refute_issues()
  end

  test "allows assign_new/3 (different function)" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def mount(_params, _session, socket) do
        {:ok, assign_new(socket, :foo, fn -> 1 end)}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> refute_issues()
  end

  test "flags unqualified assign/2 with keyword list" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def mount(_params, _session, socket) do
        {:ok, assign(socket, foo: 1, bar: 2)}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> assert_issue(fn issue ->
      assert issue.trigger == "assign/2"
      assert issue.message =~ "assign/3"
    end)
  end

  test "flags assign/2 with map" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def mount(_params, _session, socket) do
        {:ok, assign(socket, %{foo: 1})}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> assert_issue()
  end

  test "flags piped assign/2" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def mount(_params, _session, socket) do
        socket = socket |> assign(foo: 1)
        {:ok, socket}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> assert_issue(fn issue ->
      assert issue.trigger == "assign/2"
    end)
  end

  test "flags qualified Phoenix.Component.assign/2" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def mount(_params, _session, socket) do
        {:ok, Phoenix.Component.assign(socket, foo: 1)}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> assert_issue(fn issue ->
      assert issue.trigger == "assign/2"
    end)
  end

  test "flags qualified piped Phoenix.Component.assign/2" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def mount(_params, _session, socket) do
        {:ok, socket |> Phoenix.Component.assign(foo: 1)}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> assert_issue(fn issue ->
      assert issue.trigger == "assign/2"
    end)
  end

  test "allows assign/2 with a plain variable as second arg" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def render(assigns) do
        assigns = assign(assigns, report)
        ~H"<div />"
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> refute_issues()
  end

  test "allows piped assign/2 with a plain variable" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def render(assigns) do
        assigns |> assign(report)
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> refute_issues()
  end

  test "flags multiple assign/2 calls" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def mount(_params, _session, socket) do
        socket = assign(socket, foo: 1)
        socket = assign(socket, bar: 2)
        {:ok, socket}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(NoAssign2)
    |> assert_issues(fn issues ->
      assert length(issues) == 2
    end)
  end
end

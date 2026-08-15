defmodule SpendableCredo.Checks.LiveViewCallbackOrderTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.LiveViewCallbackOrder

  test "allows canonical order: mount -> handle_params -> render -> handle_event" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def handle_params(_params, _uri, socket), do: {:noreply, socket}

      def render(assigns), do: ~H""

      def handle_event("save", _params, socket), do: {:noreply, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end

  test "allows order without handle_params" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def render(assigns), do: ~H""

      def handle_event("save", _params, socket), do: {:noreply, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end

  test "allows handle_info after handle_event" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def render(assigns), do: ~H""

      def handle_event("save", _params, socket), do: {:noreply, socket}

      def handle_info(_msg, socket), do: {:noreply, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end

  test "allows multiple mount clauses next to each other" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(%{"id" => "new"}, _session, socket), do: {:ok, socket}

      def mount(%{"id" => _id}, _session, socket), do: {:ok, socket}

      def render(assigns), do: ~H""
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end

  test "allows multiple handle_event clauses" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def render(assigns), do: ~H""

      def handle_event("save", _params, socket), do: {:noreply, socket}

      def handle_event("close", _params, socket), do: {:noreply, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end

  test "allows guard clauses on callbacks" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def handle_params(params, _uri, socket) when is_map(params), do: {:noreply, socket}

      def render(assigns), do: ~H""
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end

  test "ignores modules without LiveView callbacks" do
    """
    defmodule Spendable.Banks.Schemas.BankConnection do
      def some_function, do: :ok
    end
    """
    |> to_source_file("lib/spendable/banks/schemas/bank_member.ex")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end

  test "skips .exs files" do
    """
    defmodule SpendableWeb.Live.Some.PageTest do
      def render(assigns), do: ~H""
      def mount(_params, _session, socket), do: {:ok, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page_test.exs")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end

  test "flags handle_params placed after render" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def render(assigns), do: ~H""

      def handle_params(_params, _uri, socket), do: {:noreply, socket}

      def handle_event("save", _params, socket), do: {:noreply, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> assert_issue(fn issue ->
      assert issue.trigger == "handle_params/3"
      assert issue.message =~ "render/1"
    end)
  end

  test "flags render placed before mount" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def render(assigns), do: ~H""

      def mount(_params, _session, socket), do: {:ok, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> assert_issue(fn issue ->
      assert issue.trigger == "mount/3"
      assert issue.message =~ "render/1"
    end)
  end

  test "flags handle_event placed before render" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def handle_event("save", _params, socket), do: {:noreply, socket}

      def render(assigns), do: ~H""
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> assert_issue(fn issue ->
      assert issue.trigger == "render/1"
      assert issue.message =~ "handle_event/3"
    end)
  end

  test "allows handle_async and terminate in tail position" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def render(assigns), do: ~H""

      def handle_event("save", _params, socket), do: {:noreply, socket}

      def handle_async(:load, {:ok, result}, socket), do: {:noreply, socket}

      def terminate(_reason, _socket), do: :ok
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end

  test "flags handle_async placed before render" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def handle_async(:load, {:ok, result}, socket), do: {:noreply, socket}

      def render(assigns), do: ~H""
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> assert_issue(fn issue ->
      assert issue.trigger == "render/1"
      assert issue.message =~ "handle_async/3"
    end)
  end

  test "flags terminate placed before render" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def terminate(_reason, _socket), do: :ok

      def render(assigns), do: ~H""
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> assert_issue(fn issue ->
      assert issue.trigger == "render/1"
      assert issue.message =~ "terminate/2"
    end)
  end

  test "flags handle_info placed before handle_event" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def render(assigns), do: ~H""

      def handle_info(_msg, socket), do: {:noreply, socket}

      def handle_event("save", _params, socket), do: {:noreply, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> assert_issue(fn issue ->
      assert issue.trigger == "handle_event/3"
      assert issue.message =~ "handle_info/2"
    end)
  end

  test "flags violations when a later `use` follows `:live_view`" do
    # Regression: detection must not be reset by a `use` that comes after the
    # `use SpendableWeb, :live_view` line (e.g. `use Gettext, ...`).
    """
    defmodule SpendableWeb.Live.Budgets do
      use SpendableWeb, :live_view
      use Gettext, backend: SpendableWeb.Gettext

      def render(assigns), do: ~H""

      def mount(_params, _session, socket), do: {:ok, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/budgets.ex")
    |> run_check(LiveViewCallbackOrder)
    |> assert_issue(fn issue ->
      assert issue.trigger == "mount/3"
      assert issue.message =~ "render/1"
    end)
  end

  test "handles non liveview functions" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      use SpendableWeb, :live_view

      def mount(_params, _session, socket), do: {:ok, socket}

      def render(assigns), do: ~H""

      def other(socket), do: {:noreply, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(LiveViewCallbackOrder)
    |> refute_issues()
  end
end

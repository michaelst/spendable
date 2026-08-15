defmodule SpendableCredo.Checks.PipeIntoNoreplyOkTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.PipeIntoNoreplyOk

  test "allows bare {:noreply, socket}" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def handle_params(_params, _uri, socket), do: {:noreply, socket}
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> refute_issues()
  end

  test "allows bare {:ok, socket}" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def mount(_params, _session, socket) do
        {:ok, socket}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> refute_issues()
  end

  test "allows bare {:cont, socket}" do
    """
    defmodule SpendableWeb.Live.Some.Hook do
      def on_mount(:default, _params, _session, socket) do
        {:cont, socket}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/hook.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> refute_issues()
  end

  test "allows bare {:halt, socket}" do
    """
    defmodule SpendableWeb.Live.Some.Hook do
      def on_mount(:default, _params, _session, socket) do
        {:halt, socket}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/hook.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> refute_issues()
  end

  test "allows {:noreply, socket} when other lines in the function use pipes" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def handle_event("click", _params, socket) do
        socket = socket |> assign(:foo, 1)
        {:noreply, socket}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> refute_issues()
  end

  test "flags {:noreply, ...} with a pipe inside the tuple" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def handle_event("click", _params, socket) do
        {:noreply, socket |> assign(:foo, 1)}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> assert_issue(fn issue ->
      assert issue.trigger == "{:noreply, ... |> ...}"
      assert issue.message =~ "noreply/1"
    end)
  end

  test "flags {:ok, ...} with a pipe inside the tuple" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def mount(_params, _session, socket) do
        {:ok, socket |> assign(:foo, 1)}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> assert_issue(fn issue ->
      assert issue.trigger == "{:ok, ... |> ...}"
      assert issue.message =~ "ok/1"
    end)
  end

  test "flags {:cont, ...} with a pipe inside the tuple" do
    """
    defmodule SpendableWeb.Live.Some.Hook do
      def on_mount(:default, _params, _session, socket) do
        {:cont, socket |> assign(:foo, 1)}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/hook.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> assert_issue(fn issue ->
      assert issue.trigger == "{:cont, ... |> ...}"
      assert issue.message =~ "cont/1"
    end)
  end

  test "flags {:halt, ...} with a pipe inside the tuple" do
    """
    defmodule SpendableWeb.Live.Some.Hook do
      def on_mount(:default, _params, _session, socket) do
        {:halt, socket |> push_navigate(to: "/")}
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/hook.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> assert_issue(fn issue ->
      assert issue.trigger == "{:halt, ... |> ...}"
      assert issue.message =~ "halt/1"
    end)
  end

  test "allows piped helper calls" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def handle_event("click", _params, socket) do
        socket |> assign(:foo, 1) |> noreply()
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> refute_issues()
  end

  test "allows 3-element tuples with same tag" do
    """
    defmodule Spendable.Some.Channel do
      def handle_in("msg", payload, socket) do
        result = transform(payload)
        {:reply, {:ok, result}, socket}
      end
    end
    """
    |> to_source_file("lib/spendable/some/channel.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> refute_issues()
  end

  test "flags multiple violations in the same function" do
    """
    defmodule SpendableWeb.Live.Some.Page do
      def handle_event("click", _params, socket) do
        case something do
          :a -> {:noreply, socket |> assign(:a, 1)}
          :b -> {:noreply, socket |> assign(:b, 2)}
        end
      end
    end
    """
    |> to_source_file("lib/spendable_web/live/some/page.ex")
    |> run_check(PipeIntoNoreplyOk)
    |> assert_issues(fn issues ->
      assert length(issues) == 2
    end)
  end
end

defmodule SpendableCredo.Checks.MigrationTimestampsTest do
  use Credo.Test.Case, async: true

  alias SpendableCredo.Checks.MigrationTimestamps

  @migration """
  defmodule Spendable.Repo.Migrations.AddNoteToTransactions do
    use Ecto.Migration

    def change do
      alter table(:bank_accounts) do
        add :note, references(:budgets)
      end
    end
  end
  """

  test "allows a generated timestamp" do
    @migration
    |> to_source_file("priv/repo/migrations/20260807135753_add_note_to_transactions.exs")
    |> run_check(MigrationTimestamps)
    |> refute_issues()
  end

  test "ignores files outside of migrations" do
    @migration
    |> to_source_file("lib/spendable/banks/bank_account.ex")
    |> run_check(MigrationTimestamps)
    |> refute_issues()
  end

  test "ignores dotfiles in the migrations directory" do
    """
    [inputs: ["*.exs"]]
    """
    |> to_source_file("priv/repo/migrations/.formatter.exs")
    |> run_check(MigrationTimestamps)
    |> refute_issues()
  end

  test "flags a zeroed out time" do
    @migration
    |> to_source_file("priv/repo/migrations/20260806000000_add_note_to_transactions.exs")
    |> run_check(MigrationTimestamps)
    |> assert_issue(fn issue ->
      assert issue.trigger == "20260806000000"
      assert issue.message =~ "hand-written time"
    end)
  end

  test "flags a hand-written time on the hour" do
    @migration
    |> to_source_file("priv/repo/migrations/20260806120000_add_note_to_transactions.exs")
    |> run_check(MigrationTimestamps)
    |> assert_issue(fn issue -> assert issue.message =~ "hand-written time" end)
  end

  test "flags a hand-written time on the quarter hour" do
    @migration
    |> to_source_file("priv/repo/migrations/20260806171500_add_note_to_transactions.exs")
    |> run_check(MigrationTimestamps)
    |> assert_issue(fn issue -> assert issue.message =~ "hand-written time" end)
  end

  test "flags a timestamp that is not a real date" do
    @migration
    |> to_source_file("priv/repo/migrations/20261332135753_add_note_to_transactions.exs")
    |> run_check(MigrationTimestamps)
    |> assert_issue(fn issue ->
      assert issue.trigger == "20261332135753"
      assert issue.message =~ "valid UTC timestamp"
    end)
  end

  test "flags a filename without a timestamp" do
    @migration
    |> to_source_file("priv/repo/migrations/add_note_to_transactions.exs")
    |> run_check(MigrationTimestamps)
    |> assert_issue(fn issue ->
      assert issue.trigger == "add_note_to_transactions.exs"
      assert issue.message =~ "<YYYYMMDDHHMMSS>_<name>.exs"
    end)
  end

  test "flags a timestamp with too few digits" do
    @migration
    |> to_source_file("priv/repo/migrations/202608071357_add_note_to_transactions.exs")
    |> run_check(MigrationTimestamps)
    |> assert_issue(fn issue -> assert issue.message =~ "<YYYYMMDDHHMMSS>_<name>.exs" end)
  end

  test "lets migrations at or before start_after keep their hand-written time" do
    @migration
    |> to_source_file("priv/repo/migrations/20260806120000_add_note.exs")
    |> run_check(MigrationTimestamps, start_after: "20260807")
    |> refute_issues()
  end

  test "flags a hand-written time after start_after" do
    @migration
    |> to_source_file("priv/repo/migrations/20260810120000_add_note.exs")
    |> run_check(MigrationTimestamps, start_after: "20260807")
    |> assert_issue(fn issue -> assert issue.trigger == "20260810120000" end)
  end

  test "flags a malformed name at or before start_after" do
    @migration
    |> to_source_file("priv/repo/migrations/20261332135753_add_note.exs")
    |> run_check(MigrationTimestamps, start_after: "20270101")
    |> assert_issue(fn issue -> assert issue.message =~ "valid UTC timestamp" end)
  end
end

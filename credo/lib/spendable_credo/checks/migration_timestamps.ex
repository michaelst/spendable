defmodule SpendableCredo.Checks.MigrationTimestamps do
  @moduledoc """
  Requires migration filenames to carry a real UTC timestamp.

  The `ecto.gen.migration` task prefixes the filename with `YYYYMMDDHHMMSS` read
  off the UTC clock. A hand-written prefix keeps the date and zeroes out the time
  (`20260806000000`, `20260806120000`), which collides the moment two branches
  add a migration on the same day: both files get the same version, Ecto keys
  `schema_migrations` on that version, and after the merge one of them never
  runs.

      # bad
      priv/repo/migrations/20260806000000_add_note_to_transactions.exs
      priv/repo/migrations/20260806120000_add_note_to_transactions.exs

      # good
      priv/repo/migrations/20260807135753_add_note_to_transactions.exs

  This check flags a filename that is not `<YYYYMMDDHHMMSS>_<name>.exs`, whose
  prefix is not a valid UTC timestamp, or whose seconds are `00` (the giveaway
  for a hand-written time). Migrations that already have one can be
  grandfathered with `start_after`.

  Generate migrations with `mise exec -- mix ecto.gen.migration <name>`, or take
  the prefix from `date -u +%Y%m%d%H%M%S`.
  """

  use Credo.Check,
    base_priority: :high,
    category: :warning,
    param_defaults: [start_after: "0"],
    explanations: [
      check: """
      Migration filenames must start with the UTC timestamp of the moment they
      were created, down to the second:

          # bad, the time is hand-written and collides with every other
          # migration written on 2026-08-06
          priv/repo/migrations/20260806120000_add_note_to_transactions.exs

          # good
          priv/repo/migrations/20260807135753_add_note_to_transactions.exs

      We merge several migrations a day. Ecto records the 14-digit prefix in
      `schema_migrations`, so two migrations sharing a version means only one of
      them ever runs, and the other silently disappears in the merge.

      Generate migrations with `mise exec -- mix ecto.gen.migration <name>`, or
      take the prefix from `date -u +%Y%m%d%H%M%S`.
      """,
      params: [
        start_after:
          "Migrations at or before this version keep their hand-written time. Filenames are still checked."
      ]
    ]

  @filename_format ~r/^(?<version>\d{14})_[a-z0-9_]+\.exs$/
  @generate_hint "Generate it with `mise exec -- mix ecto.gen.migration <name>`, or take the prefix from `date -u +%Y%m%d%H%M%S`."

  @impl true
  def run(%SourceFile{filename: filename} = source_file, params) do
    if migration?(filename) do
      ctx = Context.build(source_file, params, __MODULE__, %{})
      start_after = Params.get(params, :start_after, __MODULE__)

      ctx |> issue_for(Path.basename(filename), start_after) |> List.wrap()
    else
      []
    end
  end

  defp migration?(filename) do
    basename = Path.basename(filename)

    String.contains?(filename, "migrations/") and Path.extname(basename) == ".exs" and
      not String.starts_with?(basename, ".")
  end

  defp issue_for(ctx, basename, start_after) do
    case Regex.named_captures(@filename_format, basename) do
      %{"version" => version} ->
        version_issue(ctx, basename, version, start_after)

      nil ->
        issue(ctx, basename, basename, "is not named `<YYYYMMDDHHMMSS>_<name>.exs`.")
    end
  end

  defp version_issue(ctx, basename, version, start_after) do
    cond do
      not valid_timestamp?(version) ->
        issue(ctx, basename, version, "does not start with a valid UTC timestamp.")

      zeroed_seconds?(version) and version > start_after ->
        issue(
          ctx,
          basename,
          version,
          "has a hand-written time: a generated timestamp rarely lands on `00` seconds. " <>
            "Every migration written on the same day with a hand-written time gets the same " <>
            "version, and only one of them survives the merge."
        )

      true ->
        nil
    end
  end

  defp valid_timestamp?(version) do
    <<year::binary-4, month::binary-2, day::binary-2, hour::binary-2, minute::binary-2,
      second::binary-2>> = version

    match?(
      {:ok, _naive_date_time},
      NaiveDateTime.from_iso8601("#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}")
    )
  end

  defp zeroed_seconds?(version), do: String.slice(version, 12, 2) == "00"

  defp issue(ctx, basename, trigger, message) do
    format_issue(ctx,
      message: "Migration `#{basename}` #{message} #{@generate_hint}",
      trigger: trigger,
      line_no: 1
    )
  end
end

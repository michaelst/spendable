# SpendableCredo

Custom Credo checks for Spendable projects.

## Installation

Already wired into the parent project as a path dependency:

    {:spendable_credo, path: "credo", only: :dev}

Run it with `mix credo`, which is aliased to `credo --config-file credo/.credo.exs`.

The checks are enabled in [credo/.credo.exs](.credo.exs):

    %{
      configs: [
        %{
          name: "default",
          checks: %{
            enabled: [
              {SpendableCredo.Checks.ActionModuleNaming, []}
            ]
          }
        }
      ]
    }

## Checks

- **UtilImport** - Ensures utils are imported (not aliased) and only used within their own context.
- **ActionModuleNaming** - Ensures action modules have a matching public function and filename.
- **PreferPositiveTypeGuard** - Prefers a positive type guard (`is_struct/2`, `is_binary/1`, ...) over `not is_nil/1`; Ecto query expressions are exempt.
- **PrivateFunctionsLast** - Requires all public functions (`def`) to be defined before any private functions (`defp`).
- **MigrationTimestamps** - Requires migration filenames to be `<YYYYMMDDHHMMSS>_<name>.exs` with a real UTC timestamp, rejecting the hand-written `00` seconds that make same-day migrations from different branches collide. Takes a `start_after` param to grandfather existing migrations. Needs `priv/repo/migrations/` in the config's `files.included`.

## Running tests

    mix test

## Adding a new check

1. Create the check module at `lib/spendable_credo/checks/your_check.ex`
2. Create the test file at `lib/spendable_credo/checks/your_check_test.exs`
3. Run `mix test` to verify your tests pass

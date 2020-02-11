#!/bin/sh
/app/_build/prod/rel/spendable/bin/spendable eval "Ecto.Migrator.with_repo(Spendable.Repo, &Ecto.Migrator.run(&1, :up, all: true))""
/app/_build/prod/rel/spendable/bin/spendable start

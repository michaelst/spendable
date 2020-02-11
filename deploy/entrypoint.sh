#!/bin/sh
./bin/spendable eval "Ecto.Migrator.with_repo(Spendable.Repo, &Ecto.Migrator.run(&1, :up, all: true))"
./bin/spendable start

defmodule Spendable.Release do
  def migrate() do
    for repo <- repos() do
      {:ok, _fun_return, _app} =
        Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    {:ok, _fun_return, _app} =
      Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos() do
    Application.load(:spendable)
    Application.fetch_env!(:spendable, :ecto_repos)
  end
end

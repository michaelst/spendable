defmodule Mix.Tasks.Import.Categories do
  use Mix.Task

  alias Budget.Banks.Category
  alias Budget.Repo

  @shortdoc "Import categories from Plaid."
  def run(_) do
    Mix.Task.run("app.start")

    {:ok, %{body: %{"categories" => categories}}} = Plaid.categories()

    Enum.reduce(categories, %{}, fn category, acc ->
      category["hierarchy"]
      |> Enum.reverse()
      |> case do
        [name] ->
          %{id: id} =
            %Category{
              name: name,
              external_id: category["category_id"]
            }
            |> Repo.insert!()

          Map.put(acc, name, id)

        [name | parents] = all ->
          parent_key = Enum.join(parents, ":")
          new_key = Enum.join(all, ":")

          %{id: id} =
            %Category{
              name: name,
              external_id: category["category_id"],
              parent_id: acc[parent_key]
            }
            |> Repo.insert!()

          Map.put(acc, new_key, id)
      end
    end)
  end
end

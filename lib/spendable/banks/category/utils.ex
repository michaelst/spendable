defmodule Spendable.Banks.Category.Utils do
  alias Spendable.Banks.Category
  alias Spendable.Repo

  def get_categories() do
    {:ok, %{body: %{"categories" => categories}}} = Plaid.categories()
    categories
  end

  def import_categories(categories) do
    categories
    |> Enum.group_by(fn category ->
      case Enum.reverse(category["hierarchy"]) do
        [_] ->
          nil

        [_name | parents] ->
          Enum.join(parents, ":")
      end
    end)
    |> Enum.sort_by(fn
      {nil, _} -> 0
      {parent_key, _} -> parent_key |> String.split(":") |> length()
    end)
    |> Enum.reduce(%{}, fn {parent_key, categories}, acc ->
      {_count, categories} =
        Repo.insert_all(
          Category,
          Enum.map(categories, fn category ->
            %{
              name: List.last(category["hierarchy"]),
              external_id: category["category_id"],
              parent_id: acc[parent_key],
              parent_name: if(parent_key, do: parent_key |> String.split(":") |> Enum.join(" / "))
            }
          end),
          conflict_target: :external_id,
          on_conflict: {:replace, [:name, :parent_name]},
          returning: [:id, :name]
        )

      categories
      |> Enum.map(fn category ->
        case parent_key do
          nil -> {category.name, category.id}
          _ -> {category.name <> ":" <> parent_key, category.id}
        end
      end)
      |> Map.new()
      |> Map.merge(acc)
    end)
  end
end

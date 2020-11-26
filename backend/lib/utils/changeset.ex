defmodule Spendable.Utils.Changeset do
  def propogate_parent_key(%{params: params, data: data} = changeset, relation, key) do
    if is_nil(params["#{relation}"]) do
      changeset
    else
      value = params[key] || Map.get(data, key)
      relation_params = params["#{relation}"] |> Enum.map(&Map.put(&1, key, value))
      params = Map.put(params, "#{relation}", relation_params)
      Map.put(changeset, :params, params)
    end
  end
end

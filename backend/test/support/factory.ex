defmodule Factory do
  def build(model, overrides \\ [], opts \\ []) do
    params = params_for(model, overrides, opts)

    struct!(model, params)
  end

  def insert(model, overrides \\ [], opts \\ []) do
    build(model, overrides, opts)
    |> Spendable.Repo.insert!()
  end

  def params_for(model, overrides \\ [], opts \\ []) do
    build_params(model, overrides, opts)
  end

  defp build_params(model, overrides, opts) do
    factory = Module.concat([model, Factory])

    factory_name = opts[:factory_name] || :default

    unless Kernel.function_exported?(factory, factory_name, 0) do
      raise "#{factory_name}/0 must be implemented on #{factory}"
    end

    now = DateTime.utc_now()

    fields = model.__schema__(:fields)
    args = Map.new(overrides)

    keys_not_in_schema = Map.keys(args) -- fields

    unless Enum.empty?(keys_not_in_schema) do
      raise "field overrides provided that are not in schema: #{inspect(keys_not_in_schema)}"
    end

    factory
    |> apply(factory_name, [])
    |> Map.put_new(:inserted_at, now)
    |> Map.put_new(:updated_at, now)
    |> Map.merge(args)
    # remove any fields that are not part of the schema
    |> Map.take(fields)
  end
end

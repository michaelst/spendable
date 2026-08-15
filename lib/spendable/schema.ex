defmodule Spendable.Schema do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import Ecto.Query

      @foreign_key_type :string
      @timestamps_opts [type: :utc_datetime_usec]

      @doc """
      Rejects a foreign key pointing at a record the user does not own, so a caller cannot
      attach someone else's budget to their own transaction by posting an id.
      """
      def validate_relationships(changeset, fields) do
        Enum.reduce(fields, changeset, fn relationship, changeset ->
          prepare_changes(changeset, fn changeset ->
            association = changeset.data.__struct__.__schema__(:association, relationship)

            relationship_id = get_field(changeset, association.owner_key)
            user_id = get_field(changeset, :user_id)

            if changed?(changeset, association.owner_key) and is_binary(relationship_id) and
                 not Spendable.Repo.exists?(
                   from record in association.queryable,
                     where: record.user_id == ^user_id and record.id == ^relationship_id
                 ) do
              add_error(changeset, association.owner_key, "does not exist")
            else
              changeset
            end
          end)
        end)
      end
    end
  end
end

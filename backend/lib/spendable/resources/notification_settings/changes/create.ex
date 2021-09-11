defmodule Spendable.NotificationSettings.Changes.Create do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, record ->
      IO.inspect(record)
    end)
  end
end

defmodule Spendable.Repo.Migrations.Waitlist do
  use Ecto.Migration

  def change() do
    create table(:waitlist) do
      add(:email, :string, null: false)
    end

    create unique_index(:waitlist, [:email])
  end
end

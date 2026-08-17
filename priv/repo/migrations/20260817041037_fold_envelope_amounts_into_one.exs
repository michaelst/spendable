defmodule Spendable.Repo.Migrations.FoldEnvelopeAmountsIntoOne do
  use Ecto.Migration

  @moduledoc """
  An envelope had two amounts that were the same number wearing two hats: what its spending was
  measured against, and what a month put into it. It keeps one, and having one is what makes it
  fund itself.
  """

  def up do
    execute """
    UPDATE budgets
    SET funding_amount = budgeted_amount
    WHERE type = 'envelope' AND funding_amount IS NULL AND budgeted_amount IS NOT NULL
    """

    execute "UPDATE budgets SET budgeted_amount = NULL WHERE type = 'envelope'"
  end

  def down do
    execute """
    UPDATE budgets
    SET budgeted_amount = funding_amount, funding_amount = NULL
    WHERE type = 'envelope'
    """
  end
end

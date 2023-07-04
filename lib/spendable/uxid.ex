defmodule Spendable.UXID do
  def generate(prefix), do: UXID.generate!(prefix: prefix)
end

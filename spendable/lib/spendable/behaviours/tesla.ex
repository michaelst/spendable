defmodule Spendable.Behaviour.Tesla do
  @callback call(Tesla.Env.t(), any()) :: Tesla.Env.result()
end

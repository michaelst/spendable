defmodule Spendable.Behaviour.PubSub do
  @callback publish(binary(), String.t()) :: Tesla.Env.result()
end

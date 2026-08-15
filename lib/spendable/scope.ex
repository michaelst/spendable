defmodule Spendable.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  Every user-facing action takes a scope as its first argument and reads the owner from it, never
  from attrs. Actions that also take a record pin `user_id` between the two in the function head,
  so a record belonging to someone else cannot reach the body.
  """

  alias Spendable.Accounts.Schemas.User

  defstruct user: nil, system: false

  @doc """
  Creates a scope for the given user. Returns nil if no user is given.
  """
  def for_user(%User{} = user), do: %__MODULE__{user: user}
  def for_user(nil), do: nil

  @doc """
  Creates a scope for work the user did not initiate - the bank sync pipeline and inbound webhooks.

  It carries the same user, so the ownership pin still applies; `system` marks the caller as
  non-interactive.
  """
  def for_system(%User{} = user), do: %__MODULE__{user: user, system: true}
end

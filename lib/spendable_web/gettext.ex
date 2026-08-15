defmodule SpendableWeb.Gettext do
  @moduledoc """
  Internationalization with a gettext-based API.

  Modules that need it do `use Gettext, backend: SpendableWeb.Gettext`.
  """
  use Gettext.Backend, otp_app: :spendable
end

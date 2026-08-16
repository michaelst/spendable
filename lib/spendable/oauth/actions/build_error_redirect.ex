defmodule Spendable.OAuth.Actions.BuildErrorRedirect do
  @moduledoc false

  import Spendable.OAuth.Utils.RedirectUri

  @doc """
  The URL that tells a client its authorization request will not be granted. A refusal goes back to
  the client the same way a grant does, so it can stop waiting rather than hang.
  """
  def build_error_redirect(request, error) do
    redirect_with(request.redirect_uri, %{error: error, state: request.state})
  end
end

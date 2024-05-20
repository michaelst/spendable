defmodule Spendable.Guardian do
  use Guardian, otp_app: :spendable

  def subject_for_token(_sub, _claims) do
    {:error, :not_supported}
  end

  def resource_from_claims(_claims) do
    {:error, :not_supported}
  end
end

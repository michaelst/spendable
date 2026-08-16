defmodule Spendable.OAuth.Actions.GetClient do
  @moduledoc false

  import Spendable.OAuth.Utils.FetchClientMetadata
  import Spendable.OAuth.Utils.RedirectUri

  alias Spendable.OAuth.Schemas.Client
  alias Spendable.Repo

  @doc """
  Looks up a client by the id it authenticates with: either one that registered here, or a URL
  that serves its own metadata document (a Client-ID Metadata Document).
  """
  def get_client("https://" <> _rest = client_id) do
    with {:ok, %{"client_id" => ^client_id} = metadata} <- fetch_client_metadata(client_id),
         [_uri | _rest] = redirect_uris <- Map.get(metadata, "redirect_uris", []),
         true <- Enum.all?(redirect_uris, &allowed_for_client_id?(client_id, &1)),
         # A URL client never registered, so there is no step that could have provisioned it a
         # secret. Refuse rather than silently downgrade it to a public client.
         "none" <- metadata["token_endpoint_auth_method"] || "none" do
      {:ok,
       %Client{
         id: client_id,
         client_name: metadata["client_name"] || client_id,
         redirect_uris: redirect_uris,
         token_endpoint_auth_method: :none,
         scope: metadata["scope"] || "mcp"
       }}
    else
      _error -> {:error, :client_not_found}
    end
  end

  def get_client(client_id) do
    case Repo.get(Client, client_id) do
      %Client{} = client -> {:ok, client}
      nil -> {:error, :client_not_found}
    end
  end
end

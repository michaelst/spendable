defmodule Spendable.OAuth.Utils.RedirectUri do
  @moduledoc false

  @loopback_hosts ["localhost", "127.0.0.1", "::1"]

  @doc """
  Whether a redirect URI may be registered: an absolute https URI, or an http loopback URI, which
  RFC 8252 reserves for native clients receiving the code on an ephemeral local port.
  """
  def permitted?(uri) do
    # A redirect endpoint MUST NOT include a fragment component (RFC 6749 3.1.2).
    case URI.parse(uri) do
      %URI{scheme: "https", host: host, fragment: nil} when is_binary(host) -> true
      %URI{fragment: nil} = parsed -> loopback?(parsed)
      _other -> false
    end
  end

  @doc """
  Whether a client identified by a URL may use this redirect URI: a loopback URI, or one
  same-origin with the client id, since that is all it has demonstrably published.
  """
  def allowed_for_client_id?(client_id, redirect_uri) do
    redirect = URI.parse(redirect_uri)

    is_nil(redirect.fragment) and (loopback?(redirect) or same_origin?(URI.parse(client_id), redirect))
  end

  @doc """
  Whether a requested redirect URI matches one the client registered: an exact match, or - for
  loopback redirects - a match ignoring the port, which a native client binds at request time.
  """
  def registered?(registered_uris, requested) do
    parsed = URI.parse(requested)

    Enum.any?(registered_uris, &(&1 == requested or loopback_match?(URI.parse(&1), parsed)))
  end

  @doc """
  Builds a redirect URL by merging the given params (nils dropped) into the query string of
  `redirect_uri`, preserving any query already there.
  """
  def redirect_with(redirect_uri, params) do
    added = params |> Enum.reject(fn {_key, value} -> is_nil(value) end) |> URI.encode_query()
    uri = URI.parse(redirect_uri)
    query = [uri.query, added] |> Enum.reject(&(&1 in [nil, ""])) |> Enum.join("&")

    URI.to_string(%{uri | query: query})
  end

  defp loopback_match?(%URI{path: path} = registered, %URI{scheme: "http", path: path} = requested) do
    loopback?(registered) and requested.host == registered.host
  end

  defp loopback_match?(_registered, _requested), do: false

  defp loopback?(%URI{scheme: "http", host: host}), do: host in @loopback_hosts
  defp loopback?(_uri), do: false

  defp same_origin?(one, two), do: one.scheme == two.scheme and one.host == two.host and one.port == two.port
end

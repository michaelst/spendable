defmodule Spendable.OAuth.Utils.FetchClientMetadata do
  @moduledoc false

  @doc """
  Reads the Client-ID Metadata Document a url client id points at, for clients that identify
  themselves by URL rather than registering.
  """
  def fetch_client_metadata(url) do
    with true <- safe_url?(url),
         {:ok, %Tesla.Env{status: 200, body: metadata}} when is_map(metadata) <- Tesla.get(client(), url) do
      {:ok, metadata}
    else
      _error -> {:error, :invalid_client_metadata}
    end
  end

  defp client do
    Tesla.client([{Tesla.Middleware.Timeout, timeout: 5_000}, Tesla.Middleware.JSON])
  end

  # SSRF guard: a client_id is an attacker-supplied URL we fetch server-side, so refuse to reach
  # anything resolving to a private, loopback or link-local address. Hosts that do not resolve fail
  # open here and simply fail at the network layer.
  defp safe_url?(url) do
    case URI.parse(url) do
      %URI{scheme: "https", host: host} when is_binary(host) and host != "" ->
        case resolve(host) do
          [] -> true
          addresses -> Enum.all?(addresses, &public_ip?/1)
        end

      _other ->
        false
    end
  end

  defp resolve(host) do
    charlist = String.to_charlist(host)

    Enum.flat_map([:inet, :inet6], fn family ->
      case :inet.getaddrs(charlist, family) do
        {:ok, addresses} -> addresses
        {:error, _reason} -> []
      end
    end)
  end

  # IPv4: loopback, RFC 1918 private, CGNAT, link-local, "this network", benchmarking, multicast
  # and reserved/future (including broadcast).
  defp public_ip?({a, b, _c, _d}) do
    cond do
      a in [0, 10, 127] -> false
      a == 172 and b in 16..31 -> false
      a == 192 and b == 168 -> false
      a == 169 and b == 254 -> false
      a == 100 and b in 64..127 -> false
      a == 198 and b in 18..19 -> false
      a >= 224 -> false
      true -> true
    end
  end

  # IPv6 ::ffff:0:0/96 - IPv4-mapped, re-checked as the embedded IPv4 address.
  defp public_ip?({0, 0, 0, 0, 0, 65_535, g, h}) do
    public_ip?({div(g, 256), rem(g, 256), div(h, 256), rem(h, 256)})
  end

  # IPv6: unique-local (fc00::/7), link-local (fe80::/10), loopback (::1), unspecified (::).
  defp public_ip?({a, b, c, d, e, f, g, h}) do
    cond do
      a in 0xFC00..0xFDFF -> false
      a in 0xFE80..0xFEBF -> false
      {a, b, c, d, e, f, g, h} in [{0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 1}] -> false
      true -> true
    end
  end
end

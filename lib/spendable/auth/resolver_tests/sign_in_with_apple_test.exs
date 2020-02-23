defmodule Spendable.User.Resolver.SignInWithAppleTest do
  use Spendable.Web.ConnCase, async: false
  import Tesla.Mock
  import Mock

  alias Spendable.Repo
  alias Spendable.User

  setup do
    mock(fn
      %{method: :get, url: "https://appleid.apple.com/auth/keys"} ->
        json(%{
          "keys" => [
            %{
              "alg" => "RS256",
              "e" => "AQAB",
              "kid" => "86D88Kf",
              "kty" => "RSA",
              "n" =>
                "iGaLqP6y-SJCCBq5Hv6pGDbG_SQ11MNjH7rWHcCFYz4hGwHC4lcSurTlV8u3avoVNM8jXevG1Iu1SY11qInqUvjJur--hghr1b56OPJu6H1iKulSxGjEIyDP6c5BdE1uwprYyr4IO9th8fOwCPygjLFrh44XEGbDIFeImwvBAGOhmMB2AD1n1KviyNsH0bEB7phQtiLk-ILjv1bORSRl8AK677-1T8isGfHKXGZ_ZGtStDe7Lu0Ihp8zoUt59kx2o9uWpROkzF56ypresiIl4WprClRCjz8x6cPZXU2qNWhu71TQvUFwvIvbkE1oYaJMb0jcOTmBRZA2QuYw-zHLwQ",
              "use" => "sig"
            },
            %{
              "alg" => "RS256",
              "e" => "AQAB",
              "kid" => "eXaunmL",
              "kty" => "RSA",
              "n" =>
                "4dGQ7bQK8LgILOdLsYzfZjkEAoQeVC_aqyc8GC6RX7dq_KvRAQAWPvkam8VQv4GK5T4ogklEKEvj5ISBamdDNq1n52TpxQwI2EqxSk7I9fKPKhRt4F8-2yETlYvye-2s6NeWJim0KBtOVrk0gWvEDgd6WOqJl_yt5WBISvILNyVg1qAAM8JeX6dRPosahRVDjA52G2X-Tip84wqwyRpUlq2ybzcLh3zyhCitBOebiRWDQfG26EH9lTlJhll-p_Dg8vAXxJLIJ4SNLcqgFeZe4OfHLgdzMvxXZJnPp_VgmkcpUdRotazKZumj6dBPcXI_XID4Z4Z3OM1KrZPJNdUhxw",
              "use" => "sig"
            },
            %{
              "alg" => "RS256",
              "e" => "AQAB",
              "kid" => "AIDOPK1",
              "kty" => "RSA",
              "n" =>
                "lxrwmuYSAsTfn-lUu4goZSXBD9ackM9OJuwUVQHmbZo6GW4Fu_auUdN5zI7Y1dEDfgt7m7QXWbHuMD01HLnD4eRtY-RNwCWdjNfEaY_esUPY3OVMrNDI15Ns13xspWS3q-13kdGv9jHI28P87RvMpjz_JCpQ5IM44oSyRnYtVJO-320SB8E2Bw92pmrenbp67KRUzTEVfGU4-obP5RZ09OxvCr1io4KJvEOjDJuuoClF66AT72WymtoMdwzUmhINjR0XSqK6H0MdWsjw7ysyd_JhmqX5CAaT9Pgi0J8lU_pcl215oANqjy7Ob-VMhug9eGyxAWVfu_1u6QJKePlE-w",
              "use" => "sig"
            }
          ]
        })
    end)

    :ok
  end

  setup_with_mocks([
    {JOSE.JWT, [:passthrough],
     peek_protected: fn _ ->
       %JOSE.JWS{
         alg: {:jose_jws_alg_rsa_pkcs1_v1_5, :RS256},
         b64: :undefined,
         fields: %{"kid" => "86D88Kf"}
       }
     end},
    {JOSE.JWK, [:passthrough],
     verify: fn _, _ ->
       {true,
        "{\"iss\":\"https://appleid.apple.com\",\"aud\":\"fiftysevenmedia.SpendableDev\",\"exp\":1582434977,\"iat\":1582434377,\"sub\":\"000107.30cad47b3b7f4e498f6c8f075e4c259f.0422\",\"c_hash\":\"uJSa5ci_AjKT9rMzFKH17A\",\"auth_time\":1582434377,\"nonce_supported\":true}",
        %JOSE.JWS{
          alg: {:jose_jws_alg_rsa_pkcs1_v1_5, :RS256},
          b64: :undefined,
          fields: %{"kid" => "86D88Kf"}
        }}
     end}
  ]) do
    :ok
  end

  test "signup", %{conn: conn} do
    query = """
      mutation {
        signInWithApple(token: "test") {
          id
          token
        }
      }
    """

    response =
      conn
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "signInWithApple" => %{
                 "id" => id,
                 "token" => _
               }
             }
           } = response

    assert %User{apple_identifier: "000107.30cad47b3b7f4e498f6c8f075e4c259f.0422"} = Repo.get(User, id)
  end

  test "signin", %{conn: conn} do
    struct(User)
    |> User.changeset(%{apple_identifier: "000107.30cad47b3b7f4e498f6c8f075e4c259f.0422"})
    |> Spendable.Repo.insert!()

    query = """
      mutation {
        signInWithApple(token: "test") {
          id
          token
        }
      }
    """

    response =
      conn
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "signInWithApple" => %{
                 "id" => id,
                 "token" => _
               }
             }
           } = response
  end
end

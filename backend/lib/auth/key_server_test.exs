defmodule Spendable.Auth.Guardian.KeyServerTest do
  use Spendable.DataCase, async: true

  alias Spendable.Auth.Guardian
  alias Spendable.Auth.Guardian.KeyServer

  test "fetch verifying secret" do
    kid = "9ad0cb7c0f55902f97dc5245a8e7971f18d9c766"

    public_key =
      "-----BEGIN CERTIFICATE-----\nMIIDHDCCAgSgAwIBAgIIGYayEONWtCowDQYJKoZIhvcNAQEFBQAwMTEvMC0GA1UE\nAxMmc2VjdXJldG9rZW4uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wHhcNMjAx\nMTIxMDkyMDEwWhcNMjAxMjA3MjEzNTEwWjAxMS8wLQYDVQQDEyZzZWN1cmV0b2tl\nbi5zeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbTCCASIwDQYJKoZIhvcNAQEBBQAD\nggEPADCCAQoCggEBAJu0sWa9LMwcFHxxahlxkFjexiooIAunPFLJw6Sfcxwd9LbW\nkYpg8+RXxjv7tmlnT2R7P1ncnDdFHA4LEpzcITpNE6cafLSdW7oOplqGKXFyVN6f\neiyLBqNglBVNr+pZ903f77wqxMITg6ShUJQXIGB8O7Pm2J5xucOVWBwZY7vt2ZgI\njNUs6v0hBsx6PWNBIvpXRZ9634h5ywsK5o8aRHzC0O58vE2A/TVjKR5OQ+au9wjj\nEn0YaFtOAncEgn+41YfQCK4srOf0KEcIag5PFi/ybYcFLUYp2LlrWyXU+QELg7t9\nlAYB76fOyiJGqqJ+qR497AlmLxJBmQmWu1o75KECAwEAAaM4MDYwDAYDVR0TAQH/\nBAIwADAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwIwDQYJ\nKoZIhvcNAQEFBQADggEBAGCDZAFbqoN7ghqtUwdyONoKSpOhXmQVETc4wWe+8zws\nCTg5hCynKgAienjSMYFbAcfKnrGi4qEAz/BZluaCE+cNL/rcd+cpaVOOORtppVvZ\n8PrIjtuv0UPsxPMT0k6rUiwEXwcZi0W5sGSmT2/XYBPWPaymxchhqzr3qlqspbza\nSOnBj4a30KY1KRMWeSnLc5szisFgnQQJqC0AAWn5leBi2rNJMnBO/PMVaJrRe5fY\nGoMVumAVydfVzA9D/eggz6F+XDL6XFUKPzD7wcq0SZbvuiDz4NMUKIWrfLxK0TKE\nyIWKD2sGsD3uClfI0AyEMpPwmEDag7I0TzXJcvyMSjs=\n-----END CERTIFICATE-----\n"

    Tesla.Mock.mock_global(fn
      %{method: :get, url: "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"} ->
        %Tesla.Env{
          status: 200,
          body: %{
            kid => public_key,
            "b9826d093777ce005e43a327ff202652145e9604" =>
              "-----BEGIN CERTIFICATE-----\nMIIDHDCCAgSgAwIBAgIIYW292aNfx5MwDQYJKoZIhvcNAQEFBQAwMTEvMC0GA1UE\nAxMmc2VjdXJldG9rZW4uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wHhcNMjAx\nMTI5MDkyMDEwWhcNMjAxMjE1MjEzNTEwWjAxMS8wLQYDVQQDEyZzZWN1cmV0b2tl\nbi5zeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbTCCASIwDQYJKoZIhvcNAQEBBQAD\nggEPADCCAQoCggEBAOewE7djKEfbMBBVcunAlv3G7MKOlMUGZ/JJ0T65Dj8JukX6\nKV5d+aLGVRdp9fA9lOts3jA84LKBTBFi2Gz+pF59jitgAaCCs+Qw1QJoV7xJSstK\nVyzT0sqkOGicnaKwaGSW7oAgjgz5nYJmKfer22exR2N2chStNC7fL+PXG3xg2QOd\nDaFHEd5ND26Yi1VWg8TN+I0x6/VPe4Ucnm522yk2qASP3K0cwy/cmljqXwVaUL/+\naF4YSlCs8ySzjDJ5IjCdFWzNogPEWxzZZskW2NNV4XdGhFQUw7eepBRs0dwl3NZW\nDtI38GDnbX8DSennn/qoN4uEqIOb63jDCdhQlckCAwEAAaM4MDYwDAYDVR0TAQH/\nBAIwADAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwIwDQYJ\nKoZIhvcNAQEFBQADggEBAAeXrSrjFK1oigrx1CMilPEtEBJLPeRXzgoZrKUCveup\nQXzZ5RBBGkk96bTMtDsNCj+5XCg2WiBxT4XRgi5a4jBjkPWtlgpjfZDVglbLF9EZ\nuyq8Q30r+uXSxCOPKtxDAm4fNsVKO5OoKrl+S+e+rdRMovvohg8Cy+drg4gxhdRR\n3kEPI/jVFCVEGdfokkSsJMg+olLxPgz+GjOJhOZl24xTu1/PXLcfJwh9EYra7oqm\nedH1D417SFzdTIyF3nNeyd21RRHiC59HfnnSUvIwo5NhK0Kpk+UzktNMHlBW24mG\nIOcdEHlGGD33jWebF5ifqAM+vMy/p1THiLoPbny/h3A=\n-----END CERTIFICATE-----\n"
          }
        }
    end)

    jwk = JOSE.JWK.from_pem(public_key)

    assert {:ok, jwk} == KeyServer.fetch_verifying_secret(Guardian, %{"kid" => kid}, [])

    # call again to use existing state
    assert {:ok, jwk} == KeyServer.fetch_verifying_secret(Guardian, %{"kid" => kid}, [])
  end
end

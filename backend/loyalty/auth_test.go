package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRemoteAuthVerifierRejectsMissingCredentialsWithoutRequest(t *testing.T) {
	called := false
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	verifier := newRemoteAuthVerifier(server.URL)
	for _, tc := range []struct {
		name  string
		uuid  string
		token string
	}{
		{name: "missing uuid", token: "token"},
		{name: "missing token", uuid: "user"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			if _, err := verifier.Verify(context.Background(), tc.uuid, tc.token); err == nil {
				t.Fatal("missing credentials must be rejected")
			}
		})
	}
	if called {
		t.Fatal("verifier contacted auth service with missing credentials")
	}
}

func TestRemoteAuthVerifierRejectsUntrustedAuthResponses(t *testing.T) {
	for _, tc := range []struct {
		name   string
		status int
		body   string
	}{
		{name: "non-200 status", status: http.StatusServiceUnavailable, body: `{}`},
		{name: "malformed json", status: http.StatusOK, body: `{`},
		{name: "rejected response code", status: http.StatusOK, body: `{"code":401,"data":{"wallet_address":"0x1111111111111111111111111111111111111111"}}`},
		{name: "missing wallet", status: http.StatusOK, body: `{"code":200,"data":{"uuid":"user"}}`},
		{name: "identity mismatch", status: http.StatusOK, body: `{"code":200,"data":{"uuid":"other","wallet_address":"0x1111111111111111111111111111111111111111"}}`},
	} {
		t.Run(tc.name, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if r.Method != http.MethodGet || r.Header.Get("UUID") != "user" || r.Header.Get("Token") != "auth-token" {
					t.Errorf("unexpected auth request: method=%s headers=%v", r.Method, r.Header)
				}
				w.WriteHeader(tc.status)
				_, _ = w.Write([]byte(tc.body))
			}))
			defer server.Close()

			verifier := newRemoteAuthVerifier(server.URL)
			if _, err := verifier.Verify(context.Background(), "user", "auth-token"); err == nil {
				t.Fatal("untrusted auth response must be rejected")
			}
		})
	}
}

func TestRemoteAuthVerifierAcceptsWalletAddressAndLegacyAlias(t *testing.T) {
	for _, walletKey := range []string{"wallet_address", "wallet_addr"} {
		t.Run(walletKey, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				_, _ = w.Write([]byte(`{"code":200,"data":{"uuid":"user","` + walletKey + `":"0x1111111111111111111111111111111111111111"}}`))
			}))
			defer server.Close()

			identity, err := newRemoteAuthVerifier(server.URL).Verify(context.Background(), "user", "auth-token")
			if err != nil {
				t.Fatalf("Verify() error = %v", err)
			}
			if identity.UUID != "user" || identity.Wallet != "0x1111111111111111111111111111111111111111" {
				t.Fatalf("unexpected identity: %+v", identity)
			}
		})
	}
}

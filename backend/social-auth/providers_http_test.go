package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestExchangeOAuthCodeRejectsTokenEndpointFailures(t *testing.T) {
	if _, err := exchangeOAuthCode("http://unused.invalid/token", "", "secret", "code", "https://app.example/callback"); err == nil {
		t.Fatal("missing client id must fail before a token request")
	}

	for _, tc := range []struct {
		name         string
		status       int
		responseBody string
	}{
		{name: "upstream failure", status: http.StatusBadGateway, responseBody: `{"error":"temporarily unavailable"}`},
		{name: "malformed response", status: http.StatusOK, responseBody: `{`},
		{name: "missing access token", status: http.StatusOK, responseBody: `{"error":"invalid_grant"}`},
	} {
		t.Run(tc.name, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if r.Method != http.MethodPost {
					t.Errorf("method=%s, want POST", r.Method)
				}
				if err := r.ParseForm(); err != nil {
					t.Errorf("parse form: %v", err)
				}
				if r.Form.Get("client_id") != "test-client" || r.Form.Get("code") != "test-code" {
					t.Errorf("unexpected OAuth form: %v", r.Form)
				}
				w.WriteHeader(tc.status)
				_, _ = w.Write([]byte(tc.responseBody))
			}))
			defer server.Close()

			if _, err := exchangeOAuthCode(server.URL, "test-client", "test-secret", "test-code", "https://app.example/callback"); err == nil {
				t.Fatal("token endpoint failure must not produce an access token")
			}
		})
	}
}

func TestGetJSONRejectsUpstreamAndMalformedResponses(t *testing.T) {
	for _, tc := range []struct {
		name         string
		status       int
		responseBody string
	}{
		{name: "unauthorized upstream", status: http.StatusUnauthorized, responseBody: `{"message":"bad token"}`},
		{name: "malformed json", status: http.StatusOK, responseBody: `{`},
	} {
		t.Run(tc.name, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if got := r.Header.Get("Authorization"); got != "Bearer fixture-token" {
					t.Errorf("authorization=%q", got)
				}
				w.WriteHeader(tc.status)
				_, _ = w.Write([]byte(tc.responseBody))
			}))
			defer server.Close()

			var result map[string]any
			if err := getJSON(server.URL, "fixture-token", &result); err == nil {
				t.Fatal("invalid provider response must be rejected")
			}
		})
	}
}

func TestGetJSONUsesDecodedProviderPayloadOnSuccess(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(map[string]string{"id": "provider-user"})
	}))
	defer server.Close()

	var result struct {
		ID string `json:"id"`
	}
	if err := getJSON(server.URL, "fixture-token", &result); err != nil {
		t.Fatalf("getJSON() error = %v", err)
	}
	if result.ID != "provider-user" {
		t.Fatalf("decoded provider id=%q", result.ID)
	}
}

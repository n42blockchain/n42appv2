package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestLoginSocialHandlerRejectsInvalidRequests(t *testing.T) {
	handler := loginSocialHandler(testCfg())
	for _, tc := range []struct {
		name   string
		method string
		body   string
		status int
	}{
		{name: "wrong method", method: http.MethodGet, body: `{}`, status: http.StatusMethodNotAllowed},
		{name: "malformed json", method: http.MethodPost, body: `{"provider":`, status: http.StatusBadRequest},
		{name: "missing provider", method: http.MethodPost, body: `{}`, status: http.StatusBadRequest},
	} {
		t.Run(tc.name, func(t *testing.T) {
			recorder := httptest.NewRecorder()
			request := httptest.NewRequest(tc.method, "/v1/user/loginSocial", strings.NewReader(tc.body))

			handler.ServeHTTP(recorder, request)

			if recorder.Code != tc.status {
				t.Fatalf("status=%d body=%s, want %d", recorder.Code, recorder.Body.String(), tc.status)
			}
			if got := recorder.Header().Get("Content-Type"); got != "application/json" {
				t.Fatalf("content type=%q, want application/json", got)
			}
		})
	}
}

func TestLoginSocialHandlerDoesNotExposeProviderValidationDetails(t *testing.T) {
	handler := loginSocialHandler(testCfg())
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, "/v1/user/loginSocial", strings.NewReader(`{"provider":"unsupported"}`))

	handler.ServeHTTP(recorder, request)

	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
	if strings.Contains(recorder.Body.String(), "unsupported provider") || !strings.Contains(recorder.Body.String(), "provider verification failed") {
		t.Fatalf("provider internals leaked or generic message missing: %s", recorder.Body.String())
	}
}

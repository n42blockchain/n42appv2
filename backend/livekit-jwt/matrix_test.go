package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestMatrixClientVerifiesIdentityAndMembership(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(response http.ResponseWriter, request *http.Request) {
		if request.Header.Get("Authorization") != "Bearer matrix-token" {
			http.Error(response, "unauthorized", http.StatusUnauthorized)
			return
		}
		switch request.URL.Path {
		case "/_matrix/client/v3/account/whoami":
			response.Header().Set("Content-Type", "application/json")
			_, _ = response.Write([]byte(`{"user_id":"@test:m.example","device_id":"DEVICE"}`))
		case "/_matrix/client/v3/rooms/!room:m.example/state/m.room.member/@test:m.example":
			response.Header().Set("Content-Type", "application/json")
			_, _ = response.Write([]byte(`{"membership":"join"}`))
		default:
			http.NotFound(response, request)
		}
	}))
	defer server.Close()

	client := matrixClient{
		homeserver: server.URL,
		httpClient: &http.Client{Timeout: time.Second},
	}
	userID, err := client.WhoAmI(context.Background(), "matrix-token")
	if err != nil {
		t.Fatal(err)
	}
	if userID != "@test:m.example" {
		t.Fatalf("user id = %q", userID)
	}
	if err := client.RequireJoined(
		context.Background(),
		"matrix-token",
		"!room:m.example",
		userID,
	); err != nil {
		t.Fatal(err)
	}
}

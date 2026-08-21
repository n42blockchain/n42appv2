package main

import (
	"context"
	"errors"
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

// The handler tests drive a fake verifier, so they can only prove the handler
// reacts correctly to a given answer -- they never exercise how that answer is
// produced. These cover the real client against a stub homeserver, which is
// where a fail-open would actually hide.

func TestRoomIsLiveTreatsMissingMarkerAsNotLive(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusNotFound)
			_, _ = w.Write([]byte(`{"errcode":"M_NOT_FOUND"}`))
		}))
	defer server.Close()

	client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
	isLive, err := client.RoomIsLive(context.Background(), "tok", "!r:example")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if isLive {
		t.Fatal("a room without the marker must not be treated as live")
	}
}

func TestRoomIsLiveFailsClosedOnUpstreamError(t *testing.T) {
	for _, status := range []int{http.StatusInternalServerError, http.StatusBadGateway} {
		server := httptest.NewServer(http.HandlerFunc(
			func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(status)
			}))
		client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
		isLive, err := client.RoomIsLive(context.Background(), "tok", "!r:example")
		server.Close()
		if err == nil {
			t.Fatalf("status %d should surface an error", status)
		}
		if !isLive {
			t.Fatalf("status %d must fail closed to live, got %v", status, isLive)
		}
	}
}

// A 200 whose body is empty, malformed or wrapped by a proxy must still be
// treated as live: only an explicit 404 proves the marker is absent.
func TestRoomIsLiveTreatsOddSuccessBodyAsLive(t *testing.T) {
	for _, body := range []string{``, `{}`, `null`, `{"errcode":"M_UNKNOWN"}`, `[]`} {
		server := httptest.NewServer(http.HandlerFunc(
			func(w http.ResponseWriter, r *http.Request) {
				_, _ = w.Write([]byte(body))
			}))
		client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
		isLive, _ := client.RoomIsLive(context.Background(), "tok", "!r:example")
		server.Close()
		if !isLive {
			t.Fatalf("body %q must be treated as live", body)
		}
	}
}

// room v11+ drops the creator field; the sender carries it instead.
func TestRoomCreatorFallsBackToSender(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			_, _ = w.Write([]byte(`{"sender":"@streamer:example","type":"m.room.create"}`))
		}))
	defer server.Close()

	client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
	creator, err := client.RoomCreator(context.Background(), "tok", "!r:example")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if creator != "@streamer:example" {
		t.Fatalf("expected sender fallback, got %q", creator)
	}
}

func TestRoomCreatorReportsMissingCreator(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			_, _ = w.Write([]byte(`{}`))
		}))
	defer server.Close()

	client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
	if _, err := client.RoomCreator(context.Background(), "tok", "!r:example"); !errors.Is(err, errMatrixNoCreator) {
		t.Fatalf("expected errMatrixNoCreator, got %v", err)
	}
}

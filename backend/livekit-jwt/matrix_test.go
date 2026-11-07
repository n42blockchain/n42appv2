package main

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
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

func TestRoomCreatorReadsEventEnvelope(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !strings.HasSuffix(r.URL.Path, "/state") {
			t.Error("must request the full state list")
		}
		_, _ = w.Write([]byte(`[{"sender":"@streamer:example","type":"m.room.create","state_key":"","content":{"sender":"@attacker:example"}}]`))
	}))
	defer server.Close()
	client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
	creator, err := client.RoomCreator(context.Background(), "tok", "!r:example")
	if err != nil || creator != "@streamer:example" {
		t.Fatalf("creator=%q err=%v", creator, err)
	}
}

func TestRoomCreatorIgnoresClientControlledContent(t *testing.T) {
	calls := 0
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		calls++
		if r.Header.Get("Authorization") != "Bearer tok" {
			t.Error("missing authentication")
		}
		if strings.HasSuffix(r.URL.Path, "/state") {
			_, _ = w.Write([]byte(`[{"type":"m.room.name","state_key":"","sender":"@other:example","content":{}},{"type":"m.room.create","state_key":"","sender":"@streamer:example","content":{"sender":"@attacker:example"}}]`))
		} else {
			_, _ = w.Write([]byte(`{"room_version":"11","sender":"@attacker:example"}`))
		}
	}))
	defer server.Close()
	client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
	creator, err := client.RoomCreator(context.Background(), "tok", "!r:example")
	if err != nil || creator != "@streamer:example" || calls != 1 {
		t.Fatalf("creator=%q calls=%d err=%v", creator, calls, err)
	}
}

func TestRoomCreatorReportsMissingCreator(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasSuffix(r.URL.Path, "/state") {
			_, _ = w.Write([]byte(`[]`))
		} else {
			_, _ = w.Write([]byte(`{"sender":"@attacker:example"}`))
		}
	}))
	defer server.Close()
	client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
	if _, err := client.RoomCreator(context.Background(), "tok", "!r:example"); !errors.Is(err, errMatrixNoCreator) {
		t.Fatalf("expected missing creator, got %v", err)
	}
}

func TestRoomCreatorRejectsWrongStateEvent(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasSuffix(r.URL.Path, "/state") {
			_, _ = w.Write([]byte(`[{"type":"m.room.create","state_key":"unexpected","sender":"@attacker:example","content":{}}]`))
		} else {
			_, _ = w.Write([]byte(`{}`))
		}
	}))
	defer server.Close()
	client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
	if _, err := client.RoomCreator(context.Background(), "tok", "!r:example"); !errors.Is(err, errMatrixNoCreator) {
		t.Fatalf("expected missing creator, got %v", err)
	}
}

func TestRoomCreatorFailsClosedOnInvalidState(t *testing.T) {
	for _, tc := range []struct {
		name   string
		status int
		body   string
		want   error
	}{
		{"forbidden", 403, `{}`, errMatrixUnauthorized},
		{"upstream", 503, `{}`, errMatrixUpstream},
		{"content imitation", 200, `{"type":"m.room.create","state_key":"","sender":"@attacker:example","content":{}}`, errMatrixUpstream},
		{"missing state key", 200, `[{"type":"m.room.create","sender":"@attacker:example","content":{}}]`, errMatrixNoCreator},
		{"nested sender", 200, `[{"type":"m.room.create","state_key":"","content":{"sender":"@attacker:example","creator":"@attacker:example"}}]`, errMatrixNoCreator},
	} {
		t.Run(tc.name, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(tc.status)
				_, _ = w.Write([]byte(tc.body))
			}))
			defer server.Close()
			client := &matrixClient{homeserver: server.URL, httpClient: server.Client()}
			if creator, err := client.RoomCreator(context.Background(), "tok", "!r:example"); creator != "" || !errors.Is(err, tc.want) {
				t.Fatalf("creator=%q error=%v", creator, err)
			}
		})
	}
}

package main

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/livekit/protocol/auth"
)

type fakeMatrixVerifier struct {
	userID  string
	whoErr  error
	joinErr error
}

func (f fakeMatrixVerifier) WhoAmI(context.Context, string) (string, error) {
	return f.userID, f.whoErr
}

func (f fakeMatrixVerifier) RequireJoined(context.Context, string, string, string) error {
	return f.joinErr
}

type fakeIssuer struct {
	token string
	err   error
}

func (f fakeIssuer) Issue(tokenRequest) (string, error) {
	return f.token, f.err
}

func TestTokenHandlerIssuesToken(t *testing.T) {
	handler := tokenHandler{
		matrix: fakeMatrixVerifier{userID: "@test:m.example"},
		issuer: fakeIssuer{token: "header.payload.signature"},
	}
	body := `{"room":"mx__room_m_example","identity":"@test:m.example","name":"Test","video":true,"conversation_id":"!room:m.example","metadata":"{\"video\":true}","role":"broadcaster"}`
	request := httptest.NewRequest(http.MethodPost, "/livekit/jwt", strings.NewReader(body))
	request.Header.Set("Authorization", "Bearer matrix-token")
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", response.Code, response.Body.String())
	}
	var result map[string]string
	if err := json.Unmarshal(response.Body.Bytes(), &result); err != nil {
		t.Fatal(err)
	}
	if result["token"] != "header.payload.signature" {
		t.Fatalf("unexpected token: %q", result["token"])
	}
	if response.Header().Get("Cache-Control") != "no-store" {
		t.Fatal("token response must not be cacheable")
	}
}

func TestTokenHandlerRejectsIdentityMismatch(t *testing.T) {
	handler := tokenHandler{
		matrix: fakeMatrixVerifier{userID: "@real:m.example"},
		issuer: fakeIssuer{token: "unused"},
	}
	body := `{"room":"mx__room_m_example","identity":"@other:m.example","conversation_id":"!room:m.example"}`
	request := httptest.NewRequest(http.MethodPost, "/livekit/jwt", strings.NewReader(body))
	request.Header.Set("Authorization", "Bearer matrix-token")
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusForbidden {
		t.Fatalf("status = %d, body = %s", response.Code, response.Body.String())
	}
}

func TestTokenHandlerRejectsRoomMismatch(t *testing.T) {
	handler := tokenHandler{
		matrix: fakeMatrixVerifier{userID: "@test:m.example"},
		issuer: fakeIssuer{token: "unused"},
	}
	body := `{"room":"attacker-room","identity":"@test:m.example","conversation_id":"!room:m.example"}`
	request := httptest.NewRequest(http.MethodPost, "/livekit/jwt", strings.NewReader(body))
	request.Header.Set("Authorization", "Bearer matrix-token")
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, body = %s", response.Code, response.Body.String())
	}
}

func TestTokenHandlerRejectsNonMember(t *testing.T) {
	handler := tokenHandler{
		matrix: fakeMatrixVerifier{
			userID:  "@test:m.example",
			joinErr: errMatrixNotJoined,
		},
		issuer: fakeIssuer{token: "unused"},
	}
	body := `{"room":"mx__room_m_example","identity":"@test:m.example","conversation_id":"!room:m.example"}`
	request := httptest.NewRequest(http.MethodPost, "/livekit/jwt", strings.NewReader(body))
	request.Header.Set("Authorization", "Bearer matrix-token")
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusForbidden {
		t.Fatalf("status = %d, body = %s", response.Code, response.Body.String())
	}
}

func TestTokenHandlerMapsMatrixFailureToBadGateway(t *testing.T) {
	handler := tokenHandler{
		matrix: fakeMatrixVerifier{whoErr: errors.New("offline")},
		issuer: fakeIssuer{token: "unused"},
	}
	body := `{"room":"mx__room_m_example","identity":"@test:m.example","conversation_id":"!room:m.example"}`
	request := httptest.NewRequest(http.MethodPost, "/livekit/jwt", strings.NewReader(body))
	request.Header.Set("Authorization", "Bearer matrix-token")
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusBadGateway {
		t.Fatalf("status = %d, body = %s", response.Code, response.Body.String())
	}
}

func TestBuildLiveKitRoomNameMatchesFlutterClient(t *testing.T) {
	if actual := buildLiveKitRoomName(" !abc:server "); actual != "mx__abc_server" {
		t.Fatalf("room name = %q", actual)
	}
}

func TestLiveKitIssuerProducesScopedJWT(t *testing.T) {
	issuer := liveKitIssuer{
		apiKey:    "test-key",
		apiSecret: "test-secret-with-enough-entropy",
		ttl:       10 * time.Minute,
	}
	token, err := issuer.Issue(tokenRequest{
		Room:           "mx__room_m_example",
		Identity:       "@test:m.example",
		Name:           "Test",
		Video:          true,
		ConversationID: "!room:m.example",
	})
	if err != nil {
		t.Fatal(err)
	}
	verifier, err := auth.ParseAPIToken(token)
	if err != nil {
		t.Fatal(err)
	}
	_, grants, err := verifier.Verify("test-secret-with-enough-entropy")
	if err != nil {
		t.Fatal(err)
	}
	if grants.Identity != "@test:m.example" || grants.Video == nil {
		t.Fatalf("unexpected grants: %+v", grants)
	}
	if !grants.Video.RoomJoin || grants.Video.Room != "mx__room_m_example" {
		t.Fatalf("unexpected video grant: %+v", grants.Video)
	}
}

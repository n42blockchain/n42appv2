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
	userID     string
	whoErr     error
	joinErr    error
	creator    string
	creatorErr error
}

func (f fakeMatrixVerifier) WhoAmI(context.Context, string) (string, error) {
	return f.userID, f.whoErr
}

func (f fakeMatrixVerifier) RequireJoined(context.Context, string, string, string) error {
	return f.joinErr
}

func (f fakeMatrixVerifier) RoomCreator(
	context.Context,
	string,
	string,
) (string, error) {
	return f.creator, f.creatorErr
}

// capturingIssuer records the request the handler resolved, so tests can
// assert on the publish decision rather than only on the returned string.
type capturingIssuer struct {
	token string
	last  tokenRequest
}

func (c *capturingIssuer) Issue(request tokenRequest) (string, error) {
	c.last = request
	return c.token, nil
}

func publishDecision(t *testing.T, role, identity, creator string) bool {
	t.Helper()
	issuer := &capturingIssuer{token: "tok"}
	handler := tokenHandler{
		matrix: fakeMatrixVerifier{userID: identity, creator: creator},
		issuer: issuer,
	}
	const conversation = "!live:m.example"
	body, err := json.Marshal(map[string]any{
		"room":            buildLiveKitRoomName(conversation),
		"identity":        identity,
		"name":            "display",
		"video":           true,
		"conversation_id": conversation,
		"role":            role,
	})
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	request := httptest.NewRequest(http.MethodPost, "/livekit/jwt", strings.NewReader(string(body)))
	request.Header.Set("Authorization", "Bearer matrix-token")
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, request)
	if recorder.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", recorder.Code, recorder.Body.String())
	}
	return issuer.last.canPublish
}

func TestBroadcasterPublishesOnlyWhenRoomCreator(t *testing.T) {
	const streamer = "@streamer:m.example"
	if !publishDecision(t, "broadcaster", streamer, streamer) {
		t.Fatal("the room creator claiming broadcaster must be allowed to publish")
	}
}

func TestViewerNeverPublishes(t *testing.T) {
	if publishDecision(t, "viewer", "@viewer:m.example", "@streamer:m.example") {
		t.Fatal("a viewer must never receive a publish grant")
	}
}

// The whole point of the server-side check: the role field is attacker
// controlled, so a viewer sending role=broadcaster must still be denied.
func TestForgedBroadcasterRoleIsDenied(t *testing.T) {
	if publishDecision(t, "broadcaster", "@viewer:m.example", "@streamer:m.example") {
		t.Fatal("a non-creator claiming broadcaster must not be able to publish")
	}
}

func TestUnknownRoleIsTreatedAsViewer(t *testing.T) {
	const streamer = "@streamer:m.example"
	if publishDecision(t, "co-host", streamer, streamer) {
		t.Fatal("an unrecognised role must not grant publish rights")
	}
}

// Group calls send no role at all and every participant publishes; that
// behaviour must survive this change.
func TestRolelessRequestKeepsPublishing(t *testing.T) {
	const user = "@member:m.example"
	if !publishDecision(t, "", user, "@someone-else:m.example") {
		t.Fatal("a request without a role must keep the historical grant")
	}
}

// A room whose creator cannot be resolved must fail closed for live roles
// rather than silently handing out a publish grant.
func TestUnresolvableCreatorDeniesPublish(t *testing.T) {
	issuer := &capturingIssuer{token: "tok"}
	handler := tokenHandler{
		matrix: fakeMatrixVerifier{
			userID:     "@streamer:m.example",
			creatorErr: errMatrixNoCreator,
		},
		issuer: issuer,
	}
	const conversation = "!live:m.example"
	body, _ := json.Marshal(map[string]any{
		"room":            buildLiveKitRoomName(conversation),
		"identity":        "@streamer:m.example",
		"conversation_id": conversation,
		"role":            "broadcaster",
	})
	request := httptest.NewRequest(http.MethodPost, "/livekit/jwt", strings.NewReader(string(body)))
	request.Header.Set("Authorization", "Bearer matrix-token")
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, request)
	if recorder.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", recorder.Code)
	}
	if issuer.last.canPublish {
		t.Fatal("an unresolvable creator must not grant publish rights")
	}
}

// Ensures the decision actually reaches the signed JWT, not just the struct.
func TestIssuedJWTCarriesViewerRestriction(t *testing.T) {
	issuer := liveKitIssuer{apiKey: "key", apiSecret: "secret-secret-secret-secret", ttl: time.Minute}
	jwt, err := issuer.Issue(tokenRequest{
		Room:       "live-room",
		Identity:   "@viewer:m.example",
		Role:       "viewer",
		canPublish: false,
	})
	if err != nil {
		t.Fatalf("issue: %v", err)
	}
	verifier, err := auth.ParseAPIToken(jwt)
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	_, grants, err := verifier.Verify("secret-secret-secret-secret")
	if err != nil {
		t.Fatalf("verify: %v", err)
	}
	if grants.Video.CanPublish == nil || *grants.Video.CanPublish {
		t.Fatal("viewer JWT must carry CanPublish=false")
	}
	if grants.Video.CanSubscribe == nil || !*grants.Video.CanSubscribe {
		t.Fatal("viewer JWT must still allow subscribing")
	}
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

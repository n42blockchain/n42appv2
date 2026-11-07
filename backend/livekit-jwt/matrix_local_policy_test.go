package main

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/livekit/protocol/auth"
)

// Explicit opt-in against the owned disposable container only. No production
// accounts, existing user credentials or real SFU signing keys are accepted.
func TestLocalMatrixLivePolicy(t *testing.T) {
	const base = "http://127.0.0.1:18949"
	if os.Getenv("N42_MATRIX_LOCAL_POLICY_QA") != "true" {
		t.Skip("requires owned disposable Matrix container")
	}
	invite := os.Getenv("N42_MATRIX_LOCAL_REGISTRATION_TOKEN")
	if invite == "" {
		t.Fatal("disposable registration token is required")
	}
	client := &http.Client{Timeout: 15 * time.Second}
	request := func(method, path, token string, body any) (int, map[string]any) {
		data, err := json.Marshal(body)
		if err != nil {
			t.Fatal("cannot encode request")
		}
		req, err := http.NewRequest(method, base+path, bytes.NewReader(data))
		if err != nil {
			t.Fatal("invalid local request")
		}
		req.Header.Set("Content-Type", "application/json")
		if token != "" {
			req.Header.Set("Authorization", "Bearer "+token)
		}
		resp, err := client.Do(req)
		if err != nil {
			t.Fatal("local homeserver unavailable")
		}
		defer resp.Body.Close()
		var result map[string]any
		if err = json.NewDecoder(resp.Body).Decode(&result); err != nil {
			t.Fatal("invalid local response")
		}
		return resp.StatusCode, result
	}
	type account struct{ user, token, password string }
	accounts := []account{}
	t.Cleanup(func() {
		for _, a := range accounts {
			status, _ := request(http.MethodPost, "/_matrix/client/v3/account/deactivate", a.token, map[string]any{"auth": map[string]any{"type": "m.login.password", "identifier": map[string]string{"type": "m.id.user", "user": a.user}, "password": a.password}})
			if status != 200 {
				t.Error("owned synthetic account cleanup failed")
			}
		}
	})
	for i := 0; i < 3; i++ {
		entropy := make([]byte, 24)
		if _, err := rand.Read(entropy); err != nil {
			t.Fatal("entropy unavailable")
		}
		password := hex.EncodeToString(entropy)
		username := "n42policy" + password[:16]
		a := map[string]any{"type": "m.login.registration_token", "token": invite}
		body := map[string]any{"username": username, "password": password, "auth": a}
		status, result := request(http.MethodPost, "/_matrix/client/v3/register", "", body)
		if status == 401 {
			a["session"] = result["session"]
			status, result = request(http.MethodPost, "/_matrix/client/v3/register", "", body)
		}
		if status != 200 {
			t.Fatalf("synthetic registration status %d", status)
		}
		user, _ := result["user_id"].(string)
		token, _ := result["access_token"].(string)
		if user == "" || token == "" {
			t.Fatal("synthetic registration incomplete")
		}
		accounts = append(accounts, account{user, token, password})
	}
	owner, viewer, outsider := accounts[0], accounts[1], accounts[2]
	makeRoom := func(live bool) string {
		body := map[string]any{"room_version": "11", "preset": "private_chat", "invite": []string{viewer.user}}
		if live {
			body["initial_state"] = []any{map[string]any{"type": "n42.live.status", "state_key": "", "content": map[string]bool{"live": false}}}
		}
		status, result := request(http.MethodPost, "/_matrix/client/v3/createRoom", owner.token, body)
		if status != 200 {
			t.Fatalf("create status %d", status)
		}
		room, _ := result["room_id"].(string)
		if room == "" {
			t.Fatal("missing room")
		}
		status, _ = request(http.MethodPost, "/_matrix/client/v3/join/"+url.PathEscape(room), viewer.token, map[string]any{})
		if status != 200 {
			t.Fatalf("join status %d", status)
		}
		return room
	}
	live, ordinary := makeRoom(true), makeRoom(false)
	const secret = "synthetic-policy-signing-secret-not-production"
	handler := tokenHandler{matrix: &matrixClient{homeserver: base, httpClient: client}, issuer: liveKitIssuer{apiKey: "synthetic", apiSecret: secret, ttl: time.Minute}}
	cases := []struct {
		name       string
		a          account
		room, role string
		status     int
		publish    bool
	}{
		{"owner", owner, live, "broadcaster", 200, true},
		{"owner viewer role", owner, live, "viewer", 200, false},
		{"viewer forged broadcaster", viewer, live, "broadcaster", 200, false},
		{"viewer omitted role", viewer, live, "", 200, false},
		{"nonmember", outsider, live, "broadcaster", 403, false},
		{"ordinary group participant", viewer, ordinary, "", 200, true},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			body, _ := json.Marshal(map[string]any{"room": buildLiveKitRoomName(tc.room), "identity": tc.a.user, "conversation_id": tc.room, "role": tc.role})
			req := httptest.NewRequest(http.MethodPost, "/livekit/jwt", bytes.NewReader(body))
			req.Header.Set("Authorization", "Bearer "+tc.a.token)
			resp := httptest.NewRecorder()
			handler.ServeHTTP(resp, req)
			if resp.Code != tc.status {
				t.Fatalf("status %d, expected %d", resp.Code, tc.status)
			}
			if tc.status != 200 {
				return
			}
			var result struct {
				Token string `json:"token"`
			}
			if err := json.Unmarshal(resp.Body.Bytes(), &result); err != nil {
				t.Fatal("invalid issuer response")
			}
			verifier, err := auth.ParseAPIToken(strings.TrimSpace(result.Token))
			if err != nil {
				t.Fatal("invalid signed token")
			}
			_, grants, err := verifier.Verify(secret)
			if err != nil {
				t.Fatal("token signature invalid")
			}
			if grants.Video == nil || grants.Video.CanPublish == nil || *grants.Video.CanPublish != tc.publish || grants.Video.CanSubscribe == nil || !*grants.Video.CanSubscribe {
				t.Fatal("incorrect media policy")
			}
		})
	}
}

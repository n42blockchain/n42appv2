package main

import (
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

const testSecret = "synthetic-offline-test-secret-not-production"

func fixture(t *testing.T, change func(jwt.MapClaims)) string {
	t.Helper()
	claims := jwt.MapClaims{"iss": "qa-key", "sub": "qa-viewer", "exp": time.Now().Add(time.Hour).Unix(), "nbf": time.Now().Add(-time.Minute).Unix(), "video": map[string]any{"roomJoin": true, "room": "qa-room", "canPublish": false, "canSubscribe": true}}
	if change != nil {
		change(claims)
	}
	token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte(testSecret))
	if err != nil {
		t.Fatal("cannot create synthetic token")
	}
	return token
}

func TestPolicyVerification(t *testing.T) {
	cases := []struct {
		name   string
		change func(jwt.MapClaims)
		mutate func(*expectation)
		secret string
		ok     bool
	}{
		{name: "viewer", ok: true},
		{name: "publisher", change: func(c jwt.MapClaims) { c["video"].(map[string]any)["canPublish"] = true }, mutate: func(e *expectation) { e.publish = true }, ok: true},
		{name: "wrong secret", secret: "different-test-secret"},
		{name: "wrong issuer", mutate: func(e *expectation) { e.issuer = "other-key" }},
		{name: "wrong identity", mutate: func(e *expectation) { e.identity = "other-viewer" }},
		{name: "wrong room", mutate: func(e *expectation) { e.room = "other-room" }},
		{name: "publish escalation", change: func(c jwt.MapClaims) { c["video"].(map[string]any)["canPublish"] = true }},
		{name: "implicit publish", change: func(c jwt.MapClaims) { delete(c["video"].(map[string]any), "canPublish") }},
		{name: "missing media grant", change: func(c jwt.MapClaims) { delete(c, "video") }},
		{name: "cannot subscribe", change: func(c jwt.MapClaims) { c["video"].(map[string]any)["canSubscribe"] = false }},
		{name: "no room join", change: func(c jwt.MapClaims) { c["video"].(map[string]any)["roomJoin"] = false }},
		{name: "room admin", change: func(c jwt.MapClaims) { c["video"].(map[string]any)["roomAdmin"] = true }},
		{name: "ingress admin", change: func(c jwt.MapClaims) { c["video"].(map[string]any)["ingressAdmin"] = true }},
		{name: "SIP privilege", change: func(c jwt.MapClaims) { c["sip"] = map[string]any{"admin": true} }},
		{name: "expired", change: func(c jwt.MapClaims) { c["exp"] = time.Now().Add(-time.Second).Unix() }},
		{name: "missing expiry", change: func(c jwt.MapClaims) { delete(c, "exp") }},
		{name: "future token", change: func(c jwt.MapClaims) { c["nbf"] = time.Now().Add(time.Hour).Unix() }},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			token := fixture(t, tc.change)
			expected := expectation{"qa-key", "qa-viewer", "qa-room", false}
			if tc.mutate != nil {
				tc.mutate(&expected)
			}
			secret := testSecret
			if tc.secret != "" {
				secret = tc.secret
			}
			err := checkToken(token, secret, expected, time.Now())
			if (err == nil) != tc.ok {
				t.Fatalf("unexpected acceptance: %v", err)
			}
			if err != nil && (strings.Contains(err.Error(), token) || strings.Contains(err.Error(), secret)) {
				t.Fatal("credential leaked in error")
			}
		})
	}
}

func TestCommandDoesNotPrintCredentials(t *testing.T) {
	path := filepath.Join(t.TempDir(), "secret")
	if err := os.WriteFile(path, []byte(testSecret+"\n"), 0600); err != nil {
		t.Fatal("cannot write synthetic key")
	}
	token := fixture(t, nil)
	args := []string{"--secret-file", path, "--issuer", "qa-key", "--identity", "qa-viewer", "--room", "qa-room", "--publish=false"}
	var out, stderr bytes.Buffer
	if code := run(args, strings.NewReader(token), &out, &stderr); code != 0 {
		t.Fatalf("verification failed, code %d", code)
	}
	if !strings.Contains(out.String(), `"signatureVerified":true`) {
		t.Fatal("missing verified result")
	}
	if strings.Contains(out.String()+stderr.String(), token) || strings.Contains(out.String()+stderr.String(), testSecret) || strings.Contains(out.String(), "qa-viewer") {
		t.Fatal("credential or participant leaked")
	}
	for _, in := range []string{"invalid-token", strings.Repeat("x", maxCredentialBytes+1)} {
		out.Reset()
		stderr.Reset()
		if run(args, strings.NewReader(in), &out, &stderr) == 0 {
			t.Fatal("invalid input accepted")
		}
		if out.Len() != 0 || strings.Contains(stderr.String(), in) {
			t.Fatal("invalid input leaked")
		}
	}
	out.Reset()
	stderr.Reset()
	if run(args[:len(args)-1], strings.NewReader(token), &out, &stderr) == 0 {
		t.Fatal("implicit expected role accepted")
	}
}

func TestUnsignedTokenIsRejected(t *testing.T) {
	token, err := jwt.NewWithClaims(jwt.SigningMethodNone, jwt.MapClaims{
		"iss": "qa-key", "sub": "qa-viewer", "exp": time.Now().Add(time.Hour).Unix(),
		"video": map[string]any{"roomJoin": true, "room": "qa-room", "canPublish": false, "canSubscribe": true},
	}).SignedString(jwt.UnsafeAllowNoneSignatureType)
	if err != nil {
		t.Fatal("cannot create unsigned synthetic fixture")
	}
	if checkToken(token, testSecret, expectation{"qa-key", "qa-viewer", "qa-room", false}, time.Now()) == nil {
		t.Fatal("unsigned token accepted")
	}
}

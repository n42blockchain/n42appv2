package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"sort"
	"strconv"
	"strings"
	"testing"
	"time"
)

func testCfg() *Config {
	return &Config{
		MatrixHomeserver:     "https://m.example.org",
		MatrixSharedSecret:   "shared-secret",
		MatrixPasswordSecret: "pw-secret",
		TelegramBotToken:     "123456:BOT-TOKEN",
		TelegramAuthTTL:      86400 * time.Second,
	}
}

// 用与实现相同的算法造一个合法 Telegram hash,验证校验通过。
func validTelegramHash(botToken string, fields map[string]string) string {
	keys := make([]string, 0, len(fields))
	for k, v := range fields {
		if v != "" {
			keys = append(keys, k)
		}
	}
	sort.Strings(keys)
	parts := make([]string, 0, len(keys))
	for _, k := range keys {
		parts = append(parts, k+"="+fields[k])
	}
	dataCheck := strings.Join(parts, "\n")
	secret := sha256.Sum256([]byte(botToken))
	mac := hmac.New(sha256.New, secret[:])
	mac.Write([]byte(dataCheck))
	return hex.EncodeToString(mac.Sum(nil))
}

func TestVerifyTelegram_ValidHash(t *testing.T) {
	cfg := testCfg()
	now := strconv.FormatInt(time.Now().Unix(), 10)
	fields := map[string]string{
		"id":        "42",
		"auth_date": now,
		"username":  "alice",
	}
	hash := validTelegramHash(cfg.TelegramBotToken, fields)
	req := &LoginSocialRequest{
		Provider: "telegram", TelegramID: "42", TelegramAuthDate: now,
		TelegramUsername: "alice", TelegramHash: hash,
	}
	id, err := verifyTelegram(cfg, req)
	if err != nil {
		t.Fatalf("expected valid, got %v", err)
	}
	if id.UID != "42" || id.Username != "alice" {
		t.Fatalf("bad identity: %+v", id)
	}
}

func TestVerifyTelegram_TamperedHash(t *testing.T) {
	cfg := testCfg()
	now := strconv.FormatInt(time.Now().Unix(), 10)
	req := &LoginSocialRequest{
		Provider: "telegram", TelegramID: "42", TelegramAuthDate: now,
		TelegramUsername: "alice", TelegramHash: "deadbeef",
	}
	if _, err := verifyTelegram(cfg, req); err == nil {
		t.Fatal("expected hash mismatch error")
	}
}

func TestVerifyTelegramRejectsTamperedIdentityFields(t *testing.T) {
	cfg := testCfg()
	now := strconv.FormatInt(time.Now().Unix(), 10)
	fields := map[string]string{
		"id":        "42",
		"auth_date": now,
		"username":  "alice",
	}
	req := &LoginSocialRequest{
		Provider: "telegram", TelegramID: "42", TelegramAuthDate: now,
		TelegramUsername: "mallory", TelegramHash: validTelegramHash(cfg.TelegramBotToken, fields),
	}
	if _, err := verifyTelegram(cfg, req); err == nil {
		t.Fatal("a valid signature for a different username must not authenticate the request")
	}
}

func TestVerifyTelegramRejectsMalformedSignedAuthDate(t *testing.T) {
	cfg := testCfg()
	fields := map[string]string{"id": "42", "auth_date": "not-a-timestamp"}
	req := &LoginSocialRequest{
		Provider: "telegram", TelegramID: "42", TelegramAuthDate: fields["auth_date"],
		TelegramHash: validTelegramHash(cfg.TelegramBotToken, fields),
	}
	if _, err := verifyTelegram(cfg, req); err == nil {
		t.Fatal("a correctly signed but malformed auth_date must be rejected")
	}
}

func TestVerifyTelegram_Expired(t *testing.T) {
	cfg := testCfg()
	old := strconv.FormatInt(time.Now().Unix()-100000, 10) // > 24h
	fields := map[string]string{"id": "42", "auth_date": old, "username": "alice"}
	hash := validTelegramHash(cfg.TelegramBotToken, fields)
	req := &LoginSocialRequest{
		Provider: "telegram", TelegramID: "42", TelegramAuthDate: old,
		TelegramUsername: "alice", TelegramHash: hash,
	}
	if _, err := verifyTelegram(cfg, req); err == nil {
		t.Fatal("expected expired error")
	}
}

func TestDeriveLocalpart_StableAndLegal(t *testing.T) {
	id := &ProviderIdentity{Provider: "discord", UID: "99887766"}
	lp1 := deriveLocalpart(id)
	lp2 := deriveLocalpart(id)
	if lp1 != lp2 {
		t.Fatal("localpart must be deterministic")
	}
	if !strings.HasPrefix(lp1, "s_discord_") {
		t.Fatalf("unexpected localpart %q", lp1)
	}
	// Matrix localpart 合法字符集
	for _, c := range lp1 {
		ok := (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') ||
			c == '.' || c == '_' || c == '=' || c == '/' || c == '-'
		if !ok {
			t.Fatalf("illegal char %q in localpart %q", c, lp1)
		}
	}
	// 不同 provider/uid → 不同 localpart(防撞)
	other := deriveLocalpart(&ProviderIdentity{Provider: "github", UID: "99887766"})
	if other == lp1 {
		t.Fatal("different provider must yield different localpart")
	}
}

func TestDerivePassword_DeterministicPerIdentity(t *testing.T) {
	cfg := testCfg()
	a := derivePassword(cfg, &ProviderIdentity{Provider: "github", UID: "1"})
	b := derivePassword(cfg, &ProviderIdentity{Provider: "github", UID: "1"})
	c := derivePassword(cfg, &ProviderIdentity{Provider: "github", UID: "2"})
	if a != b {
		t.Fatal("password must be deterministic per identity")
	}
	if a == c {
		t.Fatal("different uid must yield different password")
	}
	if len(a) != 64 {
		t.Fatalf("expected 64-hex sha256 hmac, got len %d", len(a))
	}
}

func TestVerifyProvider_Unsupported(t *testing.T) {
	if _, err := verifyProvider(testCfg(), &LoginSocialRequest{Provider: "myspace"}); err == nil {
		t.Fatal("expected unsupported provider error")
	}
}

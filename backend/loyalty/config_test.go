package main

import (
	"strings"
	"testing"
)

func setValidConfigEnv(t *testing.T) {
	t.Helper()
	t.Setenv("PORT", "")
	t.Setenv("DB_DSN", "postgres://test/db")
	t.Setenv("N42_RPC_URL", "https://rpc.example.test")
	t.Setenv("LOYALTY_CONTRACT_ADDRESS", "0x1111111111111111111111111111111111111111")
	t.Setenv("RELAYER_PRIVATE_KEY", strings.Repeat("1", 64))
	t.Setenv("AUTH_VERIFY_URL", "https://auth.example.test/verify")
	t.Setenv("INTERNAL_API_TOKEN", strings.Repeat("t", 32))
}

func TestLoadConfigUsesDefaultPortAndRequiredSettings(t *testing.T) {
	setValidConfigEnv(t)
	cfg, err := loadConfig()
	if err != nil {
		t.Fatalf("load valid configuration: %v", err)
	}
	if cfg.Port != "8080" {
		t.Fatalf("default port = %q, want 8080", cfg.Port)
	}
	if cfg.AuthVerifyURL != "https://auth.example.test/verify" {
		t.Fatalf("auth verify URL = %q", cfg.AuthVerifyURL)
	}
}

func TestLoadConfigRejectsMissingRequiredSetting(t *testing.T) {
	setValidConfigEnv(t)
	t.Setenv("N42_RPC_URL", "")

	if _, err := loadConfig(); err == nil || !strings.Contains(err.Error(), "N42_RPC_URL") {
		t.Fatalf("loadConfig error = %v, want missing N42_RPC_URL", err)
	}
}

func TestLoadConfigRejectsShortInternalToken(t *testing.T) {
	setValidConfigEnv(t)
	t.Setenv("INTERNAL_API_TOKEN", strings.Repeat("t", 31))

	if _, err := loadConfig(); err == nil || !strings.Contains(err.Error(), "at least 32 characters") {
		t.Fatalf("loadConfig error = %v, want minimum token length error", err)
	}
}

func TestLoadConfigAcceptsExplicitPort(t *testing.T) {
	setValidConfigEnv(t)
	t.Setenv("PORT", "9088")

	cfg, err := loadConfig()
	if err != nil {
		t.Fatalf("load explicit configuration: %v", err)
	}
	if cfg.Port != "9088" {
		t.Fatalf("port = %q, want 9088", cfg.Port)
	}
}

package main

import (
	"testing"
	"time"
)

func setSocialAuthRequiredEnv(t *testing.T) {
	t.Helper()
	t.Setenv("MATRIX_HOMESERVER", "https://matrix.example.test///")
	t.Setenv("MATRIX_SHARED_SECRET", "registration-secret")
	t.Setenv("MATRIX_PASSWORD_SECRET", "password-secret")
}

func TestLoadConfigNormalizesRequiredValuesAndDefaults(t *testing.T) {
	setSocialAuthRequiredEnv(t)
	t.Setenv("PORT", "")
	t.Setenv("TELEGRAM_AUTH_TTL_SECONDS", "")
	t.Setenv("CORS_ORIGINS", "")

	cfg := loadConfig()
	if cfg.Port != "8090" || cfg.MatrixHomeserver != "https://matrix.example.test" {
		t.Fatalf("config defaults/normalization = port %q, homeserver %q", cfg.Port, cfg.MatrixHomeserver)
	}
	if cfg.TelegramAuthTTL != 24*time.Hour {
		t.Fatalf("default Telegram auth TTL = %s, want 24h", cfg.TelegramAuthTTL)
	}
}

func TestLoadConfigParsesOptionalTTLAndCORSOrigins(t *testing.T) {
	setSocialAuthRequiredEnv(t)
	t.Setenv("PORT", "9091")
	t.Setenv("TELEGRAM_AUTH_TTL_SECONDS", "3600")
	t.Setenv("CORS_ORIGINS", "https://app.example.test, https://admin.example.test")

	cfg := loadConfig()
	if cfg.Port != "9091" || cfg.TelegramAuthTTL != time.Hour {
		t.Fatalf("config values = port %q, TTL %s", cfg.Port, cfg.TelegramAuthTTL)
	}
	if len(cfg.CORSOrigins) != 2 || !cfg.CORSOrigins["https://app.example.test"] || !cfg.CORSOrigins["https://admin.example.test"] {
		t.Fatalf("CORS origins = %#v, want both trimmed origins", cfg.CORSOrigins)
	}
}

func TestLoadConfigFallsBackForMalformedOptionalTTL(t *testing.T) {
	setSocialAuthRequiredEnv(t)
	t.Setenv("TELEGRAM_AUTH_TTL_SECONDS", "not-a-number")
	t.Setenv("CORS_ORIGINS", "")

	cfg := loadConfig()
	if cfg.TelegramAuthTTL != 24*time.Hour {
		t.Fatalf("malformed optional TTL = %s, want 24h default", cfg.TelegramAuthTTL)
	}
}

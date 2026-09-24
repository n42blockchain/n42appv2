package main

import (
	"testing"
	"time"
)

func setValidConfigEnvironment(t *testing.T) {
	t.Helper()
	for _, key := range []string{"PORT", "TOKEN_TTL", "MATRIX_HOMESERVER", "LIVEKIT_API_KEY", "LIVEKIT_API_SECRET"} {
		t.Setenv(key, "")
	}
	t.Setenv("MATRIX_HOMESERVER", " https://matrix.example.org/// ")
	t.Setenv("LIVEKIT_API_KEY", " test-key ")
	t.Setenv("LIVEKIT_API_SECRET", " test-secret ")
}

func TestLoadConfigDefaultsAndNormalization(t *testing.T) {
	setValidConfigEnvironment(t)

	cfg, err := loadConfig()
	if err != nil {
		t.Fatalf("loadConfig() error = %v", err)
	}
	if cfg.Port != 8080 || cfg.TokenTTL != 15*time.Minute {
		t.Fatalf("unexpected defaults: port=%d ttl=%s", cfg.Port, cfg.TokenTTL)
	}
	if cfg.MatrixHomeserver != "https://matrix.example.org" || cfg.LiveKitAPIKey != "test-key" || cfg.LiveKitAPISecret != "test-secret" {
		t.Fatalf("environment values were not normalized: %+v", cfg)
	}
}

func TestLoadConfigAcceptsBoundaryOverrides(t *testing.T) {
	setValidConfigEnvironment(t)
	t.Setenv("PORT", " 65535 ")
	t.Setenv("TOKEN_TTL", "1h")

	cfg, err := loadConfig()
	if err != nil {
		t.Fatalf("loadConfig() error = %v", err)
	}
	if cfg.Port != 65535 || cfg.TokenTTL != time.Hour {
		t.Fatalf("boundary overrides not applied: port=%d ttl=%s", cfg.Port, cfg.TokenTTL)
	}
}

func TestLoadConfigRejectsInvalidPortAndTokenTTL(t *testing.T) {
	for _, port := range []string{"not-a-number", "0", "65536"} {
		t.Run("port/"+port, func(t *testing.T) {
			setValidConfigEnvironment(t)
			t.Setenv("PORT", port)
			if _, err := loadConfig(); err == nil {
				t.Fatal("loadConfig() accepted invalid PORT")
			}
		})
	}
	for _, ttl := range []string{"not-a-duration", "59s", "61m"} {
		t.Run("ttl/"+ttl, func(t *testing.T) {
			setValidConfigEnvironment(t)
			t.Setenv("TOKEN_TTL", ttl)
			if _, err := loadConfig(); err == nil {
				t.Fatal("loadConfig() accepted invalid TOKEN_TTL")
			}
		})
	}
}

func TestLoadConfigRequiresMatrixAndLiveKitSettings(t *testing.T) {
	for _, key := range []string{"MATRIX_HOMESERVER", "LIVEKIT_API_KEY", "LIVEKIT_API_SECRET"} {
		t.Run(key, func(t *testing.T) {
			setValidConfigEnvironment(t)
			t.Setenv(key, " ")
			if _, err := loadConfig(); err == nil {
				t.Fatalf("loadConfig() accepted missing %s", key)
			}
		})
	}
}

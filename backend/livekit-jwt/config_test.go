package main

import (
	"testing"
	"time"
)

func setRequiredConfig(t *testing.T) {
	t.Helper()
	t.Setenv("MATRIX_HOMESERVER", " https://matrix.example/ ")
	t.Setenv("LIVEKIT_API_KEY", " key ")
	t.Setenv("LIVEKIT_API_SECRET", " secret ")
	t.Setenv("PORT", "")
	t.Setenv("TOKEN_TTL", "")
}

func TestLoadConfigUsesSafeDefaultsAndTrimsValues(t *testing.T) {
	setRequiredConfig(t)

	cfg, err := loadConfig()
	if err != nil {
		t.Fatalf("loadConfig() error = %v", err)
	}
	if cfg.Port != 8080 || cfg.TokenTTL != 15*time.Minute {
		t.Fatalf("unexpected defaults: port=%d ttl=%s", cfg.Port, cfg.TokenTTL)
	}
	if cfg.MatrixHomeserver != "https://matrix.example" || cfg.LiveKitAPIKey != "key" || cfg.LiveKitAPISecret != "secret" {
		t.Fatalf("values were not normalized: %+v", cfg)
	}
}

func TestLoadConfigAcceptsBoundaryValues(t *testing.T) {
	setRequiredConfig(t)
	t.Setenv("PORT", "65535")
	t.Setenv("TOKEN_TTL", "1h")

	cfg, err := loadConfig()
	if err != nil {
		t.Fatalf("loadConfig() error = %v", err)
	}
	if cfg.Port != 65535 || cfg.TokenTTL != time.Hour {
		t.Fatalf("boundary values not retained: port=%d ttl=%s", cfg.Port, cfg.TokenTTL)
	}
}

func TestLoadConfigRejectsInvalidPortAndTTL(t *testing.T) {
	for _, tc := range []struct {
		name string
		port string
		ttl  string
	}{
		{name: "non numeric port", port: "abc"},
		{name: "port zero", port: "0"},
		{name: "port too large", port: "65536"},
		{name: "invalid duration", ttl: "soon"},
		{name: "ttl below minimum", ttl: "59s"},
		{name: "ttl above maximum", ttl: "61m"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			setRequiredConfig(t)
			if tc.port != "" {
				t.Setenv("PORT", tc.port)
			}
			if tc.ttl != "" {
				t.Setenv("TOKEN_TTL", tc.ttl)
			}
			if _, err := loadConfig(); err == nil {
				t.Fatal("loadConfig() unexpectedly accepted invalid configuration")
			}
		})
	}
}

func TestLoadConfigRequiresAllCredentials(t *testing.T) {
	for _, key := range []string{"MATRIX_HOMESERVER", "LIVEKIT_API_KEY", "LIVEKIT_API_SECRET"} {
		t.Run(key, func(t *testing.T) {
			setRequiredConfig(t)
			t.Setenv(key, " ")
			if _, err := loadConfig(); err == nil {
				t.Fatalf("loadConfig() accepted missing %s", key)
			}
		})
	}
}

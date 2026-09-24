package main

import (
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"
)

func setSocialConfigEnv(t *testing.T) {
	t.Helper()
	for _, key := range []string{
		"PORT", "MATRIX_HOMESERVER", "MATRIX_SHARED_SECRET", "MATRIX_PASSWORD_SECRET",
		"DISCORD_CLIENT_ID", "DISCORD_CLIENT_SECRET", "GITHUB_CLIENT_ID", "GITHUB_CLIENT_SECRET",
		"TELEGRAM_BOT_TOKEN", "TELEGRAM_AUTH_TTL_SECONDS", "CORS_ORIGINS",
	} {
		t.Setenv(key, "")
	}
	t.Setenv("MATRIX_HOMESERVER", " https://matrix.example.org/// ")
	t.Setenv("MATRIX_SHARED_SECRET", "synthetic-shared-secret")
	t.Setenv("MATRIX_PASSWORD_SECRET", "synthetic-password-secret")
}

func TestLoadConfigDefaultsAndOptionalProviderValues(t *testing.T) {
	setSocialConfigEnv(t)

	cfg := loadConfig()
	if cfg.Port != "8090" || cfg.TelegramAuthTTL != 24*time.Hour {
		t.Fatalf("unexpected defaults: port=%q ttl=%s", cfg.Port, cfg.TelegramAuthTTL)
	}
	if cfg.MatrixHomeserver != "https://matrix.example.org" || cfg.CORSOrigins == nil || len(cfg.CORSOrigins) != 0 {
		t.Fatalf("unexpected normalized/default values: %+v", cfg)
	}
	if cfg.DiscordClientID != "" || cfg.GithubClientSecret != "" || cfg.TelegramBotToken != "" {
		t.Fatalf("optional provider credentials should remain unset: %+v", cfg)
	}
}

func TestLoadConfigReadsPortProviderTTLAndCORSOverrides(t *testing.T) {
	setSocialConfigEnv(t)
	t.Setenv("PORT", "8099")
	t.Setenv("DISCORD_CLIENT_ID", "discord-client")
	t.Setenv("DISCORD_CLIENT_SECRET", "synthetic-discord-secret")
	t.Setenv("GITHUB_CLIENT_ID", "github-client")
	t.Setenv("GITHUB_CLIENT_SECRET", "synthetic-github-secret")
	t.Setenv("TELEGRAM_BOT_TOKEN", "synthetic-bot-token")
	t.Setenv("TELEGRAM_AUTH_TTL_SECONDS", "3600")
	t.Setenv("CORS_ORIGINS", "https://app.example, https://admin.example")

	cfg := loadConfig()
	if cfg.Port != "8099" || cfg.TelegramAuthTTL != time.Hour {
		t.Fatalf("overrides not applied: port=%q ttl=%s", cfg.Port, cfg.TelegramAuthTTL)
	}
	if cfg.DiscordClientID != "discord-client" || cfg.GithubClientSecret != "synthetic-github-secret" || cfg.TelegramBotToken != "synthetic-bot-token" {
		t.Fatalf("provider configuration not loaded: %+v", cfg)
	}
	if !cfg.CORSOrigins["https://app.example"] || !cfg.CORSOrigins["https://admin.example"] {
		t.Fatalf("CORS origins not parsed: %#v", cfg.CORSOrigins)
	}
}

func TestLoadConfigInvalidTelegramTTLFallsBackToDefault(t *testing.T) {
	setSocialConfigEnv(t)
	for _, raw := range []string{"invalid", "0", "-1", "999999999999999999999999999999"} {
		t.Run(raw, func(t *testing.T) {
			setSocialConfigEnv(t)
			t.Setenv("TELEGRAM_AUTH_TTL_SECONDS", raw)
			if got := loadConfig().TelegramAuthTTL; got != 24*time.Hour {
				t.Fatalf("invalid TTL selected %s, want 24h fallback", got)
			}
		})
	}
}

func TestLoadConfigMissingRequiredVariableExits(t *testing.T) {
	if os.Getenv("N42_TEST_MISSING_SOCIAL_CONFIG") != "" {
		loadConfig()
		return
	}

	for _, missing := range []string{"MATRIX_HOMESERVER", "MATRIX_SHARED_SECRET", "MATRIX_PASSWORD_SECRET"} {
		t.Run(missing, func(t *testing.T) {
			cmd := exec.Command(os.Args[0], "-test.run=^TestLoadConfigMissingRequiredVariableExits$")
			cmd.Env = []string{
				"N42_TEST_MISSING_SOCIAL_CONFIG=" + missing,
				"MATRIX_HOMESERVER=https://matrix.example.org",
				"MATRIX_SHARED_SECRET=synthetic-shared-secret",
				"MATRIX_PASSWORD_SECRET=synthetic-password-secret",
			}
			for i := range cmd.Env {
				if strings.HasPrefix(cmd.Env[i], missing+"=") {
					cmd.Env[i] = missing + "="
				}
			}
			output, err := cmd.CombinedOutput()
			exitErr, ok := err.(*exec.ExitError)
			if !ok || exitErr.ExitCode() != 1 {
				t.Fatalf("subprocess error=%v output=%q, want exit status 1", err, output)
			}
			wantDiagnostic := "required env var \"" + missing + "\" is not set"
			if !strings.Contains(string(output), wantDiagnostic) {
				t.Fatalf("subprocess output=%q, want diagnostic %q", output, wantDiagnostic)
			}
		})
	}
}

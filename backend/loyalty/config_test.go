package main

import (
	"strings"
	"testing"
)

var loyaltyConfigEnv = map[string]string{
	"PORT":                     "",
	"DB_DSN":                   "postgres://test.invalid/db",
	"N42_RPC_URL":              "https://rpc.test.invalid",
	"LOYALTY_CONTRACT_ADDRESS": "0x1111111111111111111111111111111111111111",
	"RELAYER_PRIVATE_KEY":      "0x" + strings.Repeat("1", 64),
	"AUTH_VERIFY_URL":          "https://auth.test.invalid/verify",
	"INTERNAL_API_TOKEN":       strings.Repeat("t", 32),
}

func setLoyaltyConfigEnv(t *testing.T, omitted string) {
	t.Helper()
	for key, value := range loyaltyConfigEnv {
		if key == omitted {
			value = ""
		}
		t.Setenv(key, value)
	}
}

func TestLoadConfigDefaultsAndReadsRequiredValues(t *testing.T) {
	setLoyaltyConfigEnv(t, "")

	cfg, err := loadConfig()
	if err != nil {
		t.Fatalf("loadConfig() error = %v", err)
	}
	if cfg.Port != "8080" || cfg.DatabaseDSN != loyaltyConfigEnv["DB_DSN"] || cfg.RPCURL != loyaltyConfigEnv["N42_RPC_URL"] {
		t.Fatalf("unexpected config: %+v", cfg)
	}
	if cfg.ContractAddress != loyaltyConfigEnv["LOYALTY_CONTRACT_ADDRESS"] || cfg.RelayerPrivateKey != loyaltyConfigEnv["RELAYER_PRIVATE_KEY"] || cfg.AuthVerifyURL != loyaltyConfigEnv["AUTH_VERIFY_URL"] || cfg.InternalToken != loyaltyConfigEnv["INTERNAL_API_TOKEN"] {
		t.Fatalf("required values not loaded: %+v", cfg)
	}
}

func TestLoadConfigUsesPortOverrideAndRejectsEachMissingValue(t *testing.T) {
	t.Run("port override", func(t *testing.T) {
		setLoyaltyConfigEnv(t, "")
		t.Setenv("PORT", "9091")
		cfg, err := loadConfig()
		if err != nil || cfg.Port != "9091" {
			t.Fatalf("loadConfig() = (%+v, %v), want port 9091", cfg, err)
		}
	})
	for _, key := range []string{"DB_DSN", "N42_RPC_URL", "LOYALTY_CONTRACT_ADDRESS", "RELAYER_PRIVATE_KEY", "AUTH_VERIFY_URL", "INTERNAL_API_TOKEN"} {
		t.Run(key, func(t *testing.T) {
			setLoyaltyConfigEnv(t, key)
			_, err := loadConfig()
			if err == nil || !strings.Contains(err.Error(), key) {
				t.Fatalf("loadConfig() error = %v, want missing %s", err, key)
			}
		})
	}
}

func TestLoadConfigRequiresMinimumInternalTokenLength(t *testing.T) {
	setLoyaltyConfigEnv(t, "")
	t.Setenv("INTERNAL_API_TOKEN", strings.Repeat("t", 31))
	if _, err := loadConfig(); err == nil || !strings.Contains(err.Error(), "at least 32") {
		t.Fatalf("loadConfig() error = %v, want minimum-length rejection", err)
	}
}

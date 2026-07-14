package main

import (
	"fmt"
	"os"
)

type config struct {
	Port              string
	DatabaseDSN       string
	RPCURL            string
	ContractAddress   string
	RelayerPrivateKey string
	AuthVerifyURL     string
	InternalToken     string
}

func loadConfig() (config, error) {
	cfg := config{
		Port:              env("PORT", "8080"),
		DatabaseDSN:       os.Getenv("DB_DSN"),
		RPCURL:            os.Getenv("N42_RPC_URL"),
		ContractAddress:   os.Getenv("LOYALTY_CONTRACT_ADDRESS"),
		RelayerPrivateKey: os.Getenv("RELAYER_PRIVATE_KEY"),
		AuthVerifyURL:     os.Getenv("AUTH_VERIFY_URL"),
		InternalToken:     os.Getenv("INTERNAL_API_TOKEN"),
	}
	for name, value := range map[string]string{
		"DB_DSN":                   cfg.DatabaseDSN,
		"N42_RPC_URL":              cfg.RPCURL,
		"LOYALTY_CONTRACT_ADDRESS": cfg.ContractAddress,
		"RELAYER_PRIVATE_KEY":      cfg.RelayerPrivateKey,
		"AUTH_VERIFY_URL":          cfg.AuthVerifyURL,
		"INTERNAL_API_TOKEN":       cfg.InternalToken,
	} {
		if value == "" {
			return config{}, fmt.Errorf("required environment variable %s is empty", name)
		}
	}
	if len(cfg.InternalToken) < 32 {
		return config{}, fmt.Errorf("INTERNAL_API_TOKEN must be at least 32 characters")
	}
	return cfg, nil
}

func env(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

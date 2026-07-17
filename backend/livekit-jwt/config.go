package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
)

type config struct {
	Port             int
	MatrixHomeserver string
	LiveKitAPIKey    string
	LiveKitAPISecret string
	TokenTTL         time.Duration
}

func loadConfig() (config, error) {
	port := 8080
	if raw := strings.TrimSpace(os.Getenv("PORT")); raw != "" {
		parsed, err := strconv.Atoi(raw)
		if err != nil || parsed < 1 || parsed > 65535 {
			return config{}, fmt.Errorf("invalid PORT")
		}
		port = parsed
	}

	ttl := 15 * time.Minute
	if raw := strings.TrimSpace(os.Getenv("TOKEN_TTL")); raw != "" {
		parsed, err := time.ParseDuration(raw)
		if err != nil || parsed < time.Minute || parsed > time.Hour {
			return config{}, fmt.Errorf("TOKEN_TTL must be between 1m and 1h")
		}
		ttl = parsed
	}

	cfg := config{
		Port:             port,
		MatrixHomeserver: strings.TrimRight(strings.TrimSpace(os.Getenv("MATRIX_HOMESERVER")), "/"),
		LiveKitAPIKey:    strings.TrimSpace(os.Getenv("LIVEKIT_API_KEY")),
		LiveKitAPISecret: strings.TrimSpace(os.Getenv("LIVEKIT_API_SECRET")),
		TokenTTL:         ttl,
	}
	if cfg.MatrixHomeserver == "" || cfg.LiveKitAPIKey == "" || cfg.LiveKitAPISecret == "" {
		return config{}, fmt.Errorf("MATRIX_HOMESERVER, LIVEKIT_API_KEY, and LIVEKIT_API_SECRET are required")
	}
	return cfg, nil
}

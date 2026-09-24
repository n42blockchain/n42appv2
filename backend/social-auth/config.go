package main

import (
	"log"
	"os"
	"strings"
	"time"
)

// Config 是服务运行配置,全部来自环境变量。
type Config struct {
	Port string

	// Matrix homeserver + 账号签发。
	MatrixHomeserver     string // e.g. https://m.si46.world
	MatrixSharedSecret   string // Synapse registration_shared_secret(注册用)
	MatrixPasswordSecret string // 后端私有盐,派生每个社交账号的确定性密码

	// OAuth2 provider client 凭据(code→token 换取用;secret 只存后端)。
	DiscordClientID     string
	DiscordClientSecret string
	GithubClientID      string
	GithubClientSecret  string

	// Telegram Login Widget 校验用 bot token。
	TelegramBotToken string
	TelegramAuthTTL  time.Duration

	CORSOrigins map[string]bool
}

func loadConfig() *Config {
	cfg := &Config{
		Port:                 envOr("PORT", "8090"),
		MatrixHomeserver:     strings.TrimRight(strings.TrimSpace(mustEnv("MATRIX_HOMESERVER")), "/"),
		MatrixSharedSecret:   mustEnv("MATRIX_SHARED_SECRET"),
		MatrixPasswordSecret: mustEnv("MATRIX_PASSWORD_SECRET"),
		DiscordClientID:      os.Getenv("DISCORD_CLIENT_ID"),
		DiscordClientSecret:  os.Getenv("DISCORD_CLIENT_SECRET"),
		GithubClientID:       os.Getenv("GITHUB_CLIENT_ID"),
		GithubClientSecret:   os.Getenv("GITHUB_CLIENT_SECRET"),
		TelegramBotToken:     os.Getenv("TELEGRAM_BOT_TOKEN"),
		TelegramAuthTTL:      86400 * time.Second,
		CORSOrigins:          map[string]bool{},
	}
	if v := os.Getenv("TELEGRAM_AUTH_TTL_SECONDS"); v != "" {
		if d, err := time.ParseDuration(v + "s"); err == nil && d > 0 {
			cfg.TelegramAuthTTL = d
		}
	}
	if v := os.Getenv("CORS_ORIGINS"); v != "" {
		for _, o := range strings.Split(v, ",") {
			cfg.CORSOrigins[strings.TrimSpace(o)] = true
		}
	}
	return cfg
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func mustEnv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		log.Fatalf("required env var %q is not set", key)
	}
	return v
}

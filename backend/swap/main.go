package main

import (
	"log"
	"os"

	"github.com/n42/n42appv2/backend/swap/db"
	"github.com/n42/n42appv2/backend/swap/handlers"
	"github.com/n42/n42appv2/backend/swap/monitor"
	"github.com/n42/n42appv2/backend/swap/services"
)

func main() {
	// ─── 环境变量 ────────────────────────────────────────────────────────
	port := getEnv("PORT", "8080")
	dbDSN := mustEnv("DB_DSN")
	inchAPIKey := mustEnv("INCH_API_KEY")

	rpcURLs := map[string]string{
		"ETH":     mustEnv("ETH_RPC"),
		"BSC":     mustEnv("BSC_RPC"),
		"POLYGON": mustEnv("POLYGON_RPC"),
		"ARB":     mustEnv("ARB_RPC"),
		"OP":      mustEnv("OP_RPC"),
	}

	// ─── 数据库 ──────────────────────────────────────────────────────────
	database, err := db.New(dbDSN)
	if err != nil {
		log.Fatalf("db init: %v", err)
	}

	// ─── 服务适配器 ──────────────────────────────────────────────────────
	uniswap := services.NewUniswapAdapter(rpcURLs)
	inch := services.NewInchAdapter(inchAPIKey)
	jupiter := services.NewJupiterAdapter()

	aggregator := services.NewAggregator(uniswap, inch, jupiter)

	// ─── 监控器 ──────────────────────────────────────────────────────────
	mon := monitor.New(database, rpcURLs)

	// ─── HTTP 处理器 ─────────────────────────────────────────────────────
	quoteHandler := handlers.NewQuoteHandler(aggregator, database)
	commitHandler := handlers.NewCommitHandler(database, mon)
	historyHandler := handlers.NewHistoryHandler(database)

	// ─── 路由 & 启动 ─────────────────────────────────────────────────────
	router := setupRouter(quoteHandler, commitHandler, historyHandler)

	log.Printf("DEX swap service starting on :%s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("server: %v", err)
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func mustEnv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		log.Fatalf("required env var %q is not set", key)
	}
	return v
}

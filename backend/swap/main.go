package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

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
	limitHandler := handlers.NewLimitHandler(database)

	// ─── 限价单价格监控 ──────────────────────────────────────────────────
	priceMonitor := services.NewPriceMonitor(database, aggregator)
	go priceMonitor.Start(context.Background())

	// ─── 价格预警监控（docs/BACKEND_REQUIREMENTS.md §五）─────────────────
	// COINGECKO_BASE/COINGECKO_API_KEY 可选（默认官方免费端点）；
	// PUSH_WEBHOOK_URL 可选（配置后触发事件 POST 给运维推送桥，未配仅记日志，
	// App 前台轮询 /v1/l/alert/price/triggered 兜底）。
	var alertNotifier services.AlertNotifier
	if hook := os.Getenv("PUSH_WEBHOOK_URL"); hook != "" {
		alertNotifier = &services.WebhookNotifier{
			URL:    hook,
			Client: &http.Client{Timeout: 10 * time.Second},
		}
	}
	alertMonitor := services.NewAlertMonitor(
		database,
		os.Getenv("COINGECKO_BASE"),
		os.Getenv("COINGECKO_API_KEY"),
		alertNotifier,
	)
	go alertMonitor.Start(context.Background())
	alertHandler := handlers.NewAlertHandler(database, alertMonitor)

	// ─── 路由 & 启动 ─────────────────────────────────────────────────────
	router := setupRouter(
		quoteHandler, commitHandler, historyHandler, limitHandler, alertHandler)

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

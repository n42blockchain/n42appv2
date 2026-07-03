package main

import (
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"

	"github.com/n42/n42appv2/backend/swap/handlers"
)

func corsMiddleware() gin.HandlerFunc {
	allowed := os.Getenv("CORS_ORIGINS")
	origins := map[string]bool{}
	if allowed != "" {
		for _, o := range strings.Split(allowed, ",") {
			origins[strings.TrimSpace(o)] = true
		}
	}
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		if origin != "" && origins[origin] {
			c.Header("Access-Control-Allow-Origin", origin)
			c.Header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
			c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
			c.Header("Access-Control-Max-Age", "86400")
		}
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	}
}

// setupRouter 注册所有路由
func setupRouter(
	qh *handlers.QuoteHandler,
	ch *handlers.CommitHandler,
	hh *handlers.HistoryHandler,
	lh *handlers.LimitHandler,
	ah *handlers.AlertHandler,
) *gin.Engine {
	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery(), corsMiddleware())

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	v1 := r.Group("/v1/dex")
	{
		v1.GET("/tokens", handlers.GetTokens)
		v1.POST("/quote", qh.Quote)
		v1.POST("/commit", ch.Commit)
		v1.GET("/history", hh.GetHistory)

		// Limit orders
		v1.POST("/limit", lh.Create)
		v1.DELETE("/limit/:id", lh.Cancel)
		v1.GET("/limit", lh.List)
	}

	// 价格预警（docs/BACKEND_REQUIREMENTS.md §五，路径与文档一致）
	alert := r.Group("/v1/l/alert/price")
	{
		alert.POST("/set", ah.Set)
		alert.GET("/list", ah.List)
		alert.DELETE("/remove", ah.Remove)
		alert.GET("/triggered", ah.Triggered) // App 前台轮询兜底（文档 §5.4 推送的降级路径）
	}

	return r
}

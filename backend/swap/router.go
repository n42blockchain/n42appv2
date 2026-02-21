package main

import (
	"github.com/gin-gonic/gin"

	"github.com/n42/n42appv2/backend/swap/handlers"
)

// setupRouter 注册所有路由
func setupRouter(
	qh *handlers.QuoteHandler,
	ch *handlers.CommitHandler,
	hh *handlers.HistoryHandler,
) *gin.Engine {
	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())

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
	}

	return r
}

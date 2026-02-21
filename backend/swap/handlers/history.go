package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"github.com/n42/n42appv2/backend/swap/db"
	"github.com/n42/n42appv2/backend/swap/models"
)

// HistoryHandler 处理历史记录查询
type HistoryHandler struct {
	db *db.DB
}

// NewHistoryHandler 创建 HistoryHandler
func NewHistoryHandler(database *db.DB) *HistoryHandler {
	return &HistoryHandler{db: database}
}

// GetHistory 处理 GET /v1/dex/history?user=uuid&page=1&size=20
func (h *HistoryHandler) GetHistory(c *gin.Context) {
	userUUID := c.Query("user")
	if userUUID == "" {
		c.JSON(http.StatusBadRequest, models.Fail("user param required"))
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "20"))
	if page < 1 {
		page = 1
	}
	if size < 1 || size > 100 {
		size = 20
	}

	orders, err := h.db.ListOrders(userUUID, page, size)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.Fail("query failed: "+err.Error()))
		return
	}

	// 将数据库行转换为 API 响应
	items := make([]models.HistoryItem, 0, len(orders))
	for _, o := range orders {
		items = append(items, models.HistoryItem{
			OrderID:        o.OrderID,
			Chain:          o.Chain,
			TokenInSymbol:  o.SymbolIn,
			TokenOutSymbol: o.SymbolOut,
			AmountIn:       o.AmountIn,
			AmountOut:      o.AmountOut,
			Source:         o.Source,
			TxHash:         o.TxHash,
			Status:         o.Status,
			CreatedAt:      o.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, models.OK(gin.H{
		"list":  items,
		"page":  page,
		"size":  size,
		"total": len(items),
	}))
}

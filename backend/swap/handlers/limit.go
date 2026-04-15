package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/n42/n42appv2/backend/swap/models"
)

// LimitHandler 限价单 API 处理器
type LimitHandler struct {
	db DEXStore
}

// NewLimitHandler 创建 LimitHandler
func NewLimitHandler(database DEXStore) *LimitHandler {
	return &LimitHandler{db: database}
}

// Create 处理 POST /v1/dex/limit — 创建限价单
func (h *LimitHandler) Create(c *gin.Context) {
	var req models.LimitOrderReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.Fail("invalid request: "+err.Error()))
		return
	}

	if req.UUID == "" || req.Chain == "" || req.TokenIn == "" ||
		req.TokenOut == "" || req.AmountIn == "" || req.LimitPrice == "" {
		c.JSON(http.StatusBadRequest, models.Fail("missing required fields"))
		return
	}

	// Default expiry: 24 hours
	if req.ExpiresIn <= 0 {
		req.ExpiresIn = 86400
	}
	// Cap at 30 days
	if req.ExpiresIn > 30*86400 {
		req.ExpiresIn = 30 * 86400
	}

	orderID := uuid.New().String()
	expiresAt := time.Now().Unix() + req.ExpiresIn

	if err := h.db.InsertLimitOrder(
		orderID, req.UUID, req.Chain,
		req.TokenIn, req.TokenOut, req.SymbolIn, req.SymbolOut,
		req.AmountIn, req.LimitPrice, expiresAt,
	); err != nil {
		c.JSON(http.StatusInternalServerError, models.Fail("failed to create limit order"))
		return
	}

	c.JSON(http.StatusOK, models.OK(gin.H{
		"order_id":   orderID,
		"expires_at": expiresAt,
	}))
}

// Cancel 处理 DELETE /v1/dex/limit/:id — 取消限价单
func (h *LimitHandler) Cancel(c *gin.Context) {
	orderID := c.Param("id")
	userUUID := c.Query("uuid")

	if orderID == "" || userUUID == "" {
		c.JSON(http.StatusBadRequest, models.Fail("missing order_id or uuid"))
		return
	}

	if err := h.db.CancelLimitOrder(orderID, userUUID); err != nil {
		c.JSON(http.StatusBadRequest, models.Fail(err.Error()))
		return
	}

	c.JSON(http.StatusOK, models.OK(gin.H{"cancelled": true}))
}

// List 处理 GET /v1/dex/limit — 查询用户限价单
func (h *LimitHandler) List(c *gin.Context) {
	userUUID := c.Query("uuid")
	if userUUID == "" {
		c.JSON(http.StatusBadRequest, models.Fail("missing uuid"))
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "20"))

	orders, err := h.db.ListUserLimitOrders(userUUID, page, size)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.Fail("query failed"))
		return
	}

	items := make([]models.LimitOrderItem, 0, len(orders))
	for _, o := range orders {
		items = append(items, models.LimitOrderItem{
			OrderID:    o.OrderID,
			Chain:      o.Chain,
			SymbolIn:   o.SymbolIn,
			SymbolOut:  o.SymbolOut,
			AmountIn:   o.AmountIn,
			LimitPrice: o.LimitPrice,
			ExpiresAt:  o.ExpiresAt,
			Status:     o.Status,
			TxHash:     o.TxHash,
			CreatedAt:  o.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, models.OK(items))
}

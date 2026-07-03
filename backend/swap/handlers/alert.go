package handlers

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/n42/n42appv2/backend/swap/db"
	"github.com/n42/n42appv2/backend/swap/models"
)

// AlertStore 是 AlertHandler 对数据库层的依赖接口（db.DB 隐式满足）。
type AlertStore interface {
	UpsertPriceAlert(alertID, userUUID, symbol, coinGeckoID, direction, targetPrice string, enabled bool) error
	ListPriceAlerts(userUUID string) ([]*db.PriceAlert, error)
	DeletePriceAlert(alertID, userUUID string) error
	ListTriggeredPriceAlertsSince(userUUID string, since int64) ([]*db.PriceAlert, error)
}

// AlertPriceSource 供 list 接口回显 current_price（AlertMonitor 隐式满足）。
type AlertPriceSource interface {
	CachedPrice(coinGeckoID string) (float64, bool)
}

// AlertHandler 价格预警 API（docs/BACKEND_REQUIREMENTS.md §五）。
type AlertHandler struct {
	db     AlertStore
	prices AlertPriceSource
}

// NewAlertHandler 创建 AlertHandler。prices 可为 nil（current_price 留空）。
func NewAlertHandler(database AlertStore, prices AlertPriceSource) *AlertHandler {
	return &AlertHandler{db: database, prices: prices}
}

// Set 处理 POST /v1/l/alert/price/set — 创建/更新价格预警（§5.1）。
func (h *AlertHandler) Set(c *gin.Context) {
	var req models.PriceAlertReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.Fail("invalid request: "+err.Error()))
		return
	}
	if req.UUID == "" || req.Symbol == "" || req.CoinGeckoID == "" ||
		req.TargetPrice == "" {
		c.JSON(http.StatusBadRequest, models.Fail("missing required fields"))
		return
	}
	dir := strings.ToLower(req.Direction)
	if dir != "above" && dir != "below" {
		c.JSON(http.StatusBadRequest, models.Fail("direction must be above|below"))
		return
	}
	if price, err := strconv.ParseFloat(req.TargetPrice, 64); err != nil || price <= 0 {
		c.JSON(http.StatusBadRequest, models.Fail("invalid target_price"))
		return
	}

	alertID := req.AlertID
	if alertID == "" {
		alertID = uuid.New().String()
	}
	if err := h.db.UpsertPriceAlert(
		alertID, req.UUID, strings.ToUpper(req.Symbol), req.CoinGeckoID,
		dir, req.TargetPrice, req.Enabled,
	); err != nil {
		c.JSON(http.StatusInternalServerError, models.Fail("failed to save alert"))
		return
	}
	c.JSON(http.StatusOK, models.OK(gin.H{"alert_id": alertID}))
}

// List 处理 GET /v1/l/alert/price/list — 用户预警列表（§5.2）。
func (h *AlertHandler) List(c *gin.Context) {
	userUUID := c.Query("uuid")
	if userUUID == "" {
		c.JSON(http.StatusBadRequest, models.Fail("missing uuid"))
		return
	}
	alerts, err := h.db.ListPriceAlerts(userUUID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.Fail("failed to list alerts"))
		return
	}
	c.JSON(http.StatusOK, models.OK(h.toItems(alerts)))
}

// Remove 处理 DELETE /v1/l/alert/price/remove — 删除预警（§5.3）。
func (h *AlertHandler) Remove(c *gin.Context) {
	var req models.PriceAlertRemoveReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.Fail("invalid request: "+err.Error()))
		return
	}
	if req.UUID == "" || req.AlertID == "" {
		c.JSON(http.StatusBadRequest, models.Fail("missing uuid or alert_id"))
		return
	}
	if err := h.db.DeletePriceAlert(req.AlertID, req.UUID); err != nil {
		c.JSON(http.StatusNotFound, models.Fail("alert not found"))
		return
	}
	c.JSON(http.StatusOK, models.OK(gin.H{"removed": req.AlertID}))
}

// Triggered 处理 GET /v1/l/alert/price/triggered — App 前台轮询兜底
// （无 FCM/APNs 也能收到触达：客户端启动/回前台时拉取近期触发项转本地通知）。
func (h *AlertHandler) Triggered(c *gin.Context) {
	userUUID := c.Query("uuid")
	if userUUID == "" {
		c.JSON(http.StatusBadRequest, models.Fail("missing uuid"))
		return
	}
	since, _ := strconv.ParseInt(c.Query("since"), 10, 64)
	alerts, err := h.db.ListTriggeredPriceAlertsSince(userUUID, since)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.Fail("failed to list triggered"))
		return
	}
	c.JSON(http.StatusOK, models.OK(h.toItems(alerts)))
}

func (h *AlertHandler) toItems(alerts []*db.PriceAlert) []models.PriceAlertItem {
	items := make([]models.PriceAlertItem, 0, len(alerts))
	for _, a := range alerts {
		item := models.PriceAlertItem{
			AlertID:     a.AlertID,
			Symbol:      a.Symbol,
			CoinGeckoID: a.CoinGeckoID,
			Direction:   a.Direction,
			TargetPrice: a.TargetPrice,
			Enabled:     a.Enabled,
			Triggered:   a.Triggered,
			CreatedAt:   a.CreatedAt,
		}
		if a.TriggerPrice != nil {
			item.TriggerPrice = *a.TriggerPrice
		}
		if a.TriggeredAt != nil {
			item.TriggeredAt = *a.TriggeredAt
		}
		if h.prices != nil {
			if p, ok := h.prices.CachedPrice(a.CoinGeckoID); ok {
				item.CurrentPrice = strconv.FormatFloat(p, 'f', -1, 64)
			}
		}
		items = append(items, item)
	}
	return items
}

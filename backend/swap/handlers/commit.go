package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/n42/n42appv2/backend/swap/models"
	"github.com/n42/n42appv2/backend/swap/monitor"
)

// CommitHandler 处理提交 txHash
type CommitHandler struct {
	db      DEXStore
	monitor *monitor.Monitor
}

// NewCommitHandler 创建 CommitHandler
func NewCommitHandler(database DEXStore, mon *monitor.Monitor) *CommitHandler {
	return &CommitHandler{db: database, monitor: mon}
}

// Commit 处理 POST /v1/dex/commit
func (h *CommitHandler) Commit(c *gin.Context) {
	var req models.CommitReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.Fail("invalid request: "+err.Error()))
		return
	}
	if req.OrderID == "" || req.TxHash == "" {
		c.JSON(http.StatusBadRequest, models.Fail("order_id and tx_hash required"))
		return
	}

	// 更新订单 txHash 和 status → committed
	if err := h.db.UpdateTxHash(req.OrderID, req.TxHash); err != nil {
		c.JSON(http.StatusInternalServerError, models.Fail("update failed: "+err.Error()))
		return
	}

	// 查询订单以获取 chain，用于 monitor 轮询
	order, err := h.db.GetOrder(req.OrderID)
	if err == nil && order != nil {
		h.monitor.Watch(req.OrderID, order.Chain, req.TxHash)
	}

	c.JSON(http.StatusOK, models.OK(true))
}

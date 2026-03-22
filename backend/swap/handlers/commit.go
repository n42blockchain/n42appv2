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
	if req.OrderID == "" || req.TxHash == "" || req.UUID == "" {
		c.JSON(http.StatusBadRequest, models.Fail("uuid, order_id and tx_hash required"))
		return
	}

	// 查询订单，验证所有者
	order, err := h.db.GetOrder(req.OrderID)
	if err != nil || order == nil {
		c.JSON(http.StatusNotFound, models.Fail("order not found"))
		return
	}
	if order.UserUUID != req.UUID {
		c.JSON(http.StatusForbidden, models.Fail("order does not belong to this user"))
		return
	}

	// 更新订单 txHash 和 status → committed
	if err := h.db.UpdateTxHash(req.OrderID, req.TxHash); err != nil {
		c.JSON(http.StatusInternalServerError, models.Fail("update failed: "+err.Error()))
		return
	}

	// 启动 monitor 轮询
	h.monitor.Watch(req.OrderID, order.Chain, req.TxHash)

	c.JSON(http.StatusOK, models.OK(true))
}

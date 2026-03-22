package handlers

import (
	"math/big"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"github.com/n42/n42appv2/backend/swap/models"
	"github.com/n42/n42appv2/backend/swap/services"
)

// QuoteHandler 持有依赖
type QuoteHandler struct {
	agg *services.Aggregator
	db  DEXStore
}

// NewQuoteHandler 创建 QuoteHandler
func NewQuoteHandler(agg *services.Aggregator, database DEXStore) *QuoteHandler {
	return &QuoteHandler{agg: agg, db: database}
}

// Quote 处理 POST /v1/dex/quote
func (h *QuoteHandler) Quote(c *gin.Context) {
	var req models.QuoteReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.Fail("invalid request: "+err.Error()))
		return
	}

	// 校验必填字段
	if req.Chain == "" || req.TokenIn == "" || req.TokenOut == "" ||
		req.AmountIn == "" || req.UserAddr == "" {
		c.JSON(http.StatusBadRequest, models.Fail("missing required fields"))
		return
	}
	if req.SlippageBps == 0 {
		req.SlippageBps = 50 // 默认 0.5%
	}

	// 解析 amountIn 为 big.Int
	amountWei, ok := new(big.Int).SetString(req.AmountIn, 10)
	if !ok || amountWei.Sign() <= 0 {
		c.JSON(http.StatusBadRequest, models.Fail("invalid amount_in"))
		return
	}
	req.AmountInWei = amountWei

	// 并发查询最优报价
	resp, err := h.agg.BestQuote(c.Request.Context(), req)
	if err != nil {
		c.JSON(http.StatusBadGateway, models.Fail("quote failed: "+err.Error()))
		return
	}

	// 生成订单 ID 并持久化
	orderID := "ord_" + uuid.New().String()[:8]
	resp.OrderID = orderID

	// gas 估算：简单以 source 类型给出固定估算文字（可接 RPC 查实际 gas）
	resp.GasEstimate = estimateGas(req.Chain, resp.Source)
	resp.PriceImpact = "< 1%"

	// 写入数据库（status=0 quoted）
	if err := h.db.InsertOrder(
		orderID, req.UserAddr, req.Chain,
		req.TokenIn, req.TokenOut,
		resp.TokenInSymbol, resp.TokenOutSymbol,
		req.AmountIn, resp.AmountOut,
		resp.Source,
	); err != nil {
		c.JSON(http.StatusInternalServerError, models.Fail("save order failed"))
		return
	}

	c.JSON(http.StatusOK, models.OK(resp))
}

// estimateGas 根据链和来源给出 gas 费估算文字
func estimateGas(chain, source string) string {
	switch chain {
	case "SOL":
		return "~0.0025 SOL"
	case "ARB", "OP":
		return "~0.0005 ETH"
	case "BSC":
		return "~0.001 BNB"
	case "POLYGON":
		return "~0.01 MATIC"
	default: // ETH
		if source == "1inch" {
			return "~0.004 ETH"
		}
		return "~0.003 ETH"
	}
}

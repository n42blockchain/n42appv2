package handlers

import "github.com/n42/n42appv2/backend/swap/db"

// DEXStore 是 handlers 对数据库层的依赖接口，便于测试替换。
// db.DB 隐式满足此接口（无需修改 db 包）。
type DEXStore interface {
	// Swap orders
	InsertOrder(orderID, userUUID, chain, tokenIn, tokenOut, symbolIn, symbolOut, amountIn, amountOut, source string) error
	UpdateTxHash(orderID, txHash string) error
	UpdateStatus(orderID string, status int) error
	GetOrder(orderID string) (*db.Order, error)
	ListOrders(userUUID string, page, size int) ([]*db.Order, error)

	// Limit orders
	InsertLimitOrder(orderID, userUUID, chain, tokenIn, tokenOut, symbolIn, symbolOut, amountIn, limitPrice string, expiresAt int64) error
	CancelLimitOrder(orderID, userUUID string) error
	ListActiveLimitOrders() ([]*db.LimitOrder, error)
	ListUserLimitOrders(userUUID string, page, size int) ([]*db.LimitOrder, error)
	UpdateLimitOrderStatus(orderID string, status int, txHash string) error
	ExpireStaleOrders() (int64, error)
}

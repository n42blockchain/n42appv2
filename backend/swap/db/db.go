package db

import (
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq" // PostgreSQL driver
)

// Schema DDL — 在服务启动时自动建表（幂等）
const schema = `
CREATE TABLE IF NOT EXISTS dex_orders (
    id           BIGSERIAL    PRIMARY KEY,
    order_id     VARCHAR(64)  NOT NULL UNIQUE,
    user_uuid    VARCHAR(64)  NOT NULL,
    chain        VARCHAR(32)  NOT NULL,
    token_in     VARCHAR(128) NOT NULL,
    token_out    VARCHAR(128) NOT NULL,
    symbol_in    VARCHAR(32),
    symbol_out   VARCHAR(32),
    amount_in    NUMERIC      NOT NULL,
    amount_out   NUMERIC,
    source       VARCHAR(32),
    tx_hash      VARCHAR(128),
    status       SMALLINT     DEFAULT 0,
    created_at   BIGINT       NOT NULL,
    updated_at   BIGINT       NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_dex_orders_user
    ON dex_orders(user_uuid, created_at DESC);

CREATE TABLE IF NOT EXISTS dex_limit_orders (
    id           BIGSERIAL    PRIMARY KEY,
    order_id     VARCHAR(64)  NOT NULL UNIQUE,
    user_uuid    VARCHAR(64)  NOT NULL,
    chain        VARCHAR(32)  NOT NULL,
    token_in     VARCHAR(128) NOT NULL,
    token_out    VARCHAR(128) NOT NULL,
    symbol_in    VARCHAR(32),
    symbol_out   VARCHAR(32),
    amount_in    NUMERIC      NOT NULL,
    limit_price  NUMERIC      NOT NULL,
    expires_at   BIGINT       NOT NULL,
    status       SMALLINT     DEFAULT 0,
    tx_hash      VARCHAR(128),
    created_at   BIGINT       NOT NULL,
    updated_at   BIGINT       NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_dex_limit_orders_user
    ON dex_limit_orders(user_uuid, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_dex_limit_orders_active
    ON dex_limit_orders(status) WHERE status = 0;
`

// DB 封装 sqlx.DB，提供 CRUD 操作
type DB struct {
	db *sqlx.DB
}

// New 创建数据库连接并初始化表结构
func New(dsn string) (*DB, error) {
	conn, err := sqlx.Connect("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("db connect: %w", err)
	}
	conn.SetMaxOpenConns(20)
	conn.SetMaxIdleConns(5)
	conn.SetConnMaxLifetime(30 * time.Minute)

	if _, err = conn.Exec(schema); err != nil {
		return nil, fmt.Errorf("db init schema: %w", err)
	}
	return &DB{db: conn}, nil
}

// Order 对应数据库行（导出供 handlers / monitor 使用）
type Order struct {
	ID        int64  `db:"id"`
	OrderID   string `db:"order_id"`
	UserUUID  string `db:"user_uuid"`
	Chain     string `db:"chain"`
	TokenIn   string `db:"token_in"`
	TokenOut  string `db:"token_out"`
	SymbolIn  string `db:"symbol_in"`
	SymbolOut string `db:"symbol_out"`
	AmountIn  string `db:"amount_in"`
	AmountOut string `db:"amount_out"`
	Source    string `db:"source"`
	TxHash    string `db:"tx_hash"`
	Status    int    `db:"status"`
	CreatedAt int64  `db:"created_at"`
	UpdatedAt int64  `db:"updated_at"`
}

// LimitOrder 限价单数据库模型
// Status: 0=active, 1=triggered, 2=executed, 3=cancelled, 4=expired
type LimitOrder struct {
	ID         int64  `db:"id"`
	OrderID    string `db:"order_id"`
	UserUUID   string `db:"user_uuid"`
	Chain      string `db:"chain"`
	TokenIn    string `db:"token_in"`
	TokenOut   string `db:"token_out"`
	SymbolIn   string `db:"symbol_in"`
	SymbolOut  string `db:"symbol_out"`
	AmountIn   string `db:"amount_in"`
	LimitPrice string `db:"limit_price"`
	ExpiresAt  int64  `db:"expires_at"`
	Status     int    `db:"status"`
	TxHash     string `db:"tx_hash"`
	CreatedAt  int64  `db:"created_at"`
	UpdatedAt  int64  `db:"updated_at"`
}

const (
	LimitStatusActive    = 0
	LimitStatusTriggered = 1
	LimitStatusExecuted  = 2
	LimitStatusCancelled = 3
	LimitStatusExpired   = 4
)

// InsertLimitOrder 创建限价单（status=0 active）
func (d *DB) InsertLimitOrder(
	orderID, userUUID, chain,
	tokenIn, tokenOut, symbolIn, symbolOut,
	amountIn, limitPrice string, expiresAt int64,
) error {
	now := time.Now().Unix()
	_, err := d.db.Exec(`
		INSERT INTO dex_limit_orders
			(order_id, user_uuid, chain, token_in, token_out,
			 symbol_in, symbol_out, amount_in, limit_price, expires_at,
			 status, created_at, updated_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,0,$11,$11)`,
		orderID, userUUID, chain, tokenIn, tokenOut,
		symbolIn, symbolOut, amountIn, limitPrice, expiresAt,
		now,
	)
	return err
}

// CancelLimitOrder 取消限价单（仅 active 状态可取消）
func (d *DB) CancelLimitOrder(orderID, userUUID string) error {
	now := time.Now().Unix()
	res, err := d.db.Exec(`
		UPDATE dex_limit_orders
		SET status=$1, updated_at=$2
		WHERE order_id=$3 AND user_uuid=$4 AND status=0`,
		LimitStatusCancelled, now, orderID, userUUID,
	)
	if err != nil {
		return err
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("limit order not found or not cancellable")
	}
	return nil
}

// ListActiveLimitOrders 获取所有活跃限价单（供价格监控使用）
func (d *DB) ListActiveLimitOrders() ([]*LimitOrder, error) {
	var orders []*LimitOrder
	err := d.db.Select(&orders, `
		SELECT * FROM dex_limit_orders
		WHERE status = 0
		ORDER BY created_at ASC
		LIMIT 5000`)
	return orders, err
}

// ListUserLimitOrders 查询用户限价单（分页）
func (d *DB) ListUserLimitOrders(userUUID string, page, size int) ([]*LimitOrder, error) {
	if page < 1 {
		page = 1
	}
	if size < 1 || size > 100 {
		size = 20
	}
	offset := (page - 1) * size
	var orders []*LimitOrder
	err := d.db.Select(&orders, `
		SELECT * FROM dex_limit_orders
		WHERE user_uuid=$1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`,
		userUUID, size, offset,
	)
	return orders, err
}

// UpdateLimitOrderStatus 更新限价单状态
func (d *DB) UpdateLimitOrderStatus(orderID string, status int, txHash string) error {
	now := time.Now().Unix()
	_, err := d.db.Exec(`
		UPDATE dex_limit_orders
		SET status=$1, tx_hash=$2, updated_at=$3
		WHERE order_id=$4`,
		status, txHash, now, orderID,
	)
	return err
}

// ExpireStaleOrders 批量过期超时的限价单
func (d *DB) ExpireStaleOrders() (int64, error) {
	now := time.Now().Unix()
	res, err := d.db.Exec(`
		UPDATE dex_limit_orders
		SET status=$1, updated_at=$2
		WHERE status=0 AND expires_at < $3`,
		LimitStatusExpired, now, now,
	)
	if err != nil {
		return 0, err
	}
	return res.RowsAffected()
}

// InsertOrder 插入报价订单（status=0）
func (d *DB) InsertOrder(
	orderID, userUUID, chain,
	tokenIn, tokenOut, symbolIn, symbolOut,
	amountIn, amountOut, source string,
) error {
	now := time.Now().Unix()
	_, err := d.db.Exec(`
		INSERT INTO dex_orders
			(order_id, user_uuid, chain, token_in, token_out,
			 symbol_in, symbol_out, amount_in, amount_out, source,
			 status, created_at, updated_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,0,$11,$11)`,
		orderID, userUUID, chain, tokenIn, tokenOut,
		symbolIn, symbolOut, amountIn, amountOut, source,
		now,
	)
	return err
}

// UpdateTxHash 设置 txHash 并将 status 改为 committed(1)
func (d *DB) UpdateTxHash(orderID, txHash string) error {
	now := time.Now().Unix()
	_, err := d.db.Exec(`
		UPDATE dex_orders
		SET tx_hash=$1, status=1, updated_at=$2
		WHERE order_id=$3`,
		txHash, now, orderID,
	)
	return err
}

// UpdateStatus 更新订单状态（2=confirmed / 3=failed）
func (d *DB) UpdateStatus(orderID string, status int) error {
	now := time.Now().Unix()
	_, err := d.db.Exec(`
		UPDATE dex_orders
		SET status=$1, updated_at=$2
		WHERE order_id=$3`,
		status, now, orderID,
	)
	return err
}

// GetOrder 通过 orderID 查询单条记录
func (d *DB) GetOrder(orderID string) (*Order, error) {
	var o Order
	if err := d.db.Get(&o,
		`SELECT * FROM dex_orders WHERE order_id=$1`, orderID); err != nil {
		return nil, err
	}
	return &o, nil
}

// ListOrders 查询用户历史记录（分页）
func (d *DB) ListOrders(userUUID string, page, size int) ([]*Order, error) {
	if page < 1 {
		page = 1
	}
	if size < 1 || size > 100 {
		size = 20
	}
	offset := (page - 1) * size
	var orders []*Order
	err := d.db.Select(&orders, `
		SELECT * FROM dex_orders
		WHERE user_uuid=$1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`,
		userUUID, size, offset,
	)
	return orders, err
}

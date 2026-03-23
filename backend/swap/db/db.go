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

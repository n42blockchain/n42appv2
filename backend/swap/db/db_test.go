package db

import (
	"database/sql/driver"
	"regexp"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/jmoiron/sqlx"
)

func newMockDB(t *testing.T) (*DB, sqlmock.Sqlmock) {
	t.Helper()

	sqlDB, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("create SQL mock: %v", err)
	}
	t.Cleanup(func() { _ = sqlDB.Close() })
	return &DB{db: sqlx.NewDb(sqlDB, "postgres")}, mock
}

func TestUpsertPriceAlertRejectsAlertOwnedByAnotherUser(t *testing.T) {
	db, mock := newMockDB(t)
	mock.ExpectExec("INSERT INTO price_alerts").
		WithArgs("alert-1", "user-2", "ETH", "ethereum", "above", "4000", true, sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 0))

	err := db.UpsertPriceAlert("alert-1", "user-2", "ETH", "ethereum", "above", "4000", true)
	if err == nil {
		t.Fatal("expected ownership conflict to be reported")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unmet SQL expectations: %v", err)
	}
}

func TestCancelLimitOrderRequiresActiveOrderOwnedByUser(t *testing.T) {
	db, mock := newMockDB(t)
	mock.ExpectExec(regexp.QuoteMeta("WHERE order_id=$3 AND user_uuid=$4 AND status=0")).
		WithArgs(LimitStatusCancelled, sqlmock.AnyArg(), "order-1", "user-2").
		WillReturnResult(sqlmock.NewResult(0, 0))

	err := db.CancelLimitOrder("order-1", "user-2")
	if err == nil {
		t.Fatal("expected missing, foreign-owned, or inactive order to be rejected")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unmet SQL expectations: %v", err)
	}
}

func TestMarkPriceAlertTriggeredDoesNotConsumeUpdatedSnapshot(t *testing.T) {
	db, mock := newMockDB(t)
	mock.ExpectExec(regexp.QuoteMeta("AND target_price=$4 AND direction=$5")).
		WithArgs("alert-1", "4100", sqlmock.AnyArg(), "4000", "above").
		WillReturnResult(sqlmock.NewResult(0, 0))

	marked, err := db.MarkPriceAlertTriggered("alert-1", "4100", "4000", "above")
	if err != nil {
		t.Fatalf("mark alert: %v", err)
	}
	if marked {
		t.Fatal("expected a stale target snapshot to remain unconsumed")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unmet SQL expectations: %v", err)
	}
}

func TestLimitOrderQueriesNormalizePagingAndMapRows(t *testing.T) {
	db, mock := newMockDB(t)
	mock.ExpectExec("INSERT INTO dex_limit_orders").WillReturnResult(sqlmock.NewResult(1, 1))
	if err := db.InsertLimitOrder("limit-1", "user-1", "ETH", "0xin", "0xout", "IN", "OUT", "2", "1800", 1900000000); err != nil {
		t.Fatalf("insert limit order: %v", err)
	}

	limitColumns := []string{"id", "order_id", "user_uuid", "chain", "token_in", "token_out", "symbol_in", "symbol_out", "amount_in", "limit_price", "expires_at", "status", "tx_hash", "created_at", "updated_at"}
	limitRow := []driver.Value{int64(1), "limit-1", "user-1", "ETH", "0xin", "0xout", "IN", "OUT", "2", "1800", int64(1900000000), 0, "", int64(10), int64(10)}
	mock.ExpectQuery("WHERE status = 0").WillReturnRows(sqlmock.NewRows(limitColumns).AddRow(limitRow...))
	active, err := db.ListActiveLimitOrders()
	if err != nil || len(active) != 1 || active[0].OrderID != "limit-1" {
		t.Fatalf("active limit orders = %#v, %v; want one mapped row", active, err)
	}

	mock.ExpectQuery(regexp.QuoteMeta("LIMIT $2 OFFSET $3")).WithArgs("user-1", 20, 0).
		WillReturnRows(sqlmock.NewRows(limitColumns))
	if rows, err := db.ListUserLimitOrders("user-1", 0, 200); err != nil || len(rows) != 0 {
		t.Fatalf("normalized limit-order page = %#v, %v; want empty page", rows, err)
	}

	mock.ExpectExec("UPDATE dex_limit_orders").WithArgs(2, "0xhash", sqlmock.AnyArg(), "limit-1").
		WillReturnResult(sqlmock.NewResult(0, 1))
	if err := db.UpdateLimitOrderStatus("limit-1", LimitStatusExecuted, "0xhash"); err != nil {
		t.Fatalf("update limit order status: %v", err)
	}
	mock.ExpectExec("UPDATE dex_limit_orders").WithArgs(LimitStatusExpired, sqlmock.AnyArg(), sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 3))
	if count, err := db.ExpireStaleOrders(); err != nil || count != 3 {
		t.Fatalf("expired count = %d, %v; want 3, nil", count, err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unmet SQL expectations: %v", err)
	}
}

func TestOrderPersistenceAndHistoryPaging(t *testing.T) {
	db, mock := newMockDB(t)
	mock.ExpectExec("INSERT INTO dex_orders").WillReturnResult(sqlmock.NewResult(1, 1))
	if err := db.InsertOrder("order-1", "user-1", "ETH", "0xin", "0xout", "IN", "OUT", "2", "3", "quote"); err != nil {
		t.Fatalf("insert order: %v", err)
	}
	mock.ExpectExec(`SET tx_hash=\$1, status=1`).WithArgs("0xhash", sqlmock.AnyArg(), "order-1").
		WillReturnResult(sqlmock.NewResult(0, 1))
	if err := db.UpdateTxHash("order-1", "0xhash"); err != nil {
		t.Fatalf("update transaction hash: %v", err)
	}
	mock.ExpectExec(`SET status=\$1, updated_at=\$2`).WithArgs(2, sqlmock.AnyArg(), "order-1").
		WillReturnResult(sqlmock.NewResult(0, 1))
	if err := db.UpdateStatus("order-1", 2); err != nil {
		t.Fatalf("update status: %v", err)
	}

	columns := []string{"id", "order_id", "user_uuid", "chain", "token_in", "token_out", "symbol_in", "symbol_out", "amount_in", "amount_out", "source", "tx_hash", "status", "created_at", "updated_at"}
	row := []driver.Value{int64(1), "order-1", "user-1", "ETH", "0xin", "0xout", "IN", "OUT", "2", "3", "quote", "0xhash", 2, int64(10), int64(11)}
	mock.ExpectQuery(`SELECT \* FROM dex_orders WHERE order_id=\$1`).WithArgs("order-1").
		WillReturnRows(sqlmock.NewRows(columns).AddRow(row...))
	order, err := db.GetOrder("order-1")
	if err != nil || order == nil || order.TxHash != "0xhash" || order.Status != 2 {
		t.Fatalf("get order = %#v, %v; want committed row", order, err)
	}
	mock.ExpectQuery(regexp.QuoteMeta("LIMIT $2 OFFSET $3")).WithArgs("user-1", 10, 10).
		WillReturnRows(sqlmock.NewRows(columns).AddRow(row...))
	orders, err := db.ListOrders("user-1", 2, 10)
	if err != nil || len(orders) != 1 || orders[0].OrderID != "order-1" {
		t.Fatalf("order history = %#v, %v; want one mapped row", orders, err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unmet SQL expectations: %v", err)
	}
}

func TestPriceAlertListsAndDeletesAreScopedToOwner(t *testing.T) {
	db, mock := newMockDB(t)
	columns := []string{"id", "alert_id", "user_uuid", "symbol", "coin_gecko_id", "direction", "target_price", "enabled", "triggered", "trigger_price", "triggered_at", "created_at", "updated_at"}
	row := []driver.Value{int64(1), "alert-1", "user-1", "ETH", "ethereum", "above", "4000", true, true, "4100", int64(100), int64(10), int64(100)}
	mock.ExpectQuery(`WHERE user_uuid=\$1`).WithArgs("user-1").
		WillReturnRows(sqlmock.NewRows(columns).AddRow(row...))
	alerts, err := db.ListPriceAlerts("user-1")
	if err != nil || len(alerts) != 1 || alerts[0].AlertID != "alert-1" || alerts[0].TriggerPrice == nil || *alerts[0].TriggerPrice != "4100" {
		t.Fatalf("price alerts = %#v, %v; want mapped owned alert", alerts, err)
	}
	mock.ExpectQuery("WHERE enabled AND NOT triggered").WillReturnRows(sqlmock.NewRows(columns))
	if alerts, err = db.ListActivePriceAlerts(); err != nil || len(alerts) != 0 {
		t.Fatalf("active alerts = %#v, %v; want empty result", alerts, err)
	}
	mock.ExpectQuery(`triggered_at > \$2`).WithArgs("user-1", int64(50)).
		WillReturnRows(sqlmock.NewRows(columns).AddRow(row...))
	if alerts, err = db.ListTriggeredPriceAlertsSince("user-1", 50); err != nil || len(alerts) != 1 {
		t.Fatalf("triggered alerts = %#v, %v; want one result", alerts, err)
	}
	mock.ExpectExec(`DELETE FROM price_alerts WHERE alert_id=\$1 AND user_uuid=\$2`).
		WithArgs("alert-1", "user-1").WillReturnResult(sqlmock.NewResult(0, 1))
	if err := db.DeletePriceAlert("alert-1", "user-1"); err != nil {
		t.Fatalf("delete owned alert: %v", err)
	}
	mock.ExpectExec(`DELETE FROM price_alerts WHERE alert_id=\$1 AND user_uuid=\$2`).
		WithArgs("alert-1", "user-2").WillReturnResult(sqlmock.NewResult(0, 0))
	if err := db.DeletePriceAlert("alert-1", "user-2"); err == nil {
		t.Fatal("expected deletion of another user's alert to be rejected")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unmet SQL expectations: %v", err)
	}
}

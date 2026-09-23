package handlers_test

import (
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"

	"github.com/n42/n42appv2/backend/swap/db"
	"github.com/n42/n42appv2/backend/swap/handlers"
	"github.com/n42/n42appv2/backend/swap/monitor"
)

// ─── Commit 测试 ──────────────────────────────────────────────────────────────

func newCommitRouter(store handlers.DEXStore) *gin.Engine {
	r := gin.New()
	// db=nil 时 Monitor.Watch 直接返回（生产安全，测试无副作用）
	mon := monitor.New(nil, nil)
	h := handlers.NewCommitHandler(store, mon)
	r.POST("/v1/dex/commit", h.Commit)
	return r
}

func TestCommit_MissingFields(t *testing.T) {
	r := newCommitRouter(&fakeStore{})
	w := doPost(r, "/v1/dex/commit", `{}`)
	if w.Code != http.StatusBadRequest {
		t.Errorf("status = %d, want 400", w.Code)
	}
}

func TestCommit_MalformedJSON(t *testing.T) {
	r := newCommitRouter(&fakeStore{})
	w := doPost(r, "/v1/dex/commit", `{"uuid":`)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
}

type commitStoreWithLookupError struct {
	handlers.DEXStore
	err error
}

func (s commitStoreWithLookupError) GetOrder(string) (*db.Order, error) {
	return nil, s.err
}

func TestCommit_OrderLookupFailureDoesNotStartCommit(t *testing.T) {
	r := newCommitRouter(commitStoreWithLookupError{
		DEXStore: &fakeStore{},
		err:      errors.New("database unavailable"),
	})
	w := doPost(r, "/v1/dex/commit", `{"uuid":"user-1","order_id":"ord_abc","tx_hash":"0x123456"}`)
	if w.Code != http.StatusNotFound {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
}

func TestCommit_MissingTxHash(t *testing.T) {
	r := newCommitRouter(&fakeStore{})
	w := doPost(r, "/v1/dex/commit", `{"order_id":"ord_abc"}`)
	if w.Code != http.StatusBadRequest {
		t.Errorf("status = %d, want 400", w.Code)
	}
}

func TestCommit_Success(t *testing.T) {
	store := &fakeStore{
		order: &db.Order{OrderID: "ord_abc", UserUUID: "user-1", Chain: "ETH", TxHash: "0xhash"},
	}
	r := newCommitRouter(store)

	body := `{"uuid":"user-1","order_id":"ord_abc","tx_hash":"0x123456"}`
	w := doPost(r, "/v1/dex/commit", body)
	if w.Code != http.StatusOK {
		t.Errorf("status = %d; body: %s", w.Code, w.Body.String())
	}
}

func TestCommit_WrongUser(t *testing.T) {
	store := &fakeStore{
		order: &db.Order{OrderID: "ord_abc", UserUUID: "user-1", Chain: "ETH"},
	}
	r := newCommitRouter(store)

	body := `{"uuid":"attacker","order_id":"ord_abc","tx_hash":"0x123456"}`
	w := doPost(r, "/v1/dex/commit", body)
	if w.Code != http.StatusForbidden {
		t.Errorf("status = %d, want 403; body: %s", w.Code, w.Body.String())
	}
}

// ─── History 测试 ─────────────────────────────────────────────────────────────

func newHistoryRouter(store handlers.DEXStore) *gin.Engine {
	r := gin.New()
	h := handlers.NewHistoryHandler(store)
	r.GET("/v1/dex/history", h.GetHistory)
	return r
}

func doGet(r *gin.Engine, path string) *httptest.ResponseRecorder {
	w := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodGet, path, nil)
	r.ServeHTTP(w, req)
	return w
}

func TestHistory_MissingUser(t *testing.T) {
	r := newHistoryRouter(&fakeStore{})
	w := doGet(r, "/v1/dex/history")
	if w.Code != http.StatusBadRequest {
		t.Errorf("status = %d, want 400", w.Code)
	}
}

func TestHistory_EmptyOrders(t *testing.T) {
	r := newHistoryRouter(&fakeStore{orders: []*db.Order{}})
	w := doGet(r, "/v1/dex/history?user=user-uuid-1")
	if w.Code != http.StatusOK {
		t.Errorf("status = %d, want 200; body: %s", w.Code, w.Body.String())
	}
}

func TestHistory_WithOrders(t *testing.T) {
	store := &fakeStore{
		orders: []*db.Order{
			{OrderID: "ord_1", Chain: "ETH", SymbolIn: "USDC", SymbolOut: "WETH",
				AmountIn: "1000000", AmountOut: "0.5", Source: "Uniswap V3", Status: 2},
			{OrderID: "ord_2", Chain: "ARB", SymbolIn: "USDT", SymbolOut: "ARB",
				AmountIn: "500000", AmountOut: "10", Source: "1inch", Status: 1},
		},
	}
	r := newHistoryRouter(store)
	w := doGet(r, "/v1/dex/history?user=user-uuid-1&page=1&size=10")
	if w.Code != http.StatusOK {
		t.Fatalf("status = %d; body: %s", w.Code, w.Body.String())
	}

	var resp struct {
		Code int `json:"code"`
		Data struct {
			List []struct {
				OrderID string `json:"order_id"`
				Source  string `json:"source"`
				Status  int    `json:"status"`
			} `json:"list"`
			Page int `json:"page"`
			Size int `json:"size"`
		} `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if len(resp.Data.List) != 2 {
		t.Errorf("list len = %d, want 2", len(resp.Data.List))
	}
	if resp.Data.List[0].OrderID != "ord_1" {
		t.Errorf("first order = %q, want ord_1", resp.Data.List[0].OrderID)
	}
}

func TestHistory_PageSizeClamp(t *testing.T) {
	// size > 100 应被夹到 20
	r := newHistoryRouter(&fakeStore{})
	w := doGet(r, "/v1/dex/history?user=u&size=999&page=0")
	if w.Code != http.StatusOK {
		t.Errorf("status = %d", w.Code)
	}
}

package handlers_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"

	"github.com/n42/n42appv2/backend/swap/db"
	"github.com/n42/n42appv2/backend/swap/handlers"
	"github.com/n42/n42appv2/backend/swap/models"
)

// ─── 桩 ───────────────────────────────────────────────────────────────────────

type fakeAlertStore struct {
	upserted  []string // alert_id 序列
	alerts    []*db.PriceAlert
	deleteErr error
}

func (f *fakeAlertStore) UpsertPriceAlert(alertID, _, _, _, _, _ string, _ bool) error {
	f.upserted = append(f.upserted, alertID)
	return nil
}
func (f *fakeAlertStore) ListPriceAlerts(_ string) ([]*db.PriceAlert, error) {
	return f.alerts, nil
}
func (f *fakeAlertStore) DeletePriceAlert(_, _ string) error { return f.deleteErr }
func (f *fakeAlertStore) ListTriggeredPriceAlertsSince(_ string, _ int64) ([]*db.PriceAlert, error) {
	return f.alerts, nil
}

type fakePrices map[string]float64

func (f fakePrices) CachedPrice(id string) (float64, bool) {
	p, ok := f[id]
	return p, ok
}

func alertRouter(store *fakeAlertStore, prices handlers.AlertPriceSource) *gin.Engine {
	h := handlers.NewAlertHandler(store, prices)
	r := gin.New()
	r.POST("/set", h.Set)
	r.GET("/list", h.List)
	r.DELETE("/remove", h.Remove)
	r.GET("/triggered", h.Triggered)
	return r
}

// ─── Set ─────────────────────────────────────────────────────────────────────

func TestAlertSetCreatesWithGeneratedID(t *testing.T) {
	store := &fakeAlertStore{}
	r := alertRouter(store, nil)

	body, _ := json.Marshal(models.PriceAlertReq{
		UUID: "u1", Symbol: "btc", CoinGeckoID: "bitcoin",
		Direction: "above", TargetPrice: "70000", Enabled: true,
	})
	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/set", bytes.NewReader(body))
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
	}
	if len(store.upserted) != 1 || store.upserted[0] == "" {
		t.Fatalf("expected one upsert with generated id, got %v", store.upserted)
	}
	var resp models.APIResp
	_ = json.Unmarshal(w.Body.Bytes(), &resp)
	if resp.Code != 200 {
		t.Fatalf("resp code = %d", resp.Code)
	}
}

func TestAlertSetKeepsProvidedID(t *testing.T) {
	store := &fakeAlertStore{}
	r := alertRouter(store, nil)

	body, _ := json.Marshal(models.PriceAlertReq{
		UUID: "u1", AlertID: "fixed-id", Symbol: "ETH", CoinGeckoID: "ethereum",
		Direction: "below", TargetPrice: "1500.5", Enabled: true,
	})
	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodPost, "/set", bytes.NewReader(body)))

	if w.Code != http.StatusOK {
		t.Fatalf("status = %d", w.Code)
	}
	if len(store.upserted) != 1 || store.upserted[0] != "fixed-id" {
		t.Fatalf("expected upsert with fixed-id, got %v", store.upserted)
	}
}

func TestAlertSetRejectsBadInput(t *testing.T) {
	cases := []models.PriceAlertReq{
		{Symbol: "BTC", CoinGeckoID: "bitcoin", Direction: "above", TargetPrice: "1"}, // no uuid
		{UUID: "u1", CoinGeckoID: "bitcoin", Direction: "above", TargetPrice: "1"},    // no symbol
		{UUID: "u1", Symbol: "BTC", CoinGeckoID: "bitcoin", Direction: "sideways", TargetPrice: "1"},
		{UUID: "u1", Symbol: "BTC", CoinGeckoID: "bitcoin", Direction: "above", TargetPrice: "-5"},
		{UUID: "u1", Symbol: "BTC", CoinGeckoID: "bitcoin", Direction: "above", TargetPrice: "abc"},
	}
	for i, c := range cases {
		store := &fakeAlertStore{}
		r := alertRouter(store, nil)
		body, _ := json.Marshal(c)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, httptest.NewRequest(http.MethodPost, "/set", bytes.NewReader(body)))
		if w.Code != http.StatusBadRequest {
			t.Fatalf("case %d: status = %d, want 400", i, w.Code)
		}
		if len(store.upserted) != 0 {
			t.Fatalf("case %d: bad input reached store", i)
		}
	}
}

// ─── List ────────────────────────────────────────────────────────────────────

func TestAlertListIncludesCachedCurrentPrice(t *testing.T) {
	trigger := "70123.45"
	ts := int64(1700000000)
	store := &fakeAlertStore{alerts: []*db.PriceAlert{
		{
			AlertID: "a1", Symbol: "BTC", CoinGeckoID: "bitcoin",
			Direction: "above", TargetPrice: "70000", Enabled: true,
			Triggered: true, TriggerPrice: &trigger, TriggeredAt: &ts,
		},
		{
			AlertID: "a2", Symbol: "DOGE", CoinGeckoID: "dogecoin",
			Direction: "below", TargetPrice: "0.1", Enabled: true,
		},
	}}
	r := alertRouter(store, fakePrices{"bitcoin": 68000.5})

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/list?uuid=u1", nil))
	if w.Code != http.StatusOK {
		t.Fatalf("status = %d", w.Code)
	}
	var resp struct {
		Code int                     `json:"code"`
		Data []models.PriceAlertItem `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if len(resp.Data) != 2 {
		t.Fatalf("items = %d, want 2", len(resp.Data))
	}
	if resp.Data[0].CurrentPrice != "68000.5" {
		t.Fatalf("current_price = %q, want 68000.5", resp.Data[0].CurrentPrice)
	}
	if resp.Data[0].TriggerPrice != trigger || resp.Data[0].TriggeredAt != ts {
		t.Fatalf("trigger fields not mapped: %+v", resp.Data[0])
	}
	// dogecoin 无缓存价 → current_price 省略
	if resp.Data[1].CurrentPrice != "" {
		t.Fatalf("expected empty current_price for uncached coin, got %q",
			resp.Data[1].CurrentPrice)
	}
}

func TestAlertListRequiresUUID(t *testing.T) {
	r := alertRouter(&fakeAlertStore{}, nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/list", nil))
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want 400", w.Code)
	}
}

// ─── Remove ──────────────────────────────────────────────────────────────────

func TestAlertRemove(t *testing.T) {
	store := &fakeAlertStore{}
	r := alertRouter(store, nil)
	body, _ := json.Marshal(models.PriceAlertRemoveReq{UUID: "u1", AlertID: "a1"})
	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodDelete, "/remove", bytes.NewReader(body)))
	if w.Code != http.StatusOK {
		t.Fatalf("status = %d", w.Code)
	}
}

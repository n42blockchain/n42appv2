package handlers_test

import (
	"bytes"
	"encoding/json"
	"errors"
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
	upserted     []string // alert_id 序列
	alerts       []*db.PriceAlert
	upsertErr    error
	listErr      error
	deleteErr    error
	triggeredErr error
}

func (f *fakeAlertStore) UpsertPriceAlert(alertID, _, _, _, _, _ string, _ bool) error {
	f.upserted = append(f.upserted, alertID)
	return f.upsertErr
}
func (f *fakeAlertStore) ListPriceAlerts(_ string) ([]*db.PriceAlert, error) {
	return f.alerts, f.listErr
}
func (f *fakeAlertStore) DeletePriceAlert(_, _ string) error { return f.deleteErr }
func (f *fakeAlertStore) ListTriggeredPriceAlertsSince(_ string, _ int64) ([]*db.PriceAlert, error) {
	return f.alerts, f.triggeredErr
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

func TestAlertSetRejectsNonFiniteTargetPrice(t *testing.T) {
	for _, price := range []string{"NaN", "+Inf", "-Inf", "1e309"} {
		t.Run(price, func(t *testing.T) {
			store := &fakeAlertStore{}
			r := alertRouter(store, nil)
			body, _ := json.Marshal(models.PriceAlertReq{
				UUID: "u1", Symbol: "BTC", CoinGeckoID: "bitcoin",
				Direction: "above", TargetPrice: price,
			})
			w := httptest.NewRecorder()
			r.ServeHTTP(w, httptest.NewRequest(http.MethodPost, "/set", bytes.NewReader(body)))
			if w.Code != http.StatusBadRequest {
				t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
			}
			if len(store.upserted) != 0 {
				t.Fatal("non-finite price reached the store")
			}
		})
	}
}

func TestAlertSetMapsOwnershipConflictAndStoreFailure(t *testing.T) {
	for _, tc := range []struct {
		name   string
		err    error
		status int
	}{
		{name: "owned by another user", err: errors.New("alert already owned by another user"), status: http.StatusConflict},
		{name: "database unavailable", err: errors.New("database unavailable"), status: http.StatusInternalServerError},
	} {
		t.Run(tc.name, func(t *testing.T) {
			store := &fakeAlertStore{upsertErr: tc.err}
			r := alertRouter(store, nil)
			body, _ := json.Marshal(models.PriceAlertReq{
				UUID: "u1", AlertID: "alert-1", Symbol: "BTC", CoinGeckoID: "bitcoin",
				Direction: "above", TargetPrice: "70000",
			})
			w := httptest.NewRecorder()
			r.ServeHTTP(w, httptest.NewRequest(http.MethodPost, "/set", bytes.NewReader(body)))
			if w.Code != tc.status {
				t.Fatalf("status=%d body=%s, want %d", w.Code, w.Body.String(), tc.status)
			}
		})
	}
}

func TestAlertTriggeredMapsStoreFailure(t *testing.T) {
	r := alertRouter(&fakeAlertStore{triggeredErr: errors.New("database unavailable")}, nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/triggered?uuid=u1&since=1700000000", nil))
	if w.Code != http.StatusInternalServerError {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
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

package handlers_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"math/big"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"

	"github.com/n42/n42appv2/backend/swap/db"
	"github.com/n42/n42appv2/backend/swap/handlers"
	"github.com/n42/n42appv2/backend/swap/models"
	"github.com/n42/n42appv2/backend/swap/services"
)

func init() { gin.SetMode(gin.TestMode) }

// ─── 桩 ───────────────────────────────────────────────────────────────────────

type fakeStore struct {
	insertErr   error
	insertCalls int
	order       *db.Order
	orders      []*db.Order
}

func (f *fakeStore) InsertOrder(_, _, _, _, _, _, _, _, _, _ string) error {
	f.insertCalls++
	return f.insertErr
}
func (f *fakeStore) UpdateTxHash(_, _ string) error                     { return nil }
func (f *fakeStore) UpdateStatus(_ string, _ int) error                 { return nil }
func (f *fakeStore) GetOrder(_ string) (*db.Order, error)               { return f.order, nil }
func (f *fakeStore) ListOrders(_ string, _, _ int) ([]*db.Order, error) { return f.orders, nil }
func (f *fakeStore) InsertLimitOrder(_, _, _, _, _, _, _, _, _ string, _ int64) error {
	return nil
}
func (f *fakeStore) CancelLimitOrder(_, _ string) error { return nil }
func (f *fakeStore) ListActiveLimitOrders() ([]*db.LimitOrder, error) {
	return nil, nil
}
func (f *fakeStore) ListUserLimitOrders(_ string, _, _ int) ([]*db.LimitOrder, error) {
	return nil, nil
}
func (f *fakeStore) UpdateLimitOrderStatus(_ string, _ int, _ string) error { return nil }
func (f *fakeStore) ExpireStaleOrders() (int64, error)                      { return 0, nil }

type stubAdapter struct {
	chains []string
	resp   *models.QuoteResp
	err    error
}

func (s *stubAdapter) SupportedChains() []string { return s.chains }
func (s *stubAdapter) Quote(_ context.Context, _ models.QuoteReq) (*models.QuoteResp, error) {
	return s.resp, s.err
}

func goodResp() *models.QuoteResp {
	return &models.QuoteResp{
		Source:       "TestDEX",
		AmountOutWei: big.NewInt(500_000_000_000_000_000),
		AmountOut:    "0.5",
		Calldata:     "0xcafe",
		RouterAddr:   "0xrouter",
		Chain:        "ETH",
	}
}

func doPost(r *gin.Engine, path, body string) *httptest.ResponseRecorder {
	w := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodPost, path, bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)
	return w
}

// ─── 测试用例 ─────────────────────────────────────────────────────────────────

func newQuoteRouter(agg *services.Aggregator, store handlers.DEXStore) *gin.Engine {
	r := gin.New()
	h := handlers.NewQuoteHandler(agg, store)
	r.POST("/v1/dex/quote", h.Quote)
	return r
}

func TestQuote_MissingFields(t *testing.T) {
	agg := services.NewAggregator()
	r := newQuoteRouter(agg, &fakeStore{})

	w := doPost(r, "/v1/dex/quote", `{"chain":"ETH"}`)
	if w.Code != http.StatusBadRequest {
		t.Errorf("status = %d, want 400", w.Code)
	}
}

func TestQuote_MalformedJSONReturnsBadRequest(t *testing.T) {
	r := newQuoteRouter(services.NewAggregator(), &fakeStore{})
	if w := doPost(r, "/v1/dex/quote", `{"chain":`); w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
}

func TestQuote_UpstreamFailureReturnsBadGatewayWithoutSavingOrder(t *testing.T) {
	store := &fakeStore{}
	agg := services.NewAggregator(&stubAdapter{
		chains: []string{"ETH"},
		err:    errors.New("provider unavailable"),
	})
	r := newQuoteRouter(agg, store)
	body := `{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"1000","user_addr":"0xU"}`

	w := doPost(r, "/v1/dex/quote", body)

	if w.Code != http.StatusBadGateway {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
	if store.insertCalls != 0 {
		t.Fatalf("persisted order after upstream failure: calls=%d", store.insertCalls)
	}
}

func TestQuote_RejectsNonPositiveUpstreamOutput(t *testing.T) {
	for _, amount := range []*big.Int{nil, big.NewInt(0), big.NewInt(-1)} {
		name := "nil"
		if amount != nil {
			name = amount.String()
		}
		t.Run(name, func(t *testing.T) {
			store := &fakeStore{}
			resp := goodResp()
			resp.AmountOutWei = amount
			agg := services.NewAggregator(&stubAdapter{chains: []string{"ETH"}, resp: resp})
			r := newQuoteRouter(agg, store)
			body := `{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"1000","user_addr":"0xU"}`

			w := doPost(r, "/v1/dex/quote", body)

			if w.Code != http.StatusBadGateway {
				t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
			}
			if store.insertCalls != 0 {
				t.Fatalf("persisted invalid quote: calls=%d", store.insertCalls)
			}
		})
	}
}

func TestQuote_InvalidAmountIn(t *testing.T) {
	agg := services.NewAggregator()
	r := newQuoteRouter(agg, &fakeStore{})

	body := `{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"notanumber","user_addr":"0xU"}`
	w := doPost(r, "/v1/dex/quote", body)
	if w.Code != http.StatusBadRequest {
		t.Errorf("status = %d, want 400", w.Code)
	}
}

func TestQuote_ZeroAmountIn(t *testing.T) {
	agg := services.NewAggregator()
	r := newQuoteRouter(agg, &fakeStore{})

	body := `{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"0","user_addr":"0xU"}`
	w := doPost(r, "/v1/dex/quote", body)
	if w.Code != http.StatusBadRequest {
		t.Errorf("status = %d, want 400", w.Code)
	}
}

func TestQuote_NoAdapters_Returns502(t *testing.T) {
	agg := services.NewAggregator()
	r := newQuoteRouter(agg, &fakeStore{})

	body := `{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"1000000","user_addr":"0xU"}`
	w := doPost(r, "/v1/dex/quote", body)
	if w.Code != http.StatusBadGateway {
		t.Errorf("status = %d, want 502", w.Code)
	}
}

func TestQuote_Success_Returns200WithOrderID(t *testing.T) {
	agg := services.NewAggregator(&stubAdapter{chains: []string{"ETH"}, resp: goodResp()})
	r := newQuoteRouter(agg, &fakeStore{})

	body := `{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"1000000000000000000","user_addr":"0xUser","slippage_bps":50}`
	w := doPost(r, "/v1/dex/quote", body)
	if w.Code != http.StatusOK {
		t.Fatalf("status = %d; body: %s", w.Code, w.Body.String())
	}

	var envelope struct {
		Code int `json:"code"`
		Data struct {
			OrderID string `json:"order_id"`
			Source  string `json:"source"`
		} `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &envelope); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if envelope.Code != 200 {
		t.Errorf("code = %d, want 200", envelope.Code)
	}
	if envelope.Data.OrderID == "" {
		t.Error("order_id should not be empty")
	}
	if envelope.Data.Source != "TestDEX" {
		t.Errorf("source = %q, want TestDEX", envelope.Data.Source)
	}
}

func TestQuote_DefaultSlippage50(t *testing.T) {
	var gotReq models.QuoteReq
	captureAdapter := &captureStub{chains: []string{"ETH"}, resp: goodResp(), capture: &gotReq}
	agg := services.NewAggregator(captureAdapter)
	r := newQuoteRouter(agg, &fakeStore{})

	// 不传 slippage_bps
	body := `{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"1000","user_addr":"0xU"}`
	w := doPost(r, "/v1/dex/quote", body)
	if w.Code != http.StatusOK {
		t.Fatalf("status = %d; body: %s", w.Code, w.Body.String())
	}
	if gotReq.SlippageBps != 50 {
		t.Errorf("default slippage = %d, want 50", gotReq.SlippageBps)
	}
}

type captureStub struct {
	chains  []string
	resp    *models.QuoteResp
	capture *models.QuoteReq
}

func (c *captureStub) SupportedChains() []string { return c.chains }
func (c *captureStub) Quote(_ context.Context, req models.QuoteReq) (*models.QuoteResp, error) {
	*c.capture = req
	return c.resp, nil
}

func TestQuote_RawOutputAndUnknownPriceImpact(t *testing.T) {
	agg := services.NewAggregator(&stubAdapter{chains: []string{"ETH"}, resp: goodResp()})
	r := newQuoteRouter(agg, &fakeStore{})
	w := doPost(r, "/v1/dex/quote", `{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"1000000","user_addr":"0xU"}`)
	var result struct {
		Data struct {
			Raw    string `json:"amount_out_raw"`
			Impact string `json:"price_impact"`
		} `json:"data"`
	}
	if err := json.Unmarshal(w.Body.Bytes(), &result); err != nil {
		t.Fatal(err)
	}
	if result.Data.Raw != "500000000000000000" {
		t.Fatalf("missing exact amount: %s", w.Body.String())
	}
	if result.Data.Impact != "" {
		t.Fatal("must not manufacture a low-risk price impact")
	}
}

func TestQuote_RejectInvalidSlippage(t *testing.T) {
	r := newQuoteRouter(services.NewAggregator(), &fakeStore{})
	for _, body := range []string{
		`{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"1","user_addr":"0xU","slippage_bps":-1}`,
		`{"chain":"ETH","token_in":"0xA","token_out":"0xB","amount_in":"1","user_addr":"0xU","slippage_bps":10001}`,
	} {
		if w := doPost(r, "/v1/dex/quote", body); w.Code != http.StatusBadRequest {
			t.Fatalf("got %d", w.Code)
		}
	}
}

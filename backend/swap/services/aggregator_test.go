package services_test

import (
	"context"
	"errors"
	"math/big"
	"testing"
	"time"

	"github.com/n42/n42appv2/backend/swap/models"
	"github.com/n42/n42appv2/backend/swap/services"
)

// ─── 测试桩 ───────────────────────────────────────────────────────────────────

type stubAdapter struct {
	chains  []string
	resp    *models.QuoteResp
	err     error
	latency time.Duration
}

func (s *stubAdapter) SupportedChains() []string { return s.chains }

func (s *stubAdapter) Quote(ctx context.Context, req models.QuoteReq) (*models.QuoteResp, error) {
	if s.latency > 0 {
		select {
		case <-time.After(s.latency):
		case <-ctx.Done():
			return nil, ctx.Err()
		}
	}
	return s.resp, s.err
}

func makeResp(amountOut int64, source string) *models.QuoteResp {
	return &models.QuoteResp{
		Source:       source,
		AmountOutWei: big.NewInt(amountOut),
		AmountOut:    "1.0",
		Calldata:     "0xdeadbeef",
		RouterAddr:   "0xrouter",
		Chain:        "ETH",
	}
}

func makeReq() models.QuoteReq {
	return models.QuoteReq{
		Chain:       "ETH",
		TokenIn:     "0xTokenIn",
		TokenOut:    "0xTokenOut",
		AmountIn:    "1000000",
		UserAddr:    "0xUser",
		SlippageBps: 50,
		AmountInWei: big.NewInt(1000000),
	}
}

// ─── 测试用例 ─────────────────────────────────────────────────────────────────

func TestAggregator_BestQuote_SingleAdapter(t *testing.T) {
	agg := services.NewAggregator(
		&stubAdapter{chains: []string{"ETH"}, resp: makeResp(1000, "TestDEX")},
	)
	resp, err := agg.BestQuote(context.Background(), makeReq())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.Source != "TestDEX" {
		t.Errorf("source = %q, want %q", resp.Source, "TestDEX")
	}
	if resp.AmountOutWei.Int64() != 1000 {
		t.Errorf("amountOut = %d, want 1000", resp.AmountOutWei.Int64())
	}
}

func TestAggregator_BestQuote_PicksHigherAmount(t *testing.T) {
	agg := services.NewAggregator(
		&stubAdapter{chains: []string{"ETH"}, resp: makeResp(500, "Low")},
		&stubAdapter{chains: []string{"ETH"}, resp: makeResp(900, "High")},
		&stubAdapter{chains: []string{"ETH"}, resp: makeResp(700, "Mid")},
	)
	resp, err := agg.BestQuote(context.Background(), makeReq())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.Source != "High" {
		t.Errorf("expected best source %q, got %q", "High", resp.Source)
	}
}

func TestAggregator_BestQuote_SkipsErrors(t *testing.T) {
	agg := services.NewAggregator(
		&stubAdapter{chains: []string{"ETH"}, err: errors.New("upstream failure")},
		&stubAdapter{chains: []string{"ETH"}, resp: makeResp(800, "Working")},
	)
	resp, err := agg.BestQuote(context.Background(), makeReq())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.Source != "Working" {
		t.Errorf("expected %q, got %q", "Working", resp.Source)
	}
}

func TestAggregator_BestQuote_AllFail_ReturnsErrNoQuote(t *testing.T) {
	agg := services.NewAggregator(
		&stubAdapter{chains: []string{"ETH"}, err: errors.New("err1")},
		&stubAdapter{chains: []string{"ETH"}, err: errors.New("err2")},
	)
	_, err := agg.BestQuote(context.Background(), makeReq())
	if !errors.Is(err, services.ErrNoQuote) {
		t.Errorf("expected ErrNoQuote, got %v", err)
	}
}

func TestAggregator_BestQuote_NoAdaptersForChain(t *testing.T) {
	agg := services.NewAggregator(
		&stubAdapter{chains: []string{"SOL"}, resp: makeResp(1000, "Jupiter")},
	)
	req := makeReq()
	req.Chain = "ETH"
	_, err := agg.BestQuote(context.Background(), req)
	if err == nil {
		t.Fatal("expected error for unsupported chain, got nil")
	}
}

func TestAggregator_BestQuote_EmptyAdapters(t *testing.T) {
	agg := services.NewAggregator()
	_, err := agg.BestQuote(context.Background(), makeReq())
	if err == nil {
		t.Fatal("expected error with no adapters, got nil")
	}
}

func TestAggregator_BestQuote_SlowAdapterTimesOut(t *testing.T) {
	// 慢适配器超过 5 秒超时；快适配器正常返回
	agg := services.NewAggregator(
		&stubAdapter{chains: []string{"ETH"}, resp: makeResp(1000, "Slow"), latency: 10 * time.Second},
		&stubAdapter{chains: []string{"ETH"}, resp: makeResp(900, "Fast"), latency: 0},
	)
	resp, err := agg.BestQuote(context.Background(), makeReq())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	// 慢适配器超时后只有 Fast 返回
	if resp.Source != "Fast" {
		t.Errorf("expected Fast, got %s", resp.Source)
	}
}

func TestAggregator_BestQuote_NilAmountOutWei(t *testing.T) {
	// 适配器返回 nil AmountOutWei 时不崩溃
	badResp := &models.QuoteResp{Source: "Bad", AmountOutWei: nil}
	goodResp := makeResp(500, "Good")

	agg := services.NewAggregator(
		&stubAdapter{chains: []string{"ETH"}, resp: badResp},
		&stubAdapter{chains: []string{"ETH"}, resp: goodResp},
	)
	resp, err := agg.BestQuote(context.Background(), makeReq())
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.Source != "Good" {
		t.Errorf("expected Good, got %s", resp.Source)
	}
}

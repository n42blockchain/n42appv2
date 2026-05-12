package services

import (
	"context"
	"math/big"
	"testing"

	"github.com/n42/n42appv2/backend/swap/db"
	"github.com/n42/n42appv2/backend/swap/models"
)

func TestReferenceAmountUsesTokenDecimals(t *testing.T) {
	tests := []struct {
		name   string
		chain  string
		token  string
		symbol string
		want   string
	}{
		{
			name:   "ethereum usdc address",
			chain:  "ETH",
			token:  "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
			symbol: "USDC",
			want:   "1000000",
		},
		{
			name:   "solana native",
			chain:  "SOL",
			token:  "So11111111111111111111111111111111111111112",
			symbol: "SOL",
			want:   "1000000000",
		},
		{
			name:   "unknown evm token",
			chain:  "ETH",
			token:  "0x0000000000000000000000000000000000000001",
			symbol: "CUSTOM",
			want:   "1000000000000000000",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := referenceAmount(tt.chain, tt.token, tt.symbol); got != tt.want {
				t.Fatalf("referenceAmount() = %s, want %s", got, tt.want)
			}
		})
	}
}

func TestQuoteOutputAmountUsesOutputTokenDecimals(t *testing.T) {
	resp := &models.QuoteResp{
		AmountOut:    "0.00000000",
		AmountOutWei: big.NewInt(1_000_000),
	}

	got, ok := quoteOutputAmount(
		resp,
		"ETH",
		"0xdAC17F958D2ee523a2206206994597C13D831ec7",
		"USDT",
	)
	if !ok {
		t.Fatal("quoteOutputAmount() failed")
	}
	if got != 1 {
		t.Fatalf("quoteOutputAmount() = %v, want 1", got)
	}
}

func TestCheckPairTriggersNon18DecimalOutput(t *testing.T) {
	store := &fakeLimitOrderStore{}
	monitor := NewPriceMonitor(store, NewAggregator(staticQuoteAdapter{
		chain: "ETH",
		resp: &models.QuoteResp{
			AmountOut:    "0.00000000",
			AmountOutWei: big.NewInt(1_000_000),
		},
	}))

	order := &db.LimitOrder{
		OrderID:    "limit-1",
		Chain:      "ETH",
		TokenIn:    "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
		TokenOut:   "0xdAC17F958D2ee523a2206206994597C13D831ec7",
		SymbolIn:   "USDC",
		SymbolOut:  "USDT",
		LimitPrice: "0.99",
	}

	monitor.checkPair(
		context.Background(),
		pairKey{chain: order.Chain, tokenIn: order.TokenIn, tokenOut: order.TokenOut},
		[]*db.LimitOrder{order},
	)

	if store.triggeredOrderID != order.OrderID {
		t.Fatalf("triggeredOrderID = %q, want %q", store.triggeredOrderID, order.OrderID)
	}
}

type staticQuoteAdapter struct {
	chain string
	resp  *models.QuoteResp
}

func (a staticQuoteAdapter) SupportedChains() []string {
	return []string{a.chain}
}

func (a staticQuoteAdapter) Quote(context.Context, models.QuoteReq) (*models.QuoteResp, error) {
	return a.resp, nil
}

type fakeLimitOrderStore struct {
	triggeredOrderID string
}

func (s *fakeLimitOrderStore) ListActiveLimitOrders() ([]*db.LimitOrder, error) {
	return nil, nil
}

func (s *fakeLimitOrderStore) UpdateLimitOrderStatus(orderID string, status int, txHash string) error {
	if status == db.LimitStatusTriggered {
		s.triggeredOrderID = orderID
	}
	return nil
}

func (s *fakeLimitOrderStore) ExpireStaleOrders() (int64, error) {
	return 0, nil
}

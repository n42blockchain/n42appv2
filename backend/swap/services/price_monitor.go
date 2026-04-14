package services

import (
	"context"
	"log"
	"math/big"
	"strconv"
	"time"

	"github.com/n42/n42appv2/backend/swap/db"
	"github.com/n42/n42appv2/backend/swap/models"
)

// LimitOrderStore is the minimal DB interface needed by PriceMonitor.
type LimitOrderStore interface {
	ListActiveLimitOrders() ([]*db.LimitOrder, error)
	UpdateLimitOrderStatus(orderID string, status int, txHash string) error
	ExpireStaleOrders() (int64, error)
}

// PriceMonitor periodically checks active limit orders against current market prices.
// When a limit order's target price is reached, it triggers execution via the aggregator.
type PriceMonitor struct {
	db  LimitOrderStore
	agg *Aggregator
}

// NewPriceMonitor creates a PriceMonitor instance.
func NewPriceMonitor(database LimitOrderStore, agg *Aggregator) *PriceMonitor {
	return &PriceMonitor{db: database, agg: agg}
}

// Start begins the monitoring loop. Blocks until ctx is cancelled.
func (pm *PriceMonitor) Start(ctx context.Context) {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	log.Println("[price-monitor] started, checking every 30s")

	for {
		select {
		case <-ctx.Done():
			log.Println("[price-monitor] stopped")
			return
		case <-ticker.C:
			pm.tick(ctx)
		}
	}
}

// pairKey groups orders by chain+tokenIn+tokenOut for batch price queries
type pairKey struct {
	chain    string
	tokenIn  string
	tokenOut string
}

func (pm *PriceMonitor) tick(ctx context.Context) {
	// Expire stale orders first
	if expired, err := pm.db.ExpireStaleOrders(); err != nil {
		log.Printf("[price-monitor] expire error: %v", err)
	} else if expired > 0 {
		log.Printf("[price-monitor] expired %d stale orders", expired)
	}

	// Fetch all active limit orders
	orders, err := pm.db.ListActiveLimitOrders()
	if err != nil {
		log.Printf("[price-monitor] list error: %v", err)
		return
	}
	if len(orders) == 0 {
		return
	}

	// Group orders by trading pair to avoid redundant price queries
	grouped := map[pairKey][]*db.LimitOrder{}
	for _, o := range orders {
		k := pairKey{chain: o.Chain, tokenIn: o.TokenIn, tokenOut: o.TokenOut}
		grouped[k] = append(grouped[k], o)
	}

	for pair, pairOrders := range grouped {
		select {
		case <-ctx.Done():
			return
		default:
		}
		pm.checkPair(ctx, pair, pairOrders)
	}
}

func (pm *PriceMonitor) checkPair(ctx context.Context, pair pairKey, orders []*db.LimitOrder) {
	refAmount := referenceAmount(pair.chain)

	quoteCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	resp, err := pm.agg.BestQuote(quoteCtx, models.QuoteReq{
		Chain:       pair.chain,
		TokenIn:     pair.tokenIn,
		TokenOut:    pair.tokenOut,
		AmountIn:    refAmount,
		AmountInWei: mustParseBigInt(refAmount),
		UserAddr:    "0x0000000000000000000000000000000000000000",
		SlippageBps: 100,
	})
	if err != nil {
		return
	}

	currentPrice, ok := parseDecimal(resp.AmountOut)
	if !ok || currentPrice <= 0 {
		return
	}

	for _, order := range orders {
		limitPrice, ok := parseDecimal(order.LimitPrice)
		if !ok || limitPrice <= 0 {
			continue
		}
		if currentPrice >= limitPrice {
			log.Printf("[price-monitor] triggered order %s: current=%.6f >= limit=%.6f",
				order.OrderID, currentPrice, limitPrice)
			pm.triggerOrder(order)
		}
	}
}

func (pm *PriceMonitor) triggerOrder(order *db.LimitOrder) {
	// Mark as triggered
	if err := pm.db.UpdateLimitOrderStatus(order.OrderID, db.LimitStatusTriggered, ""); err != nil {
		log.Printf("[price-monitor] trigger update error: %v", err)
		return
	}

	// TODO: Execute the swap transaction
	// This requires the user's wallet to sign the transaction.
	// Options:
	// 1. Use session keys (AA) for pre-approved execution
	// 2. Send push notification to user for manual confirmation
	// 3. Use a keeper/relayer service with pre-signed approvals
	//
	// For now, we mark as triggered and let the frontend poll for status changes.
	log.Printf("[price-monitor] order %s marked as triggered, awaiting execution", order.OrderID)
}

// referenceAmount returns a reasonable reference amount (in wei) for price checking.
// Uses 1 ETH equivalent for EVM chains, 1 SOL for Solana.
func referenceAmount(chain string) string {
	switch chain {
	case "SOL":
		return "1000000000" // 1 SOL = 10^9 lamports
	default:
		return "1000000000000000000" // 1 ETH = 10^18 wei
	}
}

func mustParseBigInt(s string) *big.Int {
	n, _ := new(big.Int).SetString(s, 10)
	return n
}

func parseDecimal(s string) (float64, bool) {
	f, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0, false
	}
	return f, true
}

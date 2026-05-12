package services

import (
	"context"
	"log"
	"math/big"
	"strconv"
	"strings"
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
	if len(orders) == 0 {
		return
	}

	refAmount := referenceAmount(pair.chain, pair.tokenIn, orders[0].SymbolIn)

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

	currentPrice, ok := quoteOutputAmount(resp, pair.chain, pair.tokenOut, orders[0].SymbolOut)
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

// referenceAmount returns one whole input token in base units.
func referenceAmount(chain, tokenAddress, symbol string) string {
	decimals := tokenDecimals(chain, tokenAddress, symbol)
	return new(big.Int).Exp(big.NewInt(10), big.NewInt(int64(decimals)), nil).String()
}

func quoteOutputAmount(resp *models.QuoteResp, chain, tokenAddress, symbol string) (float64, bool) {
	if resp == nil {
		return 0, false
	}
	if resp.AmountOutWei != nil {
		out := weiToHuman(resp.AmountOutWei, tokenDecimals(chain, tokenAddress, symbol))
		return parseDecimal(out)
	}
	return parseDecimal(resp.AmountOut)
}

var tokenDecimalOverrides = map[string]int{
	"ETH:0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48":     6, // USDC
	"ETH:0xdac17f958d2ee523a2206206994597c13d831ec7":     6, // USDT
	"ETH:0x2260fac5e5542a773aa44fbcfedf7c193bc2c599":     8, // WBTC
	"POLYGON:0x2791bca1f2de4661ed88a30c99a7a9449aa84174": 6, // USDC.e
	"POLYGON:0x3c499c542cef5e3811e1192ce70d8cc03d5c3359": 6, // USDC
	"POLYGON:0xc2132d05d31c914a87c6611c10748aeb04b58ef":  6, // USDT
	"POLYGON:0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6": 8, // WBTC
	"ARB:0xaf88d065e77c8cc2239327c5edb3a432268e5831":     6, // USDC
	"ARB:0xff970a61a04b1ca14834a43f5de4533ebddb5cc8":     6, // USDC.e
	"ARB:0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9":     6, // USDT
	"ARB:0x2f2a2543b76a4166549f7aa2b2e75bef0aefc5b0f":    8, // WBTC
	"OP:0x7f5c764cbc14f9669b88837ca1490cca17c31607":      6, // USDC.e
	"OP:0x0b2c639c533813f4aa9d7837caf62653d097ff85":      6, // USDC
	"OP:0x94b008aa00579c1307b0ef2c499ad98a8ce58e58":      6, // USDT
	"OP:0x68f180fcce6836688e9084f035309e29bf0a2095":      8, // WBTC
	"BSC:0xba2ae424d960c26247dd6c32edc70b295c744c43":     8, // DOGE
	"SOL:so11111111111111111111111111111111111111112":    9, // SOL
	"SOL:epjfwdd5aufqssqem2qn1xzybapc8g4wegkgzwydt1v":    6, // USDC
	"SOL:es9vmfrzacermjfrf4h2fyd4kconky11mcce8benwnyb":   6, // USDT
	"SOL:jupyiwryjfskupiha7hker8vutaefosybkedznsdvcn":    6, // JUP
}

var symbolDecimalOverrides = map[string]int{
	"ETH:USDC":       6,
	"ETH:USDT":       6,
	"ETH:WBTC":       8,
	"POLYGON:USDC":   6,
	"POLYGON:USDC.E": 6,
	"POLYGON:USDT":   6,
	"POLYGON:WBTC":   8,
	"ARB:USDC":       6,
	"ARB:USDC.E":     6,
	"ARB:USDT":       6,
	"ARB:WBTC":       8,
	"OP:USDC":        6,
	"OP:USDC.E":      6,
	"OP:USDT":        6,
	"OP:WBTC":        8,
	"BSC:DOGE":       8,
	"SOL:SOL":        9,
	"SOL:USDC":       6,
	"SOL:USDT":       6,
	"SOL:WETH":       8,
	"SOL:WBTC":       8,
	"SOL:JUP":        6,
	"SOL:RAY":        6,
	"SOL:BONK":       5,
	"SOL:WIF":        6,
	"SOL:WEN":        5,
}

func tokenDecimals(chain, tokenAddress, symbol string) int {
	chain = strings.ToUpper(chain)
	tokenAddress = strings.ToLower(tokenAddress)
	symbol = strings.ToUpper(symbol)

	if decimals, ok := tokenDecimalOverrides[chain+":"+tokenAddress]; ok {
		return decimals
	}
	if decimals, ok := symbolDecimalOverrides[chain+":"+symbol]; ok {
		return decimals
	}
	if chain == "SOL" {
		return 9
	}
	return 18
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

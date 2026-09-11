package services

import (
	"context"
	"errors"
	"math/big"
	"strings"
	"sync"
	"time"

	"github.com/n42/n42appv2/backend/swap/models"
)

// ErrNoQuote 所有适配器均未返回有效报价
var ErrNoQuote = errors.New("no valid quote from any adapter")

// Aggregator 并发查询多个 DEX 适配器，返回最优报价
type Aggregator struct {
	adapters []models.Adapter
}

// NewAggregator 创建聚合器实例
func NewAggregator(adapters ...models.Adapter) *Aggregator {
	return &Aggregator{adapters: adapters}
}

// BestQuote 并发查询所有支持指定链的适配器，返回 amountOut 最大的报价
//
// 超时时间固定为 5 秒，任何单个适配器超时只会被静默丢弃。
func (a *Aggregator) BestQuote(
	ctx context.Context,
	req models.QuoteReq,
) (*models.QuoteResp, error) {
	candidates := a.adaptersForChain(req.Chain)
	if len(candidates) == 0 {
		return nil, errors.New("no adapters support chain: " + req.Chain)
	}

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	type result struct {
		resp *models.QuoteResp
		err  error
	}
	ch := make(chan result, len(candidates))
	var wg sync.WaitGroup

	for _, ad := range candidates {
		wg.Add(1)
		go func(ad models.Adapter) {
			defer wg.Done()
			r, err := ad.Quote(ctx, req)
			ch <- result{resp: r, err: err}
		}(ad)
	}

	// 等待所有 goroutine 完成后关闭 channel
	go func() {
		wg.Wait()
		close(ch)
	}()

	var best *models.QuoteResp
	for r := range ch {
		if r.err != nil || r.resp == nil {
			continue
		}
		resp := r.resp
		if best == nil {
			best = resp
			continue
		}
		// 比较 AmountOutWei，取更大值
		if resp.AmountOutWei != nil && best.AmountOutWei != nil {
			if resp.AmountOutWei.Cmp(best.AmountOutWei) > 0 {
				best = resp
			}
		} else if resp.AmountOutWei != nil {
			best = resp
		}
	}

	if best == nil {
		return nil, ErrNoQuote
	}
	return best, nil
}

func (a *Aggregator) adaptersForChain(chain string) []models.Adapter {
	var matched []models.Adapter
	for _, ad := range a.adapters {
		for _, c := range ad.SupportedChains() {
			if c == chain {
				matched = append(matched, ad)
				break
			}
		}
	}
	return matched
}

// weiToHuman 将 wei 大整数转换为人类可读的 ETH 字符串（18 位精度）
func weiToHuman(wei *big.Int, decimals int) string {
	if wei == nil {
		return "0"
	}
	if decimals <= 0 {
		return wei.String()
	}
	digits := wei.String()
	negative := strings.HasPrefix(digits, "-")
	digits = strings.TrimPrefix(digits, "-")
	if len(digits) <= decimals {
		digits = strings.Repeat("0", decimals-len(digits)+1) + digits
	}
	split := len(digits) - decimals
	fraction := strings.TrimRight(digits[split:], "0")
	result := digits[:split]
	if fraction != "" {
		result += "." + fraction
	}
	if negative {
		result = "-" + result
	}
	return result
}

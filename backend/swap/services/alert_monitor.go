package services

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/n42/n42appv2/backend/swap/db"
)

// PriceAlertStore 是 AlertMonitor 对数据库层的最小依赖接口。
type PriceAlertStore interface {
	ListActivePriceAlerts() ([]*db.PriceAlert, error)
	MarkPriceAlertTriggered(alertID, triggerPrice, expectTarget, expectDirection string) (bool, error)
}

// AlertNotifier 触发后的通知出口。默认 LogNotifier；配置 PUSH_WEBHOOK_URL 后
// 走 WebhookNotifier（POST JSON，由运维桥接到 FCM/APNs/任意推送设施）。
// App 侧另有兜底：前台轮询 GET /v1/l/alert/price/triggered。
type AlertNotifier interface {
	NotifyPriceAlert(alert *db.PriceAlert, currentPrice float64)
}

// LogNotifier 仅记日志（默认，无外部依赖）。
type LogNotifier struct{}

// NotifyPriceAlert 输出触发日志。
func (LogNotifier) NotifyPriceAlert(a *db.PriceAlert, price float64) {
	log.Printf("[alert-monitor] TRIGGERED alert=%s user=%s %s %s %s (current=%.8g)",
		a.AlertID, a.UserUUID, a.Symbol, a.Direction, a.TargetPrice, price)
}

// WebhookNotifier 把触发事件 POST 给运维配置的 webhook（负载即
// docs/BACKEND_REQUIREMENTS.md §5.4 的推送数据格式，外加 user_uuid/alert_id）。
type WebhookNotifier struct {
	URL    string
	Client *http.Client
}

// NotifyPriceAlert 发送 webhook；失败仅记日志（App 前台轮询兜底）。
func (w *WebhookNotifier) NotifyPriceAlert(a *db.PriceAlert, price float64) {
	payload, _ := json.Marshal(map[string]any{
		"type":          "price_alert",
		"alert_id":      a.AlertID,
		"user_uuid":     a.UserUUID,
		"symbol":        a.Symbol,
		"direction":     a.Direction,
		"target_price":  a.TargetPrice,
		"current_price": strconv.FormatFloat(price, 'f', -1, 64),
	})
	resp, err := w.Client.Post(w.URL, "application/json", strings.NewReader(string(payload)))
	if err != nil {
		log.Printf("[alert-monitor] webhook error: %v", err)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		log.Printf("[alert-monitor] webhook status %d", resp.StatusCode)
	}
}

// AlertMonitor 周期检查启用中的价格预警：批量查 CoinGecko simple/price，
// 达标即标记触发并通知。价格缓存供 list 接口回显 current_price。
type AlertMonitor struct {
	store    PriceAlertStore
	notifier AlertNotifier
	client   *http.Client

	base   string // CoinGecko base URL（可代理）
	apiKey string // 可选 demo key（x-cg-demo-api-key）

	mu     sync.RWMutex
	prices map[string]float64 // coin_gecko_id -> USD 价（最近一轮）
}

// NewAlertMonitor 创建 AlertMonitor。base 为空用官方 API；notifier 为 nil 用 LogNotifier。
func NewAlertMonitor(store PriceAlertStore, base, apiKey string, notifier AlertNotifier) *AlertMonitor {
	if base == "" {
		base = "https://api.coingecko.com/api/v3"
	}
	if notifier == nil {
		notifier = LogNotifier{}
	}
	return &AlertMonitor{
		store:    store,
		notifier: notifier,
		client:   &http.Client{Timeout: 15 * time.Second},
		base:     strings.TrimRight(base, "/"),
		apiKey:   apiKey,
		prices:   map[string]float64{},
	}
}

// Start 启动监控循环，ctx 取消即退出。
func (m *AlertMonitor) Start(ctx context.Context) {
	ticker := time.NewTicker(60 * time.Second)
	defer ticker.Stop()
	log.Println("[alert-monitor] started, checking every 60s")
	for {
		select {
		case <-ctx.Done():
			log.Println("[alert-monitor] stopped")
			return
		case <-ticker.C:
			m.tick(ctx)
		}
	}
}

// CachedPrice 返回最近一轮的 USD 价（供 list 接口回显）。
func (m *AlertMonitor) CachedPrice(coinGeckoID string) (float64, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	p, ok := m.prices[coinGeckoID]
	return p, ok
}

func (m *AlertMonitor) tick(ctx context.Context) {
	alerts, err := m.store.ListActivePriceAlerts()
	if err != nil {
		log.Printf("[alert-monitor] list error: %v", err)
		return
	}
	if len(alerts) == 0 {
		return
	}

	// 收集去重的 coin_gecko_id，一次批量查价
	idSet := map[string]struct{}{}
	for _, a := range alerts {
		if a.CoinGeckoID != "" {
			idSet[a.CoinGeckoID] = struct{}{}
		}
	}
	ids := make([]string, 0, len(idSet))
	for id := range idSet {
		ids = append(ids, id)
	}

	prices, err := m.fetchPrices(ctx, ids)
	if err != nil {
		log.Printf("[alert-monitor] price fetch error: %v", err)
		return
	}
	m.mu.Lock()
	for id, p := range prices {
		m.prices[id] = p
	}
	m.mu.Unlock()

	for _, a := range alerts {
		price, ok := prices[a.CoinGeckoID]
		if !ok {
			continue
		}
		target, err := strconv.ParseFloat(a.TargetPrice, 64)
		if err != nil {
			continue
		}
		if !ShouldTriggerAlert(a.Direction, target, price) {
			continue
		}
		trigger := strconv.FormatFloat(price, 'f', -1, 64)
		// 传本轮读到的 target/direction 快照做乐观并发——用户若已 upsert 新
		// 目标价并复位 triggered,marked=false,不按旧目标误消费(复审 P1-4c)。
		marked, err := m.store.MarkPriceAlertTriggered(
			a.AlertID, trigger, a.TargetPrice, a.Direction)
		if err != nil {
			log.Printf("[alert-monitor] mark error alert=%s: %v", a.AlertID, err)
			continue
		}
		if marked {
			m.notifier.NotifyPriceAlert(a, price)
		}
	}
}

// ShouldTriggerAlert 触发判定（纯函数，供单测）。
// above：当前价 >= 目标价；below：当前价 <= 目标价。
func ShouldTriggerAlert(direction string, target, current float64) bool {
	switch strings.ToLower(direction) {
	case "above":
		return current >= target
	case "below":
		return current <= target
	default:
		return false
	}
}

// fetchPrices 批量查询 CoinGecko simple/price（USD）。
// 每批最多 250 个 id（CoinGecko 上限），顺序分批。
func (m *AlertMonitor) fetchPrices(ctx context.Context, ids []string) (map[string]float64, error) {
	out := map[string]float64{}
	const batch = 250
	for start := 0; start < len(ids); start += batch {
		end := start + batch
		if end > len(ids) {
			end = len(ids)
		}
		if err := m.fetchPriceBatch(ctx, ids[start:end], out); err != nil {
			return out, err
		}
	}
	return out, nil
}

func (m *AlertMonitor) fetchPriceBatch(ctx context.Context, ids []string, out map[string]float64) error {
	q := url.Values{}
	q.Set("ids", strings.Join(ids, ","))
	q.Set("vs_currencies", "usd")
	req, err := http.NewRequestWithContext(ctx, http.MethodGet,
		m.base+"/simple/price?"+q.Encode(), nil)
	if err != nil {
		return err
	}
	if m.apiKey != "" {
		req.Header.Set("x-cg-demo-api-key", m.apiKey)
	}
	resp, err := m.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("coingecko status %d", resp.StatusCode)
	}
	var body map[string]map[string]float64
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return err
	}
	for id, cur := range body {
		if usd, ok := cur["usd"]; ok {
			out[id] = usd
		}
	}
	return nil
}

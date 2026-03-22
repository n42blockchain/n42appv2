package monitor

import (
	"context"
	"log"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"

	"github.com/n42/n42appv2/backend/swap/models"
)

// StatusUpdater 是 Monitor 对数据库层的最小依赖接口。
// db.DB 隐式满足此接口。
type StatusUpdater interface {
	UpdateStatus(orderID string, status int) error
}

// Monitor 异步轮询 txHash 确认状态
type Monitor struct {
	db      StatusUpdater
	rpcURLs map[string]string // chain → RPC URL
}

// New 创建 Monitor
func New(database StatusUpdater, rpcURLs map[string]string) *Monitor {
	return &Monitor{db: database, rpcURLs: rpcURLs}
}

// Watch 启动后台 goroutine 轮询 tx 确认状态
//
// 检查间隔：5 秒
// 最大等待：30 分钟，超时后将订单标记为 failed
func (m *Monitor) Watch(orderID, chain, txHash string) {
	if m.db == nil {
		return
	}
	go func() {
		rpcURL, ok := m.rpcURLs[chain]
		if !ok {
			log.Printf("[monitor] no RPC for chain %s, order %s", chain, orderID)
			_ = m.db.UpdateStatus(orderID, models.StatusFailed)
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
		defer cancel()

		client, err := ethclient.DialContext(ctx, rpcURL)
		if err != nil {
			log.Printf("[monitor] dial %s error: %v", rpcURL, err)
			_ = m.db.UpdateStatus(orderID, models.StatusFailed)
			return
		}
		defer client.Close()

		ticker := time.NewTicker(5 * time.Second)
		defer ticker.Stop()

		log.Printf("[monitor] watching %s on %s (order=%s)", txHash, chain, orderID)

		for {
			select {
			case <-ctx.Done():
				log.Printf("[monitor] timeout order %s", orderID)
				_ = m.db.UpdateStatus(orderID, models.StatusFailed)
				return
			case <-ticker.C:
				confirmed, checkErr := m.checkConfirmed(ctx, client, txHash)
				if checkErr != nil {
					log.Printf("[monitor] check %s error: %v", txHash, checkErr)
					continue
				}
				if confirmed {
					log.Printf("[monitor] confirmed order %s tx %s", orderID, txHash)
					_ = m.db.UpdateStatus(orderID, models.StatusConfirmed)
					return
				}
			}
		}
	}()
}

// checkConfirmed 查询 EVM 交易是否已上链（receipt status == 1）
func (m *Monitor) checkConfirmed(parent context.Context, client *ethclient.Client, txHash string) (bool, error) {
	ctx, cancel := context.WithTimeout(parent, 5*time.Second)
	defer cancel()

	receipt, err := client.TransactionReceipt(ctx, common.HexToHash(txHash))
	if err != nil {
		if err.Error() == "not found" || err.Error() == "transaction indexing is in progress" {
			return false, nil
		}
		return false, err
	}
	return receipt.Status == 1, nil
}

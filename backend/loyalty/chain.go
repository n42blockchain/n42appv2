package main

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"math/big"
	"strings"
	"sync"
	"time"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

type chainAccount struct {
	Available      *big.Int
	TotalEarned    *big.Int
	TotalSpent     *big.Int
	LastCheckInDay uint64
}

type loyaltyChain interface {
	Account(ctx context.Context, wallet common.Address) (chainAccount, error)
	DailyCheckInPoints(ctx context.Context) (uint64, error)
	CheckedInToday(ctx context.Context, wallet common.Address) (bool, error)
	CheckIn(ctx context.Context, wallet common.Address, requestID [32]byte) (common.Hash, error)
	AwardTask(ctx context.Context, wallet common.Address, taskID [32]byte, points uint64, requestID [32]byte) (common.Hash, error)
	RegisterReferral(ctx context.Context, referrer, referred common.Address, referrerPoints, referredPoints uint64, requestID [32]byte) (common.Hash, error)
}

const loyaltyABI = `[
  {"inputs":[{"name":"account","type":"address"}],"name":"accountOf","outputs":[{"components":[{"name":"available","type":"uint128"},{"name":"totalEarned","type":"uint128"},{"name":"totalSpent","type":"uint128"},{"name":"lastCheckInDay","type":"uint64"}],"type":"tuple"}],"stateMutability":"view","type":"function"},
  {"inputs":[],"name":"dailyCheckInPoints","outputs":[{"type":"uint128"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"name":"account","type":"address"}],"name":"checkedInToday","outputs":[{"type":"bool"}],"stateMutability":"view","type":"function"},
  {"inputs":[{"name":"account","type":"address"},{"name":"requestId","type":"bytes32"}],"name":"checkInFor","outputs":[],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[{"name":"account","type":"address"},{"name":"taskId","type":"bytes32"},{"name":"amount","type":"uint128"},{"name":"requestId","type":"bytes32"}],"name":"awardTaskFor","outputs":[],"stateMutability":"nonpayable","type":"function"},
  {"inputs":[{"name":"referrer","type":"address"},{"name":"referred","type":"address"},{"name":"referrerPoints","type":"uint128"},{"name":"referredPoints","type":"uint128"},{"name":"requestId","type":"bytes32"}],"name":"registerReferral","outputs":[],"stateMutability":"nonpayable","type":"function"}
]`

type contractChain struct {
	client   *ethclient.Client
	contract *bind.BoundContract
	key      *ecdsa.PrivateKey
	chainID  *big.Int
	txMu     sync.Mutex
}

func newContractChain(ctx context.Context, rpcURL, contractAddress, privateKey string) (*contractChain, error) {
	if !common.IsHexAddress(contractAddress) || common.HexToAddress(contractAddress) == (common.Address{}) {
		return nil, fmt.Errorf("invalid contract address")
	}
	client, err := ethclient.DialContext(ctx, rpcURL)
	if err != nil {
		return nil, fmt.Errorf("dial N42 RPC: %w", err)
	}
	parsedABI, err := abi.JSON(strings.NewReader(loyaltyABI))
	if err != nil {
		client.Close()
		return nil, err
	}
	key, err := crypto.HexToECDSA(strings.TrimPrefix(privateKey, "0x"))
	if err != nil {
		client.Close()
		return nil, fmt.Errorf("parse relayer key: %w", err)
	}
	chainID, err := client.ChainID(ctx)
	if err != nil {
		client.Close()
		return nil, fmt.Errorf("read chain id: %w", err)
	}
	return &contractChain{
		client: client,
		contract: bind.NewBoundContract(
			common.HexToAddress(contractAddress),
			parsedABI,
			client,
			client,
			client,
		),
		key:     key,
		chainID: chainID,
	}, nil
}

func (c *contractChain) Close() { c.client.Close() }

func (c *contractChain) Account(ctx context.Context, wallet common.Address) (chainAccount, error) {
	var output []interface{}
	if err := c.contract.Call(&bind.CallOpts{Context: ctx}, &output, "accountOf", wallet); err != nil {
		return chainAccount{}, err
	}
	if len(output) != 1 {
		return chainAccount{}, fmt.Errorf("accountOf returned %d values", len(output))
	}
	converted := abi.ConvertType(output[0], new(chainAccount))
	account, ok := converted.(*chainAccount)
	if !ok || account == nil {
		return chainAccount{}, fmt.Errorf("invalid accountOf tuple")
	}
	return *account, nil
}

func (c *contractChain) DailyCheckInPoints(ctx context.Context) (uint64, error) {
	var output []interface{}
	if err := c.contract.Call(&bind.CallOpts{Context: ctx}, &output, "dailyCheckInPoints"); err != nil {
		return 0, err
	}
	if len(output) != 1 {
		return 0, fmt.Errorf("dailyCheckInPoints returned %d values", len(output))
	}
	points, ok := output[0].(*big.Int)
	if !ok || points == nil || points.Sign() <= 0 || !points.IsInt64() {
		return 0, fmt.Errorf("invalid dailyCheckInPoints response")
	}
	return points.Uint64(), nil
}

func (c *contractChain) CheckedInToday(ctx context.Context, wallet common.Address) (bool, error) {
	var output []interface{}
	if err := c.contract.Call(&bind.CallOpts{Context: ctx}, &output, "checkedInToday", wallet); err != nil {
		return false, err
	}
	if len(output) != 1 {
		return false, fmt.Errorf("checkedInToday returned %d values", len(output))
	}
	checked, ok := output[0].(bool)
	if !ok {
		return false, fmt.Errorf("invalid checkedInToday response")
	}
	return checked, nil
}

func (c *contractChain) CheckIn(ctx context.Context, wallet common.Address, requestID [32]byte) (common.Hash, error) {
	return c.transact(ctx, "checkInFor", wallet, requestID)
}

func (c *contractChain) AwardTask(ctx context.Context, wallet common.Address, taskID [32]byte, points uint64, requestID [32]byte) (common.Hash, error) {
	return c.transact(ctx, "awardTaskFor", wallet, taskID, new(big.Int).SetUint64(points), requestID)
}

func (c *contractChain) RegisterReferral(ctx context.Context, referrer, referred common.Address, referrerPoints, referredPoints uint64, requestID [32]byte) (common.Hash, error) {
	return c.transact(
		ctx,
		"registerReferral",
		referrer,
		referred,
		new(big.Int).SetUint64(referrerPoints),
		new(big.Int).SetUint64(referredPoints),
		requestID,
	)
}

func (c *contractChain) transact(ctx context.Context, method string, args ...interface{}) (common.Hash, error) {
	c.txMu.Lock()
	defer c.txMu.Unlock()
	auth, err := bind.NewKeyedTransactorWithChainID(c.key, c.chainID)
	if err != nil {
		return common.Hash{}, err
	}
	auth.Context = ctx
	tx, err := c.contract.Transact(auth, method, args...)
	if err != nil {
		return common.Hash{}, err
	}
	waitCtx, cancel := context.WithTimeout(ctx, 60*time.Second)
	defer cancel()
	receipt, err := bind.WaitMined(waitCtx, c.client, tx)
	if err != nil {
		return tx.Hash(), err
	}
	if receipt.Status != types.ReceiptStatusSuccessful {
		return tx.Hash(), fmt.Errorf("transaction reverted")
	}
	return tx.Hash(), nil
}

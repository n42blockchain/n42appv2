package main

import (
	"bytes"
	"context"
	"encoding/json"
	"math/big"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/ethereum/go-ethereum/common"
	"github.com/gin-gonic/gin"
)

const testWallet = "0x1111111111111111111111111111111111111111"

type fakeAuth struct{ wallet string }

func (f fakeAuth) Verify(context.Context, string, string) (identity, error) {
	return identity{UUID: "user", Wallet: f.wallet}, nil
}

type fakeChain struct {
	checkedIn bool
	checkIns  int
	daily     uint64
	accounts  map[common.Address]chainAccount
}

func (f *fakeChain) Account(_ context.Context, wallet common.Address) (chainAccount, error) {
	if account, ok := f.accounts[wallet]; ok {
		return account, nil
	}
	earned := int64(0)
	if f.checkedIn {
		earned = 10
	}
	return chainAccount{
		Available:   big.NewInt(earned),
		TotalEarned: big.NewInt(earned),
		TotalSpent:  big.NewInt(0),
	}, nil
}

func (f *fakeChain) DailyCheckInPoints(context.Context) (uint64, error) {
	if f.daily == 0 {
		return 10, nil
	}
	return f.daily, nil
}

func (f *fakeChain) CheckedInToday(context.Context, common.Address) (bool, error) {
	return f.checkedIn, nil
}

func (f *fakeChain) CheckIn(context.Context, common.Address, [32]byte) (common.Hash, error) {
	f.checkedIn = true
	f.checkIns++
	return common.HexToHash("0x1234"), nil
}

func (f *fakeChain) AwardTask(context.Context, common.Address, [32]byte, uint64, [32]byte) (common.Hash, error) {
	return common.Hash{}, nil
}

func (f *fakeChain) RegisterReferral(_ context.Context, referrer, referred common.Address, referrerPoints, referredPoints uint64, _ [32]byte) (common.Hash, error) {
	if f.accounts == nil {
		f.accounts = make(map[common.Address]chainAccount)
	}
	f.accounts[referrer] = pointAccount(referrerPoints)
	f.accounts[referred] = pointAccount(referredPoints)
	return common.HexToHash("0x5678"), nil
}

type fakeStore struct {
	historyPoints int64
	syncedWallets []string
	historyWrites []fakeHistoryWrite
}

type fakeHistoryWrite struct {
	wallet    string
	points    int64
	requestID string
}

func (f *fakeStore) SyncAccount(_ context.Context, wallet string, _ chainAccount) error {
	f.syncedWallets = append(f.syncedWallets, wallet)
	return nil
}
func (f *fakeStore) Tasks(context.Context, bool) ([]taskRecord, error) { return nil, nil }
func (f *fakeStore) Rewards(context.Context) ([]rewardRecord, error)   { return nil, nil }
func (f *fakeStore) History(context.Context, string) ([]historyRecord, error) {
	return nil, nil
}
func (f *fakeStore) Referrals(context.Context, string) ([]referralRecord, error) {
	return nil, nil
}
func (f *fakeStore) Leaderboard(context.Context) ([]leaderboardRecord, error) {
	return nil, nil
}
func (f *fakeStore) RecordHistory(_ context.Context, wallet, _ string, points int64, _, _, requestID string) error {
	f.historyPoints = points
	f.historyWrites = append(f.historyWrites, fakeHistoryWrite{
		wallet:    wallet,
		points:    points,
		requestID: requestID,
	})
	return nil
}
func (f *fakeStore) RecordReferral(context.Context, string, string, int64, string) error {
	return nil
}

func TestTasksUsesDailyPointsConfiguredOnChain(t *testing.T) {
	gin.SetMode(gin.TestMode)
	chain := &fakeChain{daily: 25}
	store := &fakeStoreWithDailyTask{fakeStore: fakeStore{}}
	router := newHandler(chain, store, fakeAuth{wallet: testWallet}, "internal").router()
	req := httptest.NewRequest(http.MethodGet, "/loyalty/v1/tasks?wallet="+testWallet, nil)
	req.Header.Set("UUID", "user")
	req.Header.Set("Token", "token")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, req)

	if recorder.Code != http.StatusOK {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
	if !bytes.Contains(recorder.Body.Bytes(), []byte(`"points":25`)) {
		t.Fatalf("daily points did not come from contract: %s", recorder.Body.String())
	}
}

type fakeStoreWithDailyTask struct{ fakeStore }

func (f *fakeStoreWithDailyTask) Tasks(context.Context, bool) ([]taskRecord, error) {
	return []taskRecord{{ID: "daily-checkin", Points: 10, Status: "available"}}, nil
}

func TestCheckInVerifiesWalletAndReturnsConfirmedAward(t *testing.T) {
	gin.SetMode(gin.TestMode)
	chain := &fakeChain{}
	store := &fakeStore{}
	router := newHandler(chain, store, fakeAuth{wallet: testWallet}, "internal").router()
	body, _ := json.Marshal(map[string]string{"wallet": testWallet})
	req := httptest.NewRequest(http.MethodPost, "/loyalty/v1/check-in", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("UUID", "user")
	req.Header.Set("Token", "token")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, req)

	if recorder.Code != http.StatusOK {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
	if chain.checkIns != 1 || store.historyPoints != 10 {
		t.Fatalf("checkIns=%d historyPoints=%d", chain.checkIns, store.historyPoints)
	}
	if !bytes.Contains(recorder.Body.Bytes(), []byte(`"tx_hash":"0x0000000000000000000000000000000000000000000000000000000000001234"`)) {
		t.Fatalf("missing transaction hash: %s", recorder.Body.String())
	}
}

func TestCheckInRejectsWalletNotBoundToAuthenticatedUser(t *testing.T) {
	gin.SetMode(gin.TestMode)
	chain := &fakeChain{}
	router := newHandler(
		chain,
		&fakeStore{},
		fakeAuth{wallet: "0x2222222222222222222222222222222222222222"},
		"internal",
	).router()
	body, _ := json.Marshal(map[string]string{"wallet": testWallet})
	req := httptest.NewRequest(http.MethodPost, "/loyalty/v1/check-in", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("UUID", "user")
	req.Header.Set("Token", "token")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, req)

	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
	if chain.checkIns != 0 {
		t.Fatal("unauthorized request reached relayer")
	}
}

func TestCheckedPointsRejectsNegativeAndOverflowValues(t *testing.T) {
	if _, err := checkedPoints(big.NewInt(-1), "test"); err == nil {
		t.Fatal("negative points accepted")
	}
	overflow := new(big.Int).Lsh(big.NewInt(1), 80)
	if _, err := checkedPoints(overflow, "test"); err == nil {
		t.Fatal("overflow points accepted")
	}
}

func TestRegisterReferralSynchronizesAndRecordsBothAccounts(t *testing.T) {
	gin.SetMode(gin.TestMode)
	chain := &fakeChain{}
	store := &fakeStore{}
	router := newHandler(chain, store, fakeAuth{wallet: testWallet}, "internal").router()
	referred := "0x2222222222222222222222222222222222222222"
	body, _ := json.Marshal(map[string]interface{}{
		"referrer":        testWallet,
		"referred":        referred,
		"referrer_points": 30,
		"referred_points": 10,
		"request_id":      "referral-1",
	})
	req := httptest.NewRequest(http.MethodPost, "/loyalty/v1/internal/referral", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Internal-Token", "internal")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, req)

	if recorder.Code != http.StatusOK {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
	if len(store.syncedWallets) != 2 {
		t.Fatalf("synced wallets=%v", store.syncedWallets)
	}
	if len(store.historyWrites) != 2 {
		t.Fatalf("history writes=%v", store.historyWrites)
	}
	if store.historyWrites[0].points != 30 || store.historyWrites[0].requestID != "referral-1:referrer" {
		t.Fatalf("referrer history=%+v", store.historyWrites[0])
	}
	if store.historyWrites[1].points != 10 || store.historyWrites[1].requestID != "referral-1:referred" {
		t.Fatalf("referred history=%+v", store.historyWrites[1])
	}
}

func pointAccount(points uint64) chainAccount {
	value := new(big.Int).SetUint64(points)
	return chainAccount{
		Available:   new(big.Int).Set(value),
		TotalEarned: new(big.Int).Set(value),
		TotalSpent:  big.NewInt(0),
	}
}

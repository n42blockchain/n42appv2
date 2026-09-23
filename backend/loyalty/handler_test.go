package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
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

type rejectingAuth struct{ err error }

func (f rejectingAuth) Verify(context.Context, string, string) (identity, error) {
	return identity{}, f.err
}

type fakeChain struct {
	checkedIn  bool
	checkIns   int
	checkCalls int
	awardCalls int
	checkErr   error
	daily      uint64
	accounts   map[common.Address]chainAccount
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
	f.checkCalls++
	return f.checkedIn, f.checkErr
}

func (f *fakeChain) CheckIn(context.Context, common.Address, [32]byte) (common.Hash, error) {
	f.checkedIn = true
	f.checkIns++
	return common.HexToHash("0x1234"), nil
}

func (f *fakeChain) AwardTask(context.Context, common.Address, [32]byte, uint64, [32]byte) (common.Hash, error) {
	f.awardCalls++
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
	tasksErr      error
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
func (f *fakeStore) Tasks(context.Context, bool) ([]taskRecord, error) {
	return nil, f.tasksErr
}
func (f *fakeStore) Rewards(context.Context) ([]rewardRecord, error) { return nil, nil }
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

func TestTasksRejectsFailedAuthenticationBeforeCallingChain(t *testing.T) {
	gin.SetMode(gin.TestMode)
	chain := &fakeChain{}
	router := newHandler(chain, &fakeStore{}, rejectingAuth{err: errUnauthorized}, "internal").router()
	req := httptest.NewRequest(http.MethodGet, "/loyalty/v1/tasks?wallet="+testWallet, nil)
	req.Header.Set("UUID", "user")
	req.Header.Set("Token", "invalid")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, req)

	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
	if chain.checkCalls != 0 {
		t.Fatal("unauthenticated request reached the chain")
	}
}

func TestTasksMapsChainAndStoreFailuresToBadGateway(t *testing.T) {
	for _, tc := range []struct {
		name  string
		chain *fakeChain
		store *fakeStore
	}{
		{name: "chain unavailable", chain: &fakeChain{checkErr: errors.New("rpc unavailable")}, store: &fakeStore{}},
		{name: "store unavailable", chain: &fakeChain{}, store: &fakeStore{tasksErr: errors.New("database unavailable")}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			router := newHandler(tc.chain, tc.store, fakeAuth{wallet: testWallet}, "internal").router()
			req := httptest.NewRequest(http.MethodGet, "/loyalty/v1/tasks?wallet="+testWallet, nil)
			req.Header.Set("UUID", "user")
			req.Header.Set("Token", "valid")
			recorder := httptest.NewRecorder()

			router.ServeHTTP(recorder, req)

			if recorder.Code != http.StatusBadGateway {
				t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
			}
		})
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

type checkInAwardMismatchChain struct {
	fakeChain
	awardDelta int64
	reads      int
}

func (f *checkInAwardMismatchChain) Account(context.Context, common.Address) (chainAccount, error) {
	f.reads++
	total := int64(100)
	if f.reads > 1 {
		total += f.awardDelta
	}
	return chainAccount{
		Available:   big.NewInt(total),
		TotalEarned: big.NewInt(total),
		TotalSpent:  big.NewInt(0),
	}, nil
}

func TestCheckInRejectsZeroOrNegativeOnChainAward(t *testing.T) {
	for _, delta := range []int64{0, -1} {
		t.Run(map[int64]string{0: "zero", -1: "negative"}[delta], func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			chain := &checkInAwardMismatchChain{awardDelta: delta}
			store := &fakeStore{}
			router := newHandler(chain, store, fakeAuth{wallet: testWallet}, "internal").router()
			body, _ := json.Marshal(map[string]string{"wallet": testWallet})
			req := httptest.NewRequest(http.MethodPost, "/loyalty/v1/check-in", bytes.NewReader(body))
			req.Header.Set("Content-Type", "application/json")
			req.Header.Set("UUID", "user")
			req.Header.Set("Token", "token")
			recorder := httptest.NewRecorder()

			router.ServeHTTP(recorder, req)

			if recorder.Code != http.StatusBadGateway {
				t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
			}
			if len(store.syncedWallets) != 0 || len(store.historyWrites) != 0 {
				t.Fatalf("persisted unverified award: synced=%v history=%v", store.syncedWallets, store.historyWrites)
			}
		})
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

func TestInternalAwardRejectsMissingToken(t *testing.T) {
	gin.SetMode(gin.TestMode)
	chain := &fakeChain{}
	router := newHandler(chain, &fakeStore{}, fakeAuth{wallet: testWallet}, "internal").router()
	body, _ := json.Marshal(map[string]interface{}{
		"wallet":     testWallet,
		"task_id":    "task-1",
		"points":     10,
		"request_id": "task-request-1",
	})
	req := httptest.NewRequest(http.MethodPost, "/loyalty/v1/internal/award-task", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	recorder := httptest.NewRecorder()

	router.ServeHTTP(recorder, req)

	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
}

func TestInternalAwardRejectsInvalidPointsBeforeCallingChain(t *testing.T) {
	for _, tc := range []struct {
		name string
		body string
	}{
		{
			name: "zero points",
			body: `{"wallet":"` + testWallet + `","task_id":"task-1","points":0,"request_id":"request-1"}`,
		},
		{
			name: "points exceed int64 storage limit",
			body: `{"wallet":"` + testWallet + `","task_id":"task-1","points":9223372036854775808,"request_id":"request-1"}`,
		},
		{
			name: "malformed wallet",
			body: `{"wallet":"not-an-address","task_id":"task-1","points":1,"request_id":"request-1"}`,
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			chain := &fakeChain{}
			router := newHandler(chain, &fakeStore{}, fakeAuth{wallet: testWallet}, "internal").router()
			req := httptest.NewRequest(http.MethodPost, "/loyalty/v1/internal/award-task", bytes.NewBufferString(tc.body))
			req.Header.Set("Content-Type", "application/json")
			req.Header.Set("X-Internal-Token", "internal")
			recorder := httptest.NewRecorder()

			router.ServeHTTP(recorder, req)

			if recorder.Code != http.StatusBadRequest {
				t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
			}
			if chain.awardCalls != 0 {
				t.Fatalf("invalid award reached chain: calls=%d", chain.awardCalls)
			}
		})
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

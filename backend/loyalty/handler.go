package main

import (
	"crypto/sha256"
	"crypto/subtle"
	"errors"
	"log"
	"math/big"
	"net/http"
	"strings"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/gin-gonic/gin"
)

type handler struct {
	chain         loyaltyChain
	store         store
	auth          authVerifier
	internalToken string
}

func newHandler(chain loyaltyChain, store store, auth authVerifier, internalToken string) *handler {
	return &handler{chain: chain, store: store, auth: auth, internalToken: internalToken}
}

func (h *handler) router() *gin.Engine {
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(func(c *gin.Context) {
		c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, 64<<10)
		c.Next()
	})
	r.GET("/healthz", func(c *gin.Context) { c.JSON(http.StatusOK, gin.H{"ok": true}) })
	v1 := r.Group("/loyalty/v1")
	v1.GET("/account", h.account)
	v1.GET("/tasks", h.tasks)
	v1.GET("/rewards", h.rewards)
	v1.GET("/history", h.history)
	v1.GET("/referral/list", h.referrals)
	v1.GET("/leaderboard", h.leaderboard)
	v1.POST("/check-in", h.checkIn)
	internal := v1.Group("/internal")
	internal.Use(h.requireInternalToken)
	internal.POST("/award-task", h.awardTask)
	internal.POST("/referral", h.registerReferral)
	return r
}

func (h *handler) account(c *gin.Context) {
	wallet, ok := h.authorizeWallet(c, c.Query("wallet"))
	if !ok {
		return
	}
	account, err := h.chain.Account(c.Request.Context(), wallet)
	if err != nil {
		h.serverError(c, err)
		return
	}
	available, err := checkedPoints(account.Available, "available")
	if err != nil {
		h.serverError(c, err)
		return
	}
	totalEarned, err := checkedPoints(account.TotalEarned, "total earned")
	if err != nil {
		h.serverError(c, err)
		return
	}
	totalSpent, err := checkedPoints(account.TotalSpent, "total spent")
	if err != nil {
		h.serverError(c, err)
		return
	}
	if err := h.store.SyncAccount(c.Request.Context(), wallet.Hex(), account); err != nil {
		h.serverError(c, err)
		return
	}
	c.JSON(http.StatusOK, envelope(gin.H{
		"wallet_address":   wallet.Hex(),
		"available_points": available,
		"total_points":     totalEarned,
		"used_points":      totalSpent,
		"tier":             tierFor(totalEarned),
		"tier_progress":    tierProgress(totalEarned),
		"next_tier_points": nextTierPoints(totalEarned),
	}))
}

func (h *handler) tasks(c *gin.Context) {
	wallet, ok := h.authorizeWallet(c, c.Query("wallet"))
	if !ok {
		return
	}
	checked, err := h.chain.CheckedInToday(c.Request.Context(), wallet)
	if err != nil {
		h.serverError(c, err)
		return
	}
	dailyPoints, err := h.chain.DailyCheckInPoints(c.Request.Context())
	if err != nil {
		h.serverError(c, err)
		return
	}
	items, err := h.store.Tasks(c.Request.Context(), checked)
	if err != nil {
		h.serverError(c, err)
		return
	}
	for index := range items {
		if items[index].ID == "daily-checkin" {
			items[index].Points = int64(dailyPoints)
		}
	}
	c.JSON(http.StatusOK, envelope(items))
}

func (h *handler) rewards(c *gin.Context) {
	if _, ok := h.authorizeWallet(c, c.Query("wallet")); !ok {
		return
	}
	items, err := h.store.Rewards(c.Request.Context())
	if err != nil {
		h.serverError(c, err)
		return
	}
	c.JSON(http.StatusOK, envelope(items))
}

func (h *handler) history(c *gin.Context) {
	wallet, ok := h.authorizeWallet(c, c.Query("wallet"))
	if !ok {
		return
	}
	items, err := h.store.History(c.Request.Context(), wallet.Hex())
	if err != nil {
		h.serverError(c, err)
		return
	}
	c.JSON(http.StatusOK, envelope(items))
}

func (h *handler) referrals(c *gin.Context) {
	wallet, ok := h.authorizeWallet(c, c.Query("wallet"))
	if !ok {
		return
	}
	items, err := h.store.Referrals(c.Request.Context(), wallet.Hex())
	if err != nil {
		h.serverError(c, err)
		return
	}
	c.JSON(http.StatusOK, envelope(items))
}

func (h *handler) leaderboard(c *gin.Context) {
	if _, ok := h.authorizeWallet(c, c.Query("wallet")); !ok {
		return
	}
	items, err := h.store.Leaderboard(c.Request.Context())
	if err != nil {
		h.serverError(c, err)
		return
	}
	c.JSON(http.StatusOK, envelope(items))
}

func (h *handler) checkIn(c *gin.Context) {
	var body struct {
		Wallet string `json:"wallet" binding:"required"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, errorEnvelope("invalid request"))
		return
	}
	wallet, ok := h.authorizeWallet(c, body.Wallet)
	if !ok {
		return
	}
	checked, err := h.chain.CheckedInToday(c.Request.Context(), wallet)
	if err != nil {
		h.serverError(c, err)
		return
	}
	if checked {
		c.JSON(http.StatusConflict, errorEnvelope("already checked in today"))
		return
	}
	before, err := h.chain.Account(c.Request.Context(), wallet)
	if err != nil {
		h.serverError(c, err)
		return
	}
	requestID := requestHash(
		"daily",
		wallet.Hex(),
		time.Now().UTC().Format("2006-01-02"),
	)
	txHash, err := h.chain.CheckIn(c.Request.Context(), wallet, requestID)
	if err != nil {
		h.serverError(c, err)
		return
	}
	account, err := h.chain.Account(c.Request.Context(), wallet)
	if err != nil {
		h.serverError(c, err)
		return
	}
	pointsEarned, err := checkedPoints(
		new(big.Int).Sub(account.TotalEarned, before.TotalEarned),
		"check-in award",
	)
	if err != nil || pointsEarned <= 0 {
		h.serverError(c, errors.New("invalid on-chain check-in award"))
		return
	}
	if err := h.store.SyncAccount(c.Request.Context(), wallet.Hex(), account); err != nil {
		h.serverError(c, err)
		return
	}
	if err := h.store.RecordHistory(c.Request.Context(), wallet.Hex(), "earn", pointsEarned, "Daily check-in", txHash.Hex(), common.Bytes2Hex(requestID[:])); err != nil {
		h.serverError(c, err)
		return
	}
	c.JSON(http.StatusOK, envelope(gin.H{"points_earned": pointsEarned, "tx_hash": txHash.Hex()}))
}

func (h *handler) awardTask(c *gin.Context) {
	var body struct {
		Wallet    string `json:"wallet" binding:"required"`
		TaskID    string `json:"task_id" binding:"required"`
		Points    uint64 `json:"points" binding:"required"`
		RequestID string `json:"request_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || !common.IsHexAddress(body.Wallet) || body.Points == 0 || body.Points > uint64(maxPointsInt64) {
		c.JSON(http.StatusBadRequest, errorEnvelope("invalid request"))
		return
	}
	wallet := common.HexToAddress(body.Wallet)
	taskID := sha256.Sum256([]byte(body.TaskID))
	requestID := sha256.Sum256([]byte(body.RequestID))
	txHash, err := h.chain.AwardTask(c.Request.Context(), wallet, taskID, body.Points, requestID)
	if err != nil {
		h.serverError(c, err)
		return
	}
	account, err := h.chain.Account(c.Request.Context(), wallet)
	if err != nil {
		h.serverError(c, err)
		return
	}
	if err := h.store.SyncAccount(c.Request.Context(), wallet.Hex(), account); err != nil {
		h.serverError(c, err)
		return
	}
	if err := h.store.RecordHistory(c.Request.Context(), wallet.Hex(), "earn", int64(body.Points), "Task: "+body.TaskID, txHash.Hex(), body.RequestID); err != nil {
		h.serverError(c, err)
		return
	}
	c.JSON(http.StatusOK, envelope(gin.H{"tx_hash": txHash.Hex()}))
}

func (h *handler) registerReferral(c *gin.Context) {
	var body struct {
		Referrer       string `json:"referrer" binding:"required"`
		Referred       string `json:"referred" binding:"required"`
		ReferrerPoints uint64 `json:"referrer_points"`
		ReferredPoints uint64 `json:"referred_points"`
		RequestID      string `json:"request_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&body); err != nil || !common.IsHexAddress(body.Referrer) || !common.IsHexAddress(body.Referred) || common.HexToAddress(body.Referrer) == (common.Address{}) || common.HexToAddress(body.Referred) == (common.Address{}) || strings.EqualFold(body.Referrer, body.Referred) || (body.ReferrerPoints == 0 && body.ReferredPoints == 0) || body.ReferrerPoints > uint64(maxPointsInt64) || body.ReferredPoints > uint64(maxPointsInt64) {
		c.JSON(http.StatusBadRequest, errorEnvelope("invalid request"))
		return
	}
	referrer := common.HexToAddress(body.Referrer)
	referred := common.HexToAddress(body.Referred)
	requestID := sha256.Sum256([]byte(body.RequestID))
	txHash, err := h.chain.RegisterReferral(c.Request.Context(), referrer, referred, body.ReferrerPoints, body.ReferredPoints, requestID)
	if err != nil {
		h.serverError(c, err)
		return
	}
	referrerAccount, err := h.chain.Account(c.Request.Context(), referrer)
	if err != nil {
		h.serverError(c, err)
		return
	}
	referredAccount, err := h.chain.Account(c.Request.Context(), referred)
	if err != nil {
		h.serverError(c, err)
		return
	}
	if err := h.store.SyncAccount(c.Request.Context(), referrer.Hex(), referrerAccount); err != nil {
		h.serverError(c, err)
		return
	}
	if err := h.store.SyncAccount(c.Request.Context(), referred.Hex(), referredAccount); err != nil {
		h.serverError(c, err)
		return
	}
	if err := h.store.RecordReferral(c.Request.Context(), referrer.Hex(), referred.Hex(), int64(body.ReferrerPoints), txHash.Hex()); err != nil {
		h.serverError(c, err)
		return
	}
	if body.ReferrerPoints > 0 {
		if err := h.store.RecordHistory(c.Request.Context(), referrer.Hex(), "earn", int64(body.ReferrerPoints), "Referral reward", txHash.Hex(), body.RequestID+":referrer"); err != nil {
			h.serverError(c, err)
			return
		}
	}
	if body.ReferredPoints > 0 {
		if err := h.store.RecordHistory(c.Request.Context(), referred.Hex(), "earn", int64(body.ReferredPoints), "Referral welcome reward", txHash.Hex(), body.RequestID+":referred"); err != nil {
			h.serverError(c, err)
			return
		}
	}
	c.JSON(http.StatusOK, envelope(gin.H{"tx_hash": txHash.Hex()}))
}

func (h *handler) authorizeWallet(c *gin.Context, rawWallet string) (common.Address, bool) {
	if !common.IsHexAddress(rawWallet) {
		c.JSON(http.StatusBadRequest, errorEnvelope("invalid wallet"))
		return common.Address{}, false
	}
	identity, err := h.auth.Verify(c.Request.Context(), c.GetHeader("UUID"), c.GetHeader("Token"))
	if err != nil || !common.IsHexAddress(identity.Wallet) || !strings.EqualFold(common.HexToAddress(identity.Wallet).Hex(), common.HexToAddress(rawWallet).Hex()) {
		c.JSON(http.StatusUnauthorized, errorEnvelope("unauthorized"))
		return common.Address{}, false
	}
	return common.HexToAddress(rawWallet), true
}

func (h *handler) requireInternalToken(c *gin.Context) {
	provided := []byte(c.GetHeader("X-Internal-Token"))
	expected := []byte(h.internalToken)
	if len(provided) != len(expected) || subtle.ConstantTimeCompare(provided, expected) != 1 {
		c.AbortWithStatusJSON(http.StatusUnauthorized, errorEnvelope("unauthorized"))
		return
	}
	c.Next()
}

func (h *handler) serverError(c *gin.Context, err error) {
	log.Printf("request failed: %v", err)
	status := http.StatusBadGateway
	message := "service unavailable"
	if errors.Is(err, errUnauthorized) {
		status = http.StatusUnauthorized
		message = "unauthorized"
	}
	c.JSON(status, errorEnvelope(message))
}

func envelope(data interface{}) gin.H    { return gin.H{"code": 200, "data": data} }
func errorEnvelope(message string) gin.H { return gin.H{"code": 1, "message": message} }

func requestHash(parts ...string) [32]byte { return sha256.Sum256([]byte(strings.Join(parts, ":"))) }

const maxPointsInt64 = int64(^uint64(0) >> 1)

func checkedPoints(value *big.Int, field string) (int64, error) {
	if value == nil || value.Sign() < 0 || !value.IsInt64() {
		return 0, errors.New("invalid on-chain " + field)
	}
	return value.Int64(), nil
}

func tierFor(points int64) string {
	return switchInt(points, "bronze", "silver", "gold", "platinum", "diamond")
}

func tierProgress(points int64) int64 {
	bounds := []int64{0, 1000, 2500, 5000, 10000}
	for i := len(bounds) - 1; i >= 0; i-- {
		if points >= bounds[i] {
			if i == len(bounds)-1 {
				return 100
			}
			return (points - bounds[i]) * 100 / (bounds[i+1] - bounds[i])
		}
	}
	return 0
}

func nextTierPoints(points int64) int64 {
	for _, bound := range []int64{1000, 2500, 5000, 10000} {
		if points < bound {
			return bound - points
		}
	}
	return 0
}

func switchInt(points int64, values ...string) string {
	thresholds := []int64{0, 1000, 2500, 5000, 10000}
	for i := len(thresholds) - 1; i >= 0; i-- {
		if points >= thresholds[i] {
			return values[i]
		}
	}
	return values[0]
}

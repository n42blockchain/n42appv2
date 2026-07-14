package main

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	_ "github.com/lib/pq"
)

type taskRecord struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Points      int64  `json:"points"`
	Status      string `json:"status"`
}

type rewardRecord struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	PointsCost  int64  `json:"points_cost"`
	Available   bool   `json:"is_available"`
}

type historyRecord struct {
	ID          string    `json:"id"`
	Action      string    `json:"action"`
	Points      int64     `json:"points"`
	Description string    `json:"description"`
	TxHash      string    `json:"tx_hash,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}

type referralRecord struct {
	Address      string    `json:"referred_address"`
	PointsEarned int64     `json:"points_earned"`
	CreatedAt    time.Time `json:"created_at"`
}

type leaderboardRecord struct {
	Rank    int64  `json:"rank"`
	Address string `json:"wallet_address"`
	Points  int64  `json:"points"`
}

type store interface {
	SyncAccount(ctx context.Context, wallet string, account chainAccount) error
	Tasks(ctx context.Context, checkedIn bool) ([]taskRecord, error)
	Rewards(ctx context.Context) ([]rewardRecord, error)
	History(ctx context.Context, wallet string) ([]historyRecord, error)
	Referrals(ctx context.Context, wallet string) ([]referralRecord, error)
	Leaderboard(ctx context.Context) ([]leaderboardRecord, error)
	RecordHistory(ctx context.Context, wallet, action string, points int64, description, txHash, requestID string) error
	RecordReferral(ctx context.Context, referrer, referred string, points int64, txHash string) error
}

type postgresStore struct{ db *sql.DB }

func newPostgresStore(dsn string) (*postgresStore, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(15)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(30 * time.Minute)
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		db.Close()
		return nil, err
	}
	s := &postgresStore{db: db}
	if err := s.migrate(ctx); err != nil {
		db.Close()
		return nil, err
	}
	return s, nil
}

func (s *postgresStore) Close() error { return s.db.Close() }

func (s *postgresStore) migrate(ctx context.Context) error {
	const schema = `
CREATE TABLE IF NOT EXISTS loyalty_accounts (
  wallet TEXT PRIMARY KEY,
  available BIGINT NOT NULL,
  total_earned BIGINT NOT NULL,
  total_spent BIGINT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS loyalty_tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  points BIGINT NOT NULL CHECK (points > 0),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS loyalty_rewards (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  points_cost BIGINT NOT NULL CHECK (points_cost > 0),
  active BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE IF NOT EXISTS loyalty_history (
  id TEXT PRIMARY KEY,
  wallet TEXT NOT NULL,
  action TEXT NOT NULL,
  points BIGINT NOT NULL,
  description TEXT NOT NULL,
  tx_hash TEXT NOT NULL,
  request_id TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS loyalty_history_wallet_time
  ON loyalty_history(wallet, created_at DESC);
ALTER TABLE loyalty_history DROP CONSTRAINT IF EXISTS loyalty_history_tx_hash_key;
CREATE INDEX IF NOT EXISTS loyalty_history_tx_hash
  ON loyalty_history(tx_hash);
CREATE TABLE IF NOT EXISTS loyalty_referrals (
  referred TEXT PRIMARY KEY,
  referrer TEXT NOT NULL,
  points_earned BIGINT NOT NULL,
  tx_hash TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO loyalty_tasks(id, title, description, points, sort_order)
VALUES ('daily-checkin', 'Daily Check-in', 'Check in once per UTC day', 10, 0)
ON CONFLICT (id) DO NOTHING;`
	_, err := s.db.ExecContext(ctx, schema)
	return err
}

func (s *postgresStore) SyncAccount(ctx context.Context, wallet string, account chainAccount) error {
	available, err := checkedPoints(account.Available, "available")
	if err != nil {
		return err
	}
	totalEarned, err := checkedPoints(account.TotalEarned, "total earned")
	if err != nil {
		return err
	}
	totalSpent, err := checkedPoints(account.TotalSpent, "total spent")
	if err != nil {
		return err
	}
	_, err = s.db.ExecContext(ctx, `
INSERT INTO loyalty_accounts(wallet, available, total_earned, total_spent, updated_at)
VALUES ($1, $2, $3, $4, NOW())
ON CONFLICT (wallet) DO UPDATE SET
  available = EXCLUDED.available,
  total_earned = EXCLUDED.total_earned,
  total_spent = EXCLUDED.total_spent,
	updated_at = NOW()`, wallet, available, totalEarned, totalSpent)
	return err
}

func (s *postgresStore) Tasks(ctx context.Context, checkedIn bool) ([]taskRecord, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id, title, description, points FROM loyalty_tasks WHERE active ORDER BY sort_order, id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []taskRecord
	for rows.Next() {
		var item taskRecord
		if err := rows.Scan(&item.ID, &item.Title, &item.Description, &item.Points); err != nil {
			return nil, err
		}
		item.Status = "available"
		if item.ID == "daily-checkin" && checkedIn {
			item.Status = "completed"
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func (s *postgresStore) Rewards(ctx context.Context) ([]rewardRecord, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id, name, description, points_cost, active FROM loyalty_rewards WHERE active ORDER BY points_cost, id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []rewardRecord
	for rows.Next() {
		var item rewardRecord
		if err := rows.Scan(&item.ID, &item.Name, &item.Description, &item.PointsCost, &item.Available); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func (s *postgresStore) History(ctx context.Context, wallet string) ([]historyRecord, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT id, action, points, description, tx_hash, created_at FROM loyalty_history WHERE wallet=$1 ORDER BY created_at DESC LIMIT 100`, wallet)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []historyRecord
	for rows.Next() {
		var item historyRecord
		if err := rows.Scan(&item.ID, &item.Action, &item.Points, &item.Description, &item.TxHash, &item.CreatedAt); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func (s *postgresStore) Referrals(ctx context.Context, wallet string) ([]referralRecord, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT referred, points_earned, created_at FROM loyalty_referrals WHERE referrer=$1 ORDER BY created_at DESC`, wallet)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []referralRecord
	for rows.Next() {
		var item referralRecord
		if err := rows.Scan(&item.Address, &item.PointsEarned, &item.CreatedAt); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func (s *postgresStore) Leaderboard(ctx context.Context) ([]leaderboardRecord, error) {
	rows, err := s.db.QueryContext(ctx, `SELECT ROW_NUMBER() OVER (ORDER BY available DESC, wallet), wallet, available FROM loyalty_accounts ORDER BY available DESC, wallet LIMIT 100`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []leaderboardRecord
	for rows.Next() {
		var item leaderboardRecord
		if err := rows.Scan(&item.Rank, &item.Address, &item.Points); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func (s *postgresStore) RecordHistory(ctx context.Context, wallet, action string, points int64, description, txHash, requestID string) error {
	_, err := s.db.ExecContext(ctx, `INSERT INTO loyalty_history(id, wallet, action, points, description, tx_hash, request_id) VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT DO NOTHING`, requestID, wallet, action, points, description, txHash, requestID)
	return err
}

func (s *postgresStore) RecordReferral(ctx context.Context, referrer, referred string, points int64, txHash string) error {
	result, err := s.db.ExecContext(ctx, `INSERT INTO loyalty_referrals(referred, referrer, points_earned, tx_hash) VALUES ($1,$2,$3,$4) ON CONFLICT (referred) DO NOTHING`, referred, referrer, points, txHash)
	if err != nil {
		return err
	}
	if rows, _ := result.RowsAffected(); rows == 0 {
		return fmt.Errorf("referral already registered")
	}
	return nil
}

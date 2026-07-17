package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
)

var errUnauthorized = errors.New("unauthorized")

type identity struct {
	UUID   string
	Wallet string
}

type authVerifier interface {
	Verify(ctx context.Context, uuid, token string) (identity, error)
}

type remoteAuthVerifier struct {
	url    string
	client *http.Client
}

func newRemoteAuthVerifier(url string) *remoteAuthVerifier {
	return &remoteAuthVerifier{
		url:    url,
		client: &http.Client{Timeout: 10 * time.Second},
	}
}

func (v *remoteAuthVerifier) Verify(ctx context.Context, uuid, token string) (identity, error) {
	if strings.TrimSpace(uuid) == "" || strings.TrimSpace(token) == "" {
		return identity{}, errUnauthorized
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, v.url, nil)
	if err != nil {
		return identity{}, err
	}
	req.Header.Set("UUID", uuid)
	req.Header.Set("Token", token)
	resp, err := v.client.Do(req)
	if err != nil {
		return identity{}, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return identity{}, errUnauthorized
	}
	var envelope struct {
		Code int `json:"code"`
		Data struct {
			UUID          string `json:"uuid"`
			WalletAddress string `json:"wallet_address"`
			WalletAddr    string `json:"wallet_addr"`
		} `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&envelope); err != nil {
		return identity{}, fmt.Errorf("decode auth response: %w", err)
	}
	if envelope.Code != 0 && envelope.Code != http.StatusOK {
		return identity{}, errUnauthorized
	}
	wallet := envelope.Data.WalletAddress
	if wallet == "" {
		wallet = envelope.Data.WalletAddr
	}
	if wallet == "" || (envelope.Data.UUID != "" && envelope.Data.UUID != uuid) {
		return identity{}, errUnauthorized
	}
	return identity{UUID: uuid, Wallet: wallet}, nil
}

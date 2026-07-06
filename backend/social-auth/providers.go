package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"sort"
	"strconv"
	"strings"
	"time"
)

// ProviderIdentity 是各 provider 校验后归一化的第三方身份。
// UID 必须是该 provider 内稳定唯一的用户标识(用于派生 Matrix 用户名)。
type ProviderIdentity struct {
	Provider string
	UID      string
	Email    string
	Username string
}

var httpClient = &http.Client{Timeout: 15 * time.Second}

// verifyProvider 按 provider 校验请求携带的凭据,返回归一化身份。
// discord/github:优先 code→client_secret 换 token,否则用直传 access_token。
// telegram:HMAC-SHA256 校验 Login Widget 的 hash。
func verifyProvider(cfg *Config, req *LoginSocialRequest) (*ProviderIdentity, error) {
	switch strings.ToLower(req.Provider) {
	case "discord":
		return verifyDiscord(cfg, req)
	case "github":
		return verifyGitHub(cfg, req)
	case "telegram":
		return verifyTelegram(cfg, req)
	default:
		return nil, fmt.Errorf("unsupported provider %q", req.Provider)
	}
}

// ── Discord ──────────────────────────────────────────────────────────────────

func verifyDiscord(cfg *Config, req *LoginSocialRequest) (*ProviderIdentity, error) {
	accessToken := req.AccessToken
	if accessToken == "" && req.Code != "" {
		tok, err := exchangeOAuthCode(
			"https://discord.com/api/oauth2/token",
			cfg.DiscordClientID, cfg.DiscordClientSecret,
			req.Code, req.RedirectURI,
		)
		if err != nil {
			return nil, fmt.Errorf("discord token exchange: %w", err)
		}
		accessToken = tok
	}
	if accessToken == "" {
		return nil, fmt.Errorf("discord: missing code/access_token")
	}
	var body struct {
		ID       string `json:"id"`
		Username string `json:"username"`
		Email    string `json:"email"`
	}
	if err := getJSON("https://discord.com/api/users/@me", accessToken, &body); err != nil {
		return nil, fmt.Errorf("discord userinfo: %w", err)
	}
	if body.ID == "" {
		return nil, fmt.Errorf("discord: empty user id")
	}
	return &ProviderIdentity{
		Provider: "discord", UID: body.ID, Email: body.Email, Username: body.Username,
	}, nil
}

// ── GitHub ───────────────────────────────────────────────────────────────────

func verifyGitHub(cfg *Config, req *LoginSocialRequest) (*ProviderIdentity, error) {
	accessToken := req.AccessToken
	if accessToken == "" && req.Code != "" {
		tok, err := exchangeOAuthCode(
			"https://github.com/login/oauth/access_token",
			cfg.GithubClientID, cfg.GithubClientSecret,
			req.Code, req.RedirectURI,
		)
		if err != nil {
			return nil, fmt.Errorf("github token exchange: %w", err)
		}
		accessToken = tok
	}
	if accessToken == "" {
		return nil, fmt.Errorf("github: missing code/access_token")
	}
	var user struct {
		ID    int64  `json:"id"`
		Login string `json:"login"`
		Email string `json:"email"`
	}
	if err := getJSON("https://api.github.com/user", accessToken, &user); err != nil {
		return nil, fmt.Errorf("github userinfo: %w", err)
	}
	if user.ID == 0 {
		return nil, fmt.Errorf("github: empty user id")
	}
	email := user.Email
	if email == "" {
		email = fetchGitHubPrimaryEmail(accessToken)
	}
	return &ProviderIdentity{
		Provider: "github", UID: strconv.FormatInt(user.ID, 10),
		Email: email, Username: user.Login,
	}, nil
}

func fetchGitHubPrimaryEmail(token string) string {
	var emails []struct {
		Email    string `json:"email"`
		Primary  bool   `json:"primary"`
		Verified bool   `json:"verified"`
	}
	if err := getJSON("https://api.github.com/user/emails", token, &emails); err != nil {
		return ""
	}
	for _, e := range emails {
		if e.Primary && e.Verified {
			return e.Email
		}
	}
	return ""
}

// ── Telegram ─────────────────────────────────────────────────────────────────

// verifyTelegram 按 https://core.telegram.org/widgets/login#checking-authorization
// 校验:secret_key = SHA256(bot_token);比对 HMAC_SHA256(data_check_string, secret_key)
// == hash;并验 auth_date 未过期。
func verifyTelegram(cfg *Config, req *LoginSocialRequest) (*ProviderIdentity, error) {
	if cfg.TelegramBotToken == "" {
		return nil, fmt.Errorf("telegram: bot token not configured")
	}
	if req.TelegramID == "" || req.TelegramHash == "" || req.TelegramAuthDate == "" {
		return nil, fmt.Errorf("telegram: missing id/hash/auth_date")
	}

	fields := map[string]string{
		"id":         req.TelegramID,
		"auth_date":  req.TelegramAuthDate,
		"first_name": req.TelegramFirst,
		"last_name":  req.TelegramLast,
		"username":   req.TelegramUsername,
		"photo_url":  req.TelegramPhoto,
	}
	keys := make([]string, 0, len(fields))
	for k, v := range fields {
		if v != "" {
			keys = append(keys, k)
		}
	}
	sort.Strings(keys)
	parts := make([]string, 0, len(keys))
	for _, k := range keys {
		parts = append(parts, k+"="+fields[k])
	}
	dataCheck := strings.Join(parts, "\n")

	secret := sha256.Sum256([]byte(cfg.TelegramBotToken))
	mac := hmac.New(sha256.New, secret[:])
	mac.Write([]byte(dataCheck))
	expected := hex.EncodeToString(mac.Sum(nil))
	if !hmac.Equal([]byte(expected), []byte(strings.ToLower(req.TelegramHash))) {
		return nil, fmt.Errorf("telegram: hash mismatch")
	}

	// auth_date 时效(默认 24h)。
	authTs, err := strconv.ParseInt(req.TelegramAuthDate, 10, 64)
	if err != nil {
		return nil, fmt.Errorf("telegram: bad auth_date")
	}
	if time.Now().Unix()-authTs > int64(cfg.TelegramAuthTTL.Seconds()) {
		return nil, fmt.Errorf("telegram: auth_date expired")
	}

	username := req.TelegramUsername
	if username == "" {
		username = req.TelegramFirst
	}
	return &ProviderIdentity{
		Provider: "telegram", UID: req.TelegramID, Username: username,
	}, nil
}

// ── OAuth2 code 换 access_token(Discord/GitHub 通用) ─────────────────────────

func exchangeOAuthCode(tokenURL, clientID, clientSecret, code, redirectURI string) (string, error) {
	if clientID == "" || clientSecret == "" {
		return "", fmt.Errorf("client id/secret not configured")
	}
	form := url.Values{}
	form.Set("client_id", clientID)
	form.Set("client_secret", clientSecret)
	form.Set("grant_type", "authorization_code")
	form.Set("code", code)
	form.Set("redirect_uri", redirectURI)

	httpReq, err := http.NewRequest(http.MethodPost, tokenURL, strings.NewReader(form.Encode()))
	if err != nil {
		return "", err
	}
	httpReq.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	httpReq.Header.Set("Accept", "application/json")

	resp, err := httpClient.Do(httpReq)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("token endpoint status %d: %s", resp.StatusCode, string(raw))
	}
	var out struct {
		AccessToken string `json:"access_token"`
		Error       string `json:"error"`
	}
	if err := json.Unmarshal(raw, &out); err != nil {
		return "", err
	}
	if out.AccessToken == "" {
		return "", fmt.Errorf("no access_token (%s)", out.Error)
	}
	return out.AccessToken, nil
}

func getJSON(endpoint, bearer string, out any) error {
	httpReq, err := http.NewRequest(http.MethodGet, endpoint, nil)
	if err != nil {
		return err
	}
	httpReq.Header.Set("Authorization", "Bearer "+bearer)
	httpReq.Header.Set("Accept", "application/json")
	httpReq.Header.Set("User-Agent", "n42-social-auth")

	resp, err := httpClient.Do(httpReq)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("status %d: %s", resp.StatusCode, string(raw))
	}
	return json.Unmarshal(raw, out)
}

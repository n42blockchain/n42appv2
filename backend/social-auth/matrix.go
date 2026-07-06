package main

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha1"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// issueMatrixAccount 把第三方身份映射为一个稳定的 Matrix 账号并返回登录态。
// 无状态设计:localpart 与 password 都由 identity 确定性派生,后端不存库——
//   - localpart = s_<provider>_<sha256(provider:uid)[:24]>
//   - password  = HMAC-SHA256(MATRIX_PASSWORD_SECRET, provider:uid)
// 首次用 Synapse shared-secret registration 创建(注册即返回登录态);
// 已存在则回退到密码登录。
func issueMatrixAccount(cfg *Config, id *ProviderIdentity) (*MatrixCredomain, error) {
	localpart := deriveLocalpart(id)
	password := derivePassword(cfg, id)

	creds, err := matrixRegisterSharedSecret(cfg, localpart, password)
	if err == nil {
		return withIdentity(creds, id), nil
	}
	// 用户已存在 → 密码登录。其余错误直接上抛。
	if !isUserInUse(err) {
		return nil, err
	}
	creds, lerr := matrixPasswordLogin(cfg, localpart, password)
	if lerr != nil {
		return nil, fmt.Errorf("register said in-use but login failed: %w", lerr)
	}
	return withIdentity(creds, id), nil
}

func withIdentity(c *MatrixCredomain, id *ProviderIdentity) *MatrixCredomain {
	c.Provider = id.Provider
	c.Email = id.Email
	c.Username = id.Username
	return c
}

// deriveLocalpart 生成合法 Matrix localpart([a-z0-9._=/-])。
func deriveLocalpart(id *ProviderIdentity) string {
	h := sha256.Sum256([]byte(id.Provider + ":" + id.UID))
	return "s_" + id.Provider + "_" + hex.EncodeToString(h[:])[:24]
}

func derivePassword(cfg *Config, id *ProviderIdentity) string {
	mac := hmac.New(sha256.New, []byte(cfg.MatrixPasswordSecret))
	mac.Write([]byte(id.Provider + ":" + id.UID))
	return hex.EncodeToString(mac.Sum(nil))
}

// ── Synapse shared-secret registration ───────────────────────────────────────
// https://matrix-org.github.io/synapse/latest/admin_api/register_api.html

type synapseRegisterResp struct {
	UserID      string `json:"user_id"`
	AccessToken string `json:"access_token"`
	DeviceID    string `json:"device_id"`
	HomeServer  string `json:"home_server"`
}

type errInUse struct{ msg string }

func (e errInUse) Error() string { return e.msg }
func isUserInUse(err error) bool { _, ok := err.(errInUse); return ok }

func matrixRegisterSharedSecret(cfg *Config, username, password string) (*MatrixCredomain, error) {
	endpoint := cfg.MatrixHomeserver + "/_synapse/admin/v1/register"

	// 1) 取 nonce
	var nonceResp struct {
		Nonce string `json:"nonce"`
	}
	if err := doJSON(http.MethodGet, endpoint, nil, &nonceResp); err != nil {
		return nil, fmt.Errorf("get nonce: %w", err)
	}
	if nonceResp.Nonce == "" {
		return nil, fmt.Errorf("empty nonce from homeserver")
	}

	// 2) mac = HMAC-SHA1(shared_secret, nonce\0user\0password\0notadmin)
	mac := hmac.New(sha1.New, []byte(cfg.MatrixSharedSecret))
	mac.Write([]byte(nonceResp.Nonce + "\x00" + username + "\x00" + password + "\x00" + "notadmin"))
	macHex := hex.EncodeToString(mac.Sum(nil))

	// 3) 注册
	body := map[string]any{
		"nonce":    nonceResp.Nonce,
		"username": username,
		"password": password,
		"admin":    false,
		"mac":      macHex,
	}
	raw, status, err := doRaw(http.MethodPost, endpoint, body)
	if err != nil {
		return nil, err
	}
	if status == http.StatusBadRequest && bytes.Contains(raw, []byte("M_USER_IN_USE")) {
		return nil, errInUse{msg: "M_USER_IN_USE"}
	}
	if status != http.StatusOK {
		return nil, fmt.Errorf("register status %d: %s", status, string(raw))
	}
	var out synapseRegisterResp
	if err := json.Unmarshal(raw, &out); err != nil {
		return nil, err
	}
	return &MatrixCredomain{
		MatrixUserID:      out.UserID,
		MatrixAccessToken: out.AccessToken,
		MatrixDeviceID:    out.DeviceID,
		MatrixHomeserver:  cfg.MatrixHomeserver,
	}, nil
}

// ── 密码登录(已存在账号) ─────────────────────────────────────────────────────

func matrixPasswordLogin(cfg *Config, username, password string) (*MatrixCredomain, error) {
	endpoint := cfg.MatrixHomeserver + "/_matrix/client/v3/login"
	body := map[string]any{
		"type": "m.login.password",
		"identifier": map[string]any{
			"type": "m.id.user",
			"user": username,
		},
		"password":                    password,
		"initial_device_display_name": "N42 Social",
	}
	var out struct {
		UserID      string `json:"user_id"`
		AccessToken string `json:"access_token"`
		DeviceID    string `json:"device_id"`
	}
	if err := doJSON(http.MethodPost, endpoint, body, &out); err != nil {
		return nil, err
	}
	if out.AccessToken == "" {
		return nil, fmt.Errorf("login returned empty access_token")
	}
	return &MatrixCredomain{
		MatrixUserID:      out.UserID,
		MatrixAccessToken: out.AccessToken,
		MatrixDeviceID:    out.DeviceID,
		MatrixHomeserver:  cfg.MatrixHomeserver,
	}, nil
}

// ── HTTP helpers ─────────────────────────────────────────────────────────────

func doRaw(method, endpoint string, body any) ([]byte, int, error) {
	var reader io.Reader
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			return nil, 0, err
		}
		reader = bytes.NewReader(b)
	}
	req, err := http.NewRequest(method, endpoint, reader)
	if err != nil {
		return nil, 0, err
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, 0, err
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	return raw, resp.StatusCode, nil
}

func doJSON(method, endpoint string, body, out any) error {
	raw, status, err := doRaw(method, endpoint, body)
	if err != nil {
		return err
	}
	if status != http.StatusOK {
		return fmt.Errorf("status %d: %s", status, string(raw))
	}
	return json.Unmarshal(raw, out)
}

package main

import (
	"encoding/json"
	"log"
	"net/http"
)

// loginSocialHandler 处理 POST /v1/user/loginSocial:
// 校验第三方凭据 → 派生并签发 Matrix 账号 → 返回登录态。
func loginSocialHandler(cfg *Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			writeJSON(w, http.StatusMethodNotAllowed, fail(405, "method not allowed"))
			return
		}
		var req LoginSocialRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			writeJSON(w, http.StatusBadRequest, fail(400, "invalid json: "+err.Error()))
			return
		}
		if req.Provider == "" {
			writeJSON(w, http.StatusBadRequest, fail(400, "missing provider"))
			return
		}

		identity, err := verifyProvider(cfg, &req)
		if err != nil {
			// 校验失败 = 凭据无效/未配置,返回 401(不泄漏内部细节到 msg 之外)。
			log.Printf("[social-auth] verify %s failed: %v", req.Provider, err)
			writeJSON(w, http.StatusUnauthorized, fail(401, "provider verification failed"))
			return
		}

		creds, err := issueMatrixAccount(cfg, identity)
		if err != nil {
			log.Printf("[social-auth] issue matrix account for %s:%s failed: %v",
				identity.Provider, identity.UID, err)
			writeJSON(w, http.StatusInternalServerError, fail(500, "failed to issue account"))
			return
		}
		log.Printf("[social-auth] login ok provider=%s uid=%s matrix=%s",
			identity.Provider, identity.UID, creds.MatrixUserID)
		writeJSON(w, http.StatusOK, ok(creds))
	}
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

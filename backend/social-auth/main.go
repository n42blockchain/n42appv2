// Command social-auth 是 N42 Chat 第三方登录后端(仓内自建)。
//
// 接收 App 侧第三方登录凭据(Discord/GitHub OAuth2、Telegram Login Widget),
// 校验后经 Matrix Synapse shared-secret registration 无状态签发 Matrix 账号,
// 返回 App 侧 SocialAuthApi 期望的 data.matrix_* 登录态。
//
// 现有五家(google/apple/facebook/twitter/wechat)由外部 api.n42.network 承载;
// 本服务补齐 discord/github/telegram 三家(见 README)。App 可经 baseUrl 分流:
// 新三家指向本服务,旧五家仍走外部,或整体切到本服务(需扩展现有五家校验)。
package main

import (
	"log"
	"net/http"
)

func main() {
	cfg := loadConfig()

	mux := http.NewServeMux()
	mux.HandleFunc("/v1/user/loginSocial", loginSocialHandler(cfg))
	mux.HandleFunc("/health", healthHandler)

	handler := corsMiddleware(cfg, mux)

	log.Printf("[social-auth] listening on :%s (homeserver=%s, providers: discord=%v github=%v telegram=%v)",
		cfg.Port, cfg.MatrixHomeserver,
		cfg.DiscordClientID != "", cfg.GithubClientID != "", cfg.TelegramBotToken != "")
	if err := http.ListenAndServe(":"+cfg.Port, handler); err != nil {
		log.Fatalf("[social-auth] server error: %v", err)
	}
}

func corsMiddleware(cfg *Config, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin != "" && cfg.CORSOrigins[origin] {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
			w.Header().Set("Access-Control-Max-Age", "86400")
		}
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

package main

// LoginSocialRequest 是 POST /v1/user/loginSocial 的请求体。
// 与 App 侧 packages/n42_chat/lib/src/data/datasources/remote/social_auth_api.dart
// 的 _loginWithSocialToken / _loginWithCustomPayload 字段对齐。
type LoginSocialRequest struct {
	Provider string `json:"provider"`
	// OAuth2 provider(discord/github)推荐传 code + redirect_uri,由后端用
	// client_secret 换 token(secret 不落客户端);兼容直接传 access_token。
	Code        string `json:"code,omitempty"`
	RedirectURI string `json:"redirect_uri,omitempty"`
	IDToken     string `json:"id_token,omitempty"`
	AccessToken string `json:"access_token,omitempty"`
	Source      string `json:"source,omitempty"`

	// Telegram Login Widget 回传字段(校验 hash 用)。
	TelegramID       string `json:"id,omitempty"`
	TelegramHash     string `json:"hash,omitempty"`
	TelegramAuthDate string `json:"auth_date,omitempty"`
	TelegramUsername string `json:"username,omitempty"`
	TelegramFirst    string `json:"first_name,omitempty"`
	TelegramLast     string `json:"last_name,omitempty"`
	TelegramPhoto    string `json:"photo_url,omitempty"`
}

// LoginSocialResponse 是统一返回信封,data 内为 Matrix 账号凭据(与 App 侧
// SocialLoginResponse.fromJson 读取的 data.matrix_* 字段对齐)。
type LoginSocialResponse struct {
	Code int              `json:"code"`
	Msg  string           `json:"msg"`
	Data *MatrixCredomain `json:"data,omitempty"`
}

// MatrixCredomain 是签发给客户端的 Matrix 登录态。
type MatrixCredomain struct {
	MatrixUserID      string `json:"matrix_user_id"`
	MatrixAccessToken string `json:"matrix_access_token"`
	MatrixDeviceID    string `json:"matrix_device_id"`
	MatrixHomeserver  string `json:"matrix_homeserver"`
	// 附带第三方身份(便于客户端展示,不含敏感 token)。
	Provider string `json:"provider"`
	Email    string `json:"email,omitempty"`
	Username string `json:"username,omitempty"`
}

func ok(data *MatrixCredomain) LoginSocialResponse {
	return LoginSocialResponse{Code: 200, Msg: "ok", Data: data}
}

func fail(code int, msg string) LoginSocialResponse {
	return LoginSocialResponse{Code: code, Msg: msg}
}

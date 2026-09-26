package evmsdk

import (
	"encoding/json"
	"strings"
	"testing"
)

type checkedEmitResponse struct {
	Code    int             `json:"code"`
	Message string          `json:"message"`
	Data    json.RawMessage `json:"data"`
}

func checkedEmit(t *testing.T, request string) checkedEmitResponse {
	t.Helper()
	raw := []byte(Emit(request))
	var fields map[string]json.RawMessage
	if err := json.Unmarshal(raw, &fields); err != nil {
		t.Fatalf("Emit returned invalid JSON: %v", err)
	}
	for _, field := range []string{"code", "message", "data"} {
		if _, ok := fields[field]; !ok {
			t.Fatalf("Emit response lacks %s: %s", field, raw)
		}
	}
	var response checkedEmitResponse
	if err := json.Unmarshal(raw, &response); err != nil {
		t.Fatalf("Emit returned wrong field type: %v", err)
	}
	return response
}

func TestAppEmitSettingStateStopAndPartialUpdate(t *testing.T) {
	oldEngine, oldDebug := EE, isDebug
	EE, isDebug = &EvmEngine{}, true
	defer func() { EE, isDebug = oldEngine, oldDebug }()
	key := strings.Repeat("01", 32)
	request, err := json.Marshal(map[string]interface{}{
		"type": "setting",
		"val": map[string]string{
			"app_base_path": t.TempDir(), "account": "N42-fixture",
			"priv_key": key, "server_uri": "ws://127.0.0.1:9", "log_level": "",
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	if got := checkedEmit(t, string(request)); got.Code != 0 || got.Message != "" || string(got.Data) != "null" {
		t.Fatalf("initial setting = %+v", got)
	}
	if got := checkedEmit(t, `{"type":"state"}`); got.Code != 0 || string(got.Data) != `"stopped"` {
		t.Fatalf("idle state = %+v", got)
	}
	if got := checkedEmit(t, `{"type":"stop"}`); got.Code != 0 || string(got.Data) != "null" {
		t.Fatalf("idle stop = %+v", got)
	}
	if got := checkedEmit(t, `{"type":"stop"}`); got.Code != 0 || string(got.Data) != "null" {
		t.Fatalf("repeat idle stop = %+v", got)
	}
	if got := checkedEmit(t, `{"type":"setting","val":{"server_uri":"ws://127.0.0.1:10"}}`); got.Code != 0 {
		t.Fatalf("partial setting = %+v", got)
	}
	if EE.PrivKey != key || EE.Account != "N42-fixture" || EE.ServerUri != "ws://127.0.0.1:10" {
		t.Fatal("partial setting lost existing account or private key")
	}
}

func TestAppEmitBlsAndMalformedRequests(t *testing.T) {
	oldEngine, oldDebug := EE, isDebug
	EE, isDebug = &EvmEngine{}, false
	defer func() { EE, isDebug = oldEngine, oldDebug }()
	for name, request := range map[string]string{
		"invalid JSON":          `{"type":`,
		"invalid setting value": `{"type":"setting","val":"bad"}`,
		"invalid key length":    `{"type":"blspubk","val":{"priv_key":"00"}}`,
		"invalid key hex":       `{"type":"blspubk","val":{"priv_key":"zz"}}`,
		"invalid message hex":   `{"type":"blssign","val":{"priv_key":"` + strings.Repeat("01", 32) + `","msg":"zz"}}`,
	} {
		t.Run(name, func(t *testing.T) {
			got := checkedEmit(t, request)
			if got.Code == 0 || got.Message == "" || string(got.Data) != "null" {
				t.Fatalf("invalid request = %+v", got)
			}
		})
	}
	for _, key := range []string{strings.Repeat("00", 31) + "01", strings.Repeat("ff", 32)} {
		for name, request := range map[string]string{
			"public key": `{"type":"blspubk","val":{"priv_key":"` + key + `"}}`,
			"signature":  `{"type":"blssign","val":{"priv_key":"` + key + `","msg":"8ac7230489e80000"}}`,
		} {
			t.Run(name+key[:2], func(t *testing.T) {
				got := checkedEmit(t, request)
				if got.Code != 0 || got.Message != "" {
					t.Fatalf("BLS request = %+v", got)
				}
				var data string
				if err := json.Unmarshal(got.Data, &data); err != nil {
					t.Fatalf("BLS data is not string: %v", err)
				}
				wantLength := 96
				if name == "signature" {
					wantLength = 192
				}
				if len(data) != wantLength {
					t.Fatalf("BLS data hex length = %d, want %d", len(data), wantLength)
				}
			})
		}
	}
}

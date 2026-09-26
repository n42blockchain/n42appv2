package evmsdk

import (
	"encoding/json"
	"testing"

	engine "github.com/n42blockchain/N42/cmd/evmsdk"
)

func TestEmitDelegatesToEngine(t *testing.T) {
	request := `{"type":"state"}`
	var got, want struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
		Data    string `json:"data"`
	}
	if err := json.Unmarshal([]byte(Emit(request)), &got); err != nil {
		t.Fatal(err)
	}
	if err := json.Unmarshal([]byte(engine.Emit(request)), &want); err != nil {
		t.Fatal(err)
	}
	if got != want || got.Data != "stopped" {
		t.Fatalf("mobile Emit = %+v, engine Emit = %+v", got, want)
	}
}

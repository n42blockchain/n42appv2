package services

import (
	"github.com/n42/n42appv2/backend/swap/models"
	"math/big"
	"testing"
)

func TestSwapCalldataPreservesQuotedPoolFee(t *testing.T) {
	adapter := NewUniswapAdapter(nil)
	for _, fee := range []int64{3000, 500} {
		data, err := adapter.buildSwapCalldata(models.QuoteReq{
			TokenIn:     "0x0000000000000000000000000000000000000001",
			TokenOut:    "0x0000000000000000000000000000000000000002",
			UserAddr:    "0x0000000000000000000000000000000000000003",
			AmountInWei: big.NewInt(1000), SlippageBps: 50,
		}, big.NewInt(2000), fee)
		if err != nil {
			t.Fatal(err)
		}
		if got := new(big.Int).SetBytes(data[68:100]).Int64(); got != fee {
			t.Fatalf("quoted fee %d but calldata contains %d", fee, got)
		}
		if got := new(big.Int).SetBytes(data[164:196]).Int64(); got != 1990 {
			t.Fatalf("minimum output %d", got)
		}
	}
}

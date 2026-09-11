package services

import (
	"context"
	"io"
	"math/big"
	"net/http"
	"strings"
	"testing"

	"github.com/n42/n42appv2/backend/swap/models"
)

type inchTransport func(*http.Request) (*http.Response, error)

func (f inchTransport) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }

func TestInchV6OutputAndTokenDecimals(t *testing.T) {
	adapter := NewInchAdapter("test-key")
	adapter.client = &http.Client{Transport: inchTransport(func(r *http.Request) (*http.Response, error) {
		if r.URL.Query().Get("includeTokensInfo") != "true" {
			t.Fatal("token metadata must be requested")
		}
		return &http.Response{StatusCode: 200, Body: io.NopCloser(strings.NewReader(`{
            "dstAmount":"1234567", "srcToken":{"symbol":"WETH"},
            "dstToken":{"symbol":"USDC","decimals":6}, "tx":{"data":"0x1234","to":"0xrouter","value":"0"}
        }`))}, nil
	})}
	result, err := adapter.Quote(context.Background(), models.QuoteReq{Chain: "ETH", AmountIn: "1000000000000000000", SlippageBps: 50})
	if err != nil {
		t.Fatal(err)
	}
	if result.AmountOut != "1.234567" || result.TokenOutSymbol != "USDC" || result.AmountOutWei.String() != "1234567" {
		t.Fatalf("wrong v6 quote: %+v", result)
	}
}

func TestInchRejectsMissingOutputDecimals(t *testing.T) {
	adapter := NewInchAdapter("test-key")
	adapter.client = &http.Client{Transport: inchTransport(func(r *http.Request) (*http.Response, error) {
		return &http.Response{StatusCode: 200, Body: io.NopCloser(strings.NewReader(`{"dstAmount":"1234567","tx":{"data":"0x1234","to":"0xrouter","value":"0"}}`))}, nil
	})}
	if _, err := adapter.Quote(context.Background(), models.QuoteReq{Chain: "ETH"}); err == nil {
		t.Fatal("must not assume 18 decimals")
	}
}

func TestWeiToHumanPreservesSmallestUnits(t *testing.T) {
	for _, tc := range []struct {
		raw      string
		decimals int
		want     string
	}{
		{"1", 18, "0.000000000000000001"},
		{"1234567", 6, "1.234567"},
		{"1000000000000000000", 18, "1"},
		{"9007199254740993", 0, "9007199254740993"},
	} {
		value, _ := new(big.Int).SetString(tc.raw, 10)
		if got := weiToHuman(value, tc.decimals); got != tc.want {
			t.Errorf("got %s want %s", got, tc.want)
		}
	}
}

func TestInchNativeValueAndRecipient(t *testing.T) {
	const native = "0x0000000000000000000000000000000000000000"
	for _, tc := range []struct {
		name, token, value string
		valid              bool
	}{
		{"native", native, "1000", true},
		{"native missing", native, "", false},
		{"native short", native, "999", false},
		{"native extra", native, "1001", false},
		{"erc20", "0xtoken", "0", true},
		{"erc20 extra", "0xtoken", "1000", false},
		{"negative", "0xtoken", "-1", false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			adapter := NewInchAdapter("fixture")
			adapter.client = &http.Client{Transport: inchTransport(func(r *http.Request) (*http.Response, error) {
				if r.URL.Query().Get("from") != "0xsmart" || r.URL.Query().Get("receiver") != "0xsmart" {
					t.Fatal("caller and receiver must match the selected account")
				}
				if tc.token == native && r.URL.Query().Get("src") != "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee" {
					t.Fatal("native alias was not normalized")
				}
				body := `{"dstAmount":"100","dstToken":{"symbol":"USDC","decimals":6},"tx":{"data":"0x1234","to":"0xrouter","value":"` + tc.value + `"}}`
				return &http.Response{StatusCode: 200, Body: io.NopCloser(strings.NewReader(body))}, nil
			})}
			result, err := adapter.Quote(context.Background(), models.QuoteReq{Chain: "ETH", TokenIn: tc.token, AmountIn: "1000", UserAddr: "0xsmart"})
			if tc.valid {
				if err != nil || result.TxValue != tc.value {
					t.Fatalf("result=%+v error=%v", result, err)
				}
			} else if err == nil {
				t.Fatal("invalid native value accepted")
			}
		})
	}
}

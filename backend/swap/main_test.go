package main

import (
	"os"
	"os/exec"
	"strings"
	"testing"
)

func TestGetEnvUsesFallbackAndOverride(t *testing.T) {
	t.Setenv("N42_SWAP_TEST_VALUE", "")
	if got := getEnv("N42_SWAP_TEST_VALUE", "fallback"); got != "fallback" {
		t.Fatalf("getEnv() = %q, want fallback", got)
	}
	t.Setenv("N42_SWAP_TEST_VALUE", "configured")
	if got := getEnv("N42_SWAP_TEST_VALUE", "fallback"); got != "configured" {
		t.Fatalf("getEnv() = %q, want configured", got)
	}
}

func TestMustEnvReturnsConfiguredValue(t *testing.T) {
	t.Setenv("N42_SWAP_TEST_REQUIRED", "synthetic-config")
	if got := mustEnv("N42_SWAP_TEST_REQUIRED"); got != "synthetic-config" {
		t.Fatalf("mustEnv() = %q, want configured value", got)
	}
}

func TestMustEnvMissingValueExitsProcess(t *testing.T) {
	if os.Getenv("N42_SWAP_TEST_FATAL_CHILD") == "1" {
		_ = mustEnv("N42_SWAP_TEST_REQUIRED_MISSING")
		return
	}
	cmd := exec.Command(os.Args[0], "-test.run=^TestMustEnvMissingValueExitsProcess$")
	cmd.Env = []string{"N42_SWAP_TEST_FATAL_CHILD=1"}
	output, err := cmd.CombinedOutput()
	exitErr, ok := err.(*exec.ExitError)
	if !ok || exitErr.ExitCode() != 1 {
		t.Fatalf("child error=%v output=%q, want exit status 1", err, output)
	}
	wantDiagnostic := `required env var "N42_SWAP_TEST_REQUIRED_MISSING" is not set`
	if !strings.Contains(string(output), wantDiagnostic) {
		t.Fatalf("child output=%q, want diagnostic %q", output, wantDiagnostic)
	}
}

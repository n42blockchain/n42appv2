// token-check verifies a join token offline. Credentials are never printed.
package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"strings"
	"time"

	"github.com/livekit/protocol/auth"
)

const maxCredentialBytes = 64 * 1024

type expectation struct {
	issuer, identity, room string
	publish                bool
}

func checkToken(raw, secret string, expected expectation, now time.Time) error {
	if raw == "" || secret == "" || len(raw) > maxCredentialBytes || expected.issuer == "" || expected.identity == "" || expected.room == "" {
		return errors.New("missing or invalid verification input")
	}
	verifier, err := auth.ParseAPIToken(raw)
	if err != nil {
		return errors.New("invalid signed token")
	}
	if verifier.APIKey() != expected.issuer || verifier.Identity() != expected.identity {
		return errors.New("token scope mismatch")
	}
	claims, grants, err := verifier.Verify(secret)
	if err != nil {
		return errors.New("token signature or validity check failed")
	}
	// The SDK allows clock skew; acceptance checks require a currently valid token.
	if claims.ExpiresAt == nil || !claims.ExpiresAt.Time.After(now) || (claims.NotBefore != nil && claims.NotBefore.Time.After(now)) {
		return errors.New("token is not currently valid")
	}
	video := grants.Video
	if video == nil || !video.RoomJoin || video.Room != expected.room || video.CanPublish == nil || *video.CanPublish != expected.publish || video.CanSubscribe == nil || !*video.CanSubscribe {
		return errors.New("media grant mismatch")
	}
	// A media policy check must not accept a viewer that can later promote itself.
	if video.RoomAdmin || video.RoomCreate || video.RoomList || video.RoomRecord || video.IngressAdmin || video.Agent || video.Recorder || video.Hidden || video.DestinationRoom != "" || (video.CanManageAgentSession != nil && *video.CanManageAgentSession) || (video.CanSubscribeMetrics != nil && *video.CanSubscribeMetrics) || grants.SIP != nil || grants.Agent != nil || grants.Inference != nil || grants.Observability != nil || grants.AgentEndpoint != nil || grants.AgentThread != nil || grants.RoomConfig != nil || grants.RoomPreset != "" {
		return errors.New("unexpected privileged grant")
	}
	return nil
}

func readCredential(in io.Reader) (string, error) {
	data, err := io.ReadAll(io.LimitReader(in, maxCredentialBytes+1))
	if err != nil || len(data) > maxCredentialBytes {
		return "", errors.New("cannot read bounded credential")
	}
	value := strings.TrimSpace(string(data))
	if value == "" {
		return "", errors.New("empty credential")
	}
	return value, nil
}

func run(args []string, in io.Reader, out, errOut io.Writer) int {
	flags := flag.NewFlagSet("token-check", flag.ContinueOnError)
	flags.SetOutput(io.Discard)
	secretPath := flags.String("secret-file", "", "controlled local file containing the LiveKit API secret")
	issuer := flags.String("issuer", "", "expected LiveKit API key identifier")
	identity := flags.String("identity", "", "expected exact participant identity")
	room := flags.String("room", "", "expected exact SFU room")
	publish := flags.Bool("publish", false, "expected explicit canPublish value (required)")
	if err := flags.Parse(args); err != nil {
		if errors.Is(err, flag.ErrHelp) {
			flags.SetOutput(errOut)
			flags.PrintDefaults()
			return 0
		}
		fmt.Fprintln(errOut, "invalid invocation")
		return 2
	}
	hasPublish := false
	flags.Visit(func(f *flag.Flag) {
		if f.Name == "publish" {
			hasPublish = true
		}
	})
	if flags.NArg() != 0 || *secretPath == "" || *issuer == "" || *identity == "" || *room == "" || !hasPublish {
		fmt.Fprintln(errOut, "secret-file, issuer, identity, room and explicit publish are required; token is read from stdin")
		return 2
	}
	file, err := os.Open(*secretPath)
	if err != nil {
		fmt.Fprintln(errOut, "cannot open secret file")
		return 2
	}
	secret, err := readCredential(file)
	file.Close()
	if err != nil {
		fmt.Fprintln(errOut, "cannot read secret file")
		return 2
	}
	token, err := readCredential(in)
	if err != nil {
		fmt.Fprintln(errOut, "cannot read token from stdin")
		return 2
	}
	if err := checkToken(token, secret, expectation{*issuer, *identity, *room, *publish}, time.Now()); err != nil {
		fmt.Fprintln(errOut, err.Error())
		return 1
	}
	if err := json.NewEncoder(out).Encode(map[string]any{"signatureVerified": true, "scopeMatches": true, "publish": *publish}); err != nil {
		fmt.Fprintln(errOut, "cannot write verification result")
		return 2
	}
	return 0
}

func main() { os.Exit(run(os.Args[1:], os.Stdin, os.Stdout, os.Stderr)) }

package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
)

var (
	errMatrixUnauthorized = errors.New("matrix authentication failed")
	errMatrixNotJoined    = errors.New("matrix user is not joined to the room")
	errMatrixNoCreator    = errors.New("matrix room has no resolvable creator")
	errMatrixUpstream     = errors.New("matrix upstream failed")
)

type matrixVerifier interface {
	WhoAmI(context.Context, string) (string, error)
	RequireJoined(context.Context, string, string, string) error
	RoomCreator(context.Context, string, string) (string, error)
	RoomIsLive(context.Context, string, string) (bool, error)
}

type matrixClient struct {
	homeserver string
	httpClient *http.Client
}

func (m *matrixClient) WhoAmI(ctx context.Context, accessToken string) (string, error) {
	endpoint := m.homeserver + "/_matrix/client/v3/account/whoami"
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return "", fmt.Errorf("%w: %v", errMatrixUpstream, err)
	}
	request.Header.Set("Authorization", "Bearer "+accessToken)

	response, err := m.httpClient.Do(request)
	if err != nil {
		return "", fmt.Errorf("%w: %v", errMatrixUpstream, err)
	}
	defer response.Body.Close()
	if response.StatusCode == http.StatusUnauthorized || response.StatusCode == http.StatusForbidden {
		return "", errMatrixUnauthorized
	}
	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("%w: whoami returned %d", errMatrixUpstream, response.StatusCode)
	}

	var body struct {
		UserID string `json:"user_id"`
	}
	if err := decodeResponseJSON(response.Body, &body); err != nil || strings.TrimSpace(body.UserID) == "" {
		return "", fmt.Errorf("%w: invalid whoami response", errMatrixUpstream)
	}
	return strings.TrimSpace(body.UserID), nil
}

func (m *matrixClient) RequireJoined(
	ctx context.Context,
	accessToken string,
	roomID string,
	userID string,
) error {
	endpoint := m.homeserver + "/_matrix/client/v3/rooms/" +
		url.PathEscape(roomID) + "/state/m.room.member/" + url.PathEscape(userID)
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return fmt.Errorf("%w: %v", errMatrixUpstream, err)
	}
	request.Header.Set("Authorization", "Bearer "+accessToken)

	response, err := m.httpClient.Do(request)
	if err != nil {
		return fmt.Errorf("%w: %v", errMatrixUpstream, err)
	}
	defer response.Body.Close()
	if response.StatusCode == http.StatusUnauthorized || response.StatusCode == http.StatusForbidden {
		return errMatrixUnauthorized
	}
	if response.StatusCode == http.StatusNotFound {
		return errMatrixNotJoined
	}
	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("%w: membership returned %d", errMatrixUpstream, response.StatusCode)
	}

	var body struct {
		Membership string `json:"membership"`
	}
	if err := decodeResponseJSON(response.Body, &body); err != nil {
		return fmt.Errorf("%w: invalid membership response", errMatrixUpstream)
	}
	if body.Membership != "join" {
		return errMatrixNotJoined
	}
	return nil
}

// RoomCreator returns the Matrix user who created the room.
//
// The creator is written by the homeserver itself into m.room.create and
// cannot be forged by a client, which makes it the authoritative signal for
// "who is the broadcaster of this live room". The Flutter client anchors the
// broadcaster's video track on the same field, so both sides agree without
// trusting any client-supplied role.
type createStateEvent struct {
	Type     string          `json:"type"`
	StateKey *string         `json:"state_key"`
	Sender   string          `json:"sender"`
	Content  json.RawMessage `json:"content"`
}

func (e createStateEvent) creator() string {
	if e.Type != "m.room.create" || e.StateKey == nil || *e.StateKey != "" || len(e.Content) == 0 {
		return ""
	}
	return strings.TrimSpace(e.Sender)
}

func (m *matrixClient) RoomCreator(ctx context.Context, accessToken, roomID string) (string, error) {
	// The single-state endpoint returns content by default. Older servers may
	// ignore format=event, and client content can imitate an event envelope.
	// Use the state-list endpoint, whose array entries are server envelopes.
	endpoint := m.homeserver + "/_matrix/client/v3/rooms/" + url.PathEscape(roomID) + "/state"
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return "", fmt.Errorf("%w: %v", errMatrixUpstream, err)
	}
	request.Header.Set("Authorization", "Bearer "+accessToken)
	response, err := m.httpClient.Do(request)
	if err != nil {
		return "", fmt.Errorf("%w: %v", errMatrixUpstream, err)
	}
	defer response.Body.Close()
	switch response.StatusCode {
	case http.StatusUnauthorized, http.StatusForbidden:
		return "", errMatrixUnauthorized
	case http.StatusNotFound:
		return "", errMatrixNoCreator
	case http.StatusOK:
	default:
		return "", fmt.Errorf("%w: room state returned %d", errMatrixUpstream, response.StatusCode)
	}
	// Bound upstream data and keep failure closed for malformed/oversized state.
	decoder := json.NewDecoder(io.LimitReader(response.Body, 16<<20))
	var events []createStateEvent
	if err = decoder.Decode(&events); err != nil {
		return "", fmt.Errorf("%w: invalid room state response", errMatrixUpstream)
	}
	for _, e := range events {
		if creator := e.creator(); creator != "" {
			return creator, nil
		}
	}
	return "", errMatrixNoCreator
}

// RoomIsLive reports whether the room is an N42 live room.
//
// Live rooms carry the n42.live.status state event that the broadcaster writes
// on air and flips to live:false when ending. Its presence - not its value -
// marks the room as a stream for the lifetime of that room.
//
// This is deliberately not keyed on the join rule. That is a user-facing
// setting a moderator can flip, and plenty of ordinary group chats are public
// too, so using it would both let a stream be un-restricted by changing a
// toggle and silently mute every non-creator in a public group call.
//
// A room whose marker cannot be read is reported as live, so the stricter
// creator-only rule applies. Failing that way can cost a group-call
// participant their microphone; failing the other way lets anyone hijack a
// stream.
func (m *matrixClient) RoomIsLive(
	ctx context.Context,
	accessToken string,
	roomID string,
) (bool, error) {
	endpoint := m.homeserver + "/_matrix/client/v3/rooms/" +
		url.PathEscape(roomID) + "/state/n42.live.status/"
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return true, fmt.Errorf("%w: %v", errMatrixUpstream, err)
	}
	request.Header.Set("Authorization", "Bearer "+accessToken)

	response, err := m.httpClient.Do(request)
	if err != nil {
		return true, fmt.Errorf("%w: %v", errMatrixUpstream, err)
	}
	defer response.Body.Close()
	if response.StatusCode == http.StatusUnauthorized || response.StatusCode == http.StatusForbidden {
		return true, errMatrixUnauthorized
	}
	// The only response that proves this is not a live room: the homeserver
	// says the state event does not exist.
	if response.StatusCode == http.StatusNotFound {
		return false, nil
	}
	if response.StatusCode != http.StatusOK {
		return true, fmt.Errorf("%w: live state returned %d", errMatrixUpstream, response.StatusCode)
	}
	return true, nil
}

func decodeRequestJSON(reader io.Reader, target any) error {
	decoder := json.NewDecoder(io.LimitReader(reader, 64<<10))
	decoder.DisallowUnknownFields()
	return decoder.Decode(target)
}

func decodeResponseJSON(reader io.Reader, target any) error {
	decoder := json.NewDecoder(io.LimitReader(reader, 64<<10))
	return decoder.Decode(target)
}

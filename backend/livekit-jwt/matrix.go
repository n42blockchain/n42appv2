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
	errMatrixUpstream     = errors.New("matrix upstream failed")
)

type matrixVerifier interface {
	WhoAmI(context.Context, string) (string, error)
	RequireJoined(context.Context, string, string, string) error
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

func decodeRequestJSON(reader io.Reader, target any) error {
	decoder := json.NewDecoder(io.LimitReader(reader, 64<<10))
	decoder.DisallowUnknownFields()
	return decoder.Decode(target)
}

func decodeResponseJSON(reader io.Reader, target any) error {
	decoder := json.NewDecoder(io.LimitReader(reader, 64<<10))
	return decoder.Decode(target)
}

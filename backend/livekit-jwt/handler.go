package main

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/livekit/protocol/auth"
)

var invalidRoomCharacter = regexp.MustCompile(`[^A-Za-z0-9_-]`)

type tokenRequest struct {
	Room           string `json:"room"`
	Identity       string `json:"identity"`
	Name           string `json:"name"`
	Video          bool   `json:"video"`
	ConversationID string `json:"conversation_id"`
	Metadata       string `json:"metadata,omitempty"`
	Role           string `json:"role,omitempty"`

	// canPublish is resolved server-side before issuing and is never parsed
	// from the request body.
	canPublish bool
}

type tokenIssuer interface {
	Issue(tokenRequest) (string, error)
}

// handlerBudget bounds the total time spent talking to the homeserver while
// issuing a single token. It must stay comfortably under the server's
// WriteTimeout so failures surface as a status code rather than a dropped
// connection.
const handlerBudget = 6 * time.Second

// roleBroadcaster is the only role allowed to publish media. Anything else
// (including an absent or unknown role) is treated as a viewer.
const roleBroadcaster = "broadcaster"

// canPublishFor decides the LiveKit publish grant.
//
// The decision is keyed on the room, never on the client-supplied role. Role
// is attacker-controlled in both directions: a viewer can claim
// role=broadcaster, and - more dangerously - can simply omit role entirely, so
// any rule of the form "no role means publish" is a bypass, not a default.
//
// A live room is identified by the n42.live.status marker the broadcaster
// writes; everything else is an ordinary room hosting a group call.
//
//   - live room  -> only the room creator publishes (the broadcaster)
//   - other room -> every joined member publishes (group call)
//
// Within a live room an explicit non-broadcaster role still downgrades the
// grant, so a broadcaster's own viewer-role request cannot publish either.
func canPublishFor(request tokenRequest, creator string, roomIsLive bool) bool {
	if !roomIsLive {
		return true
	}
	role := strings.TrimSpace(request.Role)
	if role != "" && !strings.EqualFold(role, roleBroadcaster) {
		return false
	}
	return creator != "" && request.Identity == creator
}

type liveKitIssuer struct {
	apiKey    string
	apiSecret string
	ttl       time.Duration
}

func (i liveKitIssuer) Issue(request tokenRequest) (string, error) {
	metadata, err := json.Marshal(map[string]any{
		"conversation_id": request.ConversationID,
		"video":           request.Video,
		"role":            request.Role,
	})
	if err != nil {
		return "", err
	}

	token := auth.NewAccessToken(i.apiKey, i.apiSecret).
		SetIdentity(request.Identity).
		SetName(request.Name).
		SetMetadata(string(metadata)).
		SetValidFor(i.ttl).
		SetVideoGrant(&auth.VideoGrant{
			RoomJoin: true,
			Room:     request.Room,
			// Resolved by the handler from Matrix room state, never from the
			// client-supplied role.
			CanPublish:   boolPointer(request.canPublish),
			CanSubscribe: boolPointer(true),
		})
	return token.ToJWT()
}

type tokenHandler struct {
	matrix matrixVerifier
	issuer tokenIssuer
}

func (h tokenHandler) ServeHTTP(response http.ResponseWriter, request *http.Request) {
	if request.URL.Path != "/livekit/jwt" {
		writeError(response, http.StatusNotFound, "not_found")
		return
	}
	if request.Method == http.MethodOptions {
		response.Header().Set("Allow", "GET, POST, OPTIONS")
		response.WriteHeader(http.StatusNoContent)
		return
	}
	if request.Method != http.MethodGet && request.Method != http.MethodPost {
		response.Header().Set("Allow", "GET, POST, OPTIONS")
		writeError(response, http.StatusMethodNotAllowed, "method_not_allowed")
		return
	}

	// Issuing one token costs up to four serial homeserver round trips
	// (whoami, membership, live marker, creator). With a per-call timeout only,
	// a slow homeserver keeps the handler alive past the server's write
	// deadline: the connection is cut and the client sees a transport error
	// rather than a status code, which its fallback logic cannot classify.
	// Bound the whole request instead.
	ctx, cancel := context.WithTimeout(request.Context(), handlerBudget)
	defer cancel()
	request = request.WithContext(ctx)

	accessToken := bearerToken(request.Header.Get("Authorization"))
	if accessToken == "" {
		writeError(response, http.StatusUnauthorized, "missing_matrix_token")
		return
	}

	payload, err := parseTokenRequest(request)
	if err != nil {
		writeError(response, http.StatusBadRequest, "invalid_request")
		return
	}
	if err := validateTokenRequest(payload); err != nil {
		writeError(response, http.StatusBadRequest, "invalid_request")
		return
	}

	userID, err := h.matrix.WhoAmI(request.Context(), accessToken)
	if err != nil {
		writeMatrixError(response, err)
		return
	}
	if payload.Identity != userID {
		writeError(response, http.StatusForbidden, "identity_mismatch")
		return
	}
	if err := h.matrix.RequireJoined(
		request.Context(),
		accessToken,
		payload.ConversationID,
		userID,
	); err != nil {
		writeMatrixError(response, err)
		return
	}

	if payload.Name == "" {
		payload.Name = userID
	}

	// Resolve publish rights from room state. This runs for every request,
	// including ones that carry no role at all - omitting the field must not
	// be a way around the check.
	roomIsLive, liveErr := h.matrix.RoomIsLive(
		request.Context(),
		accessToken,
		payload.ConversationID,
	)
	if liveErr != nil && !errors.Is(liveErr, errMatrixUpstream) {
		writeMatrixError(response, liveErr)
		return
	}
	// On an upstream read failure RoomIsLive reports true, which applies the
	// stricter creator-only rule rather than handing out a publish grant.

	var creator string
	if roomIsLive {
		var creatorErr error
		creator, creatorErr = h.matrix.RoomCreator(
			request.Context(),
			accessToken,
			payload.ConversationID,
		)
		if creatorErr != nil && !errors.Is(creatorErr, errMatrixNoCreator) {
			writeMatrixError(response, creatorErr)
			return
		}
		// An unresolvable creator must not silently grant publish rights.
	}
	payload.canPublish = canPublishFor(payload, creator, roomIsLive)
	// A denied publish is indistinguishable from a healthy grant on the wire
	// (both are 200 + a token), so record the decision. Without this a
	// broadcaster silently demoted to viewer - because the creator lookup
	// failed, say - looks identical to "streaming just doesn't work".
	if roomIsLive && !payload.canPublish {
		log.Printf(
			"livekit-jwt: publish denied room=%s identity=%s role=%q creator=%q",
			payload.ConversationID, payload.Identity, payload.Role, creator,
		)
	}

	token, err := h.issuer.Issue(payload)
	if err != nil {
		writeError(response, http.StatusInternalServerError, "token_issue_failed")
		return
	}
	writeJSON(response, http.StatusOK, map[string]string{"token": token})
}

func parseTokenRequest(request *http.Request) (tokenRequest, error) {
	if request.Method == http.MethodGet {
		video := request.URL.Query().Get("video")
		return tokenRequest{
			Room:           strings.TrimSpace(request.URL.Query().Get("room")),
			Identity:       strings.TrimSpace(request.URL.Query().Get("identity")),
			Name:           strings.TrimSpace(request.URL.Query().Get("name")),
			Video:          video == "1" || strings.EqualFold(video, "true"),
			ConversationID: strings.TrimSpace(request.URL.Query().Get("conversation_id")),
			Role:           strings.TrimSpace(request.URL.Query().Get("role")),
		}, nil
	}

	var payload tokenRequest
	if err := decodeRequestJSON(request.Body, &payload); err != nil {
		return tokenRequest{}, err
	}
	payload.Room = strings.TrimSpace(payload.Room)
	payload.Identity = strings.TrimSpace(payload.Identity)
	payload.Name = strings.TrimSpace(payload.Name)
	payload.ConversationID = strings.TrimSpace(payload.ConversationID)
	payload.Role = strings.TrimSpace(payload.Role)
	return payload, nil
}

func validateTokenRequest(request tokenRequest) error {
	if request.Room == "" || request.Identity == "" || request.ConversationID == "" {
		return errors.New("required fields are missing")
	}
	if len(request.Room) > 255 || len(request.Identity) > 255 ||
		len(request.Name) > 255 || len(request.ConversationID) > 255 ||
		len(request.Role) > 32 {
		return errors.New("field is too long")
	}
	if request.Room != buildLiveKitRoomName(request.ConversationID) {
		return errors.New("room does not match conversation")
	}
	return nil
}

func buildLiveKitRoomName(conversationID string) string {
	normalized := invalidRoomCharacter.ReplaceAllString(strings.TrimSpace(conversationID), "_")
	if normalized == "" {
		return "mx_group_call"
	}
	return "mx_" + normalized
}

func bearerToken(header string) string {
	parts := strings.Fields(header)
	if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
		return ""
	}
	return strings.TrimSpace(parts[1])
}

func writeMatrixError(response http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, errMatrixUnauthorized):
		writeError(response, http.StatusUnauthorized, "invalid_matrix_token")
	case errors.Is(err, errMatrixNotJoined):
		writeError(response, http.StatusForbidden, "not_joined")
	default:
		writeError(response, http.StatusBadGateway, "matrix_unavailable")
	}
}

func writeError(response http.ResponseWriter, status int, code string) {
	writeJSON(response, status, map[string]string{"error": code})
}

func writeJSON(response http.ResponseWriter, status int, body any) {
	response.Header().Set("Content-Type", "application/json")
	response.Header().Set("Cache-Control", "no-store")
	response.WriteHeader(status)
	_ = json.NewEncoder(response).Encode(body)
}

func boolPointer(value bool) *bool {
	return &value
}

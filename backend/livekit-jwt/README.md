# N42 LiveKit JWT Service

> Legacy compatibility service. Production `m.si46.world` currently uses the
> Element MatrixRTC Authorization Service (`/livekit/jwt/sfu/get`) instead.
> Do not apply this service's exact-path Nginx example to that deployment.

Issues short-lived LiveKit room tokens for authenticated Matrix room members.
The Flutter client discovers this service as
`https://m.si46.world/livekit/jwt`.

## Security contract

- `Authorization: Bearer <matrix access token>` is required.
- The requested LiveKit identity must equal Matrix `whoami.user_id`.
- The caller must currently have `membership: join` in `conversation_id`.
- The requested LiveKit room must match the Flutter room-name derivation.
- LiveKit API credentials are read only from environment variables.

## Configuration

| Variable | Required | Example |
|---|---:|---|
| `MATRIX_HOMESERVER` | yes | `https://m.si46.world` |
| `LIVEKIT_API_KEY` | yes | deployment secret |
| `LIVEKIT_API_SECRET` | yes | deployment secret |
| `PORT` | no | `8080` |
| `TOKEN_TTL` | no | `15m` |

Run tests with `go test ./...` and build with `docker build -t n42-livekit-jwt .`.

The Nginx route must proxy the exact path without adding a trailing slash:

```nginx
location = /livekit/jwt {
    proxy_pass http://127.0.0.1:8080/livekit/jwt;
    proxy_pass_request_headers on;
    proxy_set_header Authorization $http_authorization;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

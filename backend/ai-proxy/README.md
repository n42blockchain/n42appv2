# N42 AI trial gateway

Text summaries and image descriptions use `https://m.si46.world/n42/ai/v1/chat/completions`.
The mobile app sends its current Matrix access token. The gateway validates it
against the fixed homeserver and replaces it with the server-only OpenRouter key.
The app never receives the provider key. Account switching resolves the current
token for every request.

## Trial policy

- Only `openrouter/free`; caller-selected paid models are ignored.
- Provider data collection is denied; no fallback to training-permitted providers.
- 40 requests per user/day, 50 total/day, 15 total/minute, four upstream requests
  in flight. UTC windows. SQLite reservations survive restart and failed upstream
  attempts count toward the quota. Local synthetic tests also consume quota.
- At most 128,000 text characters and 2,048 output tokens. One inline JPEG, PNG,
  or WebP up to 2 MiB per request; remote image URLs are rejected. The app resizes
  images to 1,280 pixels and compresses to JPEG before upload. No image generation.
- Image translation batches recognized text into one request after user consent,
  rather than spending one request per OCR block. Upstream free limits still apply.
- Streaming UI receives a single completed text chunk in proxy mode.
- No prompt/token logging. SQLite stores user ID and time bucket only and removes
  previous days on the next reservation. Key validity is controlled by OpenRouter.
- Free provider availability varies. Empty completions and provider failures return
  a generic 503; no automatic retries consuming more of the free quota.

## Deployment

The deployed single instance runs on the HTTPS gateway host, listening only on
127.0.0.1:8099. Install server.py to /opt/n42-ai/server.py and n42-ai.service to
/etc/systemd/system/. Store OPENROUTER_API_KEY in /etc/n42-ai/openrouter.env,
root-only 0600; never copy it into the repository or Flutter build defines.
Systemd creates /var/lib/n42-ai for the persistent database.

Add nginx-location.conf to the existing m.si46.world HTTPS server and define
`limit_req_zone $binary_remote_addr zone=n42_ai:10m rate=2r/s;` in the HTTP context.
Run `nginx -t` before reload. The original site configuration is backed up as
`m.si46.world.conf.before-n42-ai`. Roll back the location before stopping the service.
Do not scale to multiple instances without a shared quota store.

## Validation (2026-09-20)

`python3 -m unittest discover -s backend/ai-proxy -v`: seven tests passed.
Direct OpenRouter and deployed gateway both returned HTTP 200 Chinese summaries
using synthetic text. Invalid Matrix credentials returned 401. Disposable Matrix
accounts were deactivated. A 160-token free-router attempt returned an empty/failing
completion (gateway 503); the 1,024-token smoke succeeded. Native App acceptance
and sustained production load remain unverified.

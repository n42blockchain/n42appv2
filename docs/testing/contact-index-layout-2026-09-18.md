# Contact index and entry divider — 2026-09-18

The user identified build 2026072683, provided Downloads/1.png as the actual app screenshot, and clarified that Downloads/9.jpeg is a visual reference. The app showed only search/star/D/#, spread over the available height, and no divider between Chat-only Friends and Group Chat.

Chat `3f0bca2ad8744084405b8e1a20590a7a338b549d` uses the fixed search/star/A–Z/# index, anchored to the right and centered with a bounded height. Sparse data no longer changes index length or spacing; missing groups remain harmless no-op targets. Drag hit testing accounts for vertical padding. The chat-only/group gap is replaced with the existing inset divider, preserving the app's icons and colors.

Verification: 14 existing contact navigation tests pass in Chat. The same 14 tests pass against the host Git dependency and Matrix SDK 6.2.0. Chat and host analysis report zero errors/warnings (219/201 informational diagnostics); all 780 mirrored lib/assets files match. Native visual acceptance remains pending in Chat QA-009. This change is after the 2026072685 release and is not included in that already uploaded IPA/APK.

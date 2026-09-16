# Friend profile previews, photos and video creation

- Friend details are displayed below the main profile's Friend Info entry and
  refreshed after editing: phone, tags, notes, photo count and thumbnails.
- Saved photos support zoom preview. The Photos row opens a dedicated management
  page that supports gallery multi-selection, deletion and preview. A failed
  import or metadata save does not publish partial additions; new orphan files
  are cleaned up. Annotations/photos remain private device-local data isolated
  by server, account and friend; this is not a cross-device photo backup.
- Discover Video Channels opens the video feed, with Publish Video and Go Live.
  Video-only composition requires a video and uses the existing Moment upload,
  visibility and friend-permission pipeline. Go Live calls a host callback,
  keeping the chat package independent of the host's LiveKit implementation.
- Generic channel discovery filters internal live-directory marker rooms.
- 33 focused tests passed, including edit-return refresh, multi-selection,
  partial-import cleanup, persisted preview, creator navigation and disabling
  text-only submissions in video composition. Native selection, actual video
  publication and live broadcasting are still acceptance gaps (QA-009).

## Host integration

The wallet pins Chat `0d509047811765edb4b198c37d5229f61e365128`; all 777
resolved lib/assets files match its source mirror. The Go Live callback opens
`/live/go` in the existing LiveApp. Live routes now nest below `/live`, so direct
entry retains a home route for Back/Stop instead of attempting to pop the only
route. No broadcast starts merely by navigating to the page.

Wallet regression (chat feedback wrapper plus live service): 254 passed.
Chat analyzer: zero errors/warnings, 213 informational diagnostics.
Device builds and actual broadcaster/viewer acceptance are separate checks;
no new TestFlight upload is included in this commit.
Wallet analyzer: zero errors/warnings, 195 informational diagnostics.

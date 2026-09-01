# HIG audit: what is configured, and what is left

`npx hig-doctor .`

audits this app against Apple's Human Interface Guidelines. Three findings were
fixed outright; the rest are held at a baseline rather than papered over.

## Fixed

All three were in `web/index.html`, the Flutter web shell:

- `<html>` had no `lang`. A screen reader picks its pronunciation from that
  attribute, and Flutter does not set it at runtime, so the shell declares `en`.
- The viewport carried `maximum-scale=1.0, user-scalable=no`, which stops the
  page being zoomed at all. WCAG 1.4.4 requires text to reach 200%, and pinch
  zoom is how a low-vision user gets there. Both are gone.

## Turned off

Theme, colour and typography files — `app_colors.dart`, `app_typography.dart`,
`theme_adapter.dart` and friends — are *where* colour and size literals belong.
Flagging a token definition for containing a literal is backwards. Test files
are off for the same practical reason: nothing a user sees.

That removes 333 findings, none of which were real.

## Held at a baseline: 3029 findings

`.hig-baseline.json` snapshots what exists today, so the audit reports **new**
occurrences only. Existing ones stay recorded and visible; they do not fail a
build that did not add them.

Why not just fix them:

| Rule | Count | What it is |
|---|---|---|
| `flutter/hardcoded-font-size` | 1343 | `fontSize: 14` and friends, bypassing `AppTypography` |
| `flutter/colors-red-blue` | 1127 | `Colors.white` (249), `Colors.black.withValues(...)`, `Colors.grey[600]` |
| `flutter/hardcoded-color` | 612 | `Color(0xFF...)` written at the point of use |

None of it is mechanically rewritable. `Colors.white` on a dark button is
correct; the same literal on a surface that flips in dark mode is a bug — and
the two look identical to a regex. `fontSize: 14` is not `14.sp`: switching to
the responsive unit changes what renders, on every screen it appears on. Each
one needs to be read against the surface it paints, and the result needs to be
looked at in both themes.

## How to work it down

The tail is long but the head is short — ten files hold roughly a fifth of it:

1. `packages/n42_chat/.../chat/message_item.dart` (86)
2. `.../red_packet/red_packet_detail_page.dart` (52)
3. `.../contact/contact_list_page.dart` (47)
4. `.../call/group_call_screen.dart` (42)
5. `.../red_packet/send_red_packet_page.dart` (39)

Take one file at a time, run the app on that screen in both light and dark, and
move its literals onto `AppColors` / `AppTypography`. Then re-run with
`--write-baseline` so the snapshot shrinks with the debt.

## In CI

```bash
npx hig-doctor@2.0.1 . --fail-on serious
```

The ignore list and the rule exemptions live in `hig-doctor.config.json`, so
this is the same command locally and in CI - nothing to keep in sync by hand.

`--fail-on serious` means the build goes red on anything critical or serious
that is newly introduced. It passes today, and the moderate backlog held in `.hig-baseline.json`
does not gate it.

Pipelines: `.workflow/hig-audit.yml` (Gitee Go) and `.github/workflows/hig-audit.yml`.

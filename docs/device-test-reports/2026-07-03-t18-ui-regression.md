# 2026-07-03 T18 UI regression

## Scope

- Branch: `fix/competitor-report-audit`
- Baseline: `b08bc455`
- Device: Android `38f4f08a` (`25098RA98C`, Android 16 / HyperOS)
- Build installed: `flutter build apk --debug --target-platform android-arm64 --no-pub`
- Screenshots: local only under `/tmp/n42-t18-screenshots/`

## Code fix

Found one real layout regression on Wallet home: the coin list header title was squeezed to `Tok...` on a 1080px phone because the row kept both a `Flexible` title and a `Spacer` before the fixed action buttons.

Fixed in `lib/features/wallet/pages/wallet_coin_list_header.dart`:
- kept `Tokens` single-line with ellipsis fallback,
- removed the extra `Spacer`,
- capped the network chip width and made its label ellipsize inside the chip.

Result: `Tokens` is fully visible in normal dark/light themes and 130% font. At 130%, `All networks` may shorten to `All netwo...`, but it stays inside the pill and does not overflow.

## Matrix

| ID | Result | Evidence | Notes |
| --- | --- | --- | --- |
| U1 Wallet home coin list header | PASS | `u1_dark_wallet_home_fixed_v2.png`, `u1_light_wallet_home.png`, `u13_130_wallet_home.png` | Header title no longer truncates in normal theme; rows/tap targets visible. |
| U2 Wallet asset card actions | PASS | `u2_dark_wallet_asset_actions.png` | Send/Receive/Buy are clickable and large enough; no overlap. |
| U3 Wallet switch / wallet list selected state | PASS | `u3_dark_wallet_switch_sheet.png` | Current wallet shows visible check icon and lock; add-wallet entries remain readable. |
| U4 Market list | PASS | `u4_dark_market.png` | Rows, star/bell action buttons, tabs, and scroll area render without overflow. |
| U5 Coin detail | PASS | `u5_dark_coin_detail.png` | Back/bell buttons, period chips, and Add Trade FAB have large hit areas and do not cover content. |
| U6 Price alert sheet | PASS | `u6_dark_price_alert_sheet.png` | Text, selected mode, input, switch, and Set Alert CTA render correctly at normal font. |
| U7 Add trade sheet | PASS | `u7_dark_add_trade_sheet.png` | Add Trade sheet opens and Save CTA remains reachable. |
| U8 Bottom nav | PASS | `u8_dark_bottom_nav.png`, `u13_130_wallet_home.png` | Five tabs remain readable and full-width clickable at normal and 130% font. |
| U9 Side drawer | PASS | `u9_dark_side_drawer.png` | Drawer rows and close button are full-size touch targets. |
| U10 Settings/profile invitation copy | PARTIAL | `u10_dark_profile_page.png`; code audit `personal_setting_fields.dart` | Current device is wallet-only/logged-out for app account, so invite code is not visible. Code path uses an `IconButton` for copy and is layout-safe when `PersonalSetting` has an invite code. |
| U11 Change email | FAIL / not wired | `u11_dark_security_settings.png`; code audit | Only `change_email_ui_helpers.dart` exists. No change-email page/route/menu entry is wired from Profile or Security Settings. |
| U12 Swap page | PASS | `u12_dark_swap_sheet.png`, `u12_dark_swap_ast_home.png` | Earn > Swap opens selection sheet and `Swap to N`; controls and CTA render without overflow. |
| U13 130% font U1/U6/U8 | PARTIAL | `u13_130_wallet_home.png`, `u13_130_market_empty.png`, `u13_130_market_search_btc.png` | U1/U8 pass at 130%. U6 could not be repeated at 130% because Market returned `No trending data` / search `No results`; normal-font U6 passed. |

## Verification

- `flutter analyze --no-fatal-infos`: PASS before report/code commit, with one pre-existing info in `packages/n42_chat/lib/src/presentation/widgets/chat/wechat_message_menu.dart`.
- `flutter build apk --debug --target-platform android-arm64 --no-pub`: PASS.
- Android install: PASS after user-confirmed install prompt.
- logcat filter: no `RenderFlex overflowed`, `Another exception was thrown`, or `FATAL EXCEPTION` matched during the regression run.

## Follow-up

- U11 needs product/code follow-up: either wire an actual Change Email flow into Profile/Security Settings, or remove the orphaned change-email helper if the feature is intentionally out of scope.

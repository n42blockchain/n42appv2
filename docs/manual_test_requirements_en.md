# N42 Manual QA Test Requirements and Detailed Test Procedures

## 1. Document Control

- Product: N42 Wallet
- Target build: 2.3.536+41
- Last updated: 2026-03-17
- Audience: Manual QA testers, UAT testers, release validation testers
- Language: English
- Scope: Wallet, chat, Web3, rewards/growth, settings, and regression coverage

This document is intended to be handed directly to testers. It defines:

1. What must be tested before release
2. What environment, accounts, and data are required
3. How to execute each major test flow step by step
4. What result is considered a pass or a release blocker

If a feature is hidden, disabled by configuration, unavailable in the target environment, or not exposed in the current build, mark it as `N/A` and record the reason.

## 2. Release Rules and Severity

### 2.1 Priority Definitions

- `P0`: Release blocking. Any failure must stop release until fixed or explicitly waived.
- `P1`: High impact. A failure affects a major flow or causes a serious UX or trust issue.
- `P2`: Medium impact. A failure affects a secondary flow, optional feature, or polish item.

### 2.2 Exit Criteria

- All `P0` cases must pass.
- No open crash, data loss, security, payment, wallet, transaction, or chat-login blocker may remain.
- All failed `P1` cases must have product-owner approval before shipment.
- Each failed case must include evidence and exact reproduction steps.

### 2.3 Result Values

- `Pass`
- `Fail`
- `Blocked`
- `N/A`

## 3. Test Execution Requirements

### 3.1 What the Tester Must Record for Every Run

- Device model
- OS version
- App build number
- Environment name (`dev`, `staging`, `pre-prod`, or `production sanity`)
- Network type (`Wi-Fi`, `4G/5G`, offline, weak network)
- Test account used
- Wallet address used
- Date and tester name

### 3.2 Evidence Required for Every Failure

- Screenshot or screen recording
- Exact test case ID
- Actual result vs expected result
- Reproduction steps
- Transaction hash, wallet address, room ID, group ID, or deep link used when relevant
- Logs if available

### 3.3 Security and Data Handling Rules

- Never attach real mnemonic phrases, private keys, or passwords to tickets.
- Redact tokens, login links, WalletConnect secrets, and recovery phrases in reports.
- Use test wallets and test accounts whenever possible.
- If a production-like environment must be used, confirm with the release owner first.

## 4. Required Test Environment and Data

### 4.1 Device Matrix

Run critical `P0` flows on at least:

- 1 Android phone on the current major Android version
- 1 Android phone on the previous major Android version
- 1 iPhone on the current major iOS version
- 1 iPhone on the previous major iOS version

Also run targeted checks on:

- 1 tablet or large-screen device
- 1 low-memory or mid-range Android device
- 1 device with biometric auth enabled
- 1 device that can receive push notifications reliably

### 4.2 Required Accounts

- 1 brand new app account
- 1 returning app account
- 2 chat users for direct-message testing
- 1 additional chat user for group tests
- Social login accounts for every provider visible in the build
- 1 test account with notification permission granted
- 1 test account with notification permission denied

### 4.3 Required Wallet Data

- 1 empty wallet
- 1 funded wallet with enough native gas token
- 1 multi-chain wallet with ETH, BTC, SOL, TRX, and N42 available
- 1 wallet containing at least 1 custom token
- 1 wallet with past transaction history
- 1 watch-only wallet, if the feature is available
- 1 AA / smart-account enabled wallet, if the feature is available

### 4.4 Required External Test Data

- 1 valid WalletConnect v2 QR code or URI
- 1 safe DApp URL
- 1 browser history candidate URL
- 1 phishing test URL or internally approved blocked domain
- 1 bridge-supported source chain and destination chain with funded assets
- 1 staking-supported asset with enough balance
- 1 MoonPay / buy-sell environment approved by the business team
- 1 airdrop-eligible wallet if available
- 1 loyalty account with points if available
- 1 QR code for add-friend, room, or payment-request routing
- 1 chat room with old messages, pinned content, and searchable keywords
- 1 chat room with image, video, voice, file, and PDF samples
- 1 chat group with admin permissions and at least one removable member
- 1 pending friend request and 1 ignored or blocked user if those states are available
- 1 wallet address or ENS name that resolves to an N42 chat identity if Web3 add-friend is visible
- 1 chat room suitable for transfer, payment-request, or red-packet tests
- 1 account pair for story / moment visibility tests if the module is visible
- 1 space/community, 1 channel, and 1 voice room if those modules are visible
- 1 connected bridge account such as Discord, Telegram, or WhatsApp if Connected Accounts is visible
- 1 storage-heavy chat account with cached media for storage-management validation
- 1 E2EE verification pair for SAS / emoji device verification if enabled
- 1 AI-assistant enabled account if the module is visible
- 1 points / redemption test account if the module is visible
- Hardware wallet devices if hardware-wallet testing is in scope:
  - Ledger
  - Trezor
  - Keystone

## 5. Navigation and Entry Map

Use this map when the tester needs to find a feature quickly.

### 5.1 Primary Home Navigation

- Wallet
- Mining
- Earn
- Market
- Chat

Note: Chat opens as a dedicated page instead of behaving like a normal tab page.

### 5.2 Drawer / Side Menu

- Profile
- Wallet Management
- Address Book
- Security
- Settings
- In-app Browser
- About

### 5.3 Wallet Home Quick Entry Points

- Send
- Receive
- Swap
- Payment Code
- Buy
- Sell
- WalletConnect / Scan
- ENS
- Smart Account
- Add Token
- Change Network

### 5.4 Chat Main Navigation

- Messages / Conversations
- Contacts
- Discover
- Me / Profile

### 5.5 Chat Secondary Entry Points

- Search
- Add Friend
- Create Group
- QR Scan
- My QR Code
- Payment / Receive / Transfer
- Chat Settings
- Group Settings
- Chat Folder Management
- Storage Management / Backup / Auto-Download
- Connected Accounts / Bridges when visible
- Voice Rooms / Spaces / AI Assistant when visible

### 5.6 Wallet Extended Entry Points

- Portfolio
- NFT Gallery
- Gas Tracker / Alerts
- Price Alert / Trade Journal
- Batch Transfer
- Token Discovery
- Cloud Backup / Export Backup
- Face Binding / Face Match

## 6. Coverage Matrix

| Area | Covered By |
|---|---|
| Install, launch, upgrade, recovery | GEN-01 to GEN-05 |
| Authentication, social login, and session handling | AUTH-01 to AUTH-05 |
| App lock, biometrics, timeout, device security | SEC-01 to SEC-05 |
| Wallet creation, import, backup, restore, watch-only basics | WLT-01 to WLT-05 |
| Wallet management, chain coverage, token management, display rules | WLT-06 to WLT-10 |
| Send, receive, QR, address book, history | TX-01 to TX-07 |
| Market, ENS, AA, batch transfer, hardware wallet | ADV-01 to ADV-06 |
| Buy / sell / swap / bridge / staking / earn | DEFI-01 to DEFI-07 |
| Mining, loyalty, airdrop | GROW-01 to GROW-04 |
| Browser, WalletConnect, anti-phishing, deep links | WEB3-01 to WEB3-06 |
| Chat auth, SSO, session persistence | CHAT-01 to CHAT-04 |
| Chat messaging core, media, and message actions | CHAT-05 to CHAT-11 |
| Groups, contacts, calls, stories, token gate, and voice rooms | CHAT-12 to CHAT-17 |
| Chat privacy, E2EE, export, search, and multi-device | CHAT-18 to CHAT-22 |
| Additional wallet coverage: cloud backup, password change, memo/tag, portfolio, NFT, gas, alerts, face verification | WLT-11 to ADV-12 |
| Extended chat coverage: add-friend, QR, folders, red packet, profile, settings, storage, bridges, spaces, AI, points | CHAT-23 to CHAT-41 |
| Push, theme, language, settings, responsiveness | UX-01 to UX-06 |
| Regression, offline, stability, long-session reliability | REG-01 to REG-05 |

Coverage rule:
Every visible top-level wallet module, every visible host-app entry point, and every chat module with a dedicated page, route, or explicit plus-menu / settings action should map to at least one case in this document. Helper-only code, internal services with no user-facing UI, and backend-only APIs are excluded from manual QA scope.

## 7. Detailed Test Procedures

## 7.1 General Build Validation

### GEN-01 Install, launch, and first-run behavior

- Priority: P0
- Platforms: Android, iOS
- Entry: OS install flow
- Preconditions: Fresh install or fully cleaned app data

Steps:
1. Install the build from the provided package.
2. Launch the app from the home screen.
3. Observe the splash screen, onboarding, login entry, and terms-of-service flow.
4. Accept terms if the build requires it.
5. Close the app completely and relaunch it.

Expected results:
1. The app opens without crash, ANR, white screen, or broken layout.
2. The first screen is correct for a new user.
3. Terms of Service appears only when expected and can be completed successfully.
4. Relaunch returns the user to the correct next screen.

### GEN-02 Cold start, warm start, and kill-relaunch

- Priority: P0
- Platforms: Android, iOS
- Entry: Home screen
- Preconditions: App installed; at least one successful login already completed

Steps:
1. Launch the app from a fully closed state and measure whether it reaches a usable screen.
2. Send the app to background and resume it after 10 seconds.
3. Force-kill the app from the task switcher.
4. Relaunch the app.

Expected results:
1. Cold start succeeds and lands on the correct authenticated or unauthenticated state.
2. Warm resume restores the previous context without corrupted UI.
3. Force-kill followed by relaunch does not cause data corruption or a login loop.

### GEN-03 Upgrade from previous version

- Priority: P0
- Platforms: Android, iOS
- Entry: Existing installed older build
- Preconditions: Older build installed with wallet data, chat data, settings, and history

Steps:
1. Install the new build over the previous version.
2. Launch the app.
3. Verify that wallets, settings, theme, language, and chat account state are preserved.
4. Open Wallet, Chat, Settings, and one transaction-history screen.

Expected results:
1. Upgrade does not wipe wallet or chat data.
2. Migration, if any, completes without blocking the user.
3. Existing sessions and preferences remain valid unless intentionally invalidated by product rules.

### GEN-04 App recovery after crash or interrupted operation

- Priority: P1
- Platforms: Android, iOS
- Entry: During any transaction, upload, or login flow
- Preconditions: Active wallet and chat sessions

Steps:
1. Start a non-trivial flow such as transaction submission, media upload, or chat login.
2. Kill the app during loading.
3. Relaunch the app.
4. Check the related module again.

Expected results:
1. The app does not become permanently stuck.
2. Incomplete flows are either resumed safely or rolled back safely.
3. Duplicate transactions or duplicate chat messages are not created unintentionally.

### GEN-05 Offline launch and reconnect

- Priority: P1
- Platforms: Android, iOS
- Entry: Home screen
- Preconditions: Logged-in user and at least one wallet already available

Steps:
1. Disable all network connectivity.
2. Launch the app.
3. Open Wallet, Chat, Market, and Settings.
4. Re-enable network connectivity.
5. Refresh Wallet and Chat manually.

Expected results:
1. The app remains usable and does not crash when offline.
2. Offline screens show graceful fallback, cached data, or a meaningful error state.
3. Reconnect restores live data without requiring reinstall or full logout.

## 7.2 Authentication and Session

### AUTH-01 Email sign-up and login

- Priority: P0
- Platforms: Android, iOS
- Entry: Login page
- Preconditions: New email address available

Steps:
1. Open the app on a fresh or logged-out state.
2. Register a new account using email and the required verification flow.
3. Complete any OTP or email verification required by the environment.
4. Log in with the new account.
5. Log out.
6. Log in again with the same credentials.

Expected results:
1. Registration completes successfully.
2. Login succeeds without UI freeze or repeated error prompts.
3. Logout returns the user to the correct unauthenticated screen.
4. Re-login works with the same credentials.

### AUTH-02 Password reset and login recovery

- Priority: P1
- Platforms: Android, iOS
- Entry: Login page > Forgot Password
- Preconditions: Existing account with a known email address

Steps:
1. Tap the password-reset or forgot-password entry.
2. Request a reset code or reset email.
3. Complete the reset flow.
4. Log in with the new password.
5. Confirm that the old password no longer works.

Expected results:
1. Reset instructions are delivered correctly.
2. Password reset completes without leaving the account unusable.
3. Only the new password works after reset.

### AUTH-03 Social login providers

- Priority: P1
- Platforms: Android, iOS
- Entry: Login page
- Preconditions: Social providers are visible in the current build

Steps:
1. Test each visible social login provider one by one.
2. Complete the provider flow.
3. Return to the app.
4. Verify successful login.
5. Log out after each provider and retry once.

Expected results:
1. The app correctly returns from the provider callback.
2. Login succeeds and opens the expected post-login destination.
3. The provider button is hidden if the provider is not configured for the build.

Note:
- Apple login is typically iOS-only.
- Test only providers that are visible and officially enabled in the environment.

### AUTH-04 Session persistence and token expiry handling

- Priority: P0
- Platforms: Android, iOS
- Entry: Logged-in state
- Preconditions: Existing authenticated account

Steps:
1. Log in successfully.
2. Close and reopen the app.
3. Background the app for several minutes and resume it.
4. If the environment supports it, use an expired or invalidated session token.
5. Observe whether the app refreshes the session or redirects to login.

Expected results:
1. Valid sessions persist correctly across relaunches.
2. Expired sessions are handled gracefully.
3. The user is not trapped in a broken loading or redirect loop.

### AUTH-05 Logout data cleanup

- Priority: P1
- Platforms: Android, iOS
- Entry: Profile or drawer logout action
- Preconditions: Logged-in user with Wallet and Chat data already visible

Steps:
1. Log in.
2. Open Wallet, Chat, and Settings.
3. Log out from the app.
4. Relaunch the app.
5. Confirm whether the expected local data is cleared or preserved according to product rules.

Expected results:
1. Logout removes or protects account-scoped data correctly.
2. Sensitive screens cannot be reopened without authentication.
3. The app returns to the correct unauthenticated state.

## 7.3 App Security and Device Protection

### SEC-01 Set and verify app lock

- Priority: P0
- Platforms: Android, iOS
- Entry: Drawer > Security or Profile > Security Settings
- Preconditions: Logged-in user

Steps:
1. Enable app lock using the available method in the build.
2. Close and reopen the app.
3. Attempt to unlock with the correct secret.
4. Attempt to unlock with an incorrect secret.

Expected results:
1. Security settings save successfully.
2. The app requests unlock on relaunch when expected.
3. Correct unlock works.
4. Incorrect unlock is rejected safely.

### SEC-02 Biometric authentication

- Priority: P0
- Platforms: Android, iOS
- Entry: Security Settings
- Preconditions: Device has biometric hardware and an enrolled biometric

Steps:
1. Enable biometric unlock.
2. Lock the app or relaunch it.
3. Unlock using a valid biometric.
4. Cancel biometric auth once.
5. Retry and unlock again.

Expected results:
1. Biometric enrollment is detected correctly.
2. Valid biometric unlock succeeds.
3. Canceling biometric auth does not break the app.
4. Fallback unlock path remains usable if provided by product design.

### SEC-03 Background timeout auto-lock

- Priority: P1
- Platforms: Android, iOS
- Entry: Security Settings
- Preconditions: App lock already enabled

Steps:
1. Set the lock timeout to the shortest available value.
2. Background the app for less than the timeout and resume it.
3. Background the app for longer than the timeout and resume it.

Expected results:
1. The app stays unlocked before the timeout expires.
2. The app locks after the timeout expires.
3. Timeout settings are honored consistently after resume and relaunch.

### SEC-04 Repeated failure handling

- Priority: P1
- Platforms: Android, iOS
- Entry: Lock screen
- Preconditions: App lock already enabled

Steps:
1. Enter the wrong unlock secret repeatedly until rate limiting is triggered.
2. Wait for the lockout period to end.
3. Enter the correct secret.

Expected results:
1. Repeated failures trigger the expected delay or lockout behavior.
2. The app does not crash or bypass the protection.
3. Correct unlock works after the lockout period.

### SEC-05 Root / jailbreak / unsupported device warning

- Priority: P2
- Platforms: Android, iOS
- Entry: App launch or security-sensitive flow
- Preconditions: Test device or simulator that can exercise the warning path, if available

Steps:
1. Launch the app on the prepared test device or environment.
2. Trigger a wallet-sensitive flow such as send or export.
3. Observe any security warning or restriction.

Expected results:
1. The app warns or restricts behavior according to product policy.
2. Messaging is clear and does not expose sensitive information.

## 7.4 Wallet Onboarding, Import, and Backup

### WLT-01 Create a new wallet

- Priority: P0
- Platforms: Android, iOS
- Entry: Create Wallet
- Preconditions: Fresh install or no existing wallet selected

Steps:
1. Start wallet creation.
2. Review the generated recovery phrase.
3. Complete the recovery-phrase verification step.
4. Set the required password or security layer.
5. Finish the flow and open the wallet home screen.

Expected results:
1. Wallet creation succeeds without broken navigation.
2. Recovery phrase is generated and can be verified.
3. The wallet opens with the correct default home state.

### WLT-02 Import wallet by mnemonic

- Priority: P0
- Platforms: Android, iOS
- Entry: Import Wallet
- Preconditions: Valid mnemonic available

Steps:
1. Start the import flow.
2. Enter the mnemonic phrase exactly.
3. Complete validation and confirm import.
4. Open the imported wallet.

Expected results:
1. Valid mnemonic import succeeds.
2. Imported addresses and balances match the source wallet.
3. Invalid mnemonic input is rejected clearly.

### WLT-03 Import wallet by private key or keystore

- Priority: P0
- Platforms: Android, iOS
- Entry: Import Wallet
- Preconditions: Supported private key or keystore file available

Steps:
1. Choose private-key import or keystore import.
2. Enter the required data and password if needed.
3. Complete the import flow.
4. Verify the imported wallet address.

Expected results:
1. Import succeeds for supported formats.
2. Unsupported or malformed input shows a clear error.
3. Imported wallet opens correctly and can load assets.

### WLT-04 Backup export and backup reminder behavior

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet or Security area
- Preconditions: Wallet created locally and backup not yet completed

Steps:
1. Create a new wallet without completing backup.
2. Return to the wallet home screen.
3. Observe any backup reminder banner or prompt.
4. Enter the backup flow and export or confirm the recovery phrase.
5. Return to wallet home.

Expected results:
1. Unbacked wallets show the expected backup reminder.
2. Backup flow is accessible and completes successfully.
3. Reminder state updates correctly after successful backup.

### WLT-05 Watch-only wallet restrictions

- Priority: P2
- Platforms: Android, iOS
- Entry: Watch-only wallet, if visible in the current build
- Preconditions: Watch-only wallet available

Steps:
1. Open a watch-only wallet.
2. Try to open send and other signing-dependent actions.
3. Try allowed read-only flows such as viewing balances and history.

Expected results:
1. Read-only data is visible.
2. Signing actions are blocked with a clear explanation.

## 7.5 Wallet Management, Multi-chain, and Tokens

### WLT-06 Multi-wallet switching, rename, and delete

- Priority: P1
- Platforms: Android, iOS
- Entry: Drawer > Wallet Management
- Preconditions: At least two wallets available

Steps:
1. Open wallet management.
2. Switch between wallets and confirm the active wallet changes.
3. Rename one wallet.
4. Delete a non-critical test wallet.

Expected results:
1. Switching updates the wallet home state correctly.
2. Rename is reflected everywhere the wallet name is shown.
3. Delete requires confirmation and removes only the selected wallet.

### WLT-07 Critical chain coverage

- Priority: P0
- Platforms: Android, iOS
- Entry: Wallet home
- Preconditions: Multi-chain wallet with supported assets

Mandatory chains for release coverage:
- ETH
- BTC
- SOL
- TRX
- N42

Secondary chains when enabled:
- TON
- APT
- SUI
- DOT
- XRP

Steps:
1. Switch to each mandatory chain.
2. Verify address format, asset visibility, balance loading, and history loading.
3. Confirm chain-specific UI does not break.

Expected results:
1. Chain switching is correct and stable.
2. Addresses match chain format expectations.
3. Balance and transaction data load without cross-chain contamination.

### WLT-08 Token list management and token discovery

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet home > Token section
- Preconditions: Wallet with token support and at least one token to add or discover

Steps:
1. Add a custom token manually.
2. Refresh the wallet.
3. Hide and re-show a token if supported.
4. Observe auto-discovered tokens if the environment provides them.
5. Dismiss or add a discovered token.

Expected results:
1. Custom tokens can be added when contract data is valid.
2. Hidden tokens no longer clutter the visible list.
3. Discovery suggestions do not duplicate already-added tokens.

### WLT-09 Network selector and chain management

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet home > Change Network or manage-chains flow
- Preconditions: Wallet with multiple chain options

Steps:
1. Open the network selector.
2. Switch between networks.
3. Open chain-management settings if available.
4. Enable or disable at least one non-critical chain.
5. Return to wallet home.

Expected results:
1. Network selector loads correctly.
2. Enabled or disabled chain state is preserved.
3. Disabled chains do not appear in main wallet flow unless re-enabled.

### WLT-10 Hide small assets / portfolio display rules

- Priority: P2
- Platforms: Android, iOS
- Entry: Wallet home > Token list controls
- Preconditions: Wallet with multiple small-balance assets

Steps:
1. Open the small-assets threshold control.
2. Set a non-zero threshold.
3. Observe the filtered token list.
4. Reset the threshold to zero.

Expected results:
1. Low-value assets are filtered correctly.
2. Resetting the threshold restores the full list.

## 7.6 Send, Receive, QR, and Transaction History

### TX-01 Receive flow and QR display

- Priority: P0
- Platforms: Android, iOS
- Entry: Wallet home > Receive
- Preconditions: Existing wallet

Steps:
1. Open the receive flow for at least ETH and BTC.
2. Verify the address and QR code.
3. Copy the address.
4. Share the address if share is supported.

Expected results:
1. Correct chain address is shown.
2. QR code matches the visible address.
3. Copy and share actions work correctly.

### TX-02 Payment code and amount-prefilled receive flow

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet home > Payment Code
- Preconditions: Existing wallet

Steps:
1. Open Payment Code.
2. Enter a custom amount if supported.
3. Generate the payment QR.
4. Scan the QR using another device or test scanner.

Expected results:
1. The QR contains the expected wallet and amount information.
2. Scanned result pre-fills the receiving data correctly.

### TX-03 Native-asset transfer happy path

- Priority: P0
- Platforms: Android, iOS
- Entry: Wallet home > Send
- Preconditions: Funded wallet with enough gas

Steps:
1. Start a native-asset transfer on a critical chain.
2. Enter a valid destination address.
3. Enter a valid amount.
4. Review fee details and confirm.
5. Complete authentication and submit.
6. Follow the result to history or details.

Expected results:
1. Transfer validation succeeds only for valid input.
2. Submission succeeds.
3. Transaction appears in history with the correct status and hash.

### TX-04 Token transfer happy path

- Priority: P1
- Platforms: Android, iOS
- Entry: Token asset detail > Send
- Preconditions: Wallet funded with a supported token and native gas token

Steps:
1. Open a token asset.
2. Start a send flow.
3. Enter a valid destination and amount.
4. Confirm and sign.

Expected results:
1. Token send uses the correct asset and chain.
2. Fee handling is correct.
3. History and detail views reflect the token transfer accurately.

### TX-05 Validation for bad address, bad amount, and insufficient balance

- Priority: P0
- Platforms: Android, iOS
- Entry: Send flow
- Preconditions: Existing wallet

Steps:
1. Enter an invalid address.
2. Enter zero amount.
3. Enter an amount greater than available balance.
4. Try to continue at each step.

Expected results:
1. Invalid inputs are blocked immediately or before submission.
2. Error messaging is clear and chain-specific where needed.
3. The app never submits malformed data silently.

### TX-06 Scan-to-fill and address-book send flow

- Priority: P1
- Platforms: Android, iOS
- Entry: Send flow
- Preconditions: One saved address-book entry and one QR code available

Steps:
1. Start a send flow.
2. Choose a saved address-book entry.
3. Cancel and repeat using QR scan.
4. Confirm that the destination field fills correctly.

Expected results:
1. Address-book selection fills the correct recipient data.
2. QR scanning parses supported address formats correctly.

### TX-07 Transaction history, detail, and retry behavior

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet transaction history
- Preconditions: Wallet with old and new transactions

Steps:
1. Open transaction history.
2. Check ordering, pagination, and status display.
3. Open a transaction detail page.
4. If the build supports retry for failed or replaceable transactions, exercise that path.

Expected results:
1. History is readable and ordered correctly.
2. Detail page shows chain, status, hash, amount, and timestamps correctly.
3. Retry or follow-up actions are only shown when valid.

## 7.7 Advanced Wallet Features

### ADV-01 Market data and gas tracking

- Priority: P2
- Platforms: Android, iOS
- Entry: Market or token detail pages
- Preconditions: Live data environment available

Steps:
1. Open Market.
2. Verify price, trend, and token list loading.
3. Open any gas-related display if the build exposes it.
4. Refresh the page.

Expected results:
1. Market data loads and refreshes without layout corruption.
2. Gas-related values display valid numbers and units.

### ADV-02 ENS lookup and management

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet home > ENS
- Preconditions: ETH address available; ENS environment configured

Steps:
1. Open the ENS area.
2. Search for an available or owned ENS name.
3. If supported, start registration or open owned-name management.
4. Confirm address-to-name display on wallet home if applicable.

Expected results:
1. ENS screen opens successfully.
2. Search and resolution behave correctly.
3. Owned ENS names, if any, display properly in wallet UI.

### ADV-03 Smart account / account abstraction

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet home > Smart Account
- Preconditions: AA feature visible and enabled

Steps:
1. Open the smart-account entry.
2. Create or select a smart account if needed.
3. Review deployment state.
4. Perform a simple supported action.
5. If paymaster or gas sponsorship is visible, test it.

Expected results:
1. Smart-account status is shown correctly.
2. Supported AA actions complete without confusing fallback behavior.
3. Deployment or undeployed state is clearly indicated.

### ADV-04 Batch transfer

- Priority: P1
- Platforms: Android, iOS
- Entry: EVM wallet actions or Earn quick tools, depending on build
- Preconditions: EVM wallet with enough balance and at least two recipients

Steps:
1. Open Batch Transfer.
2. Add at least two recipients manually or by supported import format.
3. Estimate gas.
4. Confirm and sign the batch transaction.
5. Follow the result to history or transaction status.

Expected results:
1. Invalid rows are rejected clearly.
2. Gas estimation and total amount are correct.
3. Batch transaction submits successfully or fails safely with a clear reason.

### ADV-05 Hardware wallet flows

- Priority: P1
- Platforms: Android, iOS where supported by the build and device
- Entry: Profile > Hardware Wallet
- Preconditions: Supported hardware device available

Steps:
1. Open Hardware Wallet.
2. Pair or connect the supported device.
3. Import or view accounts.
4. Attempt a supported signing flow.
5. Disconnect the device and reconnect it.

Expected results:
1. Discovery and pairing work according to the device type.
2. Account data loads correctly.
3. Signing requests are shown and confirmed correctly.
4. Disconnect handling is graceful.

### ADV-06 Address book management

- Priority: P1
- Platforms: Android, iOS
- Entry: Drawer > Address Book
- Preconditions: Existing wallet

Steps:
1. Add a new address-book entry with name, chain, and address.
2. Edit the entry.
3. Delete the entry.
4. Reopen the send flow and confirm the updated list is reflected.

Expected results:
1. CRUD actions work without duplicates or stale cache.
2. The address book is consistent across send-related screens.

## 7.8 Buy, Sell, Swap, Bridge, Staking, and Earn

### DEFI-01 Buy flow

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet home > Buy
- Preconditions: Buy provider visible and environment-approved

Steps:
1. Open Buy.
2. Select a supported asset and amount.
3. Proceed through the visible quote and checkout steps until the last safe test point.

Expected results:
1. The buy flow opens correctly.
2. Asset, wallet address, and quote data are correct.
3. If signature or verification is required, prompts are understandable.

### DEFI-02 Sell flow

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet home > Sell
- Preconditions: Sell provider visible and supported

Steps:
1. Open Sell.
2. Select a supported asset.
3. Enter amount and proceed through the flow.

Expected results:
1. Sell flow loads correctly.
2. Wallet address and asset mapping are correct.
3. Any required signing step is explicit and safe.

### DEFI-03 Swap flow

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet home > Swap
- Preconditions: Swap visible with supported liquidity in the environment

Steps:
1. Open Swap.
2. Choose source token and target token.
3. Enter amount.
4. Review quote, slippage, and fees.
5. Confirm and sign.

Expected results:
1. Quotes update correctly when token or amount changes.
2. The swap can be submitted successfully.
3. Final result is reflected in balances and transaction history.

### DEFI-04 Bridge flow

- Priority: P1
- Platforms: Android, iOS
- Entry: Bridge entry point from wallet or earn-related flow, if visible
- Preconditions: Bridge-supported chains and funded source wallet available

Steps:
1. Open Bridge.
2. Select source chain and destination chain.
3. Select a supported token.
4. Enter amount.
5. Review bridge fee, estimated receive amount, and route.
6. Confirm and sign.
7. Open bridge history.

Expected results:
1. Supported source and destination chains load correctly.
2. Bridge quote and fee display are valid.
3. History shows pending, in-progress, completed, or failed state clearly.

### DEFI-05 General staking flow

- Priority: P1
- Platforms: Android, iOS
- Entry: Staking entry or Earn, if visible
- Preconditions: Staking-supported asset with enough balance

Steps:
1. Open Staking.
2. Choose a protocol or validator.
3. Enter an amount.
4. Review APY, lock conditions, fee, and validation rules.
5. Confirm and sign.
6. Reopen the staking positions screen.

Expected results:
1. Protocol list loads correctly.
2. Stake flow validates correctly.
3. New stake appears in positions with the correct status.

### DEFI-06 Unstake, redeem, or BTC staking redemption

- Priority: P1
- Platforms: Android, iOS
- Entry: Existing staking position or BTC staking page
- Preconditions: Existing staking position or BTC staking test position

Steps:
1. Open an existing position.
2. Start unstake or redeem.
3. Review constraints such as cooldown, unbonding, or lock time.
4. Confirm and sign.

Expected results:
1. Rules are enforced correctly.
2. Position status changes to the correct intermediate or final state.

### DEFI-07 Earn page overview

- Priority: P2
- Platforms: Android, iOS
- Entry: Home > Earn
- Preconditions: Logged-in user

Steps:
1. Open Earn.
2. Review the main sections, cards, shortcuts, and data widgets.
3. Navigate to at least one connected feature such as Staking, Batch Transfer, or another visible quick tool.

Expected results:
1. Earn loads without broken cards or dead navigation.
2. Visible shortcuts lead to the correct modules.

## 7.9 Mining, Loyalty, and Airdrop

### GROW-01 Mining core flow

- Priority: P1
- Platforms: Android, iOS
- Entry: Home > Mining
- Preconditions: Mining available in the target environment

Steps:
1. Open Mining.
2. Review current mining status, daily view, and active state.
3. Start, stop, or configure mining if allowed by the environment.
4. Background and resume the app.

Expected results:
1. Mining status is displayed correctly.
2. Background/resume does not desynchronize the mining state.
3. Mining UI does not show stale data indefinitely.

### GROW-02 Loyalty tasks and points

- Priority: P2
- Platforms: Android, iOS
- Entry: Loyalty entry if visible
- Preconditions: Loyalty feature enabled

Steps:
1. Open Loyalty.
2. Review tier, point total, task list, and history.
3. Complete or simulate at least one available task.
4. Open Rewards and attempt a redeem flow if enough points are available.

Expected results:
1. Points, tier, and history load correctly.
2. Completed task state updates correctly.
3. Rewards can be redeemed only when rules allow it.

### GROW-03 Airdrop list, filter, and detail

- Priority: P2
- Platforms: Android, iOS
- Entry: Airdrop entry if visible
- Preconditions: Airdrop feature enabled

Steps:
1. Open Airdrop Tracker.
2. Review summary stats and category tabs.
3. Apply at least one filter.
4. Open one airdrop detail page.

Expected results:
1. Airdrop categories and counts are consistent.
2. Detail page loads requirement, timeline, and status correctly.

### GROW-04 Airdrop claim flow

- Priority: P2
- Platforms: Android, iOS
- Entry: Airdrop detail page
- Preconditions: Claimable airdrop available in the environment

Steps:
1. Open a claimable airdrop.
2. Start the claim flow.
3. Complete any wallet confirmation or verification step.

Expected results:
1. Claim is only allowed for eligible wallets.
2. Status updates to the correct claimed or pending state.

## 7.10 Browser, WalletConnect, DApp, and Deep Links

### WEB3-01 In-app browser basic navigation

- Priority: P1
- Platforms: Android, iOS
- Entry: Drawer > Browser
- Preconditions: Safe test URL available

Steps:
1. Open Browser.
2. Load a safe URL.
3. Verify page load progress, title, address bar, and refresh behavior.
4. Open a second tab if the UI supports it.
5. Switch tabs and close one tab.

Expected results:
1. Browser loads pages successfully.
2. Tab state is handled correctly.
3. Browser history and title updates work as expected.

### WEB3-02 WalletConnect connection flow

- Priority: P0
- Platforms: Android, iOS
- Entry: Wallet home top bar or scan entry
- Preconditions: Valid WalletConnect URI or QR available

Steps:
1. Open WalletConnect or scan.
2. Scan or paste a valid WalletConnect URI.
3. Review the DApp metadata.
4. Approve the connection.
5. Open the session list if available.

Expected results:
1. WalletConnect pairing succeeds.
2. The session shows the correct DApp metadata and chain scope.
3. Approved session appears in the session list.

### WEB3-03 WalletConnect signing and disconnect

- Priority: P0
- Platforms: Android, iOS
- Entry: Active WalletConnect session
- Preconditions: Connected DApp session

Steps:
1. Trigger a message-sign request from the DApp.
2. Approve once and reject once.
3. Trigger a transaction request from the DApp.
4. Approve it if safe in the environment.
5. Disconnect the session from the app.

Expected results:
1. Sign and transaction approval prompts show the correct details.
2. Reject flow returns a proper failure to the DApp.
3. Disconnect removes the session cleanly.

### WEB3-04 DApp chain switching and browser-based wallet injection

- Priority: P1
- Platforms: Android, iOS
- Entry: Browser + supported DApp
- Preconditions: DApp that can request chain switch or account access

Steps:
1. Open the DApp in the in-app browser.
2. Connect the wallet through the browser flow.
3. Trigger an account request.
4. Trigger a supported chain-switch request.

Expected results:
1. The injected wallet flow works correctly.
2. Chain-switch prompts are shown clearly.
3. Account and chain state stay consistent after approval.

### WEB3-05 Anti-phishing and dangerous URL handling

- Priority: P0
- Platforms: Android, iOS
- Entry: Browser or DApp redirect
- Preconditions: Approved phishing test URL or dangerous protocol test case available

Steps:
1. Attempt to open a blocked or phishing test URL.
2. Attempt to navigate to a blocked scheme such as `javascript:` or other disallowed content, if safely reproducible.
3. Observe the app response.

Expected results:
1. Dangerous navigation is prevented.
2. The user sees a warning or safe fallback.
3. The app does not crash or silently proceed to a blocked page.

### WEB3-06 Deep links

- Priority: P1
- Platforms: Android, iOS
- Entry: External link source
- Preconditions: Deep links available

Test the following examples when supported by the environment:

- `n42://chat/{roomId}`
- `n42://user/{userId}`
- `n42://group/{groupId}`
- `n42://auth/sso?...`
- WalletConnect URI links

Steps:
1. Open each supported deep link from an external source.
2. Observe app launch or resume behavior.
3. Confirm the destination page or flow.

Expected results:
1. Supported deep links route to the correct destination.
2. Unsupported links fail gracefully.
3. Sensitive parameters are never exposed in UI or logging visible to end users.

## 7.11 Chat Authentication and Session Entry

### CHAT-01 Enter chat from home and drawer

- Priority: P1
- Platforms: Android, iOS
- Entry: Home > Chat, or Drawer > Profile / Chat-related entry
- Preconditions: App installed

Steps:
1. Open Chat from the home navigation.
2. Return to home.
3. Open Chat again from any secondary visible entry.

Expected results:
1. Chat page opens correctly from all supported entry points.
2. Navigation back to the main app remains stable.

### CHAT-02 Chat login and logout

- Priority: P0
- Platforms: Android, iOS
- Entry: Chat page
- Preconditions: Valid chat account available

Steps:
1. Open Chat while logged out.
2. Log in using the primary supported chat login path.
3. Open the conversation list.
4. Log out from chat or host-account flow as designed.
5. Re-enter Chat.

Expected results:
1. Chat authentication succeeds.
2. Chat session state is synchronized correctly with the host app.
3. Logout behavior matches product rules without leaving stale private content exposed.

### CHAT-03 Chat SSO callback

- Priority: P1
- Platforms: Android, iOS
- Entry: External SSO callback link
- Preconditions: SSO environment configured

Steps:
1. Start the SSO login flow.
2. Complete authentication in the external browser or provider.
3. Return to the app via callback.

Expected results:
1. The callback is handled correctly.
2. The user lands in an authenticated chat state.
3. Missing or invalid callback data is handled gracefully.

### CHAT-04 Chat session persistence

- Priority: P1
- Platforms: Android, iOS
- Entry: Logged-in chat state
- Preconditions: Chat user already logged in

Steps:
1. Log in to Chat.
2. Kill the app and relaunch it.
3. Open Chat again.
4. Trigger a deep link into Chat if available.

Expected results:
1. Valid chat session persists.
2. Deep links wait correctly if chat initialization takes time.

## 7.12 Chat Core Messaging and Media

### CHAT-05 Direct message text flow

- Priority: P0
- Platforms: Android, iOS
- Entry: Chat > direct message
- Preconditions: Two chat users available

Steps:
1. Open a direct conversation.
2. Send a text message from user A to user B.
3. Verify delivery on user B.
4. Reply from user B.
5. Verify read state if the feature is visible.

Expected results:
1. Both users receive messages in correct order.
2. Timestamps, sender labels, and unread counts update correctly.

### CHAT-06 Conversation list and unread counters

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat conversation list
- Preconditions: At least three conversations with different unread states

Steps:
1. Open the chat conversation list.
2. Verify ordering of recent conversations.
3. Send new messages into one conversation.
4. Return to the list.

Expected results:
1. Recent conversations move to the top correctly.
2. Unread badges update correctly in list and app-level entry points.

### CHAT-07 Image and video messaging

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat conversation > media picker
- Preconditions: Media permission granted

Steps:
1. Send an image.
2. Send a video.
3. Preview each item in the conversation.
4. Retry under weak network once.

Expected results:
1. Media upload and download work correctly.
2. Preview opens successfully.
3. Failed uploads show a clear retry state.

### CHAT-08 Voice note, file, and document messaging

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat conversation > attachment tools
- Preconditions: Microphone and file access permission available

Steps:
1. Record and send a voice note.
2. Send a local file or document.
3. Receive and open the content on another device.

Expected results:
1. Voice note recording, playback, and sending work correctly.
2. File attachment metadata and file open behavior are correct.

### CHAT-09 Special message types

- Priority: P2
- Platforms: Android, iOS
- Entry: Chat conversation
- Preconditions: Feature visible in the current chat build

Test when visible:

- Contact card
- Location
- Rich link preview
- Mention
- Reply reference

Expected results:
1. Each special message renders correctly.
2. Tapping the message opens the expected follow-up action.

### CHAT-10 Message operations

- Priority: P1
- Platforms: Android, iOS
- Entry: Existing message > long press or message action menu
- Preconditions: Conversation with user-sent and received messages

Steps:
1. Long-press a sent message.
2. Test visible actions such as copy, reply, edit, delete, forward, pin, or react.
3. Repeat on a received message.

Expected results:
1. Only valid actions are shown for each message type and ownership state.
2. Action results are reflected immediately and correctly.

### CHAT-11 Multi-select, bulk actions, scheduled send, and input bar tools

- Priority: P2
- Platforms: Android, iOS
- Entry: Chat conversation
- Preconditions: Feature visible in current build

Steps:
1. Enter multi-select mode if available.
2. Select multiple messages.
3. Perform one allowed bulk action.
4. If scheduled send exists, schedule a message.
5. Exercise emoji, sticker, attachment, and voice-input tools if visible.

Expected results:
1. Multi-select selection state is stable.
2. Bulk actions apply only to eligible messages.
3. Scheduled send behaves as designed.

## 7.13 Groups, Contacts, Calls, and Social Chat Features

### CHAT-12 Group creation and group basics

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat > New Group
- Preconditions: At least three chat users available

Steps:
1. Create a group.
2. Add at least two members.
3. Send text and media messages in the group.
4. Rename the group.
5. Leave or remove a test member if the role allows it.

Expected results:
1. Group creation succeeds.
2. Membership and message flow are correct.
3. Group metadata updates are reflected to all members.

### CHAT-13 Group administration

- Priority: P2
- Platforms: Android, iOS
- Entry: Group settings
- Preconditions: Group with admin privileges

Steps:
1. Open group settings.
2. Test visible admin actions such as invite, promote, mute, pin, or change permissions.

Expected results:
1. Admin-only actions are protected correctly.
2. Permission changes take effect as expected.

### CHAT-14 Contacts

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat contacts area, if visible
- Preconditions: Multiple users available

Steps:
1. Add a contact.
2. Open the contact profile.
3. Start a conversation from the contact entry.
4. Remove or block the contact if the feature exists.

Expected results:
1. Contact add/remove state is accurate.
2. Conversation launch from contact works correctly.

### CHAT-15 Voice and video calls

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat conversation or call entry, if visible
- Preconditions: Call feature enabled, camera and microphone permission available

Steps:
1. Start a voice call.
2. Accept the call on the receiving device.
3. End the call.
4. Repeat once with video if supported.

Expected results:
1. Call invite, connect, mute, speaker, and end actions work correctly.
2. Permission prompts are correct and not repeated unnecessarily.

### CHAT-16 Moments, stories, or social feed

- Priority: P2
- Platforms: Android, iOS
- Entry: Social area, if visible in the current chat build
- Preconditions: Feature enabled

Steps:
1. Create a new post or story if supported.
2. View the post from another user.
3. Interact with available actions such as like, reply, or delete.

Expected results:
1. Content creation and consumption work correctly.
2. Privacy and visibility rules are honored.

### CHAT-17 Voice room or token-gated room

- Priority: P2
- Platforms: Android, iOS
- Entry: Voice room or token gate entry, if visible
- Preconditions: Feature enabled and required token state available if applicable

Steps:
1. Join a visible room.
2. Verify gating behavior if access depends on token ownership.
3. Leave the room.

Expected results:
1. Access control is correct.
2. Room join and leave are stable.

## 7.14 Chat Privacy, Security, Export, and Device Management

### CHAT-18 Chat lock and privacy settings

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat settings > privacy or lock settings
- Preconditions: Chat logged in

Steps:
1. Enable any chat-specific privacy lock if visible.
2. Exit Chat and re-enter it.
3. Verify privacy settings such as who can contact, view profile, or invite the user if present.

Expected results:
1. Chat lock behavior works as designed.
2. Privacy settings save and apply correctly.

### CHAT-19 End-to-end encryption and secure-session checks

- Priority: P2
- Platforms: Android, iOS
- Entry: Encrypted chat flow, if visible
- Preconditions: E2EE enabled for the environment

Steps:
1. Open an encrypted conversation.
2. Send a message.
3. Verify whether encryption state indicators and verification prompts work.

Expected results:
1. Encrypted chats still send and receive correctly.
2. Security indicators are accurate and understandable.

### CHAT-20 Multi-device session management

- Priority: P2
- Platforms: Android, iOS
- Entry: Chat session or device management, if visible
- Preconditions: Same chat account logged in on two devices

Steps:
1. Log in on device A.
2. Log in on device B.
3. Send and receive messages on both.
4. Log out one device from the session-management flow if possible.

Expected results:
1. Multi-device behavior matches product rules.
2. Forced logout or session revocation works correctly when available.

### CHAT-21 Chat search and global search

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat search
- Preconditions: Conversations contain searchable messages, users, and groups

Steps:
1. Search by keyword.
2. Search by user name.
3. Search by group name.
4. Open a result.

Expected results:
1. Search results are relevant and categorized correctly when the UI supports it.
2. Opening a result jumps to the correct target.

### CHAT-22 Chat export and history retention

- Priority: P2
- Platforms: Android, iOS
- Entry: Conversation settings or export action, if visible
- Preconditions: Export feature enabled

Steps:
1. Open the export entry.
2. Start an export.
3. Verify the exported result or completion state.

Expected results:
1. Export only includes the allowed scope.
2. Export completion or failure is clearly communicated.

## 7.15 Notifications, Settings, Theme, and Responsiveness

### UX-01 Push notifications

- Priority: P0
- Platforms: Android, iOS
- Entry: External push event
- Preconditions: Push configured; one logged-in receiving device

Steps:
1. Grant notification permission.
2. Send a chat message to the device while the app is backgrounded.
3. Tap the notification.
4. Repeat with the app killed.
5. Repeat once with notification permission denied.

Expected results:
1. Notification is received when permission is granted.
2. Tapping the notification routes to the correct chat destination.
3. Denied permission is handled gracefully without repeated spam prompts.

### UX-02 Theme and appearance

- Priority: P1
- Platforms: Android, iOS
- Entry: Settings > Theme
- Preconditions: Logged-in user

Steps:
1. Switch between available themes.
2. Reopen Wallet, Market, Earn, Chat, and Settings.
3. Relaunch the app.

Expected results:
1. Theme applies consistently across host app and embedded chat module.
2. Theme choice persists after relaunch.

### UX-03 Language and localization

- Priority: P1
- Platforms: Android, iOS
- Entry: Settings > Language
- Preconditions: At least two supported languages available

Steps:
1. Change the language.
2. Reopen Wallet, Chat, Settings, and one transaction-related screen.
3. Relaunch the app.

Expected results:
1. Visible language updates correctly.
2. No mixed-language critical UI remains in main flows.
3. Language choice persists after relaunch.

### UX-04 Currency and regional display rules

- Priority: P2
- Platforms: Android, iOS
- Entry: Settings or Market/Wallet display options
- Preconditions: Wallet with balances and token prices

Steps:
1. Change display currency if the build exposes the option.
2. Reopen Wallet and Market.

Expected results:
1. Fiat values update consistently.
2. No stale or mixed-currency values remain.

### UX-05 Settings and About

- Priority: P2
- Platforms: Android, iOS
- Entry: Drawer > Settings, Drawer > About
- Preconditions: App installed

Steps:
1. Open Settings and navigate through all visible sections.
2. Open About.
3. Verify app version, legal pages, and update-related information if visible.

Expected results:
1. All settings entries open correctly.
2. About page shows the correct build information.

### UX-06 Responsive layout and rotation

- Priority: P2
- Platforms: Android, iOS, tablet where applicable
- Entry: Main app and Chat
- Preconditions: Phone and tablet devices available

Steps:
1. Open the app on phone and tablet.
2. Rotate the device where rotation is supported.
3. Verify Wallet, Earn, Market, Chat, and the drawer/menu layout.

Expected results:
1. No clipped controls, overlapping text, or broken navigation appear.
2. Tablet layout and side navigation behave correctly.

## 7.16 Regression, Failure Handling, and Stability

### REG-01 End-to-end happy path regression

- Priority: P0
- Platforms: Android, iOS
- Preconditions: Fully configured test data

Run this minimum end-to-end path:

1. Log in
2. Open Wallet
3. Receive an address
4. Send a transaction
5. Open Chat
6. Send a text message
7. Open Browser
8. Complete one WalletConnect approval
9. Open Settings and About

Expected results:
1. No blocker exists in the main user journey.

### REG-02 Weak network and request retry behavior

- Priority: P1
- Platforms: Android, iOS
- Preconditions: Network throttling available

Steps:
1. Switch to a weak or unstable network.
2. Refresh Wallet, Market, Chat, and one media-upload or transaction flow.

Expected results:
1. Slow requests show loading and retry states appropriately.
2. The app never crashes because of transient network failure.

### REG-03 Background / foreground during sensitive flows

- Priority: P1
- Platforms: Android, iOS
- Preconditions: Any sensitive flow in progress

Steps:
1. Start transaction signing, media upload, WalletConnect approval, or chat login.
2. Background the app mid-flow.
3. Resume the app.

Expected results:
1. The app resumes safely.
2. Sensitive flows do not duplicate or corrupt state.

### REG-04 Long-session stability

- Priority: P2
- Platforms: Android, iOS
- Preconditions: Logged-in wallet and chat state

Steps:
1. Keep the app in use for an extended session.
2. Switch between Wallet, Chat, Market, Earn, and Browser repeatedly.
3. Monitor for memory pressure symptoms, blank views, or navigation breakage.

Expected results:
1. No obvious degradation, leak symptoms, or broken navigation appears during extended use.

### REG-05 Data integrity after repeated relaunch and account switching

- Priority: P1
- Platforms: Android, iOS
- Preconditions: At least two wallets and at least one chat account available

Steps:
1. Switch wallets multiple times.
2. Open Chat, then log out and log in again if allowed by the environment.
3. Relaunch the app several times.
4. Recheck active wallet, balances, unread counts, and settings.

Expected results:
1. Active wallet identity remains correct.
2. Chat unread counts and session state remain consistent.
3. Settings are not reset unexpectedly.

## 7.17 Additional Wallet Coverage

### WLT-11 Cloud backup, export backup, and recovery artifact validation

- Priority: P2
- Platforms: Android, iOS
- Entry: Wallet backup area, security area, or export-backup entry if visible
- Preconditions: Local wallet exists; backup or export feature is enabled in the build

Steps:
1. Open the wallet backup area.
2. Enter any export-backup or cloud-backup page exposed by the build.
3. Complete the flow up to the last safe test point or create an export artifact if the environment allows it.
4. Reopen the page and verify completion state, warnings, and reminder banners.
5. If import or restore from the exported artifact is supported in the target environment, validate it on a clean test wallet or secondary device.

Expected results:
1. Backup and export entry points open correctly.
2. Sensitive data is masked or gated behind secondary verification.
3. Exported artifacts can only be used through the supported restore flow.
4. Backup status and reminder state remain consistent after completion.

### WLT-12 Watch-only wallet creation and source validation

- Priority: P2
- Platforms: Android, iOS
- Entry: Wallet Management > Add Watch Wallet, if visible
- Preconditions: Public address, xpub, or other supported watch-only source available

Steps:
1. Open the add-watch-wallet flow.
2. Enter a valid supported source.
3. Finish the watch-only creation flow.
4. Reopen the wallet list and open the new watch-only wallet.
5. Confirm that only read-only actions are allowed.

Expected results:
1. Watch-only wallet creation succeeds for supported sources.
2. Invalid input is rejected clearly.
3. The created wallet is visibly marked as watch-only or read-only.

### WLT-13 Wallet password change and signing-password regression

- Priority: P1
- Platforms: Android, iOS
- Entry: Wallet Management > Edit Wallet Password, if visible
- Preconditions: Existing local wallet with a known current password

Steps:
1. Open the wallet password-change flow.
2. Enter an incorrect current password once and verify failure handling.
3. Enter the correct current password and a valid new password.
4. Save the change.
5. Reopen one signing-sensitive flow such as send or export backup and verify the new password works.
6. Confirm the old password no longer works.

Expected results:
1. Wrong current password is rejected safely.
2. Password change completes successfully.
3. Subsequent protected wallet actions require and accept only the new password.

### TX-08 Memo, tag, and chain-specific transfer validation

- Priority: P0
- Platforms: Android, iOS
- Entry: Send flow on any chain that requires or supports memo/tag behavior
- Preconditions: Wallet and recipient that require or use memo, destination tag, or chain-specific address format

Steps:
1. Start a send flow on a memo or tag sensitive chain.
2. Leave memo or tag empty when the destination requires it and try to continue.
3. Enter an invalid memo or tag format and try again.
4. Enter a valid memo or tag and proceed to the confirmation screen.
5. Review chain-specific warnings such as irreversible transfer notice or destination-tag reminder.

Expected results:
1. Required memo or tag fields are enforced correctly.
2. Invalid chain-specific data is blocked clearly.
3. Valid memo or tag input allows the flow to continue safely.

### TX-09 Transaction detail actions, copy behavior, and external explorer links

- Priority: P1
- Platforms: Android, iOS
- Entry: Transaction detail page
- Preconditions: At least one completed transaction exists

Steps:
1. Open a transaction detail page.
2. Copy the transaction hash.
3. Copy the sender or receiver address if copy actions are available.
4. Open the external explorer link.
5. Return to the app and verify navigation state remains intact.

Expected results:
1. Hash, addresses, status, fees, and timestamps are accurate.
2. Copy actions copy the expected value.
3. Explorer links open the correct chain explorer and transaction target.

### TX-10 Payment request history and receive-record validation

- Priority: P2
- Platforms: Android, iOS
- Entry: Payment Code / Payment History if visible
- Preconditions: Payment-request feature visible

Steps:
1. Open Payment Code and generate at least one fixed-amount request.
2. Generate another request with a different amount or note if supported.
3. Open payment history or receive-record history.
4. Verify ordering, amount, note, status, and recipient/request metadata.
5. Reopen one history item and verify share or copy behavior if present.

Expected results:
1. Payment requests are recorded correctly.
2. History ordering and detail data are accurate.
3. Share and copy actions work without mixing records.

### ADV-07 Portfolio analytics and holdings breakdown

- Priority: P2
- Platforms: Android, iOS
- Entry: Portfolio if visible
- Preconditions: Wallet with multiple non-zero assets

Steps:
1. Open Portfolio.
2. Verify total portfolio value, 24h PnL, and percentage display.
3. Review allocation chart, movers section, and holdings breakdown.
4. Reopen the page after refreshing wallet balances.

Expected results:
1. Portfolio totals are internally consistent.
2. Allocation and movers sections do not show broken or duplicated assets.
3. Holdings refresh when source wallet balances change.

### ADV-08 NFT gallery, filter, detail, and NFT send flow

- Priority: P2
- Platforms: Android, iOS
- Entry: NFT Gallery if visible
- Preconditions: Wallet with NFTs on a supported chain

Steps:
1. Open NFT Gallery.
2. Search and filter by at least one supported filter type.
3. Open an NFT detail page.
4. If NFT send is supported, proceed through the send flow until the last safe validation point or complete a test transfer in an approved environment.

Expected results:
1. NFT list loads the correct collection for the selected wallet and chain.
2. Search and filters work without duplicating assets.
3. NFT detail metadata and media preview render correctly.
4. NFT send, if supported, validates recipient and ownership correctly.

### ADV-09 Gas tracker, gas settings, and alert rules

- Priority: P2
- Platforms: Android, iOS
- Entry: Gas Tracker / Gas Settings if visible
- Preconditions: Supported gas-tracker environment available

Steps:
1. Open Gas Tracker.
2. Review current gas tiers, units, refresh behavior, and any chain selector.
3. Open gas settings or alert settings.
4. Configure one non-destructive rule or alert threshold.
5. Reopen the page and confirm the state is preserved.

Expected results:
1. Gas values load in the correct units.
2. Refresh updates values without layout issues.
3. Saved settings or alerts persist correctly.

### ADV-10 Market price alerts, trade journal, and external info links

- Priority: P2
- Platforms: Android, iOS
- Entry: Market > coin detail page
- Preconditions: Live market data available

Steps:
1. Open one coin detail page from Market.
2. Create or edit a price alert if the option is visible.
3. Create one trade-journal or buy-record entry if the option is visible.
4. Open one news, website, or explorer-style external link from the market detail page.

Expected results:
1. Coin detail data loads correctly.
2. Alert thresholds and trade records save and reopen correctly.
3. External links open the expected target without corrupting in-app navigation.

### ADV-11 Token discovery inbox and review workflow

- Priority: P2
- Platforms: Android, iOS
- Entry: Token Discovery if visible
- Preconditions: Wallet with discoverable tokens or discovery suggestions

Steps:
1. Open Token Discovery.
2. Review discovered token suggestions.
3. Add one suggested token.
4. Dismiss or ignore one suggestion if supported.
5. Refresh the wallet and the discovery page.

Expected results:
1. Discovery suggestions are relevant to the active wallet and chain.
2. Added tokens appear in the wallet without duplicates.
3. Dismissed items do not immediately return unless expected by product rules.

### ADV-12 Face binding and face verification for wallet-sensitive actions

- Priority: P2
- Platforms: Android, iOS
- Entry: Face Binding / Face Match if visible
- Preconditions: Supported device camera and face-verification feature enabled

Steps:
1. Open the face-binding or face-match entry.
2. Bind a face to a test wallet if the build supports it.
3. Start a wallet-sensitive action that uses face verification.
4. Complete one successful verification.
5. Retry once with cancel or failure handling.

Expected results:
1. Face enrollment and binding flow are stable.
2. Successful verification unlocks only the intended action.
3. Cancel or mismatch handling fails safely without bypassing verification.

## 7.18 Extended Chat Module Coverage

### CHAT-23 Add friend by Matrix ID, username, wallet address, or ENS

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat > Add Friend
- Preconditions: Searchable users and at least one wallet-address or ENS-backed identity available if Web3 identity resolution is visible

Steps:
1. Search by full Matrix ID.
2. Search by username or local identifier.
3. Search by wallet address if the build exposes Web3 identity search.
4. Search by ENS name if the build exposes ENS identity search.
5. Open one result and start a direct chat or send a friend request.

Expected results:
1. Supported identity formats are recognized correctly.
2. Search results map to the correct user identity.
3. Start-chat or add-friend action opens the correct next flow.

### CHAT-24 Friend requests, ignore or blocklist, and remark management

- Priority: P1
- Platforms: Android, iOS
- Entry: Contacts / Friend Requests / Contact Detail
- Preconditions: One pending request and one existing contact available if those states are supported

Steps:
1. Open the friend-request list.
2. Accept one request.
3. Reject one request.
4. Open a contact profile and edit the remark or alias.
5. Ignore or blocklist one user if the option is visible, then reverse it if policy allows.

Expected results:
1. Request state changes are reflected immediately.
2. Remark or alias updates appear in contacts and conversations.
3. Ignore or block state is enforced consistently across chat entry points.

### CHAT-25 Conversation list controls: pin, mute, hide, delete, and read state

- Priority: P1
- Platforms: Android, iOS
- Entry: Conversation list
- Preconditions: Multiple conversations with different unread states

Steps:
1. Long-press one conversation.
2. Pin or unpin it.
3. Mute or unmute it.
4. Hide, unhide, or move it to hidden chats if the option exists.
5. Delete one test conversation and mark another as read or unread if supported.
6. Relaunch the app and reopen the conversation list.

Expected results:
1. Conversation actions only appear when valid.
2. Pin, mute, hide, and delete state persist after relaunch.
3. Unread state and ordering remain consistent.

### CHAT-26 Chat folders, hidden chats, and favorites

- Priority: P2
- Platforms: Android, iOS
- Entry: Chat folder management, hidden chats, or favorites if visible
- Preconditions: Folder or hidden-chat features visible in the build

Steps:
1. Open chat-folder management.
2. Create or edit one folder if the feature allows it.
3. Add or classify at least one conversation.
4. Open hidden chats and unlock them if a lock is configured.
5. Open Favorites and verify at least one saved item if the module is visible.

Expected results:
1. Folder state is saved correctly.
2. Hidden chats remain protected and separate from the normal list.
3. Favorites open without broken navigation.

### CHAT-27 In-chat search, thread detail, pinned messages, typing, and poll flow

- Priority: P1
- Platforms: Android, iOS
- Entry: Existing chat room
- Preconditions: Room with searchable content and feature visibility for thread, pin, typing, or poll actions

Steps:
1. Search inside the room.
2. Open one search result and verify it jumps to the correct message.
3. Open or create a thread if thread UI is available.
4. Pin one message and unpin it again if permissions allow.
5. Verify typing status with a second user.
6. Create, vote on, and end a poll if the poll feature is visible.

Expected results:
1. Search results are relevant and route to the right message.
2. Thread view preserves context correctly.
3. Pin and poll actions are permission-aware and reflected to participants.

### CHAT-28 Static location, live location, GIF, sticker, and music-share flow

- Priority: P2
- Platforms: Android, iOS
- Entry: Chat > plus menu / attachment tools
- Preconditions: Location permission and media features available

Steps:
1. Send one static location.
2. Start one live-location share if the feature is visible.
3. Send one GIF.
4. Send one sticker from the picker or store if available.
5. Share one music card or local audio item if the feature is visible.

Expected results:
1. Location permission and map flows behave correctly.
2. Rich media renders in conversation without layout corruption.
3. Unsupported subfeatures fail gracefully instead of crashing.

### CHAT-29 QR flows: scan QR, My QR, and friend, room, or payment routing

- Priority: P1
- Platforms: Android, iOS
- Entry: Scan QR / My QR
- Preconditions: QR payloads available

Steps:
1. Open My QR and verify it displays correctly.
2. Scan one friend or contact QR.
3. Scan one room or group QR if supported.
4. Scan one payment or wallet-style QR if supported by the chat entry.

Expected results:
1. QR generation and scan camera entry work correctly.
2. Supported QR types route to the correct module.
3. Unsupported or malformed QR payloads fail gracefully.

### CHAT-30 Chat transfer, payment request, receive page, and red packet

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat plus menu > payment or wallet-related entry
- Preconditions: Wallet bridge enabled and funded test wallet available

Steps:
1. Open the chat transfer or payment flow.
2. Validate recipient address, token selection, and amount validation.
3. Create a payment request or open the receive page if visible.
4. Send one transfer or payment-related message in an approved test environment.
5. Send one normal or lucky red packet if the feature is visible.
6. Open the resulting message or detail entry again.

Expected results:
1. Wallet bridge data loads correctly inside chat.
2. Validation blocks invalid amount, token, or address input.
3. Transfer and red-packet messages render with correct metadata.

### CHAT-31 Profile edit, status, avatar, NFT avatar, username, and personal QR

- Priority: P2
- Platforms: Android, iOS
- Entry: Chat > Me / Profile
- Preconditions: Logged-in chat user

Steps:
1. Open the profile area.
2. Edit one profile field such as display name, bio, or signature if visible.
3. Set or clear a status message.
4. Change avatar from gallery and test NFT avatar if the entry is visible.
5. Open set-username flow if available.
6. Open personal QR page.

Expected results:
1. Profile updates save and reload correctly.
2. Avatar and status changes appear across chat surfaces where expected.
3. Personal QR opens without broken profile state.

### CHAT-32 Chat settings: notifications, privacy, appearance, language, background, quick replies, and translation

- Priority: P1
- Platforms: Android, iOS
- Entry: Chat > Settings
- Preconditions: Logged-in chat user

Steps:
1. Open Settings and visit each visible section.
2. Change one notification-related option.
3. Change one privacy-related option.
4. Change one appearance, language, or background option.
5. Add or edit one quick reply if the feature is visible.
6. Change one translation-related option if the feature is visible.
7. Return to conversations and a chat room to verify the new settings take effect.

Expected results:
1. All visible settings pages open correctly.
2. Changed settings persist after navigation and relaunch.
3. UI text, background, and translation state remain consistent.

### CHAT-33 Storage management, auto-download, backup and restore, and export artifacts

- Priority: P2
- Platforms: Android, iOS
- Entry: Chat > Settings > Storage / Auto-Download / Backup & Restore
- Preconditions: Media-heavy account preferred

Steps:
1. Open storage management and review total usage.
2. Open one per-room or media-category detail page if available.
3. Clear one safe cache or media subset.
4. Open auto-download settings and change one rule.
5. Open backup and restore entry points and reach the last safe step.

Expected results:
1. Storage figures are readable and navigation is stable.
2. Cache-clearing or cleanup actions only remove the intended data.
3. Auto-download and backup settings save correctly.

### CHAT-34 Connected accounts and bridge-account management

- Priority: P2
- Platforms: Android, iOS
- Entry: Chat > Settings > Connected Accounts, if visible
- Preconditions: One bridge-capable external account available

Steps:
1. Open Connected Accounts.
2. Review visible providers and current link state.
3. Connect one provider if safe in the environment, or verify an already-linked account.
4. Disconnect and reconnect if the flow is supported and safe.

Expected results:
1. Provider status is shown accurately.
2. Link and unlink flows return the user to the correct settings state.
3. Failed provider callbacks do not trap the user in a broken state.

### CHAT-35 Moments or stories: create, visibility, view, interact, and delete

- Priority: P2
- Platforms: Android, iOS
- Entry: Discover > Moments / Stories, or Profile > Moments
- Preconditions: Module visible; two test users available

Steps:
1. Create a moment or story with text, image, or video if supported.
2. Set or review visibility options if available.
3. View the content from another user.
4. Add one interaction such as reply, comment, or reaction if supported.
5. Delete the content or verify expiry behavior.

Expected results:
1. Publish flow completes correctly.
2. Visibility rules are honored.
3. Interaction counts and read state update as expected.

### CHAT-36 Spaces, communities, channels, and group media hub

- Priority: P2
- Platforms: Android, iOS
- Entry: Discover > Communities / Channels, or group media-related entry
- Preconditions: Space, community, or channel data available

Steps:
1. Open Communities or Spaces.
2. Enter one space or community.
3. Open one channel or channel-discovery page if visible.
4. Open one group media hub or room media page if visible.
5. Verify navigation back to Discover and Chat remains stable.

Expected results:
1. Space or community lists load correctly.
2. Channel or media-hub pages open with the correct room context.
3. Deep navigation does not break the back stack.

### CHAT-37 Voice rooms and moderator actions

- Priority: P2
- Platforms: Android, iOS
- Entry: Voice room list / room page if visible
- Preconditions: Voice-room module enabled; multiple accounts available

Steps:
1. Open voice-room list.
2. Join or create one room.
3. Raise hand if the role starts as listener.
4. Approve one speaker or demote one speaker if moderator controls are available.
5. Toggle mute, leave the room, and end the room if the role allows it.

Expected results:
1. Room join and leave behavior is stable.
2. Listener and speaker state transitions are reflected correctly.
3. Moderator-only actions are permission-protected.

### CHAT-38 AI assistant and AI settings

- Priority: P2
- Platforms: Android, iOS
- Entry: AI Assistant if visible
- Preconditions: AI assistant enabled for the environment

Steps:
1. Open AI Assistant.
2. Submit one prompt.
3. Verify response rendering, scroll behavior, and retry handling if available.
4. Open AI settings and change one safe setting.
5. Return to AI Assistant and verify the setting takes effect if applicable.

Expected results:
1. AI entry and settings pages open correctly.
2. Prompt-response flow is readable and stable.
3. Settings are saved without corrupting session state.

### CHAT-39 On-chain notifications, points dashboard, leaderboard, and redemption

- Priority: P2
- Platforms: Android, iOS
- Entry: Notification bell, points dashboard, or points-related pages if visible
- Preconditions: On-chain event or points-enabled account available

Steps:
1. Open on-chain notifications and verify list, badge, and read state.
2. Open one notification detail if applicable.
3. Open points dashboard and leaderboard.
4. Open redemption page and redeem one safe item if the account is eligible.

Expected results:
1. Notification counts and read state are accurate.
2. Points balance, leaderboard, and redemption items load correctly.
3. Redemption is permitted only when eligibility rules are met.

### CHAT-40 Discover-only modules: mini apps, games, services, orders or cards, and sticker store

- Priority: P2
- Platforms: Android, iOS
- Entry: Discover / Profile-only module entries if visible
- Preconditions: Related modules visible

Steps:
1. Open each visible module such as mini apps, games, services, orders/cards, or sticker store.
2. Verify list loading, empty states, and detail navigation.
3. Install, select, or preview one safe item if the feature allows it.
4. Return to the previous page and confirm back navigation works correctly.

Expected results:
1. Each visible module opens and renders correctly.
2. Empty and loaded states are both handled cleanly.
3. Back navigation returns to the correct originating page.

### CHAT-41 SAS or emoji device verification

- Priority: P2
- Platforms: Android, iOS
- Entry: Security verification / E2EE verification UI if visible
- Preconditions: E2EE verification enabled and a second device available

Steps:
1. Start a device-verification flow.
2. Compare emoji or SAS values on both devices.
3. Approve once.
4. Repeat and cancel once.

Expected results:
1. Verification values match across devices on the success path.
2. Successful verification updates trusted-device state.
3. Cancel flow exits safely without leaving the UI stuck.

## 8. Optional Feature Execution Notes

Mark the following modules as `N/A` if they are not visible or not enabled in the target build:

- Apple login
- Facebook login
- Twitter login
- WeChat login
- Smart Account / AA
- Hardware Wallet
- Portfolio
- NFT Gallery / NFT Send
- Gas Tracker / Gas Alerts
- Price Alerts / Trade Journal
- Face Matching / Face Binding
- Cloud Backup / Export Backup
- Bridge
- Staking
- BTC staking
- Mining
- Loyalty
- Airdrop
- Voice / video calls
- Stories / moments / voice rooms
- Token Gate
- Chat export
- Chat lock
- Chat folders / hidden chats
- Chat translation / quick replies / backup & restore
- Connected Accounts / Bridges
- AI Assistant
- Points / Leaderboard / Redemption
- Mini Apps / Games / Communities / Channels
- E2EE verification UI
- Multi-device management

If the current build explicitly shows a `Feature in development` message, a disabled backend-dependent control, or a hidden route with no visible entry point, mark the module as `N/A` unless release scope explicitly includes it. Current codebase examples include some Discover subfeatures, coupon or gift sending, and some profile or group sub-actions.

## 9. Defect Reporting Template

Use the following format for every failed case:

```text
Case ID:
Title:
Environment:
Device / OS:
App Build:
Priority:
Preconditions:
Steps to Reproduce:
Expected Result:
Actual Result:
Reproducibility:
Evidence:
Extra Data:
```

## 10. Final Release Checklist

Before sign-off, confirm:

1. All P0 cases passed on both Android and iOS.
2. Wallet creation, import, send, receive, payment code, and history were validated on critical chains.
3. Chain-specific validation such as memo or tag rules was exercised where applicable.
4. Portfolio, NFT, gas, alerts, and backup-related modules were validated when visible in the build.
5. Chat login, direct message, group message, QR routing, and notification tap handling were validated.
6. Conversation controls, search, profile, settings, storage, and wallet-bridge chat flows were validated when visible.
7. Browser, WalletConnect, DApp safety checks, and anti-phishing protections were validated.
8. Theme, language, and main settings were validated across host app and chat module.
9. No unresolved blocker remains for security, transaction integrity, wallet data, or chat session handling.

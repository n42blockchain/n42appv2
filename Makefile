.PHONY: run run-android run-ios test setup build-android build-ipa

# ── Daily development ──────────────────────────────────────────────────────────

## flutter run (debug) with auto build-number bump
run:
	@./scripts/bump_version.sh
	flutter run

## explicitly target Android
run-android:
	@./scripts/bump_version.sh
	flutter run -d android

## explicitly target iOS
run-ios:
	@./scripts/bump_version.sh
	flutter run -d ios

## run unit tests with auto build-number bump
test:
	@./scripts/bump_version.sh
	flutter test

# ── Release builds ─────────────────────────────────────────────────────────────

## build Android APK (no build-number bump; use build_ipa.sh for iOS)
build-android:
	flutter build apk

## build & upload iOS IPA to TestFlight (see scripts/build_ipa.sh)
build-ipa:
	./scripts/build_ipa.sh

# ── Project setup ──────────────────────────────────────────────────────────────

## install git hooks (run once after cloning)
setup:
	@chmod +x scripts/bump_version.sh
	@chmod +x .githooks/pre-commit
	@git config core.hooksPath .githooks
	@echo "Git hooks installed. build-number will auto-increment on every commit."

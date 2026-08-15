.PHONY: run run-android run-ios test check setup build-android build-ipa

# ── Daily development ──────────────────────────────────────────────────────────

# debug 运行也要吃 .env：此前 run/run-android/run-ios 是裸 flutter run，
# 零 dart-define——AI_API_KEY 等必空，chat 的 AI 功能族 7 处入口、GIF、
# STT 等 key 门控功能在 debug/测试包里整体隐藏，曾被误判为"功能消失"。
# Flutter ≥3.17 的 --dart-define-from-file 直接支持 .env 格式。
ENV_DEFINES := $(shell [ -f .env ] && echo "--dart-define-from-file=.env")

## flutter run (debug) with auto build-number bump
run:
	@./scripts/bump_version.sh
	flutter run $(ENV_DEFINES)

## explicitly target Android
run-android:
	@./scripts/bump_version.sh
	flutter run -d android $(ENV_DEFINES)

## explicitly target iOS
run-ios:
	@./scripts/bump_version.sh
	flutter run -d ios $(ENV_DEFINES)

## run unit tests with auto build-number bump
test:
	@./scripts/bump_version.sh
	flutter test

# 提交前守门：静态分析零 error + 全量测试（不 bump 版本号）
check:
	flutter analyze --no-fatal-infos
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

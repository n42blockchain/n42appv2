# Chat sticker asset compatibility

The pinned `n42_chat` Git dependency loads built-in stickers using root asset
keys (`assets/stickers/...`) in its picker, thumbnails, and Matrix upload path.
Flutter bundles dependency assets under `packages/n42_chat/assets/stickers/...`,
so the host also declares these unchanged copies at the root keys the package
currently requests.

Copied from resolved `n42_chat` revision
`1686066d278a784e96d4700dd0f7e3ccd00f5caf`. The original attribution and license
files are preserved in each directory.

When updating `n42_chat`, copy both sticker directories from the package location
resolved in `.dart_tool/package_config.json` after `flutter pub get`. Do not use
the repository's cache mirror as the source. Verify with:

```sh
flutter test test/features/chat/bundled_sticker_assets_test.dart
```

The test loads every sticker at the same key used for display and upload and
compares its bytes with the resolved dependency, then exercises the real picker
and thumbnails for all built-in packs. Remove this compatibility layer once the
dependency uses package-qualified asset keys throughout rendering and upload.

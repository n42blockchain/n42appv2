# Dependency resolver snapshot

Captured 2026-10-04 with Flutter 3.44.8 / Dart 3.12.2. The host command was `flutter pub outdated --json`; the Chat command was `dart pub outdated --json` in the Chat checkout at `b976317565e46bf2f6f65e96ac05bc8d28322047`. The host pins Chat to the merged PR #2 commit `a24058de8849ab2322d743458e88c60d2f042790`.

| Package graph | Kind | Count | Newer upgradable | Newer resolvable | Newer latest |
| --- | --- | ---: | ---: | ---: | ---: |
| Host | Direct | 23 | 2 | 4 | 22 |
| Host | Dev | 8 | 0 | 2 | 8 |
| Host | Transitive | 60 | 3 | 7 | 60 |
| Chat | Direct | 65 | 47 | 64 | 65 |
| Chat | Dev | 10 | 7 | 10 | 10 |
| Chat | Transitive | 157 | 117 | 141 | 157 |

“Upgradable” follows the current manifest constraints. “Resolvable” uses the current package graph and SDK. “Latest” can require constraint changes, API migrations, or platform work. These counts do not mean each package should be updated without compatibility review. The snapshots show that the request to upgrade all dependencies remains open.

Compressed Pub JSON snapshots: `host-pub-outdated-20261004.json.gz` and `chat-pub-outdated-20261004.json.gz`.

# simple_html_css 5.0.0 XML 7 compatibility source

This directory contains the published simple_html_css 5.0.0 runtime `lib/`, its Apache 2.0 license and pubspec. The optional upstream README is omitted. The official pub.dev archive SHA-256 is `93bc59c0565e943abf6674e932f3f8b77bf87290a4f6f3f364c05fad26feb9d7`, as recorded in the original host lockfile. Its source is `https://pub.dev/packages/simple_html_css/versions/5.0.0`.

Only the XML dependency constraint changes from `^6.5.0` to `^7.0.1`. The runtime source and its copyright notices are unchanged. The host tests exercise nested styling, links/entities, line breaks, self-closing and malformed tags, prefixed tags, and the separate RSS parser. This compatibility package can be removed when an official simple_html_css release supports XML 7 with equivalent behavior.

`UPSTREAM_FILES_SHA256.json` lists the pristine upstream SHA-256 of every retained file (7 files). `N42_PATCH.diff.gz` is a unified patch relative to the package root; decompress with `gzip -dc N42_PATCH.diff.gz`. It contains only the manifest constraint change. The compressed patch SHA-256 is `675a10ac941d7a76f8a0e47803b5448283701886670403b6d404a81c315f32a3`.

# fl_chart 1.2.0 compatibility source

This directory contains the published fl_chart 1.2.0 runtime `lib/` and its MIT license. The optional upstream README and development assets are omitted. The official pub.dev archive SHA-256 is `b938f77d042cbcd822936a7a359a7235bad8bd72070de1f827efc2cc297ac888`, as recorded in the original host lockfile. Its source is `https://pub.dev/packages/fl_chart/versions/1.2.0`.

The local change replaces `EquatableMixin` with Equatable 3's `Equatable` mixin in nine runtime files and updates the dependency constraint to `^3.0.0`. Equatable 3 removed `EquatableMixin`; its `Equatable` declaration supports `with Equatable` and retains the `props`, equality, hash, and stringify contract used here. The published package's examples, test fixtures, screenshots and development dependencies are omitted from this runtime package. The full MIT notice is in `LICENSE`.

This compatibility package can be removed when an official fl_chart release supports Equatable 3 and the host's chart equality/rendering regressions pass against it.

`UPSTREAM_FILES_SHA256.json` lists the pristine upstream SHA-256 of every retained file (66 files). `N42_PATCH.diff.gz` is a unified patch with paths relative to the package root; decompress with `gzip -dc N42_PATCH.diff.gz`. It contains only the nine runtime substitutions and manifest narrowing. The compressed patch SHA-256 is `c39c1a623fecc109148c1b95326812a65c50449c22dce5d95459e9cd9cf74bb7`.

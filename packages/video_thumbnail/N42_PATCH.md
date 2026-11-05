# Video thumbnail Gradle 9 compatibility

Upstream 0.5.6 archive SHA-256: `181a0c205b353918954a881f53a3441476b9e301641688a581e0c13f00dc588b`.

Replace removed jcenter() with Maven Central and align AGP with the host.
The Dart SDK range reflects the tested host. Runtime Dart/Java/Objective-C logic is unchanged; published trailing whitespace
is normalized to satisfy repository diff checks. Example apps are omitted.

Tests use the current binding/channel and check file/data calls, dimensions, headers, seek and byte results.

# XML 7.1 resolver cap, 2026-09-27

The targeted XML 7.1 update could not resolve. Root `xml: ^7.1.0` conflicts
with Chat's SVG dependency chain:

```text
n42_chat (Git e71e59ea...) → flutter_svg ^2.2.4
  → vector_graphics_compiler ^1.1.14 → xml <=7.0.1
```

The normal Flutter3.47.5/Dart3.13.4 command
`flutter pub upgrade xml petitparser` exited 1 with that exact chain; see the
[raw solver log](pub-upgrade-solver-failure.log). It ran after changing only the
root XML constraint to `^7.1.0`. The temporary edit was restored, and
`pubspec.lock` did not change. No dependency override or compiler fork was
introduced. The retained lock SHA-256 is
`e1fd1ad94887adee5d0b5316c90201f2206c69fde4a8acc8c1cfc6fa29fc35da`:
XML 7.0.1, PetitParser 7.0.2, flutter_svg 2.3.0, and
vector_graphics_compiler 1.3.0 remain selected. Chat's immutable Git ref and
source mode remain unchanged.

The [latest stable vector_graphics_compiler 1.3.0 publisher manifest](https://pub.dev/api/packages/vector_graphics_compiler/versions/1.3.0)
declares `xml >=6.3.0 <=7.0.1`, and [flutter_svg 2.3.0](https://pub.dev/api/packages/flutter_svg)
still declares `vector_graphics_compiler ^1.1.14`. [XML 7.1.0](https://pub.dev/api/packages/xml/versions/7.1.0)
requires PetitParser `^7.1.0` and Dart `^3.13.0`; the selected Dart meets
that floor, but the SVG compiler cap blocks resolution. Publisher metadata
was checked read-only on 2026-09-27. This is a production transitive version
cap for the final dependency audit; package freshness metadata alone does not
prove a resolvable host graph.

Before the attempted update, the three existing RSS/XML/HTML fixture files
passed 17/17 under unchanged XML 7.0.1: [baseline test log](baseline-tests.log).
That baseline does not establish XML 7.1 behavior. No XML 7.1 analysis,
native build, or runtime result is claimed. Revisit when the official compiler
supports XML 7.1 or a separately scoped maintained compiler migration passes
source and behavior review.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureType, DisplayFeatureState;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Keeps the same navigator alive as a scene resizes or crosses a display fold.
/// UIKit reports regions in this Flutter view's logical coordinate space.
class AdaptiveViewport extends StatefulWidget {
  const AdaptiveViewport({super.key, required this.child});

  final Widget child;

  @override
  State<AdaptiveViewport> createState() => _AdaptiveViewportState();
}

class _AdaptiveViewportState extends State<AdaptiveViewport> {
  static const _channel = MethodChannel('ai.n42.www/viewport');
  Size? _nativeSize;
  List<DisplayFeature> _regions = const [];

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'regionsChanged') _updateRegions(call.arguments);
      });
      unawaited(_readRegions());
    }
  }

  Future<void> _readRegions() async {
    try {
      _updateRegions(await _channel.invokeMethod<Object?>('getRegions'));
    } on MissingPluginException {
      // Older hosts and non-iOS entry points still resize through MediaQuery.
    } on PlatformException {
      // Geometry is optional; normal safe areas remain in effect.
    }
  }

  void _updateRegions(Object? arguments) {
    if (!mounted || arguments is! Map) return;
    final width = arguments['width'];
    final height = arguments['height'];
    final regions = arguments['regions'];
    if (width is! num || height is! num || regions is! List) return;
    final size = Size(width.toDouble(), height.toDouble());
    if (!size.width.isFinite || !size.height.isFinite || size.isEmpty) return;
    final features = <DisplayFeature>[];
    for (final region in regions) {
      if (region is! Map) continue;
      final x = region['x'];
      final y = region['y'];
      final w = region['width'];
      final h = region['height'];
      if (x is! num || y is! num || w is! num || h is! num) continue;
      final rect = Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        w.toDouble(),
        h.toDouble(),
      );
      if (!rect.isFinite || rect.isEmpty) continue;
      features.add(
        DisplayFeature(
          bounds: rect,
          type: region['kind'] == 'division'
              ? DisplayFeatureType.hinge
              : DisplayFeatureType.cutout,
          state: DisplayFeatureState.unknown,
        ),
      );
    }
    setState(() {
      _nativeSize = size;
      _regions = features;
    });
  }

  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _channel.setMethodCallHandler(null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Never apply an old display's frames during a fold/resize transition.
    final nativeMatches =
        _nativeSize != null &&
        (_nativeSize!.width - media.size.width).abs() < 1 &&
        (_nativeSize!.height - media.size.height).abs() < 1;
    final features = [...media.displayFeatures, if (nativeMatches) ..._regions];
    final viewport = usableViewport(
      media.size,
      features,
      bottomInset: media.viewInsets.bottom,
    );
    final insets = EdgeInsets.fromLTRB(
      viewport.left,
      viewport.top,
      media.size.width - viewport.right,
      media.size.height - viewport.bottom,
    );
    EdgeInsets remaining(EdgeInsets value) => EdgeInsets.fromLTRB(
      math.max(0, value.left - insets.left),
      math.max(0, value.top - insets.top),
      math.max(0, value.right - insets.right),
      math.max(0, value.bottom - insets.bottom),
    );
    return Padding(
      padding: insets,
      child: MediaQuery(
        data: media.copyWith(
          size: viewport.size,
          padding: remaining(media.padding),
          viewPadding: remaining(media.viewPadding),
          viewInsets: remaining(media.viewInsets),
          displayFeatures: [
            for (final feature in features)
              if (feature.bounds.overlaps(viewport))
                DisplayFeature(
                  bounds: feature.bounds
                      .intersect(viewport)
                      .shift(-viewport.topLeft),
                  type: feature.type,
                  state: feature.state,
                ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Active folds displace interactive content into one uninterrupted region.
/// Flat displays retain their full width, including Chat's two-column layout.
@visibleForTesting
Rect usableViewport(
  Size size,
  List<DisplayFeature> features, {
  double bottomInset = 0,
}) {
  var viewport = Offset.zero & size;
  for (final feature in features) {
    if (feature.type != DisplayFeatureType.hinge &&
        feature.type != DisplayFeatureType.fold) {
      continue;
    }
    final fold = feature.bounds.intersect(viewport);
    if (!fold.isFinite) continue;
    if (fold.height >= viewport.height / 2 &&
        fold.height > fold.width &&
        fold.left > viewport.left &&
        fold.right < viewport.right) {
      // Prefer the trailing pane, matching UIKit's alert displacement.
      viewport = Rect.fromLTRB(
        fold.right,
        viewport.top,
        viewport.right,
        viewport.bottom,
      );
    } else if (fold.width >= viewport.width / 2 &&
        fold.width > fold.height &&
        fold.top > viewport.top &&
        fold.bottom < viewport.bottom) {
      // Use the lower region for controls, unless a keyboard fills it.
      final keyboardLeavesSpace =
          viewport.bottom - fold.bottom - bottomInset >= 240;
      viewport = keyboardLeavesSpace || bottomInset == 0
          ? Rect.fromLTRB(
              viewport.left,
              fold.bottom,
              viewport.right,
              viewport.bottom,
            )
          : Rect.fromLTRB(
              viewport.left,
              viewport.top,
              viewport.right,
              fold.top,
            );
    }
  }
  return viewport;
}

/// Legacy 750px designs keep phone-sized controls on expanded scenes. Scaling
/// is continuous at layout breakpoints and doesn't grow in landscape.
class AdaptiveScreenUtil extends StatelessWidget {
  const AdaptiveScreenUtil({super.key, required this.builder});

  final ScreenUtilInitBuilder builder;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = math.max(1.0, media.size.width);
    final scale = math.min(width, 375.0) / 750;
    final designSize = Size(
      width / scale,
      math.max(1.0, media.size.height) / scale,
    );
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: false,
      rebuildFactor: RebuildFactors.change,
      builder: (context, child) {
        // ScreenUtilInit reads the platform view; use this scene's usable pane.
        ScreenUtil.configure(
          data: media,
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: false,
        );
        return builder(context, child);
      },
    );
  }
}

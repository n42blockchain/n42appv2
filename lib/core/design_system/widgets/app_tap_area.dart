import 'package:flutter/material.dart';

import '../app_touch.dart';

/// A tap target of at least [AppTouch.minTarget] around a visual that must
/// stay small (an icon, a text link, a pill).
///
/// The child is centered inside the larger hit area and is not resized. The
/// ink response is drawn on a transparent [Material], so the pressed state
/// stays visible on colored backgrounds. Give icon-only children a
/// [tooltip] (also the screen-reader label) or a [semanticLabel].
class AppTapArea extends StatelessWidget {
  const AppTapArea({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.tooltip,
    this.semanticLabel,
    this.minSize,
    this.borderRadius,
    this.customBorder,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Long-press tooltip; also announced by screen readers.
  final String? tooltip;

  /// Screen-reader label when no [tooltip] is shown.
  final String? semanticLabel;

  /// Minimum hit size; defaults to [AppTouch.target] (44pt+).
  final double? minSize;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;

  @override
  Widget build(BuildContext context) {
    final min = minSize ?? AppTouch.target;
    Widget result = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        customBorder: customBorder,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: min, minHeight: min),
          child: Center(widthFactor: 1, heightFactor: 1, child: child),
        ),
      ),
    );
    if (semanticLabel != null && tooltip == null) {
      result = Semantics(
        button: true,
        enabled: onTap != null,
        label: semanticLabel,
        onTap: onTap,
        excludeSemantics: true,
        child: result,
      );
    }
    if (tooltip != null) {
      result = Tooltip(message: tooltip!, child: result);
    }
    return result;
  }
}

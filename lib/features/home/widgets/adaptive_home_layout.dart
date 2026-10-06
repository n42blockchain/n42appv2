import 'package:flutter/material.dart';

import 'package:n42_wallet/core/utils/responsive_utils.dart';

/// Changes navigation placement without reparenting the stateful tab content.
class AdaptiveHomeLayout extends StatelessWidget {
  const AdaptiveHomeLayout({
    super.key,
    required this.content,
    required this.sideNavigation,
    required this.bottomNavigation,
  });

  final Widget content;
  final Widget sideNavigation;
  final Widget bottomNavigation;

  @override
  Widget build(BuildContext context) {
    final side = ResponsiveUtils.useSideNavigation(context);
    return Stack(
      children: [
        Row(
          children: [
            SizedBox(width: side ? 88 : 0, child: side ? sideNavigation : null),
            Expanded(child: content),
          ],
        ),
        if (!side)
          Positioned(bottom: 0, left: 0, right: 0, child: bottomNavigation),
      ],
    );
  }
}

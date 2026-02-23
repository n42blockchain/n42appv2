import 'package:flutter/material.dart';

/// Widget that preserves its state in a TabView by mixing in AutomaticKeepAliveClientMixin.
class KeepStateWidget extends StatefulWidget {
  final Widget child;
  final bool wantKeepAlive;

  const KeepStateWidget({
    required this.child,
    this.wantKeepAlive = true,
    super.key,
  });

  @override
  State<KeepStateWidget> createState() => _KeepStateWidgetState();
}

class _KeepStateWidgetState extends State<KeepStateWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.wantKeepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

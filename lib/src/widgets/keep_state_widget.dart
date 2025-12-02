import 'package:flutter/material.dart';

class KeepStateWidget extends StatefulWidget {
  final Widget child;
  final bool wantKeepAlive;
  const KeepStateWidget({required this.child, required this.wantKeepAlive,super.key});

  @override
  State<KeepStateWidget> createState() => _KeepStateWidgetState();
}

class _KeepStateWidgetState extends State<KeepStateWidget> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}

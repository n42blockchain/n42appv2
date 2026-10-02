import 'package:flutter/material.dart';

//自定义
Future<dynamic> tipsDialog3(
  BuildContext context,
  Widget child, {
  bool awaitDismissal = false,
}) async {
  ModalRoute<dynamic>? route;
  final result = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      route = ModalRoute.of(context);
      return AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: child,
        ),
      );
    },
  );
  // Caller-owned controllers remain attached during the reverse transition.
  if (awaitDismissal) await route?.completed;
  return result;
}

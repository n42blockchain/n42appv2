import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Host-rendered AuthenticationServices control. The native control owns the
/// logo, localized title and style; the existing Chat handler owns sign-in.
class NativeAppleSignInButton extends StatefulWidget {
  const NativeAppleSignInButton({super.key, required this.onPressed});
  final VoidCallback? onPressed;

  @override
  State<NativeAppleSignInButton> createState() =>
      _NativeAppleSignInButtonState();
}

class _NativeAppleSignInButtonState extends State<NativeAppleSignInButton> {
  MethodChannel? _channel;

  @override
  void didUpdateWidget(NativeAppleSignInButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.onPressed == null) != (widget.onPressed == null)) {
      _updateEnabled();
    }
  }

  Future<void> _updateEnabled() async {
    try {
      await _channel?.invokeMethod<void>(
        'setEnabled',
        widget.onPressed != null,
      );
    } on PlatformException {
      // A replaced native view may already be disposing. Dart still gates taps.
    } on MissingPluginException {
      // The old platform view may have been removed during a theme change.
    }
  }

  void _created(int id) {
    if (!mounted) return;
    _channel?.setMethodCallHandler(null);
    _channel = MethodChannel('n42.wallet/apple_sign_in_button/$id');
    _channel!.setMethodCallHandler((call) async {
      if (call.method == 'pressed' && mounted) widget.onPressed?.call();
    });
    _updateEnabled();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 44,
      child: UiKitView(
        key: ValueKey(dark),
        viewType: 'n42.wallet/apple_sign_in_button',
        creationParams: {'dark': dark, 'enabled': widget.onPressed != null},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _created,
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:n42_wallet/generated/l10n.dart';

class Loading extends StatelessWidget {
  final String? text;
  final Color? textColor;

  const Loading({super.key, this.text, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(animating: true, radius: 18),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text ?? "${S.of(context).g_key_106}...",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: textColor ?? const Color(0xff666666), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
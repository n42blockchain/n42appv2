import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SwitchWidget extends StatefulWidget {
  final bool isSwitched;
  final ValueChanged<bool> onChanged;
  const SwitchWidget({required this.isSwitched, required this.onChanged,super.key});

  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.7,
      child: CupertinoSwitch(
          value: widget.isSwitched,
          ///关闭时颜色
          trackColor:  Colors.grey,
          ///打开时颜色
          activeTrackColor: Colors.blueAccent,
          ///圆形小按钮颜色
          thumbColor: Colors.white,
          onChanged: (bool val) {
            widget.onChanged(val);
          }
      ),
    );
  }
}

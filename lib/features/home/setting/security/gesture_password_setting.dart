// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/features/home/widgets/gesture_password/gesture_password.dart';
import 'package:n42_wallet/features/home/widgets/gesture_password/gesture_pattern_strength.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_1.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GesturePasswordSetting extends StatefulWidget {
  final int type; // 0: new password, 1: reset password
  final String? oldPassword;
  const GesturePasswordSetting(this.type, {this.oldPassword, super.key});
  @override
  GesturePasswordSettingState createState() => GesturePasswordSettingState();
}

class GesturePasswordSettingState extends State<GesturePasswordSetting> {
  /// Strength from the most recent first-draw completion.
  /// Cleared when advancing past the first-draw step.
  PatternStrength? _currentStrength;

  Map<String, dynamic> cachedData = {
    // type=0: new password
    "0": {
      "1": "", // first draw
      "2": "", // confirmation draw
      "errorCount": 0,
      "index": "1",
    },
    // type=1: reset password
    "1": {
      "1": {
        "old": "", // old password (populated from widget.oldPassword)
        "errorCount": 0,
      },
      "2": "", // new password first draw
      "3": "", // new password confirmation
      "errorCount": 0,
      "index": "1",
    }
  };

  @override
  void initState() {
    super.initState();
    if (widget.type == 1) {
      cachedData["1"]["1"]["old"] = widget.oldPassword;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────

  /// Returns true when the user is on the first-draw step of a new password.
  bool get _isFirstDrawStep {
    if (widget.type == 0) return cachedData['0']['index'] == "1";
    if (widget.type == 1) return cachedData['1']['index'] == "2";
    return false;
  }

  List<int> _parsePoints(String value) =>
      value.split(',').map(int.parse).toList();

  // ────────────────────────────────────────────────────────────────────────
  // Gesture callback
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _onGestureComplete(String value) async {
    if (widget.type == 0) {
      await _handleType0(value);
    } else {
      await _handleType1(value);
    }
  }

  Future<void> _handleType0(String value) async {
    if (cachedData['0']['index'] == "1") {
      // ── First draw: check strength ──────────────────────────────────────
      final strength = GesturePatternStrength.evaluate(_parsePoints(value));
      if (strength == PatternStrength.weak) {
        setState(() => _currentStrength = strength);
        return; // block advancing — user must redraw
      }
      setState(() {
        _currentStrength = null; // clear on advance
        cachedData['0']["1"] = value;
        cachedData['0']["index"] = "2";
      });
    } else {
      // ── Confirmation draw ───────────────────────────────────────────────
      if (value == cachedData['0']["1"]) {
        setState(() => cachedData['0']["2"] = value);
        Navigator.pop(context, value);
      } else {
        cachedData['0']["errorCount"] = cachedData['0']["errorCount"] + 1;
        if (cachedData['0']["errorCount"] == 3) {
          final flag =
              await tipsDialog1(context, S.of(context).g_lock_key23);
          if (!mounted) return;
          if (flag != null && flag) {
            setState(() {
              cachedData['0']["index"] = "1";
              cachedData['0']["errorCount"] = 0;
              cachedData['0']["1"] = "";
              _currentStrength = null;
            });
            return;
          }
        }
        setState(() {});
      }
    }
  }

  Future<void> _handleType1(String value) async {
    final String index = cachedData['1']['index'];

    if (index == "1") {
      // ── Verify old password ─────────────────────────────────────────────
      if (cachedData['1']["1"]["old"] == value) {
        setState(() => cachedData['1']["index"] = "2");
      } else {
        cachedData['1']["1"]["errorCount"] =
            cachedData['1']["1"]["errorCount"] + 1;
        if (cachedData['1']["1"]["errorCount"] == 3) {
          final flag =
              await tipsDialog1(context, S.of(context).g_lock_key23);
          if (!mounted) return;
          if (flag != null && flag) {
            setState(() => cachedData['1']["1"]["errorCount"] = 0);
            Navigator.pop(context);
            return;
          }
        }
        setState(() {});
      }
    } else if (index == "2") {
      // ── New password first draw: check strength ─────────────────────────
      final strength = GesturePatternStrength.evaluate(_parsePoints(value));
      if (strength == PatternStrength.weak) {
        setState(() => _currentStrength = strength);
        return; // block advancing — user must redraw
      }
      setState(() {
        _currentStrength = null; // clear on advance
        cachedData['1']["2"] = value;
        cachedData['1']["index"] = "3";
      });
    } else {
      // ── New password confirmation draw ──────────────────────────────────
      if (value == cachedData['1']["2"]) {
        setState(() => cachedData['1']["3"] = value);
        Navigator.pop(context, value);
      } else {
        cachedData['1']["errorCount"] = cachedData['1']["errorCount"] + 1;
        if (cachedData['1']["errorCount"] == 3) {
          final flag =
              await tipsDialog1(context, S.of(context).g_lock_key23);
          if (!mounted) return;
          if (flag != null && flag) {
            setState(() {
              cachedData['1']["index"] = "2"; // back to new-password draw
              cachedData['1']["errorCount"] = 0;
              cachedData['1']["2"] = "";
              _currentStrength = null;
            });
            return;
          }
        }
        setState(() {});
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.type == 0
            ? S.of(context).g_lock_key16
            : S.of(context).g_lock_key22,
      ),
      body: gesturePasswordWidget(),
    );
  }

  Widget gesturePasswordWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: ScreenUtil().setWidth(300.0),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(60.0)),
          child: tipTextWidget(),
        ),
        if (_isFirstDrawStep && _currentStrength != null)
          _buildStrengthIndicator(),
        Container(
          alignment: Alignment.center,
          height: ScreenUtil().setWidth(540.0),
          width: double.infinity,
          child: SizedBox(
            height: ScreenUtil().setWidth(540.0),
            width: ScreenUtil().setWidth(540.0),
            child: GesturePassword(
              _onGestureComplete,
              ScreenUtil().setWidth(180.0),
              answer: getAnswer(),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Tip text
  // ────────────────────────────────────────────────────────────────────────

  Widget tipTextWidget() {
    String titleStr = "";
    String subtitleStr = "";

    if (widget.type == 0) {
      titleStr = S.of(context).g_lock_key17;
      if (cachedData["0"]["index"] == "1") {
        // First draw step
        if (_currentStrength == PatternStrength.weak) {
          subtitleStr = S.of(context).g_key_gesture_too_simple;
        } else {
          subtitleStr = S.of(context).g_lock_key18;
        }
      } else {
        // Confirmation step
        final int errCount = cachedData["0"]["errorCount"];
        if (errCount == 0) {
          subtitleStr = S.of(context).g_lock_key19;
        } else if (errCount == 2) {
          subtitleStr = S.of(context)
              .g_lock_key25("${3 - errCount}");
        } else {
          subtitleStr = S.of(context)
              .g_lock_key21("${3 - errCount}");
        }
      }
    } else {
      if (cachedData["1"]["index"] == "1") {
        // Verify old password step
        titleStr = S.of(context).g_lock_key20;
        final int errCount = cachedData["1"]["1"]["errorCount"];
        if (errCount != 0) {
          subtitleStr = errCount == 2
              ? S.of(context).g_lock_key25("${3 - errCount}")
              : S.of(context).g_lock_key21("${3 - errCount}");
        }
      } else {
        titleStr = S.of(context).g_lock_key17;
        if (cachedData["1"]["index"] == "2") {
          // New password first draw step
          if (_currentStrength == PatternStrength.weak) {
            subtitleStr = S.of(context).g_key_gesture_too_simple;
          } else {
            subtitleStr = S.of(context).g_lock_key18;
          }
        } else {
          // Confirmation step
          final int errCount = cachedData["1"]["errorCount"];
          if (errCount == 0) {
            subtitleStr = S.of(context).g_lock_key19;
          } else if (errCount == 2) {
            subtitleStr = S.of(context)
                .g_lock_key25("${3 - errCount}");
          } else {
            subtitleStr = S.of(context)
                .g_lock_key21("${3 - errCount}");
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: ScreenUtil().setWidth(120.0),
          alignment: Alignment.center,
          child: Text(
            titleStr,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(32.0),
            ),
          ),
        ),
        Text(
          subtitleStr,
          style: TextStyle(
            color: _currentStrength == PatternStrength.weak && _isFirstDrawStep
                ? AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.errorTextColor.name)
                : AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(28.0),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Strength indicator
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildStrengthIndicator() {
    final PatternStrength strength = _currentStrength!;
    final int litBars = strength == PatternStrength.weak
        ? 1
        : strength == PatternStrength.medium
            ? 2
            : 3;
    final Color barColor = strength == PatternStrength.weak
        ? const Color(0xFFE53935) // red
        : strength == PatternStrength.medium
            ? const Color(0xFFFFA726) // orange
            : const Color(0xFF43A047); // green
    final String label = strength == PatternStrength.weak
        ? S.of(context).g_key_gesture_weak
        : strength == PatternStrength.medium
            ? S.of(context).g_key_gesture_medium
            : S.of(context).g_key_gesture_strong;

    final double barW = ScreenUtil().setWidth(60.0);
    final double barH = ScreenUtil().setWidth(8.0);
    final double gap = ScreenUtil().setWidth(4.0);

    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(20.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 3; i++)
            Container(
              width: barW,
              height: barH,
              margin: EdgeInsets.symmetric(horizontal: gap),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(barH / 2),
                color: i < litBars
                    ? barColor
                    : AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name)
                        .withAlpha((0.3 * 255).round()),
              ),
            ),
          SizedBox(width: ScreenUtil().setWidth(12.0)),
          Text(
            label,
            style: TextStyle(
              color: barColor,
              fontSize: ScreenUtil().setSp(24.0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Answer helper
  // ────────────────────────────────────────────────────────────────────────

  List<int>? getAnswer() {
    if (widget.type == 0) {
      if (cachedData['0']['index'] == "1") return null;
      return _stringToIntArray(cachedData['0']["1"]);
    } else {
      if (cachedData['1']['index'] == "1") {
        return _stringToIntArray(cachedData['1']["1"]['old']);
      } else if (cachedData['1']['index'] == "2") {
        return null;
      } else {
        return _stringToIntArray(cachedData['1']["2"]);
      }
    }
  }

  List<int> _stringToIntArray(String answer) =>
      answer.split(',').map(int.parse).toList();
}

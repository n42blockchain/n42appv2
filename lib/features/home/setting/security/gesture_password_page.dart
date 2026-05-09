import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gesture_password_widget/gesture_password_widget.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// 手势密码设置 / 重置页面
///
/// [oldPassword] 为 null 时进入「新建」流程（绘制 → 确认）；
/// 不为 null 时进入「重置」流程（验证旧密码 → 绘制新 → 确认）。
/// 返回值：设置成功时 pop(newPasswordString)，取消/返回时 pop(null)。
class GesturePasswordPage extends StatefulWidget {
  const GesturePasswordPage({super.key, this.oldPassword});

  final String? oldPassword;

  @override
  State<GesturePasswordPage> createState() => _GesturePasswordPageState();
}

class _GesturePasswordPageState extends State<GesturePasswordPage> {
  // 阶段：set 模式 0=首次绘制 1=确认
  //       reset 模式 0=验证旧 1=首次绘制 2=确认
  int _stage = 0;
  String _firstInput = '';
  int _errorCount = 0;

  bool get _isResetMode => widget.oldPassword != null;

  String get _title {
    if (_isResetMode) {
      return _stage == 0 ? S.of(context).g_lock_key20 : S.of(context).g_lock_key22;
    }
    return S.of(context).g_lock_key17;
  }

  String get _subtitle {
    if (_errorCount > 0) {
      final remaining = 3 - _errorCount;
      return remaining == 1
          ? S.of(context).g_lock_key25('$remaining')
          : S.of(context).g_lock_key21('$remaining');
    }
    if (_isResetMode && _stage == 0) return '';
    final isFirstDraw = _isResetMode ? _stage == 1 : _stage == 0;
    return isFirstDraw ? S.of(context).g_lock_key18 : S.of(context).g_lock_key19;
  }

  List<int>? get _answer {
    if (_isResetMode) {
      if (_stage == 0) return _toIntList(widget.oldPassword!);
      if (_stage == 1) return null;
      return _toIntList(_firstInput);
    }
    return _stage == 0 ? null : _toIntList(_firstInput);
  }

  List<int> _toIntList(String s) =>
      s.split(',').map(int.parse).toList();

  Future<void> _onComplete(String value) async {
    if (_isResetMode) {
      switch (_stage) {
        case 0:
          if (value == widget.oldPassword) {
            setState(() {
              _stage = 1;
              _errorCount = 0;
            });
          } else {
            _errorCount++;
            if (_errorCount >= 3) {
              await _showTooManyDialog(popPage: true);
            } else {
              setState(() {});
            }
          }
        case 1:
          setState(() {
            _firstInput = value;
            _stage = 2;
            _errorCount = 0;
          });
        case 2:
          if (value == _firstInput) {
            Navigator.pop(context, value);
          } else {
            _errorCount++;
            if (_errorCount >= 3) {
              await _showTooManyDialog(resetToStage: 1);
            } else {
              setState(() {});
            }
          }
      }
    } else {
      if (_stage == 0) {
        setState(() {
          _firstInput = value;
          _stage = 1;
          _errorCount = 0;
        });
      } else {
        if (value == _firstInput) {
          Navigator.pop(context, value);
        } else {
          _errorCount++;
          if (_errorCount >= 3) {
            await _showTooManyDialog(resetToStage: 0);
          } else {
            setState(() {});
          }
        }
      }
    }
  }

  Future<void> _showTooManyDialog({bool popPage = false, int? resetToStage}) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Text(S.of(context).g_lock_key23),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (popPage) {
                Navigator.pop(context);
              } else if (resetToStage != null) {
                setState(() {
                  _stage = resetToStage;
                  _firstInput = '';
                  _errorCount = 0;
                });
              }
            },
            child: Text(S.of(context).g_key_78),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gridSize = ScreenUtil().setWidth(540.0);
    final double identifySize = ScreenUtil().setWidth(180.0);
    final double bigWidth = identifySize / 2;
    final double miniWidth = identifySize / 4;

    final Color mainBlue =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final Color errorColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name);
    final Color subtitleColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.itemSubtitleTextColor.name);
    final Color bgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name);
    final Color mainTextColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);

    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_lock_key16),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: ScreenUtil().setWidth(80.0)),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(60.0)),
              child: Column(
                children: [
                  Text(
                    _title,
                    style: TextStyle(
                      color: mainTextColor,
                      fontSize: ScreenUtil().setSp(32.0),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ScreenUtil().setWidth(20.0)),
                  Text(
                    _subtitle,
                    style: TextStyle(
                      color: _errorCount > 0 ? errorColor : subtitleColor,
                      fontSize: ScreenUtil().setSp(28.0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(60.0)),
            Center(
              child: SizedBox(
                width: gridSize,
                height: gridSize,
                child: KeyedSubtree(
                  key: ValueKey('$_stage-$_errorCount'),
                  child: GesturePasswordWidget(
                  size: gridSize,
                  lineColor: mainBlue,
                  errorLineColor: errorColor,
                  singleLineCount: 3,
                  identifySize: identifySize,
                  minLength: 4,
                  hitShowMilliseconds: 40,
                  answer: _answer,
                  color: bgColor,
                  normalItem: Container(
                    height: miniWidth,
                    width: miniWidth,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(miniWidth)),
                      color: subtitleColor,
                    ),
                  ),
                  selectedItem: Container(
                    width: bigWidth,
                    height: bigWidth,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(bigWidth)),
                      color: mainBlue.withAlpha((0.5 * 255).round()),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: miniWidth,
                      height: miniWidth,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(miniWidth)),
                        color: mainBlue,
                      ),
                    ),
                  ),
                  hitItem: Container(
                    width: bigWidth,
                    height: bigWidth,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(bigWidth)),
                      color: mainBlue.withAlpha((0.5 * 255).round()),
                    ),
                  ),
                  errorItem: Container(
                    width: bigWidth,
                    height: bigWidth,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(bigWidth)),
                      color: errorColor.withAlpha((0.5 * 255).round()),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: miniWidth,
                      height: miniWidth,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(miniWidth)),
                        color: errorColor,
                      ),
                    ),
                  ),
                  onComplete: (data) => _onComplete(data.join(',')),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

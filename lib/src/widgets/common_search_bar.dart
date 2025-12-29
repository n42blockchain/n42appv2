import 'dart:async';

import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDelete;
  final bool isCanClear;

  const CommonSearchBar(
      {Key? key,
        this.controller,
        this.placeholder,
        this.onTap,
        this.isCanClear = true,
        this.onDelete})
      : super(key: key);

  @override
  State<CommonSearchBar> createState() => _CommonSearchBarState();
}

class _CommonSearchBarState extends State<CommonSearchBar> {
  final controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _startSearchTimer(String searchTerm) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (widget.onTap != null) {
        widget.onTap!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildSearch();
  }

  Container buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor6.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(20)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemBgColor6.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
              ),
              style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor8.name),
                  height: 1.2,
                  fontSize: ScreenUtil().setSp(32)),
              placeholder: widget.placeholder,
              prefix:  Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(24)),
                child: Icon(
                  Icons.search,
                  color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor8.name),
                  size: ScreenUtil().setWidth(48),
                ),
              ),
              suffix: widget.isCanClear
                  ? GestureDetector(
                onTap: widget.onDelete ??
                        () {
                      if (widget.controller != null) {
                        widget.controller!.text = '';
                      } else {
                        controller.text = '';
                      }
                    },
                child: Padding(
                  padding: EdgeInsets.only(right: ScreenUtil().setWidth(24)),
                  child: Icon(
                    Icons.cancel,
                    color: Colors.grey,
                    size: ScreenUtil().setWidth(44),
                  ),
                ),
              )
                  : null,
              placeholderStyle: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.ff888888.name),
                  fontSize: ScreenUtil().setSp(30)),
              controller: widget.controller ?? controller,
              textInputAction: TextInputAction.search,
              inputFormatters: [LengthLimitingTextInputFormatter(32)],
              onSubmitted: (value) {
                _startSearchTimer(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
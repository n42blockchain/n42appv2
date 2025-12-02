import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          width: ScreenUtil().setWidth(200.0),
          alignment: Alignment.center,
          child: Container(
            width: ScreenUtil().setWidth(60.0),
            height: ScreenUtil().setWidth(60.0),
            child: CircularProgressIndicator(),
          ),
        )

    );
  }
}

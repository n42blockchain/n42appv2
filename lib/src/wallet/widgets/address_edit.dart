import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/src/wallet/models/address_book_model.dart';
import 'package:n42_wallet/src/wallet/pages/address_book/edit_address_page.dart';
import 'package:n42_wallet/src/widgets/prompt_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressEdit extends StatelessWidget {
  final AddressBookModel info;
  final VoidCallback? callback;
  const AddressEdit(this.info, {super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color:AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  /// copy 地址
                  ToastUtils.init(context);
                  Clipboard.setData(ClipboardData(text: info.address ?? ''));
                  ToastUtils.showFtToast(child:successViewV1(S.of(context).copy),duration: 3);
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(34.0)),
                  color: Colors.transparent,
                  child:  Center(
                    child: Text(
                      S.of(context).copyAddress,
                      style: TextStyle(color:  Color(0xFF448BDF), fontSize: ScreenUtil().setSp(30.0)),
                    ),
                  ),
                ),
              ),
              Divider(
                height: ScreenUtil().setWidth(1.0),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemLineColor.name),
              ),
              GestureDetector(
                onTap: () async {
                  /// edit
                  await Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=> EditAddressPage(info: info)));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(34.0)),
                  color: Colors.transparent,
                  child:  Center(
                    child: Text(
                      S.of(context).Edit,
                      style: TextStyle(color: Color(0xFF448BDF), fontSize: ScreenUtil().setSp(30.0)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: ScreenUtil().setWidth(20.0),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(34.0)),
            color:AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            child: Center(
              child: Text(
                S.of(context).g_key_79,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

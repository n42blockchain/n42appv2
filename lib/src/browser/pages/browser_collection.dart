import 'package:n42appv2/src/browser/pages/browser_collection_list.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/src/browser/api/browser_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrowserCollection extends StatefulWidget {
  final String title;
  final String url;

  const BrowserCollection(this.title, this.url, {super.key});

  @override
  BrowserCollectionState createState() => BrowserCollectionState();
}

class BrowserCollectionState extends State<BrowserCollection> {
  TextEditingController titleEditingController = TextEditingController();
  FocusNode titleNode = FocusNode();
  TextEditingController urlEditingController = TextEditingController();
  FocusNode urlNode = FocusNode();
  TextEditingController descEditingController = TextEditingController();
  FocusNode descNode = FocusNode();

  String titleErrorMessage = "";
  String urlErrorMessage = "";
  String descErrorMessage = "";

  @override
  void initState() {
    titleEditingController.text = widget.title;
    urlEditingController.text = widget.url;
    super.initState();
  }

  //保存 当前 url
  Future<void> _saveUrl() async {
    String title = titleEditingController.text;
    if (title == "") {
      setState(() {
        titleErrorMessage = S.of(context).g_browser_key4;
      });
      return;
    }
    String url = urlEditingController.text;
    if (url == "") {
      setState(() {
        urlErrorMessage = S.of(context).g_browser_key4;
      });
      return;
    }
    String desc = descEditingController.text;
    BrowserApi().insertBrowserCollection(title, url, desc: desc);
    setState(() {});
    ToastUtils.show(S.of(context).g_key_185);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleEditingController.dispose();
    urlEditingController.dispose();
    descEditingController.dispose();
    titleNode.dispose();
    urlNode.dispose();
    descNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          S.of(context).g_browser_key5,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
            fontSize: ScreenUtil().setSp(36.0),
          ),
        ),
        actions: [
          InkWell(
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BrowserCollectionList(type: 1)));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              alignment: Alignment.center,
              child: SizedBox(
                width: 20,
                height: 20,
                child: Icon(
                  Icons.list_alt,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainButtonBgColor.name),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget(),
                    urlWidget(),
                    descWidget(),
                    SizedBox(
                      height: ScreenUtil().setWidth(120.0),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: saveWidget(),
            )
          ],
        ),
      ),
    );
  }

  Widget titleWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: ScreenUtil().setWidth(40.0),
            child: Text(
              S.of(context).g_browser_key6,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(32.0)),
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(20.0),
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
            ),
            child: TextField(
              //key: _toKey,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              controller: titleEditingController,
              focusNode: titleNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: S.of(context).g_browser_key7,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              maxLines: 1,
              onSubmitted: (value) {
                FocusScope.of(context).requestFocus(urlNode);
              },
            ),
          ),
          Visibility(
            visible: titleErrorMessage != "",
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                titleErrorMessage,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget urlWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: ScreenUtil().setWidth(40.0),
            child: Text(
              S.of(context).g_browser_key8,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(32.0)),
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(20.0),
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
            ),
            child: TextField(
              //key: _toKey,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              controller: urlEditingController,
              focusNode: urlNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: S.of(context).g_browser_key1,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              maxLines: 1,
              onSubmitted: (value) {
                FocusScope.of(context).requestFocus(descNode);
              },
            ),
          ),
          Visibility(
            visible: urlErrorMessage != "",
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                urlErrorMessage,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget descWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: ScreenUtil().setWidth(40.0),
            child: Text(
              S.of(context).g_browser_key9,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(32.0)),
            margin: EdgeInsets.only(
              top: ScreenUtil().setWidth(20.0),
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20.0))),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
            ),
            child: TextField(
              //key: _toKey,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
              controller: descEditingController,
              focusNode: descNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: S.of(context).g_browser_key10,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              maxLines: 5,
              onSubmitted: (value) {
                FocusScope.of(context).requestFocus(titleNode);
              },
            ),
          ),
          Visibility(
            visible: descErrorMessage != "",
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                descErrorMessage,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.errorTextColor.name),
                  fontSize: ScreenUtil().setSp(24.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget saveWidget() {
    return Container(
      height: ScreenUtil().setWidth(148.0),
      width: double.infinity,
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: buttonStyle2(
        context,
            ()async {
          _saveUrl();
        },
        S.of(context).g_key_115,
      ),
    );
  }
}

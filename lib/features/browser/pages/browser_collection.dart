import 'package:n42_wallet/features/browser/pages/browser_collection_list.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrowserCollection extends StatefulWidget {
  final String title;
  final String url;

  const BrowserCollection(this.title, this.url, {super.key});

  @override
  BrowserCollectionState createState() => BrowserCollectionState();
}

class BrowserCollectionState extends State<BrowserCollection> {
  final TextEditingController titleEditingController = TextEditingController();
  final FocusNode titleNode = FocusNode();
  final TextEditingController urlEditingController = TextEditingController();
  final FocusNode urlNode = FocusNode();
  final TextEditingController descEditingController = TextEditingController();
  final FocusNode descNode = FocusNode();

  String titleErrorMessage = "";
  String urlErrorMessage = "";
  String descErrorMessage = "";
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    titleEditingController.text = widget.title;
    urlEditingController.text = widget.url;
  }

  Future<void> _saveUrl() async {
    if (_saving) return;
    final title = titleEditingController.text.trim();
    if (title == "") {
      setState(() => titleErrorMessage = S.of(context).g_browser_key4);
      return;
    }
    final url = urlEditingController.text.trim();
    if (url == "") {
      setState(() => urlErrorMessage = S.of(context).g_browser_key4);
      return;
    }
    final desc = descEditingController.text;
    setState(() {
      _saving = true;
      titleErrorMessage = "";
      urlErrorMessage = "";
    });
    bool completedWithExit = false;
    try {
      await BrowserApi().insertBrowserCollection(title, url, desc: desc);
      if (!mounted) return;
      ToastUtils.show(S.of(context).g_key_185);
      completedWithExit = true;
      Navigator.pop(context);
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _saving = false);
      }
    }
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
            color: AppColorTokens.of(context).textPrimary,
            fontSize: ScreenUtil().setSp(36.0),
          ),
        ),
        actions: [
          InkWell(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BrowserCollectionList(type: 1),
                ),
              );
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
                    context,
                    AppThemeKeys.mainButtonBgColor.name,
                  ),
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
                    SizedBox(height: ScreenUtil().setWidth(120.0)),
                  ],
                ),
              ),
            ),
            Positioned(bottom: 0, left: 0, right: 0, child: saveWidget()),
          ],
        ),
      ),
    );
  }

  /// Shared form field builder to eliminate repetition across title/url/desc.
  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
    required String errorMessage,
    int maxLines = 1,
  }) {
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
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28.0),
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(32.0)),
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(20.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(ScreenUtil().setWidth(20.0)),
              ),
              color: AppColorTokens.of(context).bgSurface,
            ),
            child: TextField(
              style: TextStyle(color: AppColorTokens.of(context).textPrimary),
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              maxLines: maxLines,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              },
            ),
          ),
          if (errorMessage.isNotEmpty)
            Text(
              errorMessage,
              style: TextStyle(
                color: AppColorTokens.of(context).danger,
                fontSize: ScreenUtil().setSp(24.0),
              ),
            ),
        ],
      ),
    );
  }

  Widget titleWidget() => _buildFormField(
    label: S.of(context).g_browser_key6,
    hintText: S.of(context).g_browser_key7,
    controller: titleEditingController,
    focusNode: titleNode,
    nextFocusNode: urlNode,
    errorMessage: titleErrorMessage,
  );

  Widget urlWidget() => _buildFormField(
    label: S.of(context).g_browser_key8,
    hintText: S.of(context).g_browser_key1,
    controller: urlEditingController,
    focusNode: urlNode,
    nextFocusNode: descNode,
    errorMessage: urlErrorMessage,
  );

  Widget descWidget() => _buildFormField(
    label: S.of(context).g_browser_key9,
    hintText: S.of(context).g_browser_key10,
    controller: descEditingController,
    focusNode: descNode,
    nextFocusNode: titleNode,
    errorMessage: descErrorMessage,
    maxLines: 5,
  );

  Widget saveWidget() {
    return Container(
      height: ScreenUtil().setWidth(148.0),
      width: double.infinity,
      color: AppColorTokens.of(context).bgBase,
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      child: AppButton(label: S.of(context).g_key_115, onPressed: _saveUrl),
    );
  }
}

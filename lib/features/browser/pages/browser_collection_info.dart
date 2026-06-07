import 'package:n42_wallet/features/browser/api/browser_api.dart';
import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrowserCollectionInfo extends StatefulWidget {
  final BrowserCollectionModel collectionModel;
  const BrowserCollectionInfo(this.collectionModel, {super.key});

  @override
  State<BrowserCollectionInfo> createState() => _BrowserCollectionInfoState();
}

class _BrowserCollectionInfoState extends State<BrowserCollectionInfo> {
  late final BrowserApi browserApi = BrowserApi();
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
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    titleEditingController.text = widget.collectionModel.name ?? "";
    urlEditingController.text = widget.collectionModel.url ?? "";
    descEditingController.text = widget.collectionModel.desc ?? "";
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

  Future<void> deleteCollection() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    bool completedWithExit = false;
    try {
      await browserApi.deleteBrowserCollection(widget.collectionModel.id!);
      if (!mounted) return;
      ToastUtils.show(S.of(context).g_key_address_5);
      completedWithExit = true;
      Navigator.pop(context, "delete");
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _deleting = false);
      }
    }
  }

  Future<void> _saveUrl() async {
    if (_saving) return;
    widget.collectionModel.name = titleEditingController.text.trim();
    if (widget.collectionModel.name == "") {
      setState(() => titleErrorMessage = S.of(context).g_browser_key4);
      return;
    }
    widget.collectionModel.url = urlEditingController.text.trim();
    if (widget.collectionModel.url == "") {
      setState(() => urlErrorMessage = S.of(context).g_browser_key4);
      return;
    }
    widget.collectionModel.desc = descEditingController.text;
    setState(() {
      _saving = true;
      titleErrorMessage = "";
      urlErrorMessage = "";
    });
    bool completedWithExit = false;
    try {
      await browserApi.updateBrowsercollection(widget.collectionModel);
      if (!mounted) return;
      ToastUtils.show(S.of(context).g_key_185);
      completedWithExit = true;
      Navigator.pop(context, "save");
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_browser_key5,
        actions: [
          InkWell(
            onTap: _deleting ? null : deleteCollection,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30.0),
              ),
              height: ScreenUtil().setWidth(40.0),
              child: _deleting
                  ? SizedBox(
                      height: ScreenUtil().setWidth(24.0),
                      width: ScreenUtil().setWidth(24.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColorTokens.of(context).brand,
                      ),
                    )
                  : Icon(Icons.delete, color: AppColorTokens.of(context).brand),
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
              borderRadius: AppRadius.brMd,
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

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/pages/chat_detail_page.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/textField_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class FriendDetail extends StatefulWidget {
  final FriendInfo info;

  const FriendDetail({Key? key, required this.info}) : super(key: key);

  @override
  State<FriendDetail> createState() => _FriendDetailState();
}
// {code: 200, msg: OK, data:
// {uuid: 1ee0edac-1311-8863-3cd1-fcdf78f399a4,
// email: zhcandroid2022@163.com,
// name: hhh,
// portrait: https://bafybeih5s2zwq3vj3uwq6zukx24qc7zo4bktwjed6pgoor4dq4qxdf2vse.ipfs.nftstorage.link/aImage.png,
// updateDt: 605}}

class _FriendDetailState extends State<FriendDetail> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    if(_chatApi==null){
      _chatApi=ChatApi();
    }
    return _chatApi!;
  }
  Load load=Load.loading;
  bool isFriend=false;
  final _remarksTextController = TextEditingController();
  final _reasonTextController = TextEditingController();
  FocusNode _remarksFocusNode=FocusNode();
  FocusNode _reasonFocusNode=FocusNode();

  String? reasonText;

  updateFriendData() async {
    final data = await chatApi.friendList();
    if (data != null && data["code"] == 200) {
      List<FriendInfo> list =
      (data["data"] as List).map((e) => FriendInfo.fromJson(e)).toList();
      // 返回列表中 把自己排除在外
      list.removeWhere((element) => element.uuid == AppGlobals.userInfo?.uuid);
      int fIndex=list.indexWhere((element) => element.uuid == widget.info.uuid);
      if(fIndex !=-1){
        isFriend=true;
      }
      setState(() {
        load = Load.finish;
      });
      //本地缓存好友列表
      ChatSPUtil().saveFriendsList(list);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AppGlobals.userInfo?.name != null) {
      reasonText = S.current.g_chat_key_10(AppGlobals.userInfo?.name ?? '');
    }
    updateFriendData();
  }

  @override
  void dispose() {
    super.dispose();
    _remarksTextController.dispose();
    _reasonTextController.dispose();
    _remarksFocusNode.dispose();
    _reasonFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_chat_key_16,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
                // color: Colors.transparent,
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: ScreenUtil().setWidth(100),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(160),
                            height: ScreenUtil().setWidth(160),
                            //超出部分，可裁剪
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(200)),
                            ),
                            child: ImageNetWork(
                              imageUrl: widget.info.portrait ?? '',
                              placeholder: "assets/chat/user_def_icon.png",
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setWidth(40),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.info.name ?? '',
                                style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(
                                        context, AppThemeKeys.mainTextColor.name),
                                    fontSize: ScreenUtil().setSp(36),
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: ScreenUtil().setWidth(24),),
                              Text(
                                widget.info.email ?? '',
                                style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(
                                        context, AppThemeKeys.ff888888.name),
                                    fontSize: ScreenUtil().setSp(30),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    _buildHandlerView()
                  ],
                ),
              ),
            ),
            if(load==Load.finish && AppGlobals.userInfo?.email != widget.info.email)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  Divider(
                    height: ScreenUtil().setWidth(1),
                    indent: 0,
                    endIndent: 0,
                  ),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setWidth(148),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: buttonWidget(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildHandlerView() {
    if (AppGlobals.userInfo?.uuid == widget.info.uuid ||
        load==Load.loading ||
        isFriend
    ) {
      return const SizedBox();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: ScreenUtil().setWidth(60),
        ),
        Container(
          height: ScreenUtil().setWidth(60),
          width: double.infinity,
          child: Text(
            S.of(context).g_chat_key_69,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ),
        Container(
            height: ScreenUtil().setWidth(120),
            decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24))),
            child: TextFieldStyle3(
              context,
              controller: _reasonTextController,
              focusNode: _reasonFocusNode,
              hintText: reasonText ?? S.of(context).g_chat_key_9,
              onEditingComplete: (){
                FocusScope.of(context).requestFocus(_remarksFocusNode);
              },
              textInputAction: TextInputAction.next,
              maxLengths:20,
              height: ScreenUtil().setWidth(120.0),
            ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(40),
        ),
        Container(
          height: ScreenUtil().setWidth(60),
          width: double.infinity,
          child: Text(
            S.of(context).g_key_8,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ),
        Container(
            height: ScreenUtil().setWidth(170),
            decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24))),
            child: TextFieldStyle3(
              context,
              controller: _remarksTextController,
              focusNode: _remarksFocusNode,
              hintText: S.of(context).g_key_8,
              onEditingComplete: (){
                FocusScope.of(context).requestFocus(FocusNode());
              },
              textInputAction: TextInputAction.done,
              maxLines: 3,
              maxLengths:100,
              height: ScreenUtil().setWidth(170.0),
            ),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(148),
        ),
      ],
    );
  }
  buttonWidget(){
    String title=S.of(context).g_chat_key_8;
    if(isFriend){
      title=S.of(context).g_key_squad;
    }
    return ButtonStyle2(context, () async {
      if(isFriend){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ChatDetailPage(targetUuid: widget.info.uuid??"", conversationType: 0)));
      }
      else{
        String? reasonData;
        final rt = _reasonTextController.text.trim();
        if (rt.isNotEmpty) {
          reasonData = rt;
        } else {
          reasonData = reasonText;
        }
        final remarks = _remarksTextController.text.trim();
        final data = await chatApi.friendAdd(reasonData ?? '', remarks,
            AppGlobals.userInfo?.uuid ?? '', widget.info.uuid ?? '');
        if (data != null && data["code"] == 200) {
          Navigator.of(context).pop();
        } else {
          ToastUtils.show(data["msg"]);
        }
      }
    }, title);
  }
}
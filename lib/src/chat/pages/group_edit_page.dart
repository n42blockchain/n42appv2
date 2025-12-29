import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/group_info.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/comm_input.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class GroupEditPage extends StatefulWidget {
  final GroupInfo info;

  const GroupEditPage({Key? key, required this.info}) : super(key: key);

  @override
  State<GroupEditPage> createState() => _GroupEditPageState();
}

class _GroupEditPageState extends State<GroupEditPage> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    if(_chatApi==null){
      _chatApi=ChatApi();
    }
    return _chatApi!;
  }
  Load load=Load.finish;
  final _nameTextEditController = TextEditingController();

  bool sureButtonCanClick = false;

  @override
  void initState() {
    super.initState();
    _nameTextEditController.addListener(() {
      setState(() {
        sureButtonCanClick = _nameTextEditController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: "",
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: ScreenUtil().setWidth(60.0),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: ScreenUtil().setWidth(60.0),
                  left: ScreenUtil().setWidth(30.0),
                  right: ScreenUtil().setWidth(30.0),
                  bottom: ScreenUtil().setWidth(40.0),
                ),
                child: Text(
                  // "修改群聊名称",
                  S.of(context).g_chat_key_24,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(40)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(30.0),
                  right: ScreenUtil().setWidth(30.0),
                  bottom: ScreenUtil().setWidth(60.0),
                ),
                child: Text(
                  // "修改群聊名称后，将在群内通知其他成员。",
                  S.of(context).g_chat_key_25,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(32)),
                ),
              ),
              Divider(
                height: ScreenUtil().setWidth(1),
                indent: 0,
                endIndent: 0,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.dividerColor.name),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(24),
                  horizontal: ScreenUtil().setWidth(30),
                ),
                child: Row(
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(80),
                      height: ScreenUtil().setWidth(80),
                      //超出部分，可裁剪
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(40)),
                          border: Border.all(
                              width: 0.5,
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemLineColor.name))),
                      child: ImageNetWork(
                        imageUrl: widget.info.avatar_url,
                        width: ScreenUtil().setWidth(40),
                        placeholder: "assets/img/person_def_1.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                        child: CommInput(
                          type: InputFieldType.account,
                          hintText: widget.info.name ?? '',
                          controller: _nameTextEditController,
                        ))
                  ],
                ),
              ),
              Divider(
                height: ScreenUtil().setWidth(1),
                indent: 0,
                endIndent: 0,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.dividerColor.name),
              ),
              const Spacer(),
              Divider(
                height: ScreenUtil().setWidth(1),
                indent: 0,
                endIndent: 0,
              ),
              Container(
                width: double.infinity,
                height: ScreenUtil().setWidth(88),
                margin: EdgeInsets.all( ScreenUtil().setWidth(30)),
                child: ButtonStyle2(context, () async {
                  try{
                    if(load==Load.loading)return;
                    final nameText = _nameTextEditController.text.trim();
                    if (nameText.isEmpty) return;
                    setState(() {
                      load=Load.loading;
                    });

                    //修改群名称
                    final data = await chatApi.updateGroupInfo(
                        g_introduction: "",
                        g_uuid: widget.info.g_uuid,
                        group_name: nameText,
                        m_uuid: AppGlobals.userInfo?.uuid ?? '');

                    if (data != null && data["code"] == 200) {
                      //更新缓存
                      GroupInfo item = widget.info;
                      item.name = nameText;
                      ChatSPUtil().saveOrUpdateGroupInfo(item);

                      //更新群聊天ui的 group name 展示
                      eventBus.fire(EventPublic(EventPublicType.updateGroupInfo));

                      Navigator.of(context).pop(true);
                    } else {
                      ToastUtils.show(data["msg"]);
                    }
                  }finally{
                    setState(() {
                      load=Load.finish;
                    });
                  }

                }, S.of(context).g_chat_key_26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
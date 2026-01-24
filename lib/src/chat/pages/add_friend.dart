import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/pages/friend_detail.dart';
import 'package:n42appv2/src/utils/regular.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/common_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class AddFriend extends StatefulWidget {
  final String? email;
  const AddFriend({this.email,super.key});

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  String? searchKey;
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    //通过深度链接打开当前页面时 自动搜索跳转到添加好友页面
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(widget.email != null){
        searchKey = widget.email;
        searchFriend(context);
      }
    });

  }

  Future<void> searchFriend(BuildContext context) async {
    if (searchKey == null) return;
    if (!Regular().isEmail(searchKey!)) {
      ToastUtils.show(S.of(context).email_error);
      return;
    }
    final data = await chatApi.searchFriend(searchKey!);
    if (data != null && data["code"] == 100002) {
      ToastUtils.show("user not found");
    }
    // {uuid: 1ee0edac-1311-8863-3cd1-fcdf78f399a4,
    // email: zhcandroid2022@163.com,
    // name: hhh,
    // portrait: https://bafybeih5s2zwq3vj3uwq6zukx24qc7zo4bktwjed6pgoor4dq4qxdf2vse.ipfs.nftstorage.link/aImage.png,
    // updateDt: 605}}
    if (data != null && data['code'] == 200) {
      FriendInfo info = FriendInfo.fromJson(data["data"]);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => FriendDetail(info: info)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_squad_k18,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
          child: Column(
            children: [
              SizedBox(height: ScreenUtil().setWidth(24),),
              CommonSearchBar(
                placeholder: S.of(context).g_key_squad_k25,
                controller: controller,
                onTap: () {
                  //search
                  searchKey = controller.text.trim();
                  searchFriend(context);
                },
                onDelete: () {
                  searchKey = '';
                  controller.text = '';
                },
                isCanClear: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

}

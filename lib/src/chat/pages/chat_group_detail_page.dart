import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:n42appv2/src/chat/pages/red_pocket_group3.dart';
import 'package:n42appv2/src/chat/provider/chat_upload_file.dart';
import 'package:n42appv2/src/chat/widgets/bottom_group_member_dialog.dart';
import 'package:n42appv2/src/chat/widgets/bottom_input_chat_reply_widget.dart';
import 'package:n42appv2/src/chat/widgets/item_group_chat_view.dart';
import 'package:n42appv2/src/https/ipfs_api.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart' as flustars;
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/models/group_data.dart';
import 'package:n42appv2/src/chat/models/group_info.dart';
import 'package:n42appv2/src/chat/models/group_member_info.dart';
import 'package:n42appv2/src/chat/models/red_pocket_claim_model.dart';
import 'package:n42appv2/src/chat/models/red_pocket_detail_model.dart';
import 'package:n42appv2/src/chat/models/red_pocket_model.dart';
import 'package:n42appv2/src/chat/pages/group_detail_page.dart';
import 'package:n42appv2/src/chat/provider/chat_message_provider.dart';
import 'package:n42appv2/src/chat/provider/message_content_type.dart';
import 'package:n42appv2/src/chat/utils/aes_utils.dart';
import 'package:n42appv2/src/chat/utils/cache_read_message_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_data_util.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/chat/utils/chat_util.dart';
import 'package:n42appv2/src/chat/widgets/file_aes_crypt_utils.dart';
import 'package:n42appv2/src/chat/widgets/file_utils.dart';
import 'package:n42appv2/src/chat/widgets/rich_input.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/base64_utils.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/src/wallet/utils/browser_txhash.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class ChatGroupDetailPage extends StatefulWidget {
  //聊天对象的uuid
  final String targetUuid;

  // 0 单聊 1群组
  final int conversationType;
  const ChatGroupDetailPage({required this.targetUuid, required this.conversationType,super.key});

  @override
  State<ChatGroupDetailPage> createState() => _ChatGroupDetailPageState();
}

class _ChatGroupDetailPageState extends State<ChatGroupDetailPage> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  ChatDataUtil? _chatDataUtils;
  ChatDataUtil get chatDataUtils{
    _chatDataUtils ??= ChatDataUtil();
    return _chatDataUtils!;
  }
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    _dataUtils ??= DataUtils();
    return _dataUtils!;
  }
  ChatDBApi? _chatDBApi;
  ChatDBApi get chatDBApi{
    _chatDBApi ??= ChatDBApi();
    return _chatDBApi!;
  }
  ChatUtil? _chatUtil;
  ChatUtil get chatUtils{
    _chatUtil ??= ChatUtil();
    return _chatUtil!;
  }
  final CustomPopupMenuController _addController = CustomPopupMenuController();

  // final TextEditingController _textEditingController = TextEditingController();
  final RichInputController _textEditingController = RichInputController();
  final ScrollController _scrollController = ScrollController();

  var centerKey = GlobalKey();

  final FocusNode _focusNode = FocusNode();

  //下拉刷新时 放入loadMoreData数据集合中
  List<ChatMessageModel> loadMoreData = [];

  //首次进入加载数据到newData中
  List<ChatMessageModel> newData = [];

  bool _isLoading = false;

  double opacityValue = 0;

  bool canSendText = false;

  String? otherUserPubKey;
  String? mPubKey;
  String? mPrivateKey;

  int pageIndex = 0;

  //采用时间分页查询 防止数据重复
  int lastPointTime = DateTime.now().millisecondsSinceEpoch;

  //群信息
  GroupInfo? groupInfo;

  //群成员
  List<GroupMemberInfo> groupMemberList = [];

  //判断当前用户是否是群主
  bool isGroupOwner = false;

  //是否还在群里
  bool isGroupMember = false;

  //群是否解散
  bool isUnGroup = false;

  int lastSeq = 0;

  //群密码
  String? groupPwd;

  double? extentAfter;

  // final ScrollPhysics _physics = const BouncingScrollPhysics();
  //https://www.jianshu.com/p/a00f56f74d5d
  final ScrollPhysics _physics = const ClampingScrollPhysics();

  //当前正在回复的消息
  ChatMessageModel? currentReplyModel;
  String? replyUserName;

  //点开的红包
  ChatMessageModel? redPocketMessage;
  StreamSubscription? eventBusFn;
  @override
  void initState() {
    //设置正在聊天的对象
    Provider.of<ChatMessageProvider>(context,listen: false).setTargetUuid(widget.targetUuid);
    super.initState();
    _textEditingController.addListener(() {
      bool flag = _textEditingController.text.isNotEmpty;
      if (canSendText != flag) {
        setState(() {
          canSendText = flag;
        });
      }
    });
    _focusNode.addListener(textFocusListener);

    getGroupPwd();
    initData();
    addMessageListener();
  }

  @override
  void dispose() {
    Provider.of<ChatMessageProvider>(context,listen: false).setTargetUuid(null);
    super.dispose();
    eventBusFn?.cancel();
    _scrollController.dispose();
    _textEditingController.dispose();
    _addController.dispose();
    _focusNode.dispose();
  }

  getGroupPwd() async {
    try {
      // 从缓存取出group pwd
      GroupData? gd =
      await ChatSPUtil().getGroupDataByGroupId(widget.targetUuid);
      if (gd != null) {
        groupPwd = gd.groupPwd;
        debugPrint("从缓存取出group pwd：$groupPwd"); //eDJHBgiQgN8aWwsN
      } else {
        debugPrint("从缓存取出group pwd：1-1010101010");
        final data = await chatApi.checkGroupSSById(widget.targetUuid);
        if (data != null && data['code'] == 200) {
          final map = data["data"];
          if (map != null) {
            final pubKey = map["public_key"];
            final ss = map["ss"];
            //兼容多钱包 根据pubKey找出对应钱包的privateKey
            // Use IChatCryptoService instead of WalletActionProvider
            final cryptoService = ServiceLocatorSetup.chatCryptoService;
            Map<String, String> keyMap = {};
            if (cryptoService != null) {
              keyMap = await cryptoService.getPublicKeyAndPrivateKeyPairs();
            }
            debugPrint("keyMap===:$keyMap");
            final privateKey = keyMap["$pubKey"];
            if (privateKey == null) {
              return;
            }
            final decode = await chatUtils.chatDecode(
                privateKey, Base64Utils().decodeBase64(ss));
            groupPwd = dataUtils.toStringFromHex(decode ?? '');
            // debugPrint("解密出的群密码是：$groupPwd"); //eDJHBgiQgN8aWwsN
            //保存group pwd
            ChatSPUtil().saveGroupDataIfNotExists(
                GroupData(widget.targetUuid, groupPwd ?? ''));
          }
        }
      }
    } catch (err) {
      debugPrint("getGroupPwd err:${err.toString()}");
    }
  }

  addMessageListener() {
    eventBusFn=eventBus.on().listen((event) async {
      /*if (event is EventPublic && event.type == EventPublicType.groupRedPocket) {
        RedPocketModel rpm=event.param as RedPocketModel;
        onSendRedPocket(rpm);
      }*/
      if (event is EventPublic && event.type == EventPublicType.chatMessage) {
        // debugPrint("EventPublicType.chatMessage: 收到监听消息了");
        ChatMessageModel model = event.param as ChatMessageModel;
        //如果发送人不是当前和我聊天的用户 不展示消息
        if (model.getTargetId() != widget.targetUuid) {
          return;
        }
        if (!mounted) {
          return;
        }
        //移除未读消息
        CacheMessageIsReadUtils().removeUnReadMessageId(widget.targetUuid);

        setState(() {
          newData.add(model);
        });
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        if(model.content.type==90){
          getGroupPwd();
          resetGroupStatus();
          getGroupDetail();
        }
      }
      if (event is EventPublic && event.type == EventPublicType.chatMessageRefresh) {
        // debugPrint("EventPublicType.chatMessage: 收到监听消息了");
        ChatMessageModel model = event.param as ChatMessageModel;
        int nIndex=newData.indexWhere((element){
          if(element.messageId==model.messageId){
            return true;
          }
          return false;
        });
        if(nIndex !=-1){
          newData[nIndex].sMessageId=model.sMessageId;
        }
        setState(() {});
      }
      //修改群名称之后 更新name
      if (event is EventPublic &&
          event.type == EventPublicType.updateGroupInfo) {
        resetGroupStatus();
        getGroupDetail();
      }
      //删除消息功能
      if (event is EventPublic &&
          event.type == EventPublicType.deleteChatItem) {
        ChatMessageModel model = event.param as ChatMessageModel;
        newData.remove(model);
        loadMoreData.remove(model);
        if (mounted) {
          setState(() {});
        }
      }

      //消息回复
      if (event is EventPublic && event.type == EventPublicType.chatItemReply) {
        ChatMessageModel model = event.param as ChatMessageModel;
        currentReplyModel = model;
        //对方的name、
        if (currentReplyModel?.direction == 1) {
          replyUserName = AppGlobals.userInfo?.name;
        } else {
          //从缓存中找出用户
          FriendInfo? info = await ChatSPUtil().getNavUserInfo(
              currentReplyModel?.from ?? '');
          if (info != null) {
            replyUserName = info.name;
          }
        }

        setState(() {});
      }
    });
  }

  resetGroupStatus() {
    //判断当前用户是否是群主
    isGroupOwner = false;
    //是否还在群里
    isGroupMember = false;
    //群是否解散
    isUnGroup = false;
  }

  void textFocusListener() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent / 2);
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  initData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // await getGroupOfflineMessage();
      await getGroupNewMessageFromNet();
      await getGroupDetail();
      //获取聊天记录
      await getMessageDetail();

      setState(() {
        _isLoading = false;
      });

      //列表移动到最后一个可见元素上
      await Future.delayed(const Duration(milliseconds: 800), () async {
        if (!mounted) return;
        //*****这里直接跳转到maxScrollExtent位置时，经常发生页面不断的抖动，所以首次进入页面直接跳转到大概的位置，在缓缓滑动到最大高度******
        if (_scrollController.position.maxScrollExtent > 200) {
          _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent - 200);
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      });

      //移除未读消息
      CacheMessageIsReadUtils().removeUnReadMessageId(widget.targetUuid);
      //移除有人@我标记
      CacheGroupMentionUtils().removeMentionGroupId(widget.targetUuid);

      mPubKey = await chatUtils.getAstPubKey();
      mPrivateKey = await chatUtils.getAstPrivateKey();
      // debugPrint("mPubKey===$mPubKey");
      // debugPrint("mPrivateKey===$mPrivateKey");

      asyncInitData();
    } finally {
      setState(() {
        opacityValue = 1;
      });
    }
  }

  //可以延迟更新的数据
  asyncInitData() async {
    await getGroupOfflineMessage();

    if (lastSeq != 0) {
      //群消息确认
      chatApi.groupMsgAck(
          widget.targetUuid, AppGlobals.userInfo?.uuid ?? '', lastSeq);

      // await getMessageDetail();
      //
      // //列表移动到最后一个可见元素上
      // await Future.delayed(const Duration(milliseconds: 500), () async {
      //   // if (!mounted) return;
      //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      // });
    }

    // updateGroupMember();

  }

  //更新群成员的缓存
  updateGroupMember() async {
    final data = await chatApi.groupMembers(
        widget.targetUuid, AppGlobals.userInfo?.uuid ?? '');
    if (data != null && data["code"] == 200) {
      final list = data["data"];
      if (list != null && list is List) {
        groupMemberList =
            list.map((e) => GroupMemberInfo.fromJson(e)).toList();
        // 添加群成员缓存
        ChatSPUtil().saveGroupMembers(widget.targetUuid, groupMemberList);
        groupMemberList.removeWhere((element) => element.memberId == AppGlobals.userInfo?.uuid);
        setState(() {});
      }
    }
  }

  getGroupNewMessageFromNet() async {
    try {
      final groupData =
      await chatApi.getGroupOfflineLastMessage(widget.targetUuid, lastSeq);
      //{code: 200, msg: OK, data: {msg_list: [{message_id:
      if (groupData != null && groupData["code"] == 200) {
        final list = groupData["data"]["msg_list"];
        if (list != null && list is List) {
          for (var element in list) {
            //final pushCode = element["code"];
            final base64Content = element["content"];
            List<int> byteData = base64.decode(base64Content);
            String jsonStr = utf8.decode(byteData);
            final content = json.decode(jsonStr);

            ChatMessageModel md = ChatMessageModel.fromMap(content);
            md.sMessageId=element['message_id'];
            MessageContent mc = md.content;
            if (mc.type == 90) {
              Map pushContent = json.decode(mc.pushContent ?? "");
              debugPrint("pushContent:$pushContent");
              final String? whiteUuid = pushContent["white_uuid"];
              final String? blackUuid = pushContent["black_uuid"];

              if (whiteUuid != null && whiteUuid.isNotEmpty) {
                if (AppGlobals.userInfo?.uuid == whiteUuid) {
                  await saveGroupOfflineMessage(md);
                }
              } else if (blackUuid != null && blackUuid.isNotEmpty) {
                if (AppGlobals.userInfo?.uuid != blackUuid) {
                  await saveGroupOfflineMessage(md);
                }
              } else {
                await saveGroupOfflineMessage(md);
              }
            } else {
              if (md.from != AppGlobals.userInfo?.uuid) {
                md.direction = 0;
                await saveGroupOfflineMessage(md);
              }
            }
          }
        }
      }
    } catch (_) {
      // 获取群最新消息失败时安全忽略，不影响正常使用
    }
  }

  //获取群离线消息
  getGroupOfflineMessage() async {
    try {
      final groupOfflineData =
      await chatApi.groupOfflineMsg(widget.targetUuid, lastSeq);
      if (groupOfflineData != null && groupOfflineData["code"] == 200) {
        final list = groupOfflineData["data"]["msg_list"];
        lastSeq = groupOfflineData["data"]["last_seq"];
        if (list != null && list is List) {
          for (var element in list) {
            try {
              //final pushCode = element["code"];
              final base64Content = element["content"];
              List<int> byteData = base64.decode(base64Content);
              String jsonStr = utf8.decode(byteData);
              final content = json.decode(jsonStr);

              ChatMessageModel md = ChatMessageModel.fromMap(content);
              md.sMessageId=element["message_id"];
              MessageContent mc = md.content;

              if (mc.type == 90) {
                Map pushContent = json.decode(mc.pushContent ?? "");
                // debugPrint("pushContent:$pushContent");
                final String? whiteUuid = pushContent["white_uuid"];
                final String? blackUuid = pushContent["black_uuid"];

                if (whiteUuid != null && whiteUuid.isNotEmpty) {
                  if (AppGlobals.userInfo?.uuid == whiteUuid) {
                    await saveGroupOfflineMessage(md);
                  }
                } else if (blackUuid != null && blackUuid.isNotEmpty) {
                  if (AppGlobals.userInfo?.uuid != blackUuid) {
                    await saveGroupOfflineMessage(md);
                  }
                } else {
                  await saveGroupOfflineMessage(md);
                }
              } else {
                if (md.from != AppGlobals.userInfo?.uuid) {
                  md.direction = 0;
                  await saveGroupOfflineMessage(md);
                }
              }
              eventBus.fire(
                  EventPublic(EventPublicType.updateChatConversationList));
            } catch (_) {
              // 解析单条离线消息失败时安全忽略，继续处理其他消息
            }
          }
        }
      }

      if (groupOfflineData != null && groupOfflineData["code"] == 200) {
        final hasMore = groupOfflineData["data"]["has_more"];
        if (hasMore != null && hasMore) {
          // debugPrint("groupOfflineData hasMore");
          await getGroupOfflineMessage();
        }
      }
    } catch (err) {
      debugPrint("getGroupOfflineMessage err:${err.toString()}");
    }
  }

  //群聊的离线消息 如果用户没有执行 ack 操作 每次登录都会获取到 不能重复插入数据库
  saveGroupOfflineMessage(ChatMessageModel model) async {
    if (await chatDBApi.getMessageByMessageId(model.messageId) == null) {
      await chatDBApi.saveMessage(model);
      // debugPrint(
      //     "saveGroupOfflineMessage status:$raw ${raw == 0 ? "失败" : "成功"}");
    }
  }

  //根据群ID或者对方的uuid 分页找出聊天记录
  getMessageDetail() async {
    try {
      List<ChatMessageModel>? list =
      await chatDBApi.getChatDetailByFromAndTarget(
          widget.targetUuid, lastPointTime);
      if (list != null) {
        newData = list.reversed.toList();
        // pageIndex++;
        lastPointTime = newData[0].timestamp;
      }
    } catch (_) {
      // 获取聊天详情失败时安全忽略，使用空列表
    }
  }

  //获取群信息详情
  getGroupDetail() async {
    try {
      //1 从缓存中获取群信息
      final GroupInfo? gInfo =
      await ChatSPUtil().getGroupInfoById(widget.targetUuid);
      // debugPrint("cache group info:${gInfo?.toJson().toString()}");
      if (gInfo != null) {
        groupInfo = gInfo;
        // member_type 0=退群 1=群主 2=普通成员
        if (gInfo.memberType == 1) {
          isGroupOwner = true;
        } else if (gInfo.memberType == 2) {
          isGroupMember = true;
        } else {
          isGroupOwner = false;
          isGroupMember = false;
        }
        setState(() {});
      }

      //从网络获取群组信息详情 更新缓存
      final groupData = await chatApi.groupInfo(widget.targetUuid);
      if (groupData != null && groupData["code"] == 200) {
        if (groupData["data"] != null) {
          GroupInfo gInfo = GroupInfo.fromJson(groupData["data"]);
          groupInfo = gInfo;
          // member_type 0=退群 1=群主 2=普通成员
          if (gInfo.memberType == 1) {
            isGroupOwner = true;
          } else if (gInfo.memberType == 2) {
            isGroupMember = true;
          } else {
            isGroupOwner = false;
            isGroupMember = false;
          }
          //更新群缓存
          ChatSPUtil().saveOrUpdateGroupInfo(gInfo);
        } else {
          // 群已经解散
          isUnGroup = true;
        }
      } else {
        //{"code":100005,"msg":"group not found","data":null} 群解散时
        isUnGroup = true;
      }
      setState(() {});
    } catch (err) {
      debugPrint("getGroupDetail err :${err.toString()}");
    }
  }

  void onSendMessage() async {
    try {
      if (widget.targetUuid.isEmpty) return;
      if (_textEditingController.text.trim().isEmpty) return;
      final message = _textEditingController.text.trim();
      if (groupPwd == null) {
        ToastUtils.show(S.of(context).g_chat_key_33);
        return;
      }

      String encryptedContent = AesUtils().aesEncode(message, groupPwd!);

      //@功能判断
      List<String> memberIds = handlerTextContent();
      int isMentioned = 0;
      if (memberIds.isNotEmpty) {
        isMentioned = 1;
      }
      _textEditingController.clearBlocks();

      //文本消息加密之后直接存在自己服务方便解析
      Map<String, dynamic> content = chatDataUtils.generateSendData(
          contentType: MessageContentType.Text,
          fromID: AppGlobals.userInfo?.uuid ?? '',
          receiveId: widget.targetUuid,
          conversationType: 1,
          replyId: currentReplyModel?.messageId,
          direction: 1,
          msg: encryptedContent,
          decryptionMessageContent: message,
          isMentioned: isMentioned,
          mentionedUserIds: json.encode(memberIds));

      ChatMessageModel cm = ChatMessageModel.fromMap(content);
      //先更新到ui 上
      setState(() {
        newData.add(cm);
        _textEditingController.text = "";
        currentReplyModel = null;
      });
      await chatDBApi.saveMessage(cm).then((value) {
      });

      //The list moves to the last visible element
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });

      //发送消息去掉 不加密的消息内容 防止抓包数据
      content["decryptionMessageContent"] = null;

      try {
        final data = await chatApi.sendMessage(
          fromUUID: AppGlobals.userInfo?.uuid ?? '',
          receiveId: widget.targetUuid,
          content: json.encode(content),
        );
        if (data != null && data["code"] == 200) {
          setState(() {
            int index = newData.indexOf(cm);
            if (index != -1) {
              cm.status = 1;
              newData[index] = cm;
            }
          });

          chatDBApi.updateMessage(cm).then((value) {
          });

          //埋点
          //AmplitudeUtils.sentMessage();
        } else {
          setState(() {
            int index = newData.indexOf(cm);
            if (index != -1) {
              cm.status = -1;
              newData[index] = cm;
            }
          });

          chatDBApi.updateMessage(cm).then((value) {
            debugPrint(
                "updateMessage status:$value ${value == 0 ? "失败" : "成功"}");
          });
        }
      } catch (err) {
        //err
        setState(() {
          int index = newData.indexOf(cm);
          if (index != -1) {
            cm.status = -1;
            newData[index] = cm;
          }
        });

        chatDBApi.updateMessage(cm).then((value) {
        });
      }
    } finally {
      //
    }
  }

  //发送文件
  void onSendFile(FileType type) async {
    try {
      if (widget.targetUuid.isEmpty) return;
      if (groupPwd == null) {
        ToastUtils.show(S.of(context).g_chat_key_33);
        return;
      }

      FilePickerResult? result;
      if (Platform.isIOS && type == FileType.audio) {
        //IOS 选择音频文件时不生效
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'wav',
            'aiff',
            'alac',
            'flac',
            'mp3',
            'aac',
            'wma',
            'ogg'
          ],
        );
      } else {
        result = await FilePicker.platform.pickFiles(type: type);
      }

      if (result != null) {
        File file = File(result.files.single.path!);
        // debugPrint("file path-->  ${file.path}");
        final contentType = type == FileType.image
            ? MessageContentType.Image
            : type == FileType.video
            ? MessageContentType.Video
            : MessageContentType.File;
        await handlerFile(file, contentType);
      }
    } catch (err) {
      debugPrint("err: ${err.toString()}");
    }
  }

  Future handlerFile(File file, int contentType) async {
    final filePath = file.absolute.path;
    String fileNavPath = filePath;
    FileUtils fileUtils=FileUtils();
    String fileNavName = fileUtils.getFileNameByPath(filePath);

    //定义临界值 最大支持100M
    int flagSize = 100 * 1024 * 1024;
    if (File(fileNavPath).lengthSync() > flagSize) {
      ToastUtils.show(S.current.g_key_squad_k11);
      return;
    }

    // 构建消息结构
    Map<String, dynamic> content = chatDataUtils.generateSendData(
        contentType: contentType,
        fromID: AppGlobals.userInfo?.uuid ?? '',
        receiveId: widget.targetUuid,
        conversationType: 1,
        direction: 1,
        originalFileName: fileNavName,
        //文件在ipfs上的地址
        msg: '',
        //本地文件地址
        decryptionMessageContent: fileNavPath,
        senderPubKey: mPubKey,
        receiverPubKey: otherUserPubKey);

    ChatMessageModel cm = ChatMessageModel.fromMap(content);

    //先更新到ui 上
    setState(() {
      newData.add(cm);
      _textEditingController.text = "";
    });

    //The list moves to the last visible element
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    final newPath =
    await FileAesCryptUtils().isolateCryptFile(fileNavPath, groupPwd!);

    if (newPath == null) {
      return;
    }
    MessageModel mm=await ChatUploadFile.handlerFile(widget.targetUuid, newPath, cm, content);
    if(mm.error==true){
      setState(() {
        int index = newData.indexOf(cm);
        if (index != -1) {
          cm.status = -1;
          newData[index] = cm;
        }
      });
    }
    else{
      setState(() {
        int index = newData.indexOf(cm);
        if (index != -1) {
          cm.status = 1;
          newData[index] = cm;
        }
      });
    }
    /*
    final data = await upLoadFile(newPath);
    //await compute(upLoadFile, newPath);

    if (data != null) {
      final fileName = data['Name'];
      //final fileSize = data['Size'];
      FileApi fileApi=FileApi();
      final fileServerUrl = fileApi.generateUrl(data['Hash'], fileName);
      // debugPrint("fileServerUrl : $fileServerUrl");

      //发送消息到服务器
      cm.content.searchableContent = fileServerUrl;
      await chatDBApi.saveMessage(cm).then((value) {
      });

      //发送消息去掉 不加密的消息内容 防止抓包数据
      content["decryptionMessageContent"] = null;
      content["content"]["searchableContent"] = fileServerUrl;
      content["content"]["originalFileName"] = fileName;

      try {
        final data = await chatApi.sendMessage(
          fromUUID: AppGlobals.userInfo?.uuid ?? '',
          receiveId: widget.targetUuid,
          content: json.encode(content),
        );

        if (data != null && data["code"] == 200) {
          setState(() {
            int index = newData.indexOf(cm);
            if (index != -1) {
              cm.status = 1;
              newData[index] = cm;
            }
            //cm.sMessageId=data['data'];
          });

          chatDBApi.updateMessage(cm).then((value) {
          });
          //埋点
          //AmplitudeUtils.sentMessage();
        } else {
          setState(() {
            int index = newData.indexOf(cm);
            if (index != -1) {
              cm.status = -1;
              newData[index] = cm;
            }
          });
          chatDBApi.updateMessage(cm).then((value) {
          });
        }
      } catch (err) {
        setState(() {
          int index = newData.indexOf(cm);
          if (index != -1) {
            cm.status = -1;
            newData[index] = cm;
          }
        });

        chatDBApi.updateMessage(cm).then((value) {
        });
      }
    }
    else {
      //上传到 ipfs 失败
      setState(() {
        int index = newData.indexOf(cm);
        if (index != -1) {
          cm.status = -1;
          newData[index] = cm;
        }
      });
    }
    */
  }

  //发送拍照文件
  Future cameraFile() async {
    try{
      if (widget.targetUuid.isEmpty) return;
      if (groupPwd == null) {
        ToastUtils.show(S.of(context).g_chat_key_33);
        return;
      }
      final ImagePicker picker = ImagePicker();
      final XFile? photo =
      await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
      debugPrint("photo path:${photo?.name} path=${photo?.path}");
      if (photo != null) {
        //name: b2ededad-af44-4b14-b1a4-3b42c522d8ef3434912846439144868.jpg
        // path: /data/user/0/com.walletamaze.nftwallet/cache/b2ededad-af44-4b14-b1a4-3b42c522d8ef3434912846439144868.jpg
        File file = File(photo.path);
        handlerFile(file, MessageContentType.Image);
      }
    }
    catch (err) {
      debugPrint("err: ${err.toString()}");
    }
  }

  //File upload is encapsulated as a top-level function
  Future<dynamic> upLoadFile(filePath) async {
    return await IpfsApi().uploadIPFSImage(filePath, "a", (int count, int total) {},type: 0);
    /*FileApi fileApi=FileApi();
    final data =
    await fileApi.upLoadFileToIpfs(filePath, (int count, int total) {
      // debugPrint("count $count total $total");
    });
    return data;*/
  }

  void onSendRedPocket(RedPocketModel redPocketModel)async{
    try {
      if (widget.targetUuid.isEmpty) return;
      //if (_textEditingController.text.trim().isEmpty) return;
      //final message = _textEditingController.text.trim();
      if (groupPwd == null) {
        ToastUtils.show(S.of(context).g_chat_key_33);
        return;
      }
      String message=json.encode(redPocketModel.toJson());
      String encryptedContent = AesUtils().aesEncode(message, groupPwd!);

      //@功能判断
      List<String> memberIds = handlerTextContent();
      int isMentioned = 0;
      if (memberIds.isNotEmpty) {
        isMentioned = 1;
      }
      _textEditingController.clearBlocks();

      //文本消息加密之后直接存在自己服务方便解析
      Map<String, dynamic> content = chatDataUtils.generateSendData(
          contentType: MessageContentType.RedEnvelope,
          fromID: AppGlobals.userInfo?.uuid ?? '',
          receiveId: widget.targetUuid,
          conversationType: 1,
          replyId: currentReplyModel?.messageId,
          direction: 1,
          msg: encryptedContent,
          decryptionMessageContent: message,
          isMentioned: isMentioned,
          mentionedUserIds: json.encode(memberIds));

      ChatMessageModel cm = ChatMessageModel.fromMap(content);
      //先更新到ui 上
      setState(() {
        newData.add(cm);
        _textEditingController.text = "";
        currentReplyModel = null;
      });
      await chatDBApi.saveMessage(cm).then((value) {
        debugPrint("saveMessage:$value ${value == 0 ? "fail" : "success"}");
      });

      //The list moves to the last visible element
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });

      //发送消息去掉 不加密的消息内容 防止抓包数据
      content["decryptionMessageContent"] = null;

      try {
        final data = await chatApi.sendMessageRed(
          fromUUID: AppGlobals.userInfo?.uuid ?? '',
          receiveId: widget.targetUuid,
          content: json.encode(content),
          count: redPocketModel.number??0,
          value: redPocketModel.value??0,//ethToWeiString((redPocketModel.value??0).toString(), 18).toString(),
          txRaw: redPocketModel.txRaw??"",
          type: redPocketModel.distribution??2,
          description: redPocketModel.note??"",
        );
        if (data != null && data["code"] == 200) {
          setState(() {
            int index = newData.indexOf(cm);
            if (index != -1) {
              cm.status = 1;
              newData[index] = cm;
            }
            cm.sMessageId=data['data'];
          });

          chatDBApi.updateMessage(cm).then((value) {
          });

          //埋点
          //AmplitudeUtils.sentMessage();
        }
        else {
          setState(() {
            int index = newData.indexOf(cm);
            if (index != -1) {
              cm.status = -1;
              newData[index] = cm;
            }
          });

          chatDBApi.updateMessage(cm).then((value) {
          });
        }
      } catch (err) {
        //err
        setState(() {
          int index = newData.indexOf(cm);
          if (index != -1) {
            cm.status = -1;
            newData[index] = cm;
          }
        });

        chatDBApi.updateMessage(cm).then((value) {
        });
      }
    } finally {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ScreenUtil().setWidth(72),
              height: ScreenUtil().setWidth(72),
              //超出部分，可裁剪
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(120)),
                  border: Border.all(
                      width: 0.5,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemLineColor.name))),
              child: ImageNetWork(
                imageUrl: groupInfo?.avatarUrl ?? "",
                width: ScreenUtil().setWidth(68),
                placeholder: "assets/chat/group_def_icon.png",
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(16),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    groupInfo?.name ?? "",
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
        actions: [
          if (!isUnGroup && !_isLoading)
            GestureDetector(
              onTap: () async {
                if (groupInfo == null) return;
                // if (groupMemberList.isEmpty) return;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => GroupDetailPage(
                      info: groupInfo!,
                    )));
              },
              child: Padding(
                padding: EdgeInsets.only(right: ScreenUtil().setWidth(24)),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
            )
        ],
      ),
      extendBody: true,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: NotificationListener(
                      onNotification: (notification) {
                        if (notification is ScrollNotification) {
                          if (notification.metrics is PageMetrics) {
                            return false;
                          }
                          if (notification.metrics is FixedScrollMetrics) {
                            if (notification.metrics.axisDirection ==
                                AxisDirection.left ||
                                notification.metrics.axisDirection ==
                                    AxisDirection.right) {
                              return false;
                            }
                          }
                          extentAfter = notification.metrics.extentAfter;
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: () async {
                          //加载更多缓存数据
                          List<ChatMessageModel>? list =
                          await chatDBApi.getChatDetailByFromAndTarget(
                              widget.targetUuid, lastPointTime);
                          if (list != null) {
                            // loadMoreData.addAll(list.reversed.toList());
                            loadMoreData.addAll(list.toList());
                            lastPointTime = list[list.length - 1].timestamp;
                            setState(() {});
                          }
                        },
                        child: _isLoading
                            ? const Loading()
                            : Opacity(
                          opacity: opacityValue,
                          child: CustomScrollView(
                            controller: _scrollController,
                            center: centerKey,
                            physics: _physics,
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                    ChatMessageModel item = loadMoreData[index];
                                    bool isCurrentUser = item.direction == 1;
                                    //处理时间的展示 间隔5分钟展示一次时间
                                    String? timeStr;
                                    final bool isToday =
                                    flustars.DateUtil.isToday(item.timestamp);

                                    if (index > 0) {
                                      ChatMessageModel? previousItem = index > 0
                                          ? loadMoreData[index - 1]
                                          : null;
                                      Duration? timeInterval = previousItem !=
                                          null
                                          ? DateTime.fromMillisecondsSinceEpoch(
                                          item.timestamp)
                                          .difference(DateTime
                                          .fromMillisecondsSinceEpoch(
                                          previousItem.timestamp))
                                          : null;
                                      if (timeInterval != null &&
                                          timeInterval.inMinutes >= 2) {
                                        timeStr = dataUtils.getTimeByTimeStamp(
                                            '${item.timestamp}',
                                            format: isToday
                                                ? "HH:mm"
                                                : "dd/MM/yy HH:mm");
                                      }
                                    } else {
                                      timeStr = dataUtils.getTimeByTimeStamp(
                                          '${item.timestamp}',
                                          format: isToday
                                              ? "HH:mm"
                                              : "dd/MM/yy HH:mm");
                                    }

                                    return ItemGroupChatView(
                                      key: ValueKey(item.messageId),
                                      isCurrentUser: isCurrentUser,
                                      item: item,
                                      mPrivateKey: mPrivateKey ?? '',
                                      time: timeStr,
                                      type10OnTap: item.content.type==10?()async{
                                        MessageModel rmm=await chatApi.getRedDetails(messageId: item.sMessageId??0);
                                        if(rmm.error){
                                          ToastUtils.show(rmm.data);
                                        }else{
                                          redPocketMessage=item;
                                          redPocketMessage!.redPocketDetailModel=RedPocketDetailModel.fromJson(rmm.data);
                                        }
                                        setState(() {});
                                      }:null,
                                    );
                                  },
                                  childCount: loadMoreData.length,
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.zero,
                                key: centerKey,
                              ),
                              SliverList(
                                // key: centerKey,
                                delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                    ChatMessageModel item = newData[index];
                                    bool isCurrentUser = item.direction == 1;

                                    //处理时间的展示 间隔5分钟展示一次时间
                                    String? timeStr;
                                    final bool isToday =
                                    flustars.DateUtil.isToday(item.timestamp);

                                    if (index > 0) {
                                      ChatMessageModel? previousItem =
                                      index > 0 ? newData[index - 1] : null;
                                      Duration? timeInterval = previousItem !=
                                          null
                                          ? DateTime.fromMillisecondsSinceEpoch(
                                          item.timestamp)
                                          .difference(DateTime
                                          .fromMillisecondsSinceEpoch(
                                          previousItem.timestamp))
                                          : null;
                                      if (timeInterval != null &&
                                          timeInterval.inMinutes >= 2) {
                                        timeStr = dataUtils.getTimeByTimeStamp(
                                            '${item.timestamp}',
                                            format: isToday
                                                ? "HH:mm"
                                                : "dd/MM/yy HH:mm");
                                      }
                                    } else {
                                      timeStr = dataUtils.getTimeByTimeStamp(
                                          '${item.timestamp}',
                                          format: isToday
                                              ? "HH:mm"
                                              : "dd/MM/yy HH:mm");
                                    }

                                    return ItemGroupChatView(
                                      key: ValueKey(item.messageId),
                                      isCurrentUser: isCurrentUser,
                                      item: item,
                                      mPrivateKey: mPrivateKey ?? '',
                                      time: timeStr,
                                      type10OnTap: item.content.type==10?()async{
                                        MessageModel rmm=await chatApi.getRedDetails(messageId: item.sMessageId??0);
                                        if(rmm.error){
                                          ToastUtils.show(rmm.data);
                                        }else{
                                          redPocketMessage=item;
                                          redPocketMessage!.redPocketDetailModel=RedPocketDetailModel.fromJson(rmm.data);
                                        }
                                        setState(() {});
                                      }:null,
                                    );
                                  },
                                  childCount: newData.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).brightness == Brightness.dark ? const  Color(0xff444444) :const  Color(0xffD9D9D9),
                    endIndent: 1,
                    indent: 1,
                  ),
                  //群未解散，且必须是群成员或者群主
                  !isUnGroup && (isGroupMember || isGroupOwner)
                      ? Column(
                    children: [
                      //回复消息时 展示布局
                      if (currentReplyModel != null)
                        Column(
                          children: [
                            BottomInputChatReplyWidget(
                              onCloseTap: () {
                                setState(() {
                                  currentReplyModel = null;
                                });
                              },
                              item: currentReplyModel!,
                              friendName: currentReplyModel!.direction == 1
                                  ? AppGlobals.userInfo?.name
                                  : replyUserName,
                            ),
                            // const SizedBox(height: 10,)
                          ],
                        ),

                      Container(
                        color: Theme.of(context).brightness == Brightness.dark ? const  Color(0xff1E1E1E) :const  Color(0xfff6f6f6),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(28)),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: (){
                                  bottomWidget();
                                },
                                child: SizedBox(
                                  width: ScreenUtil().setWidth(48.0),
                                  height: ScreenUtil().setWidth(48.0),
                                  child: Image.asset(
                                    "assets/chat/Add1.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil().setWidth(20), vertical: ScreenUtil().setWidth(20)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: ScreenUtil().setWidth(20)),
                                    decoration: BoxDecoration(
                                      // color: AppThemeUtils.getColorByKey(
                                      //     context, AppThemeKeys.mainBoxColor),
                                        color: Theme.of(context).brightness == Brightness.dark ? const  Color(0xff232323) :const  Color(0xffffffff),
                                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                                        border: groupPwd == null
                                            ? null
                                            : Border.all(
                                          // color:
                                          //     AppThemeUtils.getColorByKey(
                                          //         context,
                                          //         AppThemeKeys
                                          //             .mainBoxColor)
                                          color: Theme.of(context).brightness == Brightness.dark ? const  Color(0xff444444) :const  Color(0xffD9D9D9),
                                        )
                                    ),
                                    constraints: BoxConstraints(
                                        minHeight: ScreenUtil().setWidth(60), maxHeight: ScreenUtil().setWidth(300)),
                                    child: groupPwd == null
                                        ? Padding(
                                      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                                      child:
                                      Text(S.of(context).g_chat_key_33),
                                    )
                                        : Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            maxLines: null,
                                            keyboardType:
                                            TextInputType.multiline,
                                            decoration: InputDecoration(
                                              hintStyle: TextStyle(
                                                  fontSize: ScreenUtil().setSp(28),
                                                  color: AppThemeUtils
                                                      .getColorByKey(
                                                      context,
                                                      AppThemeKeys
                                                          .ff888888.name)),
                                              isDense: true,
                                              // hintText: S.of(context).message,
                                              contentPadding:
                                              EdgeInsets
                                                  .symmetric(
                                                  horizontal: ScreenUtil().setWidth(24),
                                                  vertical: ScreenUtil().setWidth(20)),
                                              border:
                                              const OutlineInputBorder(
                                                  borderSide:
                                                  BorderSide.none),
                                              enabledBorder:
                                              const OutlineInputBorder(
                                                  borderSide:
                                                  BorderSide.none),
                                              focusedBorder:
                                              const OutlineInputBorder(
                                                  borderSide:
                                                  BorderSide.none),
                                              // border: InputBorder.none,
                                            ),
                                            style: TextStyle(
                                              color: AppThemeUtils
                                                  .getColorByKey(
                                                  context,
                                                  AppThemeKeys
                                                      .mainTextColor.name),
                                              fontSize: ScreenUtil().setSp(32),
                                            ),
                                            controller:
                                            _textEditingController,
                                            focusNode: _focusNode,
                                            onChanged: (val) {
                                              // 处理文本输入变化
                                              _handleTextChange(
                                                  context, val);
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              rightIcon()
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                      : const SizedBox(),
                ],
              ),
            ),
            /*Positioned.fill(
              child: Visibility(
                visible: redPocketMessage !=null,
                child: ShowMessageType10(redPocketMessage,(){
                  setState(() {redPocketMessage=null;});
                }),
              ),
            ),*/
          ],
        ),
      ),

    );
  }
  bottomWidget(){
    Widget swapWidget = Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          bottomItem("assets/chat/gallery.png",S.of(context).g_chat_key_47,(){
            Navigator.of(context).pop();
            onSendFile(FileType.image);
          }),
          bottomItem("assets/chat/video.png",S.of(context).g_chat_key_46,(){
            Navigator.of(context).pop();
            onSendFile(FileType.video);
          }),
          bottomItem("assets/chat/document.png",S.of(context).file,(){
            Navigator.of(context).pop();
            onSendFile(FileType.any);
          }),
        ],
      ),
    );
    SheetBottom(
      context,
      "Action",
      swapWidget,
    );
  }
  bottomItem(String imgStr,String title,dynamic onTap){
    return InkWell(
      onTap: (){
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: ScreenUtil().setWidth(1.0),color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name))),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(48.0),
              height: ScreenUtil().setWidth(48.0),
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
              child: Image.asset(imgStr,),
            ),
            Expanded(
              flex: 1,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32.0),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  rightIcon() {
    return GestureDetector(
      child: Image.asset(
        "assets/chat/send.png",
        width: ScreenUtil().setWidth(48),
        fit: BoxFit.cover,
        color: canSendText
            ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
            : AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
      ),
      onTap: () async {
        onSendMessage();
      },
    );
    /*if (canSendText) {
      return GestureDetector(
        child: Image.asset(
          "assets/chat/send.png",
          width: ScreenUtil().setWidth(48),
          fit: BoxFit.cover,
          color: canSendText
              ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
              : AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
        ),
        onTap: () async {
          onSendMessage();
        },
      );
    }
    return GestureDetector(
      child: Image.asset(
        "assets/chat/xiangji.png",
        width: ScreenUtil().setWidth(48),
        fit: BoxFit.cover,
        color: canSendText
            ? Colors.transparent
            : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
      ),
      onTap: () async {
        cameraFile();
      },
    );*/
  }

  String lastInputText = '';

  void _handleTextChange(BuildContext context, String text) {
    if (text.contains('@')) {
      if (text != lastInputText && text.length > lastInputText.length) {
        int count = _countAtSymbol(text);
        int lastHaveCount = _countAtSymbol(lastInputText);
        if (count > lastHaveCount) {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return BottomGroupMemberDialog(
                  groupId: widget.targetUuid,
                  callBack: (value) {
                    GroupMemberInfo info = value;
                    _textEditingController.insertBlock(RichBlock(
                        text: '${info.displayName} ',
                        data: '**${info.displayName}**',
                        value: info,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name),
                        )));
                    //final text = _controller.data;
                  },
                );
              });
        }
      }
    }

    lastInputText = text;
  }

  int _countAtSymbol(String text) {
    return text.split('@').length - 1;
  }

  List<String> handlerTextContent() {
    final blocks = _textEditingController.blocks;
    List<String> uuids = [];
    for (var element in blocks) {
      uuids.add((element.value as GroupMemberInfo).memberId!);
    }
    return uuids;
  }
}
class ShowMessageType10 extends StatefulWidget {
  final ChatMessageModel? chatMessage;
  final dynamic closeOnTap;
  const ShowMessageType10(this.chatMessage,this.closeOnTap,{super.key});

  @override
  State<ShowMessageType10> createState() => _ShowMessageType10State();
}

class _ShowMessageType10State extends State<ShowMessageType10> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  Load loadOpen=Load.finish;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(widget.chatMessage==null)return SizedBox();
    Widget child;
    if(widget.chatMessage!.redPocketDetailModel?.claimed == 1) {
      //当前用户已经领取了红包
      child= userRedPocetOpened();
    }else{
      if(widget.chatMessage!.redPocketDetailModel?.remainCount==0){
        child= userRedPocetFinish();
      }else{
        child= userRedPocketOpen();
      }
    }

    return InkWell(
      onTap: (){
        widget.closeOnTap();
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.transparentBgColor.name),
        child: Center(
          child: Container(
            width: ScreenUtil().setWidth(512.0),
            height: ScreenUtil().setWidth(734.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
              color: Color(0xfffa3f3f),
            ),
            clipBehavior: Clip.hardEdge,
            child: child,
          ),
        ),
      ),
    );
  }
  userRedPocketOpen(){
    Map<String,dynamic> content=json.decode(widget.chatMessage?.decryptionMessageContent??"{}");
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: ScreenUtil().setWidth(274.0),
          child: Image.asset("assets/chat/redPocket1.png",fit: BoxFit.fitWidth,),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: (){
                        widget.closeOnTap();
                      },
                      child: Container(
                        width: ScreenUtil().setWidth(60.0),
                        height: ScreenUtil().setWidth(60.0),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                        child: Icon(
                          Icons.close,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                        ),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: ()async{
                    if(loadOpen==Load.loading)return;
                    setState(() {
                      loadOpen=Load.loading;
                    });
                    MessageModel rmm=await chatApi.getRedReceive(messageId: widget.chatMessage?.sMessageId??0);
                    if(rmm.error){
                      ToastUtils.show(rmm.data);
                    }else{
                      widget.chatMessage!.redPocketDetailModel!.claimed=1;
                      widget.chatMessage!.redPocketDetailModel!.value=(rmm.data['value'] as num).toDouble();
                    }
                    MessageModel rmm1=await chatApi.getRedDetails(messageId: widget.chatMessage?.sMessageId??0);
                    if(rmm1.error){
                      ToastUtils.show(rmm1.data);
                    }else{
                      widget.chatMessage!.redPocketDetailModel=RedPocketDetailModel.fromJson(rmm1.data);
                    }
                    setState(() {
                      loadOpen=Load.finish;
                    });
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(150.0),
                    height: ScreenUtil().setWidth(150.0),
                    margin: EdgeInsets.only(top: ScreenUtil().setWidth(120.0),bottom: ScreenUtil().setWidth(50.0)),
                    decoration: BoxDecoration(
                      color: Color(0xffFFDA44),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(150.0)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Open",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(48.0),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  height: ScreenUtil().setWidth(100.0),
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(30.0)),
                  child: Text(
                    widget.chatMessage?.redPocketDetailModel?.description??"",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  "From",
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28.0),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(20.0),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: ScreenUtil().setSp(60.0),
                      height: ScreenUtil().setSp(60.0),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(60.0)),
                      ),
                      child: ImageNetWork(
                        imageUrl: content['avatar']??"",
                        width: ScreenUtil().setSp(60.0),
                        placeholder: "assets/chat/user_def_icon.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                          minWidth: 0,
                          maxWidth: ScreenUtil().setWidth(300.0)
                      ),
                      child: Text(
                        content['nickname']??"",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Visibility(
            visible: loadOpen==Load.loading,
            child: Center(
              child: SizedBox(
                width: ScreenUtil().setWidth(60.0),
                height: ScreenUtil().setWidth(60.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ],
    );
  }
  userRedPocetOpened(){
    RedPocketClaimModel? rpcm=getClaim(AppGlobals.userInfo?.uuid??"");
    Map<String,dynamic> content=json.decode(widget.chatMessage?.decryptionMessageContent??"{}");
    String message="Error";
    if(rpcm !=null){
      if(rpcm.status==0){
        message="You will receive the above amount in 20s";
      }else if(rpcm.status==2){
        message="Fully claimed.";
      }else{
        message="Claim successful.";
      }
    }
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: ScreenUtil().setWidth(524.0),
          child: Image.asset("assets/chat/redPocket2.png",fit: BoxFit.fitWidth,),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(10.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: (){
                        widget.closeOnTap();
                      },
                      child: Container(
                        width: ScreenUtil().setWidth(60.0),
                        height: ScreenUtil().setWidth(60.0),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                        child: Icon(
                          Icons.close,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(96.0),
                  height: ScreenUtil().setWidth(96.0),
                  child: Image.asset("assets/img/ast.png",fit: BoxFit.cover,),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0)),
                  alignment: Alignment.center,
                  child: Text(
                    "${rpcm?.value??0} ${CoinType.N.name}",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(60.0),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RedPocketGroup3(widget.chatMessage)));
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                    alignment: Alignment.center,
                    child: Text(
                      "Details >",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28.0),
                        fontWeight: FontWeight.w700,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30.0)),
                  child: RichText(
                    text: TextSpan(
                        text: "$message ",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28.0),
                          fontWeight: FontWeight.w400,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                        ),
                        children: [
                          TextSpan(
                            text: 'View >',
                            style: TextStyle(
                              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                              fontWeight: FontWeight.w700,
                              fontSize: ScreenUtil().setSp(28.0),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                String openUrl=getBrowser_txHash(CoinType.N.name, rpcm?.txHash??"");
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>BrowserPage(openUrl)));
                              },
                          ),
                        ]
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Spacer(),
                Container(
                  height: ScreenUtil().setWidth(100.0),
                  width: double.infinity,
                  alignment: Alignment.center,
                  //margin: EdgeInsets.only(bottom: scr.setWidth(50.0)),
                  child: Text(
                    widget.chatMessage?.redPocketDetailModel?.description??"",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: ScreenUtil().setSp(60.0),
                      height: ScreenUtil().setSp(60.0),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(60.0)),
                      ),
                      child: ImageNetWork(
                        imageUrl: content['avatar']??"",
                        width: ScreenUtil().setSp(60.0),
                        placeholder: "assets/chat/user_def_icon.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 0,
                        maxWidth: ScreenUtil().setWidth(300.0),
                      ),
                      child: Text(
                        content['nickname']??"",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(20.0),),
              ],
            ),
          ),
        ),
      ],
    );
  }
  userRedPocetFinish(){
    //RedPocketClaimModel? rpcm=getClaim(AppGlobals.userInfo?.uuid??"");
    Map<String,dynamic> content=json.decode(widget.chatMessage?.decryptionMessageContent??"{}");
    String message="Hands are slow.";
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: ScreenUtil().setWidth(524.0),
          child: Image.asset("assets/chat/redPocket2.png",fit: BoxFit.fitWidth,),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0),vertical: ScreenUtil().setWidth(10.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: (){
                        widget.closeOnTap();
                      },
                      child: Container(
                        width: ScreenUtil().setWidth(60.0),
                        height: ScreenUtil().setWidth(60.0),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(10.0)),
                        child: Icon(
                          Icons.close,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(96.0),
                  height: ScreenUtil().setWidth(96.0),
                  child: Image.asset("assets/img/ast.png",fit: BoxFit.cover,),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: ScreenUtil().setWidth(10.0)),
                  alignment: Alignment.center,
                  child: Text(
                    "0 ${CoinType.N.name}",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(60.0),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RedPocketGroup3(widget.chatMessage)));
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
                    alignment: Alignment.center,
                    child: Text(
                      "Details >",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28.0),
                        fontWeight: FontWeight.w700,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30.0)),
                  alignment: Alignment.center,
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32.0),
                      fontWeight: FontWeight.w400,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  height: ScreenUtil().setWidth(100.0),
                  width: double.infinity,
                  alignment: Alignment.center,
                  //margin: EdgeInsets.only(bottom: scr.setWidth(50.0)),
                  child: Text(
                    widget.chatMessage?.redPocketDetailModel?.description??"",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32.0),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: ScreenUtil().setSp(60.0),
                      height: ScreenUtil().setSp(60.0),
                      margin: EdgeInsets.only(right: ScreenUtil().setWidth(10.0)),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(60.0)),
                      ),
                      child: ImageNetWork(
                        imageUrl: content['avatar']??"",
                        width: ScreenUtil().setSp(60.0),
                        placeholder: "assets/chat/user_def_icon.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 0,
                        maxWidth: ScreenUtil().setWidth(300.0),
                      ),
                      child: Text(
                        content['nickname']??"",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28.0),
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainWhiteColor.name),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(20.0),),
              ],
            ),
          ),
        ),
      ],
    );
  }
  getClaim(String uuid){
    int? index = widget.chatMessage?.redPocketDetailModel?.redClaim?.indexWhere((element) {
      if(element.uuid==uuid){
        return true;
      }
      return false;
    });
    if(index !=null && index !=-1){
      return widget.chatMessage!.redPocketDetailModel!.redClaim![index];
    }
    return null;
  }
}

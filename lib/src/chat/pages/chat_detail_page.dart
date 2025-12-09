import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/api/file_api.dart';
import 'package:n42appv2/src/chat/api/squad_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/provider/chat_message_provider.dart';
import 'package:n42appv2/src/chat/provider/chat_upload_file.dart';
import 'package:n42appv2/src/chat/provider/message_content_type.dart';
import 'package:n42appv2/src/chat/utils/aes_utils.dart';
import 'package:n42appv2/src/chat/utils/cache_read_message_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_data_util.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/chat/utils/chat_util.dart';
import 'package:n42appv2/src/chat/utils/password_gen.dart';
import 'package:n42appv2/src/chat/widgets/bottom_input_chat_reply_widget.dart';
import 'package:n42appv2/src/chat/widgets/chat_bottom_dialog.dart';
import 'package:n42appv2/src/chat/widgets/file_aes_crypt_utils.dart';
import 'package:n42appv2/src/chat/widgets/file_utils.dart';
import 'package:n42appv2/src/chat/widgets/item_chat_view.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/https/ipfs_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/utils/base64_utils.dart';
import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:n42appv2/src/utils/event_bus.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_1.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart' as flustars;
import 'package:n42appv2/src/chat/widgets/report_post.dart';

class ChatDetailPage extends StatefulWidget {
  //聊天对象的uuid
  final String targetUuid;

  // 0 单聊 1群组
  final int conversationType;
  const ChatDetailPage({required this.targetUuid, required this.conversationType,super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    if(_chatApi==null){
      _chatApi=ChatApi();
    }
    return _chatApi!;
  }
  ChatDataUtil? _chatDataUtils;
  ChatDataUtil get chatDataUtils{
    if(_chatDataUtils==null){
      _chatDataUtils=ChatDataUtil();
    }
    return _chatDataUtils!;
  }
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    if(_dataUtils==null){
      _dataUtils= DataUtils();
    }
    return _dataUtils!;
  }
  ChatDBApi? _chatDBApi;
  ChatDBApi get chatDBApi{
    if(_chatDBApi==null){
      _chatDBApi=ChatDBApi();
    }
    return _chatDBApi!;
  }
  ChatUtil? _chatUtil;
  ChatUtil get chatUtil{
    if(_chatUtil==null){
      _chatUtil= ChatUtil();
    }
    return _chatUtil!;
  }
  SquadApi? _squadApi;
  SquadApi get squadApi{
    if(_squadApi==null){
      _squadApi= SquadApi();
    }
    return _squadApi!;
  }
  final CustomPopupMenuController _addController = CustomPopupMenuController();
  final CustomPopupMenuController menuPopController =
  CustomPopupMenuController();
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  var centerKey = GlobalKey();
  final ScrollPhysics _physics = const ClampingScrollPhysics();

  final FocusNode _focusNode = FocusNode();

  //下拉刷新时 放入loadMoreData数据集合中
  List<ChatMessageModel> loadMoreData = [];

  //首次进入加载数据到newData中
  List<ChatMessageModel> newData = [];

  //bool _isLoading = false;
  Load load=Load.finish;

  double opacityValue = 0;

  bool canSendText = false;

  String? otherUserPubKey;
  String? mPubKey;
  String? mPrivateKey;

  int pageIndex = 0;

  //采用时间分页查询 防止数据重复
  int lastPointTime = DateTime.now().millisecondsSinceEpoch;

  //好友信息
  FriendInfo? info;

  String? friendName;
  String? friendEmail;

  //当前正在回复的消息
  ChatMessageModel? currentReplyModel;
  var eventBusFn;
  
  // 保存 ChatMessageProvider 的引用，避免在 dispose 中访问已停用的 context
  ChatMessageProvider? _chatMessageProvider;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 didChangeDependencies 中保存 Provider 引用
    _chatMessageProvider = Provider.of<ChatMessageProvider>(context, listen: false);
    //设置正在聊天的对象
    _chatMessageProvider?.setTargetUuid(widget.targetUuid);
  }
  
  @override
  void initState() {
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

    initData();

    addMessageListener();
  }

  @override
  void dispose() {
    // 使用保存的引用而不是通过 context 访问，避免访问已停用的 widget
    _chatMessageProvider?.setTargetUuid(null);
    _scrollController.dispose();
    _textEditingController.dispose();
    _addController.dispose();
    _focusNode.dispose();
    eventBusFn?.cancel();
    super.dispose();
  }

  addMessageListener() {
    eventBusFn=eventBus.on().listen((event) {
      if (event is EventPublic && event.type == EventPublicType.chatMessage) {
        // debugPrint("EventPublicType.chatMessage: 收到监听消息了");
        ChatMessageModel model = event.param as ChatMessageModel;
        //如果发送人不是当前和我聊天的用户 不展示消息
        if (model.targetId != widget.targetUuid) {
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
        setState(() {});
      }
    });
  }

  void textFocusListener() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  initData() async {
    //获取聊天记录
    await getMessageDetail();
    //移除未读消息
    CacheMessageIsReadUtils().removeUnReadMessageId(widget.targetUuid);
    await getFriendDetail();
    mPubKey = await chatUtil.getAstPubKey();
    mPrivateKey = await chatUtil.getAstPrivateKey();

    if (friendEmail != null) {
      //获取对方的公钥
      MessageModel userData = await squadApi.getUserPubKey(friendEmail ?? '');
      if(userData.error){
        if(userData.type==MessageErrorType.E1403){
          await TipsDialog1(context, S.of(context).g_key_error_1403);
          Application.logout();
          Navigator.pop(context);
        }else{
          ToastUtils.show(userData.data);
        }
      }else{
        otherUserPubKey = userData.data;
      }
    }
    setState(() {});
  }

  //根据群ID或者对方的uuid 分页找出聊天记录
  getMessageDetail() async {
    try {
      setState(() {
        load=Load.loading;
        //_isLoading = true;
      });
      List<ChatMessageModel>? list =
      await chatDBApi.getChatDetailByFromAndTarget(
          widget.targetUuid, lastPointTime);
      if (list != null) {
        setState(() {
          newData = list.reversed.toList();
          load=Load.finish;
          //_isLoading = false;
          lastPointTime = newData[0].timestamp;
          // pageIndex++;
        });
        await Future.delayed(const Duration(milliseconds: 800), () async {
          if (!mounted) return;
          //*****这里直接跳转到maxScrollExtent位置时，经常发生页面不断的抖动，所以首次进入页面直接跳转到大概的位置，在缓缓滑动到最大高度******
          final maxScrollExtent = _scrollController.position.maxScrollExtent;
          if (maxScrollExtent > 500) {
            _scrollController.jumpTo((maxScrollExtent / 2));
          }
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        });
      }
    } finally {
      setState(() {
        load=Load.finish;
        //_isLoading = false;
        opacityValue = 1;
      });
    }
  }

  //是否与联系人仍然是好友关系
  bool isFriend = true;

  //获取用户详情
  getFriendDetail() async {
    info = await ChatSPUtil().getNavUserInfo(widget.targetUuid);
    if (info != null) {
      friendEmail = info!.email;
      friendName = info!.name;
      setState(() {});
    }

    //2 从网络获取
    final userData = await chatApi.getUserInfo(widget.targetUuid);
    if (userData != null && userData["code"] == 200) {
      info = FriendInfo.fromJson(userData["data"]);
      friendEmail = info!.email;
      friendName = info!.name;
      //更新缓存
      ChatSPUtil().saveOrUpdateUserInfo(info!);
    }
  }

  ///发送文本消息
  void onSendMessage() async {
    try {
      if (widget.targetUuid.isEmpty) return;
      if (_textEditingController.text.trim().isEmpty) return;
      final message = _textEditingController.text.trim();
      if (mPubKey == null) return;
      if (otherUserPubKey == null ||
          (otherUserPubKey != null && otherUserPubKey!.isEmpty)) {
        if (friendEmail != null) {
          //获取对方的公钥
          MessageModel userData = await squadApi.getUserPubKey(friendEmail ?? '');
          if(userData.error){
            if(userData.type==MessageErrorType.E1403){
              await TipsDialog1(context, S.of(context).g_key_error_1403);
              Application.logout();
              Navigator.pop(context);
            }else{
              ToastUtils.show(userData.data);
              return;
            }
          }else{
            otherUserPubKey = userData.data;
          }
        }
      }
      if (otherUserPubKey == null ||
          (otherUserPubKey != null && otherUserPubKey!.isEmpty)) {
        //提醒：对方没有钱包地址 无法接收消息
        ToastUtils.show(
            "The other party does not have a wallet address and cannot receive messages！");
        return;
      }

      String passWord = generatePassword();

      final mSecrtData = await chatUtil.chatEnCode(mPubKey ?? '',
          bytesToHex(Uint8List.fromList(passWord.codeUnits)));
      debugPrint("mSecrtData: $mSecrtData");
      final otherSecrtData = await chatUtil.chatEnCode(otherUserPubKey ?? '',
          bytesToHex(Uint8List.fromList(passWord.codeUnits))
      );
      debugPrint("otherSecrtData: $otherSecrtData");

      String encryptedContent = AesUtils().aesEncode(message, passWord);
      Base64Utils base64Utils=Base64Utils();
      // 构建消息结构
      Map<String, dynamic> content = chatDataUtils.generateSendData(
          contentType: MessageContentType.Text,
          fromID: Application.userInfo?.uuid ?? '',
          receiveId: widget.targetUuid ?? '',
          conversationType: 0,
          reply_id: currentReplyModel?.messageId,
          direction: 1,
          msg: encryptedContent,
          decryptionMessageContent: message,
          senderAesSecret: base64Utils.encodeBase64(mSecrtData ?? ''),
          receiverAesSecret: base64Utils.encodeBase64(otherSecrtData ?? ''),
          senderPubKey: mPubKey,
          receiverPubKey: otherUserPubKey);

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

      // debugPrint("content====:${json.encode(content)}");

      try {
        final data = await chatApi.sendMessage(
          fromUUID: Application.userInfo?.uuid ?? '',
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
          debugPrint("send message err ！！！");
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
        debugPrint("send message err :${err.toString()}");
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
      // if (EasyLoading.isShow) {
      //   EasyLoading.dismiss();
      // }
    }
  }

  //发送文件
  void onSendFile(FileType type) async {
    try {
      if (mPubKey == null) return;
      if (otherUserPubKey == null ||
          (otherUserPubKey != null && otherUserPubKey!.isEmpty)) {
        if (friendEmail != null) {
          //获取对方的公钥
          MessageModel userData = await squadApi.getUserPubKey(friendEmail ?? '');
          if(userData.error){
            if(userData.type==MessageErrorType.E1403){
              await TipsDialog1(context, S.of(context).g_key_error_1403);
              Application.logout();
              Navigator.pop(context);
            }else{
              ToastUtils.show(userData.data);
              return;
            }
          }else{
            otherUserPubKey = userData.data;
          }
        }
      }
      if (otherUserPubKey == null ||
          (otherUserPubKey != null && otherUserPubKey!.isEmpty)) {
        //提醒：对方没有钱包地址 无法接收消息
        ToastUtils.show(
            "The other party does not have a wallet address and cannot receive messages！");
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
        final contentType = type == FileType.image
            ? MessageContentType.Image
            : type == FileType.video
            ? MessageContentType.Video
            : MessageContentType.File;

        await handlerFile(file, contentType);
      }
    } catch (err) {
    }
  }

  Future handlerFile(File file, int contentType) async {
    // File file = File(result.files.single.path!);
    debugPrint("file path-->  ${file.path}");
    final filePath = file.absolute.path;
    String fileNavPath = filePath;
    FileUtils fileUtils=FileUtils();
    String fileNavName = fileUtils.getFileNameByPath(filePath);

    String fileSize = fileUtils.computerFileSize(fileNavPath);

    //定义临界值 最大支持100M
    int flagSize = 100 * 1024 * 1024;
    if (File(fileNavPath).lengthSync() > flagSize) {
      debugPrint("Files larger than 100 MB cannot be uploaded");
      ToastUtils.show(S.current.g_key_squad_k11);
      return;
    }

    String passWord = generatePassword();
    debugPrint("Random cipher：$passWord");

    final mSecrtData = await chatUtil.chatEnCode(mPubKey ?? '',
        bytesToHex(Uint8List.fromList(passWord.codeUnits))
    );
     debugPrint("mSecrtData: $mSecrtData");
    final otherSecrtData = await chatUtil.chatEnCode(otherUserPubKey ?? '',
        bytesToHex(Uint8List.fromList(passWord.codeUnits))
    );
     debugPrint("otherSecrtData: $otherSecrtData");

    Base64Utils base64Utils=Base64Utils();
    // 构建消息结构
    Map<String, dynamic> content = chatDataUtils.generateSendData(
        contentType: contentType,
        fromID: Application.userInfo?.uuid ?? '',
        receiveId: widget.targetUuid ?? '',
        conversationType: 0,
        direction: 1,
        // reply_id: currentReplyModel?.messageId,图片或者文件类型的消息并不能作为回复消息
        originalFileName: fileNavName,
        //文件在ipfs上的地址
        msg: '',
        //本地文件地址
        decryptionMessageContent: fileNavPath,
        senderAesSecret: base64Utils.encodeBase64(mSecrtData ?? ''),
        receiverAesSecret: base64Utils.encodeBase64(otherSecrtData ?? ''),
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
    await FileAesCryptUtils().isolateCryptFile(fileNavPath, passWord);

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

    /*debugPrint("Start uploading to IPFS");
    final data = await upLoadFile(newPath);
    //await compute(upLoadFile, newPath);
    //{Hash: bafybeieufukwa6vqh3je7wkh4kx54mdmyfqjujba3k4xaapso6crz6ujii,
    // Name: u=1503362238,2089207733&fm=253&fmt=auto&app=120&f=JPEG.webp.aes,
    // Size: 16894}

    if (data != null) {
      final fileName = data['Name'];
      //final fileSize = data['Size'];
      FileApi fileApi=FileApi();
      final fileServerUrl = fileApi.generateUrl(data['Hash'], fileName);

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
          fromUUID: Application.userInfo?.uuid ?? '',
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
    } else {
      //上传到 ipfs 失败
      setState(() {
        int index = newData.indexOf(cm);
        if (index != -1) {
          cm.status = -1;
          newData[index] = cm;
        }
      });
    }*/
  }

  //发送拍照文件
  Future cameraFile() async {
    try{
      if (mPubKey == null) return;
      if (otherUserPubKey == null ||
          (otherUserPubKey != null && otherUserPubKey!.isEmpty)) {
        if (friendEmail != null) {
          //获取对方的公钥
          MessageModel userData = await squadApi.getUserPubKey(friendEmail ?? '');
          if(userData.error){
            if(userData.type==MessageErrorType.E1403){
              await TipsDialog1(context, S.of(context).g_key_error_1403);
              Application.logout();
              Navigator.pop(context);
            }else{
              ToastUtils.show(userData.data);
              return;
            }
          }else{
            otherUserPubKey = userData.data;
          }
        }
      }
      if (otherUserPubKey == null ||
          (otherUserPubKey != null && otherUserPubKey!.isEmpty)) {
        //提醒：对方没有钱包地址 无法接收消息
        ToastUtils.show(
            "The other party does not have a wallet address and cannot receive messages！");
        return;
      }
      final ImagePicker picker = ImagePicker();
      final XFile? photo =
      await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
      if (photo != null) {
        //name: b2ededad-af44-4b14-b1a4-3b42c522d8ef3434912846439144868.jpg
        // path: /data/user/0/com.walletamaze.nftwallet/cache/b2ededad-af44-4b14-b1a4-3b42c522d8ef3434912846439144868.jpg
        File file = File(photo.path);
        handlerFile(file, MessageContentType.Image);
      }
    }
    catch (err) {
    }
  }
  //发送红包
  void onSendRedEnvelope() async {
    try {
      if (widget.targetUuid.isEmpty) return;
      if (_textEditingController.text.trim().isEmpty) return;
      final message = _textEditingController.text.trim();
      if (mPubKey == null) return;
      if (otherUserPubKey == null ||
          (otherUserPubKey != null && otherUserPubKey!.isEmpty)) {
        if (friendEmail != null) {
          //获取对方的公钥
          MessageModel userData = await squadApi.getUserPubKey(friendEmail ?? '');
          if(userData.error){
            if(userData.type==MessageErrorType.E1403){
              await TipsDialog1(context, S.of(context).g_key_error_1403);
              Application.logout();
              Navigator.pop(context);
            }else{
              ToastUtils.show(userData.data);
              return;
            }
          }else{
            otherUserPubKey = userData.data;
          }
        }
      }
      if (otherUserPubKey == null ||
          (otherUserPubKey != null && otherUserPubKey!.isEmpty)) {
        //提醒：对方没有钱包地址 无法接收消息
        ToastUtils.show(
            "The other party does not have a wallet address and cannot receive messages！");
        return;
      }

      String passWord = generatePassword();
      debugPrint("random cipher：$passWord");

      final mSecrtData = await chatUtil.chatEnCode(mPubKey ?? '',
          bytesToHex(Uint8List.fromList(passWord.codeUnits))
      );
      debugPrint("mSecrtData: $mSecrtData");
      final otherSecrtData = await chatUtil.chatEnCode(otherUserPubKey ?? '',
          bytesToHex(Uint8List.fromList(passWord.codeUnits))
      );
      debugPrint("otherSecrtData: $otherSecrtData");

      String encryptedContent = AesUtils().aesEncode(message, passWord);
      debugPrint("Encryption result：$encryptedContent");

      Base64Utils base64Utils=Base64Utils();
      // 构建消息结构
      Map<String, dynamic> content = chatDataUtils.generateSendData(
          contentType: MessageContentType.RedEnvelope,
          fromID: Application.userInfo?.uuid ?? '',
          receiveId: widget.targetUuid ?? '',
          conversationType: 0,
          reply_id: currentReplyModel?.messageId,
          direction: 1,
          msg: encryptedContent,
          decryptionMessageContent: message,
          senderAesSecret: base64Utils.encodeBase64(mSecrtData ?? ''),
          receiverAesSecret: base64Utils.encodeBase64(otherSecrtData ?? ''),
          senderPubKey: mPubKey,
          receiverPubKey: otherUserPubKey);

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

      // debugPrint("content====:${json.encode(content)}");

      try {
        final data = await chatApi.sendMessage(
          fromUUID: Application.userInfo?.uuid ?? '',
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
          debugPrint("send message err ！！！");
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
    } finally {
    }
  }

  //File upload is encapsulated as a top-level function
  Future<dynamic> upLoadFile(filePath) async {
    return await IpfsApi().uploadIPFSImage(filePath, "a", (int count, int total) {},type: 0);
    /*FileApi fileApi=FileApi();
    final data =
    await fileApi.upLoadFileToIpfs(filePath, (int count, int total) {
       debugPrint("ipfs:count $count total $total");
    });
    return data;*/
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
                imageUrl: info?.image ?? "",
                width: ScreenUtil().setWidth(68),
                placeholder: "assets/chat/user_def_icon.png",
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info?.name ?? "",
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  info?.email ?? "",
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.ff888888.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          CustomPopupMenu(
            pressType: PressType.singleClick,
            showArrow: false,
            verticalMargin: 0,
            controller: menuPopController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(32)),
              child: Icon(
                Icons.more_vert_rounded,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
            menuBuilder: () {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
                ),
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(56)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: ScreenUtil().setWidth(56),
                    ),
                    GestureDetector(
                      onTap: () async {
                        menuPopController.hideMenu();
                        try {
                          //长按弹出删除对话框
                          final flagResult =
                          await TipsDialog2(
                            context,
                            "${S.of(context).g_chat_key_63} $friendName？",
                          );
                          if (flagResult != null && flagResult) {

                            /*EasyLoading.show(
                              // ignore: use_build_context_synchronously
                              status: S.of(context).loading,
                              maskType: EasyLoadingMaskType.black,
                              dismissOnTap: false,
                            );*/
                            final blockUser =
                            await chatApi.blockFriend(widget.targetUuid);
                            if (blockUser != null && blockUser["code"] == 200) {
                              ToastUtils.show("Friends blocked");
                            }
                          }
                        } finally {
                          /*if (EasyLoading.isShow) {
                            EasyLoading.dismiss();
                          }*/
                        }
                      },
                      child: Text(
                        S.of(context).g_chat_key_63,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Color(0xffFE3B30), fontSize: ScreenUtil().setSp(32)),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(56),
                    ),
                    GestureDetector(
                      onTap: () {
                        menuPopController.hideMenu();
                        final controller = TextEditingController();
                        //底部弹出举报框
                        SheetBottom(
                            context,
                            isDismissible: false,
                            "",
                            ReportPost(
                              name: info?.name ?? '',
                              messageId: "",
                              onPressed: () async {
                                Navigator.of(context).pop();
                                try {
                                  final reason = controller.text.trim();
                                  final data = await chatApi.reportUser(reason,
                                      targetUuid: widget.targetUuid);
                                  if (data != null &&
                                      data["code"] == 200 &&
                                      data["data"]) {
                                    ToastUtils.show("report success");
                                    setState(() {});
                                  }
                                } finally {
                                  //debugPrint("");
                                }
                              },
                              controller: controller,
                            ));
                      },
                      child: Text(
                        S.of(context).g_chat_key_40,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Color(0xffFE3B30), fontSize: ScreenUtil().setSp(32)),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(56),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
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
                  child: load==Load.loading
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
                              //处理时间的展示 间隔2分钟展示一次时间
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

                              return ItemChatView(
                                key: ValueKey(item.messageId),
                                isCurrentUser: isCurrentUser,
                                item: item,
                                mPrivateKey: mPrivateKey ?? '',
                                time: timeStr,
                                friendName: friendName,
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
                          delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                              ChatMessageModel item = newData[index];
                              bool isCurrentUser = item.direction == 1;

                              //处理时间的展示 间隔2分钟展示一次时间
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

                              return ItemChatView(
                                key: ValueKey(item.messageId),
                                isCurrentUser: isCurrentUser,
                                item: item,
                                mPrivateKey: mPrivateKey ?? '',
                                friendName: friendName,
                                time: timeStr,
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
            Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //回复消息时 展示布局
                  if (currentReplyModel != null)
                    BottomInputChatReplyWidget(
                      onCloseTap: () {
                        setState(() {
                          currentReplyModel = null;
                        });
                      },
                      item: currentReplyModel!,
                      friendName: currentReplyModel!.direction == 1
                          ? Application.userInfo?.name
                          : friendName,
                    ),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(28)),
                    // color: Color(0xfff6f6f6),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              enableDrag: true,
                              builder: (context) {
                                return ChatBottomDialog(
                                  photoCallBack: () {
                                    Navigator.of(context).pop();
                                    onSendFile(FileType.image);
                                  },
                                  videoCallBack: () {
                                    Navigator.of(context).pop();
                                    onSendFile(FileType.video);
                                  },
                                  fileCallBack: () {
                                    Navigator.of(context).pop();
                                    onSendFile(FileType.any);
                                  },
                                );
                              },
                            );
                          },
                          child: Image.asset(
                            "assets/chat/Add1.png",
                            width: ScreenUtil().setWidth(48),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(28), vertical: ScreenUtil().setWidth(20)),
                              padding:
                              EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                              decoration: BoxDecoration(
                                // color: AppThemeUtils.getColorByKey(
                                //     context, AppThemeKeys.mainBoxColor),
                                  color: Theme.of(context).brightness == Brightness.dark ? const  Color(0xff232323) :const  Color(0xffffffff),
                                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                                  border: Border.all(
                                    // color: AppThemeUtils.getColorByKey(
                                    //     context, AppThemeKeys.mainBoxColor)
                                    color: Theme.of(context).brightness == Brightness.dark ? const  Color(0xff444444) :const  Color(0xffD9D9D9),
                                  )),
                              constraints: BoxConstraints(
                                  minHeight: ScreenUtil().setWidth(60), maxHeight: ScreenUtil().setWidth(300)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            fontSize: ScreenUtil().setSp(28),
                                            color: AppThemeUtils.getColorByKey(
                                                context,
                                                AppThemeKeys.ff888888.name)),
                                        // hintText: S.of(context).message,
                                        isDense: true,
                                        contentPadding:
                                        EdgeInsets.symmetric(
                                            horizontal: ScreenUtil().setWidth(24), vertical: ScreenUtil().setWidth(20)),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                        // border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                        color: AppThemeUtils.getColorByKey(
                                            context,
                                            AppThemeKeys.mainTextColor.name),
                                        fontSize: ScreenUtil().setSp(32),
                                      ),
                                      controller: _textEditingController,
                                      focusNode: _focusNode,
                                      onChanged: (val) {
                                        // setState(() {
                                        //   // editorLastCursor = _textEditingController.selection.baseOffset;
                                        // });
                                      },
                                      // onTap: () {
                                      //   // handleEditorTaped();
                                      // },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        rightIcon()
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
}

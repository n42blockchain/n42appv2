import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class EventPublic {
  EventPublicType type; //0隐藏钱包页面的左侧滑出菜单,1导入助记词时从app外切回到app内时
  final int? intValue;
  final String? stringValue;
  Object? param;//附带参数

  EventPublic(this.type, {this.intValue, this.stringValue,this.param});
}

enum EventPublicType {
  finishPage, //关闭监听这个动作的页面
  refreshData, //刷新页面数据
  chatMessage, //chat-message
  chatMessageRefresh,//聊天页面消息内容更新
  deleteChatItem, //删除单条消息
  chatItemReply, //消息回复
  updateChatConversationList, //更新会话列表
  refreshMiningData, //刷新挖矿数据
  //selectTable, //选中主页面的tab
  selectWallet,//切换钱包 发出通知
  selectMiningWallet,//切换挖矿钱包 发出通知
  //changeVideoFilePath,//切换视频路径，用于nft创建时，切换视频使用
  //changeAudioFilePath,//切换音频路径，用于nft创建时，切换音频使用
  transferOk,//转账成功通知，目前wallet_chain_info页面在用
  walletConnect,
  updateGroupInfo, //更新群信息
  //swap,//弹出兑换窗口
  //changeWallet,//弹出切换钱包窗口
  //selectCoin,//弹出选择币的窗口
  blockUri,//浏览器拦截事件
  //activityMessage,//弹出活动消息
  //groupRedPocket,//群红包
  backup,//红包备份刷新
  selectMiningplansPop,//选择挖矿计划页面，返回上一页
  miningFullNode,//支付挖矿费用成功
}
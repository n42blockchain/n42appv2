class MessageContentType {
  // 基本消息类型
  static const int Unknown = 0;
  static const int Text = 1;
  static int Voice = 2;
  static const int Image = 3;
  static const int Location = 4;
  static const int File = 5;
  static const int Video = 6;
  static const int Sticker = 7;
  static const int ImageText = 8;
  static const int P_Text = 9;
  static const int RedEnvelope = 10;//红包

  // 提醒消息
  static const int RecallMessage_Notification = 80;
  static const int Tip_Notification = 90;
  static const int Typing = 91;

  // 群相关消息
  static const int CreateGroup_Notification = 104;
  static const int AddGroupMember_Notification = 105;
  static const int KickOffGroupMember_Notification = 106;
  static const int QuitGroup_Notification = 107;
  static const int DismissGroup_Notification = 108;
  static const int TransferGroupOwner_Notification = 109;
  static const int ChangeGroupName_Notification = 110;
  static const int ModifyGroupAlias_Notification = 111;
  static const int ChangeGroupPortrait_Notification = 112;

  static const int MuteGroupMember_Notification = 113;
  static const int ChangeJoinType_Notification = 114;
  static const int ChangePrivateChat_Notification = 115;
  static const int ChangeSearchable_Notificaiton = 116;
  static const int SetGroupManager_Notification = 117;
  static const int VOIP_CONTENT_TYPE_START = 400;
  static const int VOIP_CONTENT_TYPE_END = 402;
  static const int VOIP_CONTENT_TYPE_ACCEPT = 401;
  static const int VOIP_CONTENT_TYPE_SIGNAL = 403;
  static const int VOIP_CONTENT_TYPE_MODIFY = 404;
  static const int VOIP_CONTENT_TYPE_ACCEPT_T = 405;
}

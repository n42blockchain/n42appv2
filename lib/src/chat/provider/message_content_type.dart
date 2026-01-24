class MessageContentType {
  // 基本消息类型
  // ignore: constant_identifier_names
  static const int Unknown = 0;
  // ignore: constant_identifier_names
  static const int Text = 1;
  // ignore: non_constant_identifier_names
  static int Voice = 2;
  // ignore: constant_identifier_names
  static const int Image = 3;
  // ignore: constant_identifier_names
  static const int Location = 4;
  // ignore: constant_identifier_names
  static const int File = 5;
  // ignore: constant_identifier_names
  static const int Video = 6;
  // ignore: constant_identifier_names
  static const int Sticker = 7;
  // ignore: constant_identifier_names
  static const int ImageText = 8;
  // ignore: constant_identifier_names
  static const int P_Text = 9;
  // ignore: constant_identifier_names
  static const int RedEnvelope = 10;//红包

  // 提醒消息
  // ignore: constant_identifier_names
  static const int RecallMessage_Notification = 80;
  // ignore: constant_identifier_names
  static const int Tip_Notification = 90;
  // ignore: constant_identifier_names
  static const int Typing = 91;

  // 群相关消息
  // ignore: constant_identifier_names
  static const int CreateGroup_Notification = 104;
  // ignore: constant_identifier_names
  static const int AddGroupMember_Notification = 105;
  // ignore: constant_identifier_names
  static const int KickOffGroupMember_Notification = 106;
  // ignore: constant_identifier_names
  static const int QuitGroup_Notification = 107;
  // ignore: constant_identifier_names
  static const int DismissGroup_Notification = 108;
  // ignore: constant_identifier_names
  static const int TransferGroupOwner_Notification = 109;
  // ignore: constant_identifier_names
  static const int ChangeGroupName_Notification = 110;
  // ignore: constant_identifier_names
  static const int ModifyGroupAlias_Notification = 111;
  // ignore: constant_identifier_names
  static const int ChangeGroupPortrait_Notification = 112;

  // ignore: constant_identifier_names
  static const int MuteGroupMember_Notification = 113;
  // ignore: constant_identifier_names
  static const int ChangeJoinType_Notification = 114;
  // ignore: constant_identifier_names
  static const int ChangePrivateChat_Notification = 115;
  // ignore: constant_identifier_names
  static const int ChangeSearchable_Notificaiton = 116;
  // ignore: constant_identifier_names
  static const int SetGroupManager_Notification = 117;
  // ignore: constant_identifier_names
  static const int VOIP_CONTENT_TYPE_START = 400;
  // ignore: constant_identifier_names
  static const int VOIP_CONTENT_TYPE_END = 402;
  // ignore: constant_identifier_names
  static const int VOIP_CONTENT_TYPE_ACCEPT = 401;
  // ignore: constant_identifier_names
  static const int VOIP_CONTENT_TYPE_SIGNAL = 403;
  // ignore: constant_identifier_names
  static const int VOIP_CONTENT_TYPE_MODIFY = 404;
  // ignore: constant_identifier_names
  static const int VOIP_CONTENT_TYPE_ACCEPT_T = 405;
}

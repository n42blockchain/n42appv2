// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get commonRetry => '重試';

  @override
  String get commonUnknownUser => '未知用戶';

  @override
  String get transferWalletNotConnected => '錢包未連接';

  @override
  String get chatCallServiceNotInitialized => '通話服務未初始化';

  @override
  String authLoginFailed(String error) {
    return '登錄失敗: $error';
  }

  @override
  String get chatCallBack => '回撥';

  @override
  String get chatMissedVideoCall => '未接視頻通話';

  @override
  String get chatMissedVoiceCall => '未接語音通話';

  @override
  String get chatCallNotAnswered => '對方未接聽';

  @override
  String get chatCallDurationLabel => '通話時長';

  @override
  String get chatVoiceCallCancelled => '語音通話已取消';

  @override
  String get chatVideoCallCancelled => '視頻通話已取消';

  @override
  String get commonImage => '[圖片]';

  @override
  String get chatVideo => '[視頻]';

  @override
  String get chatVoice => '[語音]';

  @override
  String get commonFile => '[文件]';

  @override
  String get chatLocation => '[位置]';

  @override
  String get chatUnknownMessage => '[未知消息]';

  @override
  String get commonDelete => '刪除';

  @override
  String get chatDeleteThisMessage => '刪除這條消息？';

  @override
  String get chatMessageDeleted => '消息已刪除';

  @override
  String get profileNotLoggedIn => '未登錄';

  @override
  String get chatMyLocation => '我的位置';

  @override
  String get commonGroupChat => '羣聊';

  @override
  String get commonSearch => '搜索';

  @override
  String get commonCancel => '取消';

  @override
  String get commonLoadFailed => '加載失敗';

  @override
  String get commonMessages => '消息';

  @override
  String get commonContacts => '聯繫人';

  @override
  String get commonMe => '我';

  @override
  String get commonVoiceLoading => '語音加載中，請稍後再試';

  @override
  String get commonVoiceToTextFailed => '語音轉文字失敗';

  @override
  String get commonConvertToText => '轉文字';

  @override
  String get chatCopy => '複製';

  @override
  String get commonForward => '轉發';

  @override
  String get commonUnfavorite => '取消收藏';

  @override
  String get commonFavorite => '收藏';

  @override
  String get settingsResend => '重新發送';

  @override
  String get chatRecall => '撤回';

  @override
  String get commonQuote => '引用';

  @override
  String get commonRemind => '提醒';

  @override
  String get chatCopied => '已複製';

  @override
  String get storySendMessageHint => '發送消息';

  @override
  String get commonMicrophonePermissionRequired => '請允許使用麥克風權限';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      '麥克風權限已被拒絕，請在系統設置中開啓以使用語音消息功能。';

  @override
  String commonStartRecordingFailed(String error) {
    return '開始錄音失敗: $error';
  }

  @override
  String get commonRecordingTooShort => '錄音時間太短';

  @override
  String commonStopRecordingFailed(String error) {
    return '停止錄音失敗: $error';
  }

  @override
  String get chatReleaseToCancel => '鬆開取消';

  @override
  String get chatReleaseToSend => '鬆開發送，上滑取消';

  @override
  String get commonHoldToTalk => '按住 說話';

  @override
  String get commonSend => '發送';

  @override
  String get commonAddFriend => '添加好友';

  @override
  String get commonChatServiceNotConnected => '聊天服務未連接';

  @override
  String contactUserNotFoundHint(String query) {
    return '未找到用戶 \"$query\"\n\n提示：\n• 嘗試輸入完整用戶ID，如 @username:server.com\n• 確認用戶名拼寫正確';
  }

  @override
  String contactCreateChatFailed(String error) {
    return '創建會話失敗: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return '搜索失敗: $error';
  }

  @override
  String get contactEnterUserIdOrUsername => '輸入用戶 ID 或用戶名搜索';

  @override
  String get contactSearching => '搜索中...';

  @override
  String get contactSearchUserToChat => '搜索用戶開始聊天';

  @override
  String get contactMatrixIdExample =>
      '可以輸入完整的 Matrix ID\n例如: @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return '未找到用戶 \"$username\"';
  }

  @override
  String get commonChat => '聊天';

  @override
  String get commonSettings => '設置';

  @override
  String get profileEditProfile => '編輯資料';

  @override
  String get authLogin => '登錄';

  @override
  String get commonCreateGroup => '創建羣聊';

  @override
  String get chatError => '錯誤';

  @override
  String get commonTransfer => '轉賬';

  @override
  String get commonReceived => '已被接收';

  @override
  String get commonRefunded => '已退還';

  @override
  String get commonExpired => '已過期';

  @override
  String get chatRedPacketGreeting => '恭喜發財，大吉大利';

  @override
  String get commonN42RedPacket => 'N42紅包';

  @override
  String get commonClaimed => '已領取';

  @override
  String get commonAllClaimed => '已被領完';

  @override
  String get chatReadAloud => '朗讀';

  @override
  String get chatReply => '回覆';

  @override
  String get commonEdit => '編輯';

  @override
  String get chatSelectForwardTarget => '選擇轉發對象';

  @override
  String commonSendCount(int count) {
    return '發送($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42號：$id';
  }

  @override
  String get profileN42IdTitle => 'N42號';

  @override
  String get profileN42Bean => 'N42豆';

  @override
  String get contactFriendInfo => '朋友資料';

  @override
  String get contactFriendInfoDesc => '添加朋友的備註名、電話、標籤、備忘、照片等，並設置朋友權限。';

  @override
  String get commonMoments => '朋友圈';

  @override
  String get commonSendMessage => '發消息';

  @override
  String get contactAudioVideoCall => '音視頻通話';

  @override
  String get contactVideoChannel => '視頻號';

  @override
  String get contactRemark => '備註';

  @override
  String get contactRemarkName => '備註名';

  @override
  String get contactPhone => '電話';

  @override
  String get contactTags => '標籤';

  @override
  String get contactNotes => '備忘';

  @override
  String get contactPhotos => '照片';

  @override
  String get contactPermissions => '權限';

  @override
  String get contactChatMomentsEtc => '聊天、朋友圈、運動等';

  @override
  String get contactMoreInfo => '更多信息';

  @override
  String get contactCommonGroups => '我和他 (她) 的共同羣聊';

  @override
  String get contactSource => '來源';

  @override
  String get settingsNotificationSettings => '消息通知';

  @override
  String get settingsPrivacy => '隱私';

  @override
  String get settingsAppearance => '外觀';

  @override
  String get settingsAbout => '關於';

  @override
  String get commonLogout => '退出登錄';

  @override
  String get commonLogoutConfirm => '確定要退出登錄嗎？';

  @override
  String get commonSave => '保存';

  @override
  String get profileNickname => '暱稱';

  @override
  String get profileEnterNickname => '請輸入暱稱';

  @override
  String get profileSignature => '簽名';

  @override
  String get profileAddSignature => '添加個性簽名';

  @override
  String get commonTakePhoto => '拍照';

  @override
  String get profileChooseFromGallery => '從相冊選擇';

  @override
  String profileSaveFailed(String error) {
    return '保存失敗: $error';
  }

  @override
  String get authSecureDecentralizedChat => '安全、去中心化的即時通訊';

  @override
  String get commonEndToEndEncryption => '端到端加密';

  @override
  String get authMessagesOnlyYouCanSee => '消息僅你和對方可見';

  @override
  String get authDecentralized => '去中心化';

  @override
  String get authBasedOnMatrix => '基於Matrix開放協議';

  @override
  String get authWalletIntegration => '錢包集成';

  @override
  String get authEasyCryptoTransfer => '輕鬆進行加密貨幣轉賬';

  @override
  String get authRegister => '註冊';

  @override
  String get authAgreeTerms => '登錄即表示同意';

  @override
  String get authTermsOfService => '《服務協議》';

  @override
  String get authAnd => '和';

  @override
  String get authPrivacyPolicy => '《隱私政策》';

  @override
  String get authServerAddress => '服務器地址';

  @override
  String get authEnterServerAddress => '請輸入服務器地址';

  @override
  String authConnectedTo(String serverName) {
    return '已連接到 $serverName';
  }

  @override
  String get authUsername => '用戶名';

  @override
  String get authEnterUsername => '請輸入用戶名';

  @override
  String get authUsernameOrEmail => '用戶名或郵箱';

  @override
  String get authEnterUsernameOrEmail => '請輸入用戶名或郵箱';

  @override
  String get authPassword => '密碼';

  @override
  String get authEnterPassword => '請輸入密碼';

  @override
  String get authRegisterAccount => '註冊賬號';

  @override
  String get authForgotPassword => '忘記密碼';

  @override
  String get authOtherLoginMethods => '其他登錄方式';

  @override
  String get authCreateAccount => '創建賬號';

  @override
  String get authJoinN42Chat => '加入 N42 Chat 開始聊天';

  @override
  String get authUsernameHint => '3-20字符，字母/數字/_';

  @override
  String get authUsernameMinLength => '用戶名至少3個字符';

  @override
  String get authUsernameMaxLength => '用戶名最多20個字符';

  @override
  String get authUsernameFormat => '用戶名只能包含字母、數字和下劃線';

  @override
  String get authPasswordHint => '至少8位';

  @override
  String get commonPasswordMinLength => '密碼至少8位';

  @override
  String get authConfirmPassword => '確認密碼';

  @override
  String get authFilled => '已填寫';

  @override
  String get authEnterInviteCode => '請輸入邀請碼';

  @override
  String get authAlreadyHaveAccount => '已有賬號？';

  @override
  String get authLoginNow => '立即登錄';

  @override
  String get profileAvatar => '頭像';

  @override
  String get profileStatus => '狀態';

  @override
  String get commonLoading => '加載中...';

  @override
  String get conversationNoConversations => '暫無會話';

  @override
  String get conversationTapToChat => '點擊右上角開始聊天';

  @override
  String get conversationStartGroup => '發起羣聊';

  @override
  String get commonScan => '掃一掃';

  @override
  String get commonPayment => '收付款';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature 功能即將推出';
  }

  @override
  String get conversationMarkAsRead => '標記已讀';

  @override
  String get commonUnmute => '取消靜音';

  @override
  String get commonMute => '消息免打擾';

  @override
  String get conversationUnpin => '取消置頂';

  @override
  String get conversationPin => '置頂';

  @override
  String get conversationDeleteConversation => '刪除會話';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return '確定要刪除與 $name 的會話嗎？';
  }

  @override
  String get commonNoContacts => '暫無聯繫人';

  @override
  String get contactAddFriendsToChat => '添加好友開始聊天';

  @override
  String get contactNotFound => '未找到聯繫人';

  @override
  String get contactTryOtherKeywords => '嘗試搜索其他關鍵詞或全局搜索';

  @override
  String get contactSearchResults => '搜索結果';

  @override
  String get contactNewFriends => '新的朋友';

  @override
  String get contactChatOnlyFriends => '僅聊天的朋友';

  @override
  String get contactOfficialAccounts => '公衆號';

  @override
  String get contactServiceAccounts => '服務號';

  @override
  String get contactEnterpriseContacts => '企業聯繫人';

  @override
  String get contactRecommendToFriend => '推薦給朋友';

  @override
  String get commonSetRemark => '設置備註';

  @override
  String get contactSendingCard => '正在發送名片...';

  @override
  String get commonFileLabel => '文件';

  @override
  String get commonLocationLabel => '位置';

  @override
  String contactRecommendFailed(String error) {
    return '推薦失敗: $error';
  }

  @override
  String get profileEnterRemark => '請輸入備註名';

  @override
  String get contactOpeningChat => '正在打開聊天...';

  @override
  String contactOpenChatFailed(String error) {
    return '打開聊天失敗: $error';
  }

  @override
  String get contactAddContact => '添加聯繫人';

  @override
  String get contactEnterUserId => '輸入用戶ID';

  @override
  String get contactNoFriendRequests => '暫無好友請求';

  @override
  String get commonAccept => '接受';

  @override
  String get commonReject => '拒絕';

  @override
  String get commonNoGroups => '暫無羣聊';

  @override
  String get contactSelectFriendToRecommend => '選擇要推薦給的朋友';

  @override
  String get commonSearchContacts => '搜索聯繫人';

  @override
  String get contactNoContactsFound => '沒有找到聯繫人';

  @override
  String get favoriteYesterday => '昨天';

  @override
  String get chatJustNow => '剛剛';

  @override
  String get profileOnline => '在線';

  @override
  String get profileOffline => '離線';

  @override
  String get searchContactsGroupsMessages => '搜索聯繫人、羣聊和消息';

  @override
  String get searchError => '搜索出錯';

  @override
  String get chatSearchHint => '搜索';

  @override
  String get searchHistory => '搜索歷史';

  @override
  String get commonClear => '清除';

  @override
  String get commonAll => '全部';

  @override
  String get searchGroups => '羣聊';

  @override
  String get searchNoResults => '無結果';

  @override
  String commonGroupMembers(int count) {
    return '羣成員 ($count)';
  }

  @override
  String get groupMembersTitle => '羣成員';

  @override
  String get groupViewAll => '查看全部';

  @override
  String get groupOwner => '羣主';

  @override
  String get groupAdmin => '管理';

  @override
  String get groupInvite => '邀請';

  @override
  String get commonGroupAnnouncement => '羣公告';

  @override
  String get commonNotSet => '未設置';

  @override
  String get groupDescription => '羣簡介';

  @override
  String get groupPublicGroup => '公開羣聊';

  @override
  String get commonClearChatHistory => '清空聊天記錄';

  @override
  String get commonDissolveGroup => '解散羣聊';

  @override
  String get commonLeaveGroup => '退出羣聊';

  @override
  String get groupChangeGroupName => '修改羣名稱';

  @override
  String get commonEnterGroupName => '請輸入羣名稱';

  @override
  String get commonConfirm => '確認';

  @override
  String get groupEnterGroupDescription => '請輸入羣簡介';

  @override
  String get groupPublish => '發佈';

  @override
  String get chatClearHistoryConfirm => '確定要清空聊天記錄嗎？此操作不可恢復。';

  @override
  String get chatClearAction => '清空';

  @override
  String get commonChatHistoryCleared => '聊天記錄已清空';

  @override
  String get commonDissolve => '解散';

  @override
  String get groupQrCode => '羣二維碼';

  @override
  String get commonSearchChatHistory => '查找聊天記錄';

  @override
  String get groupIdCopied => '羣ID已複製';

  @override
  String get transferEnterOrPasteAddress => '輸入或粘貼錢包地址';

  @override
  String get transferSelectToken => '選擇代幣';

  @override
  String get commonTransferAmount => '轉賬金額';

  @override
  String get transferAvailable => '可用';

  @override
  String get transferMemoOptional => '備註（可選）';

  @override
  String get transferConfirmTransfer => '確認轉賬';

  @override
  String get transferAddressVerified => '地址已驗證';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return '可用餘額: $balance $symbol';
  }

  @override
  String get commonEnterAmount => '請輸入金額';

  @override
  String get commonRedPacketCountMin => '紅包個數至少爲1';

  @override
  String get commonViewRedPacketDetails => '查看紅包詳情';

  @override
  String get commonEnterTransferAmount => '請輸入轉賬金額';

  @override
  String get commonTransferTo => '轉賬給';

  @override
  String commonFromSender(String name, Object senderName) {
    return '來自 $name';
  }

  @override
  String get commonConfirmReceive => '確認收款';

  @override
  String get groupProfile => '羣資料';

  @override
  String get groupRemoveMember => '移出羣聊';

  @override
  String get commonRemove => '移出';

  @override
  String get profileClearStatus => '清除狀態';

  @override
  String get profileClearStatusConfirm => '確定要清除當前狀態嗎？';

  @override
  String get profileStatusCleared => '狀態已清除';

  @override
  String get profileUserNotExist => '用戶不存在';

  @override
  String get profileUserIdCopied => '用戶ID已複製';

  @override
  String get commonReport => '舉報';

  @override
  String get profileQrCode => '二維碼';

  @override
  String get profileAvatarUpdated => '頭像更新成功';

  @override
  String commonSelectImageFailed(String error) {
    return '選擇圖片失敗: $error';
  }

  @override
  String get profileChangeName => '修改名字';

  @override
  String get profileMale => '男';

  @override
  String get profileFemale => '女';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature功能開發中...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return '保存地址失敗: $error';
  }

  @override
  String get profileAddNew => '新增';

  @override
  String get profileAddAddress => '添加地址';

  @override
  String get profileAddressAdded => '地址添加成功';

  @override
  String get profileAddressUpdated => '地址更新成功';

  @override
  String get profileDeleteAddress => '刪除地址';

  @override
  String get profileAddressDeleted => '地址已刪除';

  @override
  String profileSaveInvoiceFailed(String error) {
    return '保存發票抬頭失敗: $error';
  }

  @override
  String get profileMyInvoices => '我的發票抬頭';

  @override
  String get profileAddInvoice => '添加發票抬頭';

  @override
  String get profileInvoiceAdded => '發票抬頭添加成功';

  @override
  String get profileInvoiceUpdated => '發票抬頭更新成功';

  @override
  String get profileDeleteInvoice => '刪除發票抬頭';

  @override
  String get profileInvoiceDeleted => '發票抬頭已刪除';

  @override
  String get profilePersonal => '個人';

  @override
  String get groupSelectAtLeastOne => '請至少選擇一位成員';

  @override
  String get chatFileNotExist => '文件不存在';

  @override
  String chatSendFailed(String error) {
    return '發送失敗: $error';
  }

  @override
  String get chatCannotOpenBrowser => '無法打開瀏覽器';

  @override
  String chatSelectFileFailed(String error) {
    return '選擇文件失敗: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return '設置失敗: $error';
  }

  @override
  String get transferEnterValidAmount => '請輸入有效的轉賬金額';

  @override
  String get commonAddressCopied => '地址已複製';

  @override
  String favoriteOpenItem(String content) {
    return '打開: $content';
  }

  @override
  String get favoriteDeleted => '已刪除';

  @override
  String get profileWallet => '錢包';

  @override
  String get chatRecording => '錄像';

  @override
  String get chatInvalidVideoUrl => '無效的視頻鏈接';

  @override
  String get chatDownloadFile => '下載文件';

  @override
  String get chatClearChatHistoryTitle => '清空聊天記錄';

  @override
  String get chatVideoCall => '視頻通話';

  @override
  String get commonVoiceCall => '語音通話';

  @override
  String get callLeaveMeeting => '離開會議';

  @override
  String get chatDetails => '聊天詳情';

  @override
  String get chatViewAllGroupMembers => '查看全部羣成員';

  @override
  String get chatGroupName => '羣聊名稱';

  @override
  String get chatGroupNameUpdated => '羣名稱已更新';

  @override
  String get chatUpdateFailed => '更新失敗';

  @override
  String get chatNoPermissionToModify => '您沒有修改權限';

  @override
  String get chatGroupManagement => '羣管理';

  @override
  String get chatMyNicknameInGroup => '我在本羣的暱稱';

  @override
  String get chatPinChat => '置頂聊天';

  @override
  String get chatStrongReminder => '強提醒';

  @override
  String get chatSetChatBackground => '設置當前聊天背景';

  @override
  String get chatUnknownFile => '未知文件';

  @override
  String get chatDownload => '下載';

  @override
  String get chatInvalidLocation => '無效的位置';

  @override
  String get chatTapToCancel => '點擊取消';

  @override
  String chatCaptureFailed(Object error) {
    return '拍攝失敗: $error';
  }

  @override
  String get chatProcessingVideo => '正在處理視頻...';

  @override
  String get chatVideoFileNotExist => '視頻文件不存在';

  @override
  String get chatVideoDataEmpty => '視頻數據爲空';

  @override
  String get chatVideoTooLarge => '視頻大小不能超過 100MB';

  @override
  String get chatSendingVideo => '視頻發送中...';

  @override
  String chatSendVideoFailed(Object error) {
    return '發送視頻失敗: $error';
  }

  @override
  String get chatImageFileNotExist => '圖片文件不存在';

  @override
  String get commonImageDataEmpty => '圖片數據爲空';

  @override
  String get chatSendingImage => '圖片發送中...';

  @override
  String chatSendImageFailed(Object error) {
    return '發送圖片失敗: $error';
  }

  @override
  String get chatSendLocation => '發送位置';

  @override
  String get chatSelectLocationAndSend => '選擇地點併發送給對方';

  @override
  String get chatShareRealTimeLocation => '共享實時位置';

  @override
  String get chatShareLocationForOneHour => '與好友共享1小時實時位置';

  @override
  String get chatLocationSent => '位置已發送';

  @override
  String get chatSelectMessages => '選擇消息';

  @override
  String chatSelectedCount(int count) {
    return '已選擇 $count';
  }

  @override
  String get chatSelectAll => '全選';

  @override
  String chatGroupChatCount(int count) {
    return '羣聊($count)';
  }

  @override
  String get chatPrivateChat => '私聊';

  @override
  String get chatNoMessages => '暫無消息';

  @override
  String get chatSendFirstMessage => '發送第一條消息開始聊天';

  @override
  String get chatEncryptionNotice => '此聊天已啓用端到端加密。只有您和對方可以閱讀消息。';

  @override
  String get chatMultiForward => '轉發';

  @override
  String get chatCollect => '收藏';

  @override
  String get chatNoMembers => '沒有成員';

  @override
  String get chatMemberNotFound => '未找到成員';

  @override
  String get chatVoiceFileNotExist => '語音文件不存在';

  @override
  String get chatVoiceFileEmpty => '語音文件爲空';

  @override
  String get chatSendingVoice => '語音發送中...';

  @override
  String chatSendVoiceFailed(Object error) {
    return '發送語音失敗: $error';
  }

  @override
  String get chatMessageForwarded => '消息已轉發';

  @override
  String chatForwardFailed(Object error) {
    return '轉發失敗: $error';
  }

  @override
  String get chatUnfavorited => '已取消收藏';

  @override
  String get chatFavorited => '已收藏';

  @override
  String get chatReactionAdded => '已添加表情回應';

  @override
  String get chatReactionRemoved => '已移除表情回應';

  @override
  String get chatFailedMessageDeleted => '已刪除失敗消息';

  @override
  String get chatDeleteMessages => '刪除消息';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return '確定要刪除 $count 條消息嗎？';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return '注意：$count 條消息來自他人，僅對你刪除。';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return '$count 條你發送的消息將對所有人撤回。';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return '已撤回 $count 條消息，$localCount 條僅對你刪除';
  }

  @override
  String chatRecalledMessages(Object count) {
    return '已撤回 $count 條消息';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count 條消息僅對你刪除';
  }

  @override
  String chatForwardedCount(Object count) {
    return '已轉發 $count 條消息';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return '轉發完成：成功 $success 條，失敗 $failed 條';
  }

  @override
  String get chatRemindOnlyInGroup => '提醒功能僅在羣聊中可用';

  @override
  String get chatOnlyTextSearchable => '僅支持搜索文本消息';

  @override
  String chatSearchFor(Object text) {
    return '搜索 \"$text\"';
  }

  @override
  String get chatBaiduSearch => '百度搜索';

  @override
  String get chatGoogleSearch => 'Google 搜索';

  @override
  String get chatBingSearch => '必應搜索';

  @override
  String get chatCalling => '呼叫中...';

  @override
  String get chatRinging => '響鈴中...';

  @override
  String get chatInCall => '通話中';

  @override
  String commonFeatureInDevelopment(String feature) {
    return '$feature功能開發中...';
  }

  @override
  String chatCollectMessages(Object count) {
    return '已收藏 $count 條消息';
  }

  @override
  String commonMemberCount(int count) {
    return '$count 人';
  }

  @override
  String groupDone(int count) {
    return '完成($count)';
  }

  @override
  String get profileServices => '服務';

  @override
  String get commonFavorites => '收藏';

  @override
  String get profileOrdersAndCards => '訂單與卡包';

  @override
  String get profileStickers => '表情';

  @override
  String profileStatusSetTo(String status) {
    return '狀態已設置爲：$status';
  }

  @override
  String get profileAvatarUploadFailed => '頭像上傳失敗';

  @override
  String get profilePersonalProfile => '個人信息';

  @override
  String get profileName => '名字';

  @override
  String get profileGender => '性別';

  @override
  String get profileRegion => '地區';

  @override
  String get commonMyQrCode => '我的二維碼';

  @override
  String get profilePoke => '拍一拍';

  @override
  String get profileRingtone => '來電鈴聲';

  @override
  String get profileDefaultRingtone => '默認鈴聲';

  @override
  String get profileMyAddresses => '我的地址';

  @override
  String profileGenderSetTo(String gender) {
    return '性別已設置爲：$gender';
  }

  @override
  String get profileSelectRegion => '選擇地區';

  @override
  String get profileSelectCity => '選擇城市';

  @override
  String profileRegionSetTo(String region) {
    return '地區已設置爲：$region';
  }

  @override
  String get profileSetPoke => '設置拍一拍';

  @override
  String get profileFriendPokedMe => '朋友拍了拍我';

  @override
  String get profileExample => '示例';

  @override
  String get profileOnTheShoulder => '的肩膀';

  @override
  String get profilePokeCleared => '拍一拍已清除';

  @override
  String profilePokeSetTo(String suffix) {
    return '拍一拍已設置爲：拍了拍我$suffix';
  }

  @override
  String get profileEditSignature => '編輯個性簽名';

  @override
  String get profileIntroduceYourself => '一句話介紹自己';

  @override
  String get profileSignatureCleared => '個性簽名已清除';

  @override
  String get profileSignatureUpdated => '個性簽名已更新';

  @override
  String get profileScanToAddFriend => '掃一掃上面的二維碼圖案，加我爲好友';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return '來電鈴聲已設置爲：$ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return '確定要解散羣聊「$name」嗎？此操作無法撤銷。';
  }

  @override
  String get authEnterValidServerAddress => '請輸入有效的服務器地址';

  @override
  String get authEnterServerAddressFirst => '請先輸入服務器地址';

  @override
  String get authPasskeyRequiresServer => 'Passkey登錄需要服務器支持';

  @override
  String get authLoginAgreement => '登錄即表示同意';

  @override
  String get authPleaseAgreeToTerms => '請先閱讀並同意服務協議和隱私政策';

  @override
  String get authRegisterFailed => '註冊失敗';

  @override
  String get commonReenterPassword => '請再次輸入密碼';

  @override
  String get commonPasswordsDoNotMatch => '兩次輸入的密碼不一致';

  @override
  String get authInviteCodeBuiltIn => '邀請碼（已內置）';

  @override
  String get authInviteCodeBuiltInNote => '邀請碼已內置，通常無需修改';

  @override
  String get authIHaveReadAndAgree => '我已閱讀並同意';

  @override
  String get mainStartGroupChat => '發起羣聊';

  @override
  String get mainAddFriends => '添加朋友';

  @override
  String get mainPaymentAndCollection => '收付款';

  @override
  String contactCount(int count) {
    return '$count位聯繫人';
  }

  @override
  String get contactAddToHomeScreen => '添加到桌面';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return '已將$contact的名片推薦給$recipient';
  }

  @override
  String get contactEnterRemarkName => '請輸入備註名';

  @override
  String contactRemarkSetTo(String remark) {
    return '備註已設置爲：$remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return '已接受$name的好友請求';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return '已拒絕$name的好友請求';
  }

  @override
  String get commonGroupInvites => '羣邀請';

  @override
  String commonMyGroups(int count) {
    return '我的羣聊 ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => '邀請加入羣聊';

  @override
  String commonConfirmLeaveGroup(String name) {
    return '確定要退出羣聊「$name」嗎？';
  }

  @override
  String get commonLeave => '離開';

  @override
  String get commonRecallThisMessage => '撤回該條消息？';

  @override
  String get commonSavedToGallery => '已保存到相冊';

  @override
  String get commonFailedToSave => '保存失敗';

  @override
  String get chatSaving => '保存中...';

  @override
  String get commonShare => '分享';

  @override
  String get chatSaveToGallery => '保存到相冊';

  @override
  String chatDownloadFailed(String code) {
    return '下載失敗: $code';
  }

  @override
  String commonShareFailed(String error) {
    return '分享失敗: $error';
  }

  @override
  String get chatFailedToLoadImage => '圖片加載失敗';

  @override
  String get chatVideoRecordingFailed => '視頻錄製失敗，請重試';

  @override
  String get profileRedPacket => '紅包';

  @override
  String get commonMusic => '音樂';

  @override
  String get commonCoupon => '卡券';

  @override
  String get commonGift => '禮物';

  @override
  String get commonPoll => '投票';

  @override
  String get favoriteText => '文本';

  @override
  String get favoriteLinkLabel => '鏈接';

  @override
  String get favoriteNote => '筆記';

  @override
  String get favoriteMyNotes => '我的筆記';

  @override
  String get favoriteToday => '今天';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count天前';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month月$day日';
  }

  @override
  String get favoriteNoFavorites => '暫無收藏';

  @override
  String get favoriteLongPressToFavorite => '長按消息進行收藏';

  @override
  String get favoriteNewNote => '新建筆記';

  @override
  String get favoriteLink => '收藏鏈接';

  @override
  String get favoriteEditTags => '編輯標籤';

  @override
  String get favoriteDeleteFavorite => '刪除收藏';

  @override
  String get favoriteDeleteFavoriteConfirm => '確定要刪除這條收藏嗎？';

  @override
  String get favoriteNoSearchResultsFound => '沒有找到結果';

  @override
  String get commonSendRedPacket => '發紅包';

  @override
  String get transferAmount => '金額';

  @override
  String get commonRedPacketCover => '紅包封面';

  @override
  String get commonRedPacketType => '紅包類型';

  @override
  String get commonNormalRedPacket => '普通紅包';

  @override
  String get commonLuckyRedPacket => '拼手氣';

  @override
  String get commonRedPacketCount => '紅包個數';

  @override
  String get commonPieces => '個';

  @override
  String get commonPutMoneyInRedPacket => '塞錢進紅包';

  @override
  String get commonRedPacketRefundNotice => '未領取的紅包，將於24小時後發起退款';

  @override
  String get commonOpenRedPacket => '開';

  @override
  String get commonRedPacketAllClaimed => '紅包已被領完';

  @override
  String get commonRedPacketExpired => '紅包已過期';

  @override
  String get commonAddTransferNote => '添加轉賬說明';

  @override
  String get commonYuan => '元';

  @override
  String get commonReplyWithEmoji => '用此表情回覆';

  @override
  String get contactEditRemark => '編輯備註';

  @override
  String get contactSetPermissions => '設置權限';

  @override
  String get profileAddToBlacklist => '加入黑名單';

  @override
  String get contactDeleteContact => '刪除聯繫人';

  @override
  String contactDeleteContactConfirm(String name) {
    return '確定要刪除 $name 嗎？';
  }

  @override
  String get transferTitle => '轉賬';

  @override
  String get transferReceiverAddressLabel => '收款地址';

  @override
  String get transferSelectTokenLabel => '選擇代幣';

  @override
  String get transferAmountLabel => '轉賬金額';

  @override
  String get transferMemoLabel => '備註（可選）';

  @override
  String get transferAddMemoHint => '添加備註信息';

  @override
  String get transferSendPaymentRequest => '發送收款請求';

  @override
  String get transferQrCodeGenerateFailed => '二維碼生成失敗';

  @override
  String get transferScanQrToPayMe => '掃描二維碼向我付款';

  @override
  String get transferMyWalletAddress => '我的錢包地址';

  @override
  String get transferCreatePaymentRequest => '創建收款請求';

  @override
  String profileN42IdLabel(String id) {
    return 'N42號：$id';
  }

  @override
  String get commonRedPacketDefaultGreeting => '恭喜發財，大吉大利';

  @override
  String commonSenderRedPacket(String name) {
    return '$name的紅包';
  }

  @override
  String get transferEnterValidAddress => '請輸入有效的收款地址';

  @override
  String get transferPleaseSelectToken => '請選擇代幣';

  @override
  String get commonReceivedTransfer => '收到轉賬';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name發出的紅包';
  }

  @override
  String get commonSavedToBalance => '已存入零錢，可直接轉賬';

  @override
  String get commonRedPacketExpiredOrEmpty => '紅包已過期/已領完';

  @override
  String get transferScanFeatureComingSoon => '掃描功能開發中...';

  @override
  String get contactSetAsStarred => '設爲星標朋友';

  @override
  String get contactAddToBlocklist => '加入黑名單';

  @override
  String get commonClaimedYour => '領取了你的';

  @override
  String get commonClaimedText => '領取了';

  @override
  String commonUserTyping(String name) {
    return '$name正在輸入...';
  }

  @override
  String get commonTyping => '對方正在輸入...';

  @override
  String get commonWaitingToReceive => '待對方接收';

  @override
  String get commonTapToClaim => '點擊領取';

  @override
  String get commonHasBeenReceived => '已被接收';

  @override
  String get commonGetLucky => '領個好彩頭';

  @override
  String get qrcodeCameraStartFailed => '相機啓動失敗';

  @override
  String get qrcodeUnknownError => '未知錯誤';

  @override
  String get qrcodePlaceQrCodeInFrame => '將二維碼放入框內掃描';

  @override
  String get qrcodeCloseManualInput => '關閉手動輸入';

  @override
  String get qrcodeManualInputUserId => '手動輸入用戶ID';

  @override
  String get commonAdd => '加入';

  @override
  String get profileSetStatus => '設置狀態';

  @override
  String get profileVisibleToFriends24h => '可被好友看到，24小時後自動清除';

  @override
  String get profileWriteStatus => '寫狀態';

  @override
  String get profileEnterYourStatus => '輸入你的狀態...';

  @override
  String get profileOk => '確定';

  @override
  String get qrcodeCameraPermissionRequired => '掃描二維碼需要相機權限';

  @override
  String get qrcodeCameraPermissionDenied => '相機權限已被永久拒絕，請在系統設置中開啓。';

  @override
  String qrcodePermissionCheckError(String error) {
    return '檢查權限時出錯: $error';
  }

  @override
  String get qrcodeInvalidQrCode => '無效的二維碼';

  @override
  String qrcodeCannotAddFriend(String error) {
    return '無法添加好友: $error';
  }

  @override
  String get qrcodeScanQrCode => '掃描二維碼';

  @override
  String get qrcodeCheckingCameraPermission => '正在檢查相機權限...';

  @override
  String get qrcodeNeedCameraPermission => '需要相機權限';

  @override
  String get qrcodeRetryPermission => '重試';

  @override
  String get qrcodeOpenSettings => '打開設置';

  @override
  String get groupInviteMembers => '邀請成員';

  @override
  String groupInviteCount(int count) {
    return '邀請($count)';
  }

  @override
  String get profileNoShippingAddress => '暫無收貨地址';

  @override
  String get profileDefaultLabel => '默認';

  @override
  String get profileNoInvoice => '暫無發票抬頭';

  @override
  String get profileCompany => '企業';

  @override
  String get profileTaxNumber => '稅號';

  @override
  String get profileConfirmDeleteAddress => '確定要刪除這個地址嗎？';

  @override
  String get profileConfirmDeleteInvoice => '確定要刪除這個發票抬頭嗎？';

  @override
  String get commonGroupOwner => '羣主';

  @override
  String get commonGroupAdmin => '管理員';

  @override
  String get groupSearchMembers => '搜索成員';

  @override
  String groupTotalMembers(int count) {
    return '$count位成員';
  }

  @override
  String get chatRemoveFromGroup => '移出羣聊';

  @override
  String groupConfirmRemoveMember(String name) {
    return '確定要將\"$name\"移出羣聊嗎？';
  }

  @override
  String get chatUnknownSong => '未知歌曲';

  @override
  String get chatUnknownArtist => '未知藝術家';

  @override
  String get chatUnknownContact => '未知聯繫人';

  @override
  String get chatPersonalCard => '個人名片';

  @override
  String get chatSingleChoice => '單選';

  @override
  String get chatMultiChoice => '多選';

  @override
  String get chatEnded => '已結束';

  @override
  String get chatEndPollButton => '結束投票';

  @override
  String get chatPollHint => '投票發起後將顯示在聊天中，羣成員可以參與投票';

  @override
  String get chatSearchSongOrArtist => '搜索歌曲或歌手';

  @override
  String get chatNoSongsFound => '沒有找到歌曲';

  @override
  String get chatSongNameOptional => '歌曲名稱（可選）';

  @override
  String get chatEnterSongName => '輸入歌曲名稱';

  @override
  String get chatArtistNameOptional => '歌手名稱（可選）';

  @override
  String get chatEnterArtistName => '輸入歌手名稱';

  @override
  String get chatRealTimeLocationSharing => '實時位置共享功能開發中...';

  @override
  String get profileVoiceCallFeatureInDev => '語音通話功能開發中...';

  @override
  String get profileReportFeatureInDev => '舉報功能開發中...';

  @override
  String get profileShareFeatureInDev => '分享功能開發中...';

  @override
  String get profileQrCodeFeatureInDev => '二維碼功能開發中...';

  @override
  String get qrcodeScanQrToAddMe => '掃一掃上面的二維碼，加我爲好友';

  @override
  String get qrcodeSaveToAlbum => '保存到相冊';

  @override
  String get qrcodeChangeStyle => '換個樣式';

  @override
  String get qrcodeCopyId => '複製 ID';

  @override
  String get qrcodeIdCopied => '已複製用戶 ID';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => '更多樣式即將推出';

  @override
  String get profileBio => '個性簽名';

  @override
  String get profileHomeServer => '服務器';

  @override
  String get profileShareContactCard => '分享名片';

  @override
  String get profileRemoveFromBlacklist => '移出黑名單';

  @override
  String get profileConfirmAddBlacklist => '確定將該用戶加入黑名單嗎？你將不再收到對方的消息';

  @override
  String get profileConfirmRemoveBlacklist => '確定將該用戶移出黑名單嗎？';

  @override
  String get profileRemarkSaved => '備註已保存';

  @override
  String get profileRemarkCleared => '已清除備註';

  @override
  String get transferReceive => '收款';

  @override
  String get transferPleaseConnectWallet => '請先連接錢包';

  @override
  String get transferSendRequest => '發送請求';

  @override
  String get transferPleaseEnterValidAmount => '請輸入有效的金額';

  @override
  String get searchPlaceholder => '搜索聯繫人、羣聊、消息';

  @override
  String get searchEnterKeywordToSearch => '輸入關鍵詞開始搜索';

  @override
  String get searchClearHistory => '清除';

  @override
  String searchNoResultsForQuery(String query) {
    return '沒有找到\"$query\"相關的結果';
  }

  @override
  String get searchAllResults => '全部';

  @override
  String get searchInChat => '在聊天中搜索';

  @override
  String get searchContactLabel => '聯繫人';

  @override
  String get searchGroupLabel => '羣聊';

  @override
  String get searchConversationLabel => '會話';

  @override
  String get searchMessageLabel => '消息';

  @override
  String get settingsSecurityTitle => '安全';

  @override
  String get settingsKeyBackup => '密鑰備份';

  @override
  String get settingsBackupEncryptionKeys => '備份加密密鑰';

  @override
  String settingsKeysBackedUp(int count) {
    return '已備份 $count 個密鑰';
  }

  @override
  String get settingsBackupNotSet => '未設置備份';

  @override
  String get settingsRestoreKeys => '恢復密鑰';

  @override
  String get settingsRestoreKeysFromBackup => '從備份恢復加密密鑰';

  @override
  String get settingsExportKeys => '導出密鑰';

  @override
  String get settingsExportKeysToFile => '導出密鑰到文件';

  @override
  String get settingsLoggedInDevices => '已登錄設備';

  @override
  String get settingsNoOtherDevices => '暫無其他設備';

  @override
  String get settingsVerified => '已驗證';

  @override
  String get settingsUnverified => '未驗證';

  @override
  String get settingsAdvanced => '高級';

  @override
  String get settingsCrossSigning => '跨設備簽名';

  @override
  String get settingsEnabled => '已啓用';

  @override
  String get settingsNotEnabled => '未啓用';

  @override
  String get settingsResetEncryption => '重置加密';

  @override
  String get settingsDeleteAllEncryptionKeys => '刪除所有加密密鑰';

  @override
  String get settingsEncryptionNotSupported => '不支持加密';

  @override
  String get settingsNotInitialized => '未初始化';

  @override
  String get settingsBackupKeyTitle => '備份密鑰';

  @override
  String get settingsBackupKeyMessage => '是否創建新的密鑰備份？這將幫助您在新設備上恢復加密消息。';

  @override
  String get settingsBackup => '備份';

  @override
  String get settingsRestoreKeyTitle => '恢復密鑰';

  @override
  String get settingsRestoreKeyMessage => '輸入您的恢復密碼或恢復密鑰來恢復加密消息。';

  @override
  String get settingsRestore => '恢復';

  @override
  String get settingsExportKeyTitle => '導出密鑰';

  @override
  String get settingsExportKeyMessage => '導出的密鑰文件包含您的所有加密密鑰，請妥善保管。';

  @override
  String get settingsExport => '導出';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return '設備ID: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => '狀態: 已驗證';

  @override
  String get settingsDeviceStatusUnverified => '狀態: 未驗證';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return '最後活躍: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => '驗證此設備';

  @override
  String get settingsCrossSigningAlreadyEnabled => '跨設備簽名已啓用';

  @override
  String get settingsCrossSigningSetupSuccess => '跨設備簽名設置成功';

  @override
  String get settingsResetEncryptionTitle => '重置加密';

  @override
  String get settingsResetEncryptionWarning =>
      '警告：這將刪除您所有的加密密鑰。您將無法解密之前的加密消息。此操作不可撤銷。';

  @override
  String get settingsReset => '重置';

  @override
  String get settingsBackupSuccess => '密鑰備份成功';

  @override
  String get settingsBackupFailed => '備份失敗';

  @override
  String get settingsRecoveryKey => '恢復密鑰';

  @override
  String get settingsRecoveryKeySaveWarning =>
      '請將此恢復密鑰保存在安全的地方。您需要它在新設備上恢復加密消息。';

  @override
  String get settingsRecoveryKeySaved => '我已保存';

  @override
  String get settingsRestoreSuccess => '密鑰恢復成功';

  @override
  String get settingsRestoreFailed => '恢復失敗';

  @override
  String get settingsPassword => '密碼';

  @override
  String get settingsEnterRecoveryKey => '輸入恢復密鑰';

  @override
  String get settingsEnterPassword => '輸入密碼';

  @override
  String get settingsExportSuccess => '密鑰已成功導出到服務端備份';

  @override
  String get settingsExportNeedBackupFirst => '請先創建密鑰備份';

  @override
  String get settingsExportFailed => '導出失敗';

  @override
  String get settingsResetSuccess => '加密重置成功';

  @override
  String get settingsResetFailed => '重置失敗';

  @override
  String get callLeaveMeetingConfirm => '確定要離開會議嗎？';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return '拍了拍「$name」$suffix';
  }

  @override
  String get chatNoContactsToAdd => '沒有可添加的聯繫人';

  @override
  String get chatAddMembers => '添加成員';

  @override
  String chatInvitedMembers(int count) {
    return '已邀請 $count 位成員';
  }

  @override
  String chatInviteFailed(String error) {
    return '邀請失敗: $error';
  }

  @override
  String get chatMemberRemoved => '已移除成員';

  @override
  String chatRemoveFailed(String error) {
    return '移除失敗: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage => '開始共享後，對方將能看到你的實時位置，共享時長爲1小時。';

  @override
  String get chatStartSharing => '開始共享';

  @override
  String get chatLocationServiceNotEnabled => '位置服務未開啓';

  @override
  String get chatEnableLocationService => '請開啓位置服務以使用位置功能';

  @override
  String get chatGoToSettings => '去設置';

  @override
  String get chatLocationPermissionRequired => '需要位置權限才能使用此功能';

  @override
  String get chatLocationPermissionDeniedPermanent => '位置權限已被永久拒絕，請在設置中開啓';

  @override
  String get chatLocationPermissionDenied => '位置權限被拒絕';

  @override
  String get chatGettingLocation => '正在獲取位置...';

  @override
  String chatGetLocationFailed(String error) {
    return '獲取位置失敗: $error';
  }

  @override
  String get chatMapPreview => '地圖預覽';

  @override
  String get chatSearchLocation => '搜索地點';

  @override
  String chatRedPacketSent(String amount, String token) {
    return '已發送 $amount $token 紅包';
  }

  @override
  String get chatTransferDefault => '轉賬';

  @override
  String chatTransferSent(String amount, String token) {
    return '已發送 $amount $token 轉賬';
  }

  @override
  String chatPickFileFailed(String error) {
    return '選擇文件失敗: $error';
  }

  @override
  String get chatFileSizeLimit => '文件大小不能超過 50MB';

  @override
  String chatFileSending(String filename) {
    return '文件發送中: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return '發送文件失敗: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return '已發送 $name 的名片';
  }

  @override
  String get chatFavoritesFeature => '收藏';

  @override
  String get chatCouponsFeature => '卡券';

  @override
  String get chatGiftFeature => '禮物';

  @override
  String chatSharedMusic(String name) {
    return '已分享 $name';
  }

  @override
  String get chatEndPollTitle => '結束投票';

  @override
  String get chatEndPollConfirmMessage => '確定要結束這個投票嗎？結束後將無法繼續投票。';

  @override
  String get chatPollEndedMessage => '投票已結束';

  @override
  String get chatConnectingCall => '正在連接...';

  @override
  String get chatMuteCall => '靜音';

  @override
  String get chatSpeakerOff => '關閉免提';

  @override
  String get chatSpeakerOn => '免提';

  @override
  String get chatCameraOn => '開啓攝像頭';

  @override
  String get chatCameraOff => '關閉攝像頭';

  @override
  String get chatHangUp => '掛斷';

  @override
  String get chatSelectForwardTargetTitle => '選擇轉發對象';

  @override
  String get chatNoForwardableChat => '沒有可轉發的會話';

  @override
  String get chatNoMatchingChat => '沒有找到相關會話';

  @override
  String get chatLocationTitle => '位置';

  @override
  String get chatSendButton => '發送';

  @override
  String get chatRetryButton => '重試';

  @override
  String get chatSearchContactHint => '搜索聯繫人';

  @override
  String get chatShareMusic => '分享音樂';

  @override
  String get chatRecentPlayed => '最近播放';

  @override
  String get chatMyFavorites => '我喜歡';

  @override
  String get chatNetworkLink => '網絡鏈接';

  @override
  String get chatLocalFile => '本地文件';

  @override
  String get chatPasteMusicLink => '粘貼音樂鏈接';

  @override
  String get chatShareMusicButton => '分享音樂';

  @override
  String get chatSelectLocalAudio => '選擇本地音頻文件';

  @override
  String get chatSupportedAudioFormats => '支持 MP3、M4A、WAV、FLAC 等格式';

  @override
  String get chatSelectFileButton => '選擇文件';

  @override
  String get chatPleaseEnterMusicLink => '請輸入音樂鏈接';

  @override
  String get chatPleaseEnterValidLink => '請輸入有效的網絡鏈接';

  @override
  String get chatSharedSong => '分享歌曲';

  @override
  String get chatSelectMember => '選擇成員';

  @override
  String get chatSearchMemberHint => '搜索成員';

  @override
  String get chatNoMatchingMembers => '未找到匹配的成員';

  @override
  String get commonUnknownMember => '未知';

  @override
  String chatSelectedMessagesCount(int count) {
    return '已選擇 $count 條消息';
  }

  @override
  String get chatSearchContactsOrGroups => '搜索聯繫人或羣聊';

  @override
  String get chatVideoTitle => '視頻';

  @override
  String get chatLoadingText => '加載中...';

  @override
  String get chatVideoLoadFailed => '視頻加載失敗';

  @override
  String get chatPlayerInitFailed => '播放器初始化失敗';

  @override
  String get chatCreatePollTitle => '創建投票';

  @override
  String get chatSubmitPoll => '發起';

  @override
  String get chatPollQuestionLabel => '投票問題';

  @override
  String get chatEnterPollQuestionHint => '請輸入投票問題';

  @override
  String get chatPollOptionsLabel => '投票選項';

  @override
  String chatOptionHintWithIndex(int index) {
    return '選項 $index';
  }

  @override
  String get chatAddOptionButton => '添加選項';

  @override
  String get chatPollSettingsLabel => '投票設置';

  @override
  String get chatSelectionType => '選擇類型';

  @override
  String get chatSingleChoiceLabel => '單選';

  @override
  String get chatMultiChoiceLabel => '多選';

  @override
  String get chatAnonymousPollSwitch => '匿名投票';

  @override
  String get chatPleaseEnterQuestion => '請輸入投票問題';

  @override
  String get chatAtLeastTwoOptions => '至少需要2個選項';

  @override
  String chatConfirmWithCount(int count) {
    return '確定 ($count)';
  }

  @override
  String get authEmailVerificationTitle => '郵箱驗證';

  @override
  String get authEnterValidEmailAddress => '請輸入有效的郵箱地址';

  @override
  String authVerificationCodeSentTo(String email) {
    return '驗證碼已發送到 $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return '發送驗證碼失敗: $error';
  }

  @override
  String get authVerificationSuccess => '驗證成功';

  @override
  String get authVerificationFailed => '驗證失敗';

  @override
  String authVerificationCodeError(String error) {
    return '驗證碼錯誤: $error';
  }

  @override
  String get commonEnterVerificationCode => '輸入驗證碼';

  @override
  String get authEnterYourEmail => '輸入郵箱';

  @override
  String authWeSentCodeTo(String email) {
    return '我們已向 $email 發送了\n6位驗證碼';
  }

  @override
  String get authEnterEmailForCode => '輸入您的郵箱地址，我們將發送驗證碼';

  @override
  String get commonSendVerificationCode => '發送驗證碼';

  @override
  String get authResendVerificationCode => '重新發送驗證碼';

  @override
  String authCanResendAfter(int seconds) {
    return '$seconds秒後可重新發送';
  }

  @override
  String get commonChangeEmail => '更換郵箱';

  @override
  String get contactAddToContacts => '添加到通訊錄';

  @override
  String get contactAddingToContacts => '添加中...';

  @override
  String get contactAddedToContacts => '已添加到通訊錄';

  @override
  String contactAddFailedWithError(String error) {
    return '添加失敗: $error';
  }

  @override
  String get contactAddPhone => '添加電話';

  @override
  String get contactAddTag => '添加標籤';

  @override
  String get contactAddText => '添加文字';

  @override
  String get contactAddPhoto => '添加照片';

  @override
  String contactGroupCountLabel(int count) {
    return '$count個';
  }

  @override
  String get contactAddedViaSearch => '通過搜索添加';

  @override
  String get contactAddTime => '添加時間';

  @override
  String get contactDoneButton => '完成';

  @override
  String get callWaitingForParticipants => '等待參與者加入...';

  @override
  String callParticipantMe(String name) {
    return '$name（我）';
  }

  @override
  String get callSharingLabel => '共享中';

  @override
  String callScreenSharingBy(String name) {
    return '$name 正在共享屏幕';
  }

  @override
  String callParticipantCount(int count) {
    return '$count 人';
  }

  @override
  String get callMuteLabel => '靜音';

  @override
  String get callUnmuteLabel => '解除靜音';

  @override
  String get callTurnOffVideo => '關閉視頻';

  @override
  String get callTurnOnVideo => '開啓視頻';

  @override
  String get callShareScreen => '共享屏幕';

  @override
  String get callStopSharing => '停止共享';

  @override
  String get callSwitchCameraLabel => '切換';

  @override
  String get callLeaveLabel => '離開';

  @override
  String get callParticipantsLabel => '參與者';

  @override
  String get callJoiningMeeting => '正在加入會議...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count 票 ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count 人蔘與';
  }

  @override
  String get commonTapToRetry => '點擊重試';

  @override
  String get chatDefaultRedPacketGreeting => '恭喜發財，大吉大利';

  @override
  String get groupAllowOthersToSearchAndJoin => '允許他人搜索並加入';

  @override
  String get groupConfirmClearChatHistory => '確定要清空聊天記錄嗎？';

  @override
  String get groupCreateGroupToChat => '創建羣聊以開始聊天';

  @override
  String get groupEditGroupAnnouncement => '編輯羣公告';

  @override
  String get groupEditGroupDescription => '編輯羣描述';

  @override
  String get groupEnterGroupAnnouncement => '請輸入羣公告';

  @override
  String chatErrorWithMessage(String message) {
    return '錯誤: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count人，點擊複製羣ID';
  }

  @override
  String get chatMusicLinkLabel => '音樂鏈接';

  @override
  String get chatNoMediaUrlAvailable => '沒有可用的媒體鏈接';

  @override
  String get groupNoPermissionToEditGroupName => '你沒有權限修改羣名稱';

  @override
  String get chatRedPacketTransferCannotForward => '紅包和轉賬消息無法轉發';

  @override
  String get authEmailAddress => '郵箱地址';

  @override
  String get commonEnterEmailAddress => '請輸入郵箱地址';

  @override
  String get authEmailRecoveryHint => '用於找回密碼';

  @override
  String get commonInvalidEmailFormat => '請輸入有效的郵箱地址';

  @override
  String get authOptional => '選填';

  @override
  String get authResetPassword => '重置密碼';

  @override
  String get authEnterRegisteredEmail => '請輸入註冊時綁定的郵箱地址';

  @override
  String get authSendResetCode => '發送重置驗證碼';

  @override
  String authResetCodeSent(String email) {
    return '重置驗證碼已發送至 $email';
  }

  @override
  String get authEnterResetCode => '輸入重置驗證碼';

  @override
  String get authSetNewPassword => '設置新密碼';

  @override
  String get commonConfirmNewPassword => '確認新密碼';

  @override
  String get commonNewPassword => '新密碼';

  @override
  String get authPasswordResetSuccess => '密碼重置成功，請使用新密碼登錄';

  @override
  String get authResetPasswordFailed => '重置密碼失敗';

  @override
  String get settingsChangePassword => '修改密碼';

  @override
  String get settingsCurrentPassword => '當前密碼';

  @override
  String get settingsEnterCurrentPassword => '請輸入當前密碼';

  @override
  String get settingsEnterNewPassword => '請輸入新密碼';

  @override
  String get settingsPasswordChanged => '密碼修改成功，請使用新密碼重新登錄';

  @override
  String get settingsChangePasswordFailed => '修改密碼失敗';

  @override
  String get settingsNewPasswordMustBeDifferent => '新密碼不能與當前密碼相同';

  @override
  String get settingsChangePasswordInfo => '修改密碼後，您將被登出，需要使用新密碼重新登錄。';

  @override
  String get settingsPasswordRequirements => '密碼要求：';

  @override
  String get settingsSecurityNote => '爲了安全，修改密碼後需要在所有設備上重新登錄。';

  @override
  String get settingsSecurity => '安全';

  @override
  String get settingsCurrentBoundEmail => '當前綁定郵箱';

  @override
  String get settingsNewEmailAddress => '新郵箱地址';

  @override
  String get settingsEnterNewEmail => '請輸入新郵箱地址';

  @override
  String get settingsVerificationCode => '驗證碼';

  @override
  String get settingsVerificationCodeSent => '驗證碼已發送';

  @override
  String get settingsCodeSentTo => '驗證碼已發送至';

  @override
  String get settingsDidNotReceiveCode => '沒有收到驗證碼？';

  @override
  String get settingsEmailChangedSuccess => '郵箱修改成功';

  @override
  String get settingsChangeEmailFailed => '修改郵箱失敗';

  @override
  String get settingsEmailSecurityNote => '郵箱用於密碼找回，請確保安全。';

  @override
  String get commonGoogleLogin => '使用 Google 登錄';

  @override
  String get commonAppleLogin => '使用 Apple 登錄';

  @override
  String get commonWechat => '微信';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsLanguageChanged => '語言已更改';

  @override
  String get settingsTranslation => '翻譯';

  @override
  String get settingsTranslateTextTo => '將文字翻譯爲';

  @override
  String get settingsTranslateDescription => '選擇你希望將消息翻譯成的語言。';

  @override
  String get settingsAutoTranslate => '自動翻譯聊天中收到的消息';

  @override
  String get settingsAutoTranslateDescription => '自動將聊天中收到的消息翻譯爲你選擇的語言。';

  @override
  String get settingsBiometricLogin => '生物識別登錄';

  @override
  String authLoginWithBiometric(Object type) {
    return '使用$type登錄';
  }

  @override
  String get settingsBiometricLoginEnabled => '生物識別登錄已啓用';

  @override
  String get settingsBiometricLoginDisabled => '生物識別登錄已禁用';

  @override
  String get settingsEnableBiometricLogin => '啓用生物識別登錄';

  @override
  String get settingsBiometricEnabled => '已啓用 - 使用生物識別登錄';

  @override
  String get settingsBiometricDisabled => '已禁用 - 點擊啓用';

  @override
  String get settingsBiometricNeedRelogin => '請退出後重新登錄以啓用生物識別';

  @override
  String get authOr => '或';

  @override
  String get qrcodeCameraPermissionRestricted => '此設備上的相機訪問受限';

  @override
  String get authPasskeyLabel => 'Passkey';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'Apple';

  @override
  String get authSsoLabel => 'SSO';

  @override
  String get transferAmountHintZero => '0.00';

  @override
  String get commonMatrixIdHint => '@username:server.com';

  @override
  String get authServerAddressHint => 'https://m.si46.world';

  @override
  String get authEmailExampleHint => 'example@email.com';

  @override
  String get authVerificationCodePlaceholder => '------';

  @override
  String get profileEnterPokeSuffixHint => '輸入戳一戳後綴，例如：的肩膀';

  @override
  String get groupAlbum => '羣相冊';

  @override
  String get groupFiles => '羣文件';

  @override
  String get groupImages => '圖片';

  @override
  String get groupVideos => '視頻';

  @override
  String get groupTotal => '全部';

  @override
  String get groupSize => '大小';

  @override
  String get groupNoMedia => '暫無媒體';

  @override
  String get groupNoMediaDescription => '此羣還沒有圖片或視頻';

  @override
  String get groupDocuments => '文檔';

  @override
  String get groupNoFiles => '暫無文件';

  @override
  String get groupNoFilesDescription => '此羣還沒有文件';

  @override
  String groupDownloadStarted(String filename) {
    return '正在下載 $filename...';
  }

  @override
  String get contactNoCommonGroups => '暫無共同羣組';

  @override
  String get contactNoCommonGroupsDescription => '你們沒有共同加入的羣組';

  @override
  String get chatVoiceMessage => '語音';

  @override
  String get chatMessage => '消息';

  @override
  String get conversationHideChat => '隱藏';

  @override
  String get settingsQuickReply => '快捷回覆';

  @override
  String get commonTranslate => '翻譯';

  @override
  String get contactCreateTag => '新建標籤';

  @override
  String get contactEnterTagName => '輸入標籤名稱';

  @override
  String get contactEditTag => '編輯標籤';

  @override
  String get contactDeleteTag => '刪除標籤';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return '確定要刪除標籤 \"$tagName\" 嗎？';
  }

  @override
  String get contactNoTags => '暫無標籤';

  @override
  String get contactFriendPermissions => '朋友權限';

  @override
  String get contactSetChatOnly => '設爲僅聊天';

  @override
  String get contactChatOnlyDesc => '只能聊天，其他內容將被隱藏';

  @override
  String get contactHideMyMoments => '不讓他（她）看我的朋友圈';

  @override
  String get contactHideMyMomentsDesc => '該好友無法查看你的朋友圈動態';

  @override
  String get contactHideTheirMoments => '不看他（她）的朋友圈';

  @override
  String get contactHideTheirMomentsDesc => '不會看到該好友的朋友圈動態';

  @override
  String get contactHideMyStatus => '不讓他（她）看我的狀態';

  @override
  String get contactHideMyStatusDesc => '該好友無法查看你的狀態更新';

  @override
  String get contactNoChatOnlyFriends => '暫無僅聊天的朋友';

  @override
  String get contactNoOfficialAccounts => '暫無公衆號';

  @override
  String get contactFollowOfficialAccountsDesc => '關注公衆號，獲取最新資訊';

  @override
  String get contactNoServiceAccounts => '暫無服務號';

  @override
  String get contactSubscribeServiceAccountsDesc => '訂閱服務號，享受便捷服務';

  @override
  String get contactNoEnterpriseContacts => '暫無企業聯繫人';

  @override
  String get contactEnterpriseContactsDesc => '企業通訊錄聯繫人將顯示在這裏';

  @override
  String get profileCardPack => '卡包';

  @override
  String get profileOrders => '訂單';

  @override
  String get profileNoOrders => '暫無訂單';

  @override
  String get profileOrdersDesc => '你的訂單將顯示在這裏';

  @override
  String get profileNoCards => '暫無卡券';

  @override
  String get profileCardsDesc => '你的卡券將顯示在這裏';

  @override
  String get favoriteEnterTagsHint => '輸入標籤，用逗號分隔';

  @override
  String get favoriteTagsUpdated => '標籤已更新';

  @override
  String get favoriteForwardedContent => '內容已轉發';

  @override
  String get favoriteEnterNoteContent => '輸入筆記內容';

  @override
  String get favoriteNoteAdded => '筆記已添加';

  @override
  String get favoriteLinkTitle => '鏈接標題';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => '鏈接已添加';

  @override
  String get contactPhotoAdded => '照片已添加';

  @override
  String get contactEnterPhone => '輸入手機號碼';

  @override
  String commonConversationWithId(String roomId) {
    return '會話: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return '聯繫人: $userId';
  }

  @override
  String get commonDiscover => '發現';

  @override
  String commonDeveloping(String title) {
    return '$title\n(開發中)';
  }

  @override
  String get commonPageNotFound => '頁面不存在';

  @override
  String get commonBackToHome => '返回首頁';

  @override
  String get settingsMessageNotifications => '消息通知';

  @override
  String get settingsReceiveNewMessageNotifications => '接收新消息通知';

  @override
  String get settingsShowMessagePreview => '顯示消息預覽';

  @override
  String get settingsShowMessageContentInNotification => '在通知中顯示消息內容';

  @override
  String get settingsNotificationSound => '通知聲音';

  @override
  String get settingsPlaySoundOnMessage => '收到消息時播放聲音';

  @override
  String get commonVibration => '振動';

  @override
  String get settingsVibrateOnMessage => '收到消息時震動';

  @override
  String get settingsDoNotDisturbMode => '勿擾模式';

  @override
  String get settingsDoNotDisturbDescription => '在指定時間內不接收通知';

  @override
  String get settingsStartTime => '開始時間';

  @override
  String get settingsEndTime => '結束時間';

  @override
  String get settingsDeleteQuickReply => '刪除快捷回覆';

  @override
  String get settingsEditQuickReply => '編輯快捷回覆';

  @override
  String get settingsAddQuickReply => '添加快捷回覆';

  @override
  String get settingsManageQuickReplies => '管理快捷回覆';

  @override
  String get settingsNoQuickReplies => '暫無快捷回覆';

  @override
  String get settingsDefaultQuickReplies => '將顯示默認快捷回覆';

  @override
  String get settingsWhoCanSee => '誰可以查看';

  @override
  String get settingsLastSeen => '最後上線時間';

  @override
  String get settingsHiddenChats => '隱藏的聊天';

  @override
  String get settingsMessagesLabel => '消息';

  @override
  String get settingsAllowStrangerMessages => '允許陌生人消息';

  @override
  String get settingsReceiveMessagesFromNonContacts => '接收非聯繫人的消息';

  @override
  String get settingsReadReceipts => '已讀回執';

  @override
  String get settingsLetOthersKnowYouRead => '讓對方知道你已讀';

  @override
  String get settingsTypingIndicator => '輸入狀態指示';

  @override
  String get settingsLetOthersKnowYouTyping => '讓對方知道你正在輸入';

  @override
  String get settingsEveryone => '所有人';

  @override
  String get settingsContactsOnly => '僅聯繫人';

  @override
  String get settingsNobody => '無人';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return '誰可以看到 $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return '版本 $version';
  }

  @override
  String get settingsCheckForUpdates => '檢查更新';

  @override
  String get settingsOpenSourceLicenses => '開源許可';

  @override
  String get settingsFeedbackAndSuggestions => '反饋與建議';

  @override
  String get settingsBuiltOnMatrix => '基於 Matrix 協議構建';

  @override
  String get settingsNoHiddenChats => '沒有隱藏的聊天';

  @override
  String get settingsNoHiddenChatsDescription => '你隱藏的聊天會顯示在這裏';

  @override
  String get settingsUnhideChat => '取消隱藏';

  @override
  String get settingsDarkMode => '深色模式';

  @override
  String get settingsFontSize => '字體大小';

  @override
  String get settingsBubbleStyle => '氣泡樣式';

  @override
  String get settingsFollowSystem => '跟隨系統';

  @override
  String get settingsAutoSwitchBySystem => '跟隨系統自動切換';

  @override
  String get settingsLightMode => '淺色模式';

  @override
  String get settingsAlwaysUseLightTheme => '始終使用淺色主題';

  @override
  String get settingsDarkModeOption => '深色模式選項';

  @override
  String get settingsAlwaysUseDarkTheme => '始終使用深色主題';

  @override
  String get settingsFontSizeSmall => '小';

  @override
  String get settingsFontSizeStandard => '標準';

  @override
  String get settingsFontSizeLarge => '大';

  @override
  String get settingsFontSizeExtraLarge => '特大';

  @override
  String get settingsBubbleStyleWechat => '微信樣式';

  @override
  String get settingsBubbleStyleWechatDesc => '經典微信氣泡樣式';

  @override
  String get settingsBubbleStyleModern => '現代樣式';

  @override
  String get settingsBubbleStyleModernDesc => '簡潔的現代氣泡樣式';

  @override
  String get settingsBubbleStyleClassic => '經典樣式';

  @override
  String get settingsBubbleStyleClassicDesc => '傳統的氣泡樣式';

  @override
  String get discoverVideoChannels => '視頻號';

  @override
  String get discoverLive => '直播';

  @override
  String get discoverListen => '聽一聽';

  @override
  String get discoverWatch => '看一看';

  @override
  String get discoverSearchDiscover => '搜一搜';

  @override
  String get discoverNearbyPeople => '附近的人';

  @override
  String get discoverGames => '遊戲';

  @override
  String get discoverMiniPrograms => '小程序';

  @override
  String get chatAlreadyInCall => '當前正在通話中';

  @override
  String get commonConnectionFailed => '連接失敗';

  @override
  String get chatCallRejected => '對方已拒絕';

  @override
  String get chatNoAnswer => '對方無應答';

  @override
  String get commonClose => '關閉';

  @override
  String get chatSelectContact => '選擇聯繫人';

  @override
  String get chatVoteRemoved => '已取消投票';

  @override
  String get chatVoteChanged => '投票已更改';

  @override
  String get chatVoted => '已投票';

  @override
  String chatReplyTo(String name) {
    return '回覆 $name';
  }

  @override
  String get chatCurrentLocation => '當前位置';

  @override
  String chatNearbyPlace(int index) {
    return '附近地點 $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return '約 $distance';
  }

  @override
  String get chatAddress => '地址';

  @override
  String get chatLatitude => '緯度';

  @override
  String get chatLongitude => '經度';

  @override
  String get groupDescriptionUpdated => '羣簡介已更新';

  @override
  String get groupAvatarUpdated => '羣頭像已更新';

  @override
  String get groupVisibilityUpdated => '羣可見性已更新';

  @override
  String get groupChannelCreated => '頻道已創建';

  @override
  String get groupChannelUpdated => '頻道已更新';

  @override
  String get groupChannelDeleted => '頻道已刪除';

  @override
  String get callDecline => '拒絕';

  @override
  String get callAnswer => '接聽';

  @override
  String get callIncomingVideoCall => '視頻來電';

  @override
  String get callIncomingVoiceCall => '語音來電';

  @override
  String get callVideoCallInProgress => '視頻通話中';

  @override
  String get callVoiceCallInProgress => '語音通話中';

  @override
  String get callReconnectingCall => '正在重連...';

  @override
  String get callEnded => '通話已結束';

  @override
  String get callFailed => '通話失敗';

  @override
  String get callLivekitNotConfigured => 'LiveKit 未配置';

  @override
  String callJoinMeetingFailed(String error) {
    return '加入會議失敗: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return '屏幕共享失敗: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42豆';

  @override
  String get profileNoN42Bean => '暫無N42豆';

  @override
  String get profileN42BeanDetails => 'N42豆明細';

  @override
  String get profileN42BeanDescription => 'N42豆是用於兌換N42內虛擬物品和服務的道具，目前可用於兌換：';

  @override
  String get profileN42BeanFeature1 => '會員專屬表情和主題';

  @override
  String get profileN42BeanFeature2 => '聊天氣泡個性化';

  @override
  String get profileN42BeanFeature3 => '紅包封面定製';

  @override
  String get profileN42BeanFeature4 => '專屬暱稱標識';

  @override
  String get profileN42BeanFeature5 => '羣聊特權功能';

  @override
  String get profileN42BeanFeature6 => '雲存儲空間擴展';

  @override
  String get profileN42BeanFeature7 => '視頻通話美顏濾鏡';

  @override
  String get profileN42BeanFeature8 => '朋友圈背景更換';

  @override
  String get profileN42BeanFeature9 => 'VIP客服優先服務';

  @override
  String get profileGotIt => '我知道了';

  @override
  String get profileNoN42BeanRecords => '暫無N42豆明細記錄';

  @override
  String get profileMoodAndThoughts => '心情想法';

  @override
  String get profileStatusHappy => '開心';

  @override
  String get profileStatusCracked => '裂開';

  @override
  String get profileStatusLucky => '發呆';

  @override
  String get profileStatusSunny => '天氣晴';

  @override
  String get profileStatusTired => '累了';

  @override
  String get profileStatusDaydream => '發呆中';

  @override
  String get profileStatusRushing => '忙碌';

  @override
  String get profileStatusOverthinking => '想太多';

  @override
  String get profileStatusEnergized => '元氣滿滿';

  @override
  String get profileWorkAndStudy => '工作學習';

  @override
  String get profileStatusWorking => '搬磚中';

  @override
  String get profileStatusStudying => '學習中';

  @override
  String get profileStatusBusy => '忙';

  @override
  String get profileStatusSlacking => '摸魚中';

  @override
  String get profileStatusTraveling => '旅行中';

  @override
  String get profileStatusGoingHome => '回家中';

  @override
  String get profileStatusDnd => '請勿打擾';

  @override
  String get profileActivities => '活動';

  @override
  String get profileStatusHanging => '出去浪';

  @override
  String get profileStatusCheckIn => '打卡';

  @override
  String get profileStatusExercising => '運動中';

  @override
  String get profileStatusCoffee => '喝咖啡';

  @override
  String get profileStatusBubbleTea => '奶茶';

  @override
  String get profileStatusEating => '乾飯中';

  @override
  String get profileStatusParenting => '帶娃中';

  @override
  String get profileStatusSavingWorld => '拯救世界';

  @override
  String get profileStatusSelfie => '自拍';

  @override
  String get profileRest => '休息';

  @override
  String get profileStatusRetreat => '閉關';

  @override
  String get profileStatusHome => '宅家';

  @override
  String get profileStatusSleeping => '睡覺中';

  @override
  String get profileStatusCatLover => '吸貓中';

  @override
  String get profileStatusDogWalking => '遛狗中';

  @override
  String get profileStatusGaming => '遊戲中';

  @override
  String get profileStatusListening => '聽歌中';

  @override
  String get profileEditAddress => '編輯地址';

  @override
  String get profileRecipient => '收貨人';

  @override
  String get profileEnterRecipientName => '請輸入收貨人姓名';

  @override
  String get profilePhoneNumber => '手機號碼';

  @override
  String get profileEnterPhoneNumber => '請輸入手機號碼';

  @override
  String get profileRegionHint => '省/市/區';

  @override
  String get profileDetailedAddress => '詳細地址';

  @override
  String get profileDetailedAddressHint => '街道、門牌號等';

  @override
  String get profileSetAsDefaultAddress => '設爲默認地址';

  @override
  String get profilePleaseCompleteInfo => '請填寫完整信息';

  @override
  String get profileEditInvoice => '編輯發票抬頭';

  @override
  String get profileInvoiceType => '抬頭類型';

  @override
  String get profileCompanyName => '企業名稱';

  @override
  String get profilePersonalName => '個人姓名';

  @override
  String get profileEnterCompanyName => '請輸入企業名稱';

  @override
  String get profileEnterName => '請輸入姓名';

  @override
  String get profileTaxIdNumber => '納稅人識別號';

  @override
  String get profileEnterTaxIdNumber => '請輸入納稅人識別號';

  @override
  String get profileBankNameOptional => '開戶銀行（選填）';

  @override
  String get profileEnterBankName => '請輸入開戶銀行';

  @override
  String get profileBankAccountOptional => '銀行賬號（選填）';

  @override
  String get profileEnterBankAccount => '請輸入銀行賬號';

  @override
  String get profileCompanyAddressOptional => '企業地址（選填）';

  @override
  String get profileEnterCompanyAddress => '請輸入企業地址';

  @override
  String get profileCompanyPhoneOptional => '企業電話（選填）';

  @override
  String get profileEnterCompanyPhone => '請輸入企業電話';

  @override
  String get profileSetAsDefaultInvoice => '設爲默認抬頭';

  @override
  String get profileRingtoneVibrate => '震動';

  @override
  String get profileRingtoneSilent => '靜音';

  @override
  String get profileVibrateMode => '振動模式';

  @override
  String get profileSilentMode => '靜音模式';

  @override
  String profilePlayFailed(String ringtoneName) {
    return '播放失敗: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return '正在播放: $ringtoneName';
  }

  @override
  String get profileStop => '停止';

  @override
  String get profileSelectRingtone => '選擇鈴聲';

  @override
  String get profileLoadingRingtones => '加載鈴聲中...';

  @override
  String get profileNoRingtonesFound => '未找到鈴聲';

  @override
  String mainMessagesWithCount(int count) {
    return '消息($count)';
  }

  @override
  String get storyViewers => '瀏覽者';

  @override
  String get storyNoViewers => '暫無瀏覽';

  @override
  String get storyReplyToStory => '回覆狀態...';

  @override
  String get commonCopiedToClipboard => '已複製到剪貼板';

  @override
  String get commonMore => '更多';

  @override
  String get commonTranslating => '翻譯中...';

  @override
  String commonTranslatedFrom(String language) {
    return '翻譯自$language';
  }

  @override
  String get commonTranslation => '翻譯';

  @override
  String get commonTranslationFailed => '翻譯失敗';

  @override
  String get commonAllRead => '全部已讀';

  @override
  String commonReadCount(int count) {
    return '$count人已讀';
  }

  @override
  String get commonYouRecalledMessage => '你撤回了一條消息';

  @override
  String get commonMessageRecalled => '對方撤回了一條消息';

  @override
  String get commonReEdit => '重新編輯';

  @override
  String get commonWalletArea => '錢包功能區域';

  @override
  String get callIncomingCall => '來電';

  @override
  String get callMissedCall => '未接來電';

  @override
  String get groupRemoveAdmin => '取消管理員';

  @override
  String get chatSelectCurrency => '選擇幣種';

  @override
  String get chatSelectEmoji => '選擇表情';

  @override
  String get chatSelectRedPacketCover => '選擇封面';

  @override
  String get groupSetAsAdmin => '設爲管理員';

  @override
  String get chatVideoPlaybackFailed => '視頻播放失敗';

  @override
  String get groupViewProfile => '查看資料';

  @override
  String get favoriteAddLinkComingSoon => '添加鏈接功能即將推出';

  @override
  String get favoriteNewNoteComingSoon => '新建筆記功能即將推出';

  @override
  String get qrcodeSaveFeatureComingSoon => '保存功能即將推出';

  @override
  String get qrcodeShareFeatureComingSoon => '分享功能即將推出';

  @override
  String qrcodeProcessFailed(String error) {
    return '處理二維碼失敗: $error';
  }

  @override
  String get securityDeviceIdRequired => '需要設備 ID';

  @override
  String securityVerificationStartFailed(String error) {
    return '啓動驗證失敗: $error';
  }

  @override
  String get securityVerificationFailed => '驗證失敗';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return '驗證失敗: $reason';
  }

  @override
  String get securityEmojiMismatchRejected => '驗證被拒絕 - 表情不匹配';

  @override
  String get securityWaitingForDeviceAccept => '等待另一臺設備接受...';

  @override
  String get securityVerifyDevice => '驗證此設備';

  @override
  String get securityConfirmEmojiMatch => '確認以下表情符號在兩臺設備上以相同順序顯示';

  @override
  String get securityEmojiDontMatch => '不匹配';

  @override
  String get securityEmojiMatch => '匹配';

  @override
  String get securityWaitingForDeviceConfirm => '等待另一臺設備確認...';

  @override
  String get securityVerificationSuccess => '驗證成功！';

  @override
  String get securityDeviceVerifiedTrusted => '此設備已驗證並可信任。';

  @override
  String get securityCompareEmoji => '比較兩臺設備上的表情符號';

  @override
  String get securityCompareNumbers => '比較兩臺設備上的數字';

  @override
  String get commonTryAgain => '重試';

  @override
  String get commonDone => '完成';

  @override
  String get chatExportTitle => '導出聊天記錄';

  @override
  String get chatExportSuccess => '導出成功';

  @override
  String chatExportFailed(String error) {
    return '導出失敗: $error';
  }

  @override
  String get chatExportFormat => '導出格式';

  @override
  String get chatExportHtmlDesc => '可在任何瀏覽器中打開的精美排版';

  @override
  String get chatExportJsonDesc => '機器可讀的結構化數據格式';

  @override
  String get chatExportDateRange => '日期範圍';

  @override
  String get chatExportAll => '全部消息';

  @override
  String get chatExportLastWeek => '最近7天';

  @override
  String get chatExportLastMonth => '最近一個月';

  @override
  String get chatExportLast3Months => '最近三個月';

  @override
  String get chatExportMessageCount => '待導出消息';

  @override
  String get chatExportButton => '導出並分享';

  @override
  String get chatMediaGallery => '媒體文件';

  @override
  String get chatExportHistory => '導出聊天記錄';

  @override
  String get pdfLoadFailed => '加載 PDF 失敗';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => '全部';

  @override
  String get mediaImages => '圖片';

  @override
  String get mediaVideos => '視頻';

  @override
  String get mediaFiles => '文件';

  @override
  String get mediaAudio => '音頻';

  @override
  String mediaItemsCount(int count) {
    return '$count 項';
  }

  @override
  String get mediaNoMediaFound => '暫無媒體文件';

  @override
  String get spacesTitle => '社區';

  @override
  String get spacesCreate => '創建社區';

  @override
  String get spacesJoined => '已加入';

  @override
  String get spacesDiscover => '發現';

  @override
  String get spacesNoJoined => '還沒有加入任何社區';

  @override
  String get spacesExplore => '探索社區';

  @override
  String get spacesNoPublic => '沒有找到公共社區';

  @override
  String get spacesJoin => '加入';

  @override
  String get spacesSubSpaces => '子社區';

  @override
  String get spacesChannels => '頻道';

  @override
  String spacesMembersCount(int count) {
    return '$count 位成員';
  }

  @override
  String get spacesPublic => '公開';

  @override
  String get spacesPrivate => '私密';

  @override
  String get spacesSuggested => '推薦';

  @override
  String spacesChannelsCount(int count) {
    return '$count 個頻道';
  }

  @override
  String get callInCallChat => '通話中聊天';

  @override
  String callMessagesCount(int count) {
    return '$count 條消息';
  }

  @override
  String get callNoMessagesYet => '暫無消息\n發送一條消息開始聊天';

  @override
  String get callTypeMessage => '輸入消息...';

  @override
  String get callYouSender => '我';

  @override
  String get callChatLabel => '聊天';

  @override
  String get chatEdited => '已編輯';

  @override
  String get chatEditHistory => '編輯歷史';

  @override
  String get chatOriginalMessage => '原始消息';

  @override
  String chatEditedAt(String time) {
    return '編輯於 $time';
  }

  @override
  String get chatViewOnce => '閱後即焚';

  @override
  String get chatViewOncePhoto => '閱後即焚照片';

  @override
  String get chatViewOnceVideo => '閱後即焚視頻';

  @override
  String get chatViewOnceViewed => '已查看';

  @override
  String get chatViewOnceExpired => '已過期';

  @override
  String get chatViewOnceTap => '點擊查看';

  @override
  String get chatAutoFaceBlur => '自動模糊人臉';

  @override
  String get chatAutoFaceBlurDesc => '發送照片時自動模糊人臉';

  @override
  String get threadReplyInThread => '在線程中回覆';

  @override
  String threadReplies(int count) {
    return '$count 條回覆';
  }

  @override
  String get threadReply => '1 條回覆';

  @override
  String threadLatestReply(String preview) {
    return '最新: $preview';
  }

  @override
  String get threadTitle => '消息線程';

  @override
  String get threadReplyPlaceholder => '在線程中回覆...';

  @override
  String threadParticipants(int count) {
    return '$count 位參與者';
  }

  @override
  String get voiceRoomTitle => '語音聊天室';

  @override
  String get voiceRoomCreate => '創建語音房間';

  @override
  String get voiceRoomJoin => '加入';

  @override
  String get voiceRoomLeave => '離開';

  @override
  String get voiceRoomEnd => '結束房間';

  @override
  String get voiceRoomRaiseHand => '舉手';

  @override
  String get voiceRoomLowerHand => '放下手';

  @override
  String get voiceRoomMute => '靜音';

  @override
  String get voiceRoomUnmute => '取消靜音';

  @override
  String get voiceRoomHost => '主持人';

  @override
  String get voiceRoomSpeakers => '發言者';

  @override
  String get voiceRoomListeners => '聽衆';

  @override
  String get voiceRoomLive => '直播中';

  @override
  String get voiceRoomEnded => '已結束';

  @override
  String get voiceRoomScheduled => '已預約';

  @override
  String get voiceRoomApprove => '批准發言';

  @override
  String get voiceRoomDemote => '移至聽衆';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name 舉手了';
  }

  @override
  String get voiceRoomName => '房間名稱';

  @override
  String get voiceRoomTopic => '話題（可選）';

  @override
  String get voiceRoomNoActive => '暫無活躍的語音房間';

  @override
  String get voiceRoomConnecting => '連接中...';

  @override
  String get usernameTitle => '用戶名';

  @override
  String get usernameSet => '設置用戶名';

  @override
  String get usernameChange => '修改用戶名';

  @override
  String get usernamePlaceholder => '輸入用戶名';

  @override
  String get usernameAvailable => '用戶名可用';

  @override
  String get usernameUnavailable => '用戶名已被佔用';

  @override
  String get usernameInvalid => '3-30個字符，小寫字母、數字、下劃線，必須以字母開頭';

  @override
  String get usernameReserved => '此用戶名爲保留名稱';

  @override
  String get usernameSaved => '用戶名已保存';

  @override
  String get usernameSearchHint => '通過 @用戶名 搜索';

  @override
  String get ensName => 'ENS 域名';

  @override
  String get ensLinked => '已關聯 ENS';

  @override
  String get ensResolving => '正在解析 ENS...';

  @override
  String get ensNotFound => '未找到 ENS 域名';

  @override
  String get tokenGateTitle => '代幣門控';

  @override
  String get tokenGateEnable => '啓用代幣門控';

  @override
  String get tokenGateDisable => '禁用代幣門控';

  @override
  String get tokenGateAddRule => '添加規則';

  @override
  String get tokenGateRemoveRule => '刪除規則';

  @override
  String get tokenGateContractAddress => '合約地址';

  @override
  String get tokenGateMinBalance => '最低餘額';

  @override
  String get tokenGateTokenId => 'Token ID (ERC-1155)';

  @override
  String get tokenGateChainId => '鏈 ID';

  @override
  String get tokenGateVerifying => '正在驗證代幣持有...';

  @override
  String get tokenGateVerified => '驗證通過';

  @override
  String get tokenGateDenied => '您未滿足代幣要求';

  @override
  String get tokenGateOperatorAnd => '需滿足所有規則';

  @override
  String get tokenGateOperatorOr => '滿足任一規則即可';

  @override
  String get tokenGateRuleErc20 => 'ERC-20 代幣';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => '多代幣 (ERC-1155)';

  @override
  String get tokenGateRuleNative => '原生代幣';

  @override
  String get tokenGateSaved => '代幣門控已保存';

  @override
  String get tokenGateEnableDescription => '要求成員持有指定代幣才能加入';

  @override
  String get tokenGateOperator => '規則邏輯';

  @override
  String get tokenGateRules => '規則列表';

  @override
  String get tokenGateSymbol => '代幣符號（可選）';

  @override
  String get tokenGateChain => '區塊鏈';

  @override
  String get tokenGateTokenStandard => '代幣標準';

  @override
  String get tokenGateDenialMessage => '拒絕消息';

  @override
  String get tokenGateDenialMessageHint => '驗證失敗時顯示的消息';

  @override
  String get tokenGateVerifyTitle => '代幣驗證';

  @override
  String get tokenGateVerifyPassed => '驗證通過';

  @override
  String get tokenGateVerifyFailed => '驗證未通過';

  @override
  String get tokenGateRetryVerify => '重新驗證';

  @override
  String get tokenGateRequired => '要求';

  @override
  String get tokenGateYourBalance => '你的餘額';

  @override
  String get tokenGateRulesActive => '條規則生效';

  @override
  String get tokenGateDisabled => '未啓用';

  @override
  String get ensNotBound => '未綁定';

  @override
  String get liveLocation => '實時位置';

  @override
  String get stopLiveLocation => '停止共享';

  @override
  String get startLiveLocation => '開始共享';

  @override
  String get selectDuration => '選擇共享時長';

  @override
  String get groupChatFiles => '聊天文件';

  @override
  String get groupLinks => '鏈接';

  @override
  String get groupNoLinks => '暫無鏈接';

  @override
  String get chatBackground => '聊天背景';

  @override
  String get solidColors => '純色';

  @override
  String get gradients => '漸變';

  @override
  String get defaultBackground => '默認';

  @override
  String get settingsFontSizeSlider => '字體大小';

  @override
  String get autoDownload => '自動下載';

  @override
  String get images => '圖片';

  @override
  String get voice => '語音';

  @override
  String get video => '視頻';

  @override
  String get files => '文件';

  @override
  String get mobileData => '移動數據';

  @override
  String get roaming => '漫遊';

  @override
  String get storageManagement => '存儲管理';

  @override
  String get totalUsage => '總用量';

  @override
  String get cache => '緩存';

  @override
  String get other => '其他';

  @override
  String get clearCache => '清理緩存';

  @override
  String get cacheCleared => '緩存已清除';

  @override
  String get clearCacheFailed => '清理緩存失敗';

  @override
  String get confirmClearCache => '確認清理所有緩存數據？';

  @override
  String get mapView => '地圖視圖';

  @override
  String liveLocationSharingCount(int count) {
    return '$count 人正在共享位置';
  }

  @override
  String get minutes15 => '15 分鐘';

  @override
  String get minutes30 => '30 分鐘';

  @override
  String get hour1 => '1 小時';

  @override
  String get hours8 => '8 小時';

  @override
  String get personalCard => '個人名片';

  @override
  String get downloadFailed => '下載失敗';

  @override
  String get locationExpired => '已過期';

  @override
  String secondsRemaining(int count) {
    return '$count秒';
  }

  @override
  String minutesRemaining(int count) {
    return '$count分鐘';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours小時$minutes分鐘';
  }

  @override
  String get favoriteMessages => '收藏消息';

  @override
  String get linksCopied => '鏈接已複製';

  @override
  String get noLinksFound => '未找到鏈接';

  @override
  String get roomStorageRanking => '房間存儲排行';

  @override
  String get downloadComplete => '下載完成';

  @override
  String get downloading => '下載中...';

  @override
  String get draftSaved => '草稿已保存';

  @override
  String get voiceRecording => '語音錄製';

  @override
  String get searchLocation => '搜索地點';

  @override
  String get tapToSearch => '點擊搜索';

  @override
  String get settingsThisDevice => '本設備';

  @override
  String get settingsJustNow => '剛剛';

  @override
  String get settingsDeviceId => '設備 ID';

  @override
  String get settingsStatus => '狀態';

  @override
  String get settingsLastActive => '最後活躍';

  @override
  String get settingsIpAddress => 'IP 地址';

  @override
  String get settingsRenameDevice => '重命名設備';

  @override
  String get settingsDeviceNameHint => '輸入設備名稱';

  @override
  String get settingsDeviceRenamed => '設備已重命名';

  @override
  String get settingsRenameFailed => '重命名失敗';

  @override
  String get settingsRemoteLogout => '遠程登出';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return '確定要登出「$deviceName」嗎？此操作無法撤銷。';
  }

  @override
  String get settingsDeviceLoggedOut => '設備已登出';

  @override
  String get settingsLogoutFailed => '登出失敗';

  @override
  String get settingsLogout => '登出';

  @override
  String get settingsVerifyIdentity => '驗證身份';

  @override
  String get settingsEnterPasswordToConfirm => '請輸入密碼以確認此操作。';

  @override
  String get scheduledSendTitle => '定時發送';

  @override
  String get scheduledSendInOneHour => '1小時後';

  @override
  String get scheduledSendTonight => '今晚 (20:00)';

  @override
  String get scheduledSendTomorrowMorning => '明早 (9:00)';

  @override
  String get scheduledSendCustom => '自定義時間';

  @override
  String get scheduledMessageLabel => '定時發送';

  @override
  String get scheduledMessageCancel => '取消定時發送';

  @override
  String get chatLockTitle => '聊天鎖';

  @override
  String get chatLockEnable => '鎖定此聊天';

  @override
  String get chatLockDisable => '解鎖此聊天';

  @override
  String get chatLockDescription => '鎖定的聊天需要通過生物識別或 PIN 碼驗證才能打開';

  @override
  String get chatLockVerifyTitle => '聊天已鎖定';

  @override
  String get chatLockVerifySubtitle => '驗證後訪問此聊天';

  @override
  String get chatLockVerifyFailed => '驗證失敗';

  @override
  String get chatLockEnabled => '聊天已鎖定';

  @override
  String get chatLockDisabled => '聊天已解鎖';

  @override
  String get chatLockPinTitle => '輸入 PIN 碼';

  @override
  String get chatLockPinSetTitle => '設置 PIN 碼';

  @override
  String get chatLockPinConfirmTitle => '確認 PIN 碼';

  @override
  String get chatLockPinMismatch => 'PIN 碼不一致';

  @override
  String get chatLockUseBiometric => '使用生物識別';

  @override
  String get chatLockUsePin => '使用 PIN 碼';

  @override
  String get mediaEditorUndo => '撤銷';

  @override
  String get mediaEditorRedo => '重做';

  @override
  String get mediaEditorCrop => '裁剪';

  @override
  String get mediaEditorFilter => '濾鏡';

  @override
  String get mediaEditorDraw => '塗鴉';

  @override
  String get mediaEditorText => '文字';

  @override
  String get aiAssistant => 'AI 助手';

  @override
  String get aiAssistantWelcome => '你好！我是 N42 AI 助手，有什麼可以幫你的嗎？';

  @override
  String get aiAssistantNotConfigured => 'AI 服務未配置';

  @override
  String get aiAssistantSettings => 'AI 設置';

  @override
  String get aiAssistantClearHistory => '清空對話歷史';

  @override
  String get aiAssistantClearHistoryConfirm => '確定清空所有 AI 對話歷史？';

  @override
  String get aiAssistantStopGenerating => '停止生成';

  @override
  String get aiAssistantModel => '模型';

  @override
  String get aiAssistantTemperature => '溫度';

  @override
  String get aiAssistantMaxTokens => '最大令牌數';

  @override
  String get aiAssistantContextWindow => '上下文窗口';

  @override
  String get aiAssistantServiceStatus => '服務狀態';

  @override
  String get aiAssistantAvailable => '可用';

  @override
  String get aiAssistantUnavailable => '不可用';

  @override
  String get aiSummarize => 'AI 總結';

  @override
  String aiSummarizeUnread(int count) {
    return 'AI 總結 $count 條未讀消息';
  }

  @override
  String get aiSummarizeLoading => '正在總結...';

  @override
  String get aiSummarizeError => '總結失敗';

  @override
  String get aiRewrite => 'AI 改寫';

  @override
  String get aiRewriteFormal => '正式';

  @override
  String get aiRewriteCasual => '輕鬆';

  @override
  String get aiRewritePlayful => '俏皮';

  @override
  String get aiRewriteProfessional => '專業';

  @override
  String get aiRewriteAccept => '使用';

  @override
  String get aiRewriteCancel => '取消';

  @override
  String get aiRewriteLoading => '正在改寫...';

  @override
  String get aiLinkSummary => 'AI 摘要';

  @override
  String get aiLinkSummaryAnalyzing => '正在分析...';

  @override
  String get chatFolderManagement => '管理文件夾';

  @override
  String get chatFolderSystem => '系統文件夾';

  @override
  String get chatFolderCustom => '自定義文件夾';

  @override
  String get chatFolderEmpty => '暫無自定義文件夾';

  @override
  String get chatFolderCreate => '創建文件夾';

  @override
  String get chatFolderEdit => '編輯文件夾';

  @override
  String get chatFolderNameHint => '文件夾名稱';

  @override
  String get chatFolderAll => '全部';

  @override
  String get chatFolderUnread => '未讀';

  @override
  String get chatFolderPersonal => '私聊';

  @override
  String get chatFolderGroups => '羣組';

  @override
  String get chatFolderChannels => '頻道';

  @override
  String get chatFolderMuted => '已靜音';

  @override
  String get storyAddMusic => '添加音樂';

  @override
  String get storyChangeMusic => '更換音樂';

  @override
  String get storyBackgroundMusic => '背景音樂';

  @override
  String get storyMusicPreview => '預覽 (最長15秒)';

  @override
  String get storyChooseFromDevice => '從設備選擇';

  @override
  String get storyUseThisMusic => '使用此音樂';

  @override
  String get authPasskeyNotSupported => '此設備不支持 Passkey';

  @override
  String get authPasskeyRegister => '註冊 Passkey';

  @override
  String get authPasskeyNoRegistered => '未註冊 Passkey';

  @override
  String get authPasskeyRegisterHint => '爲當前賬號註冊 Passkey，獨立 Passkey 登錄入口後續開放。';

  @override
  String get authPasskeyNameYours => '爲 Passkey 命名';

  @override
  String get authPasskeyRegistered => 'Passkey 已保存到當前賬號';

  @override
  String get authPasskeyDeleted => 'Passkey 已從當前賬號移除';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return '刪除 Passkey \"$name\"？如需後續使用 Passkey 登錄，需要重新註冊。';
  }

  @override
  String get momentVisibilityPublic => '公開';

  @override
  String get momentVisibilityPrivate => '私密';

  @override
  String get momentVisibilityPartial => '部分可見';

  @override
  String get momentVisibilityExcluded => '不給誰看';

  @override
  String momentUserMoments(String userName) {
    return '$userName的朋友圈';
  }

  @override
  String get momentForwardTo => '轉發給';

  @override
  String get momentForwardSuccess => '轉發成功';

  @override
  String get momentSelectFriends => '選擇好友';

  @override
  String get momentSelectTags => '按標籤選擇';

  @override
  String momentSelectedCount(int count) {
    return '已選擇 ($count)';
  }

  @override
  String get momentNoMomentsYet => '暫無動態';

  @override
  String get momentForwardMoment => '轉發動態';

  @override
  String get momentAddComment => '寫評論...';

  @override
  String momentForwardContent(String content) {
    return '[朋友圈] $content';
  }

  @override
  String get momentDeleteMoment => '刪除動態';

  @override
  String get momentDeleteConfirm => '確定要刪除這條動態嗎？';

  @override
  String get momentComment => '評論';

  @override
  String get momentWriteComment => '寫評論...';

  @override
  String get momentLike => '贊';

  @override
  String get momentUnlike => '取消';

  @override
  String get momentForward => '轉發';

  @override
  String get momentDelete => '刪除';

  @override
  String get momentReply => '回覆';

  @override
  String get momentMoment => '動態';

  @override
  String momentLikesCount(int count) {
    return '$count 個贊';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count 條評論';
  }

  @override
  String get momentNoComments => '暫無評論';

  @override
  String get momentFailedToLoad => '圖片加載失敗';

  @override
  String momentReplyTo(String userName) {
    return '回覆 $userName...';
  }

  @override
  String get momentNoConversations => '暫無會話';

  @override
  String get momentJustNow => '剛剛';

  @override
  String momentMinutesAgo(int count) {
    return '$count分鐘前';
  }

  @override
  String momentHoursAgo(int count) {
    return '$count小時前';
  }

  @override
  String momentDaysAgo(int count) {
    return '$count天前';
  }

  @override
  String get chatGroupAnnouncementHint => '輸入羣公告';

  @override
  String get chatGroupAnnouncementEmpty => '暫無羣公告';

  @override
  String get chatEditNickname => '編輯羣暱稱';

  @override
  String get chatNicknameHint => '輸入你在羣裏的暱稱';

  @override
  String get contactAddPhoneHint => '輸入電話號碼';

  @override
  String get contactNotesHint => '添加聯繫人備忘';

  @override
  String get reportTitle => '投訴';

  @override
  String get reportReasonSpam => '垃圾信息';

  @override
  String get reportReasonHarassment => '騷擾';

  @override
  String get reportReasonFraud => '欺詐';

  @override
  String get reportReasonOther => '其他';

  @override
  String get reportSubmitted => '投訴已提交';

  @override
  String get reportDescription => '補充說明（選填）';

  @override
  String get qrcodeSaved => '二維碼已保存到相冊';

  @override
  String get chatSendRedPacketInChat => '請在聊天中發送紅包';

  @override
  String get commonSaveFailed => '保存失敗';

  @override
  String get reportSelectReason => '請選擇投訴原因';

  @override
  String get gameCenter => '遊戲中心';

  @override
  String get gameHighScore => '最高分';

  @override
  String get gameScore => '分數';

  @override
  String get gameOver => '遊戲結束';

  @override
  String get gamePlayAgain => '再來一局';

  @override
  String get gameLeaderboard => '排行榜';

  @override
  String get gamePause => '暫停';

  @override
  String get gameResume => '點擊繼續';

  @override
  String get gameConfirmExit => '確定退出遊戲？';

  @override
  String get gameNoScores => '暫無記錄';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => '合併數字到 2048';

  @override
  String get gameBlockDrop => '方塊消除';

  @override
  String get gameBlockDropDesc => '消除方塊行';

  @override
  String get gameMinesweeper => '掃雷';

  @override
  String get gameMinesweeperDesc => '找出所有安全格';

  @override
  String get gameMatch3 => '消消樂';

  @override
  String get gameMatch3Desc => '連接3個以上寶石';

  @override
  String get gameMinesweeperEasy => '初級';

  @override
  String get gameMinesweeperMedium => '中級';

  @override
  String get gameMinesLeft => '剩餘雷數';

  @override
  String get gameTimeLeft => '時間';

  @override
  String get gameLevel => '等級';

  @override
  String get gameNext => '下一個';

  @override
  String get gameBestTime => '最佳用時';

  @override
  String get gameNewRecord => '新紀錄！';

  @override
  String get gameLines => '行數';

  @override
  String get storyMyStory => '我的動態';

  @override
  String get storageSmartCleanup => '智能清理';

  @override
  String get storageOldMediaFiles => '舊媒體文件';

  @override
  String get storageLargeFiles => '大文件';

  @override
  String get storageAppCache => '應用緩存';

  @override
  String get storageSettings => '存儲設置';

  @override
  String get storageAutoCleanup => '自動清理';

  @override
  String storageAutoCleanupDesc(int days) {
    return '自動清理 $days 天以上未訪問的文件';
  }

  @override
  String get storageCleanupPeriod => '清理週期';

  @override
  String get storagePreserveThumbnails => '保留縮略圖';

  @override
  String get storagePreserveThumbnailsDesc => '清理時保留圖片縮略圖';

  @override
  String get storageWarningHigh => '存儲空間較高，建議清理舊文件。';

  @override
  String get storageWarningCritical => '存儲空間嚴重不足，請立即清理。';

  @override
  String storageFreed(String size, int count) {
    return '已釋放 $size（$count 個文件）';
  }

  @override
  String storageDays(int days) {
    return '$days 天';
  }

  @override
  String storageViewAllRooms(int count) {
    return '查看全部 $count 個房間';
  }

  @override
  String get storageNoFiles => '暫無文件';

  @override
  String get storageFilePinned => '已保留';

  @override
  String storageDeleteSelected(int count) {
    return '刪除 $count 個選中文件？文件可從服務器重新下載。';
  }

  @override
  String get backupRestore => '備份與恢復';

  @override
  String get backupCreate => '創建備份';

  @override
  String get backupCreateDesc => '備份設置和加密密鑰。消息將在重新登錄後從服務器恢復。';

  @override
  String get backupIncludeKeys => '包含加密密鑰';

  @override
  String get backupIncludeKeysDesc => '讀取加密消息所必需';

  @override
  String get backupPasswordProtect => '密碼保護';

  @override
  String get backupEnterPassword => '輸入備份密碼';

  @override
  String get backupHistory => '備份歷史';

  @override
  String get backupNoBackups => '暫無備份';

  @override
  String get backupRestore2 => '恢復';

  @override
  String get backupDelete => '刪除';

  @override
  String get backupDeleteConfirm => '確定刪除此備份？此操作不可撤銷。';

  @override
  String get backupRestoreFromFile => '從文件恢復';

  @override
  String get backupRestoreFromFileDesc => '導入來自其他設備或之前備份的 .n42backup 文件。';

  @override
  String get backupChooseFile => '選擇備份文件';

  @override
  String get backupRestoring => '恢復中...';

  @override
  String backupCreated(int rooms, int messages) {
    return '備份已創建：$rooms 個房間，$messages 條消息';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return '已恢復 $settings 項設置（來自 $rooms 個房間）';
  }

  @override
  String backupFailed(String error) {
    return '備份失敗：$error';
  }

  @override
  String get backupPasswordRequired => '此備份需要密碼';

  @override
  String get blocGroupNotFound => '羣組未找到';

  @override
  String blocGroupMembersInvited(int count) {
    return '已邀請$count位成員';
  }

  @override
  String get blocGroupMemberRemoved => '成員已移除';

  @override
  String get blocGroupAdminRemoved => '已取消管理員';

  @override
  String get blocGroupLeft => '已退出羣聊';

  @override
  String get blocGroupDisbanded => '羣聊已解散';

  @override
  String get blocGroupJoined => '已加入羣聊';

  @override
  String get blocGroupInviteDeclined => '已拒絕邀請';

  @override
  String get blocGroupTokenGateUpdated => 'Token 門檻已更新';

  @override
  String get blocTransferProcessing => '轉賬處理中...';

  @override
  String get blocTransferCancelled => '轉賬已取消';

  @override
  String get blocTransferFailed => '轉賬失敗';

  @override
  String get blocPaymentProcessing => '支付處理中...';

  @override
  String get blocPaymentFailed => '支付失敗';

  @override
  String get groupMaxMembers => '羣人數上限';

  @override
  String get groupMaxMembersUnlimited => '不限';

  @override
  String get groupMaxMembersHint => '輸入上限（留空表示不限）';

  @override
  String get groupMaxMembersUpdated => '羣人數上限已更新';

  @override
  String get groupFull => '羣已滿員';

  @override
  String get groupChannels => '話題頻道';

  @override
  String get groupChannelsEmpty => '暫無話題頻道';

  @override
  String get groupChannelsCount => '個頻道';

  @override
  String get groupChannelCreate => '新建頻道';

  @override
  String get groupChannelName => '頻道名稱';

  @override
  String get groupChannelTopic => '頻道話題（可選）';

  @override
  String get groupChannelDelete => '刪除頻道';

  @override
  String get groupChannelDeleteConfirm => '確認刪除此頻道？消息不可恢復。';

  @override
  String get groupBotSettings => 'Bot 設置';

  @override
  String get groupBotEnabled => '啓用 Bot';

  @override
  String get groupBotWelcomeMessage => '歡迎語模板';

  @override
  String get groupBotWelcomeHint => '用 \'name\' 作爲新成員名字佔位符';

  @override
  String get groupBotConfigUpdated => 'Bot 設置已更新';

  @override
  String get groupContentFilter => '關鍵詞過濾';

  @override
  String get groupContentFilterEnabled => '啓用關鍵詞過濾';

  @override
  String get groupContentFilterReplace => '替換爲 ***';

  @override
  String get groupContentFilterHide => '隱藏消息';

  @override
  String get groupContentFilterAddWord => '添加關鍵詞';

  @override
  String get groupContentFilterUpdated => '內容過濾設置已更新';

  @override
  String get chatSlashCommands => '指令';

  @override
  String get chatCommandPoll => '/poll — 創建投票';

  @override
  String get chatCommandAnnounce => '/announce — 發佈公告';

  @override
  String get chatCommandWelcome => '/welcome — 設置歡迎語';

  @override
  String get chatReportMessage => '舉報';

  @override
  String get chatReportReason => '舉報原因';

  @override
  String get chatReportSpam => '垃圾信息';

  @override
  String get chatReportHarassment => '騷擾';

  @override
  String get chatReportInappropriate => '違規內容';

  @override
  String get chatReportOther => '其他';

  @override
  String get chatReportSuccess => '舉報已提交';

  @override
  String get spacesName => '社區名稱';

  @override
  String get spacesNameHint => '例如：加密交易者';

  @override
  String get spacesNameRequired => '請輸入社區名稱';

  @override
  String get spacesDescription => '簡介';

  @override
  String get spacesDescriptionHint => '介紹一下這個社區';

  @override
  String get spacesType => '社區類型';

  @override
  String get spacesPublicDesc => '任何人均可發現並加入';

  @override
  String get spacesPrivateDesc => '僅受邀成員可加入';

  @override
  String get spacesNotFound => '社區不存在';

  @override
  String get spacesSearch => '搜索社區...';

  @override
  String get spacesMembers => '成員';

  @override
  String get spacesNoChannels => '暫無頻道';

  @override
  String get spacesLeave => '退出社區';

  @override
  String spacesLeaveConfirm(String name) {
    return '確定要退出「$name」嗎？';
  }

  @override
  String get spacesDelete => '解散社區';

  @override
  String spacesDeleteConfirm(String name) {
    return '此操作將永久刪除「$name」及其所有頻道，且不可撤銷。';
  }

  @override
  String get spacesCreateChannel => '創建頻道';

  @override
  String get spacesChannelName => '頻道名稱';

  @override
  String get spacesChannelTopic => '話題（可選）';

  @override
  String get spacesDeleteChannel => '刪除頻道';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return '確定要刪除頻道「#$name」嗎？';
  }

  @override
  String get spacesEditName => '修改名稱';

  @override
  String get spacesEditDescription => '修改簡介';

  @override
  String spacesViewAllMembers(int count) {
    return '查看全部 $count 位成員';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return '踢出 $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return '封禁 $name';
  }

  @override
  String get spacesPromoteAdmin => '設爲管理員';

  @override
  String get spacesDemoteAdmin => '撤銷管理員';

  @override
  String get spacesInviteMember => '邀請成員';

  @override
  String get spacesInviteMemberUserId => '用戶 ID（如 @user:server.com）';

  @override
  String get spacesSave => '保存';

  @override
  String get settingsScreenshotProtection => '截圖防護';

  @override
  String get settingsScreenshotProtectionDesc => '防止截圖和屏幕錄製';

  @override
  String get chatSelfDestructTimer => '閱後即焚';

  @override
  String get chatTimerPickerTitle => '設置閱後即焚時間';

  @override
  String get chatTimerOff => '關閉';

  @override
  String get onChainNotificationsTitle => '鏈上事件';

  @override
  String get onChainMarkAllRead => '全部已讀';

  @override
  String get onChainNoNotifications => '暫無鏈上事件';

  @override
  String get onChainNoNotificationsDesc => '來自訂閱頻道的事件通知將在此顯示';

  @override
  String get onChainViewDetails => '查看詳情';

  @override
  String get chatCommandHelp => '/help — 查看所有命令';

  @override
  String get chatCommandPrice => '/price — 查詢代幣價格';

  @override
  String get chatCommandBalance => '/balance — 查看錢包餘額';

  @override
  String get chatCommandChains => '/chains — 查看 236+ 條支持鏈';

  @override
  String get chatMiniApps => '應用';

  @override
  String get miniAppMarketTitle => '小程序';

  @override
  String get miniAppCategoryAll => '全部';

  @override
  String get miniAppSearch => '搜索應用...';

  @override
  String get miniAppFeatured => '精選';

  @override
  String get miniAppAllApps => '全部應用';

  @override
  String get miniAppNoResults => '未找到應用';

  @override
  String get slideToPayLabel => '→→→  滑動確認';

  @override
  String get slideToPayConfirming => '確認中...';

  @override
  String get redPacketBestLuck => '最佳手氣';

  @override
  String get redPacketBestLuckCongrats => '最佳手氣！你搶到了最多！';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total 個已領取';
  }

  @override
  String get redPacketStatsTotal => '共計';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 搶到了紅包 • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id  •  0x 錢包地址  •  name.eth';

  @override
  String get web3SearchPlaceholder => '搜索 ID、錢包地址或 ENS...';

  @override
  String get web3WalletAddress => '錢包地址';

  @override
  String get web3AddressCopied => '地址已複製';

  @override
  String get web3Copy => '複製';

  @override
  String get web3SendMessage => '發消息';

  @override
  String get web3SendToWallet => '發送到錢包';

  @override
  String get web3WalletOnlyHint => '該地址尚無 N42 賬號。對方加入後消息將自動送達。';

  @override
  String get web3NftAvatar => 'NFT 頭像';

  @override
  String get web3ResolveFailed => '身份解析失敗';

  @override
  String web3EnsNotFound(String name) {
    return 'ENS 名稱“$name”未找到';
  }

  @override
  String get web3NoN42AccountTitle => '無 N42 賬號';

  @override
  String get web3NoN42AccountDesc => '該錢包地址尚無 N42 賬號。您可以分享 N42 邀請鏈接邀請對方加入。';

  @override
  String get web3ShareInvite => '分享邀請';

  @override
  String get nftPickerTitle => '選擇 NFT 頭像';

  @override
  String get nftPickerTabPopular => '熱門';

  @override
  String get nftPickerTabCustom => '自定義';

  @override
  String get nftPickerChain => '鏈';

  @override
  String get nftPickerContract => '合約地址';

  @override
  String get nftPickerTokenId => 'Token ID';

  @override
  String get nftPickerVerifyOwnership => '驗證所有權並預覽';

  @override
  String get nftPickerUseAsAvatar => '用作頭像';

  @override
  String get nftPickerPreview => '預覽';

  @override
  String get nftPickerNotOwned => '您不擁有這個 NFT';

  @override
  String get nftPickerInvalidTokenId => '無效的 Token ID';

  @override
  String get nftPickerEnterBoth => '請輸入合約地址和 Token ID';

  @override
  String get nftPickerInfoTitle => 'NFT 頭像 — 鏈上身份驗證';

  @override
  String get nftPickerInfoDesc =>
      '綁定您持有的 NFT 作爲頭像。任何人均可在鏈上驗證歸屬權。在 N42 全應用中以金色邊框標識。';

  @override
  String get nftPickerPopularCollections => '熱門 NFT 項目';

  @override
  String get nftPickerWalletHint => '連接 N42 錢包，自動發現您在 236+ 條鏈上持有的 NFT。';

  @override
  String get profileBindNftAvatar => '綁定 NFT 頭像';

  @override
  String get profileChangeAvatar => '更換頭像';

  @override
  String get groupTopics => '羣話題';

  @override
  String get groupTopicsEmpty => '暫無話題';

  @override
  String get syncInProgress => '正在同步歷史消息...';

  @override
  String get recoveryKeyReminderTitle => '保護您的消息';

  @override
  String get recoveryKeyReminderDesc => '創建恢復密鑰以在多設備上安全同步加密消息';

  @override
  String get recoveryKeySetupNow => '立即設置';

  @override
  String get recoveryKeyRemindLater => '稍後提醒';

  @override
  String get channelReadOnly => '僅管理員可在此頻道發言';

  @override
  String get channelSubscribers => '訂閱者';

  @override
  String get channelVerified => '已認證頻道';

  @override
  String get redPacketHistory => '紅包記錄';

  @override
  String get redPacketSent => '已發出';

  @override
  String get redPacketReceived => '已收到';

  @override
  String get redPacketExpired => '已過期';

  @override
  String get redPacketClaimed => '已領取';

  @override
  String get redPacketInsufficientBalance => '餘額不足';

  @override
  String selfDestructCountdown(String time) {
    return '$time 後銷燬';
  }

  @override
  String get messageDestroyed => '消息已銷燬';

  @override
  String miniAppPermissionDenied(String permission) {
    return '權限不足：$permission';
  }

  @override
  String get aiSuggestionGasFee => '什麼是 Gas 費？';

  @override
  String get aiSuggestionDefi => 'DeFi 入門';

  @override
  String get aiSuggestionSecurity => '如何檢查合約安全';

  @override
  String get aiSuggestionBridge => '跨鏈橋接';

  @override
  String get channelDiscoverTitle => '發現頻道';

  @override
  String get channelDiscoverSearch => '搜索頻道...';

  @override
  String get channelJoin => '加入';

  @override
  String get channelJoined => '已加入';

  @override
  String get channelCategory => '分類';

  @override
  String slowModeCooldown(int seconds) {
    return '慢速模式：請等待 $seconds 秒';
  }

  @override
  String get addressCopyAction => '複製地址';

  @override
  String get addressSendMessage => '發消息';

  @override
  String get addressViewProfile => '查看資料';

  @override
  String get sendToAddress => '通過錢包地址發消息';

  @override
  String get blocAuthSendVerificationCodeFailed => '發送驗證碼失敗';

  @override
  String get blocAuthServerNoEmailPasswordReset => '該服務器不支持通過郵箱重置密碼';

  @override
  String get blocAuthResetPasswordFailed => '重置密碼失敗';

  @override
  String get blocAuthChangePasswordFailed => '修改密碼失敗';

  @override
  String get blocAuthOldPasswordWrong => '原密碼錯誤';

  @override
  String get blocAuthLoginCancelled => '登錄已取消';

  @override
  String get blocAuthGoogleLoginFailed => 'Google 登錄失敗';

  @override
  String get blocAuthAppleLoginFailed => 'Apple 登錄失敗';

  @override
  String get blocAuthSsoLoginFailed => 'SSO 登錄失敗';

  @override
  String get blocAuthFacebookLoginFailed => 'Facebook 登錄失敗';

  @override
  String get blocAuthTwitterLoginFailed => 'Twitter 登錄失敗';

  @override
  String get blocAuthWeChatLoginFailed => '微信登錄失敗';

  @override
  String get blocAuthWeChatNotConfigured => '微信登錄未配置';

  @override
  String get blocAuthWeChatNotInstalled => '請先安裝微信';

  @override
  String get blocAuthPasswordWrong => '密碼錯誤';

  @override
  String get blocAuthEmailAlreadyBound => '該郵箱已被其他賬號綁定';

  @override
  String get blocAuthChangeEmailFailed => '修改郵箱失敗';

  @override
  String get blocAuthVerificationCodeInvalid => '驗證碼錯誤或已過期';

  @override
  String get blocAuthSessionExpired => '會話已失效，請重新登錄';

  @override
  String get blocAuthSessionIncomplete => '會話數據不完整，請重新登錄';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class SZhTw extends SZh {
  SZhTw() : super('zh_TW');

  @override
  String get commonRetry => '重試';

  @override
  String get commonUnknownUser => '未知用戶';

  @override
  String get transferWalletNotConnected => '錢包未連接';

  @override
  String get chatCallServiceNotInitialized => '通話服務未初始化';

  @override
  String authLoginFailed(String error) {
    return '登錄失敗: $error';
  }

  @override
  String get chatCallBack => '回撥';

  @override
  String get chatMissedVideoCall => '未接視頻通話';

  @override
  String get chatMissedVoiceCall => '未接語音通話';

  @override
  String get chatCallNotAnswered => '對方未接聽';

  @override
  String get chatCallDurationLabel => '通話時長';

  @override
  String get chatVoiceCallCancelled => '語音通話已取消';

  @override
  String get chatVideoCallCancelled => '視頻通話已取消';

  @override
  String get commonImage => '[圖片]';

  @override
  String get chatVideo => '[視頻]';

  @override
  String get chatVoice => '[語音]';

  @override
  String get commonFile => '[文件]';

  @override
  String get chatLocation => '[位置]';

  @override
  String get chatUnknownMessage => '[未知消息]';

  @override
  String get commonDelete => '刪除';

  @override
  String get chatDeleteThisMessage => '刪除這條消息？';

  @override
  String get chatMessageDeleted => '消息已刪除';

  @override
  String get profileNotLoggedIn => '未登錄';

  @override
  String get chatMyLocation => '我的位置';

  @override
  String get commonGroupChat => '羣聊';

  @override
  String get commonSearch => '搜索';

  @override
  String get commonCancel => '取消';

  @override
  String get commonLoadFailed => '加載失敗';

  @override
  String get commonMessages => '消息';

  @override
  String get commonContacts => '聯繫人';

  @override
  String get commonMe => '我';

  @override
  String get commonVoiceLoading => '語音加載中，請稍後再試';

  @override
  String get commonVoiceToTextFailed => '語音轉文字失敗';

  @override
  String get commonConvertToText => '轉文字';

  @override
  String get chatCopy => '複製';

  @override
  String get commonForward => '轉發';

  @override
  String get commonUnfavorite => '取消收藏';

  @override
  String get commonFavorite => '收藏';

  @override
  String get settingsResend => '重新發送';

  @override
  String get chatRecall => '撤回';

  @override
  String get commonQuote => '引用';

  @override
  String get commonRemind => '提醒';

  @override
  String get chatCopied => '已複製';

  @override
  String get storySendMessageHint => '發送消息';

  @override
  String get commonMicrophonePermissionRequired => '請允許使用麥克風權限';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      '麥克風權限已被拒絕，請在系統設置中開啓以使用語音消息功能。';

  @override
  String commonStartRecordingFailed(String error) {
    return '開始錄音失敗: $error';
  }

  @override
  String get commonRecordingTooShort => '錄音時間太短';

  @override
  String commonStopRecordingFailed(String error) {
    return '停止錄音失敗: $error';
  }

  @override
  String get chatReleaseToCancel => '鬆開取消';

  @override
  String get chatReleaseToSend => '鬆開發送，上滑取消';

  @override
  String get commonHoldToTalk => '按住 說話';

  @override
  String get commonSend => '發送';

  @override
  String get commonAddFriend => '添加好友';

  @override
  String get commonChatServiceNotConnected => '聊天服務未連接';

  @override
  String contactUserNotFoundHint(String query) {
    return '未找到用戶 \"$query\"\n\n提示：\n• 嘗試輸入完整用戶ID，如 @username:server.com\n• 確認用戶名拼寫正確';
  }

  @override
  String contactCreateChatFailed(String error) {
    return '創建會話失敗: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return '搜索失敗: $error';
  }

  @override
  String get contactEnterUserIdOrUsername => '輸入用戶 ID 或用戶名搜索';

  @override
  String get contactSearching => '搜索中...';

  @override
  String get contactSearchUserToChat => '搜索用戶開始聊天';

  @override
  String get contactMatrixIdExample =>
      '可以輸入完整的 Matrix ID\n例如: @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return '未找到用戶 \"$username\"';
  }

  @override
  String get commonChat => '聊天';

  @override
  String get commonSettings => '設置';

  @override
  String get profileEditProfile => '編輯資料';

  @override
  String get authLogin => '登錄';

  @override
  String get commonCreateGroup => '創建羣聊';

  @override
  String get chatError => '錯誤';

  @override
  String get commonTransfer => '轉賬';

  @override
  String get commonReceived => '已被接收';

  @override
  String get commonRefunded => '已退還';

  @override
  String get commonExpired => '已過期';

  @override
  String get chatRedPacketGreeting => '恭喜發財，大吉大利';

  @override
  String get commonN42RedPacket => 'N42紅包';

  @override
  String get commonClaimed => '已領取';

  @override
  String get commonAllClaimed => '已被領完';

  @override
  String get chatReadAloud => '朗讀';

  @override
  String get chatReply => '回覆';

  @override
  String get commonEdit => '編輯';

  @override
  String get chatSelectForwardTarget => '選擇轉發對象';

  @override
  String commonSendCount(int count) {
    return '發送($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42號：$id';
  }

  @override
  String get profileN42IdTitle => 'N42號';

  @override
  String get profileN42Bean => 'N42豆';

  @override
  String get contactFriendInfo => '朋友資料';

  @override
  String get contactFriendInfoDesc => '添加朋友的備註名、電話、標籤、備忘、照片等，並設置朋友權限。';

  @override
  String get commonMoments => '朋友圈';

  @override
  String get commonSendMessage => '發消息';

  @override
  String get contactAudioVideoCall => '音視頻通話';

  @override
  String get contactVideoChannel => '視頻號';

  @override
  String get contactRemark => '備註';

  @override
  String get contactRemarkName => '備註名';

  @override
  String get contactPhone => '電話';

  @override
  String get contactTags => '標籤';

  @override
  String get contactNotes => '備忘';

  @override
  String get contactPhotos => '照片';

  @override
  String get contactPermissions => '權限';

  @override
  String get contactChatMomentsEtc => '聊天、朋友圈、運動等';

  @override
  String get contactMoreInfo => '更多信息';

  @override
  String get contactCommonGroups => '我和他 (她) 的共同羣聊';

  @override
  String get contactSource => '來源';

  @override
  String get settingsNotificationSettings => '消息通知';

  @override
  String get settingsPrivacy => '隱私';

  @override
  String get settingsAppearance => '外觀';

  @override
  String get settingsAbout => '關於';

  @override
  String get commonLogout => '退出登錄';

  @override
  String get commonLogoutConfirm => '確定要退出登錄嗎？';

  @override
  String get commonSave => '保存';

  @override
  String get profileNickname => '暱稱';

  @override
  String get profileEnterNickname => '請輸入暱稱';

  @override
  String get profileSignature => '簽名';

  @override
  String get profileAddSignature => '添加個性簽名';

  @override
  String get commonTakePhoto => '拍照';

  @override
  String get profileChooseFromGallery => '從相冊選擇';

  @override
  String profileSaveFailed(String error) {
    return '保存失敗: $error';
  }

  @override
  String get authSecureDecentralizedChat => '安全、去中心化的即時通訊';

  @override
  String get commonEndToEndEncryption => '端到端加密';

  @override
  String get authMessagesOnlyYouCanSee => '消息僅你和對方可見';

  @override
  String get authDecentralized => '去中心化';

  @override
  String get authBasedOnMatrix => '基於Matrix開放協議';

  @override
  String get authWalletIntegration => '錢包集成';

  @override
  String get authEasyCryptoTransfer => '輕鬆進行加密貨幣轉賬';

  @override
  String get authRegister => '註冊';

  @override
  String get authAgreeTerms => '登錄即表示同意';

  @override
  String get authTermsOfService => '《服務協議》';

  @override
  String get authAnd => '和';

  @override
  String get authPrivacyPolicy => '《隱私政策》';

  @override
  String get authServerAddress => '服務器地址';

  @override
  String get authEnterServerAddress => '請輸入服務器地址';

  @override
  String authConnectedTo(String serverName) {
    return '已連接到 $serverName';
  }

  @override
  String get authUsername => '用戶名';

  @override
  String get authEnterUsername => '請輸入用戶名';

  @override
  String get authUsernameOrEmail => '用戶名或郵箱';

  @override
  String get authEnterUsernameOrEmail => '請輸入用戶名或郵箱';

  @override
  String get authPassword => '密碼';

  @override
  String get authEnterPassword => '請輸入密碼';

  @override
  String get authRegisterAccount => '註冊賬號';

  @override
  String get authForgotPassword => '忘記密碼';

  @override
  String get authOtherLoginMethods => '其他登錄方式';

  @override
  String get authCreateAccount => '創建賬號';

  @override
  String get authJoinN42Chat => '加入 N42 Chat 開始聊天';

  @override
  String get authUsernameHint => '3-20字符，字母/數字/_';

  @override
  String get authUsernameMinLength => '用戶名至少3個字符';

  @override
  String get authUsernameMaxLength => '用戶名最多20個字符';

  @override
  String get authUsernameFormat => '用戶名只能包含字母、數字和下劃線';

  @override
  String get authPasswordHint => '至少8位';

  @override
  String get commonPasswordMinLength => '密碼至少8位';

  @override
  String get authConfirmPassword => '確認密碼';

  @override
  String get authFilled => '已填寫';

  @override
  String get authEnterInviteCode => '請輸入邀請碼';

  @override
  String get authAlreadyHaveAccount => '已有賬號？';

  @override
  String get authLoginNow => '立即登錄';

  @override
  String get profileAvatar => '頭像';

  @override
  String get profileStatus => '狀態';

  @override
  String get commonLoading => '加載中...';

  @override
  String get conversationNoConversations => '暫無會話';

  @override
  String get conversationTapToChat => '點擊右上角開始聊天';

  @override
  String get conversationStartGroup => '發起羣聊';

  @override
  String get commonScan => '掃一掃';

  @override
  String get commonPayment => '收付款';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature 功能即將推出';
  }

  @override
  String get conversationMarkAsRead => '標記已讀';

  @override
  String get commonUnmute => '取消靜音';

  @override
  String get commonMute => '消息免打擾';

  @override
  String get conversationUnpin => '取消置頂';

  @override
  String get conversationPin => '置頂';

  @override
  String get conversationDeleteConversation => '刪除會話';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return '確定要刪除與 $name 的會話嗎？';
  }

  @override
  String get commonNoContacts => '暫無聯繫人';

  @override
  String get contactAddFriendsToChat => '添加好友開始聊天';

  @override
  String get contactNotFound => '未找到聯繫人';

  @override
  String get contactTryOtherKeywords => '嘗試搜索其他關鍵詞或全局搜索';

  @override
  String get contactSearchResults => '搜索結果';

  @override
  String get contactNewFriends => '新的朋友';

  @override
  String get contactChatOnlyFriends => '僅聊天的朋友';

  @override
  String get contactOfficialAccounts => '公衆號';

  @override
  String get contactServiceAccounts => '服務號';

  @override
  String get contactEnterpriseContacts => '企業聯繫人';

  @override
  String get contactRecommendToFriend => '推薦給朋友';

  @override
  String get commonSetRemark => '設置備註';

  @override
  String get contactSendingCard => '正在發送名片...';

  @override
  String get commonFileLabel => '文件';

  @override
  String get commonLocationLabel => '位置';

  @override
  String contactRecommendFailed(String error) {
    return '推薦失敗: $error';
  }

  @override
  String get profileEnterRemark => '請輸入備註名';

  @override
  String get contactOpeningChat => '正在打開聊天...';

  @override
  String contactOpenChatFailed(String error) {
    return '打開聊天失敗: $error';
  }

  @override
  String get contactAddContact => '添加聯繫人';

  @override
  String get contactEnterUserId => '輸入用戶ID';

  @override
  String get contactNoFriendRequests => '暫無好友請求';

  @override
  String get commonAccept => '接受';

  @override
  String get commonReject => '拒絕';

  @override
  String get commonNoGroups => '暫無羣聊';

  @override
  String get contactSelectFriendToRecommend => '選擇要推薦給的朋友';

  @override
  String get commonSearchContacts => '搜索聯繫人';

  @override
  String get contactNoContactsFound => '沒有找到聯繫人';

  @override
  String get favoriteYesterday => '昨天';

  @override
  String get chatJustNow => '剛剛';

  @override
  String get profileOnline => '在線';

  @override
  String get profileOffline => '離線';

  @override
  String get searchContactsGroupsMessages => '搜索聯繫人、羣聊和消息';

  @override
  String get searchError => '搜索出錯';

  @override
  String get chatSearchHint => '搜索';

  @override
  String get searchHistory => '搜索歷史';

  @override
  String get commonClear => '清除';

  @override
  String get commonAll => '全部';

  @override
  String get searchGroups => '羣聊';

  @override
  String get searchNoResults => '無結果';

  @override
  String commonGroupMembers(int count) {
    return '羣成員 ($count)';
  }

  @override
  String get groupMembersTitle => '羣成員';

  @override
  String get groupViewAll => '查看全部';

  @override
  String get groupOwner => '羣主';

  @override
  String get groupAdmin => '管理';

  @override
  String get groupInvite => '邀請';

  @override
  String get commonGroupAnnouncement => '羣公告';

  @override
  String get commonNotSet => '未設置';

  @override
  String get groupDescription => '羣簡介';

  @override
  String get groupPublicGroup => '公開羣聊';

  @override
  String get commonClearChatHistory => '清空聊天記錄';

  @override
  String get commonDissolveGroup => '解散羣聊';

  @override
  String get commonLeaveGroup => '退出羣聊';

  @override
  String get groupChangeGroupName => '修改羣名稱';

  @override
  String get commonEnterGroupName => '請輸入羣名稱';

  @override
  String get commonConfirm => '確認';

  @override
  String get groupEnterGroupDescription => '請輸入羣簡介';

  @override
  String get groupPublish => '發佈';

  @override
  String get chatClearHistoryConfirm => '確定要清空聊天記錄嗎？此操作不可恢復。';

  @override
  String get chatClearAction => '清空';

  @override
  String get commonChatHistoryCleared => '聊天記錄已清空';

  @override
  String get commonDissolve => '解散';

  @override
  String get groupQrCode => '羣二維碼';

  @override
  String get commonSearchChatHistory => '查找聊天記錄';

  @override
  String get groupIdCopied => '羣ID已複製';

  @override
  String get transferEnterOrPasteAddress => '輸入或粘貼錢包地址';

  @override
  String get transferSelectToken => '選擇代幣';

  @override
  String get commonTransferAmount => '轉賬金額';

  @override
  String get transferAvailable => '可用';

  @override
  String get transferMemoOptional => '備註（可選）';

  @override
  String get transferConfirmTransfer => '確認轉賬';

  @override
  String get transferAddressVerified => '地址已驗證';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return '可用餘額: $balance $symbol';
  }

  @override
  String get commonEnterAmount => '請輸入金額';

  @override
  String get commonRedPacketCountMin => '紅包個數至少爲1';

  @override
  String get commonViewRedPacketDetails => '查看紅包詳情';

  @override
  String get commonEnterTransferAmount => '請輸入轉賬金額';

  @override
  String get commonTransferTo => '轉賬給';

  @override
  String commonFromSender(String name, Object senderName) {
    return '來自 $name';
  }

  @override
  String get commonConfirmReceive => '確認收款';

  @override
  String get groupProfile => '羣資料';

  @override
  String get groupRemoveMember => '移出羣聊';

  @override
  String get commonRemove => '移出';

  @override
  String get profileClearStatus => '清除狀態';

  @override
  String get profileClearStatusConfirm => '確定要清除當前狀態嗎？';

  @override
  String get profileStatusCleared => '狀態已清除';

  @override
  String get profileUserNotExist => '用戶不存在';

  @override
  String get profileUserIdCopied => '用戶ID已複製';

  @override
  String get commonReport => '舉報';

  @override
  String get profileQrCode => '二維碼';

  @override
  String get profileAvatarUpdated => '頭像更新成功';

  @override
  String commonSelectImageFailed(String error) {
    return '選擇圖片失敗: $error';
  }

  @override
  String get profileChangeName => '修改名字';

  @override
  String get profileMale => '男';

  @override
  String get profileFemale => '女';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature功能開發中...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return '保存地址失敗: $error';
  }

  @override
  String get profileAddNew => '新增';

  @override
  String get profileAddAddress => '添加地址';

  @override
  String get profileAddressAdded => '地址添加成功';

  @override
  String get profileAddressUpdated => '地址更新成功';

  @override
  String get profileDeleteAddress => '刪除地址';

  @override
  String get profileAddressDeleted => '地址已刪除';

  @override
  String profileSaveInvoiceFailed(String error) {
    return '保存發票抬頭失敗: $error';
  }

  @override
  String get profileMyInvoices => '我的發票抬頭';

  @override
  String get profileAddInvoice => '添加發票抬頭';

  @override
  String get profileInvoiceAdded => '發票抬頭添加成功';

  @override
  String get profileInvoiceUpdated => '發票抬頭更新成功';

  @override
  String get profileDeleteInvoice => '刪除發票抬頭';

  @override
  String get profileInvoiceDeleted => '發票抬頭已刪除';

  @override
  String get profilePersonal => '個人';

  @override
  String get groupSelectAtLeastOne => '請至少選擇一位成員';

  @override
  String get chatFileNotExist => '文件不存在';

  @override
  String chatSendFailed(String error) {
    return '發送失敗: $error';
  }

  @override
  String get chatCannotOpenBrowser => '無法打開瀏覽器';

  @override
  String chatSelectFileFailed(String error) {
    return '選擇文件失敗: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return '設置失敗: $error';
  }

  @override
  String get transferEnterValidAmount => '請輸入有效的轉賬金額';

  @override
  String get commonAddressCopied => '地址已複製';

  @override
  String favoriteOpenItem(String content) {
    return '打開: $content';
  }

  @override
  String get favoriteDeleted => '已刪除';

  @override
  String get profileWallet => '錢包';

  @override
  String get chatRecording => '錄像';

  @override
  String get chatInvalidVideoUrl => '無效的視頻鏈接';

  @override
  String get chatDownloadFile => '下載文件';

  @override
  String get chatClearChatHistoryTitle => '清空聊天記錄';

  @override
  String get chatVideoCall => '視頻通話';

  @override
  String get commonVoiceCall => '語音通話';

  @override
  String get callLeaveMeeting => '離開會議';

  @override
  String get chatDetails => '聊天詳情';

  @override
  String get chatViewAllGroupMembers => '查看全部羣成員';

  @override
  String get chatGroupName => '羣聊名稱';

  @override
  String get chatGroupNameUpdated => '羣名稱已更新';

  @override
  String get chatUpdateFailed => '更新失敗';

  @override
  String get chatNoPermissionToModify => '您沒有修改權限';

  @override
  String get chatGroupManagement => '羣管理';

  @override
  String get chatMyNicknameInGroup => '我在本羣的暱稱';

  @override
  String get chatPinChat => '置頂聊天';

  @override
  String get chatStrongReminder => '強提醒';

  @override
  String get chatSetChatBackground => '設置當前聊天背景';

  @override
  String get chatUnknownFile => '未知文件';

  @override
  String get chatDownload => '下載';

  @override
  String get chatInvalidLocation => '無效的位置';

  @override
  String get chatTapToCancel => '點擊取消';

  @override
  String chatCaptureFailed(Object error) {
    return '拍攝失敗: $error';
  }

  @override
  String get chatProcessingVideo => '正在處理視頻...';

  @override
  String get chatVideoFileNotExist => '視頻文件不存在';

  @override
  String get chatVideoDataEmpty => '視頻數據爲空';

  @override
  String get chatVideoTooLarge => '視頻大小不能超過 100MB';

  @override
  String get chatSendingVideo => '視頻發送中...';

  @override
  String chatSendVideoFailed(Object error) {
    return '發送視頻失敗: $error';
  }

  @override
  String get chatImageFileNotExist => '圖片文件不存在';

  @override
  String get commonImageDataEmpty => '圖片數據爲空';

  @override
  String get chatSendingImage => '圖片發送中...';

  @override
  String chatSendImageFailed(Object error) {
    return '發送圖片失敗: $error';
  }

  @override
  String get chatSendLocation => '發送位置';

  @override
  String get chatSelectLocationAndSend => '選擇地點併發送給對方';

  @override
  String get chatShareRealTimeLocation => '共享實時位置';

  @override
  String get chatShareLocationForOneHour => '與好友共享1小時實時位置';

  @override
  String get chatLocationSent => '位置已發送';

  @override
  String get chatSelectMessages => '選擇消息';

  @override
  String chatSelectedCount(int count) {
    return '已選擇 $count';
  }

  @override
  String get chatSelectAll => '全選';

  @override
  String chatGroupChatCount(int count) {
    return '羣聊($count)';
  }

  @override
  String get chatPrivateChat => '私聊';

  @override
  String get chatNoMessages => '暫無消息';

  @override
  String get chatSendFirstMessage => '發送第一條消息開始聊天';

  @override
  String get chatEncryptionNotice => '此聊天已啓用端到端加密。只有您和對方可以閱讀消息。';

  @override
  String get chatMultiForward => '轉發';

  @override
  String get chatCollect => '收藏';

  @override
  String get chatNoMembers => '沒有成員';

  @override
  String get chatMemberNotFound => '未找到成員';

  @override
  String get chatVoiceFileNotExist => '語音文件不存在';

  @override
  String get chatVoiceFileEmpty => '語音文件爲空';

  @override
  String get chatSendingVoice => '語音發送中...';

  @override
  String chatSendVoiceFailed(Object error) {
    return '發送語音失敗: $error';
  }

  @override
  String get chatMessageForwarded => '消息已轉發';

  @override
  String chatForwardFailed(Object error) {
    return '轉發失敗: $error';
  }

  @override
  String get chatUnfavorited => '已取消收藏';

  @override
  String get chatFavorited => '已收藏';

  @override
  String get chatReactionAdded => '已添加表情回應';

  @override
  String get chatReactionRemoved => '已移除表情回應';

  @override
  String get chatFailedMessageDeleted => '已刪除失敗消息';

  @override
  String get chatDeleteMessages => '刪除消息';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return '確定要刪除 $count 條消息嗎？';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return '注意：$count 條消息來自他人，僅對你刪除。';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return '$count 條你發送的消息將對所有人撤回。';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return '已撤回 $count 條消息，$localCount 條僅對你刪除';
  }

  @override
  String chatRecalledMessages(Object count) {
    return '已撤回 $count 條消息';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count 條消息僅對你刪除';
  }

  @override
  String chatForwardedCount(Object count) {
    return '已轉發 $count 條消息';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return '轉發完成：成功 $success 條，失敗 $failed 條';
  }

  @override
  String get chatRemindOnlyInGroup => '提醒功能僅在羣聊中可用';

  @override
  String get chatOnlyTextSearchable => '僅支持搜索文本消息';

  @override
  String chatSearchFor(Object text) {
    return '搜索 \"$text\"';
  }

  @override
  String get chatBaiduSearch => '百度搜索';

  @override
  String get chatGoogleSearch => 'Google 搜索';

  @override
  String get chatBingSearch => '必應搜索';

  @override
  String get chatCalling => '呼叫中...';

  @override
  String get chatRinging => '響鈴中...';

  @override
  String get chatInCall => '通話中';

  @override
  String commonFeatureInDevelopment(String feature) {
    return '$feature功能開發中...';
  }

  @override
  String chatCollectMessages(Object count) {
    return '已收藏 $count 條消息';
  }

  @override
  String commonMemberCount(int count) {
    return '$count 人';
  }

  @override
  String groupDone(int count) {
    return '完成($count)';
  }

  @override
  String get profileServices => '服務';

  @override
  String get commonFavorites => '收藏';

  @override
  String get profileOrdersAndCards => '訂單與卡包';

  @override
  String get profileStickers => '表情';

  @override
  String profileStatusSetTo(String status) {
    return '狀態已設置爲：$status';
  }

  @override
  String get profileAvatarUploadFailed => '頭像上傳失敗';

  @override
  String get profilePersonalProfile => '個人信息';

  @override
  String get profileName => '名字';

  @override
  String get profileGender => '性別';

  @override
  String get profileRegion => '地區';

  @override
  String get commonMyQrCode => '我的二維碼';

  @override
  String get profilePoke => '拍一拍';

  @override
  String get profileRingtone => '來電鈴聲';

  @override
  String get profileDefaultRingtone => '默認鈴聲';

  @override
  String get profileMyAddresses => '我的地址';

  @override
  String profileGenderSetTo(String gender) {
    return '性別已設置爲：$gender';
  }

  @override
  String get profileSelectRegion => '選擇地區';

  @override
  String get profileSelectCity => '選擇城市';

  @override
  String profileRegionSetTo(String region) {
    return '地區已設置爲：$region';
  }

  @override
  String get profileSetPoke => '設置拍一拍';

  @override
  String get profileFriendPokedMe => '朋友拍了拍我';

  @override
  String get profileExample => '示例';

  @override
  String get profileOnTheShoulder => '的肩膀';

  @override
  String get profilePokeCleared => '拍一拍已清除';

  @override
  String profilePokeSetTo(String suffix) {
    return '拍一拍已設置爲：拍了拍我$suffix';
  }

  @override
  String get profileEditSignature => '編輯個性簽名';

  @override
  String get profileIntroduceYourself => '一句話介紹自己';

  @override
  String get profileSignatureCleared => '個性簽名已清除';

  @override
  String get profileSignatureUpdated => '個性簽名已更新';

  @override
  String get profileScanToAddFriend => '掃一掃上面的二維碼圖案，加我爲好友';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return '來電鈴聲已設置爲：$ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return '確定要解散羣聊「$name」嗎？此操作無法撤銷。';
  }

  @override
  String get authEnterValidServerAddress => '請輸入有效的服務器地址';

  @override
  String get authEnterServerAddressFirst => '請先輸入服務器地址';

  @override
  String get authPasskeyRequiresServer => 'Passkey登錄需要服務器支持';

  @override
  String get authLoginAgreement => '登錄即表示同意';

  @override
  String get authPleaseAgreeToTerms => '請先閱讀並同意服務協議和隱私政策';

  @override
  String get authRegisterFailed => '註冊失敗';

  @override
  String get commonReenterPassword => '請再次輸入密碼';

  @override
  String get commonPasswordsDoNotMatch => '兩次輸入的密碼不一致';

  @override
  String get authInviteCodeBuiltIn => '邀請碼（已內置）';

  @override
  String get authInviteCodeBuiltInNote => '邀請碼已內置，通常無需修改';

  @override
  String get authIHaveReadAndAgree => '我已閱讀並同意';

  @override
  String get mainStartGroupChat => '發起羣聊';

  @override
  String get mainAddFriends => '添加朋友';

  @override
  String get mainPaymentAndCollection => '收付款';

  @override
  String contactCount(int count) {
    return '$count位聯繫人';
  }

  @override
  String get contactAddToHomeScreen => '添加到桌面';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return '已將$contact的名片推薦給$recipient';
  }

  @override
  String get contactEnterRemarkName => '請輸入備註名';

  @override
  String contactRemarkSetTo(String remark) {
    return '備註已設置爲：$remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return '已接受$name的好友請求';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return '已拒絕$name的好友請求';
  }

  @override
  String get commonGroupInvites => '羣邀請';

  @override
  String commonMyGroups(int count) {
    return '我的羣聊 ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => '邀請加入羣聊';

  @override
  String commonConfirmLeaveGroup(String name) {
    return '確定要退出羣聊「$name」嗎？';
  }

  @override
  String get commonLeave => '離開';

  @override
  String get commonRecallThisMessage => '撤回該條消息？';

  @override
  String get commonSavedToGallery => '已保存到相冊';

  @override
  String get commonFailedToSave => '保存失敗';

  @override
  String get chatSaving => '保存中...';

  @override
  String get commonShare => '分享';

  @override
  String get chatSaveToGallery => '保存到相冊';

  @override
  String chatDownloadFailed(String code) {
    return '下載失敗: $code';
  }

  @override
  String commonShareFailed(String error) {
    return '分享失敗: $error';
  }

  @override
  String get chatFailedToLoadImage => '圖片加載失敗';

  @override
  String get chatVideoRecordingFailed => '視頻錄製失敗，請重試';

  @override
  String get profileRedPacket => '紅包';

  @override
  String get commonMusic => '音樂';

  @override
  String get commonCoupon => '卡券';

  @override
  String get commonGift => '禮物';

  @override
  String get commonPoll => '投票';

  @override
  String get favoriteText => '文本';

  @override
  String get favoriteLinkLabel => '鏈接';

  @override
  String get favoriteNote => '筆記';

  @override
  String get favoriteMyNotes => '我的筆記';

  @override
  String get favoriteToday => '今天';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count天前';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month月$day日';
  }

  @override
  String get favoriteNoFavorites => '暫無收藏';

  @override
  String get favoriteLongPressToFavorite => '長按消息進行收藏';

  @override
  String get favoriteNewNote => '新建筆記';

  @override
  String get favoriteLink => '收藏鏈接';

  @override
  String get favoriteEditTags => '編輯標籤';

  @override
  String get favoriteDeleteFavorite => '刪除收藏';

  @override
  String get favoriteDeleteFavoriteConfirm => '確定要刪除這條收藏嗎？';

  @override
  String get favoriteNoSearchResultsFound => '沒有找到結果';

  @override
  String get commonSendRedPacket => '發紅包';

  @override
  String get transferAmount => '金額';

  @override
  String get commonRedPacketCover => '紅包封面';

  @override
  String get commonRedPacketType => '紅包類型';

  @override
  String get commonNormalRedPacket => '普通紅包';

  @override
  String get commonLuckyRedPacket => '拼手氣';

  @override
  String get commonRedPacketCount => '紅包個數';

  @override
  String get commonPieces => '個';

  @override
  String get commonPutMoneyInRedPacket => '塞錢進紅包';

  @override
  String get commonRedPacketRefundNotice => '未領取的紅包，將於24小時後發起退款';

  @override
  String get commonOpenRedPacket => '開';

  @override
  String get commonRedPacketAllClaimed => '紅包已被領完';

  @override
  String get commonRedPacketExpired => '紅包已過期';

  @override
  String get commonAddTransferNote => '添加轉賬說明';

  @override
  String get commonYuan => '元';

  @override
  String get commonReplyWithEmoji => '用此表情回覆';

  @override
  String get contactEditRemark => '編輯備註';

  @override
  String get contactSetPermissions => '設置權限';

  @override
  String get profileAddToBlacklist => '加入黑名單';

  @override
  String get contactDeleteContact => '刪除聯繫人';

  @override
  String contactDeleteContactConfirm(String name) {
    return '確定要刪除 $name 嗎？';
  }

  @override
  String get transferTitle => '轉賬';

  @override
  String get transferReceiverAddressLabel => '收款地址';

  @override
  String get transferSelectTokenLabel => '選擇代幣';

  @override
  String get transferAmountLabel => '轉賬金額';

  @override
  String get transferMemoLabel => '備註（可選）';

  @override
  String get transferAddMemoHint => '添加備註信息';

  @override
  String get transferSendPaymentRequest => '發送收款請求';

  @override
  String get transferQrCodeGenerateFailed => '二維碼生成失敗';

  @override
  String get transferScanQrToPayMe => '掃描二維碼向我付款';

  @override
  String get transferMyWalletAddress => '我的錢包地址';

  @override
  String get transferCreatePaymentRequest => '創建收款請求';

  @override
  String profileN42IdLabel(String id) {
    return 'N42號：$id';
  }

  @override
  String get commonRedPacketDefaultGreeting => '恭喜發財，大吉大利';

  @override
  String commonSenderRedPacket(String name) {
    return '$name的紅包';
  }

  @override
  String get transferEnterValidAddress => '請輸入有效的收款地址';

  @override
  String get transferPleaseSelectToken => '請選擇代幣';

  @override
  String get commonReceivedTransfer => '收到轉賬';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name發出的紅包';
  }

  @override
  String get commonSavedToBalance => '已存入零錢，可直接轉賬';

  @override
  String get commonRedPacketExpiredOrEmpty => '紅包已過期/已領完';

  @override
  String get transferScanFeatureComingSoon => '掃描功能開發中...';

  @override
  String get contactSetAsStarred => '設爲星標朋友';

  @override
  String get contactAddToBlocklist => '加入黑名單';

  @override
  String get commonClaimedYour => '領取了你的';

  @override
  String get commonClaimedText => '領取了';

  @override
  String commonUserTyping(String name) {
    return '$name正在輸入...';
  }

  @override
  String get commonTyping => '對方正在輸入...';

  @override
  String get commonWaitingToReceive => '待對方接收';

  @override
  String get commonTapToClaim => '點擊領取';

  @override
  String get commonHasBeenReceived => '已被接收';

  @override
  String get commonGetLucky => '領個好彩頭';

  @override
  String get qrcodeCameraStartFailed => '相機啓動失敗';

  @override
  String get qrcodeUnknownError => '未知錯誤';

  @override
  String get qrcodePlaceQrCodeInFrame => '將二維碼放入框內掃描';

  @override
  String get qrcodeCloseManualInput => '關閉手動輸入';

  @override
  String get qrcodeManualInputUserId => '手動輸入用戶ID';

  @override
  String get commonAdd => '加入';

  @override
  String get profileSetStatus => '設置狀態';

  @override
  String get profileVisibleToFriends24h => '可被好友看到，24小時後自動清除';

  @override
  String get profileWriteStatus => '寫狀態';

  @override
  String get profileEnterYourStatus => '輸入你的狀態...';

  @override
  String get profileOk => '確定';

  @override
  String get qrcodeCameraPermissionRequired => '掃描二維碼需要相機權限';

  @override
  String get qrcodeCameraPermissionDenied => '相機權限已被永久拒絕，請在系統設置中開啓。';

  @override
  String qrcodePermissionCheckError(String error) {
    return '檢查權限時出錯: $error';
  }

  @override
  String get qrcodeInvalidQrCode => '無效的二維碼';

  @override
  String qrcodeCannotAddFriend(String error) {
    return '無法添加好友: $error';
  }

  @override
  String get qrcodeScanQrCode => '掃描二維碼';

  @override
  String get qrcodeCheckingCameraPermission => '正在檢查相機權限...';

  @override
  String get qrcodeNeedCameraPermission => '需要相機權限';

  @override
  String get qrcodeRetryPermission => '重試';

  @override
  String get qrcodeOpenSettings => '打開設置';

  @override
  String get groupInviteMembers => '邀請成員';

  @override
  String groupInviteCount(int count) {
    return '邀請($count)';
  }

  @override
  String get profileNoShippingAddress => '暫無收貨地址';

  @override
  String get profileDefaultLabel => '默認';

  @override
  String get profileNoInvoice => '暫無發票抬頭';

  @override
  String get profileCompany => '企業';

  @override
  String get profileTaxNumber => '稅號';

  @override
  String get profileConfirmDeleteAddress => '確定要刪除這個地址嗎？';

  @override
  String get profileConfirmDeleteInvoice => '確定要刪除這個發票抬頭嗎？';

  @override
  String get commonGroupOwner => '羣主';

  @override
  String get commonGroupAdmin => '管理員';

  @override
  String get groupSearchMembers => '搜索成員';

  @override
  String groupTotalMembers(int count) {
    return '$count位成員';
  }

  @override
  String get chatRemoveFromGroup => '移出羣聊';

  @override
  String groupConfirmRemoveMember(String name) {
    return '確定要將\"$name\"移出羣聊嗎？';
  }

  @override
  String get chatUnknownSong => '未知歌曲';

  @override
  String get chatUnknownArtist => '未知藝術家';

  @override
  String get chatUnknownContact => '未知聯繫人';

  @override
  String get chatPersonalCard => '個人名片';

  @override
  String get chatSingleChoice => '單選';

  @override
  String get chatMultiChoice => '多選';

  @override
  String get chatEnded => '已結束';

  @override
  String get chatEndPollButton => '結束投票';

  @override
  String get chatPollHint => '投票發起後將顯示在聊天中，羣成員可以參與投票';

  @override
  String get chatSearchSongOrArtist => '搜索歌曲或歌手';

  @override
  String get chatNoSongsFound => '沒有找到歌曲';

  @override
  String get chatSongNameOptional => '歌曲名稱（可選）';

  @override
  String get chatEnterSongName => '輸入歌曲名稱';

  @override
  String get chatArtistNameOptional => '歌手名稱（可選）';

  @override
  String get chatEnterArtistName => '輸入歌手名稱';

  @override
  String get chatRealTimeLocationSharing => '實時位置共享功能開發中...';

  @override
  String get profileVoiceCallFeatureInDev => '語音通話功能開發中...';

  @override
  String get profileReportFeatureInDev => '舉報功能開發中...';

  @override
  String get profileShareFeatureInDev => '分享功能開發中...';

  @override
  String get profileQrCodeFeatureInDev => '二維碼功能開發中...';

  @override
  String get qrcodeScanQrToAddMe => '掃一掃上面的二維碼，加我爲好友';

  @override
  String get qrcodeSaveToAlbum => '保存到相冊';

  @override
  String get qrcodeChangeStyle => '換個樣式';

  @override
  String get qrcodeCopyId => '複製 ID';

  @override
  String get qrcodeIdCopied => '已複製用戶 ID';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => '更多樣式即將推出';

  @override
  String get profileBio => '個性簽名';

  @override
  String get profileHomeServer => '服務器';

  @override
  String get profileShareContactCard => '分享名片';

  @override
  String get profileRemoveFromBlacklist => '移出黑名單';

  @override
  String get profileConfirmAddBlacklist => '確定將該用戶加入黑名單嗎？你將不再收到對方的消息';

  @override
  String get profileConfirmRemoveBlacklist => '確定將該用戶移出黑名單嗎？';

  @override
  String get profileRemarkSaved => '備註已保存';

  @override
  String get profileRemarkCleared => '已清除備註';

  @override
  String get transferReceive => '收款';

  @override
  String get transferPleaseConnectWallet => '請先連接錢包';

  @override
  String get transferSendRequest => '發送請求';

  @override
  String get transferPleaseEnterValidAmount => '請輸入有效的金額';

  @override
  String get searchPlaceholder => '搜索聯繫人、羣聊、消息';

  @override
  String get searchEnterKeywordToSearch => '輸入關鍵詞開始搜索';

  @override
  String get searchClearHistory => '清除';

  @override
  String searchNoResultsForQuery(String query) {
    return '沒有找到\"$query\"相關的結果';
  }

  @override
  String get searchAllResults => '全部';

  @override
  String get searchInChat => '在聊天中搜索';

  @override
  String get searchContactLabel => '聯繫人';

  @override
  String get searchGroupLabel => '羣聊';

  @override
  String get searchConversationLabel => '會話';

  @override
  String get searchMessageLabel => '消息';

  @override
  String get settingsSecurityTitle => '安全';

  @override
  String get settingsKeyBackup => '密鑰備份';

  @override
  String get settingsBackupEncryptionKeys => '備份加密密鑰';

  @override
  String settingsKeysBackedUp(int count) {
    return '已備份 $count 個密鑰';
  }

  @override
  String get settingsBackupNotSet => '未設置備份';

  @override
  String get settingsRestoreKeys => '恢復密鑰';

  @override
  String get settingsRestoreKeysFromBackup => '從備份恢復加密密鑰';

  @override
  String get settingsExportKeys => '導出密鑰';

  @override
  String get settingsExportKeysToFile => '導出密鑰到文件';

  @override
  String get settingsLoggedInDevices => '已登錄設備';

  @override
  String get settingsNoOtherDevices => '暫無其他設備';

  @override
  String get settingsVerified => '已驗證';

  @override
  String get settingsUnverified => '未驗證';

  @override
  String get settingsAdvanced => '高級';

  @override
  String get settingsCrossSigning => '跨設備簽名';

  @override
  String get settingsEnabled => '已啓用';

  @override
  String get settingsNotEnabled => '未啓用';

  @override
  String get settingsResetEncryption => '重置加密';

  @override
  String get settingsDeleteAllEncryptionKeys => '刪除所有加密密鑰';

  @override
  String get settingsEncryptionNotSupported => '不支持加密';

  @override
  String get settingsNotInitialized => '未初始化';

  @override
  String get settingsBackupKeyTitle => '備份密鑰';

  @override
  String get settingsBackupKeyMessage => '是否創建新的密鑰備份？這將幫助您在新設備上恢復加密消息。';

  @override
  String get settingsBackup => '備份';

  @override
  String get settingsRestoreKeyTitle => '恢復密鑰';

  @override
  String get settingsRestoreKeyMessage => '輸入您的恢復密碼或恢復密鑰來恢復加密消息。';

  @override
  String get settingsRestore => '恢復';

  @override
  String get settingsExportKeyTitle => '導出密鑰';

  @override
  String get settingsExportKeyMessage => '導出的密鑰文件包含您的所有加密密鑰，請妥善保管。';

  @override
  String get settingsExport => '導出';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return '設備ID: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => '狀態: 已驗證';

  @override
  String get settingsDeviceStatusUnverified => '狀態: 未驗證';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return '最後活躍: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => '驗證此設備';

  @override
  String get settingsCrossSigningAlreadyEnabled => '跨設備簽名已啓用';

  @override
  String get settingsCrossSigningSetupSuccess => '跨設備簽名設置成功';

  @override
  String get settingsResetEncryptionTitle => '重置加密';

  @override
  String get settingsResetEncryptionWarning =>
      '警告：這將刪除您所有的加密密鑰。您將無法解密之前的加密消息。此操作不可撤銷。';

  @override
  String get settingsReset => '重置';

  @override
  String get settingsBackupSuccess => '密鑰備份成功';

  @override
  String get settingsBackupFailed => '備份失敗';

  @override
  String get settingsRecoveryKey => '恢復密鑰';

  @override
  String get settingsRecoveryKeySaveWarning =>
      '請將此恢復密鑰保存在安全的地方。您需要它在新設備上恢復加密消息。';

  @override
  String get settingsRecoveryKeySaved => '我已保存';

  @override
  String get settingsRestoreSuccess => '密鑰恢復成功';

  @override
  String get settingsRestoreFailed => '恢復失敗';

  @override
  String get settingsPassword => '密碼';

  @override
  String get settingsEnterRecoveryKey => '輸入恢復密鑰';

  @override
  String get settingsEnterPassword => '輸入密碼';

  @override
  String get settingsExportSuccess => '密鑰已成功導出到服務端備份';

  @override
  String get settingsExportNeedBackupFirst => '請先創建密鑰備份';

  @override
  String get settingsExportFailed => '導出失敗';

  @override
  String get settingsResetSuccess => '加密重置成功';

  @override
  String get settingsResetFailed => '重置失敗';

  @override
  String get callLeaveMeetingConfirm => '確定要離開會議嗎？';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return '拍了拍「$name」$suffix';
  }

  @override
  String get chatNoContactsToAdd => '沒有可添加的聯繫人';

  @override
  String get chatAddMembers => '添加成員';

  @override
  String chatInvitedMembers(int count) {
    return '已邀請 $count 位成員';
  }

  @override
  String chatInviteFailed(String error) {
    return '邀請失敗: $error';
  }

  @override
  String get chatMemberRemoved => '已移除成員';

  @override
  String chatRemoveFailed(String error) {
    return '移除失敗: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage => '開始共享後，對方將能看到你的實時位置，共享時長爲1小時。';

  @override
  String get chatStartSharing => '開始共享';

  @override
  String get chatLocationServiceNotEnabled => '位置服務未開啓';

  @override
  String get chatEnableLocationService => '請開啓位置服務以使用位置功能';

  @override
  String get chatGoToSettings => '去設置';

  @override
  String get chatLocationPermissionRequired => '需要位置權限才能使用此功能';

  @override
  String get chatLocationPermissionDeniedPermanent => '位置權限已被永久拒絕，請在設置中開啓';

  @override
  String get chatLocationPermissionDenied => '位置權限被拒絕';

  @override
  String get chatGettingLocation => '正在獲取位置...';

  @override
  String chatGetLocationFailed(String error) {
    return '獲取位置失敗: $error';
  }

  @override
  String get chatMapPreview => '地圖預覽';

  @override
  String get chatSearchLocation => '搜索地點';

  @override
  String chatRedPacketSent(String amount, String token) {
    return '已發送 $amount $token 紅包';
  }

  @override
  String get chatTransferDefault => '轉賬';

  @override
  String chatTransferSent(String amount, String token) {
    return '已發送 $amount $token 轉賬';
  }

  @override
  String chatPickFileFailed(String error) {
    return '選擇文件失敗: $error';
  }

  @override
  String get chatFileSizeLimit => '文件大小不能超過 50MB';

  @override
  String chatFileSending(String filename) {
    return '文件發送中: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return '發送文件失敗: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return '已發送 $name 的名片';
  }

  @override
  String get chatFavoritesFeature => '收藏';

  @override
  String get chatCouponsFeature => '卡券';

  @override
  String get chatGiftFeature => '禮物';

  @override
  String chatSharedMusic(String name) {
    return '已分享 $name';
  }

  @override
  String get chatEndPollTitle => '結束投票';

  @override
  String get chatEndPollConfirmMessage => '確定要結束這個投票嗎？結束後將無法繼續投票。';

  @override
  String get chatPollEndedMessage => '投票已結束';

  @override
  String get chatConnectingCall => '正在連接...';

  @override
  String get chatMuteCall => '靜音';

  @override
  String get chatSpeakerOff => '關閉免提';

  @override
  String get chatSpeakerOn => '免提';

  @override
  String get chatCameraOn => '開啓攝像頭';

  @override
  String get chatCameraOff => '關閉攝像頭';

  @override
  String get chatHangUp => '掛斷';

  @override
  String get chatSelectForwardTargetTitle => '選擇轉發對象';

  @override
  String get chatNoForwardableChat => '沒有可轉發的會話';

  @override
  String get chatNoMatchingChat => '沒有找到相關會話';

  @override
  String get chatLocationTitle => '位置';

  @override
  String get chatSendButton => '發送';

  @override
  String get chatRetryButton => '重試';

  @override
  String get chatSearchContactHint => '搜索聯繫人';

  @override
  String get chatShareMusic => '分享音樂';

  @override
  String get chatRecentPlayed => '最近播放';

  @override
  String get chatMyFavorites => '我喜歡';

  @override
  String get chatNetworkLink => '網絡鏈接';

  @override
  String get chatLocalFile => '本地文件';

  @override
  String get chatPasteMusicLink => '粘貼音樂鏈接';

  @override
  String get chatShareMusicButton => '分享音樂';

  @override
  String get chatSelectLocalAudio => '選擇本地音頻文件';

  @override
  String get chatSupportedAudioFormats => '支持 MP3、M4A、WAV、FLAC 等格式';

  @override
  String get chatSelectFileButton => '選擇文件';

  @override
  String get chatPleaseEnterMusicLink => '請輸入音樂鏈接';

  @override
  String get chatPleaseEnterValidLink => '請輸入有效的網絡鏈接';

  @override
  String get chatSharedSong => '分享歌曲';

  @override
  String get chatSelectMember => '選擇成員';

  @override
  String get chatSearchMemberHint => '搜索成員';

  @override
  String get chatNoMatchingMembers => '未找到匹配的成員';

  @override
  String get commonUnknownMember => '未知';

  @override
  String chatSelectedMessagesCount(int count) {
    return '已選擇 $count 條消息';
  }

  @override
  String get chatSearchContactsOrGroups => '搜索聯繫人或羣聊';

  @override
  String get chatVideoTitle => '視頻';

  @override
  String get chatLoadingText => '加載中...';

  @override
  String get chatVideoLoadFailed => '視頻加載失敗';

  @override
  String get chatPlayerInitFailed => '播放器初始化失敗';

  @override
  String get chatCreatePollTitle => '創建投票';

  @override
  String get chatSubmitPoll => '發起';

  @override
  String get chatPollQuestionLabel => '投票問題';

  @override
  String get chatEnterPollQuestionHint => '請輸入投票問題';

  @override
  String get chatPollOptionsLabel => '投票選項';

  @override
  String chatOptionHintWithIndex(int index) {
    return '選項 $index';
  }

  @override
  String get chatAddOptionButton => '添加選項';

  @override
  String get chatPollSettingsLabel => '投票設置';

  @override
  String get chatSelectionType => '選擇類型';

  @override
  String get chatSingleChoiceLabel => '單選';

  @override
  String get chatMultiChoiceLabel => '多選';

  @override
  String get chatAnonymousPollSwitch => '匿名投票';

  @override
  String get chatPleaseEnterQuestion => '請輸入投票問題';

  @override
  String get chatAtLeastTwoOptions => '至少需要2個選項';

  @override
  String chatConfirmWithCount(int count) {
    return '確定 ($count)';
  }

  @override
  String get authEmailVerificationTitle => '郵箱驗證';

  @override
  String get authEnterValidEmailAddress => '請輸入有效的郵箱地址';

  @override
  String authVerificationCodeSentTo(String email) {
    return '驗證碼已發送到 $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return '發送驗證碼失敗: $error';
  }

  @override
  String get authVerificationSuccess => '驗證成功';

  @override
  String get authVerificationFailed => '驗證失敗';

  @override
  String authVerificationCodeError(String error) {
    return '驗證碼錯誤: $error';
  }

  @override
  String get commonEnterVerificationCode => '輸入驗證碼';

  @override
  String get authEnterYourEmail => '輸入郵箱';

  @override
  String authWeSentCodeTo(String email) {
    return '我們已向 $email 發送了\n6位驗證碼';
  }

  @override
  String get authEnterEmailForCode => '輸入您的郵箱地址，我們將發送驗證碼';

  @override
  String get commonSendVerificationCode => '發送驗證碼';

  @override
  String get authResendVerificationCode => '重新發送驗證碼';

  @override
  String authCanResendAfter(int seconds) {
    return '$seconds秒後可重新發送';
  }

  @override
  String get commonChangeEmail => '更換郵箱';

  @override
  String get contactAddToContacts => '添加到通訊錄';

  @override
  String get contactAddingToContacts => '添加中...';

  @override
  String get contactAddedToContacts => '已添加到通訊錄';

  @override
  String contactAddFailedWithError(String error) {
    return '添加失敗: $error';
  }

  @override
  String get contactAddPhone => '添加電話';

  @override
  String get contactAddTag => '添加標籤';

  @override
  String get contactAddText => '添加文字';

  @override
  String get contactAddPhoto => '添加照片';

  @override
  String contactGroupCountLabel(int count) {
    return '$count個';
  }

  @override
  String get contactAddedViaSearch => '通過搜索添加';

  @override
  String get contactAddTime => '添加時間';

  @override
  String get contactDoneButton => '完成';

  @override
  String get callWaitingForParticipants => '等待參與者加入...';

  @override
  String callParticipantMe(String name) {
    return '$name（我）';
  }

  @override
  String get callSharingLabel => '共享中';

  @override
  String callScreenSharingBy(String name) {
    return '$name 正在共享屏幕';
  }

  @override
  String callParticipantCount(int count) {
    return '$count 人';
  }

  @override
  String get callMuteLabel => '靜音';

  @override
  String get callUnmuteLabel => '解除靜音';

  @override
  String get callTurnOffVideo => '關閉視頻';

  @override
  String get callTurnOnVideo => '開啓視頻';

  @override
  String get callShareScreen => '共享屏幕';

  @override
  String get callStopSharing => '停止共享';

  @override
  String get callSwitchCameraLabel => '切換';

  @override
  String get callLeaveLabel => '離開';

  @override
  String get callParticipantsLabel => '參與者';

  @override
  String get callJoiningMeeting => '正在加入會議...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count 票 ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count 人蔘與';
  }

  @override
  String get commonTapToRetry => '點擊重試';

  @override
  String get chatDefaultRedPacketGreeting => '恭喜發財，大吉大利';

  @override
  String get groupAllowOthersToSearchAndJoin => '允許他人搜索並加入';

  @override
  String get groupConfirmClearChatHistory => '確定要清空聊天記錄嗎？';

  @override
  String get groupCreateGroupToChat => '創建羣聊以開始聊天';

  @override
  String get groupEditGroupAnnouncement => '編輯羣公告';

  @override
  String get groupEditGroupDescription => '編輯羣描述';

  @override
  String get groupEnterGroupAnnouncement => '請輸入羣公告';

  @override
  String chatErrorWithMessage(String message) {
    return '錯誤: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count人，點擊複製羣ID';
  }

  @override
  String get chatMusicLinkLabel => '音樂鏈接';

  @override
  String get chatNoMediaUrlAvailable => '沒有可用的媒體鏈接';

  @override
  String get groupNoPermissionToEditGroupName => '你沒有權限修改羣名稱';

  @override
  String get chatRedPacketTransferCannotForward => '紅包和轉賬消息無法轉發';

  @override
  String get authEmailAddress => '郵箱地址';

  @override
  String get commonEnterEmailAddress => '請輸入郵箱地址';

  @override
  String get authEmailRecoveryHint => '用於找回密碼';

  @override
  String get commonInvalidEmailFormat => '請輸入有效的郵箱地址';

  @override
  String get authOptional => '選填';

  @override
  String get authResetPassword => '重置密碼';

  @override
  String get authEnterRegisteredEmail => '請輸入註冊時綁定的郵箱地址';

  @override
  String get authSendResetCode => '發送重置驗證碼';

  @override
  String authResetCodeSent(String email) {
    return '重置驗證碼已發送至 $email';
  }

  @override
  String get authEnterResetCode => '輸入重置驗證碼';

  @override
  String get authSetNewPassword => '設置新密碼';

  @override
  String get commonConfirmNewPassword => '確認新密碼';

  @override
  String get commonNewPassword => '新密碼';

  @override
  String get authPasswordResetSuccess => '密碼重置成功，請使用新密碼登錄';

  @override
  String get authResetPasswordFailed => '重置密碼失敗';

  @override
  String get settingsChangePassword => '修改密碼';

  @override
  String get settingsCurrentPassword => '當前密碼';

  @override
  String get settingsEnterCurrentPassword => '請輸入當前密碼';

  @override
  String get settingsEnterNewPassword => '請輸入新密碼';

  @override
  String get settingsPasswordChanged => '密碼修改成功，請使用新密碼重新登錄';

  @override
  String get settingsChangePasswordFailed => '修改密碼失敗';

  @override
  String get settingsNewPasswordMustBeDifferent => '新密碼不能與當前密碼相同';

  @override
  String get settingsChangePasswordInfo => '修改密碼後，您將被登出，需要使用新密碼重新登錄。';

  @override
  String get settingsPasswordRequirements => '密碼要求：';

  @override
  String get settingsSecurityNote => '爲了安全，修改密碼後需要在所有設備上重新登錄。';

  @override
  String get settingsSecurity => '安全';

  @override
  String get settingsCurrentBoundEmail => '當前綁定郵箱';

  @override
  String get settingsNewEmailAddress => '新郵箱地址';

  @override
  String get settingsEnterNewEmail => '請輸入新郵箱地址';

  @override
  String get settingsVerificationCode => '驗證碼';

  @override
  String get settingsVerificationCodeSent => '驗證碼已發送';

  @override
  String get settingsCodeSentTo => '驗證碼已發送至';

  @override
  String get settingsDidNotReceiveCode => '沒有收到驗證碼？';

  @override
  String get settingsEmailChangedSuccess => '郵箱修改成功';

  @override
  String get settingsChangeEmailFailed => '修改郵箱失敗';

  @override
  String get settingsEmailSecurityNote => '郵箱用於密碼找回，請確保安全。';

  @override
  String get commonGoogleLogin => '使用 Google 登錄';

  @override
  String get commonAppleLogin => '使用 Apple 登錄';

  @override
  String get commonWechat => '微信';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsLanguageChanged => '語言已更改';

  @override
  String get settingsTranslation => '翻譯';

  @override
  String get settingsTranslateTextTo => '將文字翻譯爲';

  @override
  String get settingsTranslateDescription => '選擇你希望將消息翻譯成的語言。';

  @override
  String get settingsAutoTranslate => '自動翻譯聊天中收到的消息';

  @override
  String get settingsAutoTranslateDescription => '自動將聊天中收到的消息翻譯爲你選擇的語言。';

  @override
  String get settingsBiometricLogin => '生物識別登錄';

  @override
  String authLoginWithBiometric(Object type) {
    return '使用$type登錄';
  }

  @override
  String get settingsBiometricLoginEnabled => '生物識別登錄已啓用';

  @override
  String get settingsBiometricLoginDisabled => '生物識別登錄已禁用';

  @override
  String get settingsEnableBiometricLogin => '啓用生物識別登錄';

  @override
  String get settingsBiometricEnabled => '已啓用 - 使用生物識別登錄';

  @override
  String get settingsBiometricDisabled => '已禁用 - 點擊啓用';

  @override
  String get settingsBiometricNeedRelogin => '請退出後重新登錄以啓用生物識別';

  @override
  String get authOr => '或';

  @override
  String get qrcodeCameraPermissionRestricted => '此設備上的相機訪問受限';

  @override
  String get authPasskeyLabel => 'Passkey';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'Apple';

  @override
  String get authSsoLabel => 'SSO';

  @override
  String get transferAmountHintZero => '0.00';

  @override
  String get commonMatrixIdHint => '@username:server.com';

  @override
  String get authServerAddressHint => 'https://m.si46.world';

  @override
  String get authEmailExampleHint => 'example@email.com';

  @override
  String get authVerificationCodePlaceholder => '------';

  @override
  String get profileEnterPokeSuffixHint => '輸入戳一戳後綴，例如：的肩膀';

  @override
  String get groupAlbum => '羣相冊';

  @override
  String get groupFiles => '羣文件';

  @override
  String get groupImages => '圖片';

  @override
  String get groupVideos => '視頻';

  @override
  String get groupTotal => '全部';

  @override
  String get groupSize => '大小';

  @override
  String get groupNoMedia => '暫無媒體';

  @override
  String get groupNoMediaDescription => '此羣還沒有圖片或視頻';

  @override
  String get groupDocuments => '文檔';

  @override
  String get groupNoFiles => '暫無文件';

  @override
  String get groupNoFilesDescription => '此羣還沒有文件';

  @override
  String groupDownloadStarted(String filename) {
    return '正在下載 $filename...';
  }

  @override
  String get contactNoCommonGroups => '暫無共同羣組';

  @override
  String get contactNoCommonGroupsDescription => '你們沒有共同加入的羣組';

  @override
  String get chatVoiceMessage => '語音';

  @override
  String get chatMessage => '消息';

  @override
  String get conversationHideChat => '隱藏';

  @override
  String get settingsQuickReply => '快捷回覆';

  @override
  String get commonTranslate => '翻譯';

  @override
  String get contactCreateTag => '新建標籤';

  @override
  String get contactEnterTagName => '輸入標籤名稱';

  @override
  String get contactEditTag => '編輯標籤';

  @override
  String get contactDeleteTag => '刪除標籤';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return '確定要刪除標籤 \"$tagName\" 嗎？';
  }

  @override
  String get contactNoTags => '暫無標籤';

  @override
  String get contactFriendPermissions => '朋友權限';

  @override
  String get contactSetChatOnly => '設爲僅聊天';

  @override
  String get contactChatOnlyDesc => '只能聊天，其他內容將被隱藏';

  @override
  String get contactHideMyMoments => '不讓他（她）看我的朋友圈';

  @override
  String get contactHideMyMomentsDesc => '該好友無法查看你的朋友圈動態';

  @override
  String get contactHideTheirMoments => '不看他（她）的朋友圈';

  @override
  String get contactHideTheirMomentsDesc => '不會看到該好友的朋友圈動態';

  @override
  String get contactHideMyStatus => '不讓他（她）看我的狀態';

  @override
  String get contactHideMyStatusDesc => '該好友無法查看你的狀態更新';

  @override
  String get contactNoChatOnlyFriends => '暫無僅聊天的朋友';

  @override
  String get contactNoOfficialAccounts => '暫無公衆號';

  @override
  String get contactFollowOfficialAccountsDesc => '關注公衆號，獲取最新資訊';

  @override
  String get contactNoServiceAccounts => '暫無服務號';

  @override
  String get contactSubscribeServiceAccountsDesc => '訂閱服務號，享受便捷服務';

  @override
  String get contactNoEnterpriseContacts => '暫無企業聯繫人';

  @override
  String get contactEnterpriseContactsDesc => '企業通訊錄聯繫人將顯示在這裏';

  @override
  String get profileCardPack => '卡包';

  @override
  String get profileOrders => '訂單';

  @override
  String get profileNoOrders => '暫無訂單';

  @override
  String get profileOrdersDesc => '你的訂單將顯示在這裏';

  @override
  String get profileNoCards => '暫無卡券';

  @override
  String get profileCardsDesc => '你的卡券將顯示在這裏';

  @override
  String get favoriteEnterTagsHint => '輸入標籤，用逗號分隔';

  @override
  String get favoriteTagsUpdated => '標籤已更新';

  @override
  String get favoriteForwardedContent => '內容已轉發';

  @override
  String get favoriteEnterNoteContent => '輸入筆記內容';

  @override
  String get favoriteNoteAdded => '筆記已添加';

  @override
  String get favoriteLinkTitle => '鏈接標題';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => '鏈接已添加';

  @override
  String get contactPhotoAdded => '照片已添加';

  @override
  String get contactEnterPhone => '輸入手機號碼';

  @override
  String commonConversationWithId(String roomId) {
    return '會話: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return '聯繫人: $userId';
  }

  @override
  String get commonDiscover => '發現';

  @override
  String commonDeveloping(String title) {
    return '$title\n(開發中)';
  }

  @override
  String get commonPageNotFound => '頁面不存在';

  @override
  String get commonBackToHome => '返回首頁';

  @override
  String get settingsMessageNotifications => '消息通知';

  @override
  String get settingsReceiveNewMessageNotifications => '接收新消息通知';

  @override
  String get settingsShowMessagePreview => '顯示消息預覽';

  @override
  String get settingsShowMessageContentInNotification => '在通知中顯示消息內容';

  @override
  String get settingsNotificationSound => '通知聲音';

  @override
  String get settingsPlaySoundOnMessage => '收到消息時播放聲音';

  @override
  String get commonVibration => '振動';

  @override
  String get settingsVibrateOnMessage => '收到消息時震動';

  @override
  String get settingsDoNotDisturbMode => '勿擾模式';

  @override
  String get settingsDoNotDisturbDescription => '在指定時間內不接收通知';

  @override
  String get settingsStartTime => '開始時間';

  @override
  String get settingsEndTime => '結束時間';

  @override
  String get settingsDeleteQuickReply => '刪除快捷回覆';

  @override
  String get settingsEditQuickReply => '編輯快捷回覆';

  @override
  String get settingsAddQuickReply => '添加快捷回覆';

  @override
  String get settingsManageQuickReplies => '管理快捷回覆';

  @override
  String get settingsNoQuickReplies => '暫無快捷回覆';

  @override
  String get settingsDefaultQuickReplies => '將顯示默認快捷回覆';

  @override
  String get settingsWhoCanSee => '誰可以查看';

  @override
  String get settingsLastSeen => '最後上線時間';

  @override
  String get settingsHiddenChats => '隱藏的聊天';

  @override
  String get settingsMessagesLabel => '消息';

  @override
  String get settingsAllowStrangerMessages => '允許陌生人消息';

  @override
  String get settingsReceiveMessagesFromNonContacts => '接收非聯繫人的消息';

  @override
  String get settingsReadReceipts => '已讀回執';

  @override
  String get settingsLetOthersKnowYouRead => '讓對方知道你已讀';

  @override
  String get settingsTypingIndicator => '輸入狀態指示';

  @override
  String get settingsLetOthersKnowYouTyping => '讓對方知道你正在輸入';

  @override
  String get settingsEveryone => '所有人';

  @override
  String get settingsContactsOnly => '僅聯繫人';

  @override
  String get settingsNobody => '無人';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return '誰可以看到 $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return '版本 $version';
  }

  @override
  String get settingsCheckForUpdates => '檢查更新';

  @override
  String get settingsOpenSourceLicenses => '開源許可';

  @override
  String get settingsFeedbackAndSuggestions => '反饋與建議';

  @override
  String get settingsBuiltOnMatrix => '基於 Matrix 協議構建';

  @override
  String get settingsNoHiddenChats => '沒有隱藏的聊天';

  @override
  String get settingsNoHiddenChatsDescription => '你隱藏的聊天會顯示在這裏';

  @override
  String get settingsUnhideChat => '取消隱藏';

  @override
  String get settingsDarkMode => '深色模式';

  @override
  String get settingsFontSize => '字體大小';

  @override
  String get settingsBubbleStyle => '氣泡樣式';

  @override
  String get settingsFollowSystem => '跟隨系統';

  @override
  String get settingsAutoSwitchBySystem => '跟隨系統自動切換';

  @override
  String get settingsLightMode => '淺色模式';

  @override
  String get settingsAlwaysUseLightTheme => '始終使用淺色主題';

  @override
  String get settingsDarkModeOption => '深色模式選項';

  @override
  String get settingsAlwaysUseDarkTheme => '始終使用深色主題';

  @override
  String get settingsFontSizeSmall => '小';

  @override
  String get settingsFontSizeStandard => '標準';

  @override
  String get settingsFontSizeLarge => '大';

  @override
  String get settingsFontSizeExtraLarge => '特大';

  @override
  String get settingsBubbleStyleWechat => '微信樣式';

  @override
  String get settingsBubbleStyleWechatDesc => '經典微信氣泡樣式';

  @override
  String get settingsBubbleStyleModern => '現代樣式';

  @override
  String get settingsBubbleStyleModernDesc => '簡潔的現代氣泡樣式';

  @override
  String get settingsBubbleStyleClassic => '經典樣式';

  @override
  String get settingsBubbleStyleClassicDesc => '傳統的氣泡樣式';

  @override
  String get discoverVideoChannels => '視頻號';

  @override
  String get discoverLive => '直播';

  @override
  String get discoverListen => '聽一聽';

  @override
  String get discoverWatch => '看一看';

  @override
  String get discoverSearchDiscover => '搜一搜';

  @override
  String get discoverNearbyPeople => '附近的人';

  @override
  String get discoverGames => '遊戲';

  @override
  String get discoverMiniPrograms => '小程序';

  @override
  String get chatAlreadyInCall => '當前正在通話中';

  @override
  String get commonConnectionFailed => '連接失敗';

  @override
  String get chatCallRejected => '對方已拒絕';

  @override
  String get chatNoAnswer => '對方無應答';

  @override
  String get commonClose => '關閉';

  @override
  String get chatSelectContact => '選擇聯繫人';

  @override
  String get chatVoteRemoved => '已取消投票';

  @override
  String get chatVoteChanged => '投票已更改';

  @override
  String get chatVoted => '已投票';

  @override
  String chatReplyTo(String name) {
    return '回覆 $name';
  }

  @override
  String get chatCurrentLocation => '當前位置';

  @override
  String chatNearbyPlace(int index) {
    return '附近地點 $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return '約 $distance';
  }

  @override
  String get chatAddress => '地址';

  @override
  String get chatLatitude => '緯度';

  @override
  String get chatLongitude => '經度';

  @override
  String get groupDescriptionUpdated => '羣簡介已更新';

  @override
  String get groupAvatarUpdated => '羣頭像已更新';

  @override
  String get groupVisibilityUpdated => '羣可見性已更新';

  @override
  String get groupChannelCreated => '頻道已創建';

  @override
  String get groupChannelUpdated => '頻道已更新';

  @override
  String get groupChannelDeleted => '頻道已刪除';

  @override
  String get callDecline => '拒絕';

  @override
  String get callAnswer => '接聽';

  @override
  String get callIncomingVideoCall => '視頻來電';

  @override
  String get callIncomingVoiceCall => '語音來電';

  @override
  String get callVideoCallInProgress => '視頻通話中';

  @override
  String get callVoiceCallInProgress => '語音通話中';

  @override
  String get callReconnectingCall => '正在重連...';

  @override
  String get callEnded => '通話已結束';

  @override
  String get callFailed => '通話失敗';

  @override
  String get callLivekitNotConfigured => 'LiveKit 未配置';

  @override
  String callJoinMeetingFailed(String error) {
    return '加入會議失敗: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return '屏幕共享失敗: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42豆';

  @override
  String get profileNoN42Bean => '暫無N42豆';

  @override
  String get profileN42BeanDetails => 'N42豆明細';

  @override
  String get profileN42BeanDescription => 'N42豆是用於兌換N42內虛擬物品和服務的道具，目前可用於兌換：';

  @override
  String get profileN42BeanFeature1 => '會員專屬表情和主題';

  @override
  String get profileN42BeanFeature2 => '聊天氣泡個性化';

  @override
  String get profileN42BeanFeature3 => '紅包封面定製';

  @override
  String get profileN42BeanFeature4 => '專屬暱稱標識';

  @override
  String get profileN42BeanFeature5 => '羣聊特權功能';

  @override
  String get profileN42BeanFeature6 => '雲存儲空間擴展';

  @override
  String get profileN42BeanFeature7 => '視頻通話美顏濾鏡';

  @override
  String get profileN42BeanFeature8 => '朋友圈背景更換';

  @override
  String get profileN42BeanFeature9 => 'VIP客服優先服務';

  @override
  String get profileGotIt => '我知道了';

  @override
  String get profileNoN42BeanRecords => '暫無N42豆明細記錄';

  @override
  String get profileMoodAndThoughts => '心情想法';

  @override
  String get profileStatusHappy => '開心';

  @override
  String get profileStatusCracked => '裂開';

  @override
  String get profileStatusLucky => '發呆';

  @override
  String get profileStatusSunny => '天氣晴';

  @override
  String get profileStatusTired => '累了';

  @override
  String get profileStatusDaydream => '發呆中';

  @override
  String get profileStatusRushing => '忙碌';

  @override
  String get profileStatusOverthinking => '想太多';

  @override
  String get profileStatusEnergized => '元氣滿滿';

  @override
  String get profileWorkAndStudy => '工作學習';

  @override
  String get profileStatusWorking => '搬磚中';

  @override
  String get profileStatusStudying => '學習中';

  @override
  String get profileStatusBusy => '忙';

  @override
  String get profileStatusSlacking => '摸魚中';

  @override
  String get profileStatusTraveling => '旅行中';

  @override
  String get profileStatusGoingHome => '回家中';

  @override
  String get profileStatusDnd => '請勿打擾';

  @override
  String get profileActivities => '活動';

  @override
  String get profileStatusHanging => '出去浪';

  @override
  String get profileStatusCheckIn => '打卡';

  @override
  String get profileStatusExercising => '運動中';

  @override
  String get profileStatusCoffee => '喝咖啡';

  @override
  String get profileStatusBubbleTea => '奶茶';

  @override
  String get profileStatusEating => '乾飯中';

  @override
  String get profileStatusParenting => '帶娃中';

  @override
  String get profileStatusSavingWorld => '拯救世界';

  @override
  String get profileStatusSelfie => '自拍';

  @override
  String get profileRest => '休息';

  @override
  String get profileStatusRetreat => '閉關';

  @override
  String get profileStatusHome => '宅家';

  @override
  String get profileStatusSleeping => '睡覺中';

  @override
  String get profileStatusCatLover => '吸貓中';

  @override
  String get profileStatusDogWalking => '遛狗中';

  @override
  String get profileStatusGaming => '遊戲中';

  @override
  String get profileStatusListening => '聽歌中';

  @override
  String get profileEditAddress => '編輯地址';

  @override
  String get profileRecipient => '收貨人';

  @override
  String get profileEnterRecipientName => '請輸入收貨人姓名';

  @override
  String get profilePhoneNumber => '手機號碼';

  @override
  String get profileEnterPhoneNumber => '請輸入手機號碼';

  @override
  String get profileRegionHint => '省/市/區';

  @override
  String get profileDetailedAddress => '詳細地址';

  @override
  String get profileDetailedAddressHint => '街道、門牌號等';

  @override
  String get profileSetAsDefaultAddress => '設爲默認地址';

  @override
  String get profilePleaseCompleteInfo => '請填寫完整信息';

  @override
  String get profileEditInvoice => '編輯發票抬頭';

  @override
  String get profileInvoiceType => '抬頭類型';

  @override
  String get profileCompanyName => '企業名稱';

  @override
  String get profilePersonalName => '個人姓名';

  @override
  String get profileEnterCompanyName => '請輸入企業名稱';

  @override
  String get profileEnterName => '請輸入姓名';

  @override
  String get profileTaxIdNumber => '納稅人識別號';

  @override
  String get profileEnterTaxIdNumber => '請輸入納稅人識別號';

  @override
  String get profileBankNameOptional => '開戶銀行（選填）';

  @override
  String get profileEnterBankName => '請輸入開戶銀行';

  @override
  String get profileBankAccountOptional => '銀行賬號（選填）';

  @override
  String get profileEnterBankAccount => '請輸入銀行賬號';

  @override
  String get profileCompanyAddressOptional => '企業地址（選填）';

  @override
  String get profileEnterCompanyAddress => '請輸入企業地址';

  @override
  String get profileCompanyPhoneOptional => '企業電話（選填）';

  @override
  String get profileEnterCompanyPhone => '請輸入企業電話';

  @override
  String get profileSetAsDefaultInvoice => '設爲默認抬頭';

  @override
  String get profileRingtoneVibrate => '震動';

  @override
  String get profileRingtoneSilent => '靜音';

  @override
  String get profileVibrateMode => '振動模式';

  @override
  String get profileSilentMode => '靜音模式';

  @override
  String profilePlayFailed(String ringtoneName) {
    return '播放失敗: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return '正在播放: $ringtoneName';
  }

  @override
  String get profileStop => '停止';

  @override
  String get profileSelectRingtone => '選擇鈴聲';

  @override
  String get profileLoadingRingtones => '加載鈴聲中...';

  @override
  String get profileNoRingtonesFound => '未找到鈴聲';

  @override
  String mainMessagesWithCount(int count) {
    return '消息($count)';
  }

  @override
  String get storyViewers => '瀏覽者';

  @override
  String get storyNoViewers => '暫無瀏覽';

  @override
  String get storyReplyToStory => '回覆狀態...';

  @override
  String get commonCopiedToClipboard => '已複製到剪貼板';

  @override
  String get commonMore => '更多';

  @override
  String get commonTranslating => '翻譯中...';

  @override
  String commonTranslatedFrom(String language) {
    return '翻譯自$language';
  }

  @override
  String get commonTranslation => '翻譯';

  @override
  String get commonTranslationFailed => '翻譯失敗';

  @override
  String get commonAllRead => '全部已讀';

  @override
  String commonReadCount(int count) {
    return '$count人已讀';
  }

  @override
  String get commonYouRecalledMessage => '你撤回了一條消息';

  @override
  String get commonMessageRecalled => '對方撤回了一條消息';

  @override
  String get commonReEdit => '重新編輯';

  @override
  String get commonWalletArea => '錢包功能區域';

  @override
  String get callIncomingCall => '來電';

  @override
  String get callMissedCall => '未接來電';

  @override
  String get groupRemoveAdmin => '取消管理員';

  @override
  String get chatSelectCurrency => '選擇幣種';

  @override
  String get chatSelectEmoji => '選擇表情';

  @override
  String get chatSelectRedPacketCover => '選擇封面';

  @override
  String get groupSetAsAdmin => '設爲管理員';

  @override
  String get chatVideoPlaybackFailed => '視頻播放失敗';

  @override
  String get groupViewProfile => '查看資料';

  @override
  String get favoriteAddLinkComingSoon => '添加鏈接功能即將推出';

  @override
  String get favoriteNewNoteComingSoon => '新建筆記功能即將推出';

  @override
  String get qrcodeSaveFeatureComingSoon => '保存功能即將推出';

  @override
  String get qrcodeShareFeatureComingSoon => '分享功能即將推出';

  @override
  String qrcodeProcessFailed(String error) {
    return '處理二維碼失敗: $error';
  }

  @override
  String get securityDeviceIdRequired => '需要設備 ID';

  @override
  String securityVerificationStartFailed(String error) {
    return '啓動驗證失敗: $error';
  }

  @override
  String get securityVerificationFailed => '驗證失敗';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return '驗證失敗: $reason';
  }

  @override
  String get securityEmojiMismatchRejected => '驗證被拒絕 - 表情不匹配';

  @override
  String get securityWaitingForDeviceAccept => '等待另一臺設備接受...';

  @override
  String get securityVerifyDevice => '驗證此設備';

  @override
  String get securityConfirmEmojiMatch => '確認以下表情符號在兩臺設備上以相同順序顯示';

  @override
  String get securityEmojiDontMatch => '不匹配';

  @override
  String get securityEmojiMatch => '匹配';

  @override
  String get securityWaitingForDeviceConfirm => '等待另一臺設備確認...';

  @override
  String get securityVerificationSuccess => '驗證成功！';

  @override
  String get securityDeviceVerifiedTrusted => '此設備已驗證並可信任。';

  @override
  String get securityCompareEmoji => '比較兩臺設備上的表情符號';

  @override
  String get securityCompareNumbers => '比較兩臺設備上的數字';

  @override
  String get commonTryAgain => '重試';

  @override
  String get commonDone => '完成';

  @override
  String get chatExportTitle => '導出聊天記錄';

  @override
  String get chatExportSuccess => '導出成功';

  @override
  String chatExportFailed(String error) {
    return '導出失敗: $error';
  }

  @override
  String get chatExportFormat => '導出格式';

  @override
  String get chatExportHtmlDesc => '可在任何瀏覽器中打開的精美排版';

  @override
  String get chatExportJsonDesc => '機器可讀的結構化數據格式';

  @override
  String get chatExportDateRange => '日期範圍';

  @override
  String get chatExportAll => '全部消息';

  @override
  String get chatExportLastWeek => '最近7天';

  @override
  String get chatExportLastMonth => '最近一個月';

  @override
  String get chatExportLast3Months => '最近三個月';

  @override
  String get chatExportMessageCount => '待導出消息';

  @override
  String get chatExportButton => '導出並分享';

  @override
  String get chatMediaGallery => '媒體文件';

  @override
  String get chatExportHistory => '導出聊天記錄';

  @override
  String get pdfLoadFailed => '加載 PDF 失敗';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => '全部';

  @override
  String get mediaImages => '圖片';

  @override
  String get mediaVideos => '視頻';

  @override
  String get mediaFiles => '文件';

  @override
  String get mediaAudio => '音頻';

  @override
  String mediaItemsCount(int count) {
    return '$count 項';
  }

  @override
  String get mediaNoMediaFound => '暫無媒體文件';

  @override
  String get spacesTitle => '社區';

  @override
  String get spacesCreate => '創建社區';

  @override
  String get spacesJoined => '已加入';

  @override
  String get spacesDiscover => '發現';

  @override
  String get spacesNoJoined => '還沒有加入任何社區';

  @override
  String get spacesExplore => '探索社區';

  @override
  String get spacesNoPublic => '沒有找到公共社區';

  @override
  String get spacesJoin => '加入';

  @override
  String get spacesSubSpaces => '子社區';

  @override
  String get spacesChannels => '頻道';

  @override
  String spacesMembersCount(int count) {
    return '$count 位成員';
  }

  @override
  String get spacesPublic => '公開';

  @override
  String get spacesPrivate => '私密';

  @override
  String get spacesSuggested => '推薦';

  @override
  String spacesChannelsCount(int count) {
    return '$count 個頻道';
  }

  @override
  String get callInCallChat => '通話中聊天';

  @override
  String callMessagesCount(int count) {
    return '$count 條消息';
  }

  @override
  String get callNoMessagesYet => '暫無消息\n發送一條消息開始聊天';

  @override
  String get callTypeMessage => '輸入消息...';

  @override
  String get callYouSender => '我';

  @override
  String get callChatLabel => '聊天';

  @override
  String get chatEdited => '已編輯';

  @override
  String get chatEditHistory => '編輯歷史';

  @override
  String get chatOriginalMessage => '原始消息';

  @override
  String chatEditedAt(String time) {
    return '編輯於 $time';
  }

  @override
  String get chatViewOnce => '閱後即焚';

  @override
  String get chatViewOncePhoto => '閱後即焚照片';

  @override
  String get chatViewOnceVideo => '閱後即焚視頻';

  @override
  String get chatViewOnceViewed => '已查看';

  @override
  String get chatViewOnceExpired => '已過期';

  @override
  String get chatViewOnceTap => '點擊查看';

  @override
  String get chatAutoFaceBlur => '自動模糊人臉';

  @override
  String get chatAutoFaceBlurDesc => '發送照片時自動模糊人臉';

  @override
  String get threadReplyInThread => '在線程中回覆';

  @override
  String threadReplies(int count) {
    return '$count 條回覆';
  }

  @override
  String get threadReply => '1 條回覆';

  @override
  String threadLatestReply(String preview) {
    return '最新: $preview';
  }

  @override
  String get threadTitle => '消息線程';

  @override
  String get threadReplyPlaceholder => '在線程中回覆...';

  @override
  String threadParticipants(int count) {
    return '$count 位參與者';
  }

  @override
  String get voiceRoomTitle => '語音聊天室';

  @override
  String get voiceRoomCreate => '創建語音房間';

  @override
  String get voiceRoomJoin => '加入';

  @override
  String get voiceRoomLeave => '離開';

  @override
  String get voiceRoomEnd => '結束房間';

  @override
  String get voiceRoomRaiseHand => '舉手';

  @override
  String get voiceRoomLowerHand => '放下手';

  @override
  String get voiceRoomMute => '靜音';

  @override
  String get voiceRoomUnmute => '取消靜音';

  @override
  String get voiceRoomHost => '主持人';

  @override
  String get voiceRoomSpeakers => '發言者';

  @override
  String get voiceRoomListeners => '聽衆';

  @override
  String get voiceRoomLive => '直播中';

  @override
  String get voiceRoomEnded => '已結束';

  @override
  String get voiceRoomScheduled => '已預約';

  @override
  String get voiceRoomApprove => '批准發言';

  @override
  String get voiceRoomDemote => '移至聽衆';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name 舉手了';
  }

  @override
  String get voiceRoomName => '房間名稱';

  @override
  String get voiceRoomTopic => '話題（可選）';

  @override
  String get voiceRoomNoActive => '暫無活躍的語音房間';

  @override
  String get voiceRoomConnecting => '連接中...';

  @override
  String get usernameTitle => '用戶名';

  @override
  String get usernameSet => '設置用戶名';

  @override
  String get usernameChange => '修改用戶名';

  @override
  String get usernamePlaceholder => '輸入用戶名';

  @override
  String get usernameAvailable => '用戶名可用';

  @override
  String get usernameUnavailable => '用戶名已被佔用';

  @override
  String get usernameInvalid => '3-30個字符，小寫字母、數字、下劃線，必須以字母開頭';

  @override
  String get usernameReserved => '此用戶名爲保留名稱';

  @override
  String get usernameSaved => '用戶名已保存';

  @override
  String get usernameSearchHint => '通過 @用戶名 搜索';

  @override
  String get ensName => 'ENS 域名';

  @override
  String get ensLinked => '已關聯 ENS';

  @override
  String get ensResolving => '正在解析 ENS...';

  @override
  String get ensNotFound => '未找到 ENS 域名';

  @override
  String get tokenGateTitle => '代幣門控';

  @override
  String get tokenGateEnable => '啓用代幣門控';

  @override
  String get tokenGateDisable => '禁用代幣門控';

  @override
  String get tokenGateAddRule => '添加規則';

  @override
  String get tokenGateRemoveRule => '刪除規則';

  @override
  String get tokenGateContractAddress => '合約地址';

  @override
  String get tokenGateMinBalance => '最低餘額';

  @override
  String get tokenGateTokenId => 'Token ID (ERC-1155)';

  @override
  String get tokenGateChainId => '鏈 ID';

  @override
  String get tokenGateVerifying => '正在驗證代幣持有...';

  @override
  String get tokenGateVerified => '驗證通過';

  @override
  String get tokenGateDenied => '您未滿足代幣要求';

  @override
  String get tokenGateOperatorAnd => '需滿足所有規則';

  @override
  String get tokenGateOperatorOr => '滿足任一規則即可';

  @override
  String get tokenGateRuleErc20 => 'ERC-20 代幣';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => '多代幣 (ERC-1155)';

  @override
  String get tokenGateRuleNative => '原生代幣';

  @override
  String get tokenGateSaved => '代幣門控已保存';

  @override
  String get tokenGateEnableDescription => '要求成員持有指定代幣才能加入';

  @override
  String get tokenGateOperator => '規則邏輯';

  @override
  String get tokenGateRules => '規則列表';

  @override
  String get tokenGateSymbol => '代幣符號（可選）';

  @override
  String get tokenGateChain => '區塊鏈';

  @override
  String get tokenGateTokenStandard => '代幣標準';

  @override
  String get tokenGateDenialMessage => '拒絕消息';

  @override
  String get tokenGateDenialMessageHint => '驗證失敗時顯示的消息';

  @override
  String get tokenGateVerifyTitle => '代幣驗證';

  @override
  String get tokenGateVerifyPassed => '驗證通過';

  @override
  String get tokenGateVerifyFailed => '驗證未通過';

  @override
  String get tokenGateRetryVerify => '重新驗證';

  @override
  String get tokenGateRequired => '要求';

  @override
  String get tokenGateYourBalance => '你的餘額';

  @override
  String get tokenGateRulesActive => '條規則生效';

  @override
  String get tokenGateDisabled => '未啓用';

  @override
  String get ensNotBound => '未綁定';

  @override
  String get liveLocation => '實時位置';

  @override
  String get stopLiveLocation => '停止共享';

  @override
  String get startLiveLocation => '開始共享';

  @override
  String get selectDuration => '選擇共享時長';

  @override
  String get groupChatFiles => '聊天文件';

  @override
  String get groupLinks => '鏈接';

  @override
  String get groupNoLinks => '暫無鏈接';

  @override
  String get chatBackground => '聊天背景';

  @override
  String get solidColors => '純色';

  @override
  String get gradients => '漸變';

  @override
  String get defaultBackground => '默認';

  @override
  String get settingsFontSizeSlider => '字體大小';

  @override
  String get autoDownload => '自動下載';

  @override
  String get images => '圖片';

  @override
  String get voice => '語音';

  @override
  String get video => '視頻';

  @override
  String get files => '文件';

  @override
  String get mobileData => '移動數據';

  @override
  String get roaming => '漫遊';

  @override
  String get storageManagement => '存儲管理';

  @override
  String get totalUsage => '總用量';

  @override
  String get cache => '緩存';

  @override
  String get other => '其他';

  @override
  String get clearCache => '清理緩存';

  @override
  String get cacheCleared => '緩存已清除';

  @override
  String get clearCacheFailed => '清理緩存失敗';

  @override
  String get confirmClearCache => '確認清理所有緩存數據？';

  @override
  String get mapView => '地圖視圖';

  @override
  String liveLocationSharingCount(int count) {
    return '$count 人正在共享位置';
  }

  @override
  String get minutes15 => '15 分鐘';

  @override
  String get minutes30 => '30 分鐘';

  @override
  String get hour1 => '1 小時';

  @override
  String get hours8 => '8 小時';

  @override
  String get personalCard => '個人名片';

  @override
  String get downloadFailed => '下載失敗';

  @override
  String get locationExpired => '已過期';

  @override
  String secondsRemaining(int count) {
    return '$count秒';
  }

  @override
  String minutesRemaining(int count) {
    return '$count分鐘';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours小時$minutes分鐘';
  }

  @override
  String get favoriteMessages => '收藏消息';

  @override
  String get linksCopied => '鏈接已複製';

  @override
  String get noLinksFound => '未找到鏈接';

  @override
  String get roomStorageRanking => '房間存儲排行';

  @override
  String get downloadComplete => '下載完成';

  @override
  String get downloading => '下載中...';

  @override
  String get draftSaved => '草稿已保存';

  @override
  String get voiceRecording => '語音錄製';

  @override
  String get searchLocation => '搜索地點';

  @override
  String get tapToSearch => '點擊搜索';

  @override
  String get settingsThisDevice => '本設備';

  @override
  String get settingsJustNow => '剛剛';

  @override
  String get settingsDeviceId => '設備 ID';

  @override
  String get settingsStatus => '狀態';

  @override
  String get settingsLastActive => '最後活躍';

  @override
  String get settingsIpAddress => 'IP 地址';

  @override
  String get settingsRenameDevice => '重命名設備';

  @override
  String get settingsDeviceNameHint => '輸入設備名稱';

  @override
  String get settingsDeviceRenamed => '設備已重命名';

  @override
  String get settingsRenameFailed => '重命名失敗';

  @override
  String get settingsRemoteLogout => '遠程登出';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return '確定要登出「$deviceName」嗎？此操作無法撤銷。';
  }

  @override
  String get settingsDeviceLoggedOut => '設備已登出';

  @override
  String get settingsLogoutFailed => '登出失敗';

  @override
  String get settingsLogout => '登出';

  @override
  String get settingsVerifyIdentity => '驗證身份';

  @override
  String get settingsEnterPasswordToConfirm => '請輸入密碼以確認此操作。';

  @override
  String get scheduledSendTitle => '定時發送';

  @override
  String get scheduledSendInOneHour => '1小時後';

  @override
  String get scheduledSendTonight => '今晚 (20:00)';

  @override
  String get scheduledSendTomorrowMorning => '明早 (9:00)';

  @override
  String get scheduledSendCustom => '自定義時間';

  @override
  String get scheduledMessageLabel => '定時發送';

  @override
  String get scheduledMessageCancel => '取消定時發送';

  @override
  String get chatLockTitle => '聊天鎖';

  @override
  String get chatLockEnable => '鎖定此聊天';

  @override
  String get chatLockDisable => '解鎖此聊天';

  @override
  String get chatLockDescription => '鎖定的聊天需要通過生物識別或 PIN 碼驗證才能打開';

  @override
  String get chatLockVerifyTitle => '聊天已鎖定';

  @override
  String get chatLockVerifySubtitle => '驗證後訪問此聊天';

  @override
  String get chatLockVerifyFailed => '驗證失敗';

  @override
  String get chatLockEnabled => '聊天已鎖定';

  @override
  String get chatLockDisabled => '聊天已解鎖';

  @override
  String get chatLockPinTitle => '輸入 PIN 碼';

  @override
  String get chatLockPinSetTitle => '設置 PIN 碼';

  @override
  String get chatLockPinConfirmTitle => '確認 PIN 碼';

  @override
  String get chatLockPinMismatch => 'PIN 碼不一致';

  @override
  String get chatLockUseBiometric => '使用生物識別';

  @override
  String get chatLockUsePin => '使用 PIN 碼';

  @override
  String get mediaEditorUndo => '撤銷';

  @override
  String get mediaEditorRedo => '重做';

  @override
  String get mediaEditorCrop => '裁剪';

  @override
  String get mediaEditorFilter => '濾鏡';

  @override
  String get mediaEditorDraw => '塗鴉';

  @override
  String get mediaEditorText => '文字';

  @override
  String get aiAssistant => 'AI 助手';

  @override
  String get aiAssistantWelcome => '你好！我是 N42 AI 助手，有什麼可以幫你的嗎？';

  @override
  String get aiAssistantNotConfigured => 'AI 服務未配置';

  @override
  String get aiAssistantSettings => 'AI 設置';

  @override
  String get aiAssistantClearHistory => '清空對話歷史';

  @override
  String get aiAssistantClearHistoryConfirm => '確定清空所有 AI 對話歷史？';

  @override
  String get aiAssistantStopGenerating => '停止生成';

  @override
  String get aiAssistantModel => '模型';

  @override
  String get aiAssistantTemperature => '溫度';

  @override
  String get aiAssistantMaxTokens => '最大令牌數';

  @override
  String get aiAssistantContextWindow => '上下文窗口';

  @override
  String get aiAssistantServiceStatus => '服務狀態';

  @override
  String get aiAssistantAvailable => '可用';

  @override
  String get aiAssistantUnavailable => '不可用';

  @override
  String get aiSummarize => 'AI 總結';

  @override
  String aiSummarizeUnread(int count) {
    return 'AI 總結 $count 條未讀消息';
  }

  @override
  String get aiSummarizeLoading => '正在總結...';

  @override
  String get aiSummarizeError => '總結失敗';

  @override
  String get aiRewrite => 'AI 改寫';

  @override
  String get aiRewriteFormal => '正式';

  @override
  String get aiRewriteCasual => '輕鬆';

  @override
  String get aiRewritePlayful => '俏皮';

  @override
  String get aiRewriteProfessional => '專業';

  @override
  String get aiRewriteAccept => '使用';

  @override
  String get aiRewriteCancel => '取消';

  @override
  String get aiRewriteLoading => '正在改寫...';

  @override
  String get aiLinkSummary => 'AI 摘要';

  @override
  String get aiLinkSummaryAnalyzing => '正在分析...';

  @override
  String get chatFolderManagement => '管理文件夾';

  @override
  String get chatFolderSystem => '系統文件夾';

  @override
  String get chatFolderCustom => '自定義文件夾';

  @override
  String get chatFolderEmpty => '暫無自定義文件夾';

  @override
  String get chatFolderCreate => '創建文件夾';

  @override
  String get chatFolderEdit => '編輯文件夾';

  @override
  String get chatFolderNameHint => '文件夾名稱';

  @override
  String get chatFolderAll => '全部';

  @override
  String get chatFolderUnread => '未讀';

  @override
  String get chatFolderPersonal => '私聊';

  @override
  String get chatFolderGroups => '羣組';

  @override
  String get chatFolderChannels => '頻道';

  @override
  String get chatFolderMuted => '已靜音';

  @override
  String get storyAddMusic => '添加音樂';

  @override
  String get storyChangeMusic => '更換音樂';

  @override
  String get storyBackgroundMusic => '背景音樂';

  @override
  String get storyMusicPreview => '預覽 (最長15秒)';

  @override
  String get storyChooseFromDevice => '從設備選擇';

  @override
  String get storyUseThisMusic => '使用此音樂';

  @override
  String get authPasskeyNotSupported => '此設備不支持 Passkey';

  @override
  String get authPasskeyRegister => '註冊 Passkey';

  @override
  String get authPasskeyNoRegistered => '未註冊 Passkey';

  @override
  String get authPasskeyRegisterHint => '爲當前賬號註冊 Passkey，獨立 Passkey 登錄入口後續開放。';

  @override
  String get authPasskeyNameYours => '爲 Passkey 命名';

  @override
  String get authPasskeyRegistered => 'Passkey 已保存到當前賬號';

  @override
  String get authPasskeyDeleted => 'Passkey 已從當前賬號移除';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return '刪除 Passkey \"$name\"？如需後續使用 Passkey 登錄，需要重新註冊。';
  }

  @override
  String get momentVisibilityPublic => '公開';

  @override
  String get momentVisibilityPrivate => '私密';

  @override
  String get momentVisibilityPartial => '部分可見';

  @override
  String get momentVisibilityExcluded => '不給誰看';

  @override
  String momentUserMoments(String userName) {
    return '$userName的朋友圈';
  }

  @override
  String get momentForwardTo => '轉發給';

  @override
  String get momentForwardSuccess => '轉發成功';

  @override
  String get momentSelectFriends => '選擇好友';

  @override
  String get momentSelectTags => '按標籤選擇';

  @override
  String momentSelectedCount(int count) {
    return '已選擇 ($count)';
  }

  @override
  String get momentNoMomentsYet => '暫無動態';

  @override
  String get momentForwardMoment => '轉發動態';

  @override
  String get momentAddComment => '寫評論...';

  @override
  String momentForwardContent(String content) {
    return '[朋友圈] $content';
  }

  @override
  String get momentDeleteMoment => '刪除動態';

  @override
  String get momentDeleteConfirm => '確定要刪除這條動態嗎？';

  @override
  String get momentComment => '評論';

  @override
  String get momentWriteComment => '寫評論...';

  @override
  String get momentLike => '贊';

  @override
  String get momentUnlike => '取消';

  @override
  String get momentForward => '轉發';

  @override
  String get momentDelete => '刪除';

  @override
  String get momentReply => '回覆';

  @override
  String get momentMoment => '動態';

  @override
  String momentLikesCount(int count) {
    return '$count 個贊';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count 條評論';
  }

  @override
  String get momentNoComments => '暫無評論';

  @override
  String get momentFailedToLoad => '圖片加載失敗';

  @override
  String momentReplyTo(String userName) {
    return '回覆 $userName...';
  }

  @override
  String get momentNoConversations => '暫無會話';

  @override
  String get momentJustNow => '剛剛';

  @override
  String momentMinutesAgo(int count) {
    return '$count分鐘前';
  }

  @override
  String momentHoursAgo(int count) {
    return '$count小時前';
  }

  @override
  String momentDaysAgo(int count) {
    return '$count天前';
  }

  @override
  String get chatGroupAnnouncementHint => '輸入羣公告';

  @override
  String get chatGroupAnnouncementEmpty => '暫無羣公告';

  @override
  String get chatEditNickname => '編輯羣暱稱';

  @override
  String get chatNicknameHint => '輸入你在羣裏的暱稱';

  @override
  String get contactAddPhoneHint => '輸入電話號碼';

  @override
  String get contactNotesHint => '添加聯繫人備忘';

  @override
  String get reportTitle => '投訴';

  @override
  String get reportReasonSpam => '垃圾信息';

  @override
  String get reportReasonHarassment => '騷擾';

  @override
  String get reportReasonFraud => '欺詐';

  @override
  String get reportReasonOther => '其他';

  @override
  String get reportSubmitted => '投訴已提交';

  @override
  String get reportDescription => '補充說明（選填）';

  @override
  String get qrcodeSaved => '二維碼已保存到相冊';

  @override
  String get chatSendRedPacketInChat => '請在聊天中發送紅包';

  @override
  String get commonSaveFailed => '保存失敗';

  @override
  String get reportSelectReason => '請選擇投訴原因';

  @override
  String get gameCenter => '遊戲中心';

  @override
  String get gameHighScore => '最高分';

  @override
  String get gameScore => '分數';

  @override
  String get gameOver => '遊戲結束';

  @override
  String get gamePlayAgain => '再來一局';

  @override
  String get gameLeaderboard => '排行榜';

  @override
  String get gamePause => '暫停';

  @override
  String get gameResume => '點擊繼續';

  @override
  String get gameConfirmExit => '確定退出遊戲？';

  @override
  String get gameNoScores => '暫無記錄';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => '合併數字到 2048';

  @override
  String get gameBlockDrop => '方塊消除';

  @override
  String get gameBlockDropDesc => '消除方塊行';

  @override
  String get gameMinesweeper => '掃雷';

  @override
  String get gameMinesweeperDesc => '找出所有安全格';

  @override
  String get gameMatch3 => '消消樂';

  @override
  String get gameMatch3Desc => '連接3個以上寶石';

  @override
  String get gameMinesweeperEasy => '初級';

  @override
  String get gameMinesweeperMedium => '中級';

  @override
  String get gameMinesLeft => '剩餘雷數';

  @override
  String get gameTimeLeft => '時間';

  @override
  String get gameLevel => '等級';

  @override
  String get gameNext => '下一個';

  @override
  String get gameBestTime => '最佳用時';

  @override
  String get gameNewRecord => '新紀錄！';

  @override
  String get gameLines => '行數';

  @override
  String get storyMyStory => '我的動態';

  @override
  String get storageSmartCleanup => '智能清理';

  @override
  String get storageOldMediaFiles => '舊媒體文件';

  @override
  String get storageLargeFiles => '大文件';

  @override
  String get storageAppCache => '應用緩存';

  @override
  String get storageSettings => '存儲設置';

  @override
  String get storageAutoCleanup => '自動清理';

  @override
  String storageAutoCleanupDesc(int days) {
    return '自動清理 $days 天以上未訪問的文件';
  }

  @override
  String get storageCleanupPeriod => '清理週期';

  @override
  String get storagePreserveThumbnails => '保留縮略圖';

  @override
  String get storagePreserveThumbnailsDesc => '清理時保留圖片縮略圖';

  @override
  String get storageWarningHigh => '存儲空間較高，建議清理舊文件。';

  @override
  String get storageWarningCritical => '存儲空間嚴重不足，請立即清理。';

  @override
  String storageFreed(String size, int count) {
    return '已釋放 $size（$count 個文件）';
  }

  @override
  String storageDays(int days) {
    return '$days 天';
  }

  @override
  String storageViewAllRooms(int count) {
    return '查看全部 $count 個房間';
  }

  @override
  String get storageNoFiles => '暫無文件';

  @override
  String get storageFilePinned => '已保留';

  @override
  String storageDeleteSelected(int count) {
    return '刪除 $count 個選中文件？文件可從服務器重新下載。';
  }

  @override
  String get backupRestore => '備份與恢復';

  @override
  String get backupCreate => '創建備份';

  @override
  String get backupCreateDesc => '備份設置和加密密鑰。消息將在重新登錄後從服務器恢復。';

  @override
  String get backupIncludeKeys => '包含加密密鑰';

  @override
  String get backupIncludeKeysDesc => '讀取加密消息所必需';

  @override
  String get backupPasswordProtect => '密碼保護';

  @override
  String get backupEnterPassword => '輸入備份密碼';

  @override
  String get backupHistory => '備份歷史';

  @override
  String get backupNoBackups => '暫無備份';

  @override
  String get backupRestore2 => '恢復';

  @override
  String get backupDelete => '刪除';

  @override
  String get backupDeleteConfirm => '確定刪除此備份？此操作不可撤銷。';

  @override
  String get backupRestoreFromFile => '從文件恢復';

  @override
  String get backupRestoreFromFileDesc => '導入來自其他設備或之前備份的 .n42backup 文件。';

  @override
  String get backupChooseFile => '選擇備份文件';

  @override
  String get backupRestoring => '恢復中...';

  @override
  String backupCreated(int rooms, int messages) {
    return '備份已創建：$rooms 個房間，$messages 條消息';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return '已恢復 $settings 項設置（來自 $rooms 個房間）';
  }

  @override
  String backupFailed(String error) {
    return '備份失敗：$error';
  }

  @override
  String get backupPasswordRequired => '此備份需要密碼';

  @override
  String get blocGroupNotFound => '羣組未找到';

  @override
  String blocGroupMembersInvited(int count) {
    return '已邀請$count位成員';
  }

  @override
  String get blocGroupMemberRemoved => '成員已移除';

  @override
  String get blocGroupAdminRemoved => '已取消管理員';

  @override
  String get blocGroupLeft => '已退出羣聊';

  @override
  String get blocGroupDisbanded => '羣聊已解散';

  @override
  String get blocGroupJoined => '已加入羣聊';

  @override
  String get blocGroupInviteDeclined => '已拒絕邀請';

  @override
  String get blocGroupTokenGateUpdated => 'Token 門檻已更新';

  @override
  String get blocTransferProcessing => '轉賬處理中...';

  @override
  String get blocTransferCancelled => '轉賬已取消';

  @override
  String get blocTransferFailed => '轉賬失敗';

  @override
  String get blocPaymentProcessing => '支付處理中...';

  @override
  String get blocPaymentFailed => '支付失敗';

  @override
  String get groupMaxMembers => '羣人數上限';

  @override
  String get groupMaxMembersUnlimited => '不限';

  @override
  String get groupMaxMembersHint => '輸入上限（留空表示不限）';

  @override
  String get groupMaxMembersUpdated => '羣人數上限已更新';

  @override
  String get groupFull => '羣已滿員';

  @override
  String get groupChannels => '話題頻道';

  @override
  String get groupChannelsEmpty => '暫無話題頻道';

  @override
  String get groupChannelsCount => '個頻道';

  @override
  String get groupChannelCreate => '新建頻道';

  @override
  String get groupChannelName => '頻道名稱';

  @override
  String get groupChannelTopic => '頻道話題（可選）';

  @override
  String get groupChannelDelete => '刪除頻道';

  @override
  String get groupChannelDeleteConfirm => '確認刪除此頻道？消息不可恢復。';

  @override
  String get groupBotSettings => 'Bot 設置';

  @override
  String get groupBotEnabled => '啓用 Bot';

  @override
  String get groupBotWelcomeMessage => '歡迎語模板';

  @override
  String get groupBotWelcomeHint => '用 \'name\' 作爲新成員名字佔位符';

  @override
  String get groupBotConfigUpdated => 'Bot 設置已更新';

  @override
  String get groupContentFilter => '關鍵詞過濾';

  @override
  String get groupContentFilterEnabled => '啓用關鍵詞過濾';

  @override
  String get groupContentFilterReplace => '替換爲 ***';

  @override
  String get groupContentFilterHide => '隱藏消息';

  @override
  String get groupContentFilterAddWord => '添加關鍵詞';

  @override
  String get groupContentFilterUpdated => '內容過濾設置已更新';

  @override
  String get chatSlashCommands => '指令';

  @override
  String get chatCommandPoll => '/poll — 創建投票';

  @override
  String get chatCommandAnnounce => '/announce — 發佈公告';

  @override
  String get chatCommandWelcome => '/welcome — 設置歡迎語';

  @override
  String get chatReportMessage => '舉報';

  @override
  String get chatReportReason => '舉報原因';

  @override
  String get chatReportSpam => '垃圾信息';

  @override
  String get chatReportHarassment => '騷擾';

  @override
  String get chatReportInappropriate => '違規內容';

  @override
  String get chatReportOther => '其他';

  @override
  String get chatReportSuccess => '舉報已提交';

  @override
  String get spacesName => '社區名稱';

  @override
  String get spacesNameHint => '例如：加密交易者';

  @override
  String get spacesNameRequired => '請輸入社區名稱';

  @override
  String get spacesDescription => '簡介';

  @override
  String get spacesDescriptionHint => '介紹一下這個社區';

  @override
  String get spacesType => '社區類型';

  @override
  String get spacesPublicDesc => '任何人均可發現並加入';

  @override
  String get spacesPrivateDesc => '僅受邀成員可加入';

  @override
  String get spacesNotFound => '社區不存在';

  @override
  String get spacesSearch => '搜索社區...';

  @override
  String get spacesMembers => '成員';

  @override
  String get spacesNoChannels => '暫無頻道';

  @override
  String get spacesLeave => '退出社區';

  @override
  String spacesLeaveConfirm(String name) {
    return '確定要退出「$name」嗎？';
  }

  @override
  String get spacesDelete => '解散社區';

  @override
  String spacesDeleteConfirm(String name) {
    return '此操作將永久刪除「$name」及其所有頻道，且不可撤銷。';
  }

  @override
  String get spacesCreateChannel => '創建頻道';

  @override
  String get spacesChannelName => '頻道名稱';

  @override
  String get spacesChannelTopic => '話題（可選）';

  @override
  String get spacesDeleteChannel => '刪除頻道';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return '確定要刪除頻道「#$name」嗎？';
  }

  @override
  String get spacesEditName => '修改名稱';

  @override
  String get spacesEditDescription => '修改簡介';

  @override
  String spacesViewAllMembers(int count) {
    return '查看全部 $count 位成員';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return '踢出 $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return '封禁 $name';
  }

  @override
  String get spacesPromoteAdmin => '設爲管理員';

  @override
  String get spacesDemoteAdmin => '撤銷管理員';

  @override
  String get spacesInviteMember => '邀請成員';

  @override
  String get spacesInviteMemberUserId => '用戶 ID（如 @user:server.com）';

  @override
  String get spacesSave => '保存';

  @override
  String get settingsScreenshotProtection => '截圖防護';

  @override
  String get settingsScreenshotProtectionDesc => '防止截圖和屏幕錄製';

  @override
  String get chatSelfDestructTimer => '閱後即焚';

  @override
  String get chatTimerPickerTitle => '設置閱後即焚時間';

  @override
  String get chatTimerOff => '關閉';

  @override
  String get onChainNotificationsTitle => '鏈上事件';

  @override
  String get onChainMarkAllRead => '全部已讀';

  @override
  String get onChainNoNotifications => '暫無鏈上事件';

  @override
  String get onChainNoNotificationsDesc => '來自訂閱頻道的事件通知將在此顯示';

  @override
  String get onChainViewDetails => '查看詳情';

  @override
  String get chatCommandHelp => '/help — 查看所有命令';

  @override
  String get chatCommandPrice => '/price — 查詢代幣價格';

  @override
  String get chatCommandBalance => '/balance — 查看錢包餘額';

  @override
  String get chatCommandChains => '/chains — 查看 236+ 條支持鏈';

  @override
  String get chatMiniApps => '應用';

  @override
  String get miniAppMarketTitle => '小程序';

  @override
  String get miniAppCategoryAll => '全部';

  @override
  String get miniAppSearch => '搜索應用...';

  @override
  String get miniAppFeatured => '精選';

  @override
  String get miniAppAllApps => '全部應用';

  @override
  String get miniAppNoResults => '未找到應用';

  @override
  String get slideToPayLabel => '→→→  滑動確認';

  @override
  String get slideToPayConfirming => '確認中...';

  @override
  String get redPacketBestLuck => '最佳手氣';

  @override
  String get redPacketBestLuckCongrats => '最佳手氣！你搶到了最多！';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total 個已領取';
  }

  @override
  String get redPacketStatsTotal => '共計';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 搶到了紅包 • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id  •  0x 錢包地址  •  name.eth';

  @override
  String get web3SearchPlaceholder => '搜索 ID、錢包地址或 ENS...';

  @override
  String get web3WalletAddress => '錢包地址';

  @override
  String get web3AddressCopied => '地址已複製';

  @override
  String get web3Copy => '複製';

  @override
  String get web3SendMessage => '發消息';

  @override
  String get web3SendToWallet => '發送到錢包';

  @override
  String get web3WalletOnlyHint => '該地址尚無 N42 賬號。對方加入後消息將自動送達。';

  @override
  String get web3NftAvatar => 'NFT 頭像';

  @override
  String get web3ResolveFailed => '身份解析失敗';

  @override
  String web3EnsNotFound(String name) {
    return 'ENS 名稱“$name”未找到';
  }

  @override
  String get web3NoN42AccountTitle => '無 N42 賬號';

  @override
  String get web3NoN42AccountDesc => '該錢包地址尚無 N42 賬號。您可以分享 N42 邀請鏈接邀請對方加入。';

  @override
  String get web3ShareInvite => '分享邀請';

  @override
  String get nftPickerTitle => '選擇 NFT 頭像';

  @override
  String get nftPickerTabPopular => '熱門';

  @override
  String get nftPickerTabCustom => '自定義';

  @override
  String get nftPickerChain => '鏈';

  @override
  String get nftPickerContract => '合約地址';

  @override
  String get nftPickerTokenId => 'Token ID';

  @override
  String get nftPickerVerifyOwnership => '驗證所有權並預覽';

  @override
  String get nftPickerUseAsAvatar => '用作頭像';

  @override
  String get nftPickerPreview => '預覽';

  @override
  String get nftPickerNotOwned => '您不擁有這個 NFT';

  @override
  String get nftPickerInvalidTokenId => '無效的 Token ID';

  @override
  String get nftPickerEnterBoth => '請輸入合約地址和 Token ID';

  @override
  String get nftPickerInfoTitle => 'NFT 頭像 — 鏈上身份驗證';

  @override
  String get nftPickerInfoDesc =>
      '綁定您持有的 NFT 作爲頭像。任何人均可在鏈上驗證歸屬權。在 N42 全應用中以金色邊框標識。';

  @override
  String get nftPickerPopularCollections => '熱門 NFT 項目';

  @override
  String get nftPickerWalletHint => '連接 N42 錢包，自動發現您在 236+ 條鏈上持有的 NFT。';

  @override
  String get profileBindNftAvatar => '綁定 NFT 頭像';

  @override
  String get profileChangeAvatar => '更換頭像';

  @override
  String get groupTopics => '羣話題';

  @override
  String get groupTopicsEmpty => '暫無話題';

  @override
  String get syncInProgress => '正在同步歷史消息...';

  @override
  String get recoveryKeyReminderTitle => '保護您的消息';

  @override
  String get recoveryKeyReminderDesc => '創建恢復密鑰以在多設備上安全同步加密消息';

  @override
  String get recoveryKeySetupNow => '立即設置';

  @override
  String get recoveryKeyRemindLater => '稍後提醒';

  @override
  String get channelReadOnly => '僅管理員可在此頻道發言';

  @override
  String get channelSubscribers => '訂閱者';

  @override
  String get channelVerified => '已認證頻道';

  @override
  String get redPacketHistory => '紅包記錄';

  @override
  String get redPacketSent => '已發出';

  @override
  String get redPacketReceived => '已收到';

  @override
  String get redPacketExpired => '已過期';

  @override
  String get redPacketClaimed => '已領取';

  @override
  String get redPacketInsufficientBalance => '餘額不足';

  @override
  String selfDestructCountdown(String time) {
    return '$time 後銷燬';
  }

  @override
  String get messageDestroyed => '消息已銷燬';

  @override
  String miniAppPermissionDenied(String permission) {
    return '權限不足：$permission';
  }

  @override
  String get aiSuggestionGasFee => '什麼是 Gas 費？';

  @override
  String get aiSuggestionDefi => 'DeFi 入門';

  @override
  String get aiSuggestionSecurity => '如何檢查合約安全';

  @override
  String get aiSuggestionBridge => '跨鏈橋接';

  @override
  String get channelDiscoverTitle => '發現頻道';

  @override
  String get channelDiscoverSearch => '搜索頻道...';

  @override
  String get channelJoin => '加入';

  @override
  String get channelJoined => '已加入';

  @override
  String get channelCategory => '分類';

  @override
  String slowModeCooldown(int seconds) {
    return '慢速模式：請等待 $seconds 秒';
  }

  @override
  String get addressCopyAction => '複製地址';

  @override
  String get addressSendMessage => '發消息';

  @override
  String get addressViewProfile => '查看資料';

  @override
  String get sendToAddress => '通過錢包地址發消息';

  @override
  String get blocAuthSendVerificationCodeFailed => '發送驗證碼失敗';

  @override
  String get blocAuthServerNoEmailPasswordReset => '該服務器不支持通過郵箱重置密碼';

  @override
  String get blocAuthResetPasswordFailed => '重置密碼失敗';

  @override
  String get blocAuthChangePasswordFailed => '修改密碼失敗';

  @override
  String get blocAuthOldPasswordWrong => '原密碼錯誤';

  @override
  String get blocAuthLoginCancelled => '登錄已取消';

  @override
  String get blocAuthGoogleLoginFailed => 'Google 登錄失敗';

  @override
  String get blocAuthAppleLoginFailed => 'Apple 登錄失敗';

  @override
  String get blocAuthSsoLoginFailed => 'SSO 登錄失敗';

  @override
  String get blocAuthFacebookLoginFailed => 'Facebook 登錄失敗';

  @override
  String get blocAuthTwitterLoginFailed => 'Twitter 登錄失敗';

  @override
  String get blocAuthWeChatLoginFailed => '微信登錄失敗';

  @override
  String get blocAuthWeChatNotConfigured => '微信登錄未配置';

  @override
  String get blocAuthWeChatNotInstalled => '請先安裝微信';

  @override
  String get blocAuthPasswordWrong => '密碼錯誤';

  @override
  String get blocAuthEmailAlreadyBound => '該郵箱已被其他賬號綁定';

  @override
  String get blocAuthChangeEmailFailed => '修改郵箱失敗';

  @override
  String get blocAuthVerificationCodeInvalid => '驗證碼錯誤或已過期';

  @override
  String get blocAuthSessionExpired => '會話已失效，請重新登錄';

  @override
  String get blocAuthSessionIncomplete => '會話數據不完整，請重新登錄';
}

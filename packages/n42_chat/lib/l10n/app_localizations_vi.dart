// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class SVi extends S {
  SVi([String locale = 'vi']) : super(locale);

  @override
  String get commonRetry => 'Thu lai';

  @override
  String get commonUnknownUser => 'Nguoi dung khong xac dinh';

  @override
  String get transferWalletNotConnected => 'Vi chua ket noi';

  @override
  String get chatCallServiceNotInitialized => 'Dich vu goi chua khoi tao';

  @override
  String authLoginFailed(String error) {
    return 'Dang nhap that bai: $error';
  }

  @override
  String get chatCallBack => 'Goi lai';

  @override
  String get chatMissedVideoCall => 'Cuoc goi video nho';

  @override
  String get chatMissedVoiceCall => 'Cuoc goi thoai nho';

  @override
  String get chatCallNotAnswered => 'Không trả lời';

  @override
  String get chatCallDurationLabel => 'Thời lượng cuộc gọi';

  @override
  String get chatVoiceCallCancelled => 'Cuộc gọi thoại đã bị huỷ';

  @override
  String get chatVideoCallCancelled => 'Cuộc gọi video đã bị huỷ';

  @override
  String get commonImage => '[Hinh anh]';

  @override
  String get chatVideo => '[Băng hình]';

  @override
  String get chatVoice => '[Tin nhan thoai]';

  @override
  String get commonFile => '[Tep]';

  @override
  String get chatLocation => '[Vi tri]';

  @override
  String get chatUnknownMessage => '[Tin nhan khong xac dinh]';

  @override
  String get commonDelete => 'Xoa';

  @override
  String get chatDeleteThisMessage => 'Xóa tin nhắn này?';

  @override
  String get chatMessageDeleted => 'Tin nhắn đã xóa';

  @override
  String get profileNotLoggedIn => 'Chua dang nhap';

  @override
  String get chatMyLocation => 'Vi tri cua toi';

  @override
  String get commonGroupChat => 'Chat nhom';

  @override
  String get commonSearch => 'Tim kiem';

  @override
  String get commonCancel => 'Huy';

  @override
  String get commonLoadFailed => 'Tai that bai';

  @override
  String get commonMessages => 'Tin nhan';

  @override
  String get commonContacts => 'Danh ba';

  @override
  String get commonMe => 'Toi';

  @override
  String get commonVoiceLoading =>
      'Dang tai tin nhan thoai, vui long thu lai sau';

  @override
  String get commonVoiceToTextFailed =>
      'Chuyen giong noi thanh van ban that bai';

  @override
  String get commonConvertToText => 'Chuyen thanh van ban';

  @override
  String get chatCopy => 'Sao chep';

  @override
  String get commonForward => 'Chuyen tiep';

  @override
  String get commonUnfavorite => 'Bo yeu thich';

  @override
  String get commonFavorite => 'Yeu thich';

  @override
  String get settingsResend => 'Gui lai';

  @override
  String get chatRecall => 'Thu hoi';

  @override
  String get commonQuote => 'Trich dan';

  @override
  String get commonRemind => 'Nhac nho';

  @override
  String get chatCopied => 'Da sao chep';

  @override
  String get storySendMessageHint => 'Gui tin nhan';

  @override
  String get commonMicrophonePermissionRequired =>
      'Vui long cap quyen truy cap micro';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'Quyền sử dụng micrô đã bị từ chối. Vui lòng kích hoạt nó trong cài đặt hệ thống để sử dụng tin nhắn thoại.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'Bat dau ghi am that bai: $error';
  }

  @override
  String get commonRecordingTooShort => 'Ban ghi qua ngan';

  @override
  String commonStopRecordingFailed(String error) {
    return 'Dung ghi am that bai: $error';
  }

  @override
  String get chatReleaseToCancel => 'Tha de huy';

  @override
  String get chatReleaseToSend => 'Tha de gui, vuot len de huy';

  @override
  String get commonHoldToTalk => 'Giu de noi';

  @override
  String get commonSend => 'Gui';

  @override
  String get commonAddFriend => 'Them ban';

  @override
  String get commonChatServiceNotConnected => 'Dich vu chat chua ket noi';

  @override
  String contactUserNotFoundHint(String query) {
    return 'Khong tim thay nguoi dung \"$query\"\n\nGoi y:\n• Thu nhap day du ID nguoi dung, vi du @username:server.com\n• Kiem tra chinh ta ten nguoi dung';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'Tao cuoc tro chuyen that bai: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'Tim kiem that bai: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'Nhap ID nguoi dung hoac ten dang nhap de tim kiem';

  @override
  String get contactSearching => 'Dang tim kiem...';

  @override
  String get contactSearchUserToChat => 'Tim nguoi dung de bat dau tro chuyen';

  @override
  String get contactMatrixIdExample =>
      'Ban co the nhap day du Matrix ID\nvi du @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'Khong tim thay nguoi dung \"$username\"';
  }

  @override
  String get commonChat => 'Tro chuyen';

  @override
  String get commonSettings => 'Cai dat';

  @override
  String get profileEditProfile => 'Chinh sua ho so';

  @override
  String get authLogin => 'Dang nhap';

  @override
  String get commonCreateGroup => 'Tao nhom';

  @override
  String get chatError => 'Loi';

  @override
  String get commonTransfer => 'Chuyen tien';

  @override
  String get commonReceived => 'Da nhan';

  @override
  String get commonRefunded => 'Da hoan tien';

  @override
  String get commonExpired => 'Het han';

  @override
  String get chatRedPacketGreeting => 'Chuc mung tot lanh';

  @override
  String get commonN42RedPacket => 'Li xi N42';

  @override
  String get commonClaimed => 'Da nhan';

  @override
  String get commonAllClaimed => 'Da nhan het';

  @override
  String get chatReadAloud => 'Đọc to';

  @override
  String get chatReply => 'Tra loi';

  @override
  String get commonEdit => 'Chinh sua';

  @override
  String get chatSelectForwardTarget => 'Chon nguoi nhan';

  @override
  String commonSendCount(int count) {
    return 'Gui ($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'Mã N42: $id';
  }

  @override
  String get profileN42IdTitle => 'Mã số N42';

  @override
  String get profileN42Bean => 'Đậu N42';

  @override
  String get contactFriendInfo => 'Thong tin ban be';

  @override
  String get contactFriendInfoDesc =>
      'Them ghi chu, dien thoai, the, ghi nhan, anh cua ban be va cai dat quyen.';

  @override
  String get commonMoments => 'Khoang khac';

  @override
  String get commonSendMessage => 'Tin nhan';

  @override
  String get contactAudioVideoCall => 'Goi Am thanh/Video';

  @override
  String get contactVideoChannel => 'Kenh Video';

  @override
  String get contactRemark => 'Ghi chu';

  @override
  String get contactRemarkName => 'Ten ghi chu';

  @override
  String get contactPhone => 'Dien thoai';

  @override
  String get contactTags => 'The';

  @override
  String get contactNotes => 'Ghi chu';

  @override
  String get contactPhotos => 'Anh';

  @override
  String get contactPermissions => 'Quyen';

  @override
  String get contactChatMomentsEtc => 'Chat, Khoang khac, The thao, v.v.';

  @override
  String get contactMoreInfo => 'Thong tin them';

  @override
  String get contactCommonGroups => 'Nhom chung';

  @override
  String get contactSource => 'Nguon';

  @override
  String get settingsNotificationSettings => 'Thong bao';

  @override
  String get settingsPrivacy => 'Quyen rieng tu';

  @override
  String get settingsAppearance => 'Giao dien';

  @override
  String get settingsAbout => 'Gioi thieu';

  @override
  String get commonLogout => 'Dang xuat';

  @override
  String get commonLogoutConfirm => 'Ban co chac muon dang xuat?';

  @override
  String get commonSave => 'Luu';

  @override
  String get profileNickname => 'Biet danh';

  @override
  String get profileEnterNickname => 'Nhap biet danh';

  @override
  String get profileSignature => 'Chu ky';

  @override
  String get profileAddSignature => 'Them chu ky';

  @override
  String get commonTakePhoto => 'Chup anh';

  @override
  String get profileChooseFromGallery => 'Chon tu thu vien';

  @override
  String profileSaveFailed(String error) {
    return 'Luu that bai: $error';
  }

  @override
  String get authSecureDecentralizedChat => 'Nhan tin bao mat, phi tap trung';

  @override
  String get commonEndToEndEncryption => 'Ma hoa dau cuoi';

  @override
  String get authMessagesOnlyYouCanSee =>
      'Chi ban va nguoi nhan moi xem duoc tin nhan';

  @override
  String get authDecentralized => 'Phi tap trung';

  @override
  String get authBasedOnMatrix => 'Xay dung tren giao thuc mo Matrix';

  @override
  String get authWalletIntegration => 'Tich hop Vi';

  @override
  String get authEasyCryptoTransfer => 'Chuyen tien dien tu de dang';

  @override
  String get authRegister => 'Dang ky';

  @override
  String get authAgreeTerms => 'Bang viec dang nhap, ban dong y voi';

  @override
  String get authTermsOfService => 'Dieu khoan Dich vu';

  @override
  String get authAnd => 'va';

  @override
  String get authPrivacyPolicy => 'Chinh sach Bao mat';

  @override
  String get authServerAddress => 'Dia chi May chu';

  @override
  String get authEnterServerAddress => 'Nhap dia chi may chu';

  @override
  String authConnectedTo(String serverName) {
    return 'Da ket noi toi $serverName';
  }

  @override
  String get authUsername => 'Ten dang nhap';

  @override
  String get authEnterUsername => 'Nhap ten dang nhap';

  @override
  String get authUsernameOrEmail => 'Ten dang nhap hoac Email';

  @override
  String get authEnterUsernameOrEmail => 'Nhap ten dang nhap hoac email';

  @override
  String get authPassword => 'Mat khau';

  @override
  String get authEnterPassword => 'Nhap mat khau';

  @override
  String get authRegisterAccount => 'Dang ky';

  @override
  String get authForgotPassword => 'Quen mat khau';

  @override
  String get authOtherLoginMethods => 'Phuong thuc dang nhap khac';

  @override
  String get authCreateAccount => 'Tao tai khoan';

  @override
  String get authJoinN42Chat => 'Tham gia N42 Chat de bat dau tro chuyen';

  @override
  String get authUsernameHint => '3-20 ky tu, chu/so/_';

  @override
  String get authUsernameMinLength => 'Ten dang nhap phai co it nhat 3 ky tu';

  @override
  String get authUsernameMaxLength => 'Ten dang nhap toi da 20 ky tu';

  @override
  String get authUsernameFormat =>
      'Ten dang nhap chi co the chua chu, so va dau gach duoi';

  @override
  String get authPasswordHint => 'Toi thieu 8 ky tu';

  @override
  String get commonPasswordMinLength => 'Mat khau phai co it nhat 8 ky tu';

  @override
  String get authConfirmPassword => 'Xac nhan mat khau';

  @override
  String get authFilled => 'Da dien';

  @override
  String get authEnterInviteCode => 'Nhap ma moi';

  @override
  String get authAlreadyHaveAccount => 'Da co tai khoan?';

  @override
  String get authLoginNow => 'Dang nhap ngay';

  @override
  String get profileAvatar => 'Anh dai dien';

  @override
  String get profileStatus => 'Trang thai';

  @override
  String get commonLoading => 'Dang tai...';

  @override
  String get conversationNoConversations => 'Khong co cuoc tro chuyen';

  @override
  String get conversationTapToChat =>
      'Nhan vao goc tren ben phai de bat dau tro chuyen';

  @override
  String get conversationStartGroup => 'Bat dau Chat nhom';

  @override
  String get commonScan => 'Quet';

  @override
  String get commonPayment => 'Thanh toan';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature sap ra mat';
  }

  @override
  String get conversationMarkAsRead => 'Danh dau da doc';

  @override
  String get commonUnmute => 'Bo tat tieng';

  @override
  String get commonMute => 'Tat tieng';

  @override
  String get conversationUnpin => 'Bo ghim';

  @override
  String get conversationPin => 'Ghim';

  @override
  String get conversationDeleteConversation => 'Xoa cuoc tro chuyen';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return 'Xoa cuoc tro chuyen voi \"$name\"?';
  }

  @override
  String get commonNoContacts => 'Khong co lien he';

  @override
  String get contactAddFriendsToChat => 'Them ban de bat dau tro chuyen';

  @override
  String get contactNotFound => 'Khong tim thay lien he';

  @override
  String get contactTryOtherKeywords =>
      'Thu tu khoa khac hoac tim kiem toan cau';

  @override
  String get contactSearchResults => 'Ket qua tim kiem';

  @override
  String get contactNewFriends => 'Ban moi';

  @override
  String get contactChatOnlyFriends => 'Bạn bè chỉ trò chuyện';

  @override
  String get contactOfficialAccounts => 'Tai khoan chinh thuc';

  @override
  String get contactServiceAccounts => 'Tai khoan dich vu';

  @override
  String get contactEnterpriseContacts => 'Lien he doanh nghiep';

  @override
  String get contactRecommendToFriend => 'Chia se lien he';

  @override
  String get commonSetRemark => 'Dat ghi chu';

  @override
  String get contactSendingCard => 'Dang gui the lien he...';

  @override
  String get commonFileLabel => 'Tep';

  @override
  String get commonLocationLabel => 'Vi tri';

  @override
  String contactRecommendFailed(String error) {
    return 'Gioi thieu that bai: $error';
  }

  @override
  String get profileEnterRemark => 'Nhap ghi chu';

  @override
  String get contactOpeningChat => 'Dang mo tro chuyen...';

  @override
  String contactOpenChatFailed(String error) {
    return 'Mo tro chuyen that bai: $error';
  }

  @override
  String get contactAddContact => 'Them lien he';

  @override
  String get contactEnterUserId => 'Nhap ID nguoi dung';

  @override
  String get contactNoFriendRequests => 'Khong co yeu cau ket ban';

  @override
  String get commonAccept => 'Chap nhan';

  @override
  String get commonReject => 'Tu choi';

  @override
  String get commonNoGroups => 'Khong co nhom';

  @override
  String get contactSelectFriendToRecommend => 'Chon ban de gioi thieu';

  @override
  String get commonSearchContacts => 'Tim kiem lien he';

  @override
  String get contactNoContactsFound => 'Khong tim thay lien he';

  @override
  String get favoriteYesterday => 'Hom qua';

  @override
  String get chatJustNow => 'Vua xong';

  @override
  String get profileOnline => 'Truc tuyen';

  @override
  String get profileOffline => 'Ngoai tuyen';

  @override
  String get searchContactsGroupsMessages => 'Tim lien he, nhom, tin nhan';

  @override
  String get searchError => 'Loi tim kiem';

  @override
  String get chatSearchHint => 'Tim lien he, nhom va tin nhan';

  @override
  String get searchHistory => 'Lich su tim kiem';

  @override
  String get commonClear => 'Xoa';

  @override
  String get commonAll => 'Tat ca';

  @override
  String get searchGroups => 'Nhom';

  @override
  String get searchNoResults => 'Khong co ket qua';

  @override
  String commonGroupMembers(int count) {
    return 'Thanh vien ($count)';
  }

  @override
  String get groupMembersTitle => 'Thành viên nhóm';

  @override
  String get groupViewAll => 'Xem tat ca';

  @override
  String get groupOwner => 'Chu so huu';

  @override
  String get groupAdmin => 'Quan tri vien';

  @override
  String get groupInvite => 'Moi';

  @override
  String get commonGroupAnnouncement => 'Thong bao nhom';

  @override
  String get commonNotSet => 'Chua dat';

  @override
  String get groupDescription => 'Mo ta nhom';

  @override
  String get groupPublicGroup => 'Nhom cong khai';

  @override
  String get commonClearChatHistory => 'Xoa lich su tro chuyen';

  @override
  String get commonDissolveGroup => 'Giai tan nhom';

  @override
  String get commonLeaveGroup => 'Roi nhom';

  @override
  String get groupChangeGroupName => 'Doi ten nhom';

  @override
  String get commonEnterGroupName => 'Nhap ten nhom';

  @override
  String get commonConfirm => 'Xac nhan';

  @override
  String get groupEnterGroupDescription => 'Nhap mo ta nhom';

  @override
  String get groupPublish => 'Dang';

  @override
  String get chatClearHistoryConfirm =>
      'Xoa tat ca lich su tro chuyen? Hanh dong nay khong the hoan tac.';

  @override
  String get chatClearAction => 'Xoa';

  @override
  String get commonChatHistoryCleared => 'Da xoa lich su tro chuyen';

  @override
  String get commonDissolve => 'Giai tan';

  @override
  String get groupQrCode => 'Ma QR nhom';

  @override
  String get commonSearchChatHistory => 'Tim kich su tro chuyen';

  @override
  String get groupIdCopied => 'Da sao chep ID nhom';

  @override
  String get transferEnterOrPasteAddress => 'Nhap hoac dan dia chi vi';

  @override
  String get transferSelectToken => 'Chon Token';

  @override
  String get commonTransferAmount => 'So tien chuyen';

  @override
  String get transferAvailable => 'Kha dung';

  @override
  String get transferMemoOptional => 'Ghi chu (tuy chon)';

  @override
  String get transferConfirmTransfer => 'Xac nhan chuyen tien';

  @override
  String get transferAddressVerified => 'Dia chi da xac minh';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'Kha dung: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'Nhap so tien';

  @override
  String get commonRedPacketCountMin => 'Can it nhat 1 li xi';

  @override
  String get commonViewRedPacketDetails => 'Xem chi tiet li xi';

  @override
  String get commonEnterTransferAmount => 'Nhap so tien chuyen';

  @override
  String get commonTransferTo => 'Chuyen den';

  @override
  String commonFromSender(String name, Object senderName) {
    return 'Tu $senderName';
  }

  @override
  String get commonConfirmReceive => 'Xac nhan nhan';

  @override
  String get groupProfile => 'Thong tin nhom';

  @override
  String get groupRemoveMember => 'Xoa khoi nhom';

  @override
  String get commonRemove => 'Xoa';

  @override
  String get profileClearStatus => 'Xoa trang thai';

  @override
  String get profileClearStatusConfirm => 'Xoa trang thai hien tai?';

  @override
  String get profileStatusCleared => 'Da xoa trang thai';

  @override
  String get profileUserNotExist => 'Nguoi dung khong ton tai';

  @override
  String get profileUserIdCopied => 'Da sao chep ID nguoi dung';

  @override
  String get commonReport => 'Bao cao';

  @override
  String get profileQrCode => 'Ma QR';

  @override
  String get profileAvatarUpdated => 'Da cap nhat anh dai dien';

  @override
  String commonSelectImageFailed(String error) {
    return 'Chon hinh anh that bai: $error';
  }

  @override
  String get profileChangeName => 'Doi ten';

  @override
  String get profileMale => 'Nam';

  @override
  String get profileFemale => 'Nu';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature dang phat trien...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'Luu dia chi that bai: $error';
  }

  @override
  String get profileAddNew => 'Them';

  @override
  String get profileAddAddress => 'Them dia chi';

  @override
  String get profileAddressAdded => 'Da them dia chi';

  @override
  String get profileAddressUpdated => 'Da cap nhat dia chi';

  @override
  String get profileDeleteAddress => 'Xoa dia chi';

  @override
  String get profileAddressDeleted => 'Da xoa dia chi';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'Luu hoa don that bai: $error';
  }

  @override
  String get profileMyInvoices => 'Hoa don cua toi';

  @override
  String get profileAddInvoice => 'Them hoa don';

  @override
  String get profileInvoiceAdded => 'Da them hoa don';

  @override
  String get profileInvoiceUpdated => 'Da cap nhat hoa don';

  @override
  String get profileDeleteInvoice => 'Xoa hoa don';

  @override
  String get profileInvoiceDeleted => 'Da xoa hoa don';

  @override
  String get profilePersonal => 'Ca nhan';

  @override
  String get groupSelectAtLeastOne => 'Vui long chon it nhat mot thanh vien';

  @override
  String get chatFileNotExist => 'Tep khong ton tai';

  @override
  String chatSendFailed(String error) {
    return 'Gui that bai: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'Khong the mo trinh duyet';

  @override
  String chatSelectFileFailed(String error) {
    return 'Chon tep that bai: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'Cai dat that bai: $error';
  }

  @override
  String get transferEnterValidAmount => 'Vui long nhap so tien hop le';

  @override
  String get commonAddressCopied => 'Da sao chep dia chi';

  @override
  String favoriteOpenItem(String content) {
    return 'Mo: $content';
  }

  @override
  String get favoriteDeleted => 'Da xoa';

  @override
  String get profileWallet => 'Vi';

  @override
  String get chatRecording => 'Dang ghi am';

  @override
  String get chatInvalidVideoUrl => 'URL video khong hop le';

  @override
  String get chatDownloadFile => 'Tai tep xuong';

  @override
  String get chatClearChatHistoryTitle => 'Xoa lich su tro chuyen';

  @override
  String get chatVideoCall => 'Goi Video';

  @override
  String get commonVoiceCall => 'Goi Thoai';

  @override
  String get callLeaveMeeting => 'Roi cuoc hop';

  @override
  String get chatDetails => 'Chi tiet tro chuyen';

  @override
  String get chatViewAllGroupMembers => 'Xem tat ca thanh vien';

  @override
  String get chatGroupName => 'Ten nhom';

  @override
  String get chatGroupNameUpdated => 'Da cap nhat ten nhom';

  @override
  String get chatUpdateFailed => 'Cap nhat that bai';

  @override
  String get chatNoPermissionToModify => 'Ban khong co quyen sua doi';

  @override
  String get chatGroupManagement => 'Quan ly nhom';

  @override
  String get chatMyNicknameInGroup => 'Biet danh trong nhom';

  @override
  String get chatPinChat => 'Ghim tro chuyen';

  @override
  String get chatStrongReminder => 'Nhac nho manh';

  @override
  String get chatSetChatBackground => 'Dat hinh nen tro chuyen';

  @override
  String get chatUnknownFile => 'Tep khong xac dinh';

  @override
  String get chatDownload => 'Tai xuong';

  @override
  String get chatInvalidLocation => 'Vi tri khong hop le';

  @override
  String get chatTapToCancel => 'Nhan de huy';

  @override
  String chatCaptureFailed(Object error) {
    return 'Chup that bai: $error';
  }

  @override
  String get chatProcessingVideo => 'Dang xu ly video...';

  @override
  String get chatVideoFileNotExist => 'Tep video khong ton tai';

  @override
  String get chatVideoDataEmpty => 'Du lieu video trong';

  @override
  String get chatVideoTooLarge => 'Kich thuoc video khong the vuot qua 100MB';

  @override
  String get chatSendingVideo => 'Dang gui video...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'Gui video that bai: $error';
  }

  @override
  String get chatImageFileNotExist => 'Tep hinh anh khong ton tai';

  @override
  String get commonImageDataEmpty => 'Du lieu hinh anh trong';

  @override
  String get chatSendingImage => 'Dang gui hinh anh...';

  @override
  String chatSendImageFailed(Object error) {
    return 'Gui hinh anh that bai: $error';
  }

  @override
  String get chatSendLocation => 'Gui vi tri';

  @override
  String get chatSelectLocationAndSend => 'Chon vi tri va gui';

  @override
  String get chatShareRealTimeLocation => 'Chia se vi tri thoi gian thuc';

  @override
  String get chatShareLocationForOneHour =>
      'Chia se vi tri thoi gian thuc voi ban trong 1 gio';

  @override
  String get chatLocationSent => 'Da gui vi tri';

  @override
  String get chatSelectMessages => 'Chon tin nhan';

  @override
  String chatSelectedCount(int count) {
    return 'Da chon $count';
  }

  @override
  String get chatSelectAll => 'Chon tat ca';

  @override
  String chatGroupChatCount(int count) {
    return 'Chat nhom ($count)';
  }

  @override
  String get chatPrivateChat => 'Chat rieng';

  @override
  String get chatNoMessages => 'Khong co tin nhan';

  @override
  String get chatSendFirstMessage =>
      'Gui tin nhan dau tien de bat dau tro chuyen';

  @override
  String get chatEncryptionNotice =>
      'Cuoc tro chuyen nay duoc ma hoa dau cuoi. Chi ban va nguoi nhan moi doc duoc tin nhan.';

  @override
  String get chatMultiForward => 'Chuyen tiep';

  @override
  String get chatCollect => 'Luu tap';

  @override
  String get chatNoMembers => 'Khong co thanh vien';

  @override
  String get chatMemberNotFound => 'Khong tim thay thanh vien';

  @override
  String get chatVoiceFileNotExist => 'Tep giong noi khong ton tai';

  @override
  String get chatVoiceFileEmpty => 'Tep giong noi trong';

  @override
  String get chatSendingVoice => 'Dang gui tin nhan thoai...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'Gui tin nhan thoai that bai: $error';
  }

  @override
  String get chatMessageForwarded => 'Da chuyen tiep tin nhan';

  @override
  String chatForwardFailed(Object error) {
    return 'Chuyen tiep that bai: $error';
  }

  @override
  String get chatUnfavorited => 'Da bo yeu thich';

  @override
  String get chatFavorited => 'Da yeu thich';

  @override
  String get chatReactionAdded => 'Da them phan ung';

  @override
  String get chatReactionRemoved => 'Da xoa phan ung';

  @override
  String get chatFailedMessageDeleted => 'Da xoa tin nhan that bai';

  @override
  String get chatDeleteMessages => 'Xoa tin nhan';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'Ban co chac muon xoa $count tin nhan?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'Luu y: $count tin nhan tu nguoi khac va chi bi xoa cho ban.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return '$count tin nhan tu ban se bi thu hoi cho tat ca.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'Da thu hoi $count tin nhan, $localCount chi bi xoa cho ban';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'Da thu hoi $count tin nhan';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count tin nhan chi bi xoa cho ban';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'Da chuyen tiep $count tin nhan';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'Chuyen tiep hoan tat: $success thanh cong, $failed that bai';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'Tinh nang nhac nho chi kha dung trong chat nhom';

  @override
  String get chatOnlyTextSearchable => 'Chi co the tim kiem tin nhan van ban';

  @override
  String chatSearchFor(Object text) {
    return 'Tim \"$text\"';
  }

  @override
  String get chatBaiduSearch => 'Tim Baidu';

  @override
  String get chatGoogleSearch => 'Tim Google';

  @override
  String get chatBingSearch => 'Tim Bing';

  @override
  String get chatCalling => 'Dang goi...';

  @override
  String get chatRinging => 'Dang reo...';

  @override
  String get chatInCall => 'Dang trong cuoc goi';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'Tinh nang dang phat trien...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'Da luu $count tin nhan';
  }

  @override
  String commonMemberCount(int count) {
    return '$count thanh vien';
  }

  @override
  String groupDone(int count) {
    return 'Xong($count)';
  }

  @override
  String get profileServices => 'Dich vu';

  @override
  String get commonFavorites => 'Yeu thich';

  @override
  String get profileOrdersAndCards => 'Don hang & The';

  @override
  String get profileStickers => 'Nhan dan';

  @override
  String profileStatusSetTo(String status) {
    return 'Trang thai da dat: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'Tai len anh dai dien that bai';

  @override
  String get profilePersonalProfile => 'Ho so ca nhan';

  @override
  String get profileName => 'Ten';

  @override
  String get profileGender => 'Gioi tinh';

  @override
  String get profileRegion => 'Khu vuc';

  @override
  String get commonMyQrCode => 'Ma QR cua toi';

  @override
  String get profilePoke => 'Vo vai';

  @override
  String get profileRingtone => 'Nhac chuong';

  @override
  String get profileDefaultRingtone => 'Nhac chuong mac dinh';

  @override
  String get profileMyAddresses => 'Dia chi cua toi';

  @override
  String profileGenderSetTo(String gender) {
    return 'Gioi tinh da dat: $gender';
  }

  @override
  String get profileSelectRegion => 'Chon khu vuc';

  @override
  String get profileSelectCity => 'Chon thanh pho';

  @override
  String profileRegionSetTo(String region) {
    return 'Khu vuc da dat: $region';
  }

  @override
  String get profileSetPoke => 'Dat vo vai';

  @override
  String get profileFriendPokedMe => 'Ban be vo vai toi';

  @override
  String get profileExample => 'Vi du';

  @override
  String get profileOnTheShoulder => ' vao vai';

  @override
  String get profilePokeCleared => 'Da xoa vo vai';

  @override
  String profilePokeSetTo(String suffix) {
    return 'Vo vai da dat: vo vai toi$suffix';
  }

  @override
  String get profileEditSignature => 'Chinh sua chu ky';

  @override
  String get profileIntroduceYourself => 'Mot cau gioi thieu ban than';

  @override
  String get profileSignatureCleared => 'Da xoa chu ky';

  @override
  String get profileSignatureUpdated => 'Da cap nhat chu ky';

  @override
  String get profileScanToAddFriend => 'Quet ma QR tren de ket ban voi toi';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'Nhac chuong da dat: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'Ban co chac chac muon giai tan \"$name\" khong? Hanh dong nay khong the hoan tac.';
  }

  @override
  String get authEnterValidServerAddress =>
      'Vui long nhap dia chi may chu hop le';

  @override
  String get authEnterServerAddressFirst =>
      'Vui long nhap dia chi may chu truoc';

  @override
  String get authPasskeyRequiresServer =>
      'Dang nhap Passkey can ho tro may chu';

  @override
  String get authLoginAgreement => 'Bang viec dang nhap, ban dong y voi ';

  @override
  String get authPleaseAgreeToTerms =>
      'Vui long doc va dong y voi Dieu khoan Dich vu va Chinh sach Bao mat';

  @override
  String get authRegisterFailed => 'Dang ky that bai';

  @override
  String get commonReenterPassword => 'Nhap lai mat khau';

  @override
  String get commonPasswordsDoNotMatch => 'Mat khau khong khop';

  @override
  String get authInviteCodeBuiltIn => 'Ma moi (tich hop san)';

  @override
  String get authInviteCodeBuiltInNote =>
      'Ma moi da tich hop san, thuong khong can thay doi';

  @override
  String get authIHaveReadAndAgree => 'Toi da doc va dong y voi ';

  @override
  String get mainStartGroupChat => 'Bat dau Chat nhom';

  @override
  String get mainAddFriends => 'Them ban';

  @override
  String get mainPaymentAndCollection => 'Thanh toan';

  @override
  String contactCount(int count) {
    return '$count lien he';
  }

  @override
  String get contactAddToHomeScreen => 'Them vao man hinh chinh';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'Da gioi thieu the cua $contact cho $recipient';
  }

  @override
  String get contactEnterRemarkName => 'Nhap ten ghi chu';

  @override
  String contactRemarkSetTo(String remark) {
    return 'Ghi chu da dat: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return 'Da chap nhan yeu cau ket ban cua $name';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return 'Da tu choi yeu cau ket ban cua $name';
  }

  @override
  String get commonGroupInvites => 'Loi moi nhom';

  @override
  String commonMyGroups(int count) {
    return 'Nhom cua toi ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'Duoc moi tham gia nhom';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'Ban co chac chac muon roi khoi \"$name\" khong?';
  }

  @override
  String get commonLeave => 'Roi';

  @override
  String get commonRecallThisMessage => 'Thu hoi tin nhan nay?';

  @override
  String get commonSavedToGallery => 'Da luu vao thu vien';

  @override
  String get commonFailedToSave => 'Luu that bai';

  @override
  String get chatSaving => 'Dang luu...';

  @override
  String get commonShare => 'Chia se';

  @override
  String get chatSaveToGallery => 'Luu vao Thu vien';

  @override
  String chatDownloadFailed(String code) {
    return 'Tai xuong that bai: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'Chia se that bai: $error';
  }

  @override
  String get chatFailedToLoadImage => 'Tai hinh anh that bai';

  @override
  String get chatVideoRecordingFailed =>
      'Quay video that bai. Vui long thu lai.';

  @override
  String get profileRedPacket => 'Li xi';

  @override
  String get commonMusic => 'Nhac';

  @override
  String get commonCoupon => 'Phieu giam gia';

  @override
  String get commonGift => 'Qua tang';

  @override
  String get commonPoll => 'Binh chon';

  @override
  String get favoriteText => 'Van ban';

  @override
  String get favoriteLinkLabel => 'Lien ket';

  @override
  String get favoriteNote => 'Ghi chu';

  @override
  String get favoriteMyNotes => 'Ghi chu cua toi';

  @override
  String get favoriteToday => 'Hom nay';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count ngay truoc';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$day/$month';
  }

  @override
  String get favoriteNoFavorites => 'Chua co yeu thich';

  @override
  String get favoriteLongPressToFavorite => 'Nhan giu tin nhan de yeu thich';

  @override
  String get favoriteNewNote => 'Ghi chu moi';

  @override
  String get favoriteLink => 'Lien ket yeu thich';

  @override
  String get favoriteEditTags => 'Chinh sua the';

  @override
  String get favoriteDeleteFavorite => 'Xoa yeu thich';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'Ban co chac muon xoa yeu thich nay?';

  @override
  String get favoriteNoSearchResultsFound => 'Khong tim thay ket qua';

  @override
  String get commonSendRedPacket => 'Gui li xi';

  @override
  String get transferAmount => 'So tien';

  @override
  String get commonRedPacketCover => 'Bia li xi';

  @override
  String get commonRedPacketType => 'Loai li xi';

  @override
  String get commonNormalRedPacket => 'Thuong';

  @override
  String get commonLuckyRedPacket => 'May man';

  @override
  String get commonRedPacketCount => 'So li xi';

  @override
  String get commonPieces => 'cai';

  @override
  String get commonPutMoneyInRedPacket => 'Bo tien vao li xi';

  @override
  String get commonRedPacketRefundNotice =>
      'Li xi chua nhan se duoc hoan sau 24 gio';

  @override
  String get commonOpenRedPacket => 'Mo';

  @override
  String get commonRedPacketAllClaimed => 'Li xi da nhan het';

  @override
  String get commonRedPacketExpired => 'Li xi het han';

  @override
  String get commonAddTransferNote => 'Them ghi chu chuyen tien';

  @override
  String get commonYuan => 'VND';

  @override
  String get commonReplyWithEmoji => 'Tra loi bang bieu tuong nay';

  @override
  String get contactEditRemark => 'Chinh sua ghi chu';

  @override
  String get contactSetPermissions => 'Dat quyen';

  @override
  String get profileAddToBlacklist => 'Them vao danh sach chan';

  @override
  String get contactDeleteContact => 'Xoa lien he';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'Ban co chac muon xoa $name?';
  }

  @override
  String get transferTitle => 'Chuyen tien';

  @override
  String get transferReceiverAddressLabel => 'Dia chi nguoi nhan';

  @override
  String get transferSelectTokenLabel => 'Chon Token';

  @override
  String get transferAmountLabel => 'So tien chuyen';

  @override
  String get transferMemoLabel => 'Ghi chu (tuy chon)';

  @override
  String get transferAddMemoHint => 'Them ghi chu';

  @override
  String get transferSendPaymentRequest => 'Gui yeu cau thanh toan';

  @override
  String get transferQrCodeGenerateFailed => 'Tao ma QR that bai';

  @override
  String get transferScanQrToPayMe => 'Quet ma QR de thanh toan cho toi';

  @override
  String get transferMyWalletAddress => 'Dia chi vi cua toi';

  @override
  String get transferCreatePaymentRequest => 'Tao yeu cau thanh toan';

  @override
  String profileN42IdLabel(String id) {
    return 'Mã N42: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'Chuc mung tot lanh';

  @override
  String commonSenderRedPacket(String name) {
    return 'Li xi cua $name';
  }

  @override
  String get transferEnterValidAddress => 'Vui long nhap dia chi hop le';

  @override
  String get transferPleaseSelectToken => 'Vui long chon token';

  @override
  String get commonReceivedTransfer => 'Da nhan chuyen tien';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name da gui li xi';
  }

  @override
  String get commonSavedToBalance =>
      'Da luu vao so du, co the chuyen truc tiep';

  @override
  String get commonRedPacketExpiredOrEmpty => 'Li xi het han/da nhan het';

  @override
  String get transferScanFeatureComingSoon => 'Tinh nang quet sap ra mat...';

  @override
  String get contactSetAsStarred => 'Dat lam yeu thich';

  @override
  String get contactAddToBlocklist => 'Them vao danh sach chan';

  @override
  String get commonClaimedYour => ' da nhan ';

  @override
  String get commonClaimedText => ' da nhan ';

  @override
  String commonUserTyping(String name) {
    return '$name dang nhap...';
  }

  @override
  String get commonTyping => 'Dang nhap...';

  @override
  String get commonWaitingToReceive => 'Cho nhan';

  @override
  String get commonTapToClaim => 'Nhan de nhan';

  @override
  String get commonHasBeenReceived => 'Da nhan';

  @override
  String get commonGetLucky => 'Chuc may man';

  @override
  String get qrcodeCameraStartFailed => 'Camera khoi dong that bai';

  @override
  String get qrcodeUnknownError => 'Loi khong xac dinh';

  @override
  String get qrcodePlaceQrCodeInFrame => 'Dat ma QR trong khung de quet';

  @override
  String get qrcodeCloseManualInput => 'Dong nhap thu cong';

  @override
  String get qrcodeManualInputUserId => 'Nhap ID nguoi dung thu cong';

  @override
  String get commonAdd => 'Them';

  @override
  String get profileSetStatus => 'Dat trang thai';

  @override
  String get profileVisibleToFriends24h => 'Hien thi voi ban be trong 24 gio';

  @override
  String get profileWriteStatus => 'Viet trang thai';

  @override
  String get profileEnterYourStatus => 'Nhap trang thai...';

  @override
  String get profileOk => 'được rồi';

  @override
  String get qrcodeCameraPermissionRequired => 'Can quyen camera de quet ma QR';

  @override
  String get qrcodeCameraPermissionDenied =>
      'Quyen camera bi tu choi vinh vien. Vui long bat trong cai dat he thong.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'Loi kiem tra quyen: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'Ma QR khong hop le';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'Khong the ket ban: $error';
  }

  @override
  String get qrcodeScanQrCode => 'Quet ma QR';

  @override
  String get qrcodeCheckingCameraPermission => 'Dang kiem tra quyen camera...';

  @override
  String get qrcodeNeedCameraPermission => 'Can quyen camera';

  @override
  String get qrcodeRetryPermission => 'Thu lai';

  @override
  String get qrcodeOpenSettings => 'Mo cai dat';

  @override
  String get groupInviteMembers => 'Moi thanh vien';

  @override
  String groupInviteCount(int count) {
    return 'Moi($count)';
  }

  @override
  String get profileNoShippingAddress => 'Khong co dia chi giao hang';

  @override
  String get profileDefaultLabel => 'Mac dinh';

  @override
  String get profileNoInvoice => 'Khong co hoa don';

  @override
  String get profileCompany => 'Cong ty';

  @override
  String get profileTaxNumber => 'Ma so thue';

  @override
  String get profileConfirmDeleteAddress => 'Ban co chac muon xoa dia chi nay?';

  @override
  String get profileConfirmDeleteInvoice => 'Ban co chac muon xoa hoa don nay?';

  @override
  String get commonGroupOwner => 'Chu so huu';

  @override
  String get commonGroupAdmin => 'Quan tri vien';

  @override
  String get groupSearchMembers => 'Tim thanh vien';

  @override
  String groupTotalMembers(int count) {
    return '$count thanh vien';
  }

  @override
  String get chatRemoveFromGroup => 'Xoa khoi nhom';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'Ban co chac muon xoa \"$name\" khoi nhom?';
  }

  @override
  String get chatUnknownSong => 'Bai hat khong xac dinh';

  @override
  String get chatUnknownArtist => 'Nghe si khong xac dinh';

  @override
  String get chatUnknownContact => 'Lien he khong xac dinh';

  @override
  String get chatPersonalCard => 'The lien he';

  @override
  String get chatSingleChoice => 'Chon mot';

  @override
  String get chatMultiChoice => 'Chon nhieu';

  @override
  String get chatEnded => 'Ket thuc';

  @override
  String get chatEndPollButton => 'Ket thuc binh chon';

  @override
  String get chatPollHint =>
      'Binh chon se hien trong chat. Thanh vien nhom co the binh chon.';

  @override
  String get chatSearchSongOrArtist => 'Tim bai hat hoac nghe si';

  @override
  String get chatNoSongsFound => 'Khong tim thay bai hat';

  @override
  String get chatSongNameOptional => 'Ten bai hat (Tuy chon)';

  @override
  String get chatEnterSongName => 'Nhap ten bai hat';

  @override
  String get chatArtistNameOptional => 'Ten nghe si (Tuy chon)';

  @override
  String get chatEnterArtistName => 'Nhap ten nghe si';

  @override
  String get chatRealTimeLocationSharing =>
      'Chia se vi tri thoi gian thuc dang phat trien...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'Tinh nang goi thoai dang phat trien...';

  @override
  String get profileReportFeatureInDev =>
      'Tinh nang bao cao dang phat trien...';

  @override
  String get profileShareFeatureInDev => 'Tinh nang chia se dang phat trien...';

  @override
  String get profileQrCodeFeatureInDev => 'Tinh nang ma QR dang phat trien...';

  @override
  String get qrcodeScanQrToAddMe => 'Quet ma QR tren de ket ban voi toi';

  @override
  String get qrcodeSaveToAlbum => 'Luu vao Album';

  @override
  String get qrcodeChangeStyle => 'Doi kieu';

  @override
  String get qrcodeCopyId => 'Sao chep ID';

  @override
  String get qrcodeIdCopied => 'Da sao chep ID';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'Them kieu sap ra mat';

  @override
  String get profileBio => 'Tieu su';

  @override
  String get profileHomeServer => 'May chu';

  @override
  String get profileShareContactCard => 'Chia se the lien he';

  @override
  String get profileRemoveFromBlacklist => 'Xoa khoi danh sach chan';

  @override
  String get profileConfirmAddBlacklist =>
      'Ban co chac muon them nguoi nay vao danh sach chan? Ban se khong nhan tin nhan tu ho.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'Ban co chac muon xoa nguoi nay khoi danh sach chan?';

  @override
  String get profileRemarkSaved => 'Da luu ghi chu';

  @override
  String get profileRemarkCleared => 'Da xoa ghi chu';

  @override
  String get transferReceive => 'Nhan';

  @override
  String get transferPleaseConnectWallet => 'Vui long ket noi vi truoc';

  @override
  String get transferSendRequest => 'Gui yeu cau';

  @override
  String get transferPleaseEnterValidAmount => 'Vui long nhap so tien hop le';

  @override
  String get searchPlaceholder => 'Tim lien he, nhom, tin nhan';

  @override
  String get searchEnterKeywordToSearch => 'Nhap tu khoa de bat dau tim kiem';

  @override
  String get searchClearHistory => 'Xoa';

  @override
  String searchNoResultsForQuery(String query) {
    return 'Khong tim thay ket qua cho \"$query\"';
  }

  @override
  String get searchAllResults => 'Tat ca';

  @override
  String get searchInChat => 'Tim trong tro chuyen';

  @override
  String get searchContactLabel => 'Lien he';

  @override
  String get searchGroupLabel => 'Nhom';

  @override
  String get searchConversationLabel => 'Cuộc trò chuyện';

  @override
  String get searchMessageLabel => 'Tin nhan';

  @override
  String get settingsSecurityTitle => 'Bao mat';

  @override
  String get settingsKeyBackup => 'Sao luu khoa';

  @override
  String get settingsBackupEncryptionKeys => 'Sao luu khoa ma hoa';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count khoa da sao luu';
  }

  @override
  String get settingsBackupNotSet => 'Chua dat sao luu';

  @override
  String get settingsRestoreKeys => 'Khoi phuc khoa';

  @override
  String get settingsRestoreKeysFromBackup =>
      'Khoi phuc khoa ma hoa tu ban sao luu';

  @override
  String get settingsExportKeys => 'Xuat khoa';

  @override
  String get settingsExportKeysToFile => 'Xuat khoa ra tep';

  @override
  String get settingsLoggedInDevices => 'Thiet bi da dang nhap';

  @override
  String get settingsNoOtherDevices => 'Khong co thiet bi khac';

  @override
  String get settingsVerified => 'Da xac minh';

  @override
  String get settingsUnverified => 'Chua xac minh';

  @override
  String get settingsAdvanced => 'Nang cao';

  @override
  String get settingsCrossSigning => 'Ky cheo';

  @override
  String get settingsEnabled => 'Da bat';

  @override
  String get settingsNotEnabled => 'Chua bat';

  @override
  String get settingsResetEncryption => 'Dat lai ma hoa';

  @override
  String get settingsDeleteAllEncryptionKeys => 'Xoa tat ca khoa ma hoa';

  @override
  String get settingsEncryptionNotSupported => 'Khong ho tro ma hoa';

  @override
  String get settingsNotInitialized => 'Chua khoi tao';

  @override
  String get settingsBackupKeyTitle => 'Sao luu khoa';

  @override
  String get settingsBackupKeyMessage =>
      'Tao ban sao luu khoa moi? Dieu nay se giup ban khoi phuc tin nhan ma hoa tren thiet bi moi.';

  @override
  String get settingsBackup => 'Sao luu';

  @override
  String get settingsRestoreKeyTitle => 'Khoi phuc khoa';

  @override
  String get settingsRestoreKeyMessage =>
      'Nhap mat khau khoi phuc hoac khoa khoi phuc de khoi phuc tin nhan ma hoa.';

  @override
  String get settingsRestore => 'Khoi phuc';

  @override
  String get settingsExportKeyTitle => 'Xuat khoa';

  @override
  String get settingsExportKeyMessage =>
      'Tep khoa xuat chua tat ca khoa ma hoa cua ban. Vui long giu an toan.';

  @override
  String get settingsExport => 'Xuat';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ID thiet bi: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'Trang thai: Da xac minh';

  @override
  String get settingsDeviceStatusUnverified => 'Trang thai: Chua xac minh';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'Hoat dong cuoi: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'Xac minh thiet bi nay';

  @override
  String get settingsCrossSigningAlreadyEnabled => 'Ky cheo da duoc bat';

  @override
  String get settingsCrossSigningSetupSuccess => 'Cai dat ky cheo thanh cong';

  @override
  String get settingsResetEncryptionTitle => 'Dat lai ma hoa';

  @override
  String get settingsResetEncryptionWarning =>
      'Canh bao: Hanh dong nay se xoa tat ca khoa ma hoa cua ban. Ban se khong the giai ma tin nhan ma hoa truoc do. Hanh dong nay khong the hoan tac.';

  @override
  String get settingsReset => 'Dat lai';

  @override
  String get settingsBackupSuccess => 'Đã sao lưu khóa thành công';

  @override
  String get settingsBackupFailed => 'Sao lưu không thành công';

  @override
  String get settingsRecoveryKey => 'Khóa khôi phục';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'Vui lòng lưu khóa khôi phục này ở nơi an toàn. Bạn sẽ cần nó để khôi phục tin nhắn được mã hóa của mình trên thiết bị mới.';

  @override
  String get settingsRecoveryKeySaved => 'Tôi đã lưu nó';

  @override
  String get settingsRestoreSuccess => 'Đã khôi phục khóa thành công';

  @override
  String get settingsRestoreFailed => 'Khôi phục không thành công';

  @override
  String get settingsPassword => 'Mật khẩu';

  @override
  String get settingsEnterRecoveryKey => 'Nhập khóa khôi phục';

  @override
  String get settingsEnterPassword => 'Nhập mật khẩu';

  @override
  String get settingsExportSuccess =>
      'Đã xuất khóa sang bản sao lưu máy chủ thành công';

  @override
  String get settingsExportNeedBackupFirst =>
      'Vui lòng tạo bản sao lưu khóa trước';

  @override
  String get settingsExportFailed => 'Xuất không thành công';

  @override
  String get settingsResetSuccess => 'Đặt lại mã hóa thành công';

  @override
  String get settingsResetFailed => 'Đặt lại không thành công';

  @override
  String get callLeaveMeetingConfirm => 'Ban co chac muon roi cuoc hop?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'da vo vai $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'Khong co lien he de them';

  @override
  String get chatAddMembers => 'Them thanh vien';

  @override
  String chatInvitedMembers(int count) {
    return 'Da moi $count thanh vien';
  }

  @override
  String chatInviteFailed(String error) {
    return 'Moi that bai: $error';
  }

  @override
  String get chatMemberRemoved => 'Da xoa thanh vien';

  @override
  String chatRemoveFailed(String error) {
    return 'Xoa that bai: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'Sau khi chia se, nguoi kia co the thay vi tri thoi gian thuc cua ban trong 1 gio.';

  @override
  String get chatStartSharing => 'Bat dau chia se';

  @override
  String get chatLocationServiceNotEnabled => 'Dich vu vi tri chua duoc bat';

  @override
  String get chatEnableLocationService =>
      'Vui long bat dich vu vi tri de su dung tinh nang nay';

  @override
  String get chatGoToSettings => 'Di den Cai dat';

  @override
  String get chatLocationPermissionRequired =>
      'Can quyen vi tri cho tinh nang nay';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'Quyen vi tri bi tu choi vinh vien. Vui long bat trong cai dat.';

  @override
  String get chatLocationPermissionDenied => 'Quyen vi tri bi tu choi';

  @override
  String get chatGettingLocation => 'Dang lay vi tri...';

  @override
  String chatGetLocationFailed(String error) {
    return 'Lay vi tri that bai: $error';
  }

  @override
  String get chatMapPreview => 'Xem truoc ban do';

  @override
  String get chatSearchLocation => 'Tim vi tri';

  @override
  String chatRedPacketSent(String amount, String token) {
    return 'Da gui li xi $amount $token';
  }

  @override
  String get chatTransferDefault => 'Chuyen tien';

  @override
  String chatTransferSent(String amount, String token) {
    return 'Da gui chuyen tien $amount $token';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'Chon tep that bai: $error';
  }

  @override
  String get chatFileSizeLimit => 'Kich thuoc tep khong the vuot qua 50MB';

  @override
  String chatFileSending(String filename) {
    return 'Dang gui tep: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'Gui tep that bai: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return 'Da gui the lien he cua $name';
  }

  @override
  String get chatFavoritesFeature => 'Yeu thich';

  @override
  String get chatCouponsFeature => 'Phieu giam gia';

  @override
  String get chatGiftFeature => 'Qua tang';

  @override
  String chatSharedMusic(String name) {
    return 'Da chia se $name';
  }

  @override
  String get chatEndPollTitle => 'Ket thuc binh chon';

  @override
  String get chatEndPollConfirmMessage =>
      'Ban co chac muon ket thuc binh chon nay? Binh chon se dong sau khi ket thuc.';

  @override
  String get chatPollEndedMessage => 'Binh chon da ket thuc';

  @override
  String get chatConnectingCall => 'Đang kết nối...';

  @override
  String get chatMuteCall => 'Tat tieng';

  @override
  String get chatSpeakerOff => 'Tat loa';

  @override
  String get chatSpeakerOn => 'Loa';

  @override
  String get chatCameraOn => 'Bat camera';

  @override
  String get chatCameraOff => 'Tat camera';

  @override
  String get chatHangUp => 'Cup may';

  @override
  String get chatSelectForwardTargetTitle => 'Chon muc tieu chuyen tiep';

  @override
  String get chatNoForwardableChat => 'Khong co tro chuyen de chuyen tiep';

  @override
  String get chatNoMatchingChat => 'Khong tim thay tro chuyen phu hop';

  @override
  String get chatLocationTitle => 'Vi tri';

  @override
  String get chatSendButton => 'Gui';

  @override
  String get chatRetryButton => 'Thu lai';

  @override
  String get chatSearchContactHint => 'Tim lien he';

  @override
  String get chatShareMusic => 'Chia se nhac';

  @override
  String get chatRecentPlayed => 'Gan day';

  @override
  String get chatMyFavorites => 'Yeu thich';

  @override
  String get chatNetworkLink => 'Lien ket';

  @override
  String get chatLocalFile => 'Tep';

  @override
  String get chatPasteMusicLink => 'Dan lien ket nhac';

  @override
  String get chatShareMusicButton => 'Chia se nhac';

  @override
  String get chatSelectLocalAudio => 'Chon tep am thanh';

  @override
  String get chatSupportedAudioFormats => 'Ho tro MP3, M4A, WAV, FLAC, v.v.';

  @override
  String get chatSelectFileButton => 'Chon tep';

  @override
  String get chatPleaseEnterMusicLink => 'Vui long nhap lien ket nhac';

  @override
  String get chatPleaseEnterValidLink => 'Vui long nhap URL hop le';

  @override
  String get chatSharedSong => 'Bai hat da chia se';

  @override
  String get chatSelectMember => 'Chon thanh vien';

  @override
  String get chatSearchMemberHint => 'Tim thanh vien';

  @override
  String get chatNoMatchingMembers => 'Khong tim thay thanh vien phu hop';

  @override
  String get commonUnknownMember => 'Khong xac dinh';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'Da chon $count tin nhan';
  }

  @override
  String get chatSearchContactsOrGroups => 'Tim lien he hoac nhom';

  @override
  String get chatVideoTitle => 'Băng hình';

  @override
  String get chatLoadingText => 'Dang tai...';

  @override
  String get chatVideoLoadFailed => 'Tai video that bai';

  @override
  String get chatPlayerInitFailed => 'Khoi tao trinh phat that bai';

  @override
  String get chatCreatePollTitle => 'Tao binh chon';

  @override
  String get chatSubmitPoll => 'Gui';

  @override
  String get chatPollQuestionLabel => 'Cau hoi binh chon';

  @override
  String get chatEnterPollQuestionHint => 'Vui long nhap cau hoi binh chon';

  @override
  String get chatPollOptionsLabel => 'Cac lua chon';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'Lua chon $index';
  }

  @override
  String get chatAddOptionButton => 'Them lua chon';

  @override
  String get chatPollSettingsLabel => 'Cai dat binh chon';

  @override
  String get chatSelectionType => 'Loai chon';

  @override
  String get chatSingleChoiceLabel => 'Chon mot';

  @override
  String get chatMultiChoiceLabel => 'Chon nhieu';

  @override
  String get chatAnonymousPollSwitch => 'Binh chon an danh';

  @override
  String get chatPleaseEnterQuestion => 'Vui long nhap cau hoi binh chon';

  @override
  String get chatAtLeastTwoOptions => 'Can it nhat 2 lua chon';

  @override
  String chatConfirmWithCount(int count) {
    return 'Xac nhan ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'Xac minh Email';

  @override
  String get authEnterValidEmailAddress => 'Vui long nhap dia chi email hop le';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'Ma xac minh da gui den $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'Gui ma that bai: $error';
  }

  @override
  String get authVerificationSuccess => 'Xac minh thanh cong';

  @override
  String get authVerificationFailed => 'Xac minh that bai';

  @override
  String authVerificationCodeError(String error) {
    return 'Loi ma xac minh: $error';
  }

  @override
  String get commonEnterVerificationCode => 'Nhap ma xac minh';

  @override
  String get authEnterYourEmail => 'Nhap email';

  @override
  String authWeSentCodeTo(String email) {
    return 'Chung toi da gui ma 6 so den\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'Nhap dia chi email, chung toi se gui ma xac minh';

  @override
  String get commonSendVerificationCode => 'Gui ma xac minh';

  @override
  String get authResendVerificationCode => 'Gui lai ma xac minh';

  @override
  String authCanResendAfter(int seconds) {
    return 'Co the gui lai sau $seconds giay';
  }

  @override
  String get commonChangeEmail => 'Doi email';

  @override
  String get contactAddToContacts => 'Them vao danh ba';

  @override
  String get contactAddingToContacts => 'Dang them...';

  @override
  String get contactAddedToContacts => 'Da them vao danh ba';

  @override
  String contactAddFailedWithError(String error) {
    return 'Them that bai: $error';
  }

  @override
  String get contactAddPhone => 'Them dien thoai';

  @override
  String get contactAddTag => 'Them the';

  @override
  String get contactAddText => 'Them van ban';

  @override
  String get contactAddPhoto => 'Them anh';

  @override
  String contactGroupCountLabel(int count) {
    return '$count nhom';
  }

  @override
  String get contactAddedViaSearch => 'Da them qua tim kiem';

  @override
  String get contactAddTime => 'Thoi gian them';

  @override
  String get contactDoneButton => 'Xong';

  @override
  String get callWaitingForParticipants => 'Dang cho nguoi tham gia...';

  @override
  String callParticipantMe(String name) {
    return '$name (Toi)';
  }

  @override
  String get callSharingLabel => 'Dang chia se';

  @override
  String callScreenSharingBy(String name) {
    return '$name dang chia se man hinh';
  }

  @override
  String callParticipantCount(int count) {
    return '$count nguoi tham gia';
  }

  @override
  String get callMuteLabel => 'Tat tieng';

  @override
  String get callUnmuteLabel => 'Bat tieng';

  @override
  String get callTurnOffVideo => 'Tat video';

  @override
  String get callTurnOnVideo => 'Bat video';

  @override
  String get callShareScreen => 'Chia se man hinh';

  @override
  String get callStopSharing => 'Dung chia se';

  @override
  String get callSwitchCameraLabel => 'Chuyen';

  @override
  String get callLeaveLabel => 'Roi';

  @override
  String get callParticipantsLabel => 'Nguoi tham gia';

  @override
  String get callJoiningMeeting => 'Dang tham gia cuoc hop...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count phiếu ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count người tham gia';
  }

  @override
  String get commonTapToRetry => 'Nhấn để thử lại';

  @override
  String get chatDefaultRedPacketGreeting => 'Chúc phát tài phát lộc';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'Cho phép những người khác tìm kiếm và tham gia';

  @override
  String get groupConfirmClearChatHistory =>
      'Bạn có chắc chắn muốn xóa lịch sử trò chuyện không?';

  @override
  String get groupCreateGroupToChat => 'Tạo một nhóm để bắt đầu trò chuyện';

  @override
  String get groupEditGroupAnnouncement => 'Chỉnh sửa thông báo nhóm';

  @override
  String get groupEditGroupDescription => 'Chỉnh sửa mô tả nhóm';

  @override
  String get groupEnterGroupAnnouncement => 'Nhập thông báo nhóm';

  @override
  String chatErrorWithMessage(String message) {
    return 'Lỗi: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count thành viên, nhấp để sao chép ID nhóm';
  }

  @override
  String get chatMusicLinkLabel => 'Liên kết nhạc';

  @override
  String get chatNoMediaUrlAvailable => 'URL phương tiện không khả dụng';

  @override
  String get groupNoPermissionToEditGroupName =>
      'Bạn không có quyền chỉnh sửa tên nhóm';

  @override
  String get chatRedPacketTransferCannotForward =>
      'Lì xì và chuyển khoản không thể chuyển tiếp';

  @override
  String get authEmailAddress => 'Địa chỉ email';

  @override
  String get commonEnterEmailAddress => 'Nhập địa chỉ email';

  @override
  String get authEmailRecoveryHint => 'Dùng để khôi phục mật khẩu';

  @override
  String get commonInvalidEmailFormat => 'Vui lòng nhập địa chỉ email hợp lệ';

  @override
  String get authOptional => 'Tùy chọn';

  @override
  String get authResetPassword => 'Đặt lại mật khẩu';

  @override
  String get authEnterRegisteredEmail => 'Nhập địa chỉ email bạn đã đăng ký';

  @override
  String get authSendResetCode => 'Gửi mã đặt lại';

  @override
  String authResetCodeSent(String email) {
    return 'Mã đặt lại đã gửi đến $email';
  }

  @override
  String get authEnterResetCode => 'Nhập mã đặt lại';

  @override
  String get authSetNewPassword => 'Đặt mật khẩu mới';

  @override
  String get commonConfirmNewPassword => 'Xác nhận mật khẩu mới';

  @override
  String get commonNewPassword => 'Mật khẩu mới';

  @override
  String get authPasswordResetSuccess =>
      'Mật khẩu đã được đặt lại thành công. Vui lòng đăng nhập bằng mật khẩu mới.';

  @override
  String get authResetPasswordFailed => 'Đặt lại mật khẩu thất bại';

  @override
  String get settingsChangePassword => 'Đổi mật khẩu';

  @override
  String get settingsCurrentPassword => 'Mật khẩu hiện tại';

  @override
  String get settingsEnterCurrentPassword => 'Nhập mật khẩu hiện tại';

  @override
  String get settingsEnterNewPassword => 'Nhập mật khẩu mới';

  @override
  String get settingsPasswordChanged =>
      'Mật khẩu đã được thay đổi thành công. Vui lòng đăng nhập bằng mật khẩu mới.';

  @override
  String get settingsChangePasswordFailed => 'Đổi mật khẩu thất bại';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'Mật khẩu mới phải khác mật khẩu hiện tại';

  @override
  String get settingsChangePasswordInfo =>
      'Sau khi đổi mật khẩu, bạn sẽ bị đăng xuất và cần đăng nhập lại bằng mật khẩu mới.';

  @override
  String get settingsPasswordRequirements => 'Yêu cầu mật khẩu:';

  @override
  String get settingsSecurityNote =>
      'Vì lý do bảo mật, bạn sẽ cần đăng nhập lại trên tất cả thiết bị sau khi đổi mật khẩu.';

  @override
  String get settingsSecurity => 'Bảo mật';

  @override
  String get settingsCurrentBoundEmail => 'Email hiện đang liên kết';

  @override
  String get settingsNewEmailAddress => 'Địa chỉ email mới';

  @override
  String get settingsEnterNewEmail => 'Nhập địa chỉ email mới';

  @override
  String get settingsVerificationCode => 'Mã xác nhận';

  @override
  String get settingsVerificationCodeSent => 'Mã xác nhận đã được gửi';

  @override
  String get settingsCodeSentTo => 'Mã xác nhận đã gửi đến';

  @override
  String get settingsDidNotReceiveCode => 'Không nhận được mã?';

  @override
  String get settingsEmailChangedSuccess => 'Email đã được thay đổi thành công';

  @override
  String get settingsChangeEmailFailed => 'Thay đổi email thất bại';

  @override
  String get settingsEmailSecurityNote =>
      'Email của bạn được dùng để khôi phục mật khẩu. Hãy giữ an toàn.';

  @override
  String get commonGoogleLogin => 'Đăng nhập bằng Google';

  @override
  String get commonAppleLogin => 'Đăng nhập bằng Apple';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageChanged => 'Ngôn ngữ đã thay đổi';

  @override
  String get settingsTranslation => 'Dịch thuật';

  @override
  String get settingsTranslateTextTo => 'Dịch văn bản sang';

  @override
  String get settingsTranslateDescription =>
      'Chọn ngôn ngữ bạn muốn dịch tin nhắn sang.';

  @override
  String get settingsAutoTranslate => 'Tự động dịch tin nhắn đã nhận';

  @override
  String get settingsAutoTranslateDescription =>
      'Tự động dịch tin nhắn nhận được trong cuộc trò chuyện sang ngôn ngữ bạn đã chọn.';

  @override
  String get settingsBiometricLogin => 'Đăng nhập sinh trắc học';

  @override
  String authLoginWithBiometric(Object type) {
    return 'Đăng nhập bằng $type';
  }

  @override
  String get settingsBiometricLoginEnabled => 'Đăng nhập sinh trắc học đã bật';

  @override
  String get settingsBiometricLoginDisabled => 'Đăng nhập sinh trắc học đã tắt';

  @override
  String get settingsEnableBiometricLogin => 'Bật đăng nhập sinh trắc học';

  @override
  String get settingsBiometricEnabled =>
      'Đã bật - Dùng sinh trắc học để đăng nhập';

  @override
  String get settingsBiometricDisabled => 'Đã tắt - Nhấn để bật';

  @override
  String get settingsBiometricNeedRelogin =>
      'Vui lòng đăng xuất và đăng nhập lại để bật đăng nhập sinh trắc học';

  @override
  String get authOr => 'HOẶC';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'Quyền truy cập camera bị hạn chế trên thiết bị này';

  @override
  String get authPasskeyLabel => 'Mật khẩu';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'táo';

  @override
  String get authSsoLabel => 'SSO';

  @override
  String get transferAmountHintZero => '0,00';

  @override
  String get commonMatrixIdHint => '@username:server.com';

  @override
  String get authServerAddressHint => 'https://m.si46.world';

  @override
  String get authEmailExampleHint => 'example@email.com';

  @override
  String get authVerificationCodePlaceholder => '------';

  @override
  String get profileEnterPokeSuffixHint => 'Nhập hậu tố chọc, ví dụ: vào vai';

  @override
  String get groupAlbum => 'Album nhóm';

  @override
  String get groupFiles => 'Tệp nhóm';

  @override
  String get groupImages => 'Hình ảnh';

  @override
  String get groupVideos => 'Video';

  @override
  String get groupTotal => 'Tổng cộng';

  @override
  String get groupSize => 'Kích thước';

  @override
  String get groupNoMedia => 'Không có phương tiện';

  @override
  String get groupNoMediaDescription =>
      'Chưa có ảnh hoặc video nào trong nhóm này';

  @override
  String get groupDocuments => 'Tài liệu';

  @override
  String get groupNoFiles => 'Không có tệp';

  @override
  String get groupNoFilesDescription => 'Chưa có tệp nào trong nhóm này';

  @override
  String groupDownloadStarted(String filename) {
    return 'Đang tải $filename...';
  }

  @override
  String get contactNoCommonGroups => 'Không có nhóm chung';

  @override
  String get contactNoCommonGroupsDescription =>
      'Các bạn không có nhóm chung nào';

  @override
  String get chatVoiceMessage => 'Giọng nói';

  @override
  String get chatMessage => 'Tin nhắn';

  @override
  String get conversationHideChat => 'Ẩn';

  @override
  String get settingsQuickReply => 'Trả lời nhanh';

  @override
  String get commonTranslate => 'Dịch';

  @override
  String get contactCreateTag => 'Tạo thẻ';

  @override
  String get contactEnterTagName => 'Nhập tên thẻ';

  @override
  String get contactEditTag => 'Chỉnh sửa thẻ';

  @override
  String get contactDeleteTag => 'Xóa thẻ';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'Bạn có chắc chắn muốn xóa thẻ \"$tagName\" không?';
  }

  @override
  String get contactNoTags => 'Chưa có thẻ nào';

  @override
  String get contactFriendPermissions => 'Quyền của bạn bè';

  @override
  String get contactSetChatOnly => 'Đặt ở chế độ chỉ trò chuyện';

  @override
  String get contactChatOnlyDesc =>
      'Chỉ có thể trò chuyện với bạn, nội dung khác sẽ bị ẩn';

  @override
  String get contactHideMyMoments => 'Ẩn khoảnh khắc của tôi';

  @override
  String get contactHideMyMomentsDesc =>
      'Người bạn này không thể nhìn thấy Khoảnh khắc của tôi';

  @override
  String get contactHideTheirMoments => 'Giấu khoảnh khắc của họ';

  @override
  String get contactHideTheirMomentsDesc =>
      'Không xem được Khoảnh khắc của người bạn này';

  @override
  String get contactHideMyStatus => 'Ẩn trạng thái của tôi';

  @override
  String get contactHideMyStatusDesc =>
      'Người bạn này không thể xem cập nhật trạng thái của tôi';

  @override
  String get contactNoChatOnlyFriends => 'Không có bạn bè chỉ trò chuyện';

  @override
  String get contactNoOfficialAccounts => 'Không có tài khoản chính thức';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'Theo dõi các tài khoản chính thức để nhận được thông tin cập nhật mới nhất';

  @override
  String get contactNoServiceAccounts => 'Không có tài khoản dịch vụ';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'Đăng ký tài khoản dịch vụ để được sử dụng các dịch vụ tiện lợi';

  @override
  String get contactNoEnterpriseContacts => 'Không có liên hệ doanh nghiệp';

  @override
  String get contactEnterpriseContactsDesc =>
      'Địa chỉ liên hệ doanh nghiệp sẽ được hiển thị ở đây';

  @override
  String get profileCardPack => 'Gói thẻ';

  @override
  String get profileOrders => 'Đơn đặt hàng';

  @override
  String get profileNoOrders => 'Không có đơn đặt hàng';

  @override
  String get profileOrdersDesc => 'Đơn đặt hàng của bạn sẽ được hiển thị ở đây';

  @override
  String get profileNoCards => 'Không có thẻ';

  @override
  String get profileCardsDesc => 'Thẻ của bạn sẽ được hiển thị ở đây';

  @override
  String get favoriteEnterTagsHint =>
      'Nhập các thẻ được phân tách bằng dấu phẩy';

  @override
  String get favoriteTagsUpdated => 'Đã cập nhật thẻ';

  @override
  String get favoriteForwardedContent => 'Nội dung được chuyển tiếp';

  @override
  String get favoriteEnterNoteContent => 'Nhập nội dung ghi chú';

  @override
  String get favoriteNoteAdded => 'Đã thêm ghi chú';

  @override
  String get favoriteLinkTitle => 'Tiêu đề liên kết';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'Đã thêm liên kết';

  @override
  String get contactPhotoAdded => 'Đã thêm ảnh';

  @override
  String get contactEnterPhone => 'Nhập số điện thoại';

  @override
  String commonConversationWithId(String roomId) {
    return 'Cuoc tro chuyen: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'Lien he: $userId';
  }

  @override
  String get commonDiscover => 'Kham pha';

  @override
  String commonDeveloping(String title) {
    return '$title\n(Sap ra mat)';
  }

  @override
  String get commonPageNotFound => 'Khong tim thay trang';

  @override
  String get commonBackToHome => 'Quay lai trang chu';

  @override
  String get settingsMessageNotifications => 'Thông báo tin nhắn';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'Nhận thông báo tin nhắn mới';

  @override
  String get settingsShowMessagePreview => 'Hiển thị xem trước tin nhắn';

  @override
  String get settingsShowMessageContentInNotification =>
      'Hiển thị nội dung tin nhắn trong thông báo';

  @override
  String get settingsNotificationSound => 'Am thanh thong bao';

  @override
  String get settingsPlaySoundOnMessage => 'Phat am thanh khi nhan tin nhan';

  @override
  String get commonVibration => 'Rung';

  @override
  String get settingsVibrateOnMessage => 'Rung khi nhan tin nhan';

  @override
  String get settingsDoNotDisturbMode => 'Không làm phiền';

  @override
  String get settingsDoNotDisturbDescription =>
      'Không nhận thông báo trong khoảng thời gian chỉ định';

  @override
  String get settingsStartTime => 'Thoi gian bat dau';

  @override
  String get settingsEndTime => 'Thoi gian ket thuc';

  @override
  String get settingsDeleteQuickReply => 'Xóa trả lời nhanh';

  @override
  String get settingsEditQuickReply => 'Sửa trả lời nhanh';

  @override
  String get settingsAddQuickReply => 'Thêm trả lời nhanh';

  @override
  String get settingsManageQuickReplies => 'Quản lý trả lời nhanh';

  @override
  String get settingsNoQuickReplies => 'Không có trả lời nhanh';

  @override
  String get settingsDefaultQuickReplies =>
      'Trả lời nhanh mặc định sẽ được hiển thị';

  @override
  String get settingsWhoCanSee => 'Ai co the xem';

  @override
  String get settingsLastSeen => 'Lan cuoi truc tuyen';

  @override
  String get settingsHiddenChats => 'Cuộc trò chuyện ẩn';

  @override
  String get settingsMessagesLabel => 'Tin nhắn';

  @override
  String get settingsAllowStrangerMessages => 'Cho phép tin nhắn từ người lạ';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'Nhận tin nhắn từ người không có trong danh bạ';

  @override
  String get settingsReadReceipts => 'Xac nhan da doc';

  @override
  String get settingsLetOthersKnowYouRead =>
      'Cho người khác biết bạn đã đọc tin nhắn của họ';

  @override
  String get settingsTypingIndicator => 'Chỉ báo đang nhập';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'Cho người khác biết bạn đang nhập';

  @override
  String get settingsEveryone => 'Tat ca moi nguoi';

  @override
  String get settingsContactsOnly => 'Chi danh ba';

  @override
  String get settingsNobody => 'Khong ai';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'Ai có thể xem $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get settingsCheckForUpdates => 'Kiểm tra cập nhật';

  @override
  String get settingsOpenSourceLicenses => 'Giay phep ma nguon mo';

  @override
  String get settingsFeedbackAndSuggestions => 'Phản hồi và đề xuất';

  @override
  String get settingsBuiltOnMatrix => 'Xay dung tren giao thuc Matrix';

  @override
  String get settingsNoHiddenChats => 'Không có cuộc trò chuyện ẩn';

  @override
  String get settingsNoHiddenChatsDescription =>
      'Các cuộc trò chuyện bạn ẩn sẽ xuất hiện ở đây';

  @override
  String get settingsUnhideChat => 'Bỏ ẩn';

  @override
  String get settingsDarkMode => 'Chế độ tối';

  @override
  String get settingsFontSize => 'Cỡ chữ';

  @override
  String get settingsBubbleStyle => 'Kiểu bong bóng';

  @override
  String get settingsFollowSystem => 'Theo hệ thống';

  @override
  String get settingsAutoSwitchBySystem =>
      'Tự động chuyển theo cài đặt hệ thống';

  @override
  String get settingsLightMode => 'Chế độ sáng';

  @override
  String get settingsAlwaysUseLightTheme => 'Luôn dùng giao diện sáng';

  @override
  String get settingsDarkModeOption => 'Chế độ tối';

  @override
  String get settingsAlwaysUseDarkTheme => 'Luôn dùng giao diện tối';

  @override
  String get settingsFontSizeSmall => 'Nhỏ';

  @override
  String get settingsFontSizeStandard => 'Tiêu chuẩn';

  @override
  String get settingsFontSizeLarge => 'Lớn';

  @override
  String get settingsFontSizeExtraLarge => 'Rất lớn';

  @override
  String get settingsBubbleStyleWechat => 'Kiểu WeChat';

  @override
  String get settingsBubbleStyleWechatDesc => 'Kiểu bong bóng WeChat cổ điển';

  @override
  String get settingsBubbleStyleModern => 'Kiểu hiện đại';

  @override
  String get settingsBubbleStyleModernDesc => 'Kiểu bong bóng hiện đại sạch sẽ';

  @override
  String get settingsBubbleStyleClassic => 'Kiểu cổ điển';

  @override
  String get settingsBubbleStyleClassicDesc => 'Kiểu bong bóng truyền thống';

  @override
  String get discoverVideoChannels => 'Kenh';

  @override
  String get discoverLive => 'Truc tiep';

  @override
  String get discoverListen => 'Nghe';

  @override
  String get discoverWatch => 'Xem';

  @override
  String get discoverSearchDiscover => 'Tim kiem';

  @override
  String get discoverNearbyPeople => 'Gan day';

  @override
  String get discoverGames => 'Tro choi';

  @override
  String get discoverMiniPrograms => 'Ung dung mini';

  @override
  String get chatAlreadyInCall => 'Dang trong cuoc goi';

  @override
  String get commonConnectionFailed => 'Ket noi that bai';

  @override
  String get chatCallRejected => 'Cuoc goi bi tu choi';

  @override
  String get chatNoAnswer => 'Khong tra loi';

  @override
  String get commonClose => 'Dong';

  @override
  String get chatSelectContact => 'Chon lien he';

  @override
  String get chatVoteRemoved => 'Da xoa binh chon';

  @override
  String get chatVoteChanged => 'Da thay doi binh chon';

  @override
  String get chatVoted => 'Da binh chon';

  @override
  String chatReplyTo(String name) {
    return 'Tra loi $name';
  }

  @override
  String get chatCurrentLocation => 'Vi tri hien tai';

  @override
  String chatNearbyPlace(int index) {
    return 'Dia diem gan $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'Khoang $distance';
  }

  @override
  String get chatAddress => 'Dia chi';

  @override
  String get chatLatitude => 'Vi do';

  @override
  String get chatLongitude => 'Kinh do';

  @override
  String get groupDescriptionUpdated => 'Đã cập nhật mô tả nhóm';

  @override
  String get groupAvatarUpdated => 'Đã cập nhật ảnh đại diện nhóm';

  @override
  String get groupVisibilityUpdated => 'Đã cập nhật chế độ hiển thị nhóm';

  @override
  String get groupChannelCreated => 'Đã tạo kênh';

  @override
  String get groupChannelUpdated => 'Đã cập nhật kênh';

  @override
  String get groupChannelDeleted => 'Đã xóa kênh';

  @override
  String get callDecline => 'Tu choi';

  @override
  String get callAnswer => 'Tra loi';

  @override
  String get callIncomingVideoCall => 'Cuộc gọi video đến';

  @override
  String get callIncomingVoiceCall => 'Cuộc gọi thoại đến';

  @override
  String get callVideoCallInProgress => 'Cuộc gọi video';

  @override
  String get callVoiceCallInProgress => 'Cuộc gọi thoại';

  @override
  String get callReconnectingCall => 'Đang kết nối lại...';

  @override
  String get callEnded => 'Cuộc gọi kết thúc';

  @override
  String get callFailed => 'Cuộc gọi thất bại';

  @override
  String get callLivekitNotConfigured => 'LiveKit chua duoc cau hinh';

  @override
  String callJoinMeetingFailed(String error) {
    return 'Tham gia cuoc hop that bai: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'Chia se man hinh that bai: $error';
  }

  @override
  String get profileN42BeanTitle => 'Đậu N42';

  @override
  String get profileNoN42Bean => 'Không có N42 Bean';

  @override
  String get profileN42BeanDetails => 'Chi tiết N42 Bean';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean là token dùng để đổi vật phẩm ảo và dịch vụ trong N42. Hiện có thể dùng cho:';

  @override
  String get profileN42BeanFeature1 =>
      'Nhãn dán và chủ đề độc quyền cho thành viên';

  @override
  String get profileN42BeanFeature2 => 'Tùy chỉnh bong bóng chat';

  @override
  String get profileN42BeanFeature3 => 'Tùy chỉnh bìa phong bao đỏ';

  @override
  String get profileN42BeanFeature4 => 'Huy hiệu biệt danh độc quyền';

  @override
  String get profileN42BeanFeature5 => 'Đặc quyền trò chuyện nhóm';

  @override
  String get profileN42BeanFeature6 => 'Mở rộng lưu trữ đám mây';

  @override
  String get profileN42BeanFeature7 => 'Bộ lọc làm đẹp cuộc gọi video';

  @override
  String get profileN42BeanFeature8 => 'Tùy chỉnh nền Khoảnh khắc';

  @override
  String get profileN42BeanFeature9 => 'Ưu tiên dịch vụ khách hàng VIP';

  @override
  String get profileGotIt => 'Đã hiểu';

  @override
  String get profileNoN42BeanRecords => 'Không có bản ghi N42 Bean';

  @override
  String get profileMoodAndThoughts => 'Tam trang & Suy nghi';

  @override
  String get profileStatusHappy => 'Vui ve';

  @override
  String get profileStatusCracked => 'Vo tan';

  @override
  String get profileStatusLucky => 'May man';

  @override
  String get profileStatusSunny => 'Nang ve';

  @override
  String get profileStatusTired => 'Met moi';

  @override
  String get profileStatusDaydream => 'Mo mong';

  @override
  String get profileStatusRushing => 'Ban ron';

  @override
  String get profileStatusOverthinking => 'Suy nghi qua nhieu';

  @override
  String get profileStatusEnergized => 'Day nang luong';

  @override
  String get profileWorkAndStudy => 'Cong viec & Hoc tap';

  @override
  String get profileStatusWorking => 'Dang lam viec';

  @override
  String get profileStatusStudying => 'Dang hoc';

  @override
  String get profileStatusBusy => 'Ban';

  @override
  String get profileStatusSlacking => 'Nghi ngoi';

  @override
  String get profileStatusTraveling => 'Di du lich';

  @override
  String get profileStatusGoingHome => 'Ve nha';

  @override
  String get profileStatusDnd => 'Khong lam phien';

  @override
  String get profileActivities => 'Hoat dong';

  @override
  String get profileStatusHanging => 'Di choi';

  @override
  String get profileStatusCheckIn => 'Diem danh';

  @override
  String get profileStatusExercising => 'Tap the duc';

  @override
  String get profileStatusCoffee => 'Uong ca phe';

  @override
  String get profileStatusBubbleTea => 'Uong tra sua';

  @override
  String get profileStatusEating => 'An uong';

  @override
  String get profileStatusParenting => 'Cham con';

  @override
  String get profileStatusSavingWorld => 'Cuu the gioi';

  @override
  String get profileStatusSelfie => 'Chup selfie';

  @override
  String get profileRest => 'Nghi ngoi';

  @override
  String get profileStatusRetreat => 'An cu';

  @override
  String get profileStatusHome => 'O nha';

  @override
  String get profileStatusSleeping => 'Dang ngu';

  @override
  String get profileStatusCatLover => 'Nguoi yeu meo';

  @override
  String get profileStatusDogWalking => 'Dat cho di dao';

  @override
  String get profileStatusGaming => 'Choi game';

  @override
  String get profileStatusListening => 'Dang nghe';

  @override
  String get profileEditAddress => 'Chinh sua dia chi';

  @override
  String get profileRecipient => 'Nguoi nhan';

  @override
  String get profileEnterRecipientName => 'Nhap ten nguoi nhan';

  @override
  String get profilePhoneNumber => 'So dien thoai';

  @override
  String get profileEnterPhoneNumber => 'Nhap so dien thoai';

  @override
  String get profileRegionHint => 'Tinh/Thanh pho/Quan';

  @override
  String get profileDetailedAddress => 'Dia chi chi tiet';

  @override
  String get profileDetailedAddressHint => 'Duong, so nha, v.v.';

  @override
  String get profileSetAsDefaultAddress => 'Dat lam dia chi mac dinh';

  @override
  String get profilePleaseCompleteInfo => 'Vui long dien day du thong tin';

  @override
  String get profileEditInvoice => 'Chinh sua hoa don';

  @override
  String get profileInvoiceType => 'Loai hoa don: ';

  @override
  String get profileCompanyName => 'Ten cong ty';

  @override
  String get profilePersonalName => 'Ten ca nhan';

  @override
  String get profileEnterCompanyName => 'Nhap ten cong ty';

  @override
  String get profileEnterName => 'Nhap ten';

  @override
  String get profileTaxIdNumber => 'Ma so thue';

  @override
  String get profileEnterTaxIdNumber => 'Nhap ma so thue';

  @override
  String get profileBankNameOptional => 'Ten ngan hang (Tuy chon)';

  @override
  String get profileEnterBankName => 'Nhap ten ngan hang';

  @override
  String get profileBankAccountOptional => 'Tai khoan ngan hang (Tuy chon)';

  @override
  String get profileEnterBankAccount => 'Nhap tai khoan ngan hang';

  @override
  String get profileCompanyAddressOptional => 'Dia chi cong ty (Tuy chon)';

  @override
  String get profileEnterCompanyAddress => 'Nhap dia chi cong ty';

  @override
  String get profileCompanyPhoneOptional => 'Dien thoai cong ty (Tuy chon)';

  @override
  String get profileEnterCompanyPhone => 'Nhap dien thoai cong ty';

  @override
  String get profileSetAsDefaultInvoice => 'Dat lam hoa don mac dinh';

  @override
  String get profileRingtoneVibrate => 'Rung';

  @override
  String get profileRingtoneSilent => 'Im lang';

  @override
  String get profileVibrateMode => 'Che do rung';

  @override
  String get profileSilentMode => 'Che do im lang';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'Phat that bai: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'Dang phat: $ringtoneName';
  }

  @override
  String get profileStop => 'Dung';

  @override
  String get profileSelectRingtone => 'Chon nhac chuong';

  @override
  String get profileLoadingRingtones => 'Dang tai nhac chuong...';

  @override
  String get profileNoRingtonesFound => 'Khong tim thay nhac chuong';

  @override
  String mainMessagesWithCount(int count) {
    return 'Tin nhan($count)';
  }

  @override
  String get storyViewers => 'Người xem';

  @override
  String get storyNoViewers => 'Chưa có người xem';

  @override
  String get storyReplyToStory => 'Trả lời trạng thái...';

  @override
  String get commonCopiedToClipboard => 'Da sao chep vao clipboard';

  @override
  String get commonMore => 'Them';

  @override
  String get commonTranslating => 'Đang dịch...';

  @override
  String commonTranslatedFrom(String language) {
    return 'Dịch từ $language';
  }

  @override
  String get commonTranslation => 'Bản dịch';

  @override
  String get commonTranslationFailed => 'Dịch thất bại';

  @override
  String get commonAllRead => 'Da doc tat ca';

  @override
  String commonReadCount(int count) {
    return '$count da doc';
  }

  @override
  String get commonYouRecalledMessage => 'Ban da thu hoi mot tin nhan';

  @override
  String get commonMessageRecalled => 'Tin nhan da thu hoi';

  @override
  String get commonReEdit => 'Chinh sua lai';

  @override
  String get commonWalletArea => 'Khu vuc vi';

  @override
  String get callIncomingCall => 'Cuoc goi den';

  @override
  String get callMissedCall => 'Cuoc goi nho';

  @override
  String get groupRemoveAdmin => 'Xoa quyen quan tri';

  @override
  String get chatSelectCurrency => 'Chon loai tien';

  @override
  String get chatSelectEmoji => 'Chon bieu tuong cam xuc';

  @override
  String get chatSelectRedPacketCover => 'Chon bia';

  @override
  String get groupSetAsAdmin => 'Dat lam quan tri vien';

  @override
  String get chatVideoPlaybackFailed => 'Phat video that bai';

  @override
  String get groupViewProfile => 'Xem ho so';

  @override
  String get favoriteAddLinkComingSoon => 'Tinh nang them lien ket sap ra mat';

  @override
  String get favoriteNewNoteComingSoon => 'Tinh nang ghi chu moi sap ra mat';

  @override
  String get qrcodeSaveFeatureComingSoon => 'Tinh nang luu sap ra mat';

  @override
  String get qrcodeShareFeatureComingSoon => 'Tinh nang chia se sap ra mat';

  @override
  String qrcodeProcessFailed(String error) {
    return 'Xu ly ma QR that bai: $error';
  }

  @override
  String get securityDeviceIdRequired => 'ID thiết bị là bắt buộc';

  @override
  String securityVerificationStartFailed(String error) {
    return 'Không thể bắt đầu xác minh: $error';
  }

  @override
  String get securityVerificationFailed => 'Xác minh không thành công';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'Xác minh không thành công: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'Xác minh bị từ chối - biểu tượng cảm xúc không khớp';

  @override
  String get securityWaitingForDeviceAccept =>
      'Đang chờ thiết bị kia chấp nhận...';

  @override
  String get securityVerifyDevice => 'Xác minh thiết bị này';

  @override
  String get securityConfirmEmojiMatch =>
      'Xác nhận biểu tượng cảm xúc bên dưới được hiển thị trên cả hai thiết bị, theo cùng một thứ tự';

  @override
  String get securityEmojiDontMatch => 'Họ không phù hợp';

  @override
  String get securityEmojiMatch => 'Họ hợp nhau';

  @override
  String get securityWaitingForDeviceConfirm =>
      'Đang chờ thiết bị kia xác nhận...';

  @override
  String get securityVerificationSuccess => 'Xác minh thành công!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'Thiết bị này hiện đã được xác minh và tin cậy.';

  @override
  String get securityCompareEmoji =>
      'So sánh biểu tượng cảm xúc trên cả hai thiết bị';

  @override
  String get securityCompareNumbers =>
      'So sánh các con số trên cả hai thiết bị';

  @override
  String get commonTryAgain => 'Thử lại';

  @override
  String get commonDone => 'Xong';

  @override
  String get chatExportTitle => 'Xuất trò chuyện';

  @override
  String get chatExportSuccess => 'Xuất thành công';

  @override
  String chatExportFailed(String error) {
    return 'Xuất không thành công: $error';
  }

  @override
  String get chatExportFormat => 'Định dạng xuất';

  @override
  String get chatExportHtmlDesc =>
      'Có thể đọc được trong bất kỳ trình duyệt nào có bố cục theo kiểu';

  @override
  String get chatExportJsonDesc =>
      'Định dạng dữ liệu có cấu trúc có thể đọc được bằng máy';

  @override
  String get chatExportDateRange => 'Phạm vi ngày';

  @override
  String get chatExportAll => 'Tất cả tin nhắn';

  @override
  String get chatExportLastWeek => '7 ngày qua';

  @override
  String get chatExportLastMonth => 'Tháng trước';

  @override
  String get chatExportLast3Months => '3 tháng qua';

  @override
  String get chatExportMessageCount => 'Tin nhắn để xuất';

  @override
  String get chatExportButton => 'Xuất & Chia sẻ';

  @override
  String get chatMediaGallery => 'Thư viện phương tiện';

  @override
  String get chatExportHistory => 'Xuất lịch sử trò chuyện';

  @override
  String get pdfLoadFailed => 'Không tải được PDF';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'Tất cả';

  @override
  String get mediaImages => 'Hình ảnh';

  @override
  String get mediaVideos => 'Video';

  @override
  String get mediaFiles => 'Tập tin';

  @override
  String get mediaAudio => 'Âm thanh';

  @override
  String mediaItemsCount(int count) {
    return 'Vật phẩm $count';
  }

  @override
  String get mediaNoMediaFound => 'Không tìm thấy phương tiện nào';

  @override
  String get spacesTitle => 'Cộng đồng';

  @override
  String get spacesCreate => 'Tạo cộng đồng';

  @override
  String get spacesJoined => 'Đã tham gia';

  @override
  String get spacesDiscover => 'Khám phá';

  @override
  String get spacesNoJoined => 'Chưa có cộng đồng nào tham gia';

  @override
  String get spacesExplore => 'Khám phá cộng đồng';

  @override
  String get spacesNoPublic => 'Không tìm thấy cộng đồng công cộng nào';

  @override
  String get spacesJoin => 'Tham gia';

  @override
  String get spacesSubSpaces => 'Tiểu cộng đồng';

  @override
  String get spacesChannels => 'Kênh';

  @override
  String spacesMembersCount(int count) {
    return 'Thành viên $count';
  }

  @override
  String get spacesPublic => 'công cộng';

  @override
  String get spacesPrivate => 'Riêng tư';

  @override
  String get spacesSuggested => 'được đề xuất';

  @override
  String spacesChannelsCount(int count) {
    return 'Các kênh $count';
  }

  @override
  String get callInCallChat => 'Trò chuyện trong cuộc gọi';

  @override
  String callMessagesCount(int count) {
    return 'Tin nhắn $count';
  }

  @override
  String get callNoMessagesYet =>
      'Chưa có tin nhắn nào.\nGửi tin nhắn để bắt đầu.';

  @override
  String get callTypeMessage => 'Nhập tin nhắn...';

  @override
  String get callYouSender => 'bạn';

  @override
  String get callChatLabel => 'Trò chuyện';

  @override
  String get chatEdited => 'Đã chỉnh sửa';

  @override
  String get chatEditHistory => 'Chỉnh sửa lịch sử';

  @override
  String get chatOriginalMessage => 'Bản gốc';

  @override
  String chatEditedAt(String time) {
    return 'Đã chỉnh sửa tại $time';
  }

  @override
  String get chatViewOnce => 'Xem một lần';

  @override
  String get chatViewOncePhoto => 'Xem ảnh một lần';

  @override
  String get chatViewOnceVideo => 'Xem một lần video';

  @override
  String get chatViewOnceViewed => 'Đã xem';

  @override
  String get chatViewOnceExpired => 'Đã hết hạn';

  @override
  String get chatViewOnceTap => 'Nhấn để xem';

  @override
  String get chatAutoFaceBlur => 'Tự động làm mờ khuôn mặt';

  @override
  String get chatAutoFaceBlurDesc => 'Tự động làm mờ khuôn mặt khi gửi ảnh';

  @override
  String get threadReplyInThread => 'Trả lời trong chủ đề';

  @override
  String threadReplies(int count) {
    return '$count trả lời';
  }

  @override
  String get threadReply => '1 câu trả lời';

  @override
  String threadLatestReply(String preview) {
    return 'Mới nhất: $preview';
  }

  @override
  String get threadTitle => 'chủ đề';

  @override
  String get threadReplyPlaceholder => 'Trả lời trong chủ đề...';

  @override
  String threadParticipants(int count) {
    return 'Người tham gia $count';
  }

  @override
  String get voiceRoomTitle => 'Phòng thoại';

  @override
  String get voiceRoomCreate => 'Tạo phòng thoại';

  @override
  String get voiceRoomJoin => 'Tham gia';

  @override
  String get voiceRoomLeave => 'Rời khỏi';

  @override
  String get voiceRoomEnd => 'Phòng cuối';

  @override
  String get voiceRoomRaiseHand => 'Giơ tay';

  @override
  String get voiceRoomLowerHand => 'Hạ tay';

  @override
  String get voiceRoomMute => 'Tắt tiếng';

  @override
  String get voiceRoomUnmute => 'Bật tiếng';

  @override
  String get voiceRoomHost => 'Máy chủ';

  @override
  String get voiceRoomSpeakers => 'Loa';

  @override
  String get voiceRoomListeners => 'Người nghe';

  @override
  String get voiceRoomLive => 'TRỰC TIẾP';

  @override
  String get voiceRoomEnded => 'Đã kết thúc';

  @override
  String get voiceRoomScheduled => 'Đã lên lịch';

  @override
  String get voiceRoomApprove => 'Phê duyệt';

  @override
  String get voiceRoomDemote => 'Di chuyển đến Trình nghe';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name giơ tay';
  }

  @override
  String get voiceRoomName => 'Tên phòng';

  @override
  String get voiceRoomTopic => 'Chủ đề (tùy chọn)';

  @override
  String get voiceRoomNoActive => 'Không có phòng thoại đang hoạt động';

  @override
  String get voiceRoomConnecting => 'Đang kết nối...';

  @override
  String get usernameTitle => 'Tên người dùng';

  @override
  String get usernameSet => 'Đặt tên người dùng';

  @override
  String get usernameChange => 'Thay đổi tên người dùng';

  @override
  String get usernamePlaceholder => 'Nhập tên người dùng';

  @override
  String get usernameAvailable => 'Tên người dùng có sẵn';

  @override
  String get usernameUnavailable => 'Tên người dùng đã được sử dụng';

  @override
  String get usernameInvalid =>
      '3-30 ký tự, chữ thường, số, dấu gạch dưới. Phải bắt đầu bằng một chữ cái.';

  @override
  String get usernameReserved => 'Tên người dùng này được bảo lưu';

  @override
  String get usernameSaved => 'Đã lưu tên người dùng';

  @override
  String get usernameSearchHint => 'Tìm kiếm theo @tên người dùng';

  @override
  String get ensName => 'Tên ENS';

  @override
  String get ensLinked => 'Đã liên kết với ENS';

  @override
  String get ensResolving => 'Giải quyết ENS...';

  @override
  String get ensNotFound => 'Không tìm thấy tên ENS';

  @override
  String get tokenGateTitle => 'Cổng mã thông báo';

  @override
  String get tokenGateEnable => 'Kích hoạt Cổng Token';

  @override
  String get tokenGateDisable => 'Tắt cổng mã thông báo';

  @override
  String get tokenGateAddRule => 'Thêm quy tắc';

  @override
  String get tokenGateRemoveRule => 'Xóa quy tắc';

  @override
  String get tokenGateContractAddress => 'Địa chỉ hợp đồng';

  @override
  String get tokenGateMinBalance => 'Số dư tối thiểu';

  @override
  String get tokenGateTokenId => 'ID mã thông báo (ERC-1155)';

  @override
  String get tokenGateChainId => 'ID chuỗi';

  @override
  String get tokenGateVerifying => 'Đang xác minh việc nắm giữ mã thông báo...';

  @override
  String get tokenGateVerified => 'Xác minh đã được thông qua';

  @override
  String get tokenGateDenied => 'Bạn không đáp ứng các yêu cầu về mã thông báo';

  @override
  String get tokenGateOperatorAnd => 'Phải đáp ứng TẤT CẢ các quy tắc';

  @override
  String get tokenGateOperatorOr => 'Phải đáp ứng BẤT KỲ quy tắc nào';

  @override
  String get tokenGateRuleErc20 => 'Mã thông báo ERC-20';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'Mã thông báo đa năng (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'Mã thông báo gốc';

  @override
  String get tokenGateSaved => 'Đã lưu cổng mã thông báo';

  @override
  String get tokenGateEnableDescription =>
      'Yêu cầu thành viên phải giữ token để tham gia';

  @override
  String get tokenGateOperator => 'Quy tắc logic';

  @override
  String get tokenGateRules => 'Quy tắc';

  @override
  String get tokenGateSymbol => 'Biểu tượng (tùy chọn)';

  @override
  String get tokenGateChain => 'Chuỗi';

  @override
  String get tokenGateTokenStandard => 'Tiêu chuẩn mã thông báo';

  @override
  String get tokenGateDenialMessage => 'Tin nhắn từ chối';

  @override
  String get tokenGateDenialMessageHint =>
      'Thông báo hiển thị khi xác minh không thành công';

  @override
  String get tokenGateVerifyTitle => 'Xác minh mã thông báo';

  @override
  String get tokenGateVerifyPassed => 'Xác minh đã thông qua';

  @override
  String get tokenGateVerifyFailed => 'Xác minh không thành công';

  @override
  String get tokenGateRetryVerify => 'Thử lại';

  @override
  String get tokenGateRequired => 'Bắt buộc';

  @override
  String get tokenGateYourBalance => 'Số dư của bạn';

  @override
  String get tokenGateRulesActive => 'quy tắc hoạt động';

  @override
  String get tokenGateDisabled => 'Đã tắt';

  @override
  String get ensNotBound => 'Không bị ràng buộc';

  @override
  String get liveLocation => 'Vị trí trực tiếp';

  @override
  String get stopLiveLocation => 'Dừng chia sẻ';

  @override
  String get startLiveLocation => 'Bắt đầu chia sẻ';

  @override
  String get selectDuration => 'Chọn thời lượng';

  @override
  String get groupChatFiles => 'Tệp trò chuyện';

  @override
  String get groupLinks => 'Liên kết';

  @override
  String get groupNoLinks => 'Chưa có liên kết nào';

  @override
  String get chatBackground => 'Nền trò chuyện';

  @override
  String get solidColors => 'Màu sắc đồng nhất';

  @override
  String get gradients => 'Độ dốc';

  @override
  String get defaultBackground => 'Mặc định';

  @override
  String get settingsFontSizeSlider => 'Cỡ chữ';

  @override
  String get autoDownload => 'Tự động tải xuống';

  @override
  String get images => 'Hình ảnh';

  @override
  String get voice => 'Giọng nói';

  @override
  String get video => 'Băng hình';

  @override
  String get files => 'Tập tin';

  @override
  String get mobileData => 'Dữ liệu di động';

  @override
  String get roaming => 'Chuyển vùng';

  @override
  String get storageManagement => 'Lưu trữ';

  @override
  String get totalUsage => 'Tổng mức sử dụng';

  @override
  String get cache => 'Bộ nhớ đệm';

  @override
  String get other => 'Khác';

  @override
  String get clearCache => 'Xóa bộ nhớ đệm';

  @override
  String get cacheCleared => 'Đã xóa bộ nhớ đệm';

  @override
  String get clearCacheFailed => 'Không xóa được bộ nhớ đệm';

  @override
  String get confirmClearCache => 'Xóa tất cả dữ liệu bộ nhớ đệm?';

  @override
  String get mapView => 'Xem bản đồ';

  @override
  String liveLocationSharingCount(int count) {
    return '$count người chia sẻ vị trí';
  }

  @override
  String get minutes15 => '15 phút';

  @override
  String get minutes30 => '30 phút';

  @override
  String get hour1 => '1 giờ';

  @override
  String get hours8 => '8 giờ';

  @override
  String get personalCard => 'Thẻ cá nhân';

  @override
  String get downloadFailed => 'Tải xuống không thành công';

  @override
  String get locationExpired => 'Đã hết hạn';

  @override
  String secondsRemaining(int count) {
    return '$count';
  }

  @override
  String minutesRemaining(int count) {
    return '$count phút';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours giờ $minutes phút';
  }

  @override
  String get favoriteMessages => 'Yêu thích';

  @override
  String get linksCopied => 'Đã sao chép liên kết';

  @override
  String get noLinksFound => 'Không tìm thấy liên kết nào';

  @override
  String get roomStorageRanking => 'Xếp hạng lưu trữ phòng';

  @override
  String get downloadComplete => 'Tải xuống hoàn tất';

  @override
  String get downloading => 'Đang tải xuống...';

  @override
  String get draftSaved => 'Đã lưu bản nháp';

  @override
  String get voiceRecording => 'Ghi âm giọng nói';

  @override
  String get searchLocation => 'Tìm kiếm vị trí';

  @override
  String get tapToSearch => 'Nhấn để tìm kiếm';

  @override
  String get settingsThisDevice => 'Thiết bị này';

  @override
  String get settingsJustNow => 'Vừa rồi';

  @override
  String get settingsDeviceId => 'ID thiết bị';

  @override
  String get settingsStatus => 'Trạng thái';

  @override
  String get settingsLastActive => 'Hoạt động lần cuối';

  @override
  String get settingsIpAddress => 'địa chỉ IP';

  @override
  String get settingsRenameDevice => 'Đổi tên thiết bị';

  @override
  String get settingsDeviceNameHint => 'Nhập tên thiết bị';

  @override
  String get settingsDeviceRenamed => 'Đã đổi tên thiết bị';

  @override
  String get settingsRenameFailed => 'Đổi tên không thành công';

  @override
  String get settingsRemoteLogout => 'Đăng xuất từ xa';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'Bạn có chắc chắn muốn đăng xuất \"$deviceName\" không? Không thể hoàn tác hành động này.';
  }

  @override
  String get settingsDeviceLoggedOut => 'Thiết bị đã đăng xuất';

  @override
  String get settingsLogoutFailed => 'Đăng xuất không thành công';

  @override
  String get settingsLogout => 'Đăng xuất';

  @override
  String get settingsVerifyIdentity => 'Xác minh danh tính';

  @override
  String get settingsEnterPasswordToConfirm =>
      'Nhập mật khẩu của bạn để xác nhận hành động này.';

  @override
  String get scheduledSendTitle => 'Lên lịch nhắn tin';

  @override
  String get scheduledSendInOneHour => 'trong 1 giờ';

  @override
  String get scheduledSendTonight => 'Tối nay (8 giờ tối)';

  @override
  String get scheduledSendTomorrowMorning => 'Sáng mai (9 giờ sáng)';

  @override
  String get scheduledSendCustom => 'Chọn ngày và giờ';

  @override
  String get scheduledMessageLabel => 'Đã lên lịch';

  @override
  String get scheduledMessageCancel => 'Hủy tin nhắn đã lên lịch';

  @override
  String get chatLockTitle => 'Khóa trò chuyện';

  @override
  String get chatLockEnable => 'Khóa cuộc trò chuyện này';

  @override
  String get chatLockDisable => 'Mở khóa cuộc trò chuyện này';

  @override
  String get chatLockDescription =>
      'Các cuộc trò chuyện bị khóa yêu cầu xác minh sinh trắc học hoặc mã PIN để mở';

  @override
  String get chatLockVerifyTitle => 'Đã khóa cuộc trò chuyện';

  @override
  String get chatLockVerifySubtitle =>
      'Xác minh để truy cập cuộc trò chuyện này';

  @override
  String get chatLockVerifyFailed => 'Xác minh không thành công';

  @override
  String get chatLockEnabled => 'Đã khóa cuộc trò chuyện';

  @override
  String get chatLockDisabled => 'Đã mở khóa trò chuyện';

  @override
  String get chatLockPinTitle => 'Nhập mã PIN';

  @override
  String get chatLockPinSetTitle => 'Đặt mã PIN';

  @override
  String get chatLockPinConfirmTitle => 'Xác nhận mã PIN';

  @override
  String get chatLockPinMismatch => 'Mã PIN không khớp';

  @override
  String get chatLockUseBiometric => 'Sử dụng sinh trắc học';

  @override
  String get chatLockUsePin => 'Sử dụng mã PIN';

  @override
  String get mediaEditorUndo => 'Hoàn tác';

  @override
  String get mediaEditorRedo => 'Làm lại';

  @override
  String get mediaEditorCrop => 'Cắt';

  @override
  String get mediaEditorFilter => 'Lọc';

  @override
  String get mediaEditorDraw => 'Vẽ';

  @override
  String get mediaEditorText => 'văn bản';

  @override
  String get aiAssistant => 'Trợ lý AI';

  @override
  String get aiAssistantWelcome =>
      'Xin chào! Tôi là Trợ lý AI N42. Tôi có thể giúp gì cho bạn?';

  @override
  String get aiAssistantNotConfigured => 'Dịch vụ AI chưa được định cấu hình';

  @override
  String get aiAssistantSettings => 'Cài đặt AI';

  @override
  String get aiAssistantClearHistory => 'Xóa lịch sử trò chuyện';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'Bạn có chắc chắn muốn xóa tất cả lịch sử trò chuyện AI không?';

  @override
  String get aiAssistantStopGenerating => 'Dừng tạo';

  @override
  String get aiAssistantModel => 'người mẫu';

  @override
  String get aiAssistantTemperature => 'Nhiệt độ';

  @override
  String get aiAssistantMaxTokens => 'Mã thông báo tối đa';

  @override
  String get aiAssistantContextWindow => 'Cửa sổ ngữ cảnh';

  @override
  String get aiAssistantServiceStatus => 'Trạng thái dịch vụ';

  @override
  String get aiAssistantAvailable => 'Có sẵn';

  @override
  String get aiAssistantUnavailable => 'Không có sẵn';

  @override
  String get aiSummarize => 'Tóm tắt AI';

  @override
  String aiSummarizeUnread(int count) {
    return 'Tổng hợp $count tin nhắn chưa đọc';
  }

  @override
  String get aiSummarizeLoading => 'Tóm tắt...';

  @override
  String get aiSummarizeError => 'Không thể tóm tắt';

  @override
  String get aiRewrite => 'Viết lại AI';

  @override
  String get aiRewriteFormal => 'chính thức';

  @override
  String get aiRewriteCasual => 'Bình thường';

  @override
  String get aiRewritePlayful => 'vui tươi';

  @override
  String get aiRewriteProfessional => 'chuyên nghiệp';

  @override
  String get aiRewriteAccept => 'sử dụng';

  @override
  String get aiRewriteCancel => 'Hủy bỏ';

  @override
  String get aiRewriteLoading => 'Viết lại...';

  @override
  String get aiLinkSummary => 'Tóm tắt AI';

  @override
  String get aiLinkSummaryAnalyzing => 'Đang phân tích...';

  @override
  String get chatFolderManagement => 'Quản lý thư mục';

  @override
  String get chatFolderSystem => 'Thư mục hệ thống';

  @override
  String get chatFolderCustom => 'Thư mục tùy chỉnh';

  @override
  String get chatFolderEmpty => 'Chưa có thư mục tùy chỉnh nào';

  @override
  String get chatFolderCreate => 'Tạo thư mục';

  @override
  String get chatFolderEdit => 'Chỉnh sửa thư mục';

  @override
  String get chatFolderNameHint => 'Tên thư mục';

  @override
  String get chatFolderAll => 'Tất cả';

  @override
  String get chatFolderUnread => 'Chưa đọc';

  @override
  String get chatFolderPersonal => 'cá nhân';

  @override
  String get chatFolderGroups => 'Nhóm';

  @override
  String get chatFolderChannels => 'Kênh';

  @override
  String get chatFolderMuted => 'Đã tắt tiếng';

  @override
  String get storyAddMusic => 'Thêm nhạc';

  @override
  String get storyChangeMusic => 'Thay đổi âm nhạc';

  @override
  String get storyBackgroundMusic => 'Nhạc nền';

  @override
  String get storyMusicPreview => 'Xem trước (tối đa 15 giây)';

  @override
  String get storyChooseFromDevice => 'Chọn từ thiết bị';

  @override
  String get storyUseThisMusic => 'Sử dụng nhạc này';

  @override
  String get authPasskeyNotSupported =>
      'Mật mã không được hỗ trợ trên thiết bị này';

  @override
  String get authPasskeyRegister => 'Đăng ký mật khẩu';

  @override
  String get authPasskeyNoRegistered => 'Không có mật mã nào được đăng ký';

  @override
  String get authPasskeyRegisterHint =>
      'Đăng ký mật mã cho tài khoản này. Đăng nhập bằng mật mã độc lập sẽ được kích hoạt sau.';

  @override
  String get authPasskeyNameYours => 'Đặt tên cho mật mã của bạn';

  @override
  String get authPasskeyRegistered => 'Đã lưu mật mã vào tài khoản này';

  @override
  String get authPasskeyDeleted => 'Mật mã đã bị xóa khỏi tài khoản này';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'Xóa mật mã \"$name\"? Bạn sẽ cần phải đăng ký lại trước khi sử dụng mật mã đăng nhập sau này.';
  }

  @override
  String get momentVisibilityPublic => 'công cộng';

  @override
  String get momentVisibilityPrivate => 'Riêng tư';

  @override
  String get momentVisibilityPartial => 'Bạn bè đã chọn';

  @override
  String get momentVisibilityExcluded => 'Loại trừ một số bạn bè';

  @override
  String momentUserMoments(String userName) {
    return 'Những khoảnh khắc của $userName';
  }

  @override
  String get momentForwardTo => 'Chuyển tiếp tới';

  @override
  String get momentForwardSuccess => 'Đã chuyển tiếp thành công';

  @override
  String get momentSelectFriends => 'Chọn bạn bè';

  @override
  String get momentSelectTags => 'Chọn theo Thẻ';

  @override
  String momentSelectedCount(int count) {
    return 'Đã chọn ($count)';
  }

  @override
  String get momentNoMomentsYet => 'Chưa có khoảnh khắc nào';

  @override
  String get momentForwardMoment => 'Khoảnh khắc chuyển tiếp';

  @override
  String get momentAddComment => 'Thêm một bình luận...';

  @override
  String momentForwardContent(String content) {
    return '[Khoảnh khắc] $content';
  }

  @override
  String get momentDeleteMoment => 'Xóa khoảnh khắc';

  @override
  String get momentDeleteConfirm =>
      'Bạn có chắc chắn muốn xóa khoảnh khắc này?';

  @override
  String get momentComment => 'Bình luận';

  @override
  String get momentWriteComment => 'Viết bình luận...';

  @override
  String get momentLike => 'thích';

  @override
  String get momentUnlike => 'Không giống';

  @override
  String get momentForward => 'Chuyển tiếp';

  @override
  String get momentDelete => 'Xóa';

  @override
  String get momentReply => 'trả lời';

  @override
  String get momentMoment => 'Khoảnh khắc';

  @override
  String momentLikesCount(int count) {
    return '$count lượt thích';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count bình luận';
  }

  @override
  String get momentNoComments => 'Chưa có bình luận nào';

  @override
  String get momentFailedToLoad => 'Không thể tải hình ảnh';

  @override
  String momentReplyTo(String userName) {
    return 'Trả lời $userName...';
  }

  @override
  String get momentNoConversations => 'Không có cuộc trò chuyện nào';

  @override
  String get momentJustNow => 'ngay bây giờ';

  @override
  String momentMinutesAgo(int count) {
    return '${count}m trước đây';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h trước';
  }

  @override
  String momentDaysAgo(int count) {
    return '${count}d trước';
  }

  @override
  String get chatGroupAnnouncementHint => 'Nhập thông báo nhóm';

  @override
  String get chatGroupAnnouncementEmpty => 'Không có thông báo';

  @override
  String get chatEditNickname => 'Chỉnh sửa biệt hiệu';

  @override
  String get chatNicknameHint => 'Nhập biệt hiệu của bạn vào nhóm này';

  @override
  String get contactAddPhoneHint => 'Nhập số điện thoại';

  @override
  String get contactNotesHint => 'Thêm ghi chú về liên hệ này';

  @override
  String get reportTitle => 'Báo cáo';

  @override
  String get reportReasonSpam => 'Thư rác';

  @override
  String get reportReasonHarassment => 'Quấy rối';

  @override
  String get reportReasonFraud => 'Lừa đảo';

  @override
  String get reportReasonOther => 'Khác';

  @override
  String get reportSubmitted => 'Đã gửi báo cáo';

  @override
  String get reportDescription => 'Mô tả bổ sung (tùy chọn)';

  @override
  String get qrcodeSaved => 'Đã lưu mã QR vào album';

  @override
  String get chatSendRedPacketInChat =>
      'Vui lòng gửi gói màu đỏ trong trò chuyện';

  @override
  String get commonSaveFailed => 'Lưu không thành công';

  @override
  String get reportSelectReason => 'Vui lòng chọn một lý do';

  @override
  String get gameCenter => 'Trò chơi';

  @override
  String get gameHighScore => 'Tốt nhất';

  @override
  String get gameScore => 'Điểm';

  @override
  String get gameOver => 'Kết thúc';

  @override
  String get gamePlayAgain => 'Chơi lại';

  @override
  String get gameLeaderboard => 'Bảng xếp hạng';

  @override
  String get gamePause => 'Tạm dừng';

  @override
  String get gameResume => 'Chạm để tiếp tục';

  @override
  String get gameConfirmExit => 'Thoát trò chơi?';

  @override
  String get gameNoScores => 'Chưa có điểm';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'Ghép ô để đạt 2048';

  @override
  String get gameBlockDrop => 'Khối thả';

  @override
  String get gameBlockDropDesc => 'Thả và xóa các hàng';

  @override
  String get gameMinesweeper => 'Dò mìn';

  @override
  String get gameMinesweeperDesc => 'Tìm tất cả ô an toàn';

  @override
  String get gameMatch3 => 'Trận đấu 3';

  @override
  String get gameMatch3Desc => 'Nối 3 viên đá quý trở lên';

  @override
  String get gameMinesweeperEasy => 'Dễ';

  @override
  String get gameMinesweeperMedium => 'Trung bình';

  @override
  String get gameMinesLeft => 'Mìn còn lại';

  @override
  String get gameTimeLeft => 'Thời gian';

  @override
  String get gameLevel => 'Cấp độ';

  @override
  String get gameNext => 'Tiếp theo';

  @override
  String get gameBestTime => 'Thời gian tốt nhất';

  @override
  String get gameNewRecord => 'Kỷ lục mới!';

  @override
  String get gameLines => 'Hàng';

  @override
  String get storyMyStory => 'Câu chuyện của tôi';

  @override
  String get storageSmartCleanup => 'Dọn dẹp thông minh';

  @override
  String get storageOldMediaFiles => 'Tệp phương tiện cũ';

  @override
  String get storageLargeFiles => 'Tệp lớn';

  @override
  String get storageAppCache => 'Bộ đệm ứng dụng';

  @override
  String get storageSettings => 'Cài đặt lưu trữ';

  @override
  String get storageAutoCleanup => 'Tự động dọn dẹp';

  @override
  String storageAutoCleanupDesc(int days) {
    return 'Tự động xóa các tệp cũ hơn $days ngày';
  }

  @override
  String get storageCleanupPeriod => 'Thời gian dọn dẹp';

  @override
  String get storagePreserveThumbnails => 'Giữ nguyên hình thu nhỏ';

  @override
  String get storagePreserveThumbnailsDesc =>
      'Giữ hình thu nhỏ của hình ảnh trong quá trình dọn dẹp';

  @override
  String get storageWarningHigh =>
      'Mức sử dụng bộ nhớ cao. Hãy cân nhắc việc dọn dẹp các tập tin cũ.';

  @override
  String get storageWarningCritical =>
      'Dung lượng lưu trữ cực kỳ thấp. Hãy dọn dẹp để có không gian trống.';

  @override
  String storageFreed(String size, int count) {
    return 'Đã giải phóng $size (tệp $count)';
  }

  @override
  String storageDays(int days) {
    return '$days ngày';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'Xem tất cả các phòng $count';
  }

  @override
  String get storageNoFiles => 'Không tìm thấy tập tin nào';

  @override
  String get storageFilePinned => 'Đã ghim';

  @override
  String storageDeleteSelected(int count) {
    return 'Xóa các tập tin đã chọn $count? Chúng có thể được tải xuống lại từ máy chủ.';
  }

  @override
  String get backupRestore => 'Sao lưu & Khôi phục';

  @override
  String get backupCreate => 'Tạo bản sao lưu';

  @override
  String get backupCreateDesc =>
      'Sao lưu cài đặt và khóa mã hóa của bạn. Tin nhắn sẽ được khôi phục từ máy chủ sau khi đăng nhập lại.';

  @override
  String get backupIncludeKeys => 'Bao gồm các khóa mã hóa';

  @override
  String get backupIncludeKeysDesc => 'Cần thiết để đọc tin nhắn được mã hóa';

  @override
  String get backupPasswordProtect => 'Bảo vệ bằng mật khẩu';

  @override
  String get backupEnterPassword => 'Nhập mật khẩu dự phòng';

  @override
  String get backupHistory => 'Lịch sử sao lưu';

  @override
  String get backupNoBackups => 'Chưa có bản sao lưu nào';

  @override
  String get backupRestore2 => 'Khôi phục';

  @override
  String get backupDelete => 'Xóa';

  @override
  String get backupDeleteConfirm =>
      'Bạn có chắc chắn muốn xóa bản sao lưu này không? Điều này không thể hoàn tác được.';

  @override
  String get backupRestoreFromFile => 'Khôi phục từ tệp';

  @override
  String get backupRestoreFromFileDesc =>
      'Nhập tệp .n42backup từ thiết bị khác hoặc bản sao lưu trước đó.';

  @override
  String get backupChooseFile => 'Chọn tập tin sao lưu';

  @override
  String get backupRestoring => 'Đang khôi phục...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'Đã tạo bản sao lưu: phòng $rooms, tin nhắn $messages';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return 'Đã khôi phục cài đặt $settings từ các phòng $rooms';
  }

  @override
  String backupFailed(String error) {
    return 'Sao lưu không thành công: $error';
  }

  @override
  String get backupPasswordRequired =>
      'Bản sao lưu này được bảo vệ bằng mật khẩu';

  @override
  String get blocGroupNotFound => 'Không tìm thấy nhóm';

  @override
  String blocGroupMembersInvited(int count) {
    return 'Đã mời (các) thành viên $count';
  }

  @override
  String get blocGroupMemberRemoved => 'Thành viên đã bị xóa';

  @override
  String get blocGroupAdminRemoved => 'Quản trị viên đã xóa';

  @override
  String get blocGroupLeft => 'Đã rời nhóm';

  @override
  String get blocGroupDisbanded => 'Nhóm đã tan rã';

  @override
  String get blocGroupJoined => 'Đã tham gia nhóm';

  @override
  String get blocGroupInviteDeclined => 'Lời mời đã bị từ chối';

  @override
  String get blocGroupTokenGateUpdated => 'Cổng mã thông báo đã được cập nhật';

  @override
  String get blocTransferProcessing => 'Đang xử lý chuyển...';

  @override
  String get blocTransferCancelled => 'Đã hủy chuyển khoản';

  @override
  String get blocTransferFailed => 'Chuyển không thành công';

  @override
  String get blocPaymentProcessing => 'Đang xử lý thanh toán...';

  @override
  String get blocPaymentFailed => 'Thanh toán không thành công';

  @override
  String get groupMaxMembers => 'Giới hạn thành viên';

  @override
  String get groupMaxMembersUnlimited => 'Không giới hạn';

  @override
  String get groupMaxMembersHint =>
      'Nhập giới hạn (để trống nếu không giới hạn)';

  @override
  String get groupMaxMembersUpdated => 'Đã cập nhật giới hạn thành viên';

  @override
  String get groupFull => 'Nhóm đã đạt công suất';

  @override
  String get groupChannels => 'Kênh chủ đề';

  @override
  String get groupChannelsEmpty => 'Chưa có kênh nào';

  @override
  String get groupChannelsCount => 'kênh';

  @override
  String get groupChannelCreate => 'Kênh mới';

  @override
  String get groupChannelName => 'Tên kênh';

  @override
  String get groupChannelTopic => 'Chủ đề kênh (tùy chọn)';

  @override
  String get groupChannelDelete => 'Xóa kênh';

  @override
  String get groupChannelDeleteConfirm =>
      'Xóa kênh này? Tất cả tin nhắn sẽ bị mất.';

  @override
  String get groupBotSettings => 'Cài đặt bot';

  @override
  String get groupBotEnabled => 'Kích hoạt Bot';

  @override
  String get groupBotWelcomeMessage => 'Mẫu tin nhắn chào mừng';

  @override
  String get groupBotWelcomeHint =>
      'Sử dụng \'tên\' làm trình giữ chỗ cho tên thành viên mới';

  @override
  String get groupBotConfigUpdated => 'Đã cập nhật cài đặt bot';

  @override
  String get groupContentFilter => 'Bộ lọc nội dung';

  @override
  String get groupContentFilterEnabled => 'Bật bộ lọc từ khóa';

  @override
  String get groupContentFilterReplace => 'Thay thế bằng ***';

  @override
  String get groupContentFilterHide => 'Ẩn tin nhắn';

  @override
  String get groupContentFilterAddWord => 'Thêm từ khóa';

  @override
  String get groupContentFilterUpdated => 'Đã cập nhật bộ lọc nội dung';

  @override
  String get chatSlashCommands => 'Lệnh';

  @override
  String get chatCommandPoll => '/polll - Tạo một cuộc thăm dò';

  @override
  String get chatCommandAnnounce => '/ thông báo - Gửi thông báo';

  @override
  String get chatCommandWelcome => '/Chào mừng - Đặt tin nhắn chào mừng';

  @override
  String get chatReportMessage => 'Báo cáo';

  @override
  String get chatReportReason => 'Lý do báo cáo';

  @override
  String get chatReportSpam => 'Thư rác';

  @override
  String get chatReportHarassment => 'Quấy rối';

  @override
  String get chatReportInappropriate => 'Nội dung không phù hợp';

  @override
  String get chatReportOther => 'Khác';

  @override
  String get chatReportSuccess => 'Đã gửi báo cáo';

  @override
  String get spacesName => 'Tên cộng đồng';

  @override
  String get spacesNameHint => 'ví dụ: Nhà giao dịch tiền điện tử';

  @override
  String get spacesNameRequired => 'Tên là bắt buộc';

  @override
  String get spacesDescription => 'Mô tả';

  @override
  String get spacesDescriptionHint => 'Cộng đồng này nói về cái gì?';

  @override
  String get spacesType => 'Loại cộng đồng';

  @override
  String get spacesPublicDesc => 'Bất cứ ai cũng có thể khám phá và tham gia';

  @override
  String get spacesPrivateDesc =>
      'Chỉ những thành viên được mời mới có thể tham gia';

  @override
  String get spacesNotFound => 'Không tìm thấy cộng đồng';

  @override
  String get spacesSearch => 'Tìm kiếm cộng đồng...';

  @override
  String get spacesMembers => 'Thành viên';

  @override
  String get spacesNoChannels => 'Chưa có kênh nào';

  @override
  String get spacesLeave => 'Rời khỏi cộng đồng';

  @override
  String spacesLeaveConfirm(String name) {
    return 'Bạn có chắc chắn muốn rời khỏi \"$name\" không?';
  }

  @override
  String get spacesDelete => 'Xóa cộng đồng';

  @override
  String spacesDeleteConfirm(String name) {
    return 'Thao tác này sẽ xóa vĩnh viễn \"$name\" và tất cả các kênh của nó. Không thể hoàn tác hành động này.';
  }

  @override
  String get spacesCreateChannel => 'Thêm kênh';

  @override
  String get spacesChannelName => 'Tên kênh';

  @override
  String get spacesChannelTopic => 'Chủ đề (tùy chọn)';

  @override
  String get spacesDeleteChannel => 'Xóa kênh';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'Bạn có chắc chắn muốn xóa \"#$name\" không?';
  }

  @override
  String get spacesEditName => 'Chỉnh sửa tên';

  @override
  String get spacesEditDescription => 'Chỉnh sửa mô tả';

  @override
  String spacesViewAllMembers(int count) {
    return 'Xem tất cả thành viên $count';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return 'Đá $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'Cấm $name';
  }

  @override
  String get spacesPromoteAdmin => 'Thăng cấp lên quản trị viên';

  @override
  String get spacesDemoteAdmin => 'Xóa quản trị viên';

  @override
  String get spacesInviteMember => 'Mời thành viên';

  @override
  String get spacesInviteMemberUserId =>
      'ID người dùng (ví dụ: @user:server.com)';

  @override
  String get spacesSave => 'Lưu';

  @override
  String get settingsScreenshotProtection => 'Bảo vệ ảnh chụp màn hình';

  @override
  String get settingsScreenshotProtectionDesc =>
      'Ngăn chặn ảnh chụp màn hình và ghi màn hình';

  @override
  String get chatSelfDestructTimer => 'Tự hủy';

  @override
  String get chatTimerPickerTitle => 'Hẹn giờ tự hủy';

  @override
  String get chatTimerOff => 'Tắt';

  @override
  String get onChainNotificationsTitle => 'Sự kiện On-chain';

  @override
  String get onChainMarkAllRead => 'Đánh dấu tất cả đã đọc';

  @override
  String get onChainNoNotifications => 'Chưa có sự kiện on-chain';

  @override
  String get onChainNoNotificationsDesc =>
      'Sự kiện từ các kênh đã đăng ký sẽ xuất hiện ở đây';

  @override
  String get onChainViewDetails => 'Xem chi tiết';

  @override
  String get chatCommandHelp => '/help — Xem tất cả lệnh';

  @override
  String get chatCommandPrice => '/price — Lấy giá token';

  @override
  String get chatCommandBalance => '/balance — Xem số dư ví';

  @override
  String get chatCommandChains => '/chains — Danh sách 236+ chain';

  @override
  String get chatMiniApps => 'Ứng dụng';

  @override
  String get miniAppMarketTitle => 'Mini App';

  @override
  String get miniAppCategoryAll => 'Tất cả';

  @override
  String get miniAppSearch => 'Tìm kiếm ứng dụng...';

  @override
  String get miniAppFeatured => 'Nổi bật';

  @override
  String get miniAppAllApps => 'Tất cả ứng dụng';

  @override
  String get miniAppNoResults => 'Không tìm thấy ứng dụng';

  @override
  String get slideToPayLabel => '→→→ Trượt để xác nhận';

  @override
  String get slideToPayConfirming => 'Đang xác nhận...';

  @override
  String get redPacketBestLuck => 'May mắn nhất';

  @override
  String get redPacketBestLuckCongrats => 'You got the best luck! 👑';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total grabbed';
  }

  @override
  String get redPacketStatsTotal => 'Total: null null';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return 'I grabbed a $amount $token red packet! 🧧';
  }

  @override
  String get web3SearchHint => '@matrix:id • Địa chỉ ví 0x • name.eth';

  @override
  String get web3SearchPlaceholder => 'Tìm kiếm theo ID, ví hoặc ENS...';

  @override
  String get web3WalletAddress => 'Địa chỉ ví';

  @override
  String get web3AddressCopied => 'Đã sao chép địa chỉ';

  @override
  String get web3Copy => 'Sao chép';

  @override
  String get web3SendMessage => 'Gửi tin nhắn';

  @override
  String get web3SendToWallet => 'Ví tin nhắn';

  @override
  String get web3WalletOnlyHint =>
      'Địa chỉ này chưa có tài khoản N42. Tin nhắn sẽ được gửi khi họ tham gia.';

  @override
  String get web3NftAvatar => 'Hình đại diện NFT';

  @override
  String get web3ResolveFailed => 'Không thể giải quyết danh tính';

  @override
  String web3EnsNotFound(String name) {
    return 'Không tìm thấy tên ENS \"$name\"';
  }

  @override
  String get web3NoN42AccountTitle => 'Không có tài khoản N42';

  @override
  String get web3NoN42AccountDesc =>
      'Địa chỉ ví này chưa có tài khoản N42. Bạn có thể chia sẻ liên kết mời N42 của mình với họ để bắt đầu.';

  @override
  String get web3ShareInvite => 'Chia sẻ Mời';

  @override
  String get nftPickerTitle => 'Chọn Hình đại diện NFT';

  @override
  String get nftPickerTabPopular => 'phổ biến';

  @override
  String get nftPickerTabCustom => 'tùy chỉnh';

  @override
  String get nftPickerChain => 'Chuỗi';

  @override
  String get nftPickerContract => 'Địa chỉ hợp đồng';

  @override
  String get nftPickerTokenId => 'ID mã thông báo';

  @override
  String get nftPickerVerifyOwnership => 'Xác minh quyền sở hữu và xem trước';

  @override
  String get nftPickerUseAsAvatar => 'Sử dụng làm Hình đại diện';

  @override
  String get nftPickerPreview => 'Xem trước';

  @override
  String get nftPickerNotOwned => 'Bạn không sở hữu NFT này';

  @override
  String get nftPickerInvalidTokenId => 'ID mã thông báo không hợp lệ';

  @override
  String get nftPickerEnterBoth => 'Nhập địa chỉ hợp đồng và ID mã thông báo';

  @override
  String get nftPickerInfoTitle => 'Avatar NFT — Đã được xác minh trên chuỗi';

  @override
  String get nftPickerInfoDesc =>
      'Liên kết NFT mà bạn sở hữu làm hình đại diện của mình. Bất cứ ai cũng có thể xác minh quyền sở hữu trên chuỗi. Được trưng bày với một chiếc nhẫn vàng trên N42.';

  @override
  String get nftPickerPopularCollections => 'Bộ sưu tập phổ biến';

  @override
  String get nftPickerWalletHint =>
      'Kết nối ví N42 của bạn để tự động khám phá NFT của bạn trên hơn 236 chuỗi.';

  @override
  String get profileBindNftAvatar => 'Liên kết hình đại diện NFT';

  @override
  String get profileChangeAvatar => 'Thay đổi hình đại diện';

  @override
  String get groupTopics => 'chủ đề';

  @override
  String get groupTopicsEmpty => 'Chưa có chủ đề nào';

  @override
  String get syncInProgress => 'Đang đồng bộ hóa lịch sử tin nhắn...';

  @override
  String get recoveryKeyReminderTitle => 'Bảo vệ tin nhắn của bạn';

  @override
  String get recoveryKeyReminderDesc =>
      'Tạo khóa khôi phục để đồng bộ hóa an toàn các tin nhắn được mã hóa trên các thiết bị';

  @override
  String get recoveryKeySetupNow => 'Thiết lập ngay bây giờ';

  @override
  String get recoveryKeyRemindLater => 'Nhắc tôi sau';

  @override
  String get channelReadOnly =>
      'Chỉ quản trị viên mới có thể đăng bài trên kênh này';

  @override
  String get channelSubscribers => 'người đăng ký';

  @override
  String get channelVerified => 'Kênh đã được xác minh';

  @override
  String get redPacketHistory => 'Lịch sử gói màu đỏ';

  @override
  String get redPacketSent => 'Đã gửi';

  @override
  String get redPacketReceived => 'Đã nhận';

  @override
  String get redPacketExpired => 'Đã hết hạn';

  @override
  String get redPacketClaimed => 'Đã xác nhận quyền sở hữu';

  @override
  String get redPacketInsufficientBalance => 'Số dư không đủ';

  @override
  String selfDestructCountdown(String time) {
    return 'Tự hủy trong $time';
  }

  @override
  String get messageDestroyed => 'Tin nhắn bị hủy';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'Quyền bị từ chối: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'Phí gas là gì?';

  @override
  String get aiSuggestionDefi => 'Hướng dẫn cho người mới bắt đầu DeFi';

  @override
  String get aiSuggestionSecurity => 'Cách kiểm tra bảo mật hợp đồng';

  @override
  String get aiSuggestionBridge => 'Cầu nối chuỗi chéo';

  @override
  String get channelDiscoverTitle => 'Khám phá kênh';

  @override
  String get channelDiscoverSearch => 'Tìm kiếm kênh...';

  @override
  String get channelJoin => 'Tham gia';

  @override
  String get channelJoined => 'Đã tham gia';

  @override
  String get channelCategory => 'Danh mục';

  @override
  String slowModeCooldown(int seconds) {
    return 'Chế độ chậm: chờ ${seconds}s';
  }

  @override
  String get addressCopyAction => 'Sao chép địa chỉ';

  @override
  String get addressSendMessage => 'Gửi tin nhắn';

  @override
  String get addressViewProfile => 'Xem hồ sơ';

  @override
  String get sendToAddress => 'Gửi đến địa chỉ ví';

  @override
  String get blocAuthSendVerificationCodeFailed => 'Không gửi được mã xác minh';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'Máy chủ này không hỗ trợ đặt lại mật khẩu email';

  @override
  String get blocAuthResetPasswordFailed => 'Không thể đặt lại mật khẩu';

  @override
  String get blocAuthChangePasswordFailed => 'Không thể thay đổi mật khẩu';

  @override
  String get blocAuthOldPasswordWrong => 'Mật khẩu hiện tại không chính xác';

  @override
  String get blocAuthLoginCancelled => 'Đăng nhập bị hủy';

  @override
  String get blocAuthGoogleLoginFailed => 'Đăng nhập Google không thành công';

  @override
  String get blocAuthAppleLoginFailed => 'Đăng nhập Apple không thành công';

  @override
  String get blocAuthSsoLoginFailed => 'Đăng nhập SSO không thành công';

  @override
  String get blocAuthFacebookLoginFailed =>
      'Đăng nhập Facebook không thành công';

  @override
  String get blocAuthTwitterLoginFailed => 'Đăng nhập Twitter không thành công';

  @override
  String get blocAuthWeChatLoginFailed => 'Đăng nhập WeChat không thành công';

  @override
  String get blocAuthWeChatNotConfigured =>
      'Đăng nhập WeChat không được định cấu hình';

  @override
  String get blocAuthWeChatNotInstalled => 'Vui lòng cài đặt WeChat trước';

  @override
  String get blocAuthPasswordWrong => 'Mật khẩu không chính xác';

  @override
  String get blocAuthEmailAlreadyBound =>
      'Email này đã được liên kết với một tài khoản khác';

  @override
  String get blocAuthChangeEmailFailed => 'Không thể thay đổi email';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'Mã xác minh không chính xác hoặc đã hết hạn';

  @override
  String get blocAuthSessionExpired =>
      'Phiên đã hết hạn, vui lòng đăng nhập lại';

  @override
  String get blocAuthSessionIncomplete =>
      'Dữ liệu phiên không đầy đủ, vui lòng đăng nhập lại';
}

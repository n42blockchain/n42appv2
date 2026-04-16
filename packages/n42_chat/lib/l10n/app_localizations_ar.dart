// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get commonRetry => 'أعد المحاولة';

  @override
  String get commonUnknownUser => 'مستخدم غير معروف';

  @override
  String get transferWalletNotConnected => 'المحفظة غير متصلة';

  @override
  String get chatCallServiceNotInitialized => 'لم تتم تهيئة خدمة الاتصال';

  @override
  String authLoginFailed(String error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String get chatCallBack => 'اتصل مرة أخرى';

  @override
  String get chatMissedVideoCall => 'مكالمة فيديو فائتة';

  @override
  String get chatMissedVoiceCall => 'مكالمة صوتية فائتة';

  @override
  String get chatCallNotAnswered => 'لم يتم الرد';

  @override
  String get chatCallDurationLabel => 'مدة المكالمة';

  @override
  String get chatVoiceCallCancelled => 'تم إلغاء المكالمة الصوتية';

  @override
  String get chatVideoCallCancelled => 'تم إلغاء مكالمة الفيديو';

  @override
  String get commonImage => '[صورة]';

  @override
  String get chatVideo => '[فيديو]';

  @override
  String get chatVoice => '[صوت]';

  @override
  String get commonFile => '[ملف]';

  @override
  String get chatLocation => '[الموقع]';

  @override
  String get chatUnknownMessage => '[رسالة غير معروفة]';

  @override
  String get commonDelete => 'حذف';

  @override
  String get chatDeleteThisMessage => 'هل تريد حذف هذه الرسالة؟';

  @override
  String get chatMessageDeleted => 'تم حذف الرسالة';

  @override
  String get profileNotLoggedIn => 'لم يتم تسجيل الدخول';

  @override
  String get chatMyLocation => 'موقعي';

  @override
  String get commonGroupChat => 'دردشة جماعية';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonLoadFailed => 'فشل التحميل';

  @override
  String get commonMessages => 'الرسائل';

  @override
  String get commonContacts => 'اتصالات';

  @override
  String get commonMe => 'أنا';

  @override
  String get commonVoiceLoading =>
      'جارٍ التحميل الصوتي، يرجى المحاولة مرة أخرى لاحقًا';

  @override
  String get commonVoiceToTextFailed => 'فشل تحويل الصوت إلى نص';

  @override
  String get commonConvertToText => 'إلى النص';

  @override
  String get chatCopy => 'نسخ';

  @override
  String get commonForward => 'إلى الأمام';

  @override
  String get commonUnfavorite => 'غير مفضل';

  @override
  String get commonFavorite => 'المفضلة';

  @override
  String get settingsResend => 'إعادة الإرسال';

  @override
  String get chatRecall => 'أذكر';

  @override
  String get commonQuote => 'اقتباس';

  @override
  String get commonRemind => 'تذكير';

  @override
  String get chatCopied => 'منقول';

  @override
  String get storySendMessageHint => 'أرسل رسالة';

  @override
  String get commonMicrophonePermissionRequired => 'يرجى السماح إذن الميكروفون';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'تم رفض إذن الميكروفون. يرجى تفعيله في إعدادات النظام لاستخدام الرسائل الصوتية.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'فشل بدء التسجيل: $error';
  }

  @override
  String get commonRecordingTooShort => 'التسجيل قصير جدًا';

  @override
  String commonStopRecordingFailed(String error) {
    return 'فشل في إيقاف التسجيل: $error';
  }

  @override
  String get chatReleaseToCancel => 'الافراج عن الإلغاء';

  @override
  String get chatReleaseToSend => 'حرر للإرسال، اسحب لأعلى للإلغاء';

  @override
  String get commonHoldToTalk => 'عقد للحديث';

  @override
  String get commonSend => 'أرسل';

  @override
  String get commonAddFriend => 'إضافة صديق';

  @override
  String get commonChatServiceNotConnected => 'خدمة الدردشة غير متصلة';

  @override
  String contactUserNotFoundHint(String query) {
    return 'لم يتم العثور على المستخدم \"$query\".\n\nنصائح:\n• حاول إدخال معرف المستخدم الكامل، على سبيل المثال. @username:server.com\n• التدقيق الإملائي لاسم المستخدم';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'فشل إنشاء الدردشة: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'فشل البحث: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'أدخل معرف المستخدم أو اسم المستخدم للبحث';

  @override
  String get contactSearching => 'جارٍ البحث...';

  @override
  String get contactSearchUserToChat => 'ابحث عن المستخدم لبدء الدردشة';

  @override
  String get contactMatrixIdExample =>
      'يمكنك إدخال معرف مصفوفة كامل\nعلى سبيل المثال @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'لم يتم العثور على المستخدم \"$username\".';
  }

  @override
  String get commonChat => 'الدردشة';

  @override
  String get commonSettings => 'الإعدادات';

  @override
  String get profileEditProfile => 'تحرير الملف الشخصي';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get commonCreateGroup => 'إنشاء مجموعة';

  @override
  String get chatError => 'خطأ';

  @override
  String get commonTransfer => 'نقل';

  @override
  String get commonReceived => 'تم الاستلام';

  @override
  String get commonRefunded => 'ردها';

  @override
  String get commonExpired => 'انتهت صلاحيتها';

  @override
  String get chatRedPacketGreeting => 'أطيب التمنيات';

  @override
  String get commonN42RedPacket => 'N42 الحزمة الحمراء';

  @override
  String get commonClaimed => 'ادعى';

  @override
  String get commonAllClaimed => 'ادعى الجميع';

  @override
  String get chatReadAloud => 'اقرأ بصوت عالٍ';

  @override
  String get chatReply => 'رد';

  @override
  String get commonEdit => 'تحرير';

  @override
  String get chatSelectForwardTarget => 'حدد الهدف الأمامي';

  @override
  String commonSendCount(int count) {
    return 'إرسال($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'معرف N42: $id';
  }

  @override
  String get profileN42IdTitle => 'معرف N42';

  @override
  String get profileN42Bean => 'N42 فول';

  @override
  String get contactFriendInfo => 'معلومات الصديق';

  @override
  String get contactFriendInfoDesc =>
      'أضف ملاحظة الصديق والهاتف والعلامات والملاحظات والصور وتعيين الأذونات.';

  @override
  String get commonMoments => 'لحظات';

  @override
  String get commonSendMessage => 'رسالة';

  @override
  String get contactAudioVideoCall => 'مكالمة صوتية/فيديو';

  @override
  String get contactVideoChannel => 'قناة الفيديو';

  @override
  String get contactRemark => 'ملاحظة';

  @override
  String get contactRemarkName => 'اسم الملاحظة';

  @override
  String get contactPhone => 'الهاتف';

  @override
  String get contactTags => 'العلامات';

  @override
  String get contactNotes => 'ملاحظات';

  @override
  String get contactPhotos => 'صور';

  @override
  String get contactPermissions => 'الأذونات';

  @override
  String get contactChatMomentsEtc => 'الدردشة واللحظات والرياضة وما إلى ذلك.';

  @override
  String get contactMoreInfo => 'مزيد من المعلومات';

  @override
  String get contactCommonGroups => 'المجموعات المشتركة';

  @override
  String get contactSource => 'المصدر';

  @override
  String get settingsNotificationSettings => 'الإخطارات';

  @override
  String get settingsPrivacy => 'الخصوصية';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsAbout => 'حول';

  @override
  String get commonLogout => 'تسجيل الخروج';

  @override
  String get commonLogoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get commonSave => 'حفظ';

  @override
  String get profileNickname => 'اللقب';

  @override
  String get profileEnterNickname => 'أدخل اللقب';

  @override
  String get profileSignature => 'التوقيع';

  @override
  String get profileAddSignature => 'أضف توقيعا';

  @override
  String get commonTakePhoto => 'التقط صورة';

  @override
  String get profileChooseFromGallery => 'اختر من المعرض';

  @override
  String profileSaveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get authSecureDecentralizedChat => 'المراسلة الآمنة واللامركزية';

  @override
  String get commonEndToEndEncryption => 'التشفير من النهاية إلى النهاية';

  @override
  String get authMessagesOnlyYouCanSee => 'الرسائل مرئية لك وللمستلم فقط';

  @override
  String get authDecentralized => 'لامركزية';

  @override
  String get authBasedOnMatrix => 'مبني على بروتوكول ماتريكس المفتوح';

  @override
  String get authWalletIntegration => 'تكامل المحفظة';

  @override
  String get authEasyCryptoTransfer => 'تحويلات العملة المشفرة بسهولة';

  @override
  String get authRegister => 'قم بالتسجيل';

  @override
  String get authAgreeTerms => 'بتسجيل الدخول فإنك توافق على';

  @override
  String get authTermsOfService => 'شروط الخدمة';

  @override
  String get authAnd => 'و';

  @override
  String get authPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get authServerAddress => 'عنوان الخادم';

  @override
  String get authEnterServerAddress => 'أدخل عنوان الخادم';

  @override
  String authConnectedTo(String serverName) {
    return 'متصل بـ $serverName';
  }

  @override
  String get authUsername => 'اسم المستخدم';

  @override
  String get authEnterUsername => 'أدخل اسم المستخدم';

  @override
  String get authUsernameOrEmail => 'اسم المستخدم أو البريد الإلكتروني';

  @override
  String get authEnterUsernameOrEmail =>
      'أدخل اسم المستخدم أو البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authEnterPassword => 'أدخل كلمة المرور';

  @override
  String get authRegisterAccount => 'قم بالتسجيل';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور';

  @override
  String get authOtherLoginMethods => 'طرق تسجيل الدخول الأخرى';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authJoinN42Chat => 'انضم إلى N42 Chat لبدء الدردشة';

  @override
  String get authUsernameHint => '3-20 حرفًا، حروفًا/أرقامًا/_';

  @override
  String get authUsernameMinLength =>
      'يجب أن يكون اسم المستخدم 3 أحرف على الأقل';

  @override
  String get authUsernameMaxLength =>
      'يجب أن يكون اسم المستخدم 20 حرفًا على الأكثر';

  @override
  String get authUsernameFormat =>
      'يمكن أن يحتوي اسم المستخدم على أحرف وأرقام وشرطات سفلية فقط';

  @override
  String get authPasswordHint => 'الحد الأدنى 8 أحرف';

  @override
  String get commonPasswordMinLength =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authFilled => 'معبأ';

  @override
  String get authEnterInviteCode => 'أدخل رمز الدعوة';

  @override
  String get authAlreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get authLoginNow => 'قم بتسجيل الدخول الآن';

  @override
  String get profileAvatar => 'الصورة الرمزية';

  @override
  String get profileStatus => 'الحالة';

  @override
  String get commonLoading => 'جار التحميل...';

  @override
  String get conversationNoConversations => 'لا محادثات';

  @override
  String get conversationTapToChat =>
      'اضغط على الجزء العلوي الأيمن لبدء الدردشة';

  @override
  String get conversationStartGroup => 'ابدأ الدردشة الجماعية';

  @override
  String get commonScan => 'مسح';

  @override
  String get commonPayment => 'الدفع';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature قريبا';
  }

  @override
  String get conversationMarkAsRead => 'وضع علامة كمقروءة';

  @override
  String get commonUnmute => 'إلغاء كتم الصوت';

  @override
  String get commonMute => 'كتم الصوت';

  @override
  String get conversationUnpin => 'إزالة التثبيت';

  @override
  String get conversationPin => 'دبوس';

  @override
  String get conversationDeleteConversation => 'حذف المحادثة';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return 'هل تريد حذف المحادثة مع \"$name\"؟';
  }

  @override
  String get commonNoContacts => 'لا اتصالات';

  @override
  String get contactAddFriendsToChat => 'أضف أصدقاء لبدء الدردشة';

  @override
  String get contactNotFound => 'لم يتم العثور على جهة الاتصال';

  @override
  String get contactTryOtherKeywords => 'جرب كلمات رئيسية أخرى أو بحث عالمي';

  @override
  String get contactSearchResults => 'نتائج البحث';

  @override
  String get contactNewFriends => 'أصدقاء جدد';

  @override
  String get contactChatOnlyFriends => 'أصدقاء الدردشة فقط';

  @override
  String get contactOfficialAccounts => 'الحسابات الرسمية';

  @override
  String get contactServiceAccounts => 'حسابات الخدمة';

  @override
  String get contactEnterpriseContacts => 'اتصالات المؤسسة';

  @override
  String get contactRecommendToFriend => 'مشاركة الاتصال';

  @override
  String get commonSetRemark => 'تعيين الملاحظة';

  @override
  String get contactSendingCard => 'جارٍ إرسال بطاقة جهة الاتصال...';

  @override
  String get commonFileLabel => 'ملف';

  @override
  String get commonLocationLabel => 'الموقع';

  @override
  String contactRecommendFailed(String error) {
    return 'فشل التوصية: $error';
  }

  @override
  String get profileEnterRemark => 'أدخل الملاحظة';

  @override
  String get contactOpeningChat => 'جارٍ فتح الدردشة...';

  @override
  String contactOpenChatFailed(String error) {
    return 'فشل فتح الدردشة: $error';
  }

  @override
  String get contactAddContact => 'إضافة جهة اتصال';

  @override
  String get contactEnterUserId => 'أدخل معرف المستخدم';

  @override
  String get contactNoFriendRequests => 'لا توجد طلبات صداقة';

  @override
  String get commonAccept => 'قبول';

  @override
  String get commonReject => 'رفض';

  @override
  String get commonNoGroups => 'لا توجد مجموعات';

  @override
  String get contactSelectFriendToRecommend => 'اختر صديقًا للتوصية به';

  @override
  String get commonSearchContacts => 'البحث في جهات الاتصال';

  @override
  String get contactNoContactsFound => 'لم يتم العثور على جهات اتصال';

  @override
  String get favoriteYesterday => 'أمس';

  @override
  String get chatJustNow => 'الآن فقط';

  @override
  String get profileOnline => 'على الانترنت';

  @override
  String get profileOffline => 'غير متصل';

  @override
  String get searchContactsGroupsMessages =>
      'البحث في جهات الاتصال والمجموعات والرسائل';

  @override
  String get searchError => 'خطأ في البحث';

  @override
  String get chatSearchHint => 'بحث';

  @override
  String get searchHistory => 'سجل البحث';

  @override
  String get commonClear => 'واضح';

  @override
  String get commonAll => 'الكل';

  @override
  String get searchGroups => 'المجموعات';

  @override
  String get searchNoResults => 'لا توجد نتائج';

  @override
  String commonGroupMembers(int count) {
    return 'الأعضاء ($count)';
  }

  @override
  String get groupMembersTitle => 'أعضاء المجموعة';

  @override
  String get groupViewAll => 'عرض الكل';

  @override
  String get groupOwner => 'المالك';

  @override
  String get groupAdmin => 'المشرف';

  @override
  String get groupInvite => 'دعوة';

  @override
  String get commonGroupAnnouncement => 'إعلان المجموعة';

  @override
  String get commonNotSet => 'لم يتم ضبطه';

  @override
  String get groupDescription => 'وصف المجموعة';

  @override
  String get groupPublicGroup => 'المجموعة العامة';

  @override
  String get commonClearChatHistory => 'مسح سجل الدردشة';

  @override
  String get commonDissolveGroup => 'حل المجموعة';

  @override
  String get commonLeaveGroup => 'مغادرة المجموعة';

  @override
  String get groupChangeGroupName => 'تغيير اسم المجموعة';

  @override
  String get commonEnterGroupName => 'أدخل اسم المجموعة';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get groupEnterGroupDescription => 'أدخل وصف المجموعة';

  @override
  String get groupPublish => 'نشر';

  @override
  String get chatClearHistoryConfirm =>
      'هل تريد مسح سجل الدردشة بالكامل؟ لا يمكن التراجع عن هذا.';

  @override
  String get chatClearAction => 'واضح';

  @override
  String get commonChatHistoryCleared => 'تم مسح سجل الدردشة';

  @override
  String get commonDissolve => 'حل';

  @override
  String get groupQrCode => 'رمز الاستجابة السريعة للمجموعة';

  @override
  String get commonSearchChatHistory => 'البحث في سجل الدردشة';

  @override
  String get groupIdCopied => 'تم نسخ معرف المجموعة';

  @override
  String get transferEnterOrPasteAddress => 'أدخل أو الصق عنوان المحفظة';

  @override
  String get transferSelectToken => 'حدد الرمز المميز';

  @override
  String get commonTransferAmount => 'مبلغ التحويل';

  @override
  String get transferAvailable => 'متاح';

  @override
  String get transferMemoOptional => 'مذكرة (اختياري)';

  @override
  String get transferConfirmTransfer => 'تأكيد النقل';

  @override
  String get transferAddressVerified => 'تم التحقق من العنوان';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'متاح: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'أدخل المبلغ';

  @override
  String get commonRedPacketCountMin => 'مطلوب حزمة حمراء واحدة على الأقل';

  @override
  String get commonViewRedPacketDetails => 'عرض تفاصيل الحزمة الحمراء';

  @override
  String get commonEnterTransferAmount => 'الرجاء إدخال مبلغ التحويل';

  @override
  String get commonTransferTo => 'نقل إلى';

  @override
  String commonFromSender(String name, Object senderName) {
    return 'من $name';
  }

  @override
  String get commonConfirmReceive => 'تأكيد الاستلام';

  @override
  String get groupProfile => 'معلومات المجموعة';

  @override
  String get groupRemoveMember => 'إزالة من المجموعة';

  @override
  String get commonRemove => 'إزالة';

  @override
  String get profileClearStatus => 'مسح الحالة';

  @override
  String get profileClearStatusConfirm => 'هل تريد مسح الوضع الحالي؟';

  @override
  String get profileStatusCleared => 'تم مسح الحالة';

  @override
  String get profileUserNotExist => 'المستخدم غير موجود';

  @override
  String get profileUserIdCopied => 'تم نسخ معرف المستخدم';

  @override
  String get commonReport => 'تقرير';

  @override
  String get profileQrCode => 'رمز الاستجابة السريعة';

  @override
  String get profileAvatarUpdated => 'تم تحديث الصورة الرمزية';

  @override
  String commonSelectImageFailed(String error) {
    return 'فشل في تحديد الصورة: $error';
  }

  @override
  String get profileChangeName => 'تغيير الاسم';

  @override
  String get profileMale => 'ذكر';

  @override
  String get profileFemale => 'أنثى';

  @override
  String chatFeatureInDev(String feature) {
    return 'ميزة $feature قيد التطوير...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'فشل حفظ العنوان: $error';
  }

  @override
  String get profileAddNew => 'أضف';

  @override
  String get profileAddAddress => 'إضافة عنوان';

  @override
  String get profileAddressAdded => 'تمت إضافة العنوان';

  @override
  String get profileAddressUpdated => 'تم تحديث العنوان';

  @override
  String get profileDeleteAddress => 'حذف العنوان';

  @override
  String get profileAddressDeleted => 'تم حذف العنوان';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'فشل حفظ الفاتورة: $error';
  }

  @override
  String get profileMyInvoices => 'فواتيري';

  @override
  String get profileAddInvoice => 'أضف الفاتورة';

  @override
  String get profileInvoiceAdded => 'تمت إضافة الفاتورة';

  @override
  String get profileInvoiceUpdated => 'تم تحديث الفاتورة';

  @override
  String get profileDeleteInvoice => 'حذف الفاتورة';

  @override
  String get profileInvoiceDeleted => 'تم حذف الفاتورة';

  @override
  String get profilePersonal => 'شخصي';

  @override
  String get groupSelectAtLeastOne => 'الرجاء اختيار عضو واحد على الأقل';

  @override
  String get chatFileNotExist => 'الملف غير موجود';

  @override
  String chatSendFailed(String error) {
    return 'فشل الإرسال: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'لا يمكن فتح المتصفح';

  @override
  String chatSelectFileFailed(String error) {
    return 'فشل في تحديد الملف: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'فشل الإعداد: $error';
  }

  @override
  String get transferEnterValidAmount => 'الرجاء إدخال مبلغ صالح';

  @override
  String get commonAddressCopied => 'تم نسخ العنوان';

  @override
  String favoriteOpenItem(String content) {
    return 'فتح: $content';
  }

  @override
  String get favoriteDeleted => 'تم الحذف';

  @override
  String get profileWallet => 'المحفظة';

  @override
  String get chatRecording => 'التسجيل';

  @override
  String get chatInvalidVideoUrl => 'عنوان URL للفيديو غير صالح';

  @override
  String get chatDownloadFile => 'تنزيل الملف';

  @override
  String get chatClearChatHistoryTitle => 'مسح سجل الدردشة';

  @override
  String get chatVideoCall => 'مكالمة فيديو';

  @override
  String get commonVoiceCall => 'مكالمة صوتية';

  @override
  String get callLeaveMeeting => 'مغادرة الاجتماع';

  @override
  String get chatDetails => 'تفاصيل الدردشة';

  @override
  String get chatViewAllGroupMembers => 'مشاهدة كافة الأعضاء';

  @override
  String get chatGroupName => 'اسم المجموعة';

  @override
  String get chatGroupNameUpdated => 'تم تحديث اسم المجموعة';

  @override
  String get chatUpdateFailed => 'فشل التحديث';

  @override
  String get chatNoPermissionToModify => 'ليس لديك الإذن بالتعديل';

  @override
  String get chatGroupManagement => 'إدارة المجموعة';

  @override
  String get chatMyNicknameInGroup => 'لقبي في المجموعة';

  @override
  String get chatPinChat => 'دبوس الدردشة';

  @override
  String get chatStrongReminder => 'تذكير قوي';

  @override
  String get chatSetChatBackground => 'تعيين خلفية الدردشة';

  @override
  String get chatUnknownFile => 'ملف غير معروف';

  @override
  String get chatDownload => 'تحميل';

  @override
  String get chatInvalidLocation => 'الموقع غير صالح';

  @override
  String get chatTapToCancel => 'انقر للإلغاء';

  @override
  String chatCaptureFailed(Object error) {
    return 'فشل الالتقاط: $error';
  }

  @override
  String get chatProcessingVideo => 'جارٍ معالجة الفيديو...';

  @override
  String get chatVideoFileNotExist => 'ملف الفيديو غير موجود';

  @override
  String get chatVideoDataEmpty => 'بيانات الفيديو فارغة';

  @override
  String get chatVideoTooLarge => 'لا يمكن أن يتجاوز حجم الفيديو 100 ميجابايت';

  @override
  String get chatSendingVideo => 'جارٍ إرسال الفيديو...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'فشل إرسال الفيديو: $error';
  }

  @override
  String get chatImageFileNotExist => 'ملف الصورة غير موجود';

  @override
  String get commonImageDataEmpty => 'بيانات الصورة فارغة';

  @override
  String get chatSendingImage => 'جارٍ إرسال الصورة...';

  @override
  String chatSendImageFailed(Object error) {
    return 'فشل إرسال الصورة: $error';
  }

  @override
  String get chatSendLocation => 'إرسال الموقع';

  @override
  String get chatSelectLocationAndSend => 'حدد الموقع وأرسل';

  @override
  String get chatShareRealTimeLocation => 'مشاركة الموقع في الوقت الحقيقي';

  @override
  String get chatShareLocationForOneHour =>
      'مشاركة الموقع في الوقت الفعلي مع صديق لمدة ساعة واحدة';

  @override
  String get chatLocationSent => 'تم إرسال الموقع';

  @override
  String get chatSelectMessages => 'حدد الرسائل';

  @override
  String chatSelectedCount(int count) {
    return 'تم التحديد $count';
  }

  @override
  String get chatSelectAll => 'حدد الكل';

  @override
  String chatGroupChatCount(int count) {
    return 'الدردشة الجماعية($count)';
  }

  @override
  String get chatPrivateChat => 'دردشة خاصة';

  @override
  String get chatNoMessages => 'لا توجد رسائل';

  @override
  String get chatSendFirstMessage => 'أرسل الرسالة الأولى لبدء الدردشة';

  @override
  String get chatEncryptionNotice =>
      'هذه الدردشة مشفرة من طرف إلى طرف. يمكنك أنت والمستلم فقط قراءة الرسائل.';

  @override
  String get chatMultiForward => 'إلى الأمام';

  @override
  String get chatCollect => 'اجمع';

  @override
  String get chatNoMembers => 'لا أعضاء';

  @override
  String get chatMemberNotFound => 'لم يتم العثور على العضو';

  @override
  String get chatVoiceFileNotExist => 'الملف الصوتي غير موجود';

  @override
  String get chatVoiceFileEmpty => 'الملف الصوتي فارغ';

  @override
  String get chatSendingVoice => 'جارٍ إرسال الصوت...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'فشل إرسال الصوت: $error';
  }

  @override
  String get chatMessageForwarded => 'تم إعادة توجيه الرسالة';

  @override
  String chatForwardFailed(Object error) {
    return 'فشل إعادة التوجيه: $error';
  }

  @override
  String get chatUnfavorited => 'غير مفضل';

  @override
  String get chatFavorited => 'المفضلة';

  @override
  String get chatReactionAdded => 'تمت إضافة التفاعل';

  @override
  String get chatReactionRemoved => 'تمت إزالة التفاعل';

  @override
  String get chatFailedMessageDeleted => 'تم حذف الرسالة الفاشلة';

  @override
  String get chatDeleteMessages => 'حذف الرسائل';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'هل أنت متأكد أنك تريد حذف رسائل $count؟';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'ملاحظة: رسائل $count هي من الآخرين وسيتم حذفها لك فقط.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return 'سيتم استدعاء رسائل $count منك للجميع.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'تم استدعاء رسائل $count، وتم حذف $localCount لك فقط';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'تم استدعاء رسائل $count';
  }

  @override
  String chatDeletedLocally(Object count) {
    return 'تم حذف رسائل $count لك فقط';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'رسائل $count المعاد توجيهها';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'اكتمل إعادة التوجيه: نجح $success، وفشل $failed';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'ميزة التذكير متاحة فقط في الدردشة الجماعية';

  @override
  String get chatOnlyTextSearchable => 'يمكن البحث في الرسائل النصية فقط';

  @override
  String chatSearchFor(Object text) {
    return 'بحث \"$text\"';
  }

  @override
  String get chatBaiduSearch => 'بحث بايدو';

  @override
  String get chatGoogleSearch => 'بحث جوجل';

  @override
  String get chatBingSearch => 'بحث بنج';

  @override
  String get chatCalling => 'جارٍ الاتصال...';

  @override
  String get chatRinging => 'رنين...';

  @override
  String get chatInCall => 'في المكالمة';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'ميزة $feature قيد التطوير...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'رسائل $count المجمعة';
  }

  @override
  String commonMemberCount(int count) {
    return 'أعضاء $count';
  }

  @override
  String groupDone(int count) {
    return 'تم ($count)';
  }

  @override
  String get profileServices => 'الخدمات';

  @override
  String get commonFavorites => 'المفضلة';

  @override
  String get profileOrdersAndCards => 'الطلبات والبطاقات';

  @override
  String get profileStickers => 'ملصقات';

  @override
  String profileStatusSetTo(String status) {
    return 'تم ضبط الحالة على: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'فشل تحميل الصورة الرمزية';

  @override
  String get profilePersonalProfile => 'الملف الشخصي';

  @override
  String get profileName => 'الاسم';

  @override
  String get profileGender => 'الجنس';

  @override
  String get profileRegion => 'المنطقة';

  @override
  String get commonMyQrCode => 'رمز الاستجابة السريعة الخاص بي';

  @override
  String get profilePoke => 'كزة';

  @override
  String get profileRingtone => 'نغمة رنين';

  @override
  String get profileDefaultRingtone => 'نغمة الرنين الافتراضية';

  @override
  String get profileMyAddresses => 'عناويني';

  @override
  String profileGenderSetTo(String gender) {
    return 'تم ضبط الجنس على: $gender';
  }

  @override
  String get profileSelectRegion => 'حدد المنطقة';

  @override
  String get profileSelectCity => 'اختر المدينة';

  @override
  String profileRegionSetTo(String region) {
    return 'تم ضبط المنطقة على: $region';
  }

  @override
  String get profileSetPoke => 'تعيين كزة';

  @override
  String get profileFriendPokedMe => 'صديق طعنني';

  @override
  String get profileExample => 'مثال';

  @override
  String get profileOnTheShoulder => 'على الكتف';

  @override
  String get profilePokeCleared => 'تم مسح كزة';

  @override
  String profilePokeSetTo(String suffix) {
    return 'تم ضبط النكز على: poked me$suffix';
  }

  @override
  String get profileEditSignature => 'تحرير التوقيع';

  @override
  String get profileIntroduceYourself => 'جملة للتعريف بنفسك';

  @override
  String get profileSignatureCleared => 'تم مسح التوقيع';

  @override
  String get profileSignatureUpdated => 'تم تحديث التوقيع';

  @override
  String get profileScanToAddFriend =>
      'امسح رمز الاستجابة السريعة أعلاه لإضافتي كصديق';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'تم ضبط نغمة الرنين على: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'هل أنت متأكد أنك تريد حل \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get authEnterValidServerAddress => 'الرجاء إدخال عنوان خادم صالح';

  @override
  String get authEnterServerAddressFirst => 'الرجاء إدخال عنوان الخادم أولاً';

  @override
  String get authPasskeyRequiresServer =>
      'يتطلب تسجيل الدخول بمفتاح المرور دعم الخادم';

  @override
  String get authLoginAgreement => 'بتسجيل الدخول فإنك توافق على';

  @override
  String get authPleaseAgreeToTerms =>
      'يرجى قراءة شروط الخدمة وسياسة الخصوصية والموافقة عليها';

  @override
  String get authRegisterFailed => 'فشل التسجيل';

  @override
  String get commonReenterPassword => 'أعد إدخال كلمة المرور';

  @override
  String get commonPasswordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get authInviteCodeBuiltIn => 'رمز الدعوة (مدمج)';

  @override
  String get authInviteCodeBuiltInNote =>
      'رمز الدعوة مدمج، وعادة لا يحتاج إلى تعديل';

  @override
  String get authIHaveReadAndAgree => 'لقد قرأت ووافقت على';

  @override
  String get mainStartGroupChat => 'ابدأ الدردشة الجماعية';

  @override
  String get mainAddFriends => 'أضف أصدقاء';

  @override
  String get mainPaymentAndCollection => 'الدفع';

  @override
  String contactCount(int count) {
    return 'اتصالات $count';
  }

  @override
  String get contactAddToHomeScreen => 'أضف إلى الشاشة الرئيسية';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'أوصى بطاقة $contact ل$recipient';
  }

  @override
  String get contactEnterRemarkName => 'أدخل اسم الملاحظة';

  @override
  String contactRemarkSetTo(String remark) {
    return 'تم ضبط الملاحظة على: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return 'تم قبول طلب الصداقة الخاص بـ $name';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return 'تم رفض طلب الصداقة الخاص بـ $name';
  }

  @override
  String get commonGroupInvites => 'دعوات المجموعة';

  @override
  String commonMyGroups(int count) {
    return 'مجموعاتي ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'تمت دعوته للانضمام إلى المجموعة';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'هل أنت متأكد أنك تريد مغادرة \"$name\"؟';
  }

  @override
  String get commonLeave => 'غادر';

  @override
  String get commonRecallThisMessage => 'هل تتذكر هذه الرسالة؟';

  @override
  String get commonSavedToGallery => 'تم الحفظ في المعرض';

  @override
  String get commonFailedToSave => 'فشل الحفظ';

  @override
  String get chatSaving => 'جارٍ الحفظ...';

  @override
  String get commonShare => 'شارك';

  @override
  String get chatSaveToGallery => 'حفظ في المعرض';

  @override
  String chatDownloadFailed(String code) {
    return 'فشل التنزيل: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'فشلت المشاركة: $error';
  }

  @override
  String get chatFailedToLoadImage => 'فشل تحميل الصورة';

  @override
  String get chatVideoRecordingFailed => 'فشل تسجيل الفيديو';

  @override
  String get profileRedPacket => 'الحزمة الحمراء';

  @override
  String get commonMusic => 'موسيقى';

  @override
  String get commonCoupon => 'قسيمة';

  @override
  String get commonGift => 'هدية';

  @override
  String get commonPoll => 'استطلاع';

  @override
  String get favoriteText => 'نص';

  @override
  String get favoriteLinkLabel => 'رابط';

  @override
  String get favoriteNote => 'ملاحظة';

  @override
  String get favoriteMyNotes => 'ملاحظاتي';

  @override
  String get favoriteToday => 'اليوم';

  @override
  String favoriteDaysAgoText(int count) {
    return 'منذ أيام $count';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$month/$day';
  }

  @override
  String get favoriteNoFavorites => 'لا يوجد مفضلة بعد';

  @override
  String get favoriteLongPressToFavorite =>
      'اضغط لفترة طويلة على الرسالة إلى المفضلة';

  @override
  String get favoriteNewNote => 'ملاحظة جديدة';

  @override
  String get favoriteLink => 'الرابط المفضل';

  @override
  String get favoriteEditTags => 'تحرير العلامات';

  @override
  String get favoriteDeleteFavorite => 'حذف المفضلة';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'هل أنت متأكد أنك تريد حذف هذه المفضلة؟';

  @override
  String get favoriteNoSearchResultsFound => 'لم يتم العثور على نتائج';

  @override
  String get commonSendRedPacket => 'إرسال الحزمة الحمراء';

  @override
  String get transferAmount => 'المبلغ';

  @override
  String get commonRedPacketCover => 'غطاء الحزمة الحمراء';

  @override
  String get commonRedPacketType => 'نوع الحزمة الحمراء';

  @override
  String get commonNormalRedPacket => 'عادي';

  @override
  String get commonLuckyRedPacket => 'محظوظ';

  @override
  String get commonRedPacketCount => 'عدد الحزم الحمراء';

  @override
  String get commonPieces => 'قطع';

  @override
  String get commonPutMoneyInRedPacket => 'ضع المال في الحزمة الحمراء';

  @override
  String get commonRedPacketRefundNotice =>
      'سيتم استرداد الحزم الحمراء غير المطالب بها بعد 24 ساعة';

  @override
  String get commonOpenRedPacket => 'مفتوح';

  @override
  String get commonRedPacketAllClaimed => 'ادعى كل حزمة حمراء';

  @override
  String get commonRedPacketExpired => 'انتهت صلاحية الحزمة الحمراء';

  @override
  String get commonAddTransferNote => 'إضافة مذكرة نقل';

  @override
  String get commonYuan => 'يوان صيني';

  @override
  String get commonReplyWithEmoji => 'الرد بهذا الرمز التعبيري';

  @override
  String get contactEditRemark => 'تحرير الملاحظة';

  @override
  String get contactSetPermissions => 'تعيين الأذونات';

  @override
  String get profileAddToBlacklist => 'أضف إلى القائمة السوداء';

  @override
  String get contactDeleteContact => 'حذف جهة الاتصال';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'هل أنت متأكد من أنك تريد حذف $name؟';
  }

  @override
  String get transferTitle => 'نقل';

  @override
  String get transferReceiverAddressLabel => 'عنوان المستلم';

  @override
  String get transferSelectTokenLabel => 'حدد الرمز المميز';

  @override
  String get transferAmountLabel => 'مبلغ التحويل';

  @override
  String get transferMemoLabel => 'مذكرة (اختياري)';

  @override
  String get transferAddMemoHint => 'أضف مذكرة';

  @override
  String get transferSendPaymentRequest => 'إرسال طلب الدفع';

  @override
  String get transferQrCodeGenerateFailed => 'فشل إنشاء رمز الاستجابة السريعة';

  @override
  String get transferScanQrToPayMe =>
      'امسح رمز الاستجابة السريعة ضوئيًا لتدفع لي';

  @override
  String get transferMyWalletAddress => 'عنوان محفظتي';

  @override
  String get transferCreatePaymentRequest => 'إنشاء طلب الدفع';

  @override
  String profileN42IdLabel(String id) {
    return 'معرف N42: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'أطيب التمنيات';

  @override
  String commonSenderRedPacket(String name) {
    return 'الحزمة الحمراء لـ $name';
  }

  @override
  String get transferEnterValidAddress => 'الرجاء إدخال عنوان صالح';

  @override
  String get transferPleaseSelectToken => 'الرجاء تحديد رمز مميز';

  @override
  String get commonReceivedTransfer => 'التحويل المستلم';

  @override
  String commonSenderSentRedPacket(String name) {
    return 'أرسل $name حزمة حمراء';
  }

  @override
  String get commonSavedToBalance => 'محفوظ في الرصيد، يمكن التحويل مباشرة';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'انتهت صلاحية الحزمة الحمراء/تم المطالبة بكل شيء';

  @override
  String get transferScanFeatureComingSoon => 'ميزة المسح قريبا...';

  @override
  String get contactSetAsStarred => 'تعيين كنجمة';

  @override
  String get contactAddToBlocklist => 'أضف إلى قائمة الحظر';

  @override
  String get commonClaimedYour => 'ادعى الخاص بك';

  @override
  String get commonClaimedText => 'ادعى';

  @override
  String commonUserTyping(String name) {
    return '$name يكتب...';
  }

  @override
  String get commonTyping => 'جاري الكتابة...';

  @override
  String get commonWaitingToReceive => 'في انتظار تلقي';

  @override
  String get commonTapToClaim => 'انقر للمطالبة';

  @override
  String get commonHasBeenReceived => 'تم استلامه';

  @override
  String get commonGetLucky => 'كن محظوظا';

  @override
  String get qrcodeCameraStartFailed => 'فشل تشغيل الكاميرا';

  @override
  String get qrcodeUnknownError => 'خطأ غير معروف';

  @override
  String get qrcodePlaceQrCodeInFrame => 'ضع رمز QR داخل الإطار لمسحه ضوئيًا';

  @override
  String get qrcodeCloseManualInput => 'إغلاق الإدخال اليدوي';

  @override
  String get qrcodeManualInputUserId => 'معرف مستخدم الإدخال اليدوي';

  @override
  String get commonAdd => 'أضف';

  @override
  String get profileSetStatus => 'تعيين الحالة';

  @override
  String get profileVisibleToFriends24h => 'مرئية للأصدقاء لمدة 24 ساعة';

  @override
  String get profileWriteStatus => 'كتابة الحالة';

  @override
  String get profileEnterYourStatus => 'أدخل حالتك...';

  @override
  String get profileOk => 'حسنًا';

  @override
  String get qrcodeCameraPermissionRequired =>
      'مطلوب إذن الكاميرا لمسح رمز الاستجابة السريعة';

  @override
  String get qrcodeCameraPermissionDenied =>
      'تم رفض إذن الكاميرا بشكل دائم. يرجى تمكينه في إعدادات النظام.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'خطأ في التحقق من الإذن: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'رمز الاستجابة السريعة غير صالح';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'لا يمكن إضافة صديق: $error';
  }

  @override
  String get qrcodeScanQrCode => 'مسح رمز الاستجابة السريعة';

  @override
  String get qrcodeCheckingCameraPermission => 'جارٍ التحقق من إذن الكاميرا...';

  @override
  String get qrcodeNeedCameraPermission => 'مطلوب إذن الكاميرا';

  @override
  String get qrcodeRetryPermission => 'أعد المحاولة';

  @override
  String get qrcodeOpenSettings => 'افتح الإعدادات';

  @override
  String get groupInviteMembers => 'دعوة الأعضاء';

  @override
  String groupInviteCount(int count) {
    return 'دعوة ($count)';
  }

  @override
  String get profileNoShippingAddress => 'لا يوجد عنوان الشحن';

  @override
  String get profileDefaultLabel => 'الافتراضي';

  @override
  String get profileNoInvoice => 'لا فاتورة';

  @override
  String get profileCompany => 'الشركة';

  @override
  String get profileTaxNumber => 'الرقم الضريبي';

  @override
  String get profileConfirmDeleteAddress =>
      'هل أنت متأكد أنك تريد حذف هذا العنوان؟';

  @override
  String get profileConfirmDeleteInvoice =>
      'هل أنت متأكد أنك تريد حذف هذه الفاتورة؟';

  @override
  String get commonGroupOwner => 'المالك';

  @override
  String get commonGroupAdmin => 'المشرف';

  @override
  String get groupSearchMembers => 'أعضاء البحث';

  @override
  String groupTotalMembers(int count) {
    return 'أعضاء $count';
  }

  @override
  String get chatRemoveFromGroup => 'إزالة من المجموعة';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'هل أنت متأكد أنك تريد إزالة \"$name\" من المجموعة؟';
  }

  @override
  String get chatUnknownSong => 'أغنية غير معروفة';

  @override
  String get chatUnknownArtist => 'فنان غير معروف';

  @override
  String get chatUnknownContact => 'جهة اتصال غير معروفة';

  @override
  String get chatPersonalCard => 'بطاقة الاتصال';

  @override
  String get chatSingleChoice => 'واحد';

  @override
  String get chatMultiChoice => 'متعدد';

  @override
  String get chatEnded => 'انتهى';

  @override
  String get chatEndPollButton => 'إنهاء الاستطلاع';

  @override
  String get chatPollHint =>
      'سيتم عرض الاستطلاع في الدردشة. يمكن لأعضاء المجموعة التصويت.';

  @override
  String get chatSearchSongOrArtist => 'البحث عن أغنية أو فنان';

  @override
  String get chatNoSongsFound => 'لم يتم العثور على أي أغاني';

  @override
  String get chatSongNameOptional => 'اسم الأغنية (اختياري)';

  @override
  String get chatEnterSongName => 'أدخل اسم الأغنية';

  @override
  String get chatArtistNameOptional => 'اسم الفنان (اختياري)';

  @override
  String get chatEnterArtistName => 'أدخل اسم الفنان';

  @override
  String get chatRealTimeLocationSharing =>
      'مشاركة الموقع في الوقت الفعلي قيد التطوير...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'ميزة المكالمات الصوتية قيد التطوير...';

  @override
  String get profileReportFeatureInDev => 'ميزة التقرير قيد التطوير...';

  @override
  String get profileShareFeatureInDev => 'ميزة المشاركة قيد التطوير...';

  @override
  String get profileQrCodeFeatureInDev => 'ميزة QR Code قيد التطوير...';

  @override
  String get qrcodeScanQrToAddMe =>
      'امسح رمز الاستجابة السريعة أعلاه لإضافتي كصديق';

  @override
  String get qrcodeSaveToAlbum => 'حفظ في الألبوم';

  @override
  String get qrcodeChangeStyle => 'تغيير النمط';

  @override
  String get qrcodeCopyId => 'نسخ معرف';

  @override
  String get qrcodeIdCopied => 'تم نسخ الهوية';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'المزيد من الأساليب قريبا';

  @override
  String get profileBio => 'السيرة الذاتية';

  @override
  String get profileHomeServer => 'الخادم';

  @override
  String get profileShareContactCard => 'مشاركة بطاقة الاتصال';

  @override
  String get profileRemoveFromBlacklist => 'إزالة من القائمة السوداء';

  @override
  String get profileConfirmAddBlacklist =>
      'هل أنت متأكد أنك تريد إضافة هذا المستخدم إلى القائمة السوداء؟ لن تتلقى رسائل منهم.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'هل أنت متأكد أنك تريد إزالة هذا المستخدم من القائمة السوداء؟';

  @override
  String get profileRemarkSaved => 'تم حفظ الملاحظة';

  @override
  String get profileRemarkCleared => 'تم مسح الملاحظة';

  @override
  String get transferReceive => 'تلقي';

  @override
  String get transferPleaseConnectWallet => 'يرجى توصيل محفظتك أولا';

  @override
  String get transferSendRequest => 'إرسال الطلب';

  @override
  String get transferPleaseEnterValidAmount => 'الرجاء إدخال مبلغ صالح';

  @override
  String get searchPlaceholder => 'البحث في جهات الاتصال والمجموعات والرسائل';

  @override
  String get searchEnterKeywordToSearch => 'أدخل الكلمة الرئيسية لبدء البحث';

  @override
  String get searchClearHistory => 'واضح';

  @override
  String searchNoResultsForQuery(String query) {
    return 'لم يتم العثور على أي نتائج \"$query\"';
  }

  @override
  String get searchAllResults => 'الكل';

  @override
  String get searchInChat => 'البحث في الدردشة';

  @override
  String get searchContactLabel => 'الاتصال';

  @override
  String get searchGroupLabel => 'المجموعة';

  @override
  String get searchConversationLabel => 'محادثة';

  @override
  String get searchMessageLabel => 'رسالة';

  @override
  String get settingsSecurityTitle => 'الأمن';

  @override
  String get settingsKeyBackup => 'النسخ الاحتياطي للمفتاح';

  @override
  String get settingsBackupEncryptionKeys => 'مفاتيح التشفير الاحتياطية';

  @override
  String settingsKeysBackedUp(int count) {
    return 'تم عمل نسخة احتياطية من مفاتيح $count';
  }

  @override
  String get settingsBackupNotSet => 'لم يتم تعيين النسخ الاحتياطي';

  @override
  String get settingsRestoreKeys => 'استعادة المفاتيح';

  @override
  String get settingsRestoreKeysFromBackup =>
      'استعادة مفاتيح التشفير من النسخة الاحتياطية';

  @override
  String get settingsExportKeys => 'مفاتيح التصدير';

  @override
  String get settingsExportKeysToFile => 'تصدير المفاتيح إلى الملف';

  @override
  String get settingsLoggedInDevices => 'الأجهزة التي تم تسجيل دخولها';

  @override
  String get settingsNoOtherDevices => 'لا توجد أجهزة أخرى';

  @override
  String get settingsVerified => 'تم التحقق منه';

  @override
  String get settingsUnverified => 'لم يتم التحقق منها';

  @override
  String get settingsAdvanced => 'متقدم';

  @override
  String get settingsCrossSigning => 'التوقيع المتبادل';

  @override
  String get settingsEnabled => 'ممكّن';

  @override
  String get settingsNotEnabled => 'غير ممكّن';

  @override
  String get settingsResetEncryption => 'إعادة تعيين التشفير';

  @override
  String get settingsDeleteAllEncryptionKeys => 'احذف كافة مفاتيح التشفير';

  @override
  String get settingsEncryptionNotSupported => 'التشفير غير مدعوم';

  @override
  String get settingsNotInitialized => 'لم تتم التهيئة';

  @override
  String get settingsBackupKeyTitle => 'مفاتيح النسخ الاحتياطي';

  @override
  String get settingsBackupKeyMessage =>
      'هل تريد إنشاء نسخة احتياطية جديدة للمفتاح؟ سيساعدك هذا على استعادة الرسائل المشفرة على جهاز جديد.';

  @override
  String get settingsBackup => 'النسخ الاحتياطي';

  @override
  String get settingsRestoreKeyTitle => 'استعادة المفاتيح';

  @override
  String get settingsRestoreKeyMessage =>
      'أدخل كلمة مرور الاسترداد أو مفتاح الاسترداد لاستعادة الرسائل المشفرة.';

  @override
  String get settingsRestore => 'استعادة';

  @override
  String get settingsExportKeyTitle => 'مفاتيح التصدير';

  @override
  String get settingsExportKeyMessage =>
      'يحتوي ملف المفتاح الذي تم تصديره على جميع مفاتيح التشفير الخاصة بك. يرجى الحفاظ عليها آمنة.';

  @override
  String get settingsExport => 'تصدير';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'معرف الجهاز: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'الحالة: تم التحقق منها';

  @override
  String get settingsDeviceStatusUnverified => 'الحالة: لم يتم التحقق منها';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'آخر نشاط: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'التحقق من هذا الجهاز';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'تم تمكين التوقيع المتبادل بالفعل';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'تم إعداد التوقيع المتبادل بنجاح';

  @override
  String get settingsResetEncryptionTitle => 'إعادة تعيين التشفير';

  @override
  String get settingsResetEncryptionWarning =>
      'تحذير: سيؤدي هذا إلى حذف كافة مفاتيح التشفير الخاصة بك. لن تتمكن من فك تشفير الرسائل المشفرة السابقة. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settingsReset => 'إعادة تعيين';

  @override
  String get settingsBackupSuccess => 'تم نسخ المفاتيح احتياطيًا بنجاح';

  @override
  String get settingsBackupFailed => 'فشل النسخ الاحتياطي';

  @override
  String get settingsRecoveryKey => 'مفتاح الاسترداد';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'الرجاء حفظ مفتاح الاسترداد هذا في مكان آمن. ستحتاج إليه لاستعادة رسائلك المشفرة على جهاز جديد.';

  @override
  String get settingsRecoveryKeySaved => 'لقد أنقذته';

  @override
  String get settingsRestoreSuccess => 'تمت استعادة المفاتيح بنجاح';

  @override
  String get settingsRestoreFailed => 'فشلت عملية الاستعادة';

  @override
  String get settingsPassword => 'كلمة المرور';

  @override
  String get settingsEnterRecoveryKey => 'أدخل مفتاح الاسترداد';

  @override
  String get settingsEnterPassword => 'أدخل كلمة المرور';

  @override
  String get settingsExportSuccess =>
      'تم تصدير المفاتيح إلى النسخة الاحتياطية للخادم بنجاح';

  @override
  String get settingsExportNeedBackupFirst =>
      'الرجاء إنشاء نسخة احتياطية للمفتاح أولاً';

  @override
  String get settingsExportFailed => 'فشل التصدير';

  @override
  String get settingsResetSuccess => 'تمت إعادة تعيين التشفير بنجاح';

  @override
  String get settingsResetFailed => 'فشلت إعادة التعيين';

  @override
  String get callLeaveMeetingConfirm =>
      'هل أنت متأكد أنك تريد مغادرة الاجتماع؟';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'مطعون $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'لا توجد جهات اتصال متاحة لإضافتها';

  @override
  String get chatAddMembers => 'إضافة أعضاء';

  @override
  String chatInvitedMembers(int count) {
    return 'تمت دعوة أعضاء $count';
  }

  @override
  String chatInviteFailed(String error) {
    return 'فشلت الدعوة: $error';
  }

  @override
  String get chatMemberRemoved => 'تمت إزالة العضو';

  @override
  String chatRemoveFailed(String error) {
    return 'فشلت الإزالة: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'بعد المشاركة، يمكن للطرف الآخر رؤية موقعك في الوقت الفعلي لمدة ساعة واحدة.';

  @override
  String get chatStartSharing => 'ابدأ المشاركة';

  @override
  String get chatLocationServiceNotEnabled => 'خدمة الموقع غير ممكّنة';

  @override
  String get chatEnableLocationService =>
      'يرجى تمكين خدمة الموقع لاستخدام هذه الميزة';

  @override
  String get chatGoToSettings => 'انتقل إلى الإعدادات';

  @override
  String get chatLocationPermissionRequired => 'مطلوب إذن الموقع لهذه الميزة';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'تم رفض إذن الموقع بشكل دائم. يرجى تمكينه في الإعدادات.';

  @override
  String get chatLocationPermissionDenied => 'تم رفض إذن تحديد الموقع';

  @override
  String get chatGettingLocation => 'جارٍ الحصول على الموقع...';

  @override
  String chatGetLocationFailed(String error) {
    return 'فشل الحصول على الموقع: $error';
  }

  @override
  String get chatMapPreview => 'معاينة الخريطة';

  @override
  String get chatSearchLocation => 'موقع البحث';

  @override
  String chatRedPacketSent(String amount, String token) {
    return 'تم إرسال الحزمة الحمراء $amount $token';
  }

  @override
  String get chatTransferDefault => 'نقل';

  @override
  String chatTransferSent(String amount, String token) {
    return 'تم إرسال تحويل $amount $token';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'فشل في اختيار الملف: $error';
  }

  @override
  String get chatFileSizeLimit => 'لا يمكن أن يتجاوز حجم الملف 50 ميغابايت';

  @override
  String chatFileSending(String filename) {
    return 'إرسال الملف: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'فشل إرسال الملف: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return 'تم إرسال بطاقة جهة اتصال $name';
  }

  @override
  String get chatFavoritesFeature => 'المفضلة';

  @override
  String get chatCouponsFeature => 'كوبونات';

  @override
  String get chatGiftFeature => 'هدية';

  @override
  String chatSharedMusic(String name) {
    return 'تمت مشاركة ‏$name';
  }

  @override
  String get chatEndPollTitle => 'إنهاء الاستطلاع';

  @override
  String get chatEndPollConfirmMessage =>
      'هل أنت متأكد أنك تريد إنهاء هذا الاستطلاع؟ سيتم إغلاق التصويت بعد الإنتهاء.';

  @override
  String get chatPollEndedMessage => 'انتهى الاستطلاع';

  @override
  String get chatConnectingCall => 'جارٍ الاتصال...';

  @override
  String get chatMuteCall => 'كتم الصوت';

  @override
  String get chatSpeakerOff => 'مكبر الصوت معطل';

  @override
  String get chatSpeakerOn => 'المتحدث';

  @override
  String get chatCameraOn => 'تشغيل الكاميرا';

  @override
  String get chatCameraOff => 'الكاميرا معطلة';

  @override
  String get chatHangUp => 'شنق';

  @override
  String get chatSelectForwardTargetTitle => 'حدد الهدف الأمامي';

  @override
  String get chatNoForwardableChat => 'لا توجد محادثات متاحة لإعادة التوجيه';

  @override
  String get chatNoMatchingChat => 'لم يتم العثور على محادثات مطابقة';

  @override
  String get chatLocationTitle => 'الموقع';

  @override
  String get chatSendButton => 'أرسل';

  @override
  String get chatRetryButton => 'أعد المحاولة';

  @override
  String get chatSearchContactHint => 'البحث في جهات الاتصال';

  @override
  String get chatShareMusic => 'مشاركة الموسيقى';

  @override
  String get chatRecentPlayed => 'الأخيرة';

  @override
  String get chatMyFavorites => 'المفضلة';

  @override
  String get chatNetworkLink => 'رابط';

  @override
  String get chatLocalFile => 'محلي';

  @override
  String get chatPasteMusicLink => 'لصق رابط الموسيقى';

  @override
  String get chatShareMusicButton => 'مشاركة الموسيقى';

  @override
  String get chatSelectLocalAudio => 'حدد ملف الصوت المحلي';

  @override
  String get chatSupportedAudioFormats =>
      'يدعم ملفات MP3، M4A، WAV، FLAC، إلخ.';

  @override
  String get chatSelectFileButton => 'حدد ملف';

  @override
  String get chatPleaseEnterMusicLink => 'الرجاء إدخال رابط الموسيقى';

  @override
  String get chatPleaseEnterValidLink => 'الرجاء إدخال عنوان URL صالح';

  @override
  String get chatSharedSong => 'أغنية مشتركة';

  @override
  String get chatSelectMember => 'اختر عضوا';

  @override
  String get chatSearchMemberHint => 'أعضاء البحث';

  @override
  String get chatNoMatchingMembers => 'لم يتم العثور على أعضاء متطابقين';

  @override
  String get commonUnknownMember => 'غير معروف';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'رسائل $count مختارة';
  }

  @override
  String get chatSearchContactsOrGroups => 'البحث في جهات الاتصال أو المجموعات';

  @override
  String get chatVideoTitle => 'فيديو';

  @override
  String get chatLoadingText => 'جار التحميل...';

  @override
  String get chatVideoLoadFailed => 'فشل تحميل الفيديو';

  @override
  String get chatPlayerInitFailed => 'فشلت تهيئة المشغل';

  @override
  String get chatCreatePollTitle => 'إنشاء استطلاع';

  @override
  String get chatSubmitPoll => 'إرسال';

  @override
  String get chatPollQuestionLabel => 'سؤال الاستطلاع';

  @override
  String get chatEnterPollQuestionHint => 'الرجاء إدخال سؤال الاستطلاع';

  @override
  String get chatPollOptionsLabel => 'خيارات الاستطلاع';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'الخيار $index';
  }

  @override
  String get chatAddOptionButton => 'إضافة خيار';

  @override
  String get chatPollSettingsLabel => 'إعدادات الاستطلاع';

  @override
  String get chatSelectionType => 'نوع الاختيار';

  @override
  String get chatSingleChoiceLabel => 'واحد';

  @override
  String get chatMultiChoiceLabel => 'متعدد';

  @override
  String get chatAnonymousPollSwitch => 'استطلاع مجهول';

  @override
  String get chatPleaseEnterQuestion => 'الرجاء إدخال سؤال الاستطلاع';

  @override
  String get chatAtLeastTwoOptions => 'مطلوب خيارين على الأقل';

  @override
  String chatConfirmWithCount(int count) {
    return 'تأكيد ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'التحقق من البريد الإلكتروني';

  @override
  String get authEnterValidEmailAddress =>
      'الرجاء إدخال عنوان بريد إلكتروني صالح';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'تم إرسال رمز التحقق إلى $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'فشل إرسال الرمز: $error';
  }

  @override
  String get authVerificationSuccess => 'تم التحقق بنجاح';

  @override
  String get authVerificationFailed => 'فشل التحقق';

  @override
  String authVerificationCodeError(String error) {
    return 'خطأ في رمز التحقق: $error';
  }

  @override
  String get commonEnterVerificationCode => 'أدخل رمز التحقق';

  @override
  String get authEnterYourEmail => 'أدخل البريد الإلكتروني';

  @override
  String authWeSentCodeTo(String email) {
    return 'لقد أرسلنا رمزًا مكونًا من 6 أرقام إلى\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'أدخل عنوان بريدك الإلكتروني، وسنرسل لك رمز التحقق';

  @override
  String get commonSendVerificationCode => 'إرسال رمز التحقق';

  @override
  String get authResendVerificationCode => 'إعادة إرسال رمز التحقق';

  @override
  String authCanResendAfter(int seconds) {
    return 'يمكن إعادة الإرسال بعد ثواني $seconds';
  }

  @override
  String get commonChangeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get contactAddToContacts => 'إضافة إلى جهات الاتصال';

  @override
  String get contactAddingToContacts => 'جارٍ الإضافة...';

  @override
  String get contactAddedToContacts => 'تمت إضافتها إلى جهات الاتصال';

  @override
  String contactAddFailedWithError(String error) {
    return 'فشلت الإضافة: $error';
  }

  @override
  String get contactAddPhone => 'إضافة هاتف';

  @override
  String get contactAddTag => 'إضافة العلامات';

  @override
  String get contactAddText => 'أضف نصًا';

  @override
  String get contactAddPhoto => 'أضف صورة';

  @override
  String contactGroupCountLabel(int count) {
    return 'مجموعات $count';
  }

  @override
  String get contactAddedViaSearch => 'تمت إضافتها عبر البحث';

  @override
  String get contactAddTime => 'أضف الوقت';

  @override
  String get contactDoneButton => 'تم';

  @override
  String get callWaitingForParticipants => 'في انتظار انضمام المشاركين...';

  @override
  String callParticipantMe(String name) {
    return '$name (أنا)';
  }

  @override
  String get callSharingLabel => 'المشاركة';

  @override
  String callScreenSharingBy(String name) {
    return '$name يشارك الشاشة';
  }

  @override
  String callParticipantCount(int count) {
    return 'المشاركين $count';
  }

  @override
  String get callMuteLabel => 'كتم الصوت';

  @override
  String get callUnmuteLabel => 'إلغاء كتم الصوت';

  @override
  String get callTurnOffVideo => 'قم بإيقاف تشغيل الفيديو';

  @override
  String get callTurnOnVideo => 'قم بتشغيل الفيديو';

  @override
  String get callShareScreen => 'مشاركة الشاشة';

  @override
  String get callStopSharing => 'توقف عن المشاركة';

  @override
  String get callSwitchCameraLabel => 'التبديل';

  @override
  String get callLeaveLabel => 'غادر';

  @override
  String get callParticipantsLabel => 'المشاركون';

  @override
  String get callJoiningMeeting => 'الانضمام إلى الاجتماع...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return 'أصوات $count ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return 'المشاركين $count';
  }

  @override
  String get commonTapToRetry => 'انقر لإعادة المحاولة';

  @override
  String get chatDefaultRedPacketGreeting => 'أطيب التمنيات بالازدهار';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'السماح للآخرين بالبحث والانضمام';

  @override
  String get groupConfirmClearChatHistory =>
      'هل أنت متأكد أنك تريد مسح سجل الدردشة؟';

  @override
  String get groupCreateGroupToChat => 'قم بإنشاء مجموعة لبدء الدردشة';

  @override
  String get groupEditGroupAnnouncement => 'تحرير إعلان المجموعة';

  @override
  String get groupEditGroupDescription => 'تحرير وصف المجموعة';

  @override
  String get groupEnterGroupAnnouncement => 'أدخل إعلان المجموعة';

  @override
  String chatErrorWithMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return 'أعضاء $count، انقر لنسخ معرف المجموعة';
  }

  @override
  String get chatMusicLinkLabel => 'رابط الموسيقى';

  @override
  String get chatNoMediaUrlAvailable => 'لا يتوفر عنوان URL للوسائط';

  @override
  String get groupNoPermissionToEditGroupName =>
      'ليس لديك إذن لتعديل اسم المجموعة';

  @override
  String get chatRedPacketTransferCannotForward =>
      'لا يمكن إعادة توجيه الحزم الحمراء وعمليات النقل';

  @override
  String get authEmailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get commonEnterEmailAddress => 'أدخل عنوان البريد الإلكتروني';

  @override
  String get authEmailRecoveryHint => 'تستخدم لاستعادة كلمة المرور';

  @override
  String get commonInvalidEmailFormat =>
      'الرجاء إدخال عنوان بريد إلكتروني صالح';

  @override
  String get authOptional => 'اختياري';

  @override
  String get authResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get authEnterRegisteredEmail =>
      'أدخل عنوان البريد الإلكتروني الذي قمت بالتسجيل به';

  @override
  String get authSendResetCode => 'أرسل رمز إعادة الضبط';

  @override
  String authResetCodeSent(String email) {
    return 'تم إرسال رمز إعادة الضبط إلى $email';
  }

  @override
  String get authEnterResetCode => 'أدخل رمز إعادة الضبط';

  @override
  String get authSetNewPassword => 'تعيين كلمة مرور جديدة';

  @override
  String get commonConfirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get commonNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authPasswordResetSuccess =>
      'تمت إعادة تعيين كلمة المرور بنجاح. الرجاء تسجيل الدخول باستخدام كلمة المرور الجديدة الخاصة بك.';

  @override
  String get authResetPasswordFailed => 'فشلت إعادة تعيين كلمة المرور';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get settingsEnterCurrentPassword => 'أدخل كلمة المرور الحالية';

  @override
  String get settingsEnterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get settingsPasswordChanged =>
      'تم تغيير كلمة المرور بنجاح. الرجاء تسجيل الدخول باستخدام كلمة المرور الجديدة الخاصة بك.';

  @override
  String get settingsChangePasswordFailed => 'فشل تغيير كلمة المرور';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'كلمة المرور الجديدة يجب أن تكون مختلفة عن كلمة المرور الحالية';

  @override
  String get settingsChangePasswordInfo =>
      'بعد تغيير كلمة المرور، سيتم تسجيل خروجك وسيتعين عليك تسجيل الدخول باستخدام كلمة المرور الجديدة.';

  @override
  String get settingsPasswordRequirements => 'متطلبات كلمة المرور:';

  @override
  String get settingsSecurityNote =>
      'للأمان، ستحتاج إلى إعادة تسجيل الدخول على جميع الأجهزة بعد تغيير كلمة المرور.';

  @override
  String get settingsSecurity => 'الأمن';

  @override
  String get settingsCurrentBoundEmail => 'البريد الإلكتروني المنضم الحالي';

  @override
  String get settingsNewEmailAddress => 'عنوان البريد الإلكتروني الجديد';

  @override
  String get settingsEnterNewEmail => 'أدخل عنوان البريد الإلكتروني الجديد';

  @override
  String get settingsVerificationCode => 'رمز التحقق';

  @override
  String get settingsVerificationCodeSent => 'تم إرسال رمز التحقق';

  @override
  String get settingsCodeSentTo => 'تم إرسال رمز التحقق إلى';

  @override
  String get settingsDidNotReceiveCode => 'لم تتلق الرمز؟';

  @override
  String get settingsEmailChangedSuccess => 'تم تغيير البريد الإلكتروني بنجاح';

  @override
  String get settingsChangeEmailFailed => 'فشل تغيير البريد الإلكتروني';

  @override
  String get settingsEmailSecurityNote =>
      'يتم استخدام بريدك الإلكتروني لاستعادة كلمة المرور. يرجى الاحتفاظ بها آمنة.';

  @override
  String get commonGoogleLogin => 'قم بتسجيل الدخول باستخدام جوجل';

  @override
  String get commonAppleLogin => 'تسجيل الدخول مع أبل';

  @override
  String get commonWechat => 'وي شات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageChanged => 'تغيرت اللغة';

  @override
  String get settingsTranslation => 'الترجمة';

  @override
  String get settingsTranslateTextTo => 'ترجمة النص إلى';

  @override
  String get settingsTranslateDescription =>
      'حدد اللغة التي تريد ترجمة الرسائل إليها.';

  @override
  String get settingsAutoTranslate => 'الترجمة التلقائية للرسائل المستلمة';

  @override
  String get settingsAutoTranslateDescription =>
      'ترجمة الرسائل المستلمة في الدردشة تلقائيًا إلى لغتك المحددة.';

  @override
  String get settingsBiometricLogin => 'تسجيل الدخول البيومتري';

  @override
  String authLoginWithBiometric(Object type) {
    return 'تسجيل الدخول باستخدام $type';
  }

  @override
  String get settingsBiometricLoginEnabled => 'تم تمكين تسجيل الدخول البيومتري';

  @override
  String get settingsBiometricLoginDisabled =>
      'تم تعطيل تسجيل الدخول البيومتري';

  @override
  String get settingsEnableBiometricLogin => 'تمكين تسجيل الدخول البيومتري';

  @override
  String get settingsBiometricEnabled =>
      'ممكّن - استخدم القياسات الحيوية لتسجيل الدخول';

  @override
  String get settingsBiometricDisabled => 'معطل - انقر للتمكين';

  @override
  String get settingsBiometricNeedRelogin =>
      'يرجى تسجيل الخروج وتسجيل الدخول مرة أخرى لتمكين تسجيل الدخول البيومتري';

  @override
  String get authOr => 'أو';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'الوصول إلى الكاميرا مقيد على هذا الجهاز';

  @override
  String get authPasskeyLabel => 'مفتاح المرور';

  @override
  String get authGoogleLabel => 'جوجل';

  @override
  String get authAppleLabel => 'أبل';

  @override
  String get authSsoLabel => 'الدخول الموحد';

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
  String get profileEnterPokeSuffixHint =>
      'أدخل لاحقة الوخز، على سبيل المثال: على الكتف';

  @override
  String get groupAlbum => 'ألبوم المجموعة';

  @override
  String get groupFiles => 'ملفات المجموعة';

  @override
  String get groupImages => 'الصور';

  @override
  String get groupVideos => 'فيديوهات';

  @override
  String get groupTotal => 'المجموع';

  @override
  String get groupSize => 'الحجم';

  @override
  String get groupNoMedia => 'لا وسائل الإعلام';

  @override
  String get groupNoMediaDescription =>
      'لا توجد صور أو مقاطع فيديو في هذه المجموعة حتى الآن';

  @override
  String get groupDocuments => 'المستندات';

  @override
  String get groupNoFiles => 'لا توجد ملفات';

  @override
  String get groupNoFilesDescription =>
      'لا توجد ملفات في هذه المجموعة حتى الآن';

  @override
  String groupDownloadStarted(String filename) {
    return 'جارٍ التحميل $filename...';
  }

  @override
  String get contactNoCommonGroups => 'لا توجد مجموعات مشتركة';

  @override
  String get contactNoCommonGroupsDescription => 'ليس لديك أي مجموعات مشتركة';

  @override
  String get chatVoiceMessage => 'صوت';

  @override
  String get chatMessage => 'رسالة';

  @override
  String get conversationHideChat => 'إخفاء';

  @override
  String get settingsQuickReply => 'الرد السريع';

  @override
  String get commonTranslate => 'ترجمة';

  @override
  String get contactCreateTag => 'إنشاء علامة';

  @override
  String get contactEnterTagName => 'أدخل اسم العلامة';

  @override
  String get contactEditTag => 'تحرير العلامة';

  @override
  String get contactDeleteTag => 'حذف العلامة';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'هل أنت متأكد أنك تريد حذف العلامة \"$tagName\"؟';
  }

  @override
  String get contactNoTags => 'لا توجد علامات حتى الآن';

  @override
  String get contactFriendPermissions => 'أذونات الصديق';

  @override
  String get contactSetChatOnly => 'تعيين كدردشة فقط';

  @override
  String get contactChatOnlyDesc =>
      'يمكن الدردشة معك فقط، وسيتم إخفاء المحتوى الآخر';

  @override
  String get contactHideMyMoments => 'إخفاء لحظاتي';

  @override
  String get contactHideMyMomentsDesc => 'هذا الصديق لا يمكنه رؤية لحظاتي';

  @override
  String get contactHideTheirMoments => 'إخفاء لحظاتهم';

  @override
  String get contactHideTheirMomentsDesc => 'لا ترى لحظات هذا الصديق';

  @override
  String get contactHideMyStatus => 'إخفاء حالتي';

  @override
  String get contactHideMyStatusDesc =>
      'لا يستطيع هذا الصديق رؤية تحديثات حالتي';

  @override
  String get contactNoChatOnlyFriends => 'لا يوجد أصدقاء للدردشة فقط';

  @override
  String get contactNoOfficialAccounts => 'لا حسابات رسمية';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'اتبع الحسابات الرسمية للحصول على آخر التحديثات';

  @override
  String get contactNoServiceAccounts => 'لا توجد حسابات الخدمة';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'اشترك في حسابات الخدمة للحصول على خدمات مريحة';

  @override
  String get contactNoEnterpriseContacts => 'لا توجد اتصالات المؤسسة';

  @override
  String get contactEnterpriseContactsDesc => 'سيتم عرض جهات اتصال المؤسسة هنا';

  @override
  String get profileCardPack => 'حزمة البطاقة';

  @override
  String get profileOrders => 'أوامر';

  @override
  String get profileNoOrders => 'لا أوامر';

  @override
  String get profileOrdersDesc => 'سيتم عرض طلباتك هنا';

  @override
  String get profileNoCards => 'لا بطاقات';

  @override
  String get profileCardsDesc => 'سيتم عرض البطاقات الخاصة بك هنا';

  @override
  String get favoriteEnterTagsHint => 'أدخل العلامات مفصولة بفواصل';

  @override
  String get favoriteTagsUpdated => 'تم تحديث العلامات';

  @override
  String get favoriteForwardedContent => 'تم إعادة توجيه المحتوى';

  @override
  String get favoriteEnterNoteContent => 'أدخل محتوى الملاحظة';

  @override
  String get favoriteNoteAdded => 'تمت إضافة الملاحظة';

  @override
  String get favoriteLinkTitle => 'عنوان الرابط';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'تمت إضافة الرابط';

  @override
  String get contactPhotoAdded => 'تمت إضافة الصورة';

  @override
  String get contactEnterPhone => 'أدخل رقم الهاتف';

  @override
  String commonConversationWithId(String roomId) {
    return 'المحادثة: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'جهة الاتصال: $userId';
  }

  @override
  String get commonDiscover => 'اكتشف';

  @override
  String commonDeveloping(String title) {
    return '$title\n(قريبا)';
  }

  @override
  String get commonPageNotFound => 'لم يتم العثور على الصفحة';

  @override
  String get commonBackToHome => 'العودة إلى المنزل';

  @override
  String get settingsMessageNotifications => 'إشعارات الرسائل';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'تلقي إشعارات الرسائل الجديدة';

  @override
  String get settingsShowMessagePreview => 'إظهار معاينة الرسالة';

  @override
  String get settingsShowMessageContentInNotification =>
      'إظهار محتوى الرسالة في الإخطار';

  @override
  String get settingsNotificationSound => 'صوت الإخطار';

  @override
  String get settingsPlaySoundOnMessage => 'تشغيل الصوت عند تلقي الرسائل';

  @override
  String get commonVibration => 'الاهتزاز';

  @override
  String get settingsVibrateOnMessage => 'يهتز عند تلقي الرسائل';

  @override
  String get settingsDoNotDisturbMode => 'لا تزعج';

  @override
  String get settingsDoNotDisturbDescription =>
      'لا تتلقى الإخطارات خلال الوقت المحدد';

  @override
  String get settingsStartTime => 'وقت البدء';

  @override
  String get settingsEndTime => 'وقت النهاية';

  @override
  String get settingsDeleteQuickReply => 'حذف الرد السريع';

  @override
  String get settingsEditQuickReply => 'تحرير الرد السريع';

  @override
  String get settingsAddQuickReply => 'إضافة الرد السريع';

  @override
  String get settingsManageQuickReplies => 'إدارة الردود السريعة';

  @override
  String get settingsNoQuickReplies => 'لا ردود سريعة';

  @override
  String get settingsDefaultQuickReplies =>
      'سيتم عرض الردود السريعة الافتراضية';

  @override
  String get settingsWhoCanSee => 'من يستطيع أن يرى';

  @override
  String get settingsLastSeen => 'شوهد آخر مرة';

  @override
  String get settingsHiddenChats => 'الدردشات المخفية';

  @override
  String get settingsMessagesLabel => 'الرسائل';

  @override
  String get settingsAllowStrangerMessages => 'السماح برسائل الغرباء';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'تلقي رسائل من غير جهات الاتصال';

  @override
  String get settingsReadReceipts => 'قراءة الإيصالات';

  @override
  String get settingsLetOthersKnowYouRead => 'دع الآخرين يعرفون أنك تقرأ';

  @override
  String get settingsTypingIndicator => 'مؤشر الكتابة';

  @override
  String get settingsLetOthersKnowYouTyping => 'دع الآخرين يعرفون أنك تكتب';

  @override
  String get settingsEveryone => 'الجميع';

  @override
  String get settingsContactsOnly => 'جهات الاتصال فقط';

  @override
  String get settingsNobody => 'لا أحد';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'من يستطيع رؤية $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsCheckForUpdates => 'التحقق من وجود تحديثات';

  @override
  String get settingsOpenSourceLicenses => 'تراخيص مفتوحة المصدر';

  @override
  String get settingsFeedbackAndSuggestions => 'ردود الفعل والاقتراحات';

  @override
  String get settingsBuiltOnMatrix => 'مبني على بروتوكول المصفوفة';

  @override
  String get settingsNoHiddenChats => 'لا توجد محادثات مخفية';

  @override
  String get settingsNoHiddenChatsDescription =>
      'ستظهر هنا الدردشات التي تخفيها';

  @override
  String get settingsUnhideChat => 'إظهار';

  @override
  String get settingsDarkMode => 'الوضع المظلم';

  @override
  String get settingsFontSize => 'حجم الخط';

  @override
  String get settingsBubbleStyle => 'نمط الفقاعة';

  @override
  String get settingsFollowSystem => 'اتبع النظام';

  @override
  String get settingsAutoSwitchBySystem => 'التبديل التلقائي عن طريق النظام';

  @override
  String get settingsLightMode => 'وضع الضوء';

  @override
  String get settingsAlwaysUseLightTheme => 'استخدم دائمًا المظهر الفاتح';

  @override
  String get settingsDarkModeOption => 'خيار الوضع المظلم';

  @override
  String get settingsAlwaysUseDarkTheme => 'استخدم المظهر الداكن دائمًا';

  @override
  String get settingsFontSizeSmall => 'صغير';

  @override
  String get settingsFontSizeStandard => 'قياسي';

  @override
  String get settingsFontSizeLarge => 'كبير';

  @override
  String get settingsFontSizeExtraLarge => 'كبيرة جدًا';

  @override
  String get settingsBubbleStyleWechat => 'أسلوب ويتشات';

  @override
  String get settingsBubbleStyleWechatDesc => 'نمط فقاعة WeChat الكلاسيكي';

  @override
  String get settingsBubbleStyleModern => 'الطراز الحديث';

  @override
  String get settingsBubbleStyleModernDesc => 'نمط الفقاعة الحديث النظيف';

  @override
  String get settingsBubbleStyleClassic => 'النمط الكلاسيكي';

  @override
  String get settingsBubbleStyleClassicDesc => 'نمط الفقاعة التقليدي';

  @override
  String get discoverVideoChannels => 'القنوات';

  @override
  String get discoverLive => 'مباشر';

  @override
  String get discoverListen => 'استمع';

  @override
  String get discoverWatch => 'شاهد';

  @override
  String get discoverSearchDiscover => 'بحث';

  @override
  String get discoverNearbyPeople => 'قريب';

  @override
  String get discoverGames => 'العاب';

  @override
  String get discoverMiniPrograms => 'البرامج المصغرة';

  @override
  String get chatAlreadyInCall => 'في مكالمة بالفعل';

  @override
  String get commonConnectionFailed => 'فشل الاتصال';

  @override
  String get chatCallRejected => 'تم رفض المكالمة';

  @override
  String get chatNoAnswer => 'لا إجابة';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get chatSelectContact => 'حدد جهة الاتصال';

  @override
  String get chatVoteRemoved => 'تمت إزالة التصويت';

  @override
  String get chatVoteChanged => 'تم تغيير التصويت';

  @override
  String get chatVoted => 'تم التصويت';

  @override
  String chatReplyTo(String name) {
    return 'الرد على $name';
  }

  @override
  String get chatCurrentLocation => 'الموقع الحالي';

  @override
  String chatNearbyPlace(int index) {
    return 'مكان قريب $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'حول $distance';
  }

  @override
  String get chatAddress => 'العنوان';

  @override
  String get chatLatitude => 'خط العرض';

  @override
  String get chatLongitude => 'خط الطول';

  @override
  String get groupDescriptionUpdated => 'تم تحديث وصف المجموعة';

  @override
  String get groupAvatarUpdated => 'تم تحديث الصورة الرمزية للمجموعة';

  @override
  String get groupVisibilityUpdated => 'تم تحديث رؤية المجموعة';

  @override
  String get groupChannelCreated => 'تم إنشاء القناة';

  @override
  String get groupChannelUpdated => 'تم تحديث القناة';

  @override
  String get groupChannelDeleted => 'تم حذف القناة';

  @override
  String get callDecline => 'رفض';

  @override
  String get callAnswer => 'الإجابة';

  @override
  String get callIncomingVideoCall => 'مكالمة فيديو واردة';

  @override
  String get callIncomingVoiceCall => 'مكالمة صوتية واردة';

  @override
  String get callVideoCallInProgress => 'مكالمة الفيديو قيد التقدم';

  @override
  String get callVoiceCallInProgress => 'المكالمة الصوتية جارية';

  @override
  String get callReconnectingCall => 'جارٍ إعادة الاتصال...';

  @override
  String get callEnded => 'انتهت المكالمة';

  @override
  String get callFailed => 'فشل الاتصال';

  @override
  String get callLivekitNotConfigured => 'لم يتم تكوين LiveKit';

  @override
  String callJoinMeetingFailed(String error) {
    return 'فشل الانضمام إلى الاجتماع: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'فشلت مشاركة الشاشة: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 فول';

  @override
  String get profileNoN42Bean => 'لا يوجد فول N42';

  @override
  String get profileN42BeanDetails => 'تفاصيل الفول N42';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean هو رمز مميز يستخدم لاسترداد العناصر والخدمات الافتراضية في N42. متاح حاليا ل:';

  @override
  String get profileN42BeanFeature1 => 'ملصقات وموضوعات الأعضاء الحصرية';

  @override
  String get profileN42BeanFeature2 => 'تخصيص فقاعة الدردشة';

  @override
  String get profileN42BeanFeature3 => 'تخصيص غطاء الحزمة الحمراء';

  @override
  String get profileN42BeanFeature4 => 'شارة اللقب الحصرية';

  @override
  String get profileN42BeanFeature5 => 'امتيازات الدردشة الجماعية';

  @override
  String get profileN42BeanFeature6 => 'توسيع التخزين السحابي';

  @override
  String get profileN42BeanFeature7 => 'مرشحات الجمال لمكالمات الفيديو';

  @override
  String get profileN42BeanFeature8 => 'لحظات تخصيص الخلفية';

  @override
  String get profileN42BeanFeature9 => 'أولوية خدمة العملاء لكبار الشخصيات';

  @override
  String get profileGotIt => 'حصلت عليه';

  @override
  String get profileNoN42BeanRecords => 'لا توجد سجلات N42 Bean';

  @override
  String get profileMoodAndThoughts => 'المزاج والأفكار';

  @override
  String get profileStatusHappy => 'سعيد';

  @override
  String get profileStatusCracked => 'تحطمت';

  @override
  String get profileStatusLucky => 'محظوظ';

  @override
  String get profileStatusSunny => 'مشمس';

  @override
  String get profileStatusTired => 'متعب';

  @override
  String get profileStatusDaydream => 'أحلام اليقظة';

  @override
  String get profileStatusRushing => 'التسرع';

  @override
  String get profileStatusOverthinking => 'الإفراط في التفكير';

  @override
  String get profileStatusEnergized => 'تنشيط';

  @override
  String get profileWorkAndStudy => 'العمل والدراسة';

  @override
  String get profileStatusWorking => 'العمل';

  @override
  String get profileStatusStudying => 'دراسة';

  @override
  String get profileStatusBusy => 'مشغول';

  @override
  String get profileStatusSlacking => 'التراخي';

  @override
  String get profileStatusTraveling => 'السفر';

  @override
  String get profileStatusGoingHome => 'الذهاب إلى المنزل';

  @override
  String get profileStatusDnd => 'لا تزعج';

  @override
  String get profileActivities => 'الأنشطة';

  @override
  String get profileStatusHanging => 'التسكع';

  @override
  String get profileStatusCheckIn => 'تسجيل الوصول';

  @override
  String get profileStatusExercising => 'ممارسة الرياضة';

  @override
  String get profileStatusCoffee => 'قهوة';

  @override
  String get profileStatusBubbleTea => 'شاي الفقاعات';

  @override
  String get profileStatusEating => 'الأكل';

  @override
  String get profileStatusParenting => 'الأبوة والأمومة';

  @override
  String get profileStatusSavingWorld => 'إنقاذ العالم';

  @override
  String get profileStatusSelfie => 'صورة شخصية';

  @override
  String get profileRest => 'الراحة';

  @override
  String get profileStatusRetreat => 'تراجع';

  @override
  String get profileStatusHome => 'الصفحة الرئيسية';

  @override
  String get profileStatusSleeping => 'النوم';

  @override
  String get profileStatusCatLover => 'عاشق القطط';

  @override
  String get profileStatusDogWalking => 'كلب يمشي';

  @override
  String get profileStatusGaming => 'الألعاب';

  @override
  String get profileStatusListening => 'الاستماع';

  @override
  String get profileEditAddress => 'تحرير العنوان';

  @override
  String get profileRecipient => 'المستلم';

  @override
  String get profileEnterRecipientName => 'أدخل اسم المستلم';

  @override
  String get profilePhoneNumber => 'رقم الهاتف';

  @override
  String get profileEnterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get profileRegionHint => 'المقاطعة / المدينة / المنطقة';

  @override
  String get profileDetailedAddress => 'العنوان التفصيلي';

  @override
  String get profileDetailedAddressHint => 'الشارع ورقم المبنى وما إلى ذلك.';

  @override
  String get profileSetAsDefaultAddress => 'تعيين كعنوان افتراضي';

  @override
  String get profilePleaseCompleteInfo => 'الرجاء إكمال كافة الحقول';

  @override
  String get profileEditInvoice => 'تحرير الفاتورة';

  @override
  String get profileInvoiceType => 'نوع الفاتورة';

  @override
  String get profileCompanyName => 'اسم الشركة';

  @override
  String get profilePersonalName => 'الاسم الشخصي';

  @override
  String get profileEnterCompanyName => 'أدخل اسم الشركة';

  @override
  String get profileEnterName => 'أدخل الاسم';

  @override
  String get profileTaxIdNumber => 'رقم التعريف الضريبي';

  @override
  String get profileEnterTaxIdNumber => 'أدخل رقم الهوية الضريبية';

  @override
  String get profileBankNameOptional => 'اسم البنك (اختياري)';

  @override
  String get profileEnterBankName => 'أدخل اسم البنك';

  @override
  String get profileBankAccountOptional => 'الحساب البنكي (اختياري)';

  @override
  String get profileEnterBankAccount => 'أدخل الحساب البنكي';

  @override
  String get profileCompanyAddressOptional => 'عنوان الشركة (اختياري)';

  @override
  String get profileEnterCompanyAddress => 'أدخل عنوان الشركة';

  @override
  String get profileCompanyPhoneOptional => 'هاتف الشركة (اختياري)';

  @override
  String get profileEnterCompanyPhone => 'أدخل هاتف الشركة';

  @override
  String get profileSetAsDefaultInvoice => 'تعيين كفاتورة افتراضية';

  @override
  String get profileRingtoneVibrate => 'يهتز';

  @override
  String get profileRingtoneSilent => 'صامت';

  @override
  String get profileVibrateMode => 'وضع الاهتزاز';

  @override
  String get profileSilentMode => 'الوضع الصامت';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'فشل اللعب: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'التشغيل: $ringtoneName';
  }

  @override
  String get profileStop => 'توقف';

  @override
  String get profileSelectRingtone => 'حدد نغمة الرنين';

  @override
  String get profileLoadingRingtones => 'جارٍ تحميل نغمات الرنين...';

  @override
  String get profileNoRingtonesFound => 'لم يتم العثور على نغمات رنين';

  @override
  String mainMessagesWithCount(int count) {
    return 'الرسائل($count)';
  }

  @override
  String get storyViewers => 'المشاهدين';

  @override
  String get storyNoViewers => 'لا يوجد مشاهدين حتى الآن';

  @override
  String get storyReplyToStory => 'الرد على القصة...';

  @override
  String get commonCopiedToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get commonMore => 'المزيد';

  @override
  String get commonTranslating => 'ترجمة...';

  @override
  String commonTranslatedFrom(String language) {
    return 'مترجم من $language';
  }

  @override
  String get commonTranslation => 'الترجمة';

  @override
  String get commonTranslationFailed => 'فشلت الترجمة';

  @override
  String get commonAllRead => 'كل قراءة';

  @override
  String commonReadCount(int count) {
    return 'قراءة $count';
  }

  @override
  String get commonYouRecalledMessage => 'لقد تذكرت رسالة';

  @override
  String get commonMessageRecalled => 'تم تذكر الرسالة';

  @override
  String get commonReEdit => 'إعادة التحرير';

  @override
  String get commonWalletArea => 'منطقة المحفظة';

  @override
  String get callIncomingCall => 'مكالمة واردة';

  @override
  String get callMissedCall => 'مكالمة فائتة';

  @override
  String get groupRemoveAdmin => 'إزالة المشرف';

  @override
  String get chatSelectCurrency => 'اختر العملة';

  @override
  String get chatSelectEmoji => 'حدد الرموز التعبيرية';

  @override
  String get chatSelectRedPacketCover => 'حدد الغلاف';

  @override
  String get groupSetAsAdmin => 'تعيين كمسؤول';

  @override
  String get chatVideoPlaybackFailed => 'فشل تشغيل الفيديو';

  @override
  String get groupViewProfile => 'عرض الملف الشخصي';

  @override
  String get favoriteAddLinkComingSoon => 'إضافة ميزة الارتباط قريبا';

  @override
  String get favoriteNewNoteComingSoon => 'ميزة مذكرة جديدة قريبا';

  @override
  String get qrcodeSaveFeatureComingSoon => 'ميزة الحفظ قريبا';

  @override
  String get qrcodeShareFeatureComingSoon => 'ميزة المشاركة قريبا';

  @override
  String qrcodeProcessFailed(String error) {
    return 'فشلت معالجة رمز الاستجابة السريعة: $error';
  }

  @override
  String get securityDeviceIdRequired => 'معرف الجهاز مطلوب';

  @override
  String securityVerificationStartFailed(String error) {
    return 'فشل بدء التحقق: $error';
  }

  @override
  String get securityVerificationFailed => 'فشل التحقق';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'فشل التحقق: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'تم رفض التحقق - الرموز التعبيرية غير متطابقة';

  @override
  String get securityWaitingForDeviceAccept => 'في انتظار قبول الجهاز الآخر...';

  @override
  String get securityVerifyDevice => 'التحقق من هذا الجهاز';

  @override
  String get securityConfirmEmojiMatch =>
      'تأكد من عرض الرموز التعبيرية أدناه على كلا الجهازين بنفس الترتيب';

  @override
  String get securityEmojiDontMatch => 'أنها لا تتطابق';

  @override
  String get securityEmojiMatch => 'إنهم متطابقون';

  @override
  String get securityWaitingForDeviceConfirm =>
      'في انتظار تأكيد الجهاز الآخر...';

  @override
  String get securityVerificationSuccess => 'تم التحقق بنجاح!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'تم الآن التحقق من هذا الجهاز وموثوق به.';

  @override
  String get securityCompareEmoji => 'قارن الرموز التعبيرية على كلا الجهازين';

  @override
  String get securityCompareNumbers => 'قارن الأرقام على كلا الجهازين';

  @override
  String get commonTryAgain => 'حاول مرة أخرى';

  @override
  String get commonDone => 'تم';

  @override
  String get chatExportTitle => 'تصدير الدردشة';

  @override
  String get chatExportSuccess => 'تم التصدير بنجاح';

  @override
  String chatExportFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get chatExportFormat => 'تنسيق التصدير';

  @override
  String get chatExportHtmlDesc => 'يمكن قراءتها في أي متصفح بتصميم أنيق';

  @override
  String get chatExportJsonDesc => 'تنسيق بيانات منظمة يمكن قراءته آليًا';

  @override
  String get chatExportDateRange => 'النطاق الزمني';

  @override
  String get chatExportAll => 'جميع الرسائل';

  @override
  String get chatExportLastWeek => 'آخر 7 أيام';

  @override
  String get chatExportLastMonth => 'الشهر الماضي';

  @override
  String get chatExportLast3Months => 'آخر 3 أشهر';

  @override
  String get chatExportMessageCount => 'رسائل للتصدير';

  @override
  String get chatExportButton => 'تصدير ومشاركة';

  @override
  String get chatMediaGallery => 'معرض الوسائط';

  @override
  String get chatExportHistory => 'تصدير سجل الدردشة';

  @override
  String get pdfLoadFailed => 'فشل تحميل PDF';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'الكل';

  @override
  String get mediaImages => 'الصور';

  @override
  String get mediaVideos => 'فيديوهات';

  @override
  String get mediaFiles => 'ملفات';

  @override
  String get mediaAudio => 'الصوت';

  @override
  String mediaItemsCount(int count) {
    return 'عناصر $count';
  }

  @override
  String get mediaNoMediaFound => 'لم يتم العثور على أي وسائط';

  @override
  String get spacesTitle => 'المجتمعات';

  @override
  String get spacesCreate => 'إنشاء مجتمع';

  @override
  String get spacesJoined => 'انضم';

  @override
  String get spacesDiscover => 'اكتشف';

  @override
  String get spacesNoJoined => 'لم تنضم أي مجتمعات حتى الآن';

  @override
  String get spacesExplore => 'اكتشف المجتمعات';

  @override
  String get spacesNoPublic => 'لم يتم العثور على مجتمعات عامة';

  @override
  String get spacesJoin => 'انضم';

  @override
  String get spacesSubSpaces => 'المجتمعات الفرعية';

  @override
  String get spacesChannels => 'القنوات';

  @override
  String spacesMembersCount(int count) {
    return 'أعضاء $count';
  }

  @override
  String get spacesPublic => 'عام';

  @override
  String get spacesPrivate => 'خاص';

  @override
  String get spacesSuggested => 'مقترح';

  @override
  String spacesChannelsCount(int count) {
    return 'قنوات $count';
  }

  @override
  String get callInCallChat => 'الدردشة أثناء المكالمة';

  @override
  String callMessagesCount(int count) {
    return 'رسائل $count';
  }

  @override
  String get callNoMessagesYet => 'لا توجد رسائل حتى الآن.\nأرسل رسالة للبدء.';

  @override
  String get callTypeMessage => 'اكتب رسالة...';

  @override
  String get callYouSender => 'أنت';

  @override
  String get callChatLabel => 'الدردشة';

  @override
  String get chatEdited => 'تم تحريره';

  @override
  String get chatEditHistory => 'تحرير التاريخ';

  @override
  String get chatOriginalMessage => 'أصلي';

  @override
  String chatEditedAt(String time) {
    return 'تم التعديل في $time';
  }

  @override
  String get chatViewOnce => 'عرض مرة واحدة';

  @override
  String get chatViewOncePhoto => 'عرض الصورة مرة واحدة';

  @override
  String get chatViewOnceVideo => 'شاهد الفيديو مرة واحدة';

  @override
  String get chatViewOnceViewed => 'تم المشاهدة';

  @override
  String get chatViewOnceExpired => 'انتهت صلاحيتها';

  @override
  String get chatViewOnceTap => 'انقر للعرض';

  @override
  String get chatAutoFaceBlur => 'طمس الوجه التلقائي';

  @override
  String get chatAutoFaceBlurDesc => 'طمس الوجوه تلقائيًا عند إرسال الصور';

  @override
  String get threadReplyInThread => 'الرد في الموضوع';

  @override
  String threadReplies(int count) {
    return 'ردود $count';
  }

  @override
  String get threadReply => '1 رد';

  @override
  String threadLatestReply(String preview) {
    return 'الأحدث: $preview';
  }

  @override
  String get threadTitle => 'الموضوع';

  @override
  String get threadReplyPlaceholder => 'الرد في الموضوع...';

  @override
  String threadParticipants(int count) {
    return 'المشاركين $count';
  }

  @override
  String get voiceRoomTitle => 'غرفة الصوت';

  @override
  String get voiceRoomCreate => 'إنشاء غرفة صوتية';

  @override
  String get voiceRoomJoin => 'انضم';

  @override
  String get voiceRoomLeave => 'غادر';

  @override
  String get voiceRoomEnd => 'غرفة النهاية';

  @override
  String get voiceRoomRaiseHand => 'ارفع اليد';

  @override
  String get voiceRoomLowerHand => 'اليد السفلى';

  @override
  String get voiceRoomMute => 'كتم الصوت';

  @override
  String get voiceRoomUnmute => 'إلغاء كتم الصوت';

  @override
  String get voiceRoomHost => 'المضيف';

  @override
  String get voiceRoomSpeakers => 'مكبرات الصوت';

  @override
  String get voiceRoomListeners => 'المستمعون';

  @override
  String get voiceRoomLive => 'مباشر';

  @override
  String get voiceRoomEnded => 'انتهى';

  @override
  String get voiceRoomScheduled => 'المقرر';

  @override
  String get voiceRoomApprove => 'موافقة';

  @override
  String get voiceRoomDemote => 'انتقل إلى المستمع';

  @override
  String voiceRoomHandRaised(String name) {
    return 'رفع $name أيديهم';
  }

  @override
  String get voiceRoomName => 'اسم الغرفة';

  @override
  String get voiceRoomTopic => 'الموضوع (اختياري)';

  @override
  String get voiceRoomNoActive => 'لا توجد غرف صوتية نشطة';

  @override
  String get voiceRoomConnecting => 'جارٍ الاتصال...';

  @override
  String get usernameTitle => 'اسم المستخدم';

  @override
  String get usernameSet => 'تعيين اسم المستخدم';

  @override
  String get usernameChange => 'تغيير اسم المستخدم';

  @override
  String get usernamePlaceholder => 'أدخل اسم المستخدم';

  @override
  String get usernameAvailable => 'اسم المستخدم متاح';

  @override
  String get usernameUnavailable => 'اسم المستخدم مأخوذ بالفعل';

  @override
  String get usernameInvalid =>
      '3-30 حرفًا، أحرف صغيرة، أرقام، شرطة سفلية. يجب أن تبدأ بحرف.';

  @override
  String get usernameReserved => 'اسم المستخدم هذا محجوز';

  @override
  String get usernameSaved => 'تم حفظ اسم المستخدم';

  @override
  String get usernameSearchHint => 'البحث عن طريق @اسم المستخدم';

  @override
  String get ensName => 'اسم إنس';

  @override
  String get ensLinked => 'مرتبط بـ ENS';

  @override
  String get ensResolving => 'حل مشكلة ENS...';

  @override
  String get ensNotFound => 'لم يتم العثور على اسم ENS';

  @override
  String get tokenGateTitle => 'بوابة الرمز';

  @override
  String get tokenGateEnable => 'تمكين بوابة الرمز المميز';

  @override
  String get tokenGateDisable => 'تعطيل بوابة الرمز المميز';

  @override
  String get tokenGateAddRule => 'أضف القاعدة';

  @override
  String get tokenGateRemoveRule => 'إزالة القاعدة';

  @override
  String get tokenGateContractAddress => 'عنوان العقد';

  @override
  String get tokenGateMinBalance => 'الحد الأدنى للرصيد';

  @override
  String get tokenGateTokenId => 'معرف الرمز المميز (ERC-1155)';

  @override
  String get tokenGateChainId => 'معرف السلسلة';

  @override
  String get tokenGateVerifying => 'التحقق من ملكية الرموز المميزة...';

  @override
  String get tokenGateVerified => 'تم التحقق';

  @override
  String get tokenGateDenied => 'أنت لا تستوفي متطلبات الرمز المميز';

  @override
  String get tokenGateOperatorAnd => 'يجب أن تستوفي جميع القواعد';

  @override
  String get tokenGateOperatorOr => 'يجب أن تستوفي أي قاعدة';

  @override
  String get tokenGateRuleErc20 => 'رمز ERC-20';

  @override
  String get tokenGateRuleErc721 => 'ان اف تي (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'الرموز المتعددة (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'الرمز الأصلي';

  @override
  String get tokenGateSaved => 'تم حفظ بوابة الرمز المميز';

  @override
  String get tokenGateEnableDescription =>
      'مطالبة الأعضاء بحمل الرموز المميزة للانضمام';

  @override
  String get tokenGateOperator => 'منطق القاعدة';

  @override
  String get tokenGateRules => 'القواعد';

  @override
  String get tokenGateSymbol => 'الرمز (اختياري)';

  @override
  String get tokenGateChain => 'سلسلة';

  @override
  String get tokenGateTokenStandard => 'معيار الرمز المميز';

  @override
  String get tokenGateDenialMessage => 'رسالة الرفض';

  @override
  String get tokenGateDenialMessageHint => 'تظهر الرسالة عند فشل التحقق';

  @override
  String get tokenGateVerifyTitle => 'التحقق من الرمز المميز';

  @override
  String get tokenGateVerifyPassed => 'تم التحقق';

  @override
  String get tokenGateVerifyFailed => 'فشل التحقق';

  @override
  String get tokenGateRetryVerify => 'أعد المحاولة';

  @override
  String get tokenGateRequired => 'مطلوب';

  @override
  String get tokenGateYourBalance => 'رصيدك';

  @override
  String get tokenGateRulesActive => 'القواعد نشطة';

  @override
  String get tokenGateDisabled => 'معطل';

  @override
  String get ensNotBound => 'غير ملزمة';

  @override
  String get liveLocation => 'الموقع المباشر';

  @override
  String get stopLiveLocation => 'توقف عن المشاركة';

  @override
  String get startLiveLocation => 'ابدأ المشاركة';

  @override
  String get selectDuration => 'حدد المدة';

  @override
  String get groupChatFiles => 'ملفات الدردشة';

  @override
  String get groupLinks => 'روابط';

  @override
  String get groupNoLinks => 'لا توجد روابط حتى الآن';

  @override
  String get chatBackground => 'خلفية الدردشة';

  @override
  String get solidColors => 'الألوان الصلبة';

  @override
  String get gradients => 'التدرجات';

  @override
  String get defaultBackground => 'الافتراضي';

  @override
  String get settingsFontSizeSlider => 'حجم الخط';

  @override
  String get autoDownload => 'التنزيل التلقائي';

  @override
  String get images => 'الصور';

  @override
  String get voice => 'صوت';

  @override
  String get video => 'فيديو';

  @override
  String get files => 'ملفات';

  @override
  String get mobileData => 'بيانات الجوال';

  @override
  String get roaming => 'التجوال';

  @override
  String get storageManagement => 'التخزين';

  @override
  String get totalUsage => 'الاستخدام الإجمالي';

  @override
  String get cache => 'ذاكرة التخزين المؤقت';

  @override
  String get other => 'أخرى';

  @override
  String get clearCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get cacheCleared => 'تم مسح ذاكرة التخزين المؤقت';

  @override
  String get clearCacheFailed => 'فشل في مسح ذاكرة التخزين المؤقت';

  @override
  String get confirmClearCache =>
      'هل تريد مسح جميع بيانات ذاكرة التخزين المؤقت؟';

  @override
  String get mapView => 'عرض الخريطة';

  @override
  String liveLocationSharingCount(int count) {
    return '$count يشارك الأشخاص الموقع';
  }

  @override
  String get minutes15 => '15 دقيقة';

  @override
  String get minutes30 => '30 دقيقة';

  @override
  String get hour1 => '1 ساعة';

  @override
  String get hours8 => '8 ساعات';

  @override
  String get personalCard => 'البطاقة الشخصية';

  @override
  String get downloadFailed => 'فشل التنزيل';

  @override
  String get locationExpired => 'انتهت صلاحيتها';

  @override
  String secondsRemaining(int count) {
    return '$count ثانية';
  }

  @override
  String minutesRemaining(int count) {
    return 'دقائق $count';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours ساعة $minutes دقيقة';
  }

  @override
  String get favoriteMessages => 'المفضلة';

  @override
  String get linksCopied => 'تم نسخ الرابط';

  @override
  String get noLinksFound => 'لم يتم العثور على روابط';

  @override
  String get roomStorageRanking => 'تصنيف تخزين الغرفة';

  @override
  String get downloadComplete => 'اكتمل التنزيل';

  @override
  String get downloading => 'جارٍ التنزيل...';

  @override
  String get draftSaved => 'تم حفظ المسودة';

  @override
  String get voiceRecording => 'تسجيل صوتي';

  @override
  String get searchLocation => 'موقع البحث';

  @override
  String get tapToSearch => 'انقر للبحث';

  @override
  String get settingsThisDevice => 'هذا الجهاز';

  @override
  String get settingsJustNow => 'الآن فقط';

  @override
  String get settingsDeviceId => 'معرف الجهاز';

  @override
  String get settingsStatus => 'الحالة';

  @override
  String get settingsLastActive => 'آخر نشاط';

  @override
  String get settingsIpAddress => 'عنوان IP';

  @override
  String get settingsRenameDevice => 'إعادة تسمية الجهاز';

  @override
  String get settingsDeviceNameHint => 'أدخل اسم الجهاز';

  @override
  String get settingsDeviceRenamed => 'تمت إعادة تسمية الجهاز';

  @override
  String get settingsRenameFailed => 'فشلت إعادة التسمية';

  @override
  String get settingsRemoteLogout => 'تسجيل الخروج عن بعد';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'هل أنت متأكد أنك تريد تسجيل الخروج \"$deviceName\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get settingsDeviceLoggedOut => 'تم تسجيل خروج الجهاز';

  @override
  String get settingsLogoutFailed => 'فشل تسجيل الخروج';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsVerifyIdentity => 'التحقق من الهوية';

  @override
  String get settingsEnterPasswordToConfirm =>
      'أدخل كلمة المرور الخاصة بك لتأكيد هذا الإجراء.';

  @override
  String get scheduledSendTitle => 'جدولة الرسالة';

  @override
  String get scheduledSendInOneHour => 'في 1 ساعة';

  @override
  String get scheduledSendTonight => 'الليلة (8:00 مساءً)';

  @override
  String get scheduledSendTomorrowMorning => 'صباح الغد (9:00 صباحًا)';

  @override
  String get scheduledSendCustom => 'اختر التاريخ والوقت';

  @override
  String get scheduledMessageLabel => 'المقرر';

  @override
  String get scheduledMessageCancel => 'إلغاء الرسالة المجدولة';

  @override
  String get chatLockTitle => 'قفل الدردشة';

  @override
  String get chatLockEnable => 'قفل هذه الدردشة';

  @override
  String get chatLockDisable => 'فتح هذه الدردشة';

  @override
  String get chatLockDescription =>
      'تتطلب الدردشات المقفلة التحقق من المقاييس الحيوية أو رقم التعريف الشخصي لفتحها';

  @override
  String get chatLockVerifyTitle => 'الدردشة مغلقة';

  @override
  String get chatLockVerifySubtitle => 'قم بالتحقق للوصول إلى هذه الدردشة';

  @override
  String get chatLockVerifyFailed => 'فشل التحقق';

  @override
  String get chatLockEnabled => 'الدردشة مغلقة';

  @override
  String get chatLockDisabled => 'تم فتح الدردشة';

  @override
  String get chatLockPinTitle => 'أدخل رقم التعريف الشخصي';

  @override
  String get chatLockPinSetTitle => 'تعيين رقم التعريف الشخصي';

  @override
  String get chatLockPinConfirmTitle => 'تأكيد رقم التعريف الشخصي';

  @override
  String get chatLockPinMismatch => 'رقم التعريف الشخصي غير متطابق';

  @override
  String get chatLockUseBiometric => 'استخدم القياسات الحيوية';

  @override
  String get chatLockUsePin => 'استخدم رقم التعريف الشخصي';

  @override
  String get mediaEditorUndo => 'تراجع';

  @override
  String get mediaEditorRedo => 'إعادة';

  @override
  String get mediaEditorCrop => 'المحاصيل';

  @override
  String get mediaEditorFilter => 'تصفية';

  @override
  String get mediaEditorDraw => 'ارسم';

  @override
  String get mediaEditorText => 'نص';

  @override
  String get aiAssistant => 'مساعد الذكاء الاصطناعي';

  @override
  String get aiAssistantWelcome =>
      'مرحبا! أنا مساعد الذكاء الاصطناعي N42. كيف يمكنني مساعدك؟';

  @override
  String get aiAssistantNotConfigured => 'لم يتم تكوين خدمة الذكاء الاصطناعي';

  @override
  String get aiAssistantSettings => 'إعدادات الذكاء الاصطناعي';

  @override
  String get aiAssistantClearHistory => 'مسح سجل الدردشة';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'هل أنت متأكد من أنك تريد مسح كل سجل دردشة الذكاء الاصطناعي؟';

  @override
  String get aiAssistantStopGenerating => 'توقف عن التوليد';

  @override
  String get aiAssistantModel => 'نموذج';

  @override
  String get aiAssistantTemperature => 'درجة الحرارة';

  @override
  String get aiAssistantMaxTokens => 'الرموز القصوى';

  @override
  String get aiAssistantContextWindow => 'نافذة السياق';

  @override
  String get aiAssistantServiceStatus => 'حالة الخدمة';

  @override
  String get aiAssistantAvailable => 'متاح';

  @override
  String get aiAssistantUnavailable => 'غير متاح';

  @override
  String get aiSummarize => 'ملخص الذكاء الاصطناعي';

  @override
  String aiSummarizeUnread(int count) {
    return 'تلخيص الرسائل غير المقروءة $count';
  }

  @override
  String get aiSummarizeLoading => 'تلخيص...';

  @override
  String get aiSummarizeError => 'فشل في التلخيص';

  @override
  String get aiRewrite => 'إعادة كتابة الذكاء الاصطناعي';

  @override
  String get aiRewriteFormal => 'رسمي';

  @override
  String get aiRewriteCasual => 'عادية';

  @override
  String get aiRewritePlayful => 'لعوب';

  @override
  String get aiRewriteProfessional => 'محترف';

  @override
  String get aiRewriteAccept => 'استخدم';

  @override
  String get aiRewriteCancel => 'إلغاء';

  @override
  String get aiRewriteLoading => 'إعادة الكتابة...';

  @override
  String get aiLinkSummary => 'ملخص الذكاء الاصطناعي';

  @override
  String get aiLinkSummaryAnalyzing => 'جارٍ التحليل...';

  @override
  String get chatFolderManagement => 'إدارة المجلدات';

  @override
  String get chatFolderSystem => 'مجلدات النظام';

  @override
  String get chatFolderCustom => 'المجلدات المخصصة';

  @override
  String get chatFolderEmpty => 'لا توجد مجلدات مخصصة حتى الآن';

  @override
  String get chatFolderCreate => 'إنشاء مجلد';

  @override
  String get chatFolderEdit => 'تحرير المجلد';

  @override
  String get chatFolderNameHint => 'اسم المجلد';

  @override
  String get chatFolderAll => 'الكل';

  @override
  String get chatFolderUnread => 'غير مقروءة';

  @override
  String get chatFolderPersonal => 'شخصي';

  @override
  String get chatFolderGroups => 'المجموعات';

  @override
  String get chatFolderChannels => 'القنوات';

  @override
  String get chatFolderMuted => 'كتم الصوت';

  @override
  String get storyAddMusic => 'أضف موسيقى';

  @override
  String get storyChangeMusic => 'تغيير الموسيقى';

  @override
  String get storyBackgroundMusic => 'موسيقى خلفية';

  @override
  String get storyMusicPreview => 'المعاينة (بحد أقصى 15 ثانية)';

  @override
  String get storyChooseFromDevice => 'اختر من الجهاز';

  @override
  String get storyUseThisMusic => 'استخدم هذه الموسيقى';

  @override
  String get authPasskeyNotSupported => 'مفتاح المرور غير مدعوم على هذا الجهاز';

  @override
  String get authPasskeyRegister => 'تسجيل مفتاح المرور';

  @override
  String get authPasskeyNoRegistered => 'لم يتم تسجيل أي مفاتيح مرور';

  @override
  String get authPasskeyRegisterHint =>
      'تسجيل مفتاح مرور لهذا الحساب. سيتم تمكين تسجيل الدخول بمفتاح المرور المستقل لاحقًا.';

  @override
  String get authPasskeyNameYours => 'قم بتسمية مفتاح المرور الخاص بك';

  @override
  String get authPasskeyRegistered => 'تم حفظ مفتاح المرور في هذا الحساب';

  @override
  String get authPasskeyDeleted => 'تمت إزالة مفتاح المرور من هذا الحساب';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'هل تريد حذف مفتاح المرور \"$name\"؟ ستحتاج إلى تسجيله مرة أخرى قبل استخدام تسجيل الدخول بمفتاح المرور لاحقًا.';
  }

  @override
  String get momentVisibilityPublic => 'عام';

  @override
  String get momentVisibilityPrivate => 'خاص';

  @override
  String get momentVisibilityPartial => 'الأصدقاء المختارون';

  @override
  String get momentVisibilityExcluded => 'استبعاد بعض الأصدقاء';

  @override
  String momentUserMoments(String userName) {
    return 'لحظات $userName';
  }

  @override
  String get momentForwardTo => 'إلى الأمام ل';

  @override
  String get momentForwardSuccess => 'تم الإرسال بنجاح';

  @override
  String get momentSelectFriends => 'حدد الأصدقاء';

  @override
  String get momentSelectTags => 'اختر حسب العلامات';

  @override
  String momentSelectedCount(int count) {
    return 'محدد ($count)';
  }

  @override
  String get momentNoMomentsYet => 'لا توجد لحظات بعد';

  @override
  String get momentForwardMoment => 'لحظة إلى الأمام';

  @override
  String get momentAddComment => 'إضافة تعليق...';

  @override
  String momentForwardContent(String content) {
    return '[لحظة] $content';
  }

  @override
  String get momentDeleteMoment => 'حذف لحظة';

  @override
  String get momentDeleteConfirm => 'هل أنت متأكد أنك تريد حذف هذه اللحظة؟';

  @override
  String get momentComment => 'التعليق';

  @override
  String get momentWriteComment => 'أكتب تعليق...';

  @override
  String get momentLike => 'مثل';

  @override
  String get momentUnlike => 'على عكس';

  @override
  String get momentForward => 'إلى الأمام';

  @override
  String get momentDelete => 'حذف';

  @override
  String get momentReply => 'الرد';

  @override
  String get momentMoment => 'لحظة';

  @override
  String momentLikesCount(int count) {
    return '$count يحب';
  }

  @override
  String momentCommentsCount(int count) {
    return 'تعليقات $count';
  }

  @override
  String get momentNoComments => 'لا توجد تعليقات حتى الآن';

  @override
  String get momentFailedToLoad => 'فشل تحميل الصورة';

  @override
  String momentReplyTo(String userName) {
    return 'الرد على $userName...';
  }

  @override
  String get momentNoConversations => 'لا محادثات';

  @override
  String get momentJustNow => 'الآن فقط';

  @override
  String momentMinutesAgo(int count) {
    return 'منذ ${count}m';
  }

  @override
  String momentHoursAgo(int count) {
    return 'منذ ${count}h';
  }

  @override
  String momentDaysAgo(int count) {
    return 'منذ ${count}d';
  }

  @override
  String get chatGroupAnnouncementHint => 'أدخل إعلان المجموعة';

  @override
  String get chatGroupAnnouncementEmpty => 'لا يوجد إعلان';

  @override
  String get chatEditNickname => 'تحرير اللقب';

  @override
  String get chatNicknameHint => 'أدخل لقبك في هذه المجموعة';

  @override
  String get contactAddPhoneHint => 'أدخل رقم الهاتف';

  @override
  String get contactNotesHint => 'أضف ملاحظات حول جهة الاتصال هذه';

  @override
  String get reportTitle => 'تقرير';

  @override
  String get reportReasonSpam => 'البريد العشوائي';

  @override
  String get reportReasonHarassment => 'التحرش';

  @override
  String get reportReasonFraud => 'الاحتيال';

  @override
  String get reportReasonOther => 'أخرى';

  @override
  String get reportSubmitted => 'تم تقديم التقرير';

  @override
  String get reportDescription => 'وصف إضافي (اختياري)';

  @override
  String get qrcodeSaved => 'تم حفظ رمز الاستجابة السريعة في الألبوم';

  @override
  String get chatSendRedPacketInChat => 'يرجى إرسال الحزمة الحمراء في الدردشة';

  @override
  String get commonSaveFailed => 'فشل الحفظ';

  @override
  String get reportSelectReason => 'الرجاء تحديد السبب';

  @override
  String get gameCenter => 'العاب';

  @override
  String get gameHighScore => 'الأفضل';

  @override
  String get gameScore => 'النتيجة';

  @override
  String get gameOver => 'انتهت اللعبة';

  @override
  String get gamePlayAgain => 'العب مرة أخرى';

  @override
  String get gameLeaderboard => 'المتصدرين';

  @override
  String get gamePause => 'متوقف مؤقتًا';

  @override
  String get gameResume => 'انقر للاستئناف';

  @override
  String get gameConfirmExit => 'ترك هذه اللعبة؟';

  @override
  String get gameNoScores => 'لا توجد نتائج حتى الآن';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'دمج البلاط للوصول إلى 2048';

  @override
  String get gameBlockDrop => 'إسقاط الكتلة';

  @override
  String get gameBlockDropDesc => 'إسقاط وخطوط واضحة';

  @override
  String get gameMinesweeper => 'كاسحة ألغام';

  @override
  String get gameMinesweeperDesc => 'البحث عن جميع الخلايا الآمنة';

  @override
  String get gameMatch3 => 'المباراة 3';

  @override
  String get gameMatch3Desc => 'المباراة 3 أو أكثر من الأحجار الكريمة';

  @override
  String get gameMinesweeperEasy => 'سهل';

  @override
  String get gameMinesweeperMedium => 'متوسط';

  @override
  String get gameMinesLeft => 'الألغام اليسار';

  @override
  String get gameTimeLeft => 'الوقت';

  @override
  String get gameLevel => 'المستوى';

  @override
  String get gameNext => 'التالي';

  @override
  String get gameBestTime => 'أفضل وقت';

  @override
  String get gameNewRecord => 'رقم قياسي جديد!';

  @override
  String get gameLines => 'خطوط';

  @override
  String get storyMyStory => 'قصتي';

  @override
  String get storageSmartCleanup => 'التنظيف الذكي';

  @override
  String get storageOldMediaFiles => 'ملفات الوسائط القديمة';

  @override
  String get storageLargeFiles => 'ملفات كبيرة';

  @override
  String get storageAppCache => 'ذاكرة التخزين المؤقت للتطبيق';

  @override
  String get storageSettings => 'إعدادات التخزين';

  @override
  String get storageAutoCleanup => 'التنظيف التلقائي';

  @override
  String storageAutoCleanupDesc(int days) {
    return 'يقوم تلقائيًا بتنظيف الملفات الأقدم من أيام $days';
  }

  @override
  String get storageCleanupPeriod => 'فترة التنظيف';

  @override
  String get storagePreserveThumbnails => 'الحفاظ على الصور المصغرة';

  @override
  String get storagePreserveThumbnailsDesc =>
      'احتفظ بالصور المصغرة للصور أثناء عملية التنظيف';

  @override
  String get storageWarningHigh =>
      'استخدام التخزين مرتفع. فكر في تنظيف الملفات القديمة.';

  @override
  String get storageWarningCritical =>
      'التخزين منخفض للغاية. يرجى تنظيف المساحة الحرة.';

  @override
  String storageFreed(String size, int count) {
    return 'تم تحرير $size (ملفات $count)';
  }

  @override
  String storageDays(int days) {
    return 'أيام $days';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'عرض جميع غرف $count';
  }

  @override
  String get storageNoFiles => 'لم يتم العثور على ملفات';

  @override
  String get storageFilePinned => 'مثبت';

  @override
  String storageDeleteSelected(int count) {
    return 'هل تريد حذف الملفات المحددة $count؟ يمكن إعادة تنزيلها من الخادم.';
  }

  @override
  String get backupRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupCreate => 'إنشاء نسخة احتياطية';

  @override
  String get backupCreateDesc =>
      'قم بعمل نسخة احتياطية من إعداداتك ومفاتيح التشفير. سيتم استعادة الرسائل من الخادم بعد إعادة تسجيل الدخول.';

  @override
  String get backupIncludeKeys => 'تضمين مفاتيح التشفير';

  @override
  String get backupIncludeKeysDesc => 'مطلوب لقراءة الرسائل المشفرة';

  @override
  String get backupPasswordProtect => 'حماية كلمة المرور';

  @override
  String get backupEnterPassword => 'أدخل كلمة المرور الاحتياطية';

  @override
  String get backupHistory => 'تاريخ النسخ الاحتياطي';

  @override
  String get backupNoBackups => 'لا توجد نسخ احتياطية حتى الآن';

  @override
  String get backupRestore2 => 'استعادة';

  @override
  String get backupDelete => 'حذف';

  @override
  String get backupDeleteConfirm =>
      'هل أنت متأكد أنك تريد حذف هذه النسخة الاحتياطية؟ لا يمكن التراجع عن هذا.';

  @override
  String get backupRestoreFromFile => 'استعادة من الملف';

  @override
  String get backupRestoreFromFileDesc =>
      'قم باستيراد ملف .n42backup من جهاز آخر أو نسخة احتياطية سابقة.';

  @override
  String get backupChooseFile => 'اختر ملف النسخ الاحتياطي';

  @override
  String get backupRestoring => 'جارٍ الاستعادة...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'تم إنشاء النسخة الاحتياطية: غرف $rooms، رسائل $messages';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return 'تمت استعادة إعدادات $settings من غرف $rooms';
  }

  @override
  String backupFailed(String error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String get backupPasswordRequired => 'هذه النسخة الاحتياطية محمية بكلمة مرور';

  @override
  String get blocGroupNotFound => 'لم يتم العثور على المجموعة';

  @override
  String blocGroupMembersInvited(int count) {
    return 'أعضاء $count المدعوين';
  }

  @override
  String get blocGroupMemberRemoved => 'تمت إزالة العضو';

  @override
  String get blocGroupAdminRemoved => 'تمت إزالة المشرف';

  @override
  String get blocGroupLeft => 'غادر المجموعة';

  @override
  String get blocGroupDisbanded => 'تم حل المجموعة';

  @override
  String get blocGroupJoined => 'انضم إلى المجموعة';

  @override
  String get blocGroupInviteDeclined => 'تم رفض الدعوة';

  @override
  String get blocGroupTokenGateUpdated => 'تم تحديث بوابة الرمز المميز';

  @override
  String get blocTransferProcessing => 'جارٍ معالجة النقل...';

  @override
  String get blocTransferCancelled => 'تم إلغاء النقل';

  @override
  String get blocTransferFailed => 'فشل النقل';

  @override
  String get blocPaymentProcessing => 'جارٍ معالجة الدفع...';

  @override
  String get blocPaymentFailed => 'فشل الدفع';

  @override
  String get groupMaxMembers => 'حد الأعضاء';

  @override
  String get groupMaxMembersUnlimited => 'غير محدود';

  @override
  String get groupMaxMembersHint => 'أدخل الحد (اتركه فارغًا لعدد غير محدود)';

  @override
  String get groupMaxMembersUpdated => 'تم تحديث حد الأعضاء';

  @override
  String get groupFull => 'المجموعة في القدرة';

  @override
  String get groupChannels => 'قنوات الموضوع';

  @override
  String get groupChannelsEmpty => 'لا توجد قنوات بعد';

  @override
  String get groupChannelsCount => 'القنوات';

  @override
  String get groupChannelCreate => 'قناة جديدة';

  @override
  String get groupChannelName => 'اسم القناة';

  @override
  String get groupChannelTopic => 'موضوع القناة (اختياري)';

  @override
  String get groupChannelDelete => 'حذف القناة';

  @override
  String get groupChannelDeleteConfirm =>
      'هل تريد حذف هذه القناة؟ سيتم فقدان كافة الرسائل.';

  @override
  String get groupBotSettings => 'إعدادات البوت';

  @override
  String get groupBotEnabled => 'تمكين بوت';

  @override
  String get groupBotWelcomeMessage => 'قالب رسالة الترحيب';

  @override
  String get groupBotWelcomeHint =>
      'استخدم \"الاسم\" كعنصر نائب لاسم العضو الجديد';

  @override
  String get groupBotConfigUpdated => 'تم تحديث إعدادات الروبوت';

  @override
  String get groupContentFilter => 'مرشح المحتوى';

  @override
  String get groupContentFilterEnabled => 'تمكين تصفية الكلمات الرئيسية';

  @override
  String get groupContentFilterReplace => 'استبدل بـ ***';

  @override
  String get groupContentFilterHide => 'إخفاء الرسالة';

  @override
  String get groupContentFilterAddWord => 'أضف كلمة رئيسية';

  @override
  String get groupContentFilterUpdated => 'تم تحديث فلتر المحتوى';

  @override
  String get chatSlashCommands => 'الأوامر';

  @override
  String get chatCommandPoll => '/ استطلاع - إنشاء استطلاع';

  @override
  String get chatCommandAnnounce => '/ إعلان - إرسال إعلان';

  @override
  String get chatCommandWelcome => '/ ترحيب - تعيين رسالة الترحيب';

  @override
  String get chatReportMessage => 'تقرير';

  @override
  String get chatReportReason => 'سبب التقرير';

  @override
  String get chatReportSpam => 'البريد العشوائي';

  @override
  String get chatReportHarassment => 'التحرش';

  @override
  String get chatReportInappropriate => 'محتوى غير لائق';

  @override
  String get chatReportOther => 'أخرى';

  @override
  String get chatReportSuccess => 'تم تقديم التقرير';

  @override
  String get spacesName => 'اسم المجتمع';

  @override
  String get spacesNameHint => 'على سبيل المثال تجار التشفير';

  @override
  String get spacesNameRequired => 'الاسم مطلوب';

  @override
  String get spacesDescription => 'الوصف';

  @override
  String get spacesDescriptionHint => 'ما هو هذا المجتمع عنه؟';

  @override
  String get spacesType => 'نوع المجتمع';

  @override
  String get spacesPublicDesc => 'يمكن لأي شخص اكتشاف والانضمام';

  @override
  String get spacesPrivateDesc => 'يمكن للأعضاء المدعوين فقط الانضمام';

  @override
  String get spacesNotFound => 'لم يتم العثور على المجتمع';

  @override
  String get spacesSearch => 'بحث في المجتمعات...';

  @override
  String get spacesMembers => 'الأعضاء';

  @override
  String get spacesNoChannels => 'لا توجد قنوات بعد';

  @override
  String get spacesLeave => 'مغادرة المجتمع';

  @override
  String spacesLeaveConfirm(String name) {
    return 'هل أنت متأكد أنك تريد مغادرة \"$name\"؟';
  }

  @override
  String get spacesDelete => 'حذف المجتمع';

  @override
  String spacesDeleteConfirm(String name) {
    return 'سيؤدي هذا إلى حذف \"$name\" وجميع قنواتها نهائيًا. لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get spacesCreateChannel => 'أضف قناة';

  @override
  String get spacesChannelName => 'اسم القناة';

  @override
  String get spacesChannelTopic => 'الموضوع (اختياري)';

  @override
  String get spacesDeleteChannel => 'حذف القناة';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'هل أنت متأكد أنك تريد حذف \"#$name\"؟';
  }

  @override
  String get spacesEditName => 'تحرير الاسم';

  @override
  String get spacesEditDescription => 'تحرير الوصف';

  @override
  String spacesViewAllMembers(int count) {
    return 'عرض جميع أعضاء $count';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return 'ركلة $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'حظر $name';
  }

  @override
  String get spacesPromoteAdmin => 'ترقية إلى المشرف';

  @override
  String get spacesDemoteAdmin => 'إزالة المشرف';

  @override
  String get spacesInviteMember => 'دعوة العضو';

  @override
  String get spacesInviteMemberUserId => 'معرف المستخدم (مثل @user:server.com)';

  @override
  String get spacesSave => 'حفظ';

  @override
  String get settingsScreenshotProtection => 'حماية لقطة الشاشة';

  @override
  String get settingsScreenshotProtectionDesc =>
      'منع لقطات الشاشة وتسجيل الشاشة';

  @override
  String get chatSelfDestructTimer => 'التدمير الذاتي';

  @override
  String get chatTimerPickerTitle => 'مؤقت التدمير الذاتي';

  @override
  String get chatTimerOff => 'إيقاف';

  @override
  String get onChainNotificationsTitle => 'الأحداث على السلسلة';

  @override
  String get onChainMarkAllRead => 'وضع علامة على كل قراءة';

  @override
  String get onChainNoNotifications => 'لا توجد أحداث على السلسلة حتى الآن';

  @override
  String get onChainNoNotificationsDesc =>
      'ستظهر هنا الأحداث من القنوات المشتركة';

  @override
  String get onChainViewDetails => 'عرض التفاصيل';

  @override
  String get chatCommandHelp => '/ مساعدة — إظهار كافة الأوامر';

  @override
  String get chatCommandPrice => '/السعر - احصل على سعر الرمز المميز';

  @override
  String get chatCommandBalance => '/التوازن - إظهار رصيد المحفظة';

  @override
  String get chatCommandChains => '/chains - قائمة بأكثر من 236 سلسلة مدعومة';

  @override
  String get chatMiniApps => 'تطبيقات';

  @override
  String get miniAppMarketTitle => 'تطبيقات مصغرة';

  @override
  String get miniAppCategoryAll => 'الكل';

  @override
  String get miniAppSearch => 'تطبيقات البحث...';

  @override
  String get miniAppFeatured => 'مميز';

  @override
  String get miniAppAllApps => 'جميع التطبيقات';

  @override
  String get miniAppNoResults => 'لم يتم العثور على أي تطبيقات';

  @override
  String get slideToPayLabel => '→ → → قم بالتمرير للتأكيد';

  @override
  String get slideToPayConfirming => 'جارٍ التأكيد...';

  @override
  String get redPacketBestLuck => 'حظا سعيدا';

  @override
  String get redPacketBestLuckCongrats => 'حظا سعيدا! لقد حصلت على أكثر!';

  @override
  String redPacketStats(int claimed, int total) {
    return 'ادعى $claimed / $total';
  }

  @override
  String get redPacketStatsTotal => 'المجموع';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 أمسكت بعلبة حمراء • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id • عنوان المحفظة 0x • name.eth';

  @override
  String get web3SearchPlaceholder => 'البحث حسب الهوية أو المحفظة أو ENS...';

  @override
  String get web3WalletAddress => 'عنوان المحفظة';

  @override
  String get web3AddressCopied => 'تم نسخ العنوان';

  @override
  String get web3Copy => 'نسخ';

  @override
  String get web3SendMessage => 'أرسل رسالة';

  @override
  String get web3SendToWallet => 'محفظة الرسائل';

  @override
  String get web3WalletOnlyHint =>
      'هذا العنوان ليس لديه حساب N42 حتى الآن. سيتم تسليم الرسالة عند انضمامهم.';

  @override
  String get web3NftAvatar => 'الصورة الرمزية NFT';

  @override
  String get web3ResolveFailed => 'فشل في حل الهوية';

  @override
  String web3EnsNotFound(String name) {
    return 'لم يتم العثور على اسم ENS \"$name\".';
  }

  @override
  String get web3NoN42AccountTitle => 'لا يوجد حساب N42';

  @override
  String get web3NoN42AccountDesc =>
      'عنوان المحفظة هذا لا يحتوي على حساب N42 حتى الآن. يمكنك مشاركة رابط دعوة N42 معهم للبدء.';

  @override
  String get web3ShareInvite => 'مشاركة الدعوة';

  @override
  String get nftPickerTitle => 'حدد الصورة الرمزية NFT';

  @override
  String get nftPickerTabPopular => 'شعبية';

  @override
  String get nftPickerTabCustom => 'مخصص';

  @override
  String get nftPickerChain => 'سلسلة';

  @override
  String get nftPickerContract => 'عنوان العقد';

  @override
  String get nftPickerTokenId => 'معرف الرمز المميز';

  @override
  String get nftPickerVerifyOwnership => 'التحقق من الملكية والمعاينة';

  @override
  String get nftPickerUseAsAvatar => 'استخدم كصورة رمزية';

  @override
  String get nftPickerPreview => 'معاينة';

  @override
  String get nftPickerNotOwned => 'أنت لا تملك هذا NFT';

  @override
  String get nftPickerInvalidTokenId => 'معرف الرمز المميز غير صالح';

  @override
  String get nftPickerEnterBoth => 'أدخل عنوان العقد ومعرف الرمز المميز';

  @override
  String get nftPickerInfoTitle =>
      'الصورة الرمزية NFT - تم التحقق منها على السلسلة';

  @override
  String get nftPickerInfoDesc =>
      'قم بربط NFT الذي تمتلكه باعتباره الصورة الرمزية الخاصة بك. يمكن لأي شخص التحقق من الملكية على السلسلة. معروض بحلقة ذهبية عبر N42.';

  @override
  String get nftPickerPopularCollections => 'مجموعات شعبية';

  @override
  String get nftPickerWalletHint =>
      'قم بتوصيل محفظة N42 الخاصة بك لاكتشاف NFTs الخاصة بك تلقائيًا عبر أكثر من 236 سلسلة.';

  @override
  String get profileBindNftAvatar => 'ربط الصورة الرمزية NFT';

  @override
  String get profileChangeAvatar => 'تغيير الصورة الرمزية';

  @override
  String get groupTopics => 'المواضيع';

  @override
  String get groupTopicsEmpty => 'لا توجد مواضيع حتى الآن';

  @override
  String get syncInProgress => 'جارٍ مزامنة سجل الرسائل...';

  @override
  String get recoveryKeyReminderTitle => 'حماية رسائلك';

  @override
  String get recoveryKeyReminderDesc =>
      'قم بإنشاء مفتاح استرداد لمزامنة الرسائل المشفرة بشكل آمن عبر الأجهزة';

  @override
  String get recoveryKeySetupNow => 'قم بالإعداد الآن';

  @override
  String get recoveryKeyRemindLater => 'ذكرني لاحقا';

  @override
  String get channelReadOnly => 'يمكن للمسؤولين فقط النشر في هذه القناة';

  @override
  String get channelSubscribers => 'المشتركين';

  @override
  String get channelVerified => 'قناة تم التحقق منها';

  @override
  String get redPacketHistory => 'تاريخ الحزمة الحمراء';

  @override
  String get redPacketSent => 'تم الإرسال';

  @override
  String get redPacketReceived => 'تم الاستلام';

  @override
  String get redPacketExpired => 'انتهت صلاحيتها';

  @override
  String get redPacketClaimed => 'ادعى';

  @override
  String get redPacketInsufficientBalance => 'رصيد غير كاف';

  @override
  String selfDestructCountdown(String time) {
    return 'التدمير الذاتي في $time';
  }

  @override
  String get messageDestroyed => 'تم تدمير الرسالة';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'تم رفض الإذن: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'ما هي رسوم الغاز؟';

  @override
  String get aiSuggestionDefi => 'دليل DeFi للمبتدئين';

  @override
  String get aiSuggestionSecurity => 'كيفية التحقق من سلامة العقد';

  @override
  String get aiSuggestionBridge => 'الجسور عبر السلسلة';

  @override
  String get channelDiscoverTitle => 'اكتشف القنوات';

  @override
  String get channelDiscoverSearch => 'بحث في القنوات...';

  @override
  String get channelJoin => 'انضم';

  @override
  String get channelJoined => 'انضم';

  @override
  String get channelCategory => 'الفئة';

  @override
  String slowModeCooldown(int seconds) {
    return 'الوضع البطيء: انتظر ${seconds}s';
  }

  @override
  String get addressCopyAction => 'نسخ العنوان';

  @override
  String get addressSendMessage => 'أرسل رسالة';

  @override
  String get addressViewProfile => 'عرض الملف الشخصي';

  @override
  String get sendToAddress => 'إرسال إلى عنوان المحفظة';

  @override
  String get blocAuthSendVerificationCodeFailed => 'فشل في إرسال رمز التحقق';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'هذا الخادم لا يدعم إعادة تعيين كلمة مرور البريد الإلكتروني';

  @override
  String get blocAuthResetPasswordFailed => 'فشل في إعادة تعيين كلمة المرور';

  @override
  String get blocAuthChangePasswordFailed => 'فشل في تغيير كلمة المرور';

  @override
  String get blocAuthOldPasswordWrong => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get blocAuthLoginCancelled => 'تم إلغاء تسجيل الدخول';

  @override
  String get blocAuthGoogleLoginFailed => 'فشل تسجيل الدخول إلى جوجل';

  @override
  String get blocAuthAppleLoginFailed => 'فشل تسجيل دخول أبل';

  @override
  String get blocAuthSsoLoginFailed => 'فشل تسجيل الدخول الموحّد (SSO).';

  @override
  String get blocAuthFacebookLoginFailed => 'فشل تسجيل الدخول الفيسبوك';

  @override
  String get blocAuthTwitterLoginFailed => 'فشل تسجيل الدخول إلى تويتر';

  @override
  String get blocAuthWeChatLoginFailed => 'فشل تسجيل الدخول إلى WeChat';

  @override
  String get blocAuthWeChatNotConfigured =>
      'لم يتم تكوين تسجيل الدخول إلى WeChat';

  @override
  String get blocAuthWeChatNotInstalled => 'الرجاء تثبيت WeChat أولاً';

  @override
  String get blocAuthPasswordWrong => 'كلمة مرور غير صحيحة';

  @override
  String get blocAuthEmailAlreadyBound =>
      'هذا البريد الإلكتروني مرتبط بالفعل بحساب آخر';

  @override
  String get blocAuthChangeEmailFailed => 'فشل في تغيير البريد الإلكتروني';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'رمز التحقق غير صحيح أو منتهي الصلاحية';

  @override
  String get blocAuthSessionExpired =>
      'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';

  @override
  String get blocAuthSessionIncomplete =>
      'بيانات الجلسة غير كاملة، يرجى تسجيل الدخول مرة أخرى';
}

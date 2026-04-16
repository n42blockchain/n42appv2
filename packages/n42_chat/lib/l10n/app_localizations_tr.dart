// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class STr extends S {
  STr([String locale = 'tr']) : super(locale);

  @override
  String get commonRetry => 'Tekrar Dene';

  @override
  String get commonUnknownUser => 'Bilinmeyen Kullanıcı';

  @override
  String get transferWalletNotConnected => 'Cüzdan bağlı değil';

  @override
  String get chatCallServiceNotInitialized => 'Arama servisi başlatılmadı';

  @override
  String authLoginFailed(String error) {
    return 'Giriş başarısız: $error';
  }

  @override
  String get chatCallBack => 'Geri ara';

  @override
  String get chatMissedVideoCall => 'Cevapsız görüntülü arama';

  @override
  String get chatMissedVoiceCall => 'Cevapsız sesli arama';

  @override
  String get chatCallNotAnswered => 'Cevaplanmadı';

  @override
  String get chatCallDurationLabel => 'Arama süresi';

  @override
  String get chatVoiceCallCancelled => 'Sesli arama iptal edildi';

  @override
  String get chatVideoCallCancelled => 'Görüntülü arama iptal edildi';

  @override
  String get commonImage => '[Resim]';

  @override
  String get chatVideo => '[Video]';

  @override
  String get chatVoice => '[Ses]';

  @override
  String get commonFile => '[Dosya]';

  @override
  String get chatLocation => '[Konum]';

  @override
  String get chatUnknownMessage => '[Bilinmeyen mesaj]';

  @override
  String get commonDelete => 'Sil';

  @override
  String get chatDeleteThisMessage => 'Bu mesajı silmek istiyor musunuz?';

  @override
  String get chatMessageDeleted => 'Mesaj silindi';

  @override
  String get profileNotLoggedIn => 'Giriş yapılmadı';

  @override
  String get chatMyLocation => 'Konumum';

  @override
  String get commonGroupChat => 'Grup Sohbeti';

  @override
  String get commonSearch => 'Ara';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonLoadFailed => 'Yükleme başarısız';

  @override
  String get commonMessages => 'Mesajlar';

  @override
  String get commonContacts => 'Kişiler';

  @override
  String get commonMe => 'Ben';

  @override
  String get commonVoiceLoading =>
      'Ses yükleniyor, lütfen daha sonra tekrar deneyin';

  @override
  String get commonVoiceToTextFailed => 'Sesten metne dönüştürme başarısız';

  @override
  String get commonConvertToText => 'Metne çevir';

  @override
  String get chatCopy => 'Kopyala';

  @override
  String get commonForward => 'İlet';

  @override
  String get commonUnfavorite => 'Favorilerden çıkar';

  @override
  String get commonFavorite => 'Favorilere ekle';

  @override
  String get settingsResend => 'Tekrar gönder';

  @override
  String get chatRecall => 'Geri al';

  @override
  String get commonQuote => 'Alıntıla';

  @override
  String get commonRemind => 'Hatırlat';

  @override
  String get chatCopied => 'Kopyalandı';

  @override
  String get storySendMessageHint => 'Mesaj gönder';

  @override
  String get commonMicrophonePermissionRequired =>
      'Lütfen mikrofon iznini verin';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'Mikrofon izni reddedildi. Sesli mesajları kullanmak için lütfen sistem ayarlarında etkinleştirin.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'Kayıt başlatılamadı: $error';
  }

  @override
  String get commonRecordingTooShort => 'Kayıt çok kısa';

  @override
  String commonStopRecordingFailed(String error) {
    return 'Kayıt durdurulamadı: $error';
  }

  @override
  String get chatReleaseToCancel => 'İptal etmek için bırakın';

  @override
  String get chatReleaseToSend =>
      'Göndermek için bırakın, iptal için yukarı kaydırın';

  @override
  String get commonHoldToTalk => 'Konuşmak için basılı tutun';

  @override
  String get commonSend => 'Gönder';

  @override
  String get commonAddFriend => 'Arkadaş Ekle';

  @override
  String get commonChatServiceNotConnected => 'Sohbet servisi bağlı değil';

  @override
  String contactUserNotFoundHint(String query) {
    return '\"$query\" kullanıcısı bulunamadı\n\nİpuçları:\n• Tam kullanıcı ID\'sini girin, örn. @kullaniciadi:sunucu.com\n• Kullanıcı adı yazımını kontrol edin';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'Sohbet oluşturulamadı: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'Arama başarısız: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'Aramak için kullanıcı ID\'si veya adı girin';

  @override
  String get contactSearching => 'Aranıyor...';

  @override
  String get contactSearchUserToChat =>
      'Sohbet başlatmak için kullanıcı arayın';

  @override
  String get contactMatrixIdExample =>
      'Tam Matrix ID\'si girebilirsiniz\nörn. @kullanici:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return '\"$username\" kullanıcısı bulunamadı';
  }

  @override
  String get commonChat => 'Sohbet';

  @override
  String get commonSettings => 'Ayarlar';

  @override
  String get profileEditProfile => 'Profili Düzenle';

  @override
  String get authLogin => 'Giriş Yap';

  @override
  String get commonCreateGroup => 'Grup Oluştur';

  @override
  String get chatError => 'Hata';

  @override
  String get commonTransfer => 'Aktarım';

  @override
  String get commonReceived => 'Alındı';

  @override
  String get commonRefunded => 'İade edildi';

  @override
  String get commonExpired => 'Süresi doldu';

  @override
  String get chatRedPacketGreeting => 'İyi dilekler';

  @override
  String get commonN42RedPacket => 'N42 Kırmızı Paket';

  @override
  String get commonClaimed => 'Alındı';

  @override
  String get commonAllClaimed => 'Tamamı alındı';

  @override
  String get chatReadAloud => 'Yüksek Sesle Oku';

  @override
  String get chatReply => 'Yanıtla';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get chatSelectForwardTarget => 'Alıcı seçin';

  @override
  String commonSendCount(int count) {
    return 'Gönder ($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'N42 Kimliği: $id';
  }

  @override
  String get profileN42IdTitle => 'N42 kimliği';

  @override
  String get profileN42Bean => 'N42 Fasulye';

  @override
  String get contactFriendInfo => 'Arkadaş Bilgisi';

  @override
  String get contactFriendInfoDesc =>
      'Arkadaşınıza not, telefon, etiket ekleyin ve izinleri ayarlayın.';

  @override
  String get commonMoments => 'Anlar';

  @override
  String get commonSendMessage => 'Mesaj';

  @override
  String get contactAudioVideoCall => 'Sesli/Görüntülü Arama';

  @override
  String get contactVideoChannel => 'Video Kanalı';

  @override
  String get contactRemark => 'Not';

  @override
  String get contactRemarkName => 'Takma Ad';

  @override
  String get contactPhone => 'Telefon';

  @override
  String get contactTags => 'Etiketler';

  @override
  String get contactNotes => 'Notlar';

  @override
  String get contactPhotos => 'Fotoğraflar';

  @override
  String get contactPermissions => 'İzinler';

  @override
  String get contactChatMomentsEtc => 'Sohbet, Anlar, Spor, vb.';

  @override
  String get contactMoreInfo => 'Daha Fazla Bilgi';

  @override
  String get contactCommonGroups => 'Ortak Gruplar';

  @override
  String get contactSource => 'Kaynak';

  @override
  String get settingsNotificationSettings => 'Bildirimler';

  @override
  String get settingsPrivacy => 'Gizlilik';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get commonLogout => 'Çıkış Yap';

  @override
  String get commonLogoutConfirm => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get profileNickname => 'Takma Ad';

  @override
  String get profileEnterNickname => 'Takma ad girin';

  @override
  String get profileSignature => 'İmza';

  @override
  String get profileAddSignature => 'İmza ekle';

  @override
  String get commonTakePhoto => 'Fotoğraf Çek';

  @override
  String get profileChooseFromGallery => 'Galeriden Seç';

  @override
  String profileSaveFailed(String error) {
    return 'Kaydetme başarısız: $error';
  }

  @override
  String get authSecureDecentralizedChat =>
      'Güvenli, merkezi olmayan mesajlaşma';

  @override
  String get commonEndToEndEncryption => 'Uçtan uca şifreleme';

  @override
  String get authMessagesOnlyYouCanSee =>
      'Mesajlar sadece siz ve alıcı tarafından görülebilir';

  @override
  String get authDecentralized => 'Merkezi Olmayan';

  @override
  String get authBasedOnMatrix => 'Matrix açık protokolü üzerine kurulu';

  @override
  String get authWalletIntegration => 'Cüzdan Entegrasyonu';

  @override
  String get authEasyCryptoTransfer => 'Kolay kripto para transferi';

  @override
  String get authRegister => 'Kayıt Ol';

  @override
  String get authAgreeTerms => 'Giriş yaparak kabul etmiş olursunuz';

  @override
  String get authTermsOfService => 'Hizmet Şartları';

  @override
  String get authAnd => 've';

  @override
  String get authPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get authServerAddress => 'Sunucu Adresi';

  @override
  String get authEnterServerAddress => 'Sunucu adresi girin';

  @override
  String authConnectedTo(String serverName) {
    return '$serverName sunucusuna bağlandı';
  }

  @override
  String get authUsername => 'Kullanıcı Adı';

  @override
  String get authEnterUsername => 'Kullanıcı adı girin';

  @override
  String get authUsernameOrEmail => 'Kullanıcı Adı veya E-posta';

  @override
  String get authEnterUsernameOrEmail => 'Kullanıcı adı veya e-posta girin';

  @override
  String get authPassword => 'Şifre';

  @override
  String get authEnterPassword => 'Şifre girin';

  @override
  String get authRegisterAccount => 'Kayıt Ol';

  @override
  String get authForgotPassword => 'Şifremi Unuttum';

  @override
  String get authOtherLoginMethods => 'Diğer giriş yöntemleri';

  @override
  String get authCreateAccount => 'Hesap Oluştur';

  @override
  String get authJoinN42Chat => 'Sohbete başlamak için N42 Chat\'e katılın';

  @override
  String get authUsernameHint => '3-20 karakter, harf/rakam/_';

  @override
  String get authUsernameMinLength =>
      'Kullanıcı adı en az 3 karakter olmalıdır';

  @override
  String get authUsernameMaxLength =>
      'Kullanıcı adı en fazla 20 karakter olmalıdır';

  @override
  String get authUsernameFormat =>
      'Kullanıcı adı sadece harf, rakam ve alt çizgi içerebilir';

  @override
  String get authPasswordHint => 'En az 8 karakter';

  @override
  String get commonPasswordMinLength => 'Şifre en az 8 karakter olmalıdır';

  @override
  String get authConfirmPassword => 'Şifreyi Onayla';

  @override
  String get authFilled => 'Dolduruldu';

  @override
  String get authEnterInviteCode => 'Davet kodu girin';

  @override
  String get authAlreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get authLoginNow => 'Hemen giriş yapın';

  @override
  String get profileAvatar => 'avatar';

  @override
  String get profileStatus => 'Durum';

  @override
  String get commonLoading => 'Yükleniyor...';

  @override
  String get conversationNoConversations => 'Sohbet yok';

  @override
  String get conversationTapToChat => 'Sohbet başlatmak için sağ üste dokunun';

  @override
  String get conversationStartGroup => 'Grup Sohbeti Başlat';

  @override
  String get commonScan => 'Tara';

  @override
  String get commonPayment => 'Ödeme';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature yakında';
  }

  @override
  String get conversationMarkAsRead => 'Okundu olarak işaretle';

  @override
  String get commonUnmute => 'Sesi aç';

  @override
  String get commonMute => 'Sessize al';

  @override
  String get conversationUnpin => 'Sabitlemeyi kaldır';

  @override
  String get conversationPin => 'Sabitle';

  @override
  String get conversationDeleteConversation => 'Sohbeti Sil';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return '\"$name\" ile sohbeti silmek istiyor musunuz?';
  }

  @override
  String get commonNoContacts => 'Kişi yok';

  @override
  String get contactAddFriendsToChat => 'Sohbete başlamak için arkadaş ekleyin';

  @override
  String get contactNotFound => 'Kişi bulunamadı';

  @override
  String get contactTryOtherKeywords =>
      'Başka anahtar kelimeler veya genel arama deneyin';

  @override
  String get contactSearchResults => 'Arama sonuçları';

  @override
  String get contactNewFriends => 'Yeni Arkadaşlar';

  @override
  String get contactChatOnlyFriends => 'Yalnızca Sohbete Özel Arkadaşlar';

  @override
  String get contactOfficialAccounts => 'Resmi Hesaplar';

  @override
  String get contactServiceAccounts => 'Hizmet Hesapları';

  @override
  String get contactEnterpriseContacts => 'Kurumsal Kişiler';

  @override
  String get contactRecommendToFriend => 'Kişiyi paylaş';

  @override
  String get commonSetRemark => 'Not ekle';

  @override
  String get contactSendingCard => 'Kişi kartı gönderiliyor...';

  @override
  String get commonFileLabel => 'Dosya';

  @override
  String get commonLocationLabel => 'Konum';

  @override
  String contactRecommendFailed(String error) {
    return 'Öneri başarısız: $error';
  }

  @override
  String get profileEnterRemark => 'Not girin';

  @override
  String get contactOpeningChat => 'Sohbet açılıyor...';

  @override
  String contactOpenChatFailed(String error) {
    return 'Sohbet açılamadı: $error';
  }

  @override
  String get contactAddContact => 'Kişi Ekle';

  @override
  String get contactEnterUserId => 'Kullanıcı ID\'si girin';

  @override
  String get contactNoFriendRequests => 'Arkadaşlık isteği yok';

  @override
  String get commonAccept => 'Kabul Et';

  @override
  String get commonReject => 'Reddet';

  @override
  String get commonNoGroups => 'Grup yok';

  @override
  String get contactSelectFriendToRecommend => 'Önermek için arkadaş seçin';

  @override
  String get commonSearchContacts => 'Kişilerde ara';

  @override
  String get contactNoContactsFound => 'Kişi bulunamadı';

  @override
  String get favoriteYesterday => 'Dün';

  @override
  String get chatJustNow => 'Az önce';

  @override
  String get profileOnline => 'Çevrimiçi';

  @override
  String get profileOffline => 'Çevrimdışı';

  @override
  String get searchContactsGroupsMessages => 'Kişi, grup ve mesajlarda ara';

  @override
  String get searchError => 'Arama hatası';

  @override
  String get chatSearchHint => 'Kişi, grup ve mesajlarda ara';

  @override
  String get searchHistory => 'Arama Geçmişi';

  @override
  String get commonClear => 'Temizle';

  @override
  String get commonAll => 'Tümü';

  @override
  String get searchGroups => 'Gruplar';

  @override
  String get searchNoResults => 'Sonuç yok';

  @override
  String commonGroupMembers(int count) {
    return 'Üyeler ($count)';
  }

  @override
  String get groupMembersTitle => 'Grup Üyeleri';

  @override
  String get groupViewAll => 'Tümünü gör';

  @override
  String get groupOwner => 'Sahip';

  @override
  String get groupAdmin => 'Yönetici';

  @override
  String get groupInvite => 'Davet Et';

  @override
  String get commonGroupAnnouncement => 'Grup Duyurusu';

  @override
  String get commonNotSet => 'Ayarlanmadı';

  @override
  String get groupDescription => 'Grup Açıklaması';

  @override
  String get groupPublicGroup => 'Herkese Açık Grup';

  @override
  String get commonClearChatHistory => 'Sohbet Geçmişini Temizle';

  @override
  String get commonDissolveGroup => 'Grubu Dağıt';

  @override
  String get commonLeaveGroup => 'Gruptan Ayrıl';

  @override
  String get groupChangeGroupName => 'Grup Adını Değiştir';

  @override
  String get commonEnterGroupName => 'Grup adı girin';

  @override
  String get commonConfirm => 'Onayla';

  @override
  String get groupEnterGroupDescription => 'Grup açıklaması girin';

  @override
  String get groupPublish => 'Yayınla';

  @override
  String get chatClearHistoryConfirm =>
      'Tüm sohbet geçmişini temizle? Bu işlem geri alınamaz.';

  @override
  String get chatClearAction => 'Temizle';

  @override
  String get commonChatHistoryCleared => 'Sohbet geçmişi temizlendi';

  @override
  String get commonDissolve => 'Dağıt';

  @override
  String get groupQrCode => 'Grup QR Kodu';

  @override
  String get commonSearchChatHistory => 'Sohbet Geçmişinde Ara';

  @override
  String get groupIdCopied => 'Grup ID\'si kopyalandı';

  @override
  String get transferEnterOrPasteAddress =>
      'Cüzdan adresini girin veya yapıştırın';

  @override
  String get transferSelectToken => 'Token Seç';

  @override
  String get commonTransferAmount => 'Transfer Tutarı';

  @override
  String get transferAvailable => 'Kullanılabilir';

  @override
  String get transferMemoOptional => 'Not (isteğe bağlı)';

  @override
  String get transferConfirmTransfer => 'Transferi Onayla';

  @override
  String get transferAddressVerified => 'Adres doğrulandı';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'Kullanılabilir: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'Tutar girin';

  @override
  String get commonRedPacketCountMin => 'En az 1 kırmızı paket gerekli';

  @override
  String get commonViewRedPacketDetails => 'Kırmızı paket detaylarını gör';

  @override
  String get commonEnterTransferAmount => 'Transfer tutarını girin';

  @override
  String get commonTransferTo => 'Transfer hedefi';

  @override
  String commonFromSender(String name, Object senderName) {
    return '$senderName tarafından';
  }

  @override
  String get commonConfirmReceive => 'Alımı Onayla';

  @override
  String get groupProfile => 'Grup Bilgisi';

  @override
  String get groupRemoveMember => 'Gruptan Çıkar';

  @override
  String get commonRemove => 'Çıkar';

  @override
  String get profileClearStatus => 'Durumu Temizle';

  @override
  String get profileClearStatusConfirm => 'Mevcut durumu temizle?';

  @override
  String get profileStatusCleared => 'Durum temizlendi';

  @override
  String get profileUserNotExist => 'Kullanıcı mevcut değil';

  @override
  String get profileUserIdCopied => 'Kullanıcı ID\'si kopyalandı';

  @override
  String get commonReport => 'Şikayet Et';

  @override
  String get profileQrCode => 'QR Kod';

  @override
  String get profileAvatarUpdated => 'Avatar güncellendi';

  @override
  String commonSelectImageFailed(String error) {
    return 'Resim seçilemedi: $error';
  }

  @override
  String get profileChangeName => 'Adı Değiştir';

  @override
  String get profileMale => 'Erkek';

  @override
  String get profileFemale => 'Kadın';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature geliştirme aşamasında...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'Adres kaydedilemedi: $error';
  }

  @override
  String get profileAddNew => 'Ekle';

  @override
  String get profileAddAddress => 'Adres Ekle';

  @override
  String get profileAddressAdded => 'Adres eklendi';

  @override
  String get profileAddressUpdated => 'Adres güncellendi';

  @override
  String get profileDeleteAddress => 'Adresi Sil';

  @override
  String get profileAddressDeleted => 'Adres silindi';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'Fatura kaydedilemedi: $error';
  }

  @override
  String get profileMyInvoices => 'Faturalarım';

  @override
  String get profileAddInvoice => 'Fatura Ekle';

  @override
  String get profileInvoiceAdded => 'Fatura eklendi';

  @override
  String get profileInvoiceUpdated => 'Fatura güncellendi';

  @override
  String get profileDeleteInvoice => 'Faturayı Sil';

  @override
  String get profileInvoiceDeleted => 'Fatura silindi';

  @override
  String get profilePersonal => 'Bireysel';

  @override
  String get groupSelectAtLeastOne => 'Lütfen en az bir üye seçin';

  @override
  String get chatFileNotExist => 'Dosya mevcut değil';

  @override
  String chatSendFailed(String error) {
    return 'Gönderme başarısız: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'Tarayıcı açılamadı';

  @override
  String chatSelectFileFailed(String error) {
    return 'Dosya seçilemedi: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'Kurulum başarısız: $error';
  }

  @override
  String get transferEnterValidAmount => 'Lütfen geçerli bir tutar girin';

  @override
  String get commonAddressCopied => 'Adres kopyalandı';

  @override
  String favoriteOpenItem(String content) {
    return 'Aç: $content';
  }

  @override
  String get favoriteDeleted => 'Silindi';

  @override
  String get profileWallet => 'Cüzdan';

  @override
  String get chatRecording => 'Kayıt';

  @override
  String get chatInvalidVideoUrl => 'Geçersiz video URL\'si';

  @override
  String get chatDownloadFile => 'Dosyayı indir';

  @override
  String get chatClearChatHistoryTitle => 'Sohbet Geçmişini Temizle';

  @override
  String get chatVideoCall => 'Görüntülü Arama';

  @override
  String get commonVoiceCall => 'Sesli Arama';

  @override
  String get callLeaveMeeting => 'Toplantıdan Ayrıl';

  @override
  String get chatDetails => 'Sohbet Detayları';

  @override
  String get chatViewAllGroupMembers => 'Tüm üyeleri gör';

  @override
  String get chatGroupName => 'Grup Adı';

  @override
  String get chatGroupNameUpdated => 'Grup adı güncellendi';

  @override
  String get chatUpdateFailed => 'Güncelleme başarısız';

  @override
  String get chatNoPermissionToModify => 'Değiştirme izniniz yok';

  @override
  String get chatGroupManagement => 'Grup Yönetimi';

  @override
  String get chatMyNicknameInGroup => 'Gruptaki Takma Adım';

  @override
  String get chatPinChat => 'Sohbeti Sabitle';

  @override
  String get chatStrongReminder => 'Güçlü Hatırlatıcı';

  @override
  String get chatSetChatBackground => 'Sohbet Arka Planını Ayarla';

  @override
  String get chatUnknownFile => 'Bilinmeyen dosya';

  @override
  String get chatDownload => 'İndir';

  @override
  String get chatInvalidLocation => 'Geçersiz konum';

  @override
  String get chatTapToCancel => 'İptal etmek için dokunun';

  @override
  String chatCaptureFailed(Object error) {
    return 'Yakalama başarısız: $error';
  }

  @override
  String get chatProcessingVideo => 'Video işleniyor...';

  @override
  String get chatVideoFileNotExist => 'Video dosyası mevcut değil';

  @override
  String get chatVideoDataEmpty => 'Video verisi boş';

  @override
  String get chatVideoTooLarge => 'Video boyutu 100MB\'ı geçemez';

  @override
  String get chatSendingVideo => 'Video gönderiliyor...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'Video gönderilemedi: $error';
  }

  @override
  String get chatImageFileNotExist => 'Resim dosyası mevcut değil';

  @override
  String get commonImageDataEmpty => 'Resim verisi boş';

  @override
  String get chatSendingImage => 'Resim gönderiliyor...';

  @override
  String chatSendImageFailed(Object error) {
    return 'Resim gönderilemedi: $error';
  }

  @override
  String get chatSendLocation => 'Konum Gönder';

  @override
  String get chatSelectLocationAndSend => 'Konum seçin ve gönderin';

  @override
  String get chatShareRealTimeLocation => 'Gerçek Zamanlı Konum Paylaş';

  @override
  String get chatShareLocationForOneHour =>
      'Arkadaşınızla 1 saat gerçek zamanlı konum paylaşın';

  @override
  String get chatLocationSent => 'Konum gönderildi';

  @override
  String get chatSelectMessages => 'Mesaj seç';

  @override
  String chatSelectedCount(int count) {
    return '$count seçildi';
  }

  @override
  String get chatSelectAll => 'Tümünü Seç';

  @override
  String chatGroupChatCount(int count) {
    return 'Grup Sohbeti ($count)';
  }

  @override
  String get chatPrivateChat => 'Özel Sohbet';

  @override
  String get chatNoMessages => 'Mesaj yok';

  @override
  String get chatSendFirstMessage =>
      'Sohbeti başlatmak için ilk mesajı gönderin';

  @override
  String get chatEncryptionNotice =>
      'Bu sohbet uçtan uca şifrelenmiştir. Mesajları sadece siz ve alıcı okuyabilir.';

  @override
  String get chatMultiForward => 'İlet';

  @override
  String get chatCollect => 'Kaydet';

  @override
  String get chatNoMembers => 'Üye yok';

  @override
  String get chatMemberNotFound => 'Üye bulunamadı';

  @override
  String get chatVoiceFileNotExist => 'Ses dosyası mevcut değil';

  @override
  String get chatVoiceFileEmpty => 'Ses dosyası boş';

  @override
  String get chatSendingVoice => 'Ses gönderiliyor...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'Ses gönderilemedi: $error';
  }

  @override
  String get chatMessageForwarded => 'Mesaj iletildi';

  @override
  String chatForwardFailed(Object error) {
    return 'İletme başarısız: $error';
  }

  @override
  String get chatUnfavorited => 'Favorilerden çıkarıldı';

  @override
  String get chatFavorited => 'Favorilere eklendi';

  @override
  String get chatReactionAdded => 'Tepki eklendi';

  @override
  String get chatReactionRemoved => 'Tepki kaldırıldı';

  @override
  String get chatFailedMessageDeleted => 'Başarısız mesaj silindi';

  @override
  String get chatDeleteMessages => 'Mesajları sil';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return '$count mesajı silmek istediğinizden emin misiniz?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'Not: $count mesaj başkalarına ait ve sadece sizin için silinecek.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return 'Sizden $count mesaj herkes için geri alınacak.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return '$count mesaj geri alındı, $localCount sadece sizin için silindi';
  }

  @override
  String chatRecalledMessages(Object count) {
    return '$count mesaj geri alındı';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count mesaj sadece sizin için silindi';
  }

  @override
  String chatForwardedCount(Object count) {
    return '$count mesaj iletildi';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'İletme tamamlandı: $success başarılı, $failed başarısız';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'Hatırlatma özelliği sadece grup sohbetlerinde kullanılabilir';

  @override
  String get chatOnlyTextSearchable => 'Sadece metin mesajları aranabilir';

  @override
  String chatSearchFor(Object text) {
    return '\"$text\" ara';
  }

  @override
  String get chatBaiduSearch => 'Baidu Arama';

  @override
  String get chatGoogleSearch => 'Google Arama';

  @override
  String get chatBingSearch => 'Bing Arama';

  @override
  String get chatCalling => 'Aranıyor...';

  @override
  String get chatRinging => 'Çalıyor...';

  @override
  String get chatInCall => 'Aramada';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'Özellik geliştirme aşamasında...';
  }

  @override
  String chatCollectMessages(Object count) {
    return '$count mesaj kaydedildi';
  }

  @override
  String commonMemberCount(int count) {
    return '$count üye';
  }

  @override
  String groupDone(int count) {
    return 'Tamamlandı($count)';
  }

  @override
  String get profileServices => 'Hizmetler';

  @override
  String get commonFavorites => 'Favoriler';

  @override
  String get profileOrdersAndCards => 'Siparişler ve Kartlar';

  @override
  String get profileStickers => 'Çıkartmalar';

  @override
  String profileStatusSetTo(String status) {
    return 'Durum ayarlandı: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'Avatar yüklemesi başarısız';

  @override
  String get profilePersonalProfile => 'Kişisel Profil';

  @override
  String get profileName => 'Ad';

  @override
  String get profileGender => 'Cinsiyet';

  @override
  String get profileRegion => 'Bölge';

  @override
  String get commonMyQrCode => 'QR Kodum';

  @override
  String get profilePoke => 'Dürt';

  @override
  String get profileRingtone => 'Zil Sesi';

  @override
  String get profileDefaultRingtone => 'Varsayılan Zil Sesi';

  @override
  String get profileMyAddresses => 'Adreslerim';

  @override
  String profileGenderSetTo(String gender) {
    return 'Cinsiyet ayarlandı: $gender';
  }

  @override
  String get profileSelectRegion => 'Bölge Seç';

  @override
  String get profileSelectCity => 'Şehir Seç';

  @override
  String profileRegionSetTo(String region) {
    return 'Bölge ayarlandı: $region';
  }

  @override
  String get profileSetPoke => 'Dürtmeyi Ayarla';

  @override
  String get profileFriendPokedMe => 'Arkadaş beni dürttü';

  @override
  String get profileExample => 'Örnek';

  @override
  String get profileOnTheShoulder => ' omuzdan';

  @override
  String get profilePokeCleared => 'Dürtme temizlendi';

  @override
  String profilePokeSetTo(String suffix) {
    return 'Dürtme ayarlandı: beni dürttü$suffix';
  }

  @override
  String get profileEditSignature => 'İmzayı Düzenle';

  @override
  String get profileIntroduceYourself => 'Kendinizi tanıtacak bir cümle';

  @override
  String get profileSignatureCleared => 'İmza temizlendi';

  @override
  String get profileSignatureUpdated => 'İmza güncellendi';

  @override
  String get profileScanToAddFriend =>
      'Beni arkadaş olarak eklemek için yukarıdaki QR kodu tarayın';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'Zil sesi ayarlandı: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return '\"$name\" grubunu dağıtmak istediğinize emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get authEnterValidServerAddress =>
      'Lütfen geçerli bir sunucu adresi girin';

  @override
  String get authEnterServerAddressFirst => 'Lütfen önce sunucu adresi girin';

  @override
  String get authPasskeyRequiresServer =>
      'Passkey girişi sunucu desteği gerektirir';

  @override
  String get authLoginAgreement => 'Giriş yaparak kabul etmiş olursunuz ';

  @override
  String get authPleaseAgreeToTerms =>
      'Lütfen Hizmet Şartları ve Gizlilik Politikasını okuyun ve kabul edin';

  @override
  String get authRegisterFailed => 'Kayıt başarısız';

  @override
  String get commonReenterPassword => 'Şifreyi tekrar girin';

  @override
  String get commonPasswordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get authInviteCodeBuiltIn => 'Davet Kodu (Yerleşik)';

  @override
  String get authInviteCodeBuiltInNote =>
      'Davet kodu yerleşiktir, genellikle değiştirmeye gerek yoktur';

  @override
  String get authIHaveReadAndAgree => 'Okudum ve kabul ediyorum ';

  @override
  String get mainStartGroupChat => 'Grup Sohbeti Başlat';

  @override
  String get mainAddFriends => 'Arkadaş Ekle';

  @override
  String get mainPaymentAndCollection => 'Ödeme';

  @override
  String contactCount(int count) {
    return '$count kişi';
  }

  @override
  String get contactAddToHomeScreen => 'Ana ekrana ekle';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return '$contact kartı $recipient kişisine önerildi';
  }

  @override
  String get contactEnterRemarkName => 'Takma ad girin';

  @override
  String contactRemarkSetTo(String remark) {
    return 'Not ayarlandı: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return '$name arkadaşlık isteği kabul edildi';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return '$name arkadaşlık isteği reddedildi';
  }

  @override
  String get commonGroupInvites => 'Grup Davetleri';

  @override
  String commonMyGroups(int count) {
    return 'Gruplarım ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'Gruba davet edildi';

  @override
  String commonConfirmLeaveGroup(String name) {
    return '\"$name\" grubundan ayrılmak istediğinize emin misiniz?';
  }

  @override
  String get commonLeave => 'Ayrıl';

  @override
  String get commonRecallThisMessage => 'Bu mesajı geri al?';

  @override
  String get commonSavedToGallery => 'Galeriye kaydedildi';

  @override
  String get commonFailedToSave => 'Kaydetme başarısız';

  @override
  String get chatSaving => 'Kaydediliyor...';

  @override
  String get commonShare => 'Paylaş';

  @override
  String get chatSaveToGallery => 'Galeriye Kaydet';

  @override
  String chatDownloadFailed(String code) {
    return 'İndirme başarısız: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'Paylaşım başarısız: $error';
  }

  @override
  String get chatFailedToLoadImage => 'Resim yüklenemedi';

  @override
  String get chatVideoRecordingFailed =>
      'Video kaydı başarısız. Lütfen tekrar deneyin.';

  @override
  String get profileRedPacket => 'Kırmızı Paket';

  @override
  String get commonMusic => 'Müzik';

  @override
  String get commonCoupon => 'Kupon';

  @override
  String get commonGift => 'Hediye';

  @override
  String get commonPoll => 'Anket';

  @override
  String get favoriteText => 'Metin';

  @override
  String get favoriteLinkLabel => 'Bağlantı';

  @override
  String get favoriteNote => 'Not';

  @override
  String get favoriteMyNotes => 'Notlarım';

  @override
  String get favoriteToday => 'Bugün';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count gün önce';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$day/$month';
  }

  @override
  String get favoriteNoFavorites => 'Henüz favori yok';

  @override
  String get favoriteLongPressToFavorite =>
      'Favorilere eklemek için mesaja uzun basın';

  @override
  String get favoriteNewNote => 'Yeni Not';

  @override
  String get favoriteLink => 'Favori Bağlantı';

  @override
  String get favoriteEditTags => 'Etiketleri Düzenle';

  @override
  String get favoriteDeleteFavorite => 'Favoriyi Sil';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'Bu favoriyi silmek istediğinizden emin misiniz?';

  @override
  String get favoriteNoSearchResultsFound => 'Sonuç bulunamadı';

  @override
  String get commonSendRedPacket => 'Kırmızı Paket Gönder';

  @override
  String get transferAmount => 'Tutar';

  @override
  String get commonRedPacketCover => 'Kırmızı Paket Kapağı';

  @override
  String get commonRedPacketType => 'Kırmızı Paket Türü';

  @override
  String get commonNormalRedPacket => 'Normal';

  @override
  String get commonLuckyRedPacket => 'Şanslı';

  @override
  String get commonRedPacketCount => 'Kırmızı Paket Sayısı';

  @override
  String get commonPieces => 'adet';

  @override
  String get commonPutMoneyInRedPacket => 'Kırmızı pakete para koy';

  @override
  String get commonRedPacketRefundNotice =>
      'Alınmayan kırmızı paketler 24 saat sonra iade edilir';

  @override
  String get commonOpenRedPacket => 'Aç';

  @override
  String get commonRedPacketAllClaimed => 'Kırmızı paket tamamı alındı';

  @override
  String get commonRedPacketExpired => 'Kırmızı paket süresi doldu';

  @override
  String get commonAddTransferNote => 'Transfer notu ekle';

  @override
  String get commonYuan => 'TL';

  @override
  String get commonReplyWithEmoji => 'Bu emoji ile yanıtla';

  @override
  String get contactEditRemark => 'Notu Düzenle';

  @override
  String get contactSetPermissions => 'İzinleri Ayarla';

  @override
  String get profileAddToBlacklist => 'Kara Listeye Ekle';

  @override
  String get contactDeleteContact => 'Kişiyi Sil';

  @override
  String contactDeleteContactConfirm(String name) {
    return '$name kişisini silmek istediğinizden emin misiniz?';
  }

  @override
  String get transferTitle => 'Aktarım';

  @override
  String get transferReceiverAddressLabel => 'Alıcı Adresi';

  @override
  String get transferSelectTokenLabel => 'Token Seç';

  @override
  String get transferAmountLabel => 'Transfer Tutarı';

  @override
  String get transferMemoLabel => 'Not (isteğe bağlı)';

  @override
  String get transferAddMemoHint => 'Not ekle';

  @override
  String get transferSendPaymentRequest => 'Ödeme Talebi Gönder';

  @override
  String get transferQrCodeGenerateFailed => 'QR kod oluşturma başarısız';

  @override
  String get transferScanQrToPayMe => 'Bana ödeme yapmak için QR kodu tarayın';

  @override
  String get transferMyWalletAddress => 'Cüzdan Adresim';

  @override
  String get transferCreatePaymentRequest => 'Ödeme Talebi Oluştur';

  @override
  String profileN42IdLabel(String id) {
    return 'N42 Kimliği: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'İyi dilekler';

  @override
  String commonSenderRedPacket(String name) {
    return '$name Kırmızı Paketi';
  }

  @override
  String get transferEnterValidAddress => 'Lütfen geçerli bir adres girin';

  @override
  String get transferPleaseSelectToken => 'Lütfen bir token seçin';

  @override
  String get commonReceivedTransfer => 'Transfer Alındı';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name bir kırmızı paket gönderdi';
  }

  @override
  String get commonSavedToBalance =>
      'Bakiyeye kaydedildi, doğrudan transfer edilebilir';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'Kırmızı paket süresi doldu/tamamı alındı';

  @override
  String get transferScanFeatureComingSoon => 'Tarama özelliği yakında...';

  @override
  String get contactSetAsStarred => 'Yıldızlı Olarak Ayarla';

  @override
  String get contactAddToBlocklist => 'Engelleme Listesine Ekle';

  @override
  String get commonClaimedYour => ' sizinkini aldı ';

  @override
  String get commonClaimedText => ' aldı ';

  @override
  String commonUserTyping(String name) {
    return '$name yazıyor...';
  }

  @override
  String get commonTyping => 'Yazıyor...';

  @override
  String get commonWaitingToReceive => 'Alınmayı bekliyor';

  @override
  String get commonTapToClaim => 'Almak için dokunun';

  @override
  String get commonHasBeenReceived => 'Alındı';

  @override
  String get commonGetLucky => 'Şansını dene';

  @override
  String get qrcodeCameraStartFailed => 'Kamera başlatılamadı';

  @override
  String get qrcodeUnknownError => 'Bilinmeyen hata';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'QR kodu taramak için çerçeveye yerleştirin';

  @override
  String get qrcodeCloseManualInput => 'Manuel Girişi Kapat';

  @override
  String get qrcodeManualInputUserId => 'Manuel Kullanıcı ID Girişi';

  @override
  String get commonAdd => 'Ekle';

  @override
  String get profileSetStatus => 'Durum Ayarla';

  @override
  String get profileVisibleToFriends24h => '24 saat arkadaşlara görünür';

  @override
  String get profileWriteStatus => 'Durum Yaz';

  @override
  String get profileEnterYourStatus => 'Durumunuzu girin...';

  @override
  String get profileOk => 'Tamam';

  @override
  String get qrcodeCameraPermissionRequired =>
      'QR kod taramak için kamera izni gerekli';

  @override
  String get qrcodeCameraPermissionDenied =>
      'Kamera izni kalıcı olarak reddedildi. Lütfen sistem ayarlarından etkinleştirin.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'İzin kontrol hatası: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'Geçersiz QR kod';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'Arkadaş eklenemedi: $error';
  }

  @override
  String get qrcodeScanQrCode => 'QR Kod Tara';

  @override
  String get qrcodeCheckingCameraPermission =>
      'Kamera izni kontrol ediliyor...';

  @override
  String get qrcodeNeedCameraPermission => 'Kamera İzni Gerekli';

  @override
  String get qrcodeRetryPermission => 'Tekrar Dene';

  @override
  String get qrcodeOpenSettings => 'Ayarları Aç';

  @override
  String get groupInviteMembers => 'Üye Davet Et';

  @override
  String groupInviteCount(int count) {
    return 'Davet Et($count)';
  }

  @override
  String get profileNoShippingAddress => 'Teslimat adresi yok';

  @override
  String get profileDefaultLabel => 'Varsayılan';

  @override
  String get profileNoInvoice => 'Fatura yok';

  @override
  String get profileCompany => 'Şirket';

  @override
  String get profileTaxNumber => 'Vergi Numarası';

  @override
  String get profileConfirmDeleteAddress =>
      'Bu adresi silmek istediğinizden emin misiniz?';

  @override
  String get profileConfirmDeleteInvoice =>
      'Bu faturayı silmek istediğinizden emin misiniz?';

  @override
  String get commonGroupOwner => 'Sahip';

  @override
  String get commonGroupAdmin => 'Yönetici';

  @override
  String get groupSearchMembers => 'Üyelerde ara';

  @override
  String groupTotalMembers(int count) {
    return '$count üye';
  }

  @override
  String get chatRemoveFromGroup => 'Gruptan Çıkar';

  @override
  String groupConfirmRemoveMember(String name) {
    return '\"$name\" kişisini gruptan çıkarmak istediğinizden emin misiniz?';
  }

  @override
  String get chatUnknownSong => 'Bilinmeyen Şarkı';

  @override
  String get chatUnknownArtist => 'Bilinmeyen Sanatçı';

  @override
  String get chatUnknownContact => 'Bilinmeyen Kişi';

  @override
  String get chatPersonalCard => 'Kişi Kartı';

  @override
  String get chatSingleChoice => 'Tekli';

  @override
  String get chatMultiChoice => 'Çoklu';

  @override
  String get chatEnded => 'Sona erdi';

  @override
  String get chatEndPollButton => 'Anketi Bitir';

  @override
  String get chatPollHint =>
      'Anket sohbette görüntülenecek. Grup üyeleri oy verebilir.';

  @override
  String get chatSearchSongOrArtist => 'Şarkı veya sanatçı ara';

  @override
  String get chatNoSongsFound => 'Şarkı bulunamadı';

  @override
  String get chatSongNameOptional => 'Şarkı Adı (İsteğe bağlı)';

  @override
  String get chatEnterSongName => 'Şarkı adı girin';

  @override
  String get chatArtistNameOptional => 'Sanatçı Adı (İsteğe bağlı)';

  @override
  String get chatEnterArtistName => 'Sanatçı adı girin';

  @override
  String get chatRealTimeLocationSharing =>
      'Gerçek zamanlı konum paylaşımı geliştirme aşamasında...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'Sesli arama özelliği geliştirme aşamasında...';

  @override
  String get profileReportFeatureInDev =>
      'Şikayet özelliği geliştirme aşamasında...';

  @override
  String get profileShareFeatureInDev =>
      'Paylaşım özelliği geliştirme aşamasında...';

  @override
  String get profileQrCodeFeatureInDev =>
      'QR kod özelliği geliştirme aşamasında...';

  @override
  String get qrcodeScanQrToAddMe =>
      'Beni arkadaş olarak eklemek için yukarıdaki QR kodu tarayın';

  @override
  String get qrcodeSaveToAlbum => 'Albüme Kaydet';

  @override
  String get qrcodeChangeStyle => 'Stili Değiştir';

  @override
  String get qrcodeCopyId => 'ID Kopyala';

  @override
  String get qrcodeIdCopied => 'ID kopyalandı';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'Daha fazla stil yakında';

  @override
  String get profileBio => 'Biyografi';

  @override
  String get profileHomeServer => 'Sunucu';

  @override
  String get profileShareContactCard => 'Kişi Kartını Paylaş';

  @override
  String get profileRemoveFromBlacklist => 'Kara Listeden Çıkar';

  @override
  String get profileConfirmAddBlacklist =>
      'Bu kullanıcıyı kara listeye eklemek istediğinizden emin misiniz? Onlardan mesaj almayacaksınız.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'Bu kullanıcıyı kara listeden çıkarmak istediğinizden emin misiniz?';

  @override
  String get profileRemarkSaved => 'Not kaydedildi';

  @override
  String get profileRemarkCleared => 'Not temizlendi';

  @override
  String get transferReceive => 'Al';

  @override
  String get transferPleaseConnectWallet => 'Lütfen önce cüzdanınızı bağlayın';

  @override
  String get transferSendRequest => 'Talep Gönder';

  @override
  String get transferPleaseEnterValidAmount => 'Lütfen geçerli bir tutar girin';

  @override
  String get searchPlaceholder => 'Kişi, grup ve mesajlarda ara';

  @override
  String get searchEnterKeywordToSearch =>
      'Aramaya başlamak için anahtar kelime girin';

  @override
  String get searchClearHistory => 'Temizle';

  @override
  String searchNoResultsForQuery(String query) {
    return '\"$query\" için sonuç bulunamadı';
  }

  @override
  String get searchAllResults => 'Tümü';

  @override
  String get searchInChat => 'Sohbette ara';

  @override
  String get searchContactLabel => 'Kişi';

  @override
  String get searchGroupLabel => 'Grup';

  @override
  String get searchConversationLabel => 'Sohbet';

  @override
  String get searchMessageLabel => 'Mesaj';

  @override
  String get settingsSecurityTitle => 'Güvenlik';

  @override
  String get settingsKeyBackup => 'Anahtar Yedekleme';

  @override
  String get settingsBackupEncryptionKeys => 'Şifreleme Anahtarlarını Yedekle';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count anahtar yedeklendi';
  }

  @override
  String get settingsBackupNotSet => 'Yedekleme ayarlanmadı';

  @override
  String get settingsRestoreKeys => 'Anahtarları Geri Yükle';

  @override
  String get settingsRestoreKeysFromBackup =>
      'Yedekten şifreleme anahtarlarını geri yükle';

  @override
  String get settingsExportKeys => 'Anahtarları Dışa Aktar';

  @override
  String get settingsExportKeysToFile => 'Anahtarları dosyaya aktar';

  @override
  String get settingsLoggedInDevices => 'Giriş Yapılmış Cihazlar';

  @override
  String get settingsNoOtherDevices => 'Başka cihaz yok';

  @override
  String get settingsVerified => 'Doğrulanmış';

  @override
  String get settingsUnverified => 'Doğrulanmamış';

  @override
  String get settingsAdvanced => 'Gelişmiş';

  @override
  String get settingsCrossSigning => 'Çapraz İmza';

  @override
  String get settingsEnabled => 'Etkin';

  @override
  String get settingsNotEnabled => 'Etkin değil';

  @override
  String get settingsResetEncryption => 'Şifrelemeyi Sıfırla';

  @override
  String get settingsDeleteAllEncryptionKeys =>
      'Tüm şifreleme anahtarlarını sil';

  @override
  String get settingsEncryptionNotSupported => 'Şifreleme desteklenmiyor';

  @override
  String get settingsNotInitialized => 'Başlatılmadı';

  @override
  String get settingsBackupKeyTitle => 'Anahtarları Yedekle';

  @override
  String get settingsBackupKeyMessage =>
      'Yeni bir anahtar yedeklemesi oluştur? Bu, yeni bir cihazda şifrelenmiş mesajları geri yüklemenize yardımcı olacaktır.';

  @override
  String get settingsBackup => 'Yedekle';

  @override
  String get settingsRestoreKeyTitle => 'Anahtarları Geri Yükle';

  @override
  String get settingsRestoreKeyMessage =>
      'Şifrelenmiş mesajları geri yüklemek için kurtarma şifrenizi veya kurtarma anahtarınızı girin.';

  @override
  String get settingsRestore => 'Geri Yükle';

  @override
  String get settingsExportKeyTitle => 'Anahtarları Dışa Aktar';

  @override
  String get settingsExportKeyMessage =>
      'Dışa aktarılan anahtar dosyası tüm şifreleme anahtarlarınızı içerir. Lütfen güvenli bir yerde saklayın.';

  @override
  String get settingsExport => 'Dışa Aktar';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'Cihaz ID: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'Durum: Doğrulanmış';

  @override
  String get settingsDeviceStatusUnverified => 'Durum: Doğrulanmamış';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'Son etkinlik: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'Bu cihazı doğrula';

  @override
  String get settingsCrossSigningAlreadyEnabled => 'Çapraz imza zaten etkin';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'Çapraz imza kurulumu başarılı';

  @override
  String get settingsResetEncryptionTitle => 'Şifrelemeyi Sıfırla';

  @override
  String get settingsResetEncryptionWarning =>
      'Uyarı: Bu tüm şifreleme anahtarlarınızı silecektir. Önceki şifrelenmiş mesajların şifresini çözemeyeceksiniz. Bu işlem geri alınamaz.';

  @override
  String get settingsReset => 'Sıfırla';

  @override
  String get settingsBackupSuccess => 'Anahtarlar başarıyla yedeklendi';

  @override
  String get settingsBackupFailed => 'Yedekleme başarısız oldu';

  @override
  String get settingsRecoveryKey => 'Kurtarma Anahtarı';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'Lütfen bu kurtarma anahtarını güvenli bir yere saklayın. Şifrelenmiş mesajlarınızı yeni bir cihaza geri yüklemek için buna ihtiyacınız olacak.';

  @override
  String get settingsRecoveryKeySaved => 'onu sakladım';

  @override
  String get settingsRestoreSuccess => 'Anahtarlar başarıyla geri yüklendi';

  @override
  String get settingsRestoreFailed => 'Geri yükleme başarısız oldu';

  @override
  String get settingsPassword => 'Şifre';

  @override
  String get settingsEnterRecoveryKey => 'Kurtarma anahtarını girin';

  @override
  String get settingsEnterPassword => 'Şifreyi girin';

  @override
  String get settingsExportSuccess =>
      'Anahtarlar sunucu yedeklemesine başarıyla aktarıldı';

  @override
  String get settingsExportNeedBackupFirst =>
      'Lütfen önce bir anahtar yedeği oluşturun';

  @override
  String get settingsExportFailed => 'Dışa aktarma başarısız oldu';

  @override
  String get settingsResetSuccess => 'Şifreleme sıfırlama başarılı';

  @override
  String get settingsResetFailed => 'Sıfırlama başarısız oldu';

  @override
  String get callLeaveMeetingConfirm =>
      'Toplantıdan ayrılmak istediğinizden emin misiniz?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return '$name kişisini$suffix dürttü';
  }

  @override
  String get chatNoContactsToAdd => 'Eklenecek kişi yok';

  @override
  String get chatAddMembers => 'Üye Ekle';

  @override
  String chatInvitedMembers(int count) {
    return '$count üye davet edildi';
  }

  @override
  String chatInviteFailed(String error) {
    return 'Davet başarısız: $error';
  }

  @override
  String get chatMemberRemoved => 'Üye çıkarıldı';

  @override
  String chatRemoveFailed(String error) {
    return 'Çıkarma başarısız: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'Paylaştıktan sonra, karşı taraf 1 saat boyunca gerçek zamanlı konumunuzu görebilir.';

  @override
  String get chatStartSharing => 'Paylaşımı Başlat';

  @override
  String get chatLocationServiceNotEnabled => 'Konum servisi etkin değil';

  @override
  String get chatEnableLocationService =>
      'Bu özelliği kullanmak için lütfen konum servisini etkinleştirin';

  @override
  String get chatGoToSettings => 'Ayarlara Git';

  @override
  String get chatLocationPermissionRequired =>
      'Bu özellik için konum izni gerekli';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan etkinleştirin.';

  @override
  String get chatLocationPermissionDenied => 'Konum izni reddedildi';

  @override
  String get chatGettingLocation => 'Konum alınıyor...';

  @override
  String chatGetLocationFailed(String error) {
    return 'Konum alınamadı: $error';
  }

  @override
  String get chatMapPreview => 'Harita Önizleme';

  @override
  String get chatSearchLocation => 'Konum ara';

  @override
  String chatRedPacketSent(String amount, String token) {
    return '$amount $token kırmızı paket gönderildi';
  }

  @override
  String get chatTransferDefault => 'Aktarım';

  @override
  String chatTransferSent(String amount, String token) {
    return '$amount $token transfer gönderildi';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'Dosya seçilemedi: $error';
  }

  @override
  String get chatFileSizeLimit => 'Dosya boyutu 50MB\'ı geçemez';

  @override
  String chatFileSending(String filename) {
    return 'Dosya gönderiliyor: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'Dosya gönderilemedi: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return '$name kişi kartı gönderildi';
  }

  @override
  String get chatFavoritesFeature => 'Favoriler';

  @override
  String get chatCouponsFeature => 'Kuponlar';

  @override
  String get chatGiftFeature => 'Hediye';

  @override
  String chatSharedMusic(String name) {
    return '$name paylaşıldı';
  }

  @override
  String get chatEndPollTitle => 'Anketi Bitir';

  @override
  String get chatEndPollConfirmMessage =>
      'Bu anketi bitirmek istediğinizden emin misiniz? Bitirdikten sonra oylama kapanacaktır.';

  @override
  String get chatPollEndedMessage => 'Anket sona erdi';

  @override
  String get chatConnectingCall => 'Bağlanıyor...';

  @override
  String get chatMuteCall => 'Sessize Al';

  @override
  String get chatSpeakerOff => 'Hoparlör Kapalı';

  @override
  String get chatSpeakerOn => 'Hoparlör';

  @override
  String get chatCameraOn => 'Kamera Açık';

  @override
  String get chatCameraOff => 'Kamera Kapalı';

  @override
  String get chatHangUp => 'Kapat';

  @override
  String get chatSelectForwardTargetTitle => 'İletilecek Hedefi Seçin';

  @override
  String get chatNoForwardableChat => 'İletmek için sohbet yok';

  @override
  String get chatNoMatchingChat => 'Eşleşen sohbet bulunamadı';

  @override
  String get chatLocationTitle => 'Konum';

  @override
  String get chatSendButton => 'Gönder';

  @override
  String get chatRetryButton => 'Tekrar Dene';

  @override
  String get chatSearchContactHint => 'Kişilerde ara';

  @override
  String get chatShareMusic => 'Müzik Paylaş';

  @override
  String get chatRecentPlayed => 'Son Çalınanlar';

  @override
  String get chatMyFavorites => 'Favorilerim';

  @override
  String get chatNetworkLink => 'Bağlantı';

  @override
  String get chatLocalFile => 'Yerel';

  @override
  String get chatPasteMusicLink => 'Müzik bağlantısı yapıştırın';

  @override
  String get chatShareMusicButton => 'Müzik Paylaş';

  @override
  String get chatSelectLocalAudio => 'Yerel Ses Dosyası Seç';

  @override
  String get chatSupportedAudioFormats =>
      'MP3, M4A, WAV, FLAC vb. desteklenir.';

  @override
  String get chatSelectFileButton => 'Dosya Seç';

  @override
  String get chatPleaseEnterMusicLink => 'Lütfen müzik bağlantısı girin';

  @override
  String get chatPleaseEnterValidLink => 'Lütfen geçerli bir URL girin';

  @override
  String get chatSharedSong => 'Paylaşılan Şarkı';

  @override
  String get chatSelectMember => 'Üye Seç';

  @override
  String get chatSearchMemberHint => 'Üyelerde ara';

  @override
  String get chatNoMatchingMembers => 'Eşleşen üye bulunamadı';

  @override
  String get commonUnknownMember => 'Bilinmeyen';

  @override
  String chatSelectedMessagesCount(int count) {
    return '$count mesaj seçildi';
  }

  @override
  String get chatSearchContactsOrGroups => 'Kişi veya gruplarda ara';

  @override
  String get chatVideoTitle => 'video';

  @override
  String get chatLoadingText => 'Yükleniyor...';

  @override
  String get chatVideoLoadFailed => 'Video yüklenemedi';

  @override
  String get chatPlayerInitFailed => 'Oynatıcı başlatılamadı';

  @override
  String get chatCreatePollTitle => 'Anket Oluştur';

  @override
  String get chatSubmitPoll => 'Gönder';

  @override
  String get chatPollQuestionLabel => 'Anket Sorusu';

  @override
  String get chatEnterPollQuestionHint => 'Anket sorusu girin';

  @override
  String get chatPollOptionsLabel => 'Anket Seçenekleri';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'Seçenek $index';
  }

  @override
  String get chatAddOptionButton => 'Seçenek Ekle';

  @override
  String get chatPollSettingsLabel => 'Anket Ayarları';

  @override
  String get chatSelectionType => 'Seçim Türü';

  @override
  String get chatSingleChoiceLabel => 'Tekli';

  @override
  String get chatMultiChoiceLabel => 'Çoklu';

  @override
  String get chatAnonymousPollSwitch => 'Anonim Anket';

  @override
  String get chatPleaseEnterQuestion => 'Lütfen anket sorusu girin';

  @override
  String get chatAtLeastTwoOptions => 'En az 2 seçenek gerekli';

  @override
  String chatConfirmWithCount(int count) {
    return 'Onayla ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'E-posta Doğrulama';

  @override
  String get authEnterValidEmailAddress =>
      'Lütfen geçerli bir e-posta adresi girin';

  @override
  String authVerificationCodeSentTo(String email) {
    return '$email adresine doğrulama kodu gönderildi';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'Kod gönderilemedi: $error';
  }

  @override
  String get authVerificationSuccess => 'Doğrulama başarılı';

  @override
  String get authVerificationFailed => 'Doğrulama başarısız';

  @override
  String authVerificationCodeError(String error) {
    return 'Doğrulama kodu hatası: $error';
  }

  @override
  String get commonEnterVerificationCode => 'Doğrulama kodunu girin';

  @override
  String get authEnterYourEmail => 'E-posta girin';

  @override
  String authWeSentCodeTo(String email) {
    return '$email adresine\n6 haneli kod gönderdik';
  }

  @override
  String get authEnterEmailForCode =>
      'E-posta adresinizi girin, doğrulama kodu göndereceğiz';

  @override
  String get commonSendVerificationCode => 'Doğrulama kodu gönder';

  @override
  String get authResendVerificationCode => 'Doğrulama kodunu tekrar gönder';

  @override
  String authCanResendAfter(int seconds) {
    return '$seconds saniye sonra tekrar gönderilebilir';
  }

  @override
  String get commonChangeEmail => 'E-postayı değiştir';

  @override
  String get contactAddToContacts => 'Kişilere Ekle';

  @override
  String get contactAddingToContacts => 'Ekleniyor...';

  @override
  String get contactAddedToContacts => 'Kişilere eklendi';

  @override
  String contactAddFailedWithError(String error) {
    return 'Ekleme başarısız: $error';
  }

  @override
  String get contactAddPhone => 'Telefon ekle';

  @override
  String get contactAddTag => 'Etiket ekle';

  @override
  String get contactAddText => 'Metin ekle';

  @override
  String get contactAddPhoto => 'Fotoğraf ekle';

  @override
  String contactGroupCountLabel(int count) {
    return '$count grup';
  }

  @override
  String get contactAddedViaSearch => 'Arama yoluyla eklendi';

  @override
  String get contactAddTime => 'Zaman ekle';

  @override
  String get contactDoneButton => 'Tamam';

  @override
  String get callWaitingForParticipants => 'Katılımcılar bekleniyor...';

  @override
  String callParticipantMe(String name) {
    return '$name (Ben)';
  }

  @override
  String get callSharingLabel => 'Paylaşılıyor';

  @override
  String callScreenSharingBy(String name) {
    return '$name ekran paylaşıyor';
  }

  @override
  String callParticipantCount(int count) {
    return '$count katılımcı';
  }

  @override
  String get callMuteLabel => 'Sessize Al';

  @override
  String get callUnmuteLabel => 'Sesi Aç';

  @override
  String get callTurnOffVideo => 'Videoyu kapat';

  @override
  String get callTurnOnVideo => 'Videoyu aç';

  @override
  String get callShareScreen => 'Ekran paylaş';

  @override
  String get callStopSharing => 'Paylaşımı durdur';

  @override
  String get callSwitchCameraLabel => 'Değiştir';

  @override
  String get callLeaveLabel => 'Ayrıl';

  @override
  String get callParticipantsLabel => 'Katılımcılar';

  @override
  String get callJoiningMeeting => 'Toplantıya katılınıyor...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count oy ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count katılımcı';
  }

  @override
  String get commonTapToRetry => 'Tekrar denemek için dokunun';

  @override
  String get chatDefaultRedPacketGreeting => 'Bol şans ve bereket dilerim';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'Başkalarının arama yapmasına ve katılmasına izin ver';

  @override
  String get groupConfirmClearChatHistory =>
      'Sohbet geçmişini temizlemek istediğinizden emin misiniz?';

  @override
  String get groupCreateGroupToChat =>
      'Sohbet etmeye başlamak için bir grup oluşturun';

  @override
  String get groupEditGroupAnnouncement => 'Grup duyurusunu düzenle';

  @override
  String get groupEditGroupDescription => 'Grup açıklamasını düzenle';

  @override
  String get groupEnterGroupAnnouncement => 'Grup duyurusunu girin';

  @override
  String chatErrorWithMessage(String message) {
    return 'Hata: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count üye, grup ID\'sini kopyalamak için tıklayın';
  }

  @override
  String get chatMusicLinkLabel => 'Müzik bağlantısı';

  @override
  String get chatNoMediaUrlAvailable => 'Medya URL\'si mevcut değil';

  @override
  String get groupNoPermissionToEditGroupName =>
      'Grup adını düzenleme izniniz yok';

  @override
  String get chatRedPacketTransferCannotForward =>
      'Kırmızı zarflar ve transferler iletilemez';

  @override
  String get authEmailAddress => 'E-posta adresi';

  @override
  String get commonEnterEmailAddress => 'E-posta adresini girin';

  @override
  String get authEmailRecoveryHint => 'Şifre kurtarma için kullanılır';

  @override
  String get commonInvalidEmailFormat => 'Geçerli bir e-posta adresi girin';

  @override
  String get authOptional => 'İsteğe bağlı';

  @override
  String get authResetPassword => 'Şifre sıfırla';

  @override
  String get authEnterRegisteredEmail =>
      'Kayıt olduğunuz e-posta adresini girin';

  @override
  String get authSendResetCode => 'Sıfırlama kodu gönder';

  @override
  String authResetCodeSent(String email) {
    return 'Sıfırlama kodu $email adresine gönderildi';
  }

  @override
  String get authEnterResetCode => 'Sıfırlama kodunu girin';

  @override
  String get authSetNewPassword => 'Yeni şifre belirle';

  @override
  String get commonConfirmNewPassword => 'Yeni şifreyi onayla';

  @override
  String get commonNewPassword => 'Yeni şifre';

  @override
  String get authPasswordResetSuccess =>
      'Şifre başarıyla sıfırlandı. Yeni şifrenizle giriş yapın.';

  @override
  String get authResetPasswordFailed => 'Şifre sıfırlanamadı';

  @override
  String get settingsChangePassword => 'Şifre değiştir';

  @override
  String get settingsCurrentPassword => 'Mevcut şifre';

  @override
  String get settingsEnterCurrentPassword => 'Mevcut şifreyi girin';

  @override
  String get settingsEnterNewPassword => 'Yeni şifreyi girin';

  @override
  String get settingsPasswordChanged =>
      'Şifre başarıyla değiştirildi. Yeni şifrenizle giriş yapın.';

  @override
  String get settingsChangePasswordFailed => 'Şifre değiştirilemedi';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'Yeni şifre mevcut şifreden farklı olmalıdır';

  @override
  String get settingsChangePasswordInfo =>
      'Şifre değiştirildikten sonra çıkış yapılacak ve yeni şifre ile giriş yapmanız gerekecek.';

  @override
  String get settingsPasswordRequirements => 'Şifre gereksinimleri:';

  @override
  String get settingsSecurityNote =>
      'Güvenlik için şifre değiştirdikten sonra tüm cihazlarda yeniden giriş yapmanız gerekecek.';

  @override
  String get settingsSecurity => 'Güvenlik';

  @override
  String get settingsCurrentBoundEmail => 'Mevcut bağlı e-posta';

  @override
  String get settingsNewEmailAddress => 'Yeni e-posta adresi';

  @override
  String get settingsEnterNewEmail => 'Yeni e-posta adresini girin';

  @override
  String get settingsVerificationCode => 'Doğrulama kodu';

  @override
  String get settingsVerificationCodeSent => 'Doğrulama kodu gönderildi';

  @override
  String get settingsCodeSentTo => 'Doğrulama kodu gönderildi';

  @override
  String get settingsDidNotReceiveCode => 'Kodu almadınız mı?';

  @override
  String get settingsEmailChangedSuccess => 'E-posta başarıyla değiştirildi';

  @override
  String get settingsChangeEmailFailed => 'E-posta değiştirilemedi';

  @override
  String get settingsEmailSecurityNote =>
      'E-postanız şifre kurtarma için kullanılır. Güvende tutun.';

  @override
  String get commonGoogleLogin => 'Google ile giriş yap';

  @override
  String get commonAppleLogin => 'Apple ile giriş yap';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageChanged => 'Dil değiştirildi';

  @override
  String get settingsTranslation => 'Çeviri';

  @override
  String get settingsTranslateTextTo => 'Metni şu dile çevir:';

  @override
  String get settingsTranslateDescription =>
      'Mesajların çevrilmesini istediğiniz dili seçin.';

  @override
  String get settingsAutoTranslate => 'Alınan mesajları otomatik çevir';

  @override
  String get settingsAutoTranslateDescription =>
      'Sohbette alınan mesajları otomatik olarak seçtiğiniz dile çevirin.';

  @override
  String get settingsBiometricLogin => 'Biyometrik giriş';

  @override
  String authLoginWithBiometric(Object type) {
    return '$type ile giriş yap';
  }

  @override
  String get settingsBiometricLoginEnabled => 'Biyometrik giriş etkin';

  @override
  String get settingsBiometricLoginDisabled => 'Biyometrik giriş devre dışı';

  @override
  String get settingsEnableBiometricLogin => 'Biyometrik girişi etkinleştir';

  @override
  String get settingsBiometricEnabled => 'Etkin - Giriş için biyometri kullan';

  @override
  String get settingsBiometricDisabled =>
      'Devre dışı - Etkinleştirmek için dokunun';

  @override
  String get settingsBiometricNeedRelogin =>
      'Biyometrik girişi etkinleştirmek için çıkış yapıp tekrar giriş yapın';

  @override
  String get authOr => 'VEYA';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'Bu cihazda kamera erişimi kısıtlı';

  @override
  String get authPasskeyLabel => 'Geçiş anahtarı';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'elma';

  @override
  String get authSsoLabel => 'TOA';

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
  String get profileEnterPokeSuffixHint => 'Dürtme ekini girin, ör.: omzuna';

  @override
  String get groupAlbum => 'Grup albümü';

  @override
  String get groupFiles => 'Grup dosyaları';

  @override
  String get groupImages => 'Görseller';

  @override
  String get groupVideos => 'Videolar';

  @override
  String get groupTotal => 'Toplam';

  @override
  String get groupSize => 'Boyut';

  @override
  String get groupNoMedia => 'Medya yok';

  @override
  String get groupNoMediaDescription =>
      'Bu grupta henüz fotoğraf veya video yok';

  @override
  String get groupDocuments => 'Belgeler';

  @override
  String get groupNoFiles => 'Dosya yok';

  @override
  String get groupNoFilesDescription => 'Bu grupta henüz dosya yok';

  @override
  String groupDownloadStarted(String filename) {
    return '$filename indiriliyor...';
  }

  @override
  String get contactNoCommonGroups => 'Ortak grup yok';

  @override
  String get contactNoCommonGroupsDescription => 'Ortak grubunuz yok';

  @override
  String get chatVoiceMessage => 'Ses';

  @override
  String get chatMessage => 'Mesaj';

  @override
  String get conversationHideChat => 'Gizle';

  @override
  String get settingsQuickReply => 'Hızlı yanıt';

  @override
  String get commonTranslate => 'Çevir';

  @override
  String get contactCreateTag => 'Etiket Oluştur';

  @override
  String get contactEnterTagName => 'Etiket adını girin';

  @override
  String get contactEditTag => 'Etiketi Düzenle';

  @override
  String get contactDeleteTag => 'Etiketi Sil';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return '\"$tagName\" etiketini silmek istediğinizden emin misiniz?';
  }

  @override
  String get contactNoTags => 'Henüz etiket yok';

  @override
  String get contactFriendPermissions => 'Arkadaş İzinleri';

  @override
  String get contactSetChatOnly => 'Yalnızca Sohbet olarak ayarla';

  @override
  String get contactChatOnlyDesc =>
      'Yalnızca sizinle sohbet edebilirim, diğer içerikler gizlenecek';

  @override
  String get contactHideMyMoments => 'Anlarımı Gizle';

  @override
  String get contactHideMyMomentsDesc => 'Bu arkadaş anlarımı göremiyor';

  @override
  String get contactHideTheirMoments => 'Anlarını Gizle';

  @override
  String get contactHideTheirMomentsDesc => 'Bu arkadaşın Anlarını görme';

  @override
  String get contactHideMyStatus => 'Durumumu Gizle';

  @override
  String get contactHideMyStatusDesc =>
      'Bu arkadaş durum güncellemelerimi göremiyor';

  @override
  String get contactNoChatOnlyFriends => 'Yalnızca sohbet için arkadaş yok';

  @override
  String get contactNoOfficialAccounts => 'Resmi hesap yok';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'En son güncellemeleri almak için resmi hesapları takip edin';

  @override
  String get contactNoServiceAccounts => 'Hizmet hesabı yok';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'Uygun hizmetler için hizmet hesaplarına abone olun';

  @override
  String get contactNoEnterpriseContacts => 'Kurumsal bağlantı yok';

  @override
  String get contactEnterpriseContactsDesc =>
      'Kurumsal kişiler burada görüntülenecek';

  @override
  String get profileCardPack => 'Kart Paketi';

  @override
  String get profileOrders => 'Siparişler';

  @override
  String get profileNoOrders => 'Sipariş yok';

  @override
  String get profileOrdersDesc => 'Siparişleriniz burada görüntülenecek';

  @override
  String get profileNoCards => 'Kart yok';

  @override
  String get profileCardsDesc => 'Kartlarınız burada görüntülenecek';

  @override
  String get favoriteEnterTagsHint => 'Etiketleri virgülle ayırarak girin';

  @override
  String get favoriteTagsUpdated => 'Etiketler güncellendi';

  @override
  String get favoriteForwardedContent => 'İçerik iletildi';

  @override
  String get favoriteEnterNoteContent => 'Not içeriğini girin';

  @override
  String get favoriteNoteAdded => 'Not eklendi';

  @override
  String get favoriteLinkTitle => 'Bağlantı başlığı';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'Bağlantı eklendi';

  @override
  String get contactPhotoAdded => 'Fotoğraf eklendi';

  @override
  String get contactEnterPhone => 'Telefon numarasını girin';

  @override
  String commonConversationWithId(String roomId) {
    return 'Sohbet: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'Kişi: $userId';
  }

  @override
  String get commonDiscover => 'Keşfet';

  @override
  String commonDeveloping(String title) {
    return '$title\n(Yakında)';
  }

  @override
  String get commonPageNotFound => 'Sayfa bulunamadı';

  @override
  String get commonBackToHome => 'Ana Sayfaya Dön';

  @override
  String get settingsMessageNotifications => 'Mesaj bildirimleri';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'Yeni mesaj bildirimleri al';

  @override
  String get settingsShowMessagePreview => 'Mesaj önizlemesini göster';

  @override
  String get settingsShowMessageContentInNotification =>
      'Bildirimlerde mesaj içeriğini göster';

  @override
  String get settingsNotificationSound => 'Bildirim sesi';

  @override
  String get settingsPlaySoundOnMessage => 'Mesaj alındığında ses çal';

  @override
  String get commonVibration => 'Titreşim';

  @override
  String get settingsVibrateOnMessage => 'Mesaj alındığında titret';

  @override
  String get settingsDoNotDisturbMode => 'Rahatsız etmeyin';

  @override
  String get settingsDoNotDisturbDescription =>
      'Belirtilen süre boyunca bildirim alma';

  @override
  String get settingsStartTime => 'Başlangıç saati';

  @override
  String get settingsEndTime => 'Bitiş saati';

  @override
  String get settingsDeleteQuickReply => 'Hızlı yanıtı sil';

  @override
  String get settingsEditQuickReply => 'Hızlı yanıtı düzenle';

  @override
  String get settingsAddQuickReply => 'Hızlı yanıt ekle';

  @override
  String get settingsManageQuickReplies => 'Hızlı yanıtları yönet';

  @override
  String get settingsNoQuickReplies => 'Hızlı yanıt yok';

  @override
  String get settingsDefaultQuickReplies =>
      'Varsayılan hızlı yanıtlar gösterilecek';

  @override
  String get settingsWhoCanSee => 'Kimler görebilir';

  @override
  String get settingsLastSeen => 'Son görülme';

  @override
  String get settingsHiddenChats => 'Gizli sohbetler';

  @override
  String get settingsMessagesLabel => 'Mesajlar';

  @override
  String get settingsAllowStrangerMessages =>
      'Yabancılardan mesajlara izin ver';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'Kişiler dışından mesaj al';

  @override
  String get settingsReadReceipts => 'Okundu bilgisi';

  @override
  String get settingsLetOthersKnowYouRead =>
      'Başkalarının mesajlarını okuduğunuzu bilmelerini sağlayın';

  @override
  String get settingsTypingIndicator => 'Yazma göstergesi';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'Başkalarının yazdığınızı bilmelerini sağlayın';

  @override
  String get settingsEveryone => 'Herkes';

  @override
  String get settingsContactsOnly => 'Sadece kişiler';

  @override
  String get settingsNobody => 'Hiç kimse';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return '$title kimler görebilir';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'Sürüm $version';
  }

  @override
  String get settingsCheckForUpdates => 'Güncellemeleri kontrol et';

  @override
  String get settingsOpenSourceLicenses => 'Açık kaynak lisansları';

  @override
  String get settingsFeedbackAndSuggestions => 'Geri bildirim ve öneriler';

  @override
  String get settingsBuiltOnMatrix => 'Matrix protokolü üzerine kurulu';

  @override
  String get settingsNoHiddenChats => 'Gizli sohbet yok';

  @override
  String get settingsNoHiddenChatsDescription =>
      'Gizlediğiniz sohbetler burada görünecek';

  @override
  String get settingsUnhideChat => 'Göster';

  @override
  String get settingsDarkMode => 'Karanlık mod';

  @override
  String get settingsFontSize => 'Yazı tipi boyutu';

  @override
  String get settingsBubbleStyle => 'Balon stili';

  @override
  String get settingsFollowSystem => 'Sistemi takip et';

  @override
  String get settingsAutoSwitchBySystem =>
      'Sistem ayarlarına göre otomatik geçiş yap';

  @override
  String get settingsLightMode => 'Aydınlık mod';

  @override
  String get settingsAlwaysUseLightTheme => 'Her zaman açık tema kullan';

  @override
  String get settingsDarkModeOption => 'Karanlık mod';

  @override
  String get settingsAlwaysUseDarkTheme => 'Her zaman koyu tema kullan';

  @override
  String get settingsFontSizeSmall => 'Küçük';

  @override
  String get settingsFontSizeStandard => 'Standart';

  @override
  String get settingsFontSizeLarge => 'Büyük';

  @override
  String get settingsFontSizeExtraLarge => 'Çok büyük';

  @override
  String get settingsBubbleStyleWechat => 'WeChat stili';

  @override
  String get settingsBubbleStyleWechatDesc => 'Klasik WeChat balon stili';

  @override
  String get settingsBubbleStyleModern => 'Modern stil';

  @override
  String get settingsBubbleStyleModernDesc => 'Temiz modern balon stili';

  @override
  String get settingsBubbleStyleClassic => 'Klasik stil';

  @override
  String get settingsBubbleStyleClassicDesc => 'Geleneksel balon stili';

  @override
  String get discoverVideoChannels => 'Kanallar';

  @override
  String get discoverLive => 'Canlı';

  @override
  String get discoverListen => 'Dinle';

  @override
  String get discoverWatch => 'İzle';

  @override
  String get discoverSearchDiscover => 'Ara';

  @override
  String get discoverNearbyPeople => 'Yakındakiler';

  @override
  String get discoverGames => 'Oyunlar';

  @override
  String get discoverMiniPrograms => 'Mini Programlar';

  @override
  String get chatAlreadyInCall => 'Zaten bir aramada';

  @override
  String get commonConnectionFailed => 'Bağlantı başarısız';

  @override
  String get chatCallRejected => 'Arama reddedildi';

  @override
  String get chatNoAnswer => 'Cevap yok';

  @override
  String get commonClose => 'Kapat';

  @override
  String get chatSelectContact => 'Kişi Seç';

  @override
  String get chatVoteRemoved => 'Oy kaldırıldı';

  @override
  String get chatVoteChanged => 'Oy değiştirildi';

  @override
  String get chatVoted => 'Oy verildi';

  @override
  String chatReplyTo(String name) {
    return '$name adlı kişiye yanıt';
  }

  @override
  String get chatCurrentLocation => 'Mevcut Konum';

  @override
  String chatNearbyPlace(int index) {
    return 'Yakın Yer $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'Yaklaşık $distance';
  }

  @override
  String get chatAddress => 'Adres';

  @override
  String get chatLatitude => 'Enlem';

  @override
  String get chatLongitude => 'Boylam';

  @override
  String get groupDescriptionUpdated => 'Grup açıklaması güncellendi';

  @override
  String get groupAvatarUpdated => 'Grup avatarı güncellendi';

  @override
  String get groupVisibilityUpdated => 'Grup görünürlüğü güncellendi';

  @override
  String get groupChannelCreated => 'Kanal oluşturuldu';

  @override
  String get groupChannelUpdated => 'Kanal güncellendi';

  @override
  String get groupChannelDeleted => 'Kanal silindi';

  @override
  String get callDecline => 'Reddet';

  @override
  String get callAnswer => 'Yanıtla';

  @override
  String get callIncomingVideoCall => 'Gelen görüntülü arama';

  @override
  String get callIncomingVoiceCall => 'Gelen sesli arama';

  @override
  String get callVideoCallInProgress => 'Görüntülü arama';

  @override
  String get callVoiceCallInProgress => 'Sesli arama';

  @override
  String get callReconnectingCall => 'Yeniden bağlanıyor...';

  @override
  String get callEnded => 'Arama sonlandı';

  @override
  String get callFailed => 'Arama başarısız';

  @override
  String get callLivekitNotConfigured => 'LiveKit yapılandırılmadı';

  @override
  String callJoinMeetingFailed(String error) {
    return 'Toplantıya katılınamadı: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'Ekran paylaşımı başarısız: $error';
  }

  @override
  String get profileN42BeanTitle => 'N42 Fasulye';

  @override
  String get profileNoN42Bean => 'N42 Bean yok';

  @override
  String get profileN42BeanDetails => 'N42 Bean Detayları';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean, N42\'deki sanal eşya ve hizmetleri almak için kullanılan bir tokendır. Şu anda şunlar için kullanılabilir:';

  @override
  String get profileN42BeanFeature1 => 'Üyelere özel çıkartmalar ve temalar';

  @override
  String get profileN42BeanFeature2 => 'Sohbet balonu özelleştirme';

  @override
  String get profileN42BeanFeature3 => 'Kırmızı zarf kapağı özelleştirme';

  @override
  String get profileN42BeanFeature4 => 'Özel takma ad rozeti';

  @override
  String get profileN42BeanFeature5 => 'Grup sohbeti ayrıcalıkları';

  @override
  String get profileN42BeanFeature6 => 'Bulut depolama genişletme';

  @override
  String get profileN42BeanFeature7 => 'Görüntülü arama güzellik filtreleri';

  @override
  String get profileN42BeanFeature8 => 'Anlar arka plan özelleştirme';

  @override
  String get profileN42BeanFeature9 => 'VIP müşteri hizmetleri önceliği';

  @override
  String get profileGotIt => 'Anladım';

  @override
  String get profileNoN42BeanRecords => 'N42 Bean kaydı yok';

  @override
  String get profileMoodAndThoughts => 'Ruh Hali ve Düşünceler';

  @override
  String get profileStatusHappy => 'Mutlu';

  @override
  String get profileStatusCracked => 'Paramparça';

  @override
  String get profileStatusLucky => 'Şanslı';

  @override
  String get profileStatusSunny => 'Güneşli';

  @override
  String get profileStatusTired => 'Yorgun';

  @override
  String get profileStatusDaydream => 'Hayal';

  @override
  String get profileStatusRushing => 'Acele';

  @override
  String get profileStatusOverthinking => 'Fazla Düşünme';

  @override
  String get profileStatusEnergized => 'Enerjik';

  @override
  String get profileWorkAndStudy => 'İş ve Çalışma';

  @override
  String get profileStatusWorking => 'Çalışıyor';

  @override
  String get profileStatusStudying => 'Ders Çalışıyor';

  @override
  String get profileStatusBusy => 'Meşgul';

  @override
  String get profileStatusSlacking => 'Tembellik';

  @override
  String get profileStatusTraveling => 'Seyahatte';

  @override
  String get profileStatusGoingHome => 'Eve Gidiyor';

  @override
  String get profileStatusDnd => 'Rahatsız Etmeyin';

  @override
  String get profileActivities => 'Aktiviteler';

  @override
  String get profileStatusHanging => 'Takılıyor';

  @override
  String get profileStatusCheckIn => 'Check-in';

  @override
  String get profileStatusExercising => 'Egzersiz';

  @override
  String get profileStatusCoffee => 'Kahve';

  @override
  String get profileStatusBubbleTea => 'Kabarcık Çayı';

  @override
  String get profileStatusEating => 'Yemek Yiyor';

  @override
  String get profileStatusParenting => 'Ebeveynlik';

  @override
  String get profileStatusSavingWorld => 'Dünyayı Kurtarıyor';

  @override
  String get profileStatusSelfie => 'Selfie';

  @override
  String get profileRest => 'Dinlenme';

  @override
  String get profileStatusRetreat => 'Dinlenme';

  @override
  String get profileStatusHome => 'Evde';

  @override
  String get profileStatusSleeping => 'Uyuyor';

  @override
  String get profileStatusCatLover => 'Kedi Sever';

  @override
  String get profileStatusDogWalking => 'Köpek Gezdiriyor';

  @override
  String get profileStatusGaming => 'Oyun Oynuyor';

  @override
  String get profileStatusListening => 'Dinliyor';

  @override
  String get profileEditAddress => 'Adresi Düzenle';

  @override
  String get profileRecipient => 'Alıcı';

  @override
  String get profileEnterRecipientName => 'Alıcı adını girin';

  @override
  String get profilePhoneNumber => 'Telefon Numarası';

  @override
  String get profileEnterPhoneNumber => 'Telefon numarası girin';

  @override
  String get profileRegionHint => 'İl/İlçe/Mahalle';

  @override
  String get profileDetailedAddress => 'Detaylı Adres';

  @override
  String get profileDetailedAddressHint => 'Sokak, bina numarası, vb.';

  @override
  String get profileSetAsDefaultAddress => 'Varsayılan adres olarak ayarla';

  @override
  String get profilePleaseCompleteInfo => 'Lütfen tüm alanları doldurun';

  @override
  String get profileEditInvoice => 'Faturayı Düzenle';

  @override
  String get profileInvoiceType => 'Fatura türü: ';

  @override
  String get profileCompanyName => 'Şirket Adı';

  @override
  String get profilePersonalName => 'Kişi Adı';

  @override
  String get profileEnterCompanyName => 'Şirket adı girin';

  @override
  String get profileEnterName => 'Ad girin';

  @override
  String get profileTaxIdNumber => 'Vergi Kimlik Numarası';

  @override
  String get profileEnterTaxIdNumber => 'Vergi kimlik numarası girin';

  @override
  String get profileBankNameOptional => 'Banka Adı (İsteğe bağlı)';

  @override
  String get profileEnterBankName => 'Banka adı girin';

  @override
  String get profileBankAccountOptional => 'Banka Hesabı (İsteğe bağlı)';

  @override
  String get profileEnterBankAccount => 'Banka hesabı girin';

  @override
  String get profileCompanyAddressOptional => 'Şirket Adresi (İsteğe bağlı)';

  @override
  String get profileEnterCompanyAddress => 'Şirket adresi girin';

  @override
  String get profileCompanyPhoneOptional => 'Şirket Telefonu (İsteğe bağlı)';

  @override
  String get profileEnterCompanyPhone => 'Şirket telefonu girin';

  @override
  String get profileSetAsDefaultInvoice => 'Varsayılan fatura olarak ayarla';

  @override
  String get profileRingtoneVibrate => 'Titreşim';

  @override
  String get profileRingtoneSilent => 'Sessiz';

  @override
  String get profileVibrateMode => 'Titreşim modu';

  @override
  String get profileSilentMode => 'Sessiz mod';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'Çalınamadı: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'Çalıyor: $ringtoneName';
  }

  @override
  String get profileStop => 'Durdur';

  @override
  String get profileSelectRingtone => 'Zil Sesi Seç';

  @override
  String get profileLoadingRingtones => 'Zil sesleri yükleniyor...';

  @override
  String get profileNoRingtonesFound => 'Zil sesi bulunamadı';

  @override
  String mainMessagesWithCount(int count) {
    return 'Mesajlar($count)';
  }

  @override
  String get storyViewers => 'İzleyenler';

  @override
  String get storyNoViewers => 'Henüz izleyen yok';

  @override
  String get storyReplyToStory => 'Hikayeye yanıt ver...';

  @override
  String get commonCopiedToClipboard => 'Panoya kopyalandı';

  @override
  String get commonMore => 'Daha fazla';

  @override
  String get commonTranslating => 'Çevriliyor...';

  @override
  String commonTranslatedFrom(String language) {
    return '$language dilinden çevrildi';
  }

  @override
  String get commonTranslation => 'Çeviri';

  @override
  String get commonTranslationFailed => 'Çeviri başarısız';

  @override
  String get commonAllRead => 'Tümü okundu';

  @override
  String commonReadCount(int count) {
    return '$count okundu';
  }

  @override
  String get commonYouRecalledMessage => 'Bir mesajı geri aldınız';

  @override
  String get commonMessageRecalled => 'Mesaj geri alındı';

  @override
  String get commonReEdit => 'Yeniden düzenle';

  @override
  String get commonWalletArea => 'Cüzdan alanı';

  @override
  String get callIncomingCall => 'Gelen arama';

  @override
  String get callMissedCall => 'Cevapsız arama';

  @override
  String get groupRemoveAdmin => 'Yöneticilikten Çıkar';

  @override
  String get chatSelectCurrency => 'Para birimi seç';

  @override
  String get chatSelectEmoji => 'Emoji seç';

  @override
  String get chatSelectRedPacketCover => 'Kapak seç';

  @override
  String get groupSetAsAdmin => 'Yönetici Yap';

  @override
  String get chatVideoPlaybackFailed => 'Video oynatma başarısız';

  @override
  String get groupViewProfile => 'Profili Gör';

  @override
  String get favoriteAddLinkComingSoon => 'Bağlantı ekleme özelliği yakında';

  @override
  String get favoriteNewNoteComingSoon => 'Yeni not özelliği yakında';

  @override
  String get qrcodeSaveFeatureComingSoon => 'Kaydetme özelliği yakında';

  @override
  String get qrcodeShareFeatureComingSoon => 'Paylaşım özelliği yakında';

  @override
  String qrcodeProcessFailed(String error) {
    return 'QR kod işlenemedi: $error';
  }

  @override
  String get securityDeviceIdRequired => 'Cihaz kimliği gerekli';

  @override
  String securityVerificationStartFailed(String error) {
    return 'Doğrulama başlatılamadı: $error';
  }

  @override
  String get securityVerificationFailed => 'Doğrulama başarısız oldu';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'Doğrulama başarısız oldu: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'Doğrulama reddedildi - emoji eşleşmedi';

  @override
  String get securityWaitingForDeviceAccept =>
      'Diğer cihazın kabul etmesi bekleniyor...';

  @override
  String get securityVerifyDevice => 'Bu cihazı doğrulayın';

  @override
  String get securityConfirmEmojiMatch =>
      'Aşağıdaki emojilerin her iki cihazda da aynı sırayla görüntülendiğini doğrulayın';

  @override
  String get securityEmojiDontMatch => 'Bunlar eşleşmiyor';

  @override
  String get securityEmojiMatch => 'Eşleşiyorlar';

  @override
  String get securityWaitingForDeviceConfirm =>
      'Diğer cihazın onaylaması bekleniyor...';

  @override
  String get securityVerificationSuccess => 'Doğrulama başarılı!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'Bu cihaz artık doğrulandı ve güvenilir.';

  @override
  String get securityCompareEmoji =>
      'Her iki cihazdaki emojileri karşılaştırın';

  @override
  String get securityCompareNumbers =>
      'Her iki cihazdaki sayıları karşılaştırın';

  @override
  String get commonTryAgain => 'Tekrar Deneyin';

  @override
  String get commonDone => 'Bitti';

  @override
  String get chatExportTitle => 'Sohbeti Dışa Aktar';

  @override
  String get chatExportSuccess => 'Dışa aktarma başarılı';

  @override
  String chatExportFailed(String error) {
    return 'Dışa aktarma başarısız oldu: $error';
  }

  @override
  String get chatExportFormat => 'Dışa Aktarma Formatı';

  @override
  String get chatExportHtmlDesc =>
      'Stillendirilmiş düzen ile herhangi bir tarayıcıda okunabilir';

  @override
  String get chatExportJsonDesc =>
      'Makine tarafından okunabilen yapılandırılmış veri formatı';

  @override
  String get chatExportDateRange => 'Tarih Aralığı';

  @override
  String get chatExportAll => 'Tüm Mesajlar';

  @override
  String get chatExportLastWeek => 'Son 7 Gün';

  @override
  String get chatExportLastMonth => 'Geçen Ay';

  @override
  String get chatExportLast3Months => 'Son 3 Ay';

  @override
  String get chatExportMessageCount => 'Dışa aktarılacak mesajlar';

  @override
  String get chatExportButton => 'Dışa Aktar ve Paylaş';

  @override
  String get chatMediaGallery => 'Medya Galerisi';

  @override
  String get chatExportHistory => 'Sohbet Geçmişini Dışa Aktar';

  @override
  String get pdfLoadFailed => 'PDF yüklenemedi';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'Hepsi';

  @override
  String get mediaImages => 'Görseller';

  @override
  String get mediaVideos => 'Videolar';

  @override
  String get mediaFiles => 'Dosyalar';

  @override
  String get mediaAudio => 'Ses';

  @override
  String mediaItemsCount(int count) {
    return '$count öğeleri';
  }

  @override
  String get mediaNoMediaFound => 'Medya bulunamadı';

  @override
  String get spacesTitle => 'Topluluklar';

  @override
  String get spacesCreate => 'Topluluk Oluştur';

  @override
  String get spacesJoined => 'Katıldı';

  @override
  String get spacesDiscover => 'Keşfet';

  @override
  String get spacesNoJoined => 'Henüz hiçbir topluluk katılmadı';

  @override
  String get spacesExplore => 'Toplulukları Keşfedin';

  @override
  String get spacesNoPublic => 'Herkese açık topluluk bulunamadı';

  @override
  String get spacesJoin => 'Katıl';

  @override
  String get spacesSubSpaces => 'Alt Topluluklar';

  @override
  String get spacesChannels => 'Kanallar';

  @override
  String spacesMembersCount(int count) {
    return '$count üyeleri';
  }

  @override
  String get spacesPublic => 'halka açık';

  @override
  String get spacesPrivate => 'Özel';

  @override
  String get spacesSuggested => 'Önerilen';

  @override
  String spacesChannelsCount(int count) {
    return '$count kanalları';
  }

  @override
  String get callInCallChat => 'Çağrı İçi Sohbet';

  @override
  String callMessagesCount(int count) {
    return '$count mesajları';
  }

  @override
  String get callNoMessagesYet =>
      'Henüz mesaj yok.\nBaşlamak için bir mesaj gönderin.';

  @override
  String get callTypeMessage => 'Bir mesaj yazın...';

  @override
  String get callYouSender => 'sen';

  @override
  String get callChatLabel => 'Sohbet';

  @override
  String get chatEdited => 'Düzenlendi';

  @override
  String get chatEditHistory => 'Geçmişi Düzenle';

  @override
  String get chatOriginalMessage => 'Orijinal';

  @override
  String chatEditedAt(String time) {
    return '$time adresinde düzenlendi';
  }

  @override
  String get chatViewOnce => 'Bir Kez Görüntüle';

  @override
  String get chatViewOncePhoto => 'Fotoğrafı Bir Kez Görüntüle';

  @override
  String get chatViewOnceVideo => 'Videoyu Bir Kez Görüntüle';

  @override
  String get chatViewOnceViewed => 'Görüntülendi';

  @override
  String get chatViewOnceExpired => 'Süresi dolmuş';

  @override
  String get chatViewOnceTap => 'Görüntülemek için dokunun';

  @override
  String get chatAutoFaceBlur => 'Otomatik yüz bulanıklaştırma';

  @override
  String get chatAutoFaceBlurDesc =>
      'Fotoğraf gönderirken yüzleri otomatik olarak bulanıklaştırın';

  @override
  String get threadReplyInThread => 'Konuda yanıtla';

  @override
  String threadReplies(int count) {
    return '$count yanıtları';
  }

  @override
  String get threadReply => '1 yanıt';

  @override
  String threadLatestReply(String preview) {
    return 'En son: $preview';
  }

  @override
  String get threadTitle => 'Konu';

  @override
  String get threadReplyPlaceholder => 'Konuda yanıtla...';

  @override
  String threadParticipants(int count) {
    return '$count katılımcıları';
  }

  @override
  String get voiceRoomTitle => 'Ses Odası';

  @override
  String get voiceRoomCreate => 'Ses Odası Oluştur';

  @override
  String get voiceRoomJoin => 'Katıl';

  @override
  String get voiceRoomLeave => 'Ayrıl';

  @override
  String get voiceRoomEnd => 'Son Oda';

  @override
  String get voiceRoomRaiseHand => 'Elini Kaldır';

  @override
  String get voiceRoomLowerHand => 'Alt El';

  @override
  String get voiceRoomMute => 'Sessiz';

  @override
  String get voiceRoomUnmute => 'Sesi aç';

  @override
  String get voiceRoomHost => 'Sunucu';

  @override
  String get voiceRoomSpeakers => 'Hoparlörler';

  @override
  String get voiceRoomListeners => 'Dinleyiciler';

  @override
  String get voiceRoomLive => 'CANLI';

  @override
  String get voiceRoomEnded => 'Sona erdi';

  @override
  String get voiceRoomScheduled => 'planlanmış';

  @override
  String get voiceRoomApprove => 'Onayla';

  @override
  String get voiceRoomDemote => 'Dinleyiciye Taşı';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name elini kaldırdı';
  }

  @override
  String get voiceRoomName => 'Oda adı';

  @override
  String get voiceRoomTopic => 'Konu (isteğe bağlı)';

  @override
  String get voiceRoomNoActive => 'Aktif ses odası yok';

  @override
  String get voiceRoomConnecting => 'Bağlanıyor...';

  @override
  String get usernameTitle => 'Kullanıcı adı';

  @override
  String get usernameSet => 'Kullanıcı Adını Ayarla';

  @override
  String get usernameChange => 'Kullanıcı Adını Değiştir';

  @override
  String get usernamePlaceholder => 'Kullanıcı adını girin';

  @override
  String get usernameAvailable => 'Kullanıcı adı mevcut';

  @override
  String get usernameUnavailable => 'Kullanıcı adı zaten alınmış';

  @override
  String get usernameInvalid =>
      '3-30 karakter, küçük harfler, sayılar, alt çizgi. Bir harfle başlamalıdır.';

  @override
  String get usernameReserved => 'Bu kullanıcı adı saklıdır';

  @override
  String get usernameSaved => 'Kullanıcı adı kaydedildi';

  @override
  String get usernameSearchHint => '@kullanıcı adına göre ara';

  @override
  String get ensName => 'ENS Adı';

  @override
  String get ensLinked => 'ENS\'ye bağlı';

  @override
  String get ensResolving => 'ENS\'yi çözüyor...';

  @override
  String get ensNotFound => 'ENS adı bulunamadı';

  @override
  String get tokenGateTitle => 'Jeton Kapısı';

  @override
  String get tokenGateEnable => 'Token Kapısını Etkinleştir';

  @override
  String get tokenGateDisable => 'Jeton Kapısını Devre Dışı Bırak';

  @override
  String get tokenGateAddRule => 'Kural Ekle';

  @override
  String get tokenGateRemoveRule => 'Kuralı Kaldır';

  @override
  String get tokenGateContractAddress => 'Sözleşme Adresi';

  @override
  String get tokenGateMinBalance => 'Minimum Bakiye';

  @override
  String get tokenGateTokenId => 'Belirteç Kimliği (ERC-1155)';

  @override
  String get tokenGateChainId => 'Zincir Kimliği';

  @override
  String get tokenGateVerifying => 'Token stokları doğrulanıyor...';

  @override
  String get tokenGateVerified => 'Doğrulama başarılı oldu';

  @override
  String get tokenGateDenied => 'Jeton gereksinimlerini karşılamıyorsunuz';

  @override
  String get tokenGateOperatorAnd => 'TÜM kurallara uymalı';

  @override
  String get tokenGateOperatorOr => 'HERHANGİ bir kurala uymalı';

  @override
  String get tokenGateRuleErc20 => 'ERC-20 Jetonu';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'Çoklu Token (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'Yerel Jeton';

  @override
  String get tokenGateSaved => 'Jeton kapısı kaydedildi';

  @override
  String get tokenGateEnableDescription =>
      'Üyelerin katılmak için jeton tutmasını zorunlu kılın';

  @override
  String get tokenGateOperator => 'Kural Mantığı';

  @override
  String get tokenGateRules => 'Kurallar';

  @override
  String get tokenGateSymbol => 'Sembol (isteğe bağlı)';

  @override
  String get tokenGateChain => 'Zincir';

  @override
  String get tokenGateTokenStandard => 'Jeton Standardı';

  @override
  String get tokenGateDenialMessage => 'Reddetme Mesajı';

  @override
  String get tokenGateDenialMessageHint =>
      'Doğrulama başarısız olduğunda gösterilen mesaj';

  @override
  String get tokenGateVerifyTitle => 'Jeton Doğrulaması';

  @override
  String get tokenGateVerifyPassed => 'Doğrulama Geçildi';

  @override
  String get tokenGateVerifyFailed => 'Doğrulama Başarısız';

  @override
  String get tokenGateRetryVerify => 'Yeniden dene';

  @override
  String get tokenGateRequired => 'Gerekli';

  @override
  String get tokenGateYourBalance => 'Bakiyeniz';

  @override
  String get tokenGateRulesActive => 'kurallar aktif';

  @override
  String get tokenGateDisabled => 'Devre dışı';

  @override
  String get ensNotBound => 'Bağlı değil';

  @override
  String get liveLocation => 'Canlı Konum';

  @override
  String get stopLiveLocation => 'Paylaşımı Durdur';

  @override
  String get startLiveLocation => 'Paylaşmaya Başla';

  @override
  String get selectDuration => 'Süreyi Seçin';

  @override
  String get groupChatFiles => 'Sohbet Dosyaları';

  @override
  String get groupLinks => 'Bağlantılar';

  @override
  String get groupNoLinks => 'Henüz bağlantı yok';

  @override
  String get chatBackground => 'Sohbet Arka Planı';

  @override
  String get solidColors => 'Katı Renkler';

  @override
  String get gradients => 'Degradeler';

  @override
  String get defaultBackground => 'Varsayılan';

  @override
  String get settingsFontSizeSlider => 'Yazı Tipi Boyutu';

  @override
  String get autoDownload => 'Otomatik İndirme';

  @override
  String get images => 'Görseller';

  @override
  String get voice => 'Ses';

  @override
  String get video => 'video';

  @override
  String get files => 'Dosyalar';

  @override
  String get mobileData => 'Mobil Veri';

  @override
  String get roaming => 'Dolaşım';

  @override
  String get storageManagement => 'Depolama';

  @override
  String get totalUsage => 'Toplam Kullanım';

  @override
  String get cache => 'Önbellek';

  @override
  String get other => 'Diğer';

  @override
  String get clearCache => 'Önbelleği Temizle';

  @override
  String get cacheCleared => 'Önbellek temizlendi';

  @override
  String get clearCacheFailed => 'Önbellek temizlenemedi';

  @override
  String get confirmClearCache => 'Tüm önbellek verileri temizlensin mi?';

  @override
  String get mapView => 'Harita Görünümü';

  @override
  String liveLocationSharingCount(int count) {
    return '$count konum paylaşan kişiler';
  }

  @override
  String get minutes15 => '15 dakika';

  @override
  String get minutes30 => '30 dakika';

  @override
  String get hour1 => '1 saat';

  @override
  String get hours8 => '8 saat';

  @override
  String get personalCard => 'Kişisel Kart';

  @override
  String get downloadFailed => 'İndirme başarısız oldu';

  @override
  String get locationExpired => 'Süresi dolmuş';

  @override
  String secondsRemaining(int count) {
    return '$count\'lar';
  }

  @override
  String minutesRemaining(int count) {
    return '$count dakika';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours saat $minutes dakika';
  }

  @override
  String get favoriteMessages => 'Favoriler';

  @override
  String get linksCopied => 'Bağlantı kopyalandı';

  @override
  String get noLinksFound => 'Bağlantı bulunamadı';

  @override
  String get roomStorageRanking => 'Oda Depolama Sıralaması';

  @override
  String get downloadComplete => 'İndirme tamamlandı';

  @override
  String get downloading => 'İndiriliyor...';

  @override
  String get draftSaved => 'Taslak kaydedildi';

  @override
  String get voiceRecording => 'Ses Kaydı';

  @override
  String get searchLocation => 'Konum Ara';

  @override
  String get tapToSearch => 'Aramak için dokunun';

  @override
  String get settingsThisDevice => 'Bu cihaz';

  @override
  String get settingsJustNow => 'Az önce';

  @override
  String get settingsDeviceId => 'Cihaz Kimliği';

  @override
  String get settingsStatus => 'Durum';

  @override
  String get settingsLastActive => 'Son aktif';

  @override
  String get settingsIpAddress => 'IP adresi';

  @override
  String get settingsRenameDevice => 'Cihazı yeniden adlandır';

  @override
  String get settingsDeviceNameHint => 'Cihaz adını girin';

  @override
  String get settingsDeviceRenamed => 'Cihaz yeniden adlandırıldı';

  @override
  String get settingsRenameFailed => 'Yeniden adlandırma başarısız oldu';

  @override
  String get settingsRemoteLogout => 'Uzaktan oturum kapatma';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return '\"$deviceName\" oturumunu kapatmak istediğinizden emin misiniz? Bu eylem geri alınamaz.';
  }

  @override
  String get settingsDeviceLoggedOut => 'Cihaz oturumu kapatıldı';

  @override
  String get settingsLogoutFailed => 'Oturum kapatılamadı';

  @override
  String get settingsLogout => 'Oturumu kapat';

  @override
  String get settingsVerifyIdentity => 'Kimliği doğrulayın';

  @override
  String get settingsEnterPasswordToConfirm =>
      'Bu işlemi onaylamak için şifrenizi girin.';

  @override
  String get scheduledSendTitle => 'Mesajı planla';

  @override
  String get scheduledSendInOneHour => '1 saat içinde';

  @override
  String get scheduledSendTonight => 'Bu gece (20:00)';

  @override
  String get scheduledSendTomorrowMorning => 'Yarın sabah (09:00)';

  @override
  String get scheduledSendCustom => 'Bir tarih ve saat seçin';

  @override
  String get scheduledMessageLabel => 'planlanmış';

  @override
  String get scheduledMessageCancel => 'Planlanan mesajı iptal et';

  @override
  String get chatLockTitle => 'Sohbet kilidi';

  @override
  String get chatLockEnable => 'Bu sohbeti kilitle';

  @override
  String get chatLockDisable => 'Bu sohbetin kilidini aç';

  @override
  String get chatLockDescription =>
      'Kilitli sohbetlerin açılması için biyometrik veya PIN doğrulaması gerekir';

  @override
  String get chatLockVerifyTitle => 'Sohbet kilitlendi';

  @override
  String get chatLockVerifySubtitle => 'Bu sohbete erişmek için doğrulayın';

  @override
  String get chatLockVerifyFailed => 'Doğrulama başarısız oldu';

  @override
  String get chatLockEnabled => 'Sohbet kilitlendi';

  @override
  String get chatLockDisabled => 'Sohbetin kilidi açıldı';

  @override
  String get chatLockPinTitle => 'PIN\'i girin';

  @override
  String get chatLockPinSetTitle => 'PIN\'i ayarla';

  @override
  String get chatLockPinConfirmTitle => 'PIN\'i onayla';

  @override
  String get chatLockPinMismatch => 'PIN eşleşmiyor';

  @override
  String get chatLockUseBiometric => 'Biyometrik kullan';

  @override
  String get chatLockUsePin => 'PIN\'i kullan';

  @override
  String get mediaEditorUndo => 'Geri al';

  @override
  String get mediaEditorRedo => 'Yinele';

  @override
  String get mediaEditorCrop => 'Kırpma';

  @override
  String get mediaEditorFilter => 'Filtre';

  @override
  String get mediaEditorDraw => 'Beraberlik';

  @override
  String get mediaEditorText => 'Metin';

  @override
  String get aiAssistant => 'Yapay Zeka Asistanı';

  @override
  String get aiAssistantWelcome =>
      'Merhaba! Ben N42 Yapay Zeka Asistanıyım. Size nasıl yardım edebilirim?';

  @override
  String get aiAssistantNotConfigured => 'AI hizmeti yapılandırılmadı';

  @override
  String get aiAssistantSettings => 'Yapay Zeka Ayarları';

  @override
  String get aiAssistantClearHistory => 'Sohbet geçmişini temizle';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'Tüm AI sohbet geçmişini temizlemek istediğinizden emin misiniz?';

  @override
  String get aiAssistantStopGenerating => 'Oluşturmayı durdur';

  @override
  String get aiAssistantModel => 'Modeli';

  @override
  String get aiAssistantTemperature => 'Sıcaklık';

  @override
  String get aiAssistantMaxTokens => 'Maksimum jeton';

  @override
  String get aiAssistantContextWindow => 'Bağlam penceresi';

  @override
  String get aiAssistantServiceStatus => 'Hizmet durumu';

  @override
  String get aiAssistantAvailable => 'Mevcut';

  @override
  String get aiAssistantUnavailable => 'Kullanılamıyor';

  @override
  String get aiSummarize => 'Yapay Zeka Özeti';

  @override
  String aiSummarizeUnread(int count) {
    return '$count okunmamış iletileri özetle';
  }

  @override
  String get aiSummarizeLoading => 'Özetleniyor...';

  @override
  String get aiSummarizeError => 'Özetlenemedi';

  @override
  String get aiRewrite => 'Yapay Zeka Yeniden Yazma';

  @override
  String get aiRewriteFormal => 'Resmi';

  @override
  String get aiRewriteCasual => 'gündelik';

  @override
  String get aiRewritePlayful => 'Şakacı';

  @override
  String get aiRewriteProfessional => 'Profesyonel';

  @override
  String get aiRewriteAccept => 'Kullanım';

  @override
  String get aiRewriteCancel => 'İptal';

  @override
  String get aiRewriteLoading => 'Yeniden yazılıyor...';

  @override
  String get aiLinkSummary => 'Yapay Zeka Özeti';

  @override
  String get aiLinkSummaryAnalyzing => 'Analiz ediliyor...';

  @override
  String get chatFolderManagement => 'Klasörleri Yönet';

  @override
  String get chatFolderSystem => 'Sistem Klasörleri';

  @override
  String get chatFolderCustom => 'Özel Klasörler';

  @override
  String get chatFolderEmpty => 'Henüz özel klasör yok';

  @override
  String get chatFolderCreate => 'Klasör Oluştur';

  @override
  String get chatFolderEdit => 'Klasörü Düzenle';

  @override
  String get chatFolderNameHint => 'Klasör adı';

  @override
  String get chatFolderAll => 'Hepsi';

  @override
  String get chatFolderUnread => 'Okunmamış';

  @override
  String get chatFolderPersonal => 'Kişisel';

  @override
  String get chatFolderGroups => 'Gruplar';

  @override
  String get chatFolderChannels => 'Kanallar';

  @override
  String get chatFolderMuted => 'Sessize alındı';

  @override
  String get storyAddMusic => 'Müzik Ekle';

  @override
  String get storyChangeMusic => 'Müziği Değiştir';

  @override
  String get storyBackgroundMusic => 'Fon Müziği';

  @override
  String get storyMusicPreview => 'Önizleme (en fazla 15 saniye)';

  @override
  String get storyChooseFromDevice => 'Cihaz arasından seçim yapın';

  @override
  String get storyUseThisMusic => 'Bu Müziği Kullan';

  @override
  String get authPasskeyNotSupported =>
      'Şifre anahtarı bu cihazda desteklenmiyor';

  @override
  String get authPasskeyRegister => 'Şifre Anahtarını Kaydet';

  @override
  String get authPasskeyNoRegistered => 'Kayıtlı şifre anahtarı yok';

  @override
  String get authPasskeyRegisterHint =>
      'Bu hesap için bir şifre kaydedin. Bağımsız şifre anahtarıyla oturum açma daha sonra etkinleştirilecektir.';

  @override
  String get authPasskeyNameYours => 'Parolanızı adlandırın';

  @override
  String get authPasskeyRegistered => 'Şifre anahtarı bu hesaba kaydedildi';

  @override
  String get authPasskeyDeleted => 'Şifre anahtarı bu hesaptan kaldırıldı';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return '\"$name\" şifre anahtarı silinsin mi? Daha sonra şifreyle oturum açmayı kullanmadan önce tekrar kaydetmeniz gerekecektir.';
  }

  @override
  String get momentVisibilityPublic => 'halka açık';

  @override
  String get momentVisibilityPrivate => 'Özel';

  @override
  String get momentVisibilityPartial => 'Seçilen Arkadaşlar';

  @override
  String get momentVisibilityExcluded => 'Bazı Arkadaşları Hariç Tut';

  @override
  String momentUserMoments(String userName) {
    return '$userName\'nun Anları';
  }

  @override
  String get momentForwardTo => 'Şuraya ilet:';

  @override
  String get momentForwardSuccess => 'Başarıyla iletildi';

  @override
  String get momentSelectFriends => 'Arkadaşları Seç';

  @override
  String get momentSelectTags => 'Etiketlere göre seç';

  @override
  String momentSelectedCount(int count) {
    return 'Seçildi ($count)';
  }

  @override
  String get momentNoMomentsYet => 'Henüz an yok';

  @override
  String get momentForwardMoment => 'İleri An';

  @override
  String get momentAddComment => 'Yorum ekleyin...';

  @override
  String momentForwardContent(String content) {
    return '[An] $content';
  }

  @override
  String get momentDeleteMoment => 'Anı Sil';

  @override
  String get momentDeleteConfirm =>
      'Bu anı silmek istediğinizden emin misiniz?';

  @override
  String get momentComment => 'Yorum';

  @override
  String get momentWriteComment => 'Bir yorum yazın...';

  @override
  String get momentLike => 'Beğen';

  @override
  String get momentUnlike => 'aksine';

  @override
  String get momentForward => 'İleri';

  @override
  String get momentDelete => 'Sil';

  @override
  String get momentReply => 'cevapla';

  @override
  String get momentMoment => 'An';

  @override
  String momentLikesCount(int count) {
    return '$count beğenmeler';
  }

  @override
  String momentCommentsCount(int count) {
    return '$count yorumlar';
  }

  @override
  String get momentNoComments => 'Henüz yorum yok';

  @override
  String get momentFailedToLoad => 'Resim yüklenemedi';

  @override
  String momentReplyTo(String userName) {
    return '$userName\'ya yanıt ver...';
  }

  @override
  String get momentNoConversations => 'Konuşma yok';

  @override
  String get momentJustNow => 'şimdi';

  @override
  String momentMinutesAgo(int count) {
    return '$count dk önce';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h önce';
  }

  @override
  String momentDaysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get chatGroupAnnouncementHint => 'Grup duyurusunu girin';

  @override
  String get chatGroupAnnouncementEmpty => 'Duyuru yok';

  @override
  String get chatEditNickname => 'Takma Adı Düzenle';

  @override
  String get chatNicknameHint => 'Bu gruba takma adınızı girin';

  @override
  String get contactAddPhoneHint => 'Telefon numarasını girin';

  @override
  String get contactNotesHint => 'Bu kişi hakkında not ekleyin';

  @override
  String get reportTitle => 'Rapor';

  @override
  String get reportReasonSpam => 'İstenmeyen e-posta';

  @override
  String get reportReasonHarassment => 'Taciz';

  @override
  String get reportReasonFraud => 'Dolandırıcılık';

  @override
  String get reportReasonOther => 'Diğer';

  @override
  String get reportSubmitted => 'Rapor gönderildi';

  @override
  String get reportDescription => 'Ek açıklama (isteğe bağlı)';

  @override
  String get qrcodeSaved => 'QR kodu albüme kaydedildi';

  @override
  String get chatSendRedPacketInChat =>
      'Lütfen sohbette kırmızı paket gönderin';

  @override
  String get commonSaveFailed => 'Kaydetme başarısız oldu';

  @override
  String get reportSelectReason => 'Lütfen bir neden seçin';

  @override
  String get gameCenter => 'Oyunlar';

  @override
  String get gameHighScore => 'En İyi';

  @override
  String get gameScore => 'Puan';

  @override
  String get gameOver => 'Oyun Bitti';

  @override
  String get gamePlayAgain => 'Tekrar Oyna';

  @override
  String get gameLeaderboard => 'Sıralama';

  @override
  String get gamePause => 'Duraklatıldı';

  @override
  String get gameResume => 'Devam etmek için dokun';

  @override
  String get gameConfirmExit => 'Oyundan çıkmak istiyor musunuz?';

  @override
  String get gameNoScores => 'Henüz skor yok';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'Karoları birleştirerek 2048\'e ulaşın';

  @override
  String get gameBlockDrop => 'Blok Düşürme';

  @override
  String get gameBlockDropDesc => 'Blokları düşürüp satırları temizleyin';

  @override
  String get gameMinesweeper => 'Mayın Tarlası';

  @override
  String get gameMinesweeperDesc => 'Tüm güvenli hücreleri bulun';

  @override
  String get gameMatch3 => '3. maç';

  @override
  String get gameMatch3Desc => '3 veya daha fazla taşı eşleştirin';

  @override
  String get gameMinesweeperEasy => 'Kolay';

  @override
  String get gameMinesweeperMedium => 'Orta';

  @override
  String get gameMinesLeft => 'Kalan Mayın';

  @override
  String get gameTimeLeft => 'Süre';

  @override
  String get gameLevel => 'Seviye';

  @override
  String get gameNext => 'Sonraki';

  @override
  String get gameBestTime => 'En İyi Süre';

  @override
  String get gameNewRecord => 'Yeni Rekor!';

  @override
  String get gameLines => 'Satır';

  @override
  String get storyMyStory => 'Hikayem';

  @override
  String get storageSmartCleanup => 'Akıllı Temizleme';

  @override
  String get storageOldMediaFiles => 'Eski Medya Dosyaları';

  @override
  String get storageLargeFiles => 'Büyük Dosyalar';

  @override
  String get storageAppCache => 'Uygulama Önbelleği';

  @override
  String get storageSettings => 'Depolama Ayarları';

  @override
  String get storageAutoCleanup => 'Otomatik Temizleme';

  @override
  String storageAutoCleanupDesc(int days) {
    return '$days günden daha eski dosyaları otomatik olarak temizle';
  }

  @override
  String get storageCleanupPeriod => 'Temizleme Dönemi';

  @override
  String get storagePreserveThumbnails => 'Küçük Resimleri Koru';

  @override
  String get storagePreserveThumbnailsDesc =>
      'Temizleme sırasında görsel küçük resimlerini koruyun';

  @override
  String get storageWarningHigh =>
      'Depolama kullanımı yüksektir. Eski dosyaları temizlemeyi düşünün.';

  @override
  String get storageWarningCritical =>
      'Depolama kritik derecede düşük. Lütfen boş alana kadar temizleyin.';

  @override
  String storageFreed(String size, int count) {
    return 'Serbest bırakılan $size ($count dosyaları)';
  }

  @override
  String storageDays(int days) {
    return '$days gün';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'Tüm $count odalarını görüntüleyin';
  }

  @override
  String get storageNoFiles => 'Hiçbir dosya bulunamadı';

  @override
  String get storageFilePinned => 'Sabitlendi';

  @override
  String storageDeleteSelected(int count) {
    return '$count seçilen dosyalar silinsin mi? Sunucudan yeniden indirilebilirler.';
  }

  @override
  String get backupRestore => 'Yedekleme ve Geri Yükleme';

  @override
  String get backupCreate => 'Yedekleme Oluştur';

  @override
  String get backupCreateDesc =>
      'Ayarlarınızı ve şifreleme anahtarlarınızı yedekleyin. Yeniden giriş yaptıktan sonra mesajlar sunucudan geri yüklenecektir.';

  @override
  String get backupIncludeKeys => 'Şifreleme anahtarlarını dahil et';

  @override
  String get backupIncludeKeysDesc =>
      'Şifrelenmiş mesajları okumak için gereklidir';

  @override
  String get backupPasswordProtect => 'Şifre koruması';

  @override
  String get backupEnterPassword => 'Yedekleme şifresini girin';

  @override
  String get backupHistory => 'Yedekleme Geçmişi';

  @override
  String get backupNoBackups => 'Henüz yedekleme yok';

  @override
  String get backupRestore2 => 'Geri yükle';

  @override
  String get backupDelete => 'Sil';

  @override
  String get backupDeleteConfirm =>
      'Bu yedeği silmek istediğinizden emin misiniz? Bu geri alınamaz.';

  @override
  String get backupRestoreFromFile => 'Dosyadan Geri Yükle';

  @override
  String get backupRestoreFromFileDesc =>
      'Başka bir cihazdan veya önceki yedeklemeden bir .n42backup dosyasını içe aktarın.';

  @override
  String get backupChooseFile => 'Yedekleme Dosyasını Seçin';

  @override
  String get backupRestoring => 'Geri yükleniyor...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'Yedekleme oluşturuldu: $rooms odaları, $messages mesajları';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return '$rooms odalarından $settings ayarları geri yüklendi';
  }

  @override
  String backupFailed(String error) {
    return 'Yedekleme başarısız oldu: $error';
  }

  @override
  String get backupPasswordRequired => 'Bu yedekleme şifre korumalıdır';

  @override
  String get blocGroupNotFound => 'Grup bulunamadı';

  @override
  String blocGroupMembersInvited(int count) {
    return 'Davet edilen $count üye(ler)i';
  }

  @override
  String get blocGroupMemberRemoved => 'Üye kaldırıldı';

  @override
  String get blocGroupAdminRemoved => 'Yönetici kaldırıldı';

  @override
  String get blocGroupLeft => 'Gruptan ayrıldı';

  @override
  String get blocGroupDisbanded => 'Grup dağıldı';

  @override
  String get blocGroupJoined => 'Gruba katıldı';

  @override
  String get blocGroupInviteDeclined => 'Davet reddedildi';

  @override
  String get blocGroupTokenGateUpdated => 'Jeton kapısı güncellendi';

  @override
  String get blocTransferProcessing => 'Aktarım işleniyor...';

  @override
  String get blocTransferCancelled => 'Aktarım iptal edildi';

  @override
  String get blocTransferFailed => 'Aktarım başarısız oldu';

  @override
  String get blocPaymentProcessing => 'Ödeme işleniyor...';

  @override
  String get blocPaymentFailed => 'Ödeme başarısız oldu';

  @override
  String get groupMaxMembers => 'Üye Limiti';

  @override
  String get groupMaxMembersUnlimited => 'Sınırsız';

  @override
  String get groupMaxMembersHint =>
      'Limiti girin (sınırsız olması için boş bırakın)';

  @override
  String get groupMaxMembersUpdated => 'Üye sınırı güncellendi';

  @override
  String get groupFull => 'Grup kapasitesi dolmuştur';

  @override
  String get groupChannels => 'Konu Kanalları';

  @override
  String get groupChannelsEmpty => 'Henüz kanal yok';

  @override
  String get groupChannelsCount => 'kanallar';

  @override
  String get groupChannelCreate => 'Yeni Kanal';

  @override
  String get groupChannelName => 'Kanal Adı';

  @override
  String get groupChannelTopic => 'Kanal Konusu (isteğe bağlı)';

  @override
  String get groupChannelDelete => 'Kanalı Sil';

  @override
  String get groupChannelDeleteConfirm =>
      'Bu kanal silinsin mi? Tüm mesajlar kaybolacak.';

  @override
  String get groupBotSettings => 'Bot Ayarları';

  @override
  String get groupBotEnabled => 'Botu Etkinleştir';

  @override
  String get groupBotWelcomeMessage => 'Hoş Geldiniz Mesajı Şablonu';

  @override
  String get groupBotWelcomeHint =>
      'Yeni üye adı için yer tutucu olarak \'ad\'ı kullanın';

  @override
  String get groupBotConfigUpdated => 'Bot ayarları güncellendi';

  @override
  String get groupContentFilter => 'İçerik Filtresi';

  @override
  String get groupContentFilterEnabled =>
      'Anahtar Kelime Filtresini Etkinleştir';

  @override
  String get groupContentFilterReplace => '*** ile değiştirin';

  @override
  String get groupContentFilterHide => 'Mesajı Gizle';

  @override
  String get groupContentFilterAddWord => 'Anahtar Kelime Ekle';

  @override
  String get groupContentFilterUpdated => 'İçerik filtresi güncellendi';

  @override
  String get chatSlashCommands => 'Komutlar';

  @override
  String get chatCommandPoll => '/poll — Anket oluşturur';

  @override
  String get chatCommandAnnounce => '/announce — Duyuru gönder';

  @override
  String get chatCommandWelcome => '/welcome — Hoş geldiniz mesajını ayarlayın';

  @override
  String get chatReportMessage => 'Rapor';

  @override
  String get chatReportReason => 'Rapor Nedeni';

  @override
  String get chatReportSpam => 'İstenmeyen e-posta';

  @override
  String get chatReportHarassment => 'Taciz';

  @override
  String get chatReportInappropriate => 'Uygunsuz İçerik';

  @override
  String get chatReportOther => 'Diğer';

  @override
  String get chatReportSuccess => 'Rapor gönderildi';

  @override
  String get spacesName => 'Topluluk Adı';

  @override
  String get spacesNameHint => 'örneğin Kripto Yatırımcıları';

  @override
  String get spacesNameRequired => 'Ad gerekli';

  @override
  String get spacesDescription => 'Açıklama';

  @override
  String get spacesDescriptionHint => 'Bu topluluk neyle ilgili?';

  @override
  String get spacesType => 'Topluluk Türü';

  @override
  String get spacesPublicDesc => 'Herkes keşfedebilir ve katılabilir';

  @override
  String get spacesPrivateDesc => 'Yalnızca davet edilen üyeler katılabilir';

  @override
  String get spacesNotFound => 'Topluluk bulunamadı';

  @override
  String get spacesSearch => 'Topluluklarda ara...';

  @override
  String get spacesMembers => 'Üyeler';

  @override
  String get spacesNoChannels => 'Henüz kanal yok';

  @override
  String get spacesLeave => 'Topluluktan Ayrıl';

  @override
  String spacesLeaveConfirm(String name) {
    return '\"$name\"dan ayrılmak istediğinizden emin misiniz?';
  }

  @override
  String get spacesDelete => 'Topluluğu Sil';

  @override
  String spacesDeleteConfirm(String name) {
    return 'Bu, \"$name\" ve tüm kanallarını kalıcı olarak silecektir. Bu eylem geri alınamaz.';
  }

  @override
  String get spacesCreateChannel => 'Kanal Ekle';

  @override
  String get spacesChannelName => 'Kanal Adı';

  @override
  String get spacesChannelTopic => 'Konu (isteğe bağlı)';

  @override
  String get spacesDeleteChannel => 'Kanalı Sil';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return '\"#$name\" ifadesini silmek istediğinizden emin misiniz?';
  }

  @override
  String get spacesEditName => 'Adı Düzenle';

  @override
  String get spacesEditDescription => 'Açıklamayı Düzenle';

  @override
  String spacesViewAllMembers(int count) {
    return 'Tüm $count üyelerini görüntüle';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return '$name\'yu tekmele';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return '$name\'yu yasakla';
  }

  @override
  String get spacesPromoteAdmin => 'Yöneticiliğe Yükselt';

  @override
  String get spacesDemoteAdmin => 'Yöneticiyi Kaldır';

  @override
  String get spacesInviteMember => 'Üyeyi Davet Et';

  @override
  String get spacesInviteMemberUserId =>
      'Kullanıcı Kimliği (ör. @user:server.com)';

  @override
  String get spacesSave => 'Kaydet';

  @override
  String get settingsScreenshotProtection => 'Ekran Görüntüsü Koruması';

  @override
  String get settingsScreenshotProtectionDesc =>
      'Ekran görüntülerini ve ekran kaydını önleyin';

  @override
  String get chatSelfDestructTimer => 'Kendini imha etme';

  @override
  String get chatTimerPickerTitle => 'Kendini İmha Etme Zamanlayıcısı';

  @override
  String get chatTimerOff => 'Kapalı';

  @override
  String get onChainNotificationsTitle => 'Zincir Üstü Olaylar';

  @override
  String get onChainMarkAllRead => 'Tümünü okundu işaretle';

  @override
  String get onChainNoNotifications => 'Henüz zincir üstü olay yok';

  @override
  String get onChainNoNotificationsDesc =>
      'Abone olunan kanallardan olaylar burada görünecek';

  @override
  String get onChainViewDetails => 'Ayrıntıları gör';

  @override
  String get chatCommandHelp => '/help — Tüm komutları göster';

  @override
  String get chatCommandPrice => '/price — Token fiyatını al';

  @override
  String get chatCommandBalance => '/balance — Cüzdan bakiyesini göster';

  @override
  String get chatCommandChains => '/chains — 236+ desteklenen ağı listele';

  @override
  String get chatMiniApps => 'Uygulamalar';

  @override
  String get miniAppMarketTitle => 'Mini Uygulamalar';

  @override
  String get miniAppCategoryAll => 'Tümü';

  @override
  String get miniAppSearch => 'Uygulama ara...';

  @override
  String get miniAppFeatured => 'Öne Çıkanlar';

  @override
  String get miniAppAllApps => 'Tüm Uygulamalar';

  @override
  String get miniAppNoResults => 'Uygulama bulunamadı';

  @override
  String get slideToPayLabel => '→→→  Onaylamak için kaydırın';

  @override
  String get slideToPayConfirming => 'Onaylanıyor...';

  @override
  String get redPacketBestLuck => 'En iyi şans';

  @override
  String get redPacketBestLuckCongrats => 'En iyi şans! En çok siz aldınız!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total talep edildi';
  }

  @override
  String get redPacketStatsTotal => 'toplam';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 Kırmızı zarf aldı • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id  •  0x adres  •  name.eth';

  @override
  String get web3SearchPlaceholder => 'ID, cüzdan veya ENS ile ara...';

  @override
  String get web3WalletAddress => 'Cüzdan adresi';

  @override
  String get web3AddressCopied => 'Adres kopyalandı';

  @override
  String get web3Copy => 'Kopyala';

  @override
  String get web3SendMessage => 'Mesaj gönder';

  @override
  String get web3SendToWallet => 'Cüzdana mesaj';

  @override
  String get web3WalletOnlyHint =>
      'Bu adresin N42 hesabı yok. Katıldıklarında mesaj iletilecek.';

  @override
  String get web3NftAvatar => 'NFT Avatarı';

  @override
  String get web3ResolveFailed => 'Kimlik çözümlenemedi';

  @override
  String web3EnsNotFound(String name) {
    return 'ENS adı \"$name\" bulunamadı';
  }

  @override
  String get web3NoN42AccountTitle => 'N42 hesabı yok';

  @override
  String get web3NoN42AccountDesc =>
      'Bu cüzdan adresinin henüz bir N42 hesabı yok. Başlamak için N42 davet bağlantınızı onlarla paylaşabilirsiniz.';

  @override
  String get web3ShareInvite => 'Daveti paylaş';

  @override
  String get nftPickerTitle => 'NFT avatar seç';

  @override
  String get nftPickerTabPopular => 'Popüler';

  @override
  String get nftPickerTabCustom => 'Özel';

  @override
  String get nftPickerChain => 'Zincir';

  @override
  String get nftPickerContract => 'Sözleşme Adresi';

  @override
  String get nftPickerTokenId => 'Jeton Kimliği';

  @override
  String get nftPickerVerifyOwnership => 'Sahipliği doğrula ve önizle';

  @override
  String get nftPickerUseAsAvatar => 'Avatar olarak kullan';

  @override
  String get nftPickerPreview => 'Önizleme';

  @override
  String get nftPickerNotOwned => 'Bu NFT\'ye sahip değilsiniz';

  @override
  String get nftPickerInvalidTokenId => 'Geçersiz belirteç kimliği';

  @override
  String get nftPickerEnterBoth => 'Sözleşme adresini ve jeton kimliğini girin';

  @override
  String get nftPickerInfoTitle => 'NFT Avatar — Zincir Üzeri Doğrulama';

  @override
  String get nftPickerInfoDesc =>
      'Sahip olduğunuz bir NFT\'yi avatarınız olarak bağlayın. Herkes zincirdeki sahipliği doğrulayabilir. N42 boyunca altın bir yüzükle görüntülenir.';

  @override
  String get nftPickerPopularCollections => 'Popüler koleksiyonlar';

  @override
  String get nftPickerWalletHint =>
      'N42 cüzdanınızı bağlayarak 236+ zincirde NFT\'lerinizi otomatik keşfedin.';

  @override
  String get profileBindNftAvatar => 'NFT Avatarını Bağla';

  @override
  String get profileChangeAvatar => 'Avatarı Değiştir';

  @override
  String get groupTopics => 'Konular';

  @override
  String get groupTopicsEmpty => 'Henüz konu yok';

  @override
  String get syncInProgress => 'Mesaj geçmişi senkronize ediliyor...';

  @override
  String get recoveryKeyReminderTitle => 'Mesajlarınızı koruyun';

  @override
  String get recoveryKeyReminderDesc =>
      'Şifrelenmiş mesajları cihazlar arasında güvenli bir şekilde senkronize etmek için bir kurtarma anahtarı oluşturun';

  @override
  String get recoveryKeySetupNow => 'Şimdi ayarla';

  @override
  String get recoveryKeyRemindLater => 'Daha sonra hatırlat';

  @override
  String get channelReadOnly =>
      'Bu kanalda yalnızca yöneticiler paylaşım yapabilir';

  @override
  String get channelSubscribers => 'aboneler';

  @override
  String get channelVerified => 'Doğrulanmış kanal';

  @override
  String get redPacketHistory => 'Kırmızı Paket Geçmişi';

  @override
  String get redPacketSent => 'Gönderildi';

  @override
  String get redPacketReceived => 'Alındı';

  @override
  String get redPacketExpired => 'Süresi dolmuş';

  @override
  String get redPacketClaimed => 'Hak talebinde bulunuldu';

  @override
  String get redPacketInsufficientBalance => 'Yetersiz bakiye';

  @override
  String selfDestructCountdown(String time) {
    return '$time\'da kendi kendini imha etme';
  }

  @override
  String get messageDestroyed => 'Mesaj yok edildi';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'İzin reddedildi: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'Gaz ücreti nedir?';

  @override
  String get aiSuggestionDefi => 'DeFi Başlangıç Kılavuzu';

  @override
  String get aiSuggestionSecurity => 'Sözleşme güvenliği nasıl kontrol edilir';

  @override
  String get aiSuggestionBridge => 'Çapraz zincir köprüleme';

  @override
  String get channelDiscoverTitle => 'Kanalları Keşfedin';

  @override
  String get channelDiscoverSearch => 'Kanal ara...';

  @override
  String get channelJoin => 'Katıl';

  @override
  String get channelJoined => 'Katıldı';

  @override
  String get channelCategory => 'Kategori';

  @override
  String slowModeCooldown(int seconds) {
    return 'Yavaş mod: bekleyin ${seconds}s';
  }

  @override
  String get addressCopyAction => 'Adresi Kopyala';

  @override
  String get addressSendMessage => 'Mesaj Gönder';

  @override
  String get addressViewProfile => 'Profili Görüntüle';

  @override
  String get sendToAddress => 'Cüzdan adresine gönder';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'Doğrulama kodu gönderilemedi';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'Bu sunucu e-posta şifre sıfırlamayı desteklemiyor';

  @override
  String get blocAuthResetPasswordFailed => 'Şifre sıfırlanamadı';

  @override
  String get blocAuthChangePasswordFailed => 'Şifre değiştirilemedi';

  @override
  String get blocAuthOldPasswordWrong => 'Yanlış mevcut şifre';

  @override
  String get blocAuthLoginCancelled => 'Giriş iptal edildi';

  @override
  String get blocAuthGoogleLoginFailed => 'Google girişi başarısız oldu';

  @override
  String get blocAuthAppleLoginFailed => 'Apple\'a giriş başarısız oldu';

  @override
  String get blocAuthSsoLoginFailed => 'TOA girişi başarısız oldu';

  @override
  String get blocAuthFacebookLoginFailed => 'Facebook\'a giriş başarısız oldu';

  @override
  String get blocAuthTwitterLoginFailed => 'Twitter\'a giriş başarısız oldu';

  @override
  String get blocAuthWeChatLoginFailed => 'WeChat\'e giriş başarısız oldu';

  @override
  String get blocAuthWeChatNotConfigured => 'WeChat girişi yapılandırılmadı';

  @override
  String get blocAuthWeChatNotInstalled => 'Lütfen önce WeChat\'i yükleyin';

  @override
  String get blocAuthPasswordWrong => 'Yanlış şifre';

  @override
  String get blocAuthEmailAlreadyBound =>
      'Bu e-posta zaten başka bir hesaba bağlı';

  @override
  String get blocAuthChangeEmailFailed => 'E-posta değiştirilemedi';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'Doğrulama kodu yanlış veya süresi dolmuş';

  @override
  String get blocAuthSessionExpired =>
      'Oturumun süresi doldu, lütfen tekrar giriş yapın';

  @override
  String get blocAuthSessionIncomplete =>
      'Oturum verileri eksik, lütfen tekrar giriş yapın';
}

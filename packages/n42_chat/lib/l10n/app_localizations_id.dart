// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class SId extends S {
  SId([String locale = 'id']) : super(locale);

  @override
  String get commonRetry => 'Coba Lagi';

  @override
  String get commonUnknownUser => 'Pengguna Tidak Dikenal';

  @override
  String get transferWalletNotConnected => 'Dompet tidak terhubung';

  @override
  String get chatCallServiceNotInitialized =>
      'Layanan panggilan belum diinisialisasi';

  @override
  String authLoginFailed(String error) {
    return 'Login gagal: $error';
  }

  @override
  String get chatCallBack => 'Panggil balik';

  @override
  String get chatMissedVideoCall => 'Panggilan video tidak terjawab';

  @override
  String get chatMissedVoiceCall => 'Panggilan suara tidak terjawab';

  @override
  String get chatCallNotAnswered => 'Tidak dijawab';

  @override
  String get chatCallDurationLabel => 'Durasi panggilan';

  @override
  String get chatVoiceCallCancelled => 'Panggilan suara dibatalkan';

  @override
  String get chatVideoCallCancelled => 'Panggilan video dibatalkan';

  @override
  String get commonImage => '[Gambar]';

  @override
  String get chatVideo => '[Video]';

  @override
  String get chatVoice => '[Suara]';

  @override
  String get commonFile => '[Berkas]';

  @override
  String get chatLocation => '[Lokasi]';

  @override
  String get chatUnknownMessage => '[Pesan tidak dikenal]';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get chatDeleteThisMessage => 'Hapus pesan ini?';

  @override
  String get chatMessageDeleted => 'Pesan dihapus';

  @override
  String get profileNotLoggedIn => 'Belum masuk';

  @override
  String get chatMyLocation => 'Lokasi saya';

  @override
  String get commonGroupChat => 'Chat Grup';

  @override
  String get commonSearch => 'Cari';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonLoadFailed => 'Gagal memuat';

  @override
  String get commonMessages => 'Pesan';

  @override
  String get commonContacts => 'Kontak';

  @override
  String get commonMe => 'Saya';

  @override
  String get commonVoiceLoading =>
      'Suara sedang dimuat, silakan coba lagi nanti';

  @override
  String get commonVoiceToTextFailed => 'Gagal mengubah suara ke teks';

  @override
  String get commonConvertToText => 'Ke teks';

  @override
  String get chatCopy => 'Salin';

  @override
  String get commonForward => 'Teruskan';

  @override
  String get commonUnfavorite => 'Batal favorit';

  @override
  String get commonFavorite => 'Favorit';

  @override
  String get settingsResend => 'Kirim ulang';

  @override
  String get chatRecall => 'Tarik';

  @override
  String get commonQuote => 'Kutip';

  @override
  String get commonRemind => 'Ingatkan';

  @override
  String get chatCopied => 'Disalin';

  @override
  String get storySendMessageHint => 'Kirim pesan';

  @override
  String get commonMicrophonePermissionRequired =>
      'Silakan izinkan akses mikrofon';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'Izin mikrofon telah ditolak. Harap aktifkan di pengaturan sistem untuk menggunakan pesan suara.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'Gagal memulai rekaman: $error';
  }

  @override
  String get commonRecordingTooShort => 'Rekaman terlalu pendek';

  @override
  String commonStopRecordingFailed(String error) {
    return 'Gagal menghentikan rekaman: $error';
  }

  @override
  String get chatReleaseToCancel => 'Lepas untuk membatalkan';

  @override
  String get chatReleaseToSend =>
      'Lepas untuk kirim, geser ke atas untuk batal';

  @override
  String get commonHoldToTalk => 'Tahan untuk bicara';

  @override
  String get commonSend => 'Kirim';

  @override
  String get commonAddFriend => 'Tambah Teman';

  @override
  String get commonChatServiceNotConnected => 'Layanan chat tidak terhubung';

  @override
  String contactUserNotFoundHint(String query) {
    return 'Pengguna \"$query\" tidak ditemukan\n\nTips:\n• Coba masukkan ID pengguna lengkap, contoh @username:server.com\n• Periksa ejaan nama pengguna';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'Gagal membuat chat: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'Pencarian gagal: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'Masukkan ID atau nama pengguna untuk mencari';

  @override
  String get contactSearching => 'Mencari...';

  @override
  String get contactSearchUserToChat => 'Cari pengguna untuk mulai mengobrol';

  @override
  String get contactMatrixIdExample =>
      'Anda dapat memasukkan Matrix ID lengkap\ncontoh @user:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'Pengguna \"$username\" tidak ditemukan';
  }

  @override
  String get commonChat => 'Obrolan';

  @override
  String get commonSettings => 'Pengaturan';

  @override
  String get profileEditProfile => 'Edit Profil';

  @override
  String get authLogin => 'Masuk';

  @override
  String get commonCreateGroup => 'Buat Grup';

  @override
  String get chatError => 'Kesalahan';

  @override
  String get commonTransfer => 'Pemindahan';

  @override
  String get commonReceived => 'Diterima';

  @override
  String get commonRefunded => 'Dikembalikan';

  @override
  String get commonExpired => 'Kedaluwarsa';

  @override
  String get chatRedPacketGreeting => 'Semoga sukses selalu';

  @override
  String get commonN42RedPacket => 'Angpao N42';

  @override
  String get commonClaimed => 'Diklaim';

  @override
  String get commonAllClaimed => 'Semua diklaim';

  @override
  String get chatReadAloud => 'Baca dengan Keras';

  @override
  String get chatReply => 'Balas';

  @override
  String get commonEdit => 'Sunting';

  @override
  String get chatSelectForwardTarget => 'Pilih penerima';

  @override
  String commonSendCount(int count) {
    return 'Kirim ($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'ID N42: $id';
  }

  @override
  String get profileN42IdTitle => 'tanda pengenal N42';

  @override
  String get profileN42Bean => 'Kacang N42';

  @override
  String get contactFriendInfo => 'Info Teman';

  @override
  String get contactFriendInfoDesc =>
      'Tambahkan catatan teman, telepon, tag, catatan, foto dan atur izin.';

  @override
  String get commonMoments => 'Momen';

  @override
  String get commonSendMessage => 'Pesan';

  @override
  String get contactAudioVideoCall => 'Panggilan Audio/Video';

  @override
  String get contactVideoChannel => 'Saluran Video';

  @override
  String get contactRemark => 'Catatan';

  @override
  String get contactRemarkName => 'Nama Catatan';

  @override
  String get contactPhone => 'Telepon';

  @override
  String get contactTags => 'Tag';

  @override
  String get contactNotes => 'Catatan';

  @override
  String get contactPhotos => 'Foto';

  @override
  String get contactPermissions => 'Izin';

  @override
  String get contactChatMomentsEtc => 'Chat, Moments, Olahraga, dll.';

  @override
  String get contactMoreInfo => 'Info Lainnya';

  @override
  String get contactCommonGroups => 'Grup bersama';

  @override
  String get contactSource => 'Sumber';

  @override
  String get settingsNotificationSettings => 'Notifikasi';

  @override
  String get settingsPrivacy => 'Privasi';

  @override
  String get settingsAppearance => 'Tampilan';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get commonLogout => 'Keluar';

  @override
  String get commonLogoutConfirm => 'Apakah Anda yakin ingin keluar?';

  @override
  String get commonSave => 'Simpan';

  @override
  String get profileNickname => 'Nama Panggilan';

  @override
  String get profileEnterNickname => 'Masukkan nama panggilan';

  @override
  String get profileSignature => 'Tanda Tangan';

  @override
  String get profileAddSignature => 'Tambahkan tanda tangan';

  @override
  String get commonTakePhoto => 'Ambil Foto';

  @override
  String get profileChooseFromGallery => 'Pilih dari Galeri';

  @override
  String profileSaveFailed(String error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String get authSecureDecentralizedChat => 'Pesan aman dan terdesentralisasi';

  @override
  String get commonEndToEndEncryption => 'Enkripsi ujung ke ujung';

  @override
  String get authMessagesOnlyYouCanSee =>
      'Pesan hanya dapat dilihat oleh Anda dan penerima';

  @override
  String get authDecentralized => 'Terdesentralisasi';

  @override
  String get authBasedOnMatrix => 'Dibangun di atas protokol terbuka Matrix';

  @override
  String get authWalletIntegration => 'Integrasi Dompet';

  @override
  String get authEasyCryptoTransfer => 'Transfer kripto dengan mudah';

  @override
  String get authRegister => 'Daftar';

  @override
  String get authAgreeTerms => 'Dengan masuk, Anda menyetujui';

  @override
  String get authTermsOfService => 'Ketentuan Layanan';

  @override
  String get authAnd => 'dan';

  @override
  String get authPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get authServerAddress => 'Alamat Server';

  @override
  String get authEnterServerAddress => 'Masukkan alamat server';

  @override
  String authConnectedTo(String serverName) {
    return 'Terhubung ke $serverName';
  }

  @override
  String get authUsername => 'Nama Pengguna';

  @override
  String get authEnterUsername => 'Masukkan nama pengguna';

  @override
  String get authUsernameOrEmail => 'Nama Pengguna atau Email';

  @override
  String get authEnterUsernameOrEmail => 'Masukkan nama pengguna atau email';

  @override
  String get authPassword => 'Kata Sandi';

  @override
  String get authEnterPassword => 'Masukkan kata sandi';

  @override
  String get authRegisterAccount => 'Daftar';

  @override
  String get authForgotPassword => 'Lupa Kata Sandi';

  @override
  String get authOtherLoginMethods => 'Metode login lainnya';

  @override
  String get authCreateAccount => 'Buat Akun';

  @override
  String get authJoinN42Chat =>
      'Bergabung dengan N42 Chat untuk mulai mengobrol';

  @override
  String get authUsernameHint => '3-20 karakter, huruf/angka/_';

  @override
  String get authUsernameMinLength => 'Nama pengguna minimal 3 karakter';

  @override
  String get authUsernameMaxLength => 'Nama pengguna maksimal 20 karakter';

  @override
  String get authUsernameFormat =>
      'Nama pengguna hanya boleh berisi huruf, angka, dan garis bawah';

  @override
  String get authPasswordHint => 'Minimal 8 karakter';

  @override
  String get commonPasswordMinLength => 'Kata sandi minimal 8 karakter';

  @override
  String get authConfirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get authFilled => 'Terisi';

  @override
  String get authEnterInviteCode => 'Masukkan kode undangan';

  @override
  String get authAlreadyHaveAccount => 'Sudah punya akun?';

  @override
  String get authLoginNow => 'Masuk sekarang';

  @override
  String get profileAvatar => 'Avatar';

  @override
  String get profileStatus => 'Status';

  @override
  String get commonLoading => 'Memuat...';

  @override
  String get conversationNoConversations => 'Tidak ada percakapan';

  @override
  String get conversationTapToChat => 'Ketuk kanan atas untuk mulai mengobrol';

  @override
  String get conversationStartGroup => 'Mulai Chat Grup';

  @override
  String get commonScan => 'Pindai';

  @override
  String get commonPayment => 'Pembayaran';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature segera hadir';
  }

  @override
  String get conversationMarkAsRead => 'Tandai sudah dibaca';

  @override
  String get commonUnmute => 'Bunyikan';

  @override
  String get commonMute => 'Bisukan';

  @override
  String get conversationUnpin => 'Lepas pin';

  @override
  String get conversationPin => 'Sematkan';

  @override
  String get conversationDeleteConversation => 'Hapus Percakapan';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return 'Hapus percakapan dengan \"$name\"?';
  }

  @override
  String get commonNoContacts => 'Tidak ada kontak';

  @override
  String get contactAddFriendsToChat => 'Tambah teman untuk mulai mengobrol';

  @override
  String get contactNotFound => 'Kontak tidak ditemukan';

  @override
  String get contactTryOtherKeywords =>
      'Coba kata kunci lain atau pencarian global';

  @override
  String get contactSearchResults => 'Hasil pencarian';

  @override
  String get contactNewFriends => 'Teman Baru';

  @override
  String get contactChatOnlyFriends => 'Teman Hanya Obrolan';

  @override
  String get contactOfficialAccounts => 'Akun Resmi';

  @override
  String get contactServiceAccounts => 'Akun Layanan';

  @override
  String get contactEnterpriseContacts => 'Kontak Perusahaan';

  @override
  String get contactRecommendToFriend => 'Bagikan kontak';

  @override
  String get commonSetRemark => 'Atur catatan';

  @override
  String get contactSendingCard => 'Mengirim kartu kontak...';

  @override
  String get commonFileLabel => 'Berkas';

  @override
  String get commonLocationLabel => 'Lokasi';

  @override
  String contactRecommendFailed(String error) {
    return 'Rekomendasi gagal: $error';
  }

  @override
  String get profileEnterRemark => 'Masukkan catatan';

  @override
  String get contactOpeningChat => 'Membuka chat...';

  @override
  String contactOpenChatFailed(String error) {
    return 'Gagal membuka chat: $error';
  }

  @override
  String get contactAddContact => 'Tambah Kontak';

  @override
  String get contactEnterUserId => 'Masukkan ID pengguna';

  @override
  String get contactNoFriendRequests => 'Tidak ada permintaan pertemanan';

  @override
  String get commonAccept => 'Terima';

  @override
  String get commonReject => 'Tolak';

  @override
  String get commonNoGroups => 'Tidak ada grup';

  @override
  String get contactSelectFriendToRecommend =>
      'Pilih teman untuk direkomendasikan';

  @override
  String get commonSearchContacts => 'Cari kontak';

  @override
  String get contactNoContactsFound => 'Tidak ada kontak ditemukan';

  @override
  String get favoriteYesterday => 'Kemarin';

  @override
  String get chatJustNow => 'Baru saja';

  @override
  String get profileOnline => 'Daring';

  @override
  String get profileOffline => 'Luring';

  @override
  String get searchContactsGroupsMessages => 'Cari kontak, grup, pesan';

  @override
  String get searchError => 'Kesalahan pencarian';

  @override
  String get chatSearchHint => 'Cari kontak, grup, dan pesan';

  @override
  String get searchHistory => 'Riwayat Pencarian';

  @override
  String get commonClear => 'Hapus';

  @override
  String get commonAll => 'Semua';

  @override
  String get searchGroups => 'Grup';

  @override
  String get searchNoResults => 'Tidak ada hasil';

  @override
  String commonGroupMembers(int count) {
    return 'Anggota ($count)';
  }

  @override
  String get groupMembersTitle => 'Anggota Grup';

  @override
  String get groupViewAll => 'Lihat semua';

  @override
  String get groupOwner => 'Pemilik';

  @override
  String get groupAdmin => 'Admin';

  @override
  String get groupInvite => 'Undang';

  @override
  String get commonGroupAnnouncement => 'Pengumuman Grup';

  @override
  String get commonNotSet => 'Belum diatur';

  @override
  String get groupDescription => 'Deskripsi Grup';

  @override
  String get groupPublicGroup => 'Grup Publik';

  @override
  String get commonClearChatHistory => 'Hapus Riwayat Chat';

  @override
  String get commonDissolveGroup => 'Bubarkan Grup';

  @override
  String get commonLeaveGroup => 'Keluar Grup';

  @override
  String get groupChangeGroupName => 'Ubah Nama Grup';

  @override
  String get commonEnterGroupName => 'Masukkan nama grup';

  @override
  String get commonConfirm => 'Konfirmasi';

  @override
  String get groupEnterGroupDescription => 'Masukkan deskripsi grup';

  @override
  String get groupPublish => 'Publikasikan';

  @override
  String get chatClearHistoryConfirm =>
      'Hapus semua riwayat chat? Ini tidak dapat dibatalkan.';

  @override
  String get chatClearAction => 'Hapus';

  @override
  String get commonChatHistoryCleared => 'Riwayat chat dihapus';

  @override
  String get commonDissolve => 'Bubarkan';

  @override
  String get groupQrCode => 'Kode QR Grup';

  @override
  String get commonSearchChatHistory => 'Cari Riwayat Chat';

  @override
  String get groupIdCopied => 'ID Grup disalin';

  @override
  String get transferEnterOrPasteAddress =>
      'Masukkan atau tempel alamat dompet';

  @override
  String get transferSelectToken => 'Pilih Token';

  @override
  String get commonTransferAmount => 'Jumlah Transfer';

  @override
  String get transferAvailable => 'Tersedia';

  @override
  String get transferMemoOptional => 'Memo (opsional)';

  @override
  String get transferConfirmTransfer => 'Konfirmasi Transfer';

  @override
  String get transferAddressVerified => 'Alamat terverifikasi';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'Tersedia: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'Masukkan jumlah';

  @override
  String get commonRedPacketCountMin => 'Minimal 1 angpao diperlukan';

  @override
  String get commonViewRedPacketDetails => 'Lihat detail angpao';

  @override
  String get commonEnterTransferAmount => 'Masukkan jumlah transfer';

  @override
  String get commonTransferTo => 'Transfer ke';

  @override
  String commonFromSender(String name, Object senderName) {
    return 'Dari $senderName';
  }

  @override
  String get commonConfirmReceive => 'Konfirmasi Penerimaan';

  @override
  String get groupProfile => 'Info Grup';

  @override
  String get groupRemoveMember => 'Keluarkan dari Grup';

  @override
  String get commonRemove => 'Keluarkan';

  @override
  String get profileClearStatus => 'Hapus Status';

  @override
  String get profileClearStatusConfirm => 'Hapus status saat ini?';

  @override
  String get profileStatusCleared => 'Status dihapus';

  @override
  String get profileUserNotExist => 'Pengguna tidak ada';

  @override
  String get profileUserIdCopied => 'ID Pengguna disalin';

  @override
  String get commonReport => 'Laporkan';

  @override
  String get profileQrCode => 'Kode QR';

  @override
  String get profileAvatarUpdated => 'Avatar diperbarui';

  @override
  String commonSelectImageFailed(String error) {
    return 'Gagal memilih gambar: $error';
  }

  @override
  String get profileChangeName => 'Ubah Nama';

  @override
  String get profileMale => 'Pria';

  @override
  String get profileFemale => 'Wanita';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature sedang dikembangkan...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'Gagal menyimpan alamat: $error';
  }

  @override
  String get profileAddNew => 'Tambah';

  @override
  String get profileAddAddress => 'Tambah Alamat';

  @override
  String get profileAddressAdded => 'Alamat ditambahkan';

  @override
  String get profileAddressUpdated => 'Alamat diperbarui';

  @override
  String get profileDeleteAddress => 'Hapus Alamat';

  @override
  String get profileAddressDeleted => 'Alamat dihapus';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'Gagal menyimpan faktur: $error';
  }

  @override
  String get profileMyInvoices => 'Faktur Saya';

  @override
  String get profileAddInvoice => 'Tambah Faktur';

  @override
  String get profileInvoiceAdded => 'Faktur ditambahkan';

  @override
  String get profileInvoiceUpdated => 'Faktur diperbarui';

  @override
  String get profileDeleteInvoice => 'Hapus Faktur';

  @override
  String get profileInvoiceDeleted => 'Faktur dihapus';

  @override
  String get profilePersonal => 'Pribadi';

  @override
  String get groupSelectAtLeastOne => 'Silakan pilih minimal satu anggota';

  @override
  String get chatFileNotExist => 'Berkas tidak ada';

  @override
  String chatSendFailed(String error) {
    return 'Gagal mengirim: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'Tidak dapat membuka browser';

  @override
  String chatSelectFileFailed(String error) {
    return 'Gagal memilih berkas: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'Pengaturan gagal: $error';
  }

  @override
  String get transferEnterValidAmount => 'Silakan masukkan jumlah yang valid';

  @override
  String get commonAddressCopied => 'Alamat disalin';

  @override
  String favoriteOpenItem(String content) {
    return 'Buka: $content';
  }

  @override
  String get favoriteDeleted => 'Dihapus';

  @override
  String get profileWallet => 'Dompet';

  @override
  String get chatRecording => 'Merekam';

  @override
  String get chatInvalidVideoUrl => 'URL video tidak valid';

  @override
  String get chatDownloadFile => 'Unduh berkas';

  @override
  String get chatClearChatHistoryTitle => 'Hapus Riwayat Chat';

  @override
  String get chatVideoCall => 'Panggilan Video';

  @override
  String get commonVoiceCall => 'Panggilan Suara';

  @override
  String get callLeaveMeeting => 'Tinggalkan Meeting';

  @override
  String get chatDetails => 'Detail Chat';

  @override
  String get chatViewAllGroupMembers => 'Lihat semua anggota';

  @override
  String get chatGroupName => 'Nama Grup';

  @override
  String get chatGroupNameUpdated => 'Nama grup diperbarui';

  @override
  String get chatUpdateFailed => 'Pembaruan gagal';

  @override
  String get chatNoPermissionToModify =>
      'Anda tidak memiliki izin untuk mengubah';

  @override
  String get chatGroupManagement => 'Manajemen Grup';

  @override
  String get chatMyNicknameInGroup => 'Nama Panggilan Saya di Grup';

  @override
  String get chatPinChat => 'Sematkan Obrolan';

  @override
  String get chatStrongReminder => 'Pengingat Kuat';

  @override
  String get chatSetChatBackground => 'Atur Latar Belakang Chat';

  @override
  String get chatUnknownFile => 'Berkas tidak dikenal';

  @override
  String get chatDownload => 'Unduh';

  @override
  String get chatInvalidLocation => 'Lokasi tidak valid';

  @override
  String get chatTapToCancel => 'Ketuk untuk membatalkan';

  @override
  String chatCaptureFailed(Object error) {
    return 'Gagal mengambil gambar: $error';
  }

  @override
  String get chatProcessingVideo => 'Memproses video...';

  @override
  String get chatVideoFileNotExist => 'Berkas video tidak ada';

  @override
  String get chatVideoDataEmpty => 'Data video kosong';

  @override
  String get chatVideoTooLarge => 'Ukuran video tidak boleh melebihi 100MB';

  @override
  String get chatSendingVideo => 'Mengirim video...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'Gagal mengirim video: $error';
  }

  @override
  String get chatImageFileNotExist => 'Berkas gambar tidak ada';

  @override
  String get commonImageDataEmpty => 'Data gambar kosong';

  @override
  String get chatSendingImage => 'Mengirim gambar...';

  @override
  String chatSendImageFailed(Object error) {
    return 'Gagal mengirim gambar: $error';
  }

  @override
  String get chatSendLocation => 'Kirim Lokasi';

  @override
  String get chatSelectLocationAndSend => 'Pilih lokasi dan kirim';

  @override
  String get chatShareRealTimeLocation => 'Bagikan Lokasi Real-time';

  @override
  String get chatShareLocationForOneHour =>
      'Bagikan lokasi real-time dengan teman selama 1 jam';

  @override
  String get chatLocationSent => 'Lokasi terkirim';

  @override
  String get chatSelectMessages => 'Pilih pesan';

  @override
  String chatSelectedCount(int count) {
    return 'Dipilih $count';
  }

  @override
  String get chatSelectAll => 'Pilih Semua';

  @override
  String chatGroupChatCount(int count) {
    return 'Chat Grup ($count)';
  }

  @override
  String get chatPrivateChat => 'Chat Pribadi';

  @override
  String get chatNoMessages => 'Tidak ada pesan';

  @override
  String get chatSendFirstMessage =>
      'Kirim pesan pertama untuk mulai mengobrol';

  @override
  String get chatEncryptionNotice =>
      'Chat ini dienkripsi ujung ke ujung. Hanya Anda dan penerima yang dapat membaca pesan.';

  @override
  String get chatMultiForward => 'Teruskan';

  @override
  String get chatCollect => 'Koleksi';

  @override
  String get chatNoMembers => 'Tidak ada anggota';

  @override
  String get chatMemberNotFound => 'Anggota tidak ditemukan';

  @override
  String get chatVoiceFileNotExist => 'Berkas suara tidak ada';

  @override
  String get chatVoiceFileEmpty => 'Berkas suara kosong';

  @override
  String get chatSendingVoice => 'Mengirim suara...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'Gagal mengirim suara: $error';
  }

  @override
  String get chatMessageForwarded => 'Pesan diteruskan';

  @override
  String chatForwardFailed(Object error) {
    return 'Gagal meneruskan: $error';
  }

  @override
  String get chatUnfavorited => 'Batal favorit';

  @override
  String get chatFavorited => 'Difavoritkan';

  @override
  String get chatReactionAdded => 'Reaksi ditambahkan';

  @override
  String get chatReactionRemoved => 'Reaksi dihapus';

  @override
  String get chatFailedMessageDeleted => 'Pesan gagal dihapus';

  @override
  String get chatDeleteMessages => 'Hapus pesan';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'Apakah Anda yakin ingin menghapus $count pesan?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'Catatan: $count pesan dari orang lain dan hanya akan dihapus untuk Anda.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return '$count pesan dari Anda akan ditarik untuk semua.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'Menarik $count pesan, $localCount dihapus hanya untuk Anda';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'Menarik $count pesan';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count pesan dihapus hanya untuk Anda';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'Meneruskan $count pesan';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'Penerusan selesai: $success berhasil, $failed gagal';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'Fitur pengingat hanya tersedia di chat grup';

  @override
  String get chatOnlyTextSearchable => 'Hanya pesan teks yang dapat dicari';

  @override
  String chatSearchFor(Object text) {
    return 'Cari \"$text\"';
  }

  @override
  String get chatBaiduSearch => 'Pencarian Baidu';

  @override
  String get chatGoogleSearch => 'Pencarian Google';

  @override
  String get chatBingSearch => 'Pencarian Bing';

  @override
  String get chatCalling => 'Memanggil...';

  @override
  String get chatRinging => 'Berdering...';

  @override
  String get chatInCall => 'Dalam panggilan';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'Fitur sedang dikembangkan...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'Mengoleksi $count pesan';
  }

  @override
  String commonMemberCount(int count) {
    return '$count anggota';
  }

  @override
  String groupDone(int count) {
    return 'Selesai($count)';
  }

  @override
  String get profileServices => 'Layanan';

  @override
  String get commonFavorites => 'Favorit';

  @override
  String get profileOrdersAndCards => 'Pesanan & Kartu';

  @override
  String get profileStickers => 'Stiker';

  @override
  String profileStatusSetTo(String status) {
    return 'Status diatur ke: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'Gagal mengunggah avatar';

  @override
  String get profilePersonalProfile => 'Profil Pribadi';

  @override
  String get profileName => 'Nama';

  @override
  String get profileGender => 'Jenis Kelamin';

  @override
  String get profileRegion => 'Wilayah';

  @override
  String get commonMyQrCode => 'Kode QR Saya';

  @override
  String get profilePoke => 'Colek';

  @override
  String get profileRingtone => 'Nada Dering';

  @override
  String get profileDefaultRingtone => 'Nada Dering Default';

  @override
  String get profileMyAddresses => 'Alamat Saya';

  @override
  String profileGenderSetTo(String gender) {
    return 'Jenis kelamin diatur ke: $gender';
  }

  @override
  String get profileSelectRegion => 'Pilih Wilayah';

  @override
  String get profileSelectCity => 'Pilih Kota';

  @override
  String profileRegionSetTo(String region) {
    return 'Wilayah diatur ke: $region';
  }

  @override
  String get profileSetPoke => 'Atur Colek';

  @override
  String get profileFriendPokedMe => 'Teman mencolek saya';

  @override
  String get profileExample => 'Contoh';

  @override
  String get profileOnTheShoulder => ' di bahu';

  @override
  String get profilePokeCleared => 'Colek dihapus';

  @override
  String profilePokeSetTo(String suffix) {
    return 'Colek diatur ke: mencolek saya$suffix';
  }

  @override
  String get profileEditSignature => 'Edit Tanda Tangan';

  @override
  String get profileIntroduceYourself =>
      'Sebuah kalimat untuk memperkenalkan diri';

  @override
  String get profileSignatureCleared => 'Tanda tangan dihapus';

  @override
  String get profileSignatureUpdated => 'Tanda tangan diperbarui';

  @override
  String get profileScanToAddFriend =>
      'Pindai kode QR di atas untuk menambahkan saya sebagai teman';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'Nada dering diatur ke: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return 'Apakah Anda yakin ingin membubarkan \"$name\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get authEnterValidServerAddress =>
      'Silakan masukkan alamat server yang valid';

  @override
  String get authEnterServerAddressFirst =>
      'Silakan masukkan alamat server terlebih dahulu';

  @override
  String get authPasskeyRequiresServer =>
      'Login passkey memerlukan dukungan server';

  @override
  String get authLoginAgreement => 'Dengan masuk, Anda menyetujui ';

  @override
  String get authPleaseAgreeToTerms =>
      'Silakan baca dan setujui Ketentuan Layanan dan Kebijakan Privasi';

  @override
  String get authRegisterFailed => 'Pendaftaran gagal';

  @override
  String get commonReenterPassword => 'Masukkan ulang kata sandi';

  @override
  String get commonPasswordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get authInviteCodeBuiltIn => 'Kode Undangan (Bawaan)';

  @override
  String get authInviteCodeBuiltInNote =>
      'Kode undangan sudah bawaan, biasanya tidak perlu diubah';

  @override
  String get authIHaveReadAndAgree => 'Saya telah membaca dan menyetujui ';

  @override
  String get mainStartGroupChat => 'Mulai Chat Grup';

  @override
  String get mainAddFriends => 'Tambah Teman';

  @override
  String get mainPaymentAndCollection => 'Pembayaran';

  @override
  String contactCount(int count) {
    return '$count kontak';
  }

  @override
  String get contactAddToHomeScreen => 'Tambahkan ke layar utama';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'Merekomendasikan kartu $contact ke $recipient';
  }

  @override
  String get contactEnterRemarkName => 'Masukkan nama catatan';

  @override
  String contactRemarkSetTo(String remark) {
    return 'Catatan diatur ke: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return 'Menerima permintaan pertemanan $name';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return 'Menolak permintaan pertemanan $name';
  }

  @override
  String get commonGroupInvites => 'Undangan Grup';

  @override
  String commonMyGroups(int count) {
    return 'Grup Saya ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'Diundang untuk bergabung ke grup';

  @override
  String commonConfirmLeaveGroup(String name) {
    return 'Apakah Anda yakin ingin keluar dari \"$name\"?';
  }

  @override
  String get commonLeave => 'Keluar';

  @override
  String get commonRecallThisMessage => 'Tarik pesan ini?';

  @override
  String get commonSavedToGallery => 'Disimpan ke galeri';

  @override
  String get commonFailedToSave => 'Gagal menyimpan';

  @override
  String get chatSaving => 'Menyimpan...';

  @override
  String get commonShare => 'Bagikan';

  @override
  String get chatSaveToGallery => 'Simpan ke Galeri';

  @override
  String chatDownloadFailed(String code) {
    return 'Unduhan gagal: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'Gagal berbagi: $error';
  }

  @override
  String get chatFailedToLoadImage => 'Gagal memuat gambar';

  @override
  String get chatVideoRecordingFailed =>
      'Perekaman video gagal. Silakan coba lagi.';

  @override
  String get profileRedPacket => 'Angpao';

  @override
  String get commonMusic => 'Musik';

  @override
  String get commonCoupon => 'Kupon';

  @override
  String get commonGift => 'Hadiah';

  @override
  String get commonPoll => 'Polling';

  @override
  String get favoriteText => 'Teks';

  @override
  String get favoriteLinkLabel => 'Tautan';

  @override
  String get favoriteNote => 'Catatan';

  @override
  String get favoriteMyNotes => 'Catatan Saya';

  @override
  String get favoriteToday => 'Hari ini';

  @override
  String favoriteDaysAgoText(int count) {
    return '$count hari lalu';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$day/$month';
  }

  @override
  String get favoriteNoFavorites => 'Belum ada favorit';

  @override
  String get favoriteLongPressToFavorite =>
      'Tekan lama pesan untuk difavoritkan';

  @override
  String get favoriteNewNote => 'Catatan Baru';

  @override
  String get favoriteLink => 'Favoritkan Tautan';

  @override
  String get favoriteEditTags => 'Edit Tag';

  @override
  String get favoriteDeleteFavorite => 'Hapus Favorit';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'Apakah Anda yakin ingin menghapus favorit ini?';

  @override
  String get favoriteNoSearchResultsFound => 'Tidak ada hasil ditemukan';

  @override
  String get commonSendRedPacket => 'Kirim Angpao';

  @override
  String get transferAmount => 'Jumlah';

  @override
  String get commonRedPacketCover => 'Sampul Angpao';

  @override
  String get commonRedPacketType => 'Jenis Angpao';

  @override
  String get commonNormalRedPacket => 'Biasa';

  @override
  String get commonLuckyRedPacket => 'Hoki';

  @override
  String get commonRedPacketCount => 'Jumlah Angpao';

  @override
  String get commonPieces => 'buah';

  @override
  String get commonPutMoneyInRedPacket => 'Masukkan uang ke angpao';

  @override
  String get commonRedPacketRefundNotice =>
      'Angpao yang tidak diklaim akan dikembalikan setelah 24 jam';

  @override
  String get commonOpenRedPacket => 'Buka';

  @override
  String get commonRedPacketAllClaimed => 'Angpao habis diklaim';

  @override
  String get commonRedPacketExpired => 'Angpao kedaluwarsa';

  @override
  String get commonAddTransferNote => 'Tambahkan catatan transfer';

  @override
  String get commonYuan => 'IDR';

  @override
  String get commonReplyWithEmoji => 'Balas dengan emoji ini';

  @override
  String get contactEditRemark => 'Edit Catatan';

  @override
  String get contactSetPermissions => 'Atur Izin';

  @override
  String get profileAddToBlacklist => 'Tambahkan ke Daftar Hitam';

  @override
  String get contactDeleteContact => 'Hapus Kontak';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'Apakah Anda yakin ingin menghapus $name?';
  }

  @override
  String get transferTitle => 'Pemindahan';

  @override
  String get transferReceiverAddressLabel => 'Alamat Penerima';

  @override
  String get transferSelectTokenLabel => 'Pilih Token';

  @override
  String get transferAmountLabel => 'Jumlah Transfer';

  @override
  String get transferMemoLabel => 'Memo (opsional)';

  @override
  String get transferAddMemoHint => 'Tambahkan memo';

  @override
  String get transferSendPaymentRequest => 'Kirim Permintaan Pembayaran';

  @override
  String get transferQrCodeGenerateFailed => 'Gagal membuat kode QR';

  @override
  String get transferScanQrToPayMe => 'Pindai kode QR untuk membayar saya';

  @override
  String get transferMyWalletAddress => 'Alamat Dompet Saya';

  @override
  String get transferCreatePaymentRequest => 'Buat Permintaan Pembayaran';

  @override
  String profileN42IdLabel(String id) {
    return 'ID N42: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'Semoga sukses selalu';

  @override
  String commonSenderRedPacket(String name) {
    return 'Angpao $name';
  }

  @override
  String get transferEnterValidAddress => 'Silakan masukkan alamat yang valid';

  @override
  String get transferPleaseSelectToken => 'Silakan pilih token';

  @override
  String get commonReceivedTransfer => 'Transfer Diterima';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name mengirim angpao';
  }

  @override
  String get commonSavedToBalance =>
      'Disimpan ke saldo, dapat ditransfer langsung';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'Angpao kedaluwarsa/habis diklaim';

  @override
  String get transferScanFeatureComingSoon => 'Fitur pindai segera hadir...';

  @override
  String get contactSetAsStarred => 'Atur sebagai Berbintang';

  @override
  String get contactAddToBlocklist => 'Tambahkan ke Daftar Blokir';

  @override
  String get commonClaimedYour => ' mengklaim ';

  @override
  String get commonClaimedText => ' mengklaim ';

  @override
  String commonUserTyping(String name) {
    return '$name sedang mengetik...';
  }

  @override
  String get commonTyping => 'Mengetik...';

  @override
  String get commonWaitingToReceive => 'Menunggu untuk diterima';

  @override
  String get commonTapToClaim => 'Ketuk untuk klaim';

  @override
  String get commonHasBeenReceived => 'Sudah diterima';

  @override
  String get commonGetLucky => 'Semoga beruntung';

  @override
  String get qrcodeCameraStartFailed => 'Kamera gagal dimulai';

  @override
  String get qrcodeUnknownError => 'Kesalahan tidak dikenal';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'Letakkan kode QR dalam bingkai untuk memindai';

  @override
  String get qrcodeCloseManualInput => 'Tutup Input Manual';

  @override
  String get qrcodeManualInputUserId => 'Input Manual ID Pengguna';

  @override
  String get commonAdd => 'Tambah';

  @override
  String get profileSetStatus => 'Atur Status';

  @override
  String get profileVisibleToFriends24h => 'Terlihat oleh teman selama 24 jam';

  @override
  String get profileWriteStatus => 'Tulis Status';

  @override
  String get profileEnterYourStatus => 'Masukkan status Anda...';

  @override
  String get profileOk => 'Oke';

  @override
  String get qrcodeCameraPermissionRequired =>
      'Izin kamera diperlukan untuk memindai kode QR';

  @override
  String get qrcodeCameraPermissionDenied =>
      'Izin kamera ditolak secara permanen. Silakan aktifkan di pengaturan sistem.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'Kesalahan memeriksa izin: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'Kode QR tidak valid';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'Tidak dapat menambah teman: $error';
  }

  @override
  String get qrcodeScanQrCode => 'Pindai Kode QR';

  @override
  String get qrcodeCheckingCameraPermission => 'Memeriksa izin kamera...';

  @override
  String get qrcodeNeedCameraPermission => 'Izin Kamera Diperlukan';

  @override
  String get qrcodeRetryPermission => 'Coba Lagi';

  @override
  String get qrcodeOpenSettings => 'Buka Pengaturan';

  @override
  String get groupInviteMembers => 'Undang Anggota';

  @override
  String groupInviteCount(int count) {
    return 'Undang($count)';
  }

  @override
  String get profileNoShippingAddress => 'Tidak ada alamat pengiriman';

  @override
  String get profileDefaultLabel => 'Bawaan';

  @override
  String get profileNoInvoice => 'Tidak ada faktur';

  @override
  String get profileCompany => 'Perusahaan';

  @override
  String get profileTaxNumber => 'Nomor Pajak';

  @override
  String get profileConfirmDeleteAddress =>
      'Apakah Anda yakin ingin menghapus alamat ini?';

  @override
  String get profileConfirmDeleteInvoice =>
      'Apakah Anda yakin ingin menghapus faktur ini?';

  @override
  String get commonGroupOwner => 'Pemilik';

  @override
  String get commonGroupAdmin => 'Admin';

  @override
  String get groupSearchMembers => 'Cari anggota';

  @override
  String groupTotalMembers(int count) {
    return '$count anggota';
  }

  @override
  String get chatRemoveFromGroup => 'Keluarkan dari Grup';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'Apakah Anda yakin ingin mengeluarkan \"$name\" dari grup?';
  }

  @override
  String get chatUnknownSong => 'Lagu Tidak Dikenal';

  @override
  String get chatUnknownArtist => 'Artis Tidak Dikenal';

  @override
  String get chatUnknownContact => 'Kontak Tidak Dikenal';

  @override
  String get chatPersonalCard => 'Kartu Kontak';

  @override
  String get chatSingleChoice => 'Tunggal';

  @override
  String get chatMultiChoice => 'Multi';

  @override
  String get chatEnded => 'Berakhir';

  @override
  String get chatEndPollButton => 'Akhiri Polling';

  @override
  String get chatPollHint =>
      'Polling akan ditampilkan di chat. Anggota grup dapat memilih.';

  @override
  String get chatSearchSongOrArtist => 'Cari lagu atau artis';

  @override
  String get chatNoSongsFound => 'Tidak ada lagu ditemukan';

  @override
  String get chatSongNameOptional => 'Nama Lagu (Opsional)';

  @override
  String get chatEnterSongName => 'Masukkan nama lagu';

  @override
  String get chatArtistNameOptional => 'Nama Artis (Opsional)';

  @override
  String get chatEnterArtistName => 'Masukkan nama artis';

  @override
  String get chatRealTimeLocationSharing =>
      'Berbagi lokasi real-time sedang dikembangkan...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'Fitur panggilan suara sedang dikembangkan...';

  @override
  String get profileReportFeatureInDev =>
      'Fitur laporan sedang dikembangkan...';

  @override
  String get profileShareFeatureInDev => 'Fitur bagikan sedang dikembangkan...';

  @override
  String get profileQrCodeFeatureInDev =>
      'Fitur kode QR sedang dikembangkan...';

  @override
  String get qrcodeScanQrToAddMe =>
      'Pindai kode QR di atas untuk menambahkan saya sebagai teman';

  @override
  String get qrcodeSaveToAlbum => 'Simpan ke Album';

  @override
  String get qrcodeChangeStyle => 'Ubah Gaya';

  @override
  String get qrcodeCopyId => 'Salin ID';

  @override
  String get qrcodeIdCopied => 'ID disalin';

  @override
  String get qrcodeMoreStylesFeatureComingSoon =>
      'Lebih banyak gaya segera hadir';

  @override
  String get profileBio => 'Biografi';

  @override
  String get profileHomeServer => 'pelayan';

  @override
  String get profileShareContactCard => 'Bagikan Kartu Kontak';

  @override
  String get profileRemoveFromBlacklist => 'Hapus dari Daftar Hitam';

  @override
  String get profileConfirmAddBlacklist =>
      'Apakah Anda yakin ingin menambahkan pengguna ini ke daftar hitam? Anda tidak akan menerima pesan dari mereka.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'Apakah Anda yakin ingin menghapus pengguna ini dari daftar hitam?';

  @override
  String get profileRemarkSaved => 'Catatan disimpan';

  @override
  String get profileRemarkCleared => 'Catatan dihapus';

  @override
  String get transferReceive => 'Terima';

  @override
  String get transferPleaseConnectWallet =>
      'Silakan hubungkan dompet Anda terlebih dahulu';

  @override
  String get transferSendRequest => 'Kirim Permintaan';

  @override
  String get transferPleaseEnterValidAmount =>
      'Silakan masukkan jumlah yang valid';

  @override
  String get searchPlaceholder => 'Cari kontak, grup, pesan';

  @override
  String get searchEnterKeywordToSearch =>
      'Masukkan kata kunci untuk mulai mencari';

  @override
  String get searchClearHistory => 'Hapus';

  @override
  String searchNoResultsForQuery(String query) {
    return 'Tidak ada hasil ditemukan untuk \"$query\"';
  }

  @override
  String get searchAllResults => 'Semua';

  @override
  String get searchInChat => 'Cari di chat';

  @override
  String get searchContactLabel => 'Kontak';

  @override
  String get searchGroupLabel => 'Grup';

  @override
  String get searchConversationLabel => 'Percakapan';

  @override
  String get searchMessageLabel => 'Pesan';

  @override
  String get settingsSecurityTitle => 'Keamanan';

  @override
  String get settingsKeyBackup => 'Cadangan Kunci';

  @override
  String get settingsBackupEncryptionKeys => 'Cadangkan Kunci Enkripsi';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count kunci dicadangkan';
  }

  @override
  String get settingsBackupNotSet => 'Cadangan belum diatur';

  @override
  String get settingsRestoreKeys => 'Pulihkan Kunci';

  @override
  String get settingsRestoreKeysFromBackup =>
      'Pulihkan kunci enkripsi dari cadangan';

  @override
  String get settingsExportKeys => 'Ekspor Kunci';

  @override
  String get settingsExportKeysToFile => 'Ekspor kunci ke berkas';

  @override
  String get settingsLoggedInDevices => 'Perangkat yang Masuk';

  @override
  String get settingsNoOtherDevices => 'Tidak ada perangkat lain';

  @override
  String get settingsVerified => 'Terverifikasi';

  @override
  String get settingsUnverified => 'Belum terverifikasi';

  @override
  String get settingsAdvanced => 'Lanjutan';

  @override
  String get settingsCrossSigning => 'Penandatanganan Silang';

  @override
  String get settingsEnabled => 'Diaktifkan';

  @override
  String get settingsNotEnabled => 'Tidak diaktifkan';

  @override
  String get settingsResetEncryption => 'Reset Enkripsi';

  @override
  String get settingsDeleteAllEncryptionKeys => 'Hapus semua kunci enkripsi';

  @override
  String get settingsEncryptionNotSupported => 'Enkripsi tidak didukung';

  @override
  String get settingsNotInitialized => 'Belum diinisialisasi';

  @override
  String get settingsBackupKeyTitle => 'Cadangkan Kunci';

  @override
  String get settingsBackupKeyMessage =>
      'Buat cadangan kunci baru? Ini akan membantu Anda memulihkan pesan terenkripsi di perangkat baru.';

  @override
  String get settingsBackup => 'Cadangkan';

  @override
  String get settingsRestoreKeyTitle => 'Pulihkan Kunci';

  @override
  String get settingsRestoreKeyMessage =>
      'Masukkan kata sandi pemulihan atau kunci pemulihan untuk memulihkan pesan terenkripsi.';

  @override
  String get settingsRestore => 'Pulihkan';

  @override
  String get settingsExportKeyTitle => 'Ekspor Kunci';

  @override
  String get settingsExportKeyMessage =>
      'Berkas kunci yang diekspor berisi semua kunci enkripsi Anda. Harap simpan dengan aman.';

  @override
  String get settingsExport => 'Ekspor';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ID Perangkat: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'Status: Terverifikasi';

  @override
  String get settingsDeviceStatusUnverified => 'Status: Belum terverifikasi';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'Terakhir aktif: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'Verifikasi perangkat ini';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'Cross-signing sudah diaktifkan';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'Pengaturan cross-signing berhasil';

  @override
  String get settingsResetEncryptionTitle => 'Reset Enkripsi';

  @override
  String get settingsResetEncryptionWarning =>
      'Peringatan: Ini akan menghapus semua kunci enkripsi Anda. Anda tidak akan dapat mendekripsi pesan terenkripsi sebelumnya. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get settingsReset => 'Setel ulang';

  @override
  String get settingsBackupSuccess => 'Kunci berhasil dicadangkan';

  @override
  String get settingsBackupFailed => 'Pencadangan gagal';

  @override
  String get settingsRecoveryKey => 'Kunci Pemulihan';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'Harap simpan kunci pemulihan ini di tempat yang aman. Anda akan membutuhkannya untuk memulihkan pesan terenkripsi di perangkat baru.';

  @override
  String get settingsRecoveryKeySaved => 'Saya telah menyimpannya';

  @override
  String get settingsRestoreSuccess => 'Kunci berhasil dipulihkan';

  @override
  String get settingsRestoreFailed => 'Pemulihan gagal';

  @override
  String get settingsPassword => 'Kata sandi';

  @override
  String get settingsEnterRecoveryKey => 'Masukkan kunci pemulihan';

  @override
  String get settingsEnterPassword => 'Masukkan kata sandi';

  @override
  String get settingsExportSuccess =>
      'Kunci berhasil diekspor ke cadangan server';

  @override
  String get settingsExportNeedBackupFirst =>
      'Silakan buat cadangan kunci terlebih dahulu';

  @override
  String get settingsExportFailed => 'Ekspor gagal';

  @override
  String get settingsResetSuccess => 'Penyetelan ulang enkripsi berhasil';

  @override
  String get settingsResetFailed => 'Penyetelan ulang gagal';

  @override
  String get callLeaveMeetingConfirm =>
      'Apakah Anda yakin ingin meninggalkan meeting?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'mencolek $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'Tidak ada kontak yang dapat ditambahkan';

  @override
  String get chatAddMembers => 'Tambah Anggota';

  @override
  String chatInvitedMembers(int count) {
    return 'Mengundang $count anggota';
  }

  @override
  String chatInviteFailed(String error) {
    return 'Undangan gagal: $error';
  }

  @override
  String get chatMemberRemoved => 'Anggota dikeluarkan';

  @override
  String chatRemoveFailed(String error) {
    return 'Gagal mengeluarkan: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'Setelah berbagi, pihak lain dapat melihat lokasi real-time Anda selama 1 jam.';

  @override
  String get chatStartSharing => 'Mulai Berbagi';

  @override
  String get chatLocationServiceNotEnabled => 'Layanan lokasi tidak diaktifkan';

  @override
  String get chatEnableLocationService =>
      'Silakan aktifkan layanan lokasi untuk menggunakan fitur ini';

  @override
  String get chatGoToSettings => 'Buka Pengaturan';

  @override
  String get chatLocationPermissionRequired =>
      'Izin lokasi diperlukan untuk fitur ini';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'Izin lokasi telah ditolak secara permanen. Silakan aktifkan di pengaturan.';

  @override
  String get chatLocationPermissionDenied => 'Izin lokasi ditolak';

  @override
  String get chatGettingLocation => 'Mendapatkan lokasi...';

  @override
  String chatGetLocationFailed(String error) {
    return 'Gagal mendapatkan lokasi: $error';
  }

  @override
  String get chatMapPreview => 'Pratinjau Peta';

  @override
  String get chatSearchLocation => 'Cari lokasi';

  @override
  String chatRedPacketSent(String amount, String token) {
    return 'Mengirim angpao $amount $token';
  }

  @override
  String get chatTransferDefault => 'Pemindahan';

  @override
  String chatTransferSent(String amount, String token) {
    return 'Mengirim transfer $amount $token';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'Gagal memilih berkas: $error';
  }

  @override
  String get chatFileSizeLimit => 'Ukuran berkas tidak boleh melebihi 50MB';

  @override
  String chatFileSending(String filename) {
    return 'Mengirim berkas: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'Gagal mengirim berkas: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return 'Mengirim kartu kontak $name';
  }

  @override
  String get chatFavoritesFeature => 'Favorit';

  @override
  String get chatCouponsFeature => 'Kupon';

  @override
  String get chatGiftFeature => 'Hadiah';

  @override
  String chatSharedMusic(String name) {
    return 'Membagikan $name';
  }

  @override
  String get chatEndPollTitle => 'Akhiri Polling';

  @override
  String get chatEndPollConfirmMessage =>
      'Apakah Anda yakin ingin mengakhiri polling ini? Pemungutan suara akan ditutup setelah diakhiri.';

  @override
  String get chatPollEndedMessage => 'Polling berakhir';

  @override
  String get chatConnectingCall => 'Menghubungkan...';

  @override
  String get chatMuteCall => 'Bisukan';

  @override
  String get chatSpeakerOff => 'Speaker Mati';

  @override
  String get chatSpeakerOn => 'Pembicara';

  @override
  String get chatCameraOn => 'Kamera Nyala';

  @override
  String get chatCameraOff => 'Kamera Mati';

  @override
  String get chatHangUp => 'Tutup';

  @override
  String get chatSelectForwardTargetTitle => 'Pilih Tujuan Terusan';

  @override
  String get chatNoForwardableChat => 'Tidak ada chat yang dapat diteruskan';

  @override
  String get chatNoMatchingChat => 'Tidak ada chat yang cocok ditemukan';

  @override
  String get chatLocationTitle => 'Lokasi';

  @override
  String get chatSendButton => 'Kirim';

  @override
  String get chatRetryButton => 'Coba Lagi';

  @override
  String get chatSearchContactHint => 'Cari kontak';

  @override
  String get chatShareMusic => 'Bagikan Musik';

  @override
  String get chatRecentPlayed => 'Terbaru';

  @override
  String get chatMyFavorites => 'Favorit';

  @override
  String get chatNetworkLink => 'Tautan';

  @override
  String get chatLocalFile => 'Lokal';

  @override
  String get chatPasteMusicLink => 'Tempel tautan musik';

  @override
  String get chatShareMusicButton => 'Bagikan Musik';

  @override
  String get chatSelectLocalAudio => 'Pilih Berkas Audio Lokal';

  @override
  String get chatSupportedAudioFormats => 'Mendukung MP3, M4A, WAV, FLAC, dll.';

  @override
  String get chatSelectFileButton => 'Pilih Berkas';

  @override
  String get chatPleaseEnterMusicLink => 'Silakan masukkan tautan musik';

  @override
  String get chatPleaseEnterValidLink => 'Silakan masukkan URL yang valid';

  @override
  String get chatSharedSong => 'Lagu Dibagikan';

  @override
  String get chatSelectMember => 'Pilih Anggota';

  @override
  String get chatSearchMemberHint => 'Cari anggota';

  @override
  String get chatNoMatchingMembers => 'Tidak ada anggota yang cocok ditemukan';

  @override
  String get commonUnknownMember => 'Tidak Dikenal';

  @override
  String chatSelectedMessagesCount(int count) {
    return 'Dipilih $count pesan';
  }

  @override
  String get chatSearchContactsOrGroups => 'Cari kontak atau grup';

  @override
  String get chatVideoTitle => 'Video';

  @override
  String get chatLoadingText => 'Memuat...';

  @override
  String get chatVideoLoadFailed => 'Gagal memuat video';

  @override
  String get chatPlayerInitFailed => 'Gagal menginisialisasi pemutar';

  @override
  String get chatCreatePollTitle => 'Buat Polling';

  @override
  String get chatSubmitPoll => 'Kirim';

  @override
  String get chatPollQuestionLabel => 'Pertanyaan Polling';

  @override
  String get chatEnterPollQuestionHint => 'Masukkan pertanyaan polling';

  @override
  String get chatPollOptionsLabel => 'Opsi Polling';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'Opsi $index';
  }

  @override
  String get chatAddOptionButton => 'Tambah Opsi';

  @override
  String get chatPollSettingsLabel => 'Pengaturan Polling';

  @override
  String get chatSelectionType => 'Jenis Pilihan';

  @override
  String get chatSingleChoiceLabel => 'Tunggal';

  @override
  String get chatMultiChoiceLabel => 'Multi';

  @override
  String get chatAnonymousPollSwitch => 'Polling Anonim';

  @override
  String get chatPleaseEnterQuestion => 'Silakan masukkan pertanyaan polling';

  @override
  String get chatAtLeastTwoOptions => 'Minimal 2 opsi diperlukan';

  @override
  String chatConfirmWithCount(int count) {
    return 'Konfirmasi ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'Verifikasi Email';

  @override
  String get authEnterValidEmailAddress =>
      'Silakan masukkan alamat email yang valid';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'Kode verifikasi dikirim ke $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'Gagal mengirim kode: $error';
  }

  @override
  String get authVerificationSuccess => 'Verifikasi berhasil';

  @override
  String get authVerificationFailed => 'Verifikasi gagal';

  @override
  String authVerificationCodeError(String error) {
    return 'Kesalahan kode verifikasi: $error';
  }

  @override
  String get commonEnterVerificationCode => 'Masukkan kode verifikasi';

  @override
  String get authEnterYourEmail => 'Masukkan email';

  @override
  String authWeSentCodeTo(String email) {
    return 'Kami mengirim kode 6 digit ke\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'Masukkan alamat email Anda, kami akan mengirim kode verifikasi';

  @override
  String get commonSendVerificationCode => 'Kirim kode verifikasi';

  @override
  String get authResendVerificationCode => 'Kirim ulang kode verifikasi';

  @override
  String authCanResendAfter(int seconds) {
    return 'Dapat mengirim ulang setelah $seconds detik';
  }

  @override
  String get commonChangeEmail => 'Ubah email';

  @override
  String get contactAddToContacts => 'Tambah ke Kontak';

  @override
  String get contactAddingToContacts => 'Menambahkan...';

  @override
  String get contactAddedToContacts => 'Ditambahkan ke kontak';

  @override
  String contactAddFailedWithError(String error) {
    return 'Gagal menambahkan: $error';
  }

  @override
  String get contactAddPhone => 'Tambah telepon';

  @override
  String get contactAddTag => 'Tambah tag';

  @override
  String get contactAddText => 'Tambah teks';

  @override
  String get contactAddPhoto => 'Tambah foto';

  @override
  String contactGroupCountLabel(int count) {
    return '$count grup';
  }

  @override
  String get contactAddedViaSearch => 'Ditambahkan melalui pencarian';

  @override
  String get contactAddTime => 'Tambah waktu';

  @override
  String get contactDoneButton => 'Selesai';

  @override
  String get callWaitingForParticipants => 'Menunggu peserta bergabung...';

  @override
  String callParticipantMe(String name) {
    return '$name (Saya)';
  }

  @override
  String get callSharingLabel => 'Berbagi';

  @override
  String callScreenSharingBy(String name) {
    return '$name sedang berbagi layar';
  }

  @override
  String callParticipantCount(int count) {
    return '$count peserta';
  }

  @override
  String get callMuteLabel => 'Bisukan';

  @override
  String get callUnmuteLabel => 'Bunyikan';

  @override
  String get callTurnOffVideo => 'Matikan video';

  @override
  String get callTurnOnVideo => 'Nyalakan video';

  @override
  String get callShareScreen => 'Berbagi layar';

  @override
  String get callStopSharing => 'Berhenti berbagi';

  @override
  String get callSwitchCameraLabel => 'Ganti';

  @override
  String get callLeaveLabel => 'Keluar';

  @override
  String get callParticipantsLabel => 'Peserta';

  @override
  String get callJoiningMeeting => 'Bergabung ke meeting...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count suara ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count peserta';
  }

  @override
  String get commonTapToRetry => 'Ketuk untuk mencoba lagi';

  @override
  String get chatDefaultRedPacketGreeting => 'Semoga sukses dan sejahtera';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'Izinkan orang lain untuk mencari dan bergabung';

  @override
  String get groupConfirmClearChatHistory =>
      'Apakah Anda yakin ingin menghapus riwayat chat?';

  @override
  String get groupCreateGroupToChat => 'Buat grup untuk mulai berbincang';

  @override
  String get groupEditGroupAnnouncement => 'Edit pengumuman grup';

  @override
  String get groupEditGroupDescription => 'Edit deskripsi grup';

  @override
  String get groupEnterGroupAnnouncement => 'Masukkan pengumuman grup';

  @override
  String chatErrorWithMessage(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count anggota, klik untuk menyalin ID grup';
  }

  @override
  String get chatMusicLinkLabel => 'Link musik';

  @override
  String get chatNoMediaUrlAvailable => 'URL media tidak tersedia';

  @override
  String get groupNoPermissionToEditGroupName =>
      'Anda tidak memiliki izin untuk mengubah nama grup';

  @override
  String get chatRedPacketTransferCannotForward =>
      'Angpao dan transfer tidak dapat diteruskan';

  @override
  String get authEmailAddress => 'Alamat email';

  @override
  String get commonEnterEmailAddress => 'Masukkan alamat email';

  @override
  String get authEmailRecoveryHint => 'Digunakan untuk pemulihan kata sandi';

  @override
  String get commonInvalidEmailFormat => 'Masukkan alamat email yang valid';

  @override
  String get authOptional => 'Opsional';

  @override
  String get authResetPassword => 'Reset kata sandi';

  @override
  String get authEnterRegisteredEmail =>
      'Masukkan alamat email yang Anda daftarkan';

  @override
  String get authSendResetCode => 'Kirim kode reset';

  @override
  String authResetCodeSent(String email) {
    return 'Kode reset dikirim ke $email';
  }

  @override
  String get authEnterResetCode => 'Masukkan kode reset';

  @override
  String get authSetNewPassword => 'Atur kata sandi baru';

  @override
  String get commonConfirmNewPassword => 'Konfirmasi kata sandi baru';

  @override
  String get commonNewPassword => 'Kata sandi baru';

  @override
  String get authPasswordResetSuccess =>
      'Kata sandi berhasil direset. Silakan masuk dengan kata sandi baru Anda.';

  @override
  String get authResetPasswordFailed => 'Gagal mereset kata sandi';

  @override
  String get settingsChangePassword => 'Ubah kata sandi';

  @override
  String get settingsCurrentPassword => 'Kata sandi saat ini';

  @override
  String get settingsEnterCurrentPassword => 'Masukkan kata sandi saat ini';

  @override
  String get settingsEnterNewPassword => 'Masukkan kata sandi baru';

  @override
  String get settingsPasswordChanged =>
      'Kata sandi berhasil diubah. Silakan masuk dengan kata sandi baru Anda.';

  @override
  String get settingsChangePasswordFailed => 'Gagal mengubah kata sandi';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'Kata sandi baru harus berbeda dari kata sandi saat ini';

  @override
  String get settingsChangePasswordInfo =>
      'Setelah mengubah kata sandi, Anda akan keluar dan perlu masuk dengan kata sandi baru.';

  @override
  String get settingsPasswordRequirements => 'Persyaratan kata sandi:';

  @override
  String get settingsSecurityNote =>
      'Untuk keamanan, Anda perlu masuk ulang di semua perangkat setelah mengubah kata sandi.';

  @override
  String get settingsSecurity => 'Keamanan';

  @override
  String get settingsCurrentBoundEmail => 'Email yang terhubung saat ini';

  @override
  String get settingsNewEmailAddress => 'Alamat email baru';

  @override
  String get settingsEnterNewEmail => 'Masukkan alamat email baru';

  @override
  String get settingsVerificationCode => 'Kode verifikasi';

  @override
  String get settingsVerificationCodeSent => 'Kode verifikasi terkirim';

  @override
  String get settingsCodeSentTo => 'Kode verifikasi dikirim ke';

  @override
  String get settingsDidNotReceiveCode => 'Tidak menerima kode?';

  @override
  String get settingsEmailChangedSuccess => 'Email berhasil diubah';

  @override
  String get settingsChangeEmailFailed => 'Gagal mengubah email';

  @override
  String get settingsEmailSecurityNote =>
      'Email Anda digunakan untuk pemulihan kata sandi. Jaga keamanannya.';

  @override
  String get commonGoogleLogin => 'Masuk dengan Google';

  @override
  String get commonAppleLogin => 'Masuk dengan Apple';

  @override
  String get commonWechat => 'Wechat wechat';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageChanged => 'Bahasa diubah';

  @override
  String get settingsTranslation => 'Terjemahan';

  @override
  String get settingsTranslateTextTo => 'Terjemahkan teks ke';

  @override
  String get settingsTranslateDescription =>
      'Pilih bahasa yang Anda inginkan untuk menerjemahkan pesan.';

  @override
  String get settingsAutoTranslate =>
      'Terjemahkan otomatis pesan yang diterima';

  @override
  String get settingsAutoTranslateDescription =>
      'Terjemahkan pesan yang diterima dalam obrolan secara otomatis ke bahasa pilihan Anda.';

  @override
  String get settingsBiometricLogin => 'Login biometrik';

  @override
  String authLoginWithBiometric(Object type) {
    return 'Masuk dengan $type';
  }

  @override
  String get settingsBiometricLoginEnabled => 'Login biometrik diaktifkan';

  @override
  String get settingsBiometricLoginDisabled => 'Login biometrik dinonaktifkan';

  @override
  String get settingsEnableBiometricLogin => 'Aktifkan login biometrik';

  @override
  String get settingsBiometricEnabled =>
      'Aktif - Gunakan biometrik untuk masuk';

  @override
  String get settingsBiometricDisabled => 'Nonaktif - Ketuk untuk mengaktifkan';

  @override
  String get settingsBiometricNeedRelogin =>
      'Silakan keluar dan masuk kembali untuk mengaktifkan login biometrik';

  @override
  String get authOr => 'ATAU';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'Akses kamera dibatasi pada perangkat ini';

  @override
  String get authPasskeyLabel => 'Kunci pas';

  @override
  String get authGoogleLabel => 'Google';

  @override
  String get authAppleLabel => 'apel';

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
  String get profileEnterPokeSuffixHint =>
      'Masukkan sufiks colek, misal: di bahu';

  @override
  String get groupAlbum => 'Album grup';

  @override
  String get groupFiles => 'File grup';

  @override
  String get groupImages => 'Gambar';

  @override
  String get groupVideos => 'Video';

  @override
  String get groupTotal => 'Jumlah';

  @override
  String get groupSize => 'Ukuran';

  @override
  String get groupNoMedia => 'Tidak ada media';

  @override
  String get groupNoMediaDescription => 'Belum ada foto atau video di grup ini';

  @override
  String get groupDocuments => 'Dokumen';

  @override
  String get groupNoFiles => 'Tidak ada file';

  @override
  String get groupNoFilesDescription => 'Belum ada file di grup ini';

  @override
  String groupDownloadStarted(String filename) {
    return 'Mengunduh $filename...';
  }

  @override
  String get contactNoCommonGroups => 'Tidak ada grup bersama';

  @override
  String get contactNoCommonGroupsDescription =>
      'Kamu tidak memiliki grup bersama';

  @override
  String get chatVoiceMessage => 'Suara';

  @override
  String get chatMessage => 'Pesan';

  @override
  String get conversationHideChat => 'Sembunyikan';

  @override
  String get settingsQuickReply => 'Balasan cepat';

  @override
  String get commonTranslate => 'Terjemahkan';

  @override
  String get contactCreateTag => 'Buat Tanda';

  @override
  String get contactEnterTagName => 'Masukkan nama tag';

  @override
  String get contactEditTag => 'Sunting Tandai';

  @override
  String get contactDeleteTag => 'Hapus Tanda';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return 'Apakah Anda yakin ingin menghapus tag \"$tagName\"?';
  }

  @override
  String get contactNoTags => 'Belum ada tag';

  @override
  String get contactFriendPermissions => 'Izin Teman';

  @override
  String get contactSetChatOnly => 'Tetapkan sebagai Hanya Obrolan';

  @override
  String get contactChatOnlyDesc =>
      'Hanya dapat ngobrol dengan Anda, konten lainnya akan disembunyikan';

  @override
  String get contactHideMyMoments => 'Sembunyikan Momen Saya';

  @override
  String get contactHideMyMomentsDesc =>
      'Teman ini tidak dapat melihat Momen saya';

  @override
  String get contactHideTheirMoments => 'Sembunyikan Momen Mereka';

  @override
  String get contactHideTheirMomentsDesc => 'Jangan lihat Momen teman ini';

  @override
  String get contactHideMyStatus => 'Sembunyikan Status Saya';

  @override
  String get contactHideMyStatusDesc =>
      'Teman ini tidak dapat melihat pembaruan status saya';

  @override
  String get contactNoChatOnlyFriends => 'Tidak ada teman yang hanya mengobrol';

  @override
  String get contactNoOfficialAccounts => 'Tidak ada akun resmi';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'Ikuti akun resmi untuk mendapatkan update terkini';

  @override
  String get contactNoServiceAccounts => 'Tidak ada akun layanan';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'Berlangganan akun layanan untuk layanan yang nyaman';

  @override
  String get contactNoEnterpriseContacts => 'Tidak ada kontak perusahaan';

  @override
  String get contactEnterpriseContactsDesc =>
      'Kontak perusahaan akan ditampilkan di sini';

  @override
  String get profileCardPack => 'Paket Kartu';

  @override
  String get profileOrders => 'Pesanan';

  @override
  String get profileNoOrders => 'Tidak ada perintah';

  @override
  String get profileOrdersDesc => 'Pesanan Anda akan ditampilkan di sini';

  @override
  String get profileNoCards => 'Tidak ada kartu';

  @override
  String get profileCardsDesc => 'Kartu Anda akan ditampilkan di sini';

  @override
  String get favoriteEnterTagsHint =>
      'Masukkan tag yang dipisahkan dengan koma';

  @override
  String get favoriteTagsUpdated => 'Tag diperbarui';

  @override
  String get favoriteForwardedContent => 'Konten diteruskan';

  @override
  String get favoriteEnterNoteContent => 'Masukkan konten catatan';

  @override
  String get favoriteNoteAdded => 'Catatan ditambahkan';

  @override
  String get favoriteLinkTitle => 'Judul tautan';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'Tautan ditambahkan';

  @override
  String get contactPhotoAdded => 'Foto ditambahkan';

  @override
  String get contactEnterPhone => 'Masukkan nomor telepon';

  @override
  String commonConversationWithId(String roomId) {
    return 'Percakapan: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'Kontak: $userId';
  }

  @override
  String get commonDiscover => 'Jelajahi';

  @override
  String commonDeveloping(String title) {
    return '$title\n(Segera hadir)';
  }

  @override
  String get commonPageNotFound => 'Halaman tidak ditemukan';

  @override
  String get commonBackToHome => 'Kembali ke Beranda';

  @override
  String get settingsMessageNotifications => 'Notifikasi pesan';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'Terima notifikasi pesan baru';

  @override
  String get settingsShowMessagePreview => 'Tampilkan pratinjau pesan';

  @override
  String get settingsShowMessageContentInNotification =>
      'Tampilkan isi pesan di notifikasi';

  @override
  String get settingsNotificationSound => 'Suara notifikasi';

  @override
  String get settingsPlaySoundOnMessage => 'Putar suara saat menerima pesan';

  @override
  String get commonVibration => 'Getaran';

  @override
  String get settingsVibrateOnMessage => 'Getar saat menerima pesan';

  @override
  String get settingsDoNotDisturbMode => 'Jangan ganggu';

  @override
  String get settingsDoNotDisturbDescription =>
      'Tidak menerima notifikasi selama waktu yang ditentukan';

  @override
  String get settingsStartTime => 'Waktu mulai';

  @override
  String get settingsEndTime => 'Waktu selesai';

  @override
  String get settingsDeleteQuickReply => 'Hapus balasan cepat';

  @override
  String get settingsEditQuickReply => 'Edit balasan cepat';

  @override
  String get settingsAddQuickReply => 'Tambah balasan cepat';

  @override
  String get settingsManageQuickReplies => 'Kelola balasan cepat';

  @override
  String get settingsNoQuickReplies => 'Tidak ada balasan cepat';

  @override
  String get settingsDefaultQuickReplies =>
      'Balasan cepat default akan ditampilkan';

  @override
  String get settingsWhoCanSee => 'Siapa yang dapat melihat';

  @override
  String get settingsLastSeen => 'Terakhir dilihat';

  @override
  String get settingsHiddenChats => 'Chat tersembunyi';

  @override
  String get settingsMessagesLabel => 'Pesan';

  @override
  String get settingsAllowStrangerMessages => 'Izinkan pesan dari orang asing';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'Terima pesan dari non-kontak';

  @override
  String get settingsReadReceipts => 'Tanda baca';

  @override
  String get settingsLetOthersKnowYouRead =>
      'Biarkan orang lain tahu Anda telah membaca pesan mereka';

  @override
  String get settingsTypingIndicator => 'Indikator mengetik';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'Biarkan orang lain tahu Anda sedang mengetik';

  @override
  String get settingsEveryone => 'Semua orang';

  @override
  String get settingsContactsOnly => 'Hanya kontak';

  @override
  String get settingsNobody => 'Tidak ada';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'Siapa yang bisa melihat $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'Versi $version';
  }

  @override
  String get settingsCheckForUpdates => 'Periksa pembaruan';

  @override
  String get settingsOpenSourceLicenses => 'Lisensi open source';

  @override
  String get settingsFeedbackAndSuggestions => 'Masukan dan saran';

  @override
  String get settingsBuiltOnMatrix => 'Dibangun di atas protokol Matrix';

  @override
  String get settingsNoHiddenChats => 'Tidak ada chat tersembunyi';

  @override
  String get settingsNoHiddenChatsDescription =>
      'Chat yang kamu sembunyikan akan muncul di sini';

  @override
  String get settingsUnhideChat => 'Tampilkan';

  @override
  String get settingsDarkMode => 'Mode gelap';

  @override
  String get settingsFontSize => 'Ukuran font';

  @override
  String get settingsBubbleStyle => 'Gaya gelembung';

  @override
  String get settingsFollowSystem => 'Ikuti sistem';

  @override
  String get settingsAutoSwitchBySystem =>
      'Beralih otomatis sesuai pengaturan sistem';

  @override
  String get settingsLightMode => 'Mode terang';

  @override
  String get settingsAlwaysUseLightTheme => 'Selalu gunakan tema terang';

  @override
  String get settingsDarkModeOption => 'Mode gelap';

  @override
  String get settingsAlwaysUseDarkTheme => 'Selalu gunakan tema gelap';

  @override
  String get settingsFontSizeSmall => 'Kecil';

  @override
  String get settingsFontSizeStandard => 'Standar';

  @override
  String get settingsFontSizeLarge => 'Besar';

  @override
  String get settingsFontSizeExtraLarge => 'Sangat besar';

  @override
  String get settingsBubbleStyleWechat => 'Gaya WeChat';

  @override
  String get settingsBubbleStyleWechatDesc => 'Gaya gelembung klasik WeChat';

  @override
  String get settingsBubbleStyleModern => 'Gaya modern';

  @override
  String get settingsBubbleStyleModernDesc =>
      'Gaya gelembung modern yang bersih';

  @override
  String get settingsBubbleStyleClassic => 'Gaya klasik';

  @override
  String get settingsBubbleStyleClassicDesc => 'Gaya gelembung tradisional';

  @override
  String get discoverVideoChannels => 'Saluran';

  @override
  String get discoverLive => 'Siaran';

  @override
  String get discoverListen => 'Dengarkan';

  @override
  String get discoverWatch => 'Tonton';

  @override
  String get discoverSearchDiscover => 'Cari';

  @override
  String get discoverNearbyPeople => 'Sekitar';

  @override
  String get discoverGames => 'Permainan';

  @override
  String get discoverMiniPrograms => 'Mini Program';

  @override
  String get chatAlreadyInCall => 'Sedang dalam panggilan';

  @override
  String get commonConnectionFailed => 'Koneksi gagal';

  @override
  String get chatCallRejected => 'Panggilan ditolak';

  @override
  String get chatNoAnswer => 'Tidak ada jawaban';

  @override
  String get commonClose => 'Tutup';

  @override
  String get chatSelectContact => 'Pilih Kontak';

  @override
  String get chatVoteRemoved => 'Pilihan dihapus';

  @override
  String get chatVoteChanged => 'Pilihan diubah';

  @override
  String get chatVoted => 'Memilih';

  @override
  String chatReplyTo(String name) {
    return 'Balas ke $name';
  }

  @override
  String get chatCurrentLocation => 'Lokasi Saat Ini';

  @override
  String chatNearbyPlace(int index) {
    return 'Tempat Terdekat $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'Sekitar $distance';
  }

  @override
  String get chatAddress => 'Alamat';

  @override
  String get chatLatitude => 'Garis Lintang';

  @override
  String get chatLongitude => 'Garis Bujur';

  @override
  String get groupDescriptionUpdated => 'Deskripsi grup diperbarui';

  @override
  String get groupAvatarUpdated => 'Avatar grup diperbarui';

  @override
  String get groupVisibilityUpdated => 'Visibilitas grup diperbarui';

  @override
  String get groupChannelCreated => 'Saluran dibuat';

  @override
  String get groupChannelUpdated => 'Saluran diperbarui';

  @override
  String get groupChannelDeleted => 'Saluran dihapus';

  @override
  String get callDecline => 'Tolak';

  @override
  String get callAnswer => 'Jawab';

  @override
  String get callIncomingVideoCall => 'Panggilan video masuk';

  @override
  String get callIncomingVoiceCall => 'Panggilan suara masuk';

  @override
  String get callVideoCallInProgress => 'Panggilan video';

  @override
  String get callVoiceCallInProgress => 'Panggilan suara';

  @override
  String get callReconnectingCall => 'Menghubungkan ulang...';

  @override
  String get callEnded => 'Panggilan berakhir';

  @override
  String get callFailed => 'Panggilan gagal';

  @override
  String get callLivekitNotConfigured => 'LiveKit belum dikonfigurasi';

  @override
  String callJoinMeetingFailed(String error) {
    return 'Gagal bergabung ke meeting: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'Berbagi layar gagal: $error';
  }

  @override
  String get profileN42BeanTitle => 'Kacang N42';

  @override
  String get profileNoN42Bean => 'Tidak ada N42 Bean';

  @override
  String get profileN42BeanDetails => 'Detail N42 Bean';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean adalah token untuk menukarkan barang virtual dan layanan di N42. Saat ini tersedia untuk:';

  @override
  String get profileN42BeanFeature1 => 'Stiker dan tema eksklusif anggota';

  @override
  String get profileN42BeanFeature2 => 'Kustomisasi gelembung chat';

  @override
  String get profileN42BeanFeature3 => 'Kustomisasi sampul amplop merah';

  @override
  String get profileN42BeanFeature4 => 'Lencana nama panggilan eksklusif';

  @override
  String get profileN42BeanFeature5 => 'Hak istimewa chat grup';

  @override
  String get profileN42BeanFeature6 => 'Perluasan penyimpanan cloud';

  @override
  String get profileN42BeanFeature7 => 'Filter kecantikan panggilan video';

  @override
  String get profileN42BeanFeature8 => 'Kustomisasi latar belakang Moments';

  @override
  String get profileN42BeanFeature9 => 'Prioritas layanan pelanggan VIP';

  @override
  String get profileGotIt => 'Mengerti';

  @override
  String get profileNoN42BeanRecords => 'Tidak ada catatan N42 Bean';

  @override
  String get profileMoodAndThoughts => 'Suasana Hati & Pikiran';

  @override
  String get profileStatusHappy => 'Senang';

  @override
  String get profileStatusCracked => 'Hancur';

  @override
  String get profileStatusLucky => 'Beruntung';

  @override
  String get profileStatusSunny => 'Cerah';

  @override
  String get profileStatusTired => 'Lelah';

  @override
  String get profileStatusDaydream => 'Melamun';

  @override
  String get profileStatusRushing => 'Terburu-buru';

  @override
  String get profileStatusOverthinking => 'Berpikir Berlebihan';

  @override
  String get profileStatusEnergized => 'Berenergi';

  @override
  String get profileWorkAndStudy => 'Kerja & Belajar';

  @override
  String get profileStatusWorking => 'Bekerja';

  @override
  String get profileStatusStudying => 'Belajar';

  @override
  String get profileStatusBusy => 'Sibuk';

  @override
  String get profileStatusSlacking => 'Santai';

  @override
  String get profileStatusTraveling => 'Bepergian';

  @override
  String get profileStatusGoingHome => 'Pulang';

  @override
  String get profileStatusDnd => 'Jangan Ganggu';

  @override
  String get profileActivities => 'Aktivitas';

  @override
  String get profileStatusHanging => 'Nongkrong';

  @override
  String get profileStatusCheckIn => 'Lapor Masuk';

  @override
  String get profileStatusExercising => 'Berolahraga';

  @override
  String get profileStatusCoffee => 'Kopi';

  @override
  String get profileStatusBubbleTea => 'Boba';

  @override
  String get profileStatusEating => 'Makan';

  @override
  String get profileStatusParenting => 'Mengasuh';

  @override
  String get profileStatusSavingWorld => 'Menyelamatkan Dunia';

  @override
  String get profileStatusSelfie => 'Selfie';

  @override
  String get profileRest => 'Istirahat';

  @override
  String get profileStatusRetreat => 'Istirahat';

  @override
  String get profileStatusHome => 'Di Rumah';

  @override
  String get profileStatusSleeping => 'Tidur';

  @override
  String get profileStatusCatLover => 'Pecinta Kucing';

  @override
  String get profileStatusDogWalking => 'Jalan-jalan dengan Anjing';

  @override
  String get profileStatusGaming => 'Bermain Game';

  @override
  String get profileStatusListening => 'Mendengarkan';

  @override
  String get profileEditAddress => 'Edit Alamat';

  @override
  String get profileRecipient => 'Penerima';

  @override
  String get profileEnterRecipientName => 'Masukkan nama penerima';

  @override
  String get profilePhoneNumber => 'Nomor Telepon';

  @override
  String get profileEnterPhoneNumber => 'Masukkan nomor telepon';

  @override
  String get profileRegionHint => 'Provinsi/Kota/Kabupaten';

  @override
  String get profileDetailedAddress => 'Alamat Lengkap';

  @override
  String get profileDetailedAddressHint => 'Jalan, nomor gedung, dll.';

  @override
  String get profileSetAsDefaultAddress => 'Atur sebagai alamat default';

  @override
  String get profilePleaseCompleteInfo => 'Silakan lengkapi semua kolom';

  @override
  String get profileEditInvoice => 'Edit Faktur';

  @override
  String get profileInvoiceType => 'Jenis faktur: ';

  @override
  String get profileCompanyName => 'Nama Perusahaan';

  @override
  String get profilePersonalName => 'Nama Pribadi';

  @override
  String get profileEnterCompanyName => 'Masukkan nama perusahaan';

  @override
  String get profileEnterName => 'Masukkan nama';

  @override
  String get profileTaxIdNumber => 'NPWP';

  @override
  String get profileEnterTaxIdNumber => 'Masukkan NPWP';

  @override
  String get profileBankNameOptional => 'Nama Bank (Opsional)';

  @override
  String get profileEnterBankName => 'Masukkan nama bank';

  @override
  String get profileBankAccountOptional => 'Rekening Bank (Opsional)';

  @override
  String get profileEnterBankAccount => 'Masukkan rekening bank';

  @override
  String get profileCompanyAddressOptional => 'Alamat Perusahaan (Opsional)';

  @override
  String get profileEnterCompanyAddress => 'Masukkan alamat perusahaan';

  @override
  String get profileCompanyPhoneOptional => 'Telepon Perusahaan (Opsional)';

  @override
  String get profileEnterCompanyPhone => 'Masukkan telepon perusahaan';

  @override
  String get profileSetAsDefaultInvoice => 'Atur sebagai faktur default';

  @override
  String get profileRingtoneVibrate => 'Getar';

  @override
  String get profileRingtoneSilent => 'Senyap';

  @override
  String get profileVibrateMode => 'Mode getar';

  @override
  String get profileSilentMode => 'Mode senyap';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'Gagal memutar: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'Memutar: $ringtoneName';
  }

  @override
  String get profileStop => 'Berhenti';

  @override
  String get profileSelectRingtone => 'Pilih Nada Dering';

  @override
  String get profileLoadingRingtones => 'Memuat nada dering...';

  @override
  String get profileNoRingtonesFound => 'Tidak ada nada dering ditemukan';

  @override
  String mainMessagesWithCount(int count) {
    return 'Pesan($count)';
  }

  @override
  String get storyViewers => 'Penonton';

  @override
  String get storyNoViewers => 'Belum ada penonton';

  @override
  String get storyReplyToStory => 'Balas cerita...';

  @override
  String get commonCopiedToClipboard => 'Disalin ke papan klip';

  @override
  String get commonMore => 'Lainnya';

  @override
  String get commonTranslating => 'Menerjemahkan...';

  @override
  String commonTranslatedFrom(String language) {
    return 'Diterjemahkan dari $language';
  }

  @override
  String get commonTranslation => 'Terjemahan';

  @override
  String get commonTranslationFailed => 'Terjemahan gagal';

  @override
  String get commonAllRead => 'Semua dibaca';

  @override
  String commonReadCount(int count) {
    return '$count dibaca';
  }

  @override
  String get commonYouRecalledMessage => 'Anda menarik sebuah pesan';

  @override
  String get commonMessageRecalled => 'Pesan ditarik';

  @override
  String get commonReEdit => 'Edit ulang';

  @override
  String get commonWalletArea => 'Area dompet';

  @override
  String get callIncomingCall => 'Panggilan masuk';

  @override
  String get callMissedCall => 'Panggilan tidak terjawab';

  @override
  String get groupRemoveAdmin => 'Hapus Admin';

  @override
  String get chatSelectCurrency => 'Pilih mata uang';

  @override
  String get chatSelectEmoji => 'Pilih emoji';

  @override
  String get chatSelectRedPacketCover => 'Pilih sampul';

  @override
  String get groupSetAsAdmin => 'Atur sebagai Admin';

  @override
  String get chatVideoPlaybackFailed => 'Pemutaran video gagal';

  @override
  String get groupViewProfile => 'Lihat Profil';

  @override
  String get favoriteAddLinkComingSoon => 'Fitur tambah tautan segera hadir';

  @override
  String get favoriteNewNoteComingSoon => 'Fitur catatan baru segera hadir';

  @override
  String get qrcodeSaveFeatureComingSoon => 'Fitur simpan segera hadir';

  @override
  String get qrcodeShareFeatureComingSoon => 'Fitur bagikan segera hadir';

  @override
  String qrcodeProcessFailed(String error) {
    return 'Gagal memproses kode QR: $error';
  }

  @override
  String get securityDeviceIdRequired => 'ID perangkat diperlukan';

  @override
  String securityVerificationStartFailed(String error) {
    return 'Gagal memulai verifikasi: $error';
  }

  @override
  String get securityVerificationFailed => 'Verifikasi gagal';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'Verifikasi gagal: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'Verifikasi ditolak - emoji tidak cocok';

  @override
  String get securityWaitingForDeviceAccept =>
      'Menunggu perangkat lain menerima...';

  @override
  String get securityVerifyDevice => 'Verifikasi perangkat ini';

  @override
  String get securityConfirmEmojiMatch =>
      'Pastikan emoji di bawah ini ditampilkan di kedua perangkat, dalam urutan yang sama';

  @override
  String get securityEmojiDontMatch => 'Mereka tidak cocok';

  @override
  String get securityEmojiMatch => 'Mereka cocok';

  @override
  String get securityWaitingForDeviceConfirm =>
      'Menunggu perangkat lain mengonfirmasi...';

  @override
  String get securityVerificationSuccess => 'Verifikasi berhasil!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'Perangkat ini sekarang telah diverifikasi dan dipercaya.';

  @override
  String get securityCompareEmoji => 'Bandingkan emoji di kedua perangkat';

  @override
  String get securityCompareNumbers => 'Bandingkan angka di kedua perangkat';

  @override
  String get commonTryAgain => 'Coba Lagi';

  @override
  String get commonDone => 'Selesai';

  @override
  String get chatExportTitle => 'Ekspor Obrolan';

  @override
  String get chatExportSuccess => 'Ekspor berhasil';

  @override
  String chatExportFailed(String error) {
    return 'Ekspor gagal: $error';
  }

  @override
  String get chatExportFormat => 'Format Ekspor';

  @override
  String get chatExportHtmlDesc =>
      'Dapat dibaca di browser apa pun dengan tata letak bergaya';

  @override
  String get chatExportJsonDesc =>
      'Format data terstruktur yang dapat dibaca mesin';

  @override
  String get chatExportDateRange => 'Rentang Tanggal';

  @override
  String get chatExportAll => 'Semua Pesan';

  @override
  String get chatExportLastWeek => '7 Hari Terakhir';

  @override
  String get chatExportLastMonth => 'Bulan Lalu';

  @override
  String get chatExportLast3Months => '3 Bulan Terakhir';

  @override
  String get chatExportMessageCount => 'Pesan untuk diekspor';

  @override
  String get chatExportButton => 'Ekspor & Bagikan';

  @override
  String get chatMediaGallery => 'Galeri Media';

  @override
  String get chatExportHistory => 'Ekspor Riwayat Obrolan';

  @override
  String get pdfLoadFailed => 'Gagal memuat PDF';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'Semua';

  @override
  String get mediaImages => 'Gambar';

  @override
  String get mediaVideos => 'Video';

  @override
  String get mediaFiles => 'File';

  @override
  String get mediaAudio => 'Audio';

  @override
  String mediaItemsCount(int count) {
    return 'item $count';
  }

  @override
  String get mediaNoMediaFound => 'Tidak ada media yang ditemukan';

  @override
  String get spacesTitle => 'Komunitas';

  @override
  String get spacesCreate => 'Buat Komunitas';

  @override
  String get spacesJoined => 'Bergabung';

  @override
  String get spacesDiscover => 'Temukan';

  @override
  String get spacesNoJoined => 'Belum ada komunitas yang bergabung';

  @override
  String get spacesExplore => 'Jelajahi Komunitas';

  @override
  String get spacesNoPublic => 'Tidak ada komunitas publik yang ditemukan';

  @override
  String get spacesJoin => 'Bergabunglah';

  @override
  String get spacesSubSpaces => 'Sub-Komunitas';

  @override
  String get spacesChannels => 'Saluran';

  @override
  String spacesMembersCount(int count) {
    return 'Anggota $count';
  }

  @override
  String get spacesPublic => 'Publik';

  @override
  String get spacesPrivate => 'Pribadi';

  @override
  String get spacesSuggested => 'Disarankan';

  @override
  String spacesChannelsCount(int count) {
    return 'saluran $count';
  }

  @override
  String get callInCallChat => 'Obrolan Dalam Panggilan';

  @override
  String callMessagesCount(int count) {
    return 'Pesan $count';
  }

  @override
  String get callNoMessagesYet =>
      'Belum ada pesan.\nKirim pesan untuk memulai.';

  @override
  String get callTypeMessage => 'Ketik pesan...';

  @override
  String get callYouSender => 'kamu';

  @override
  String get callChatLabel => 'Obrolan';

  @override
  String get chatEdited => 'Diedit';

  @override
  String get chatEditHistory => 'Sunting Riwayat';

  @override
  String get chatOriginalMessage => 'Asli';

  @override
  String chatEditedAt(String time) {
    return 'Diedit di $time';
  }

  @override
  String get chatViewOnce => 'Lihat Sekali';

  @override
  String get chatViewOncePhoto => 'Lihat Sekali Foto';

  @override
  String get chatViewOnceVideo => 'Lihat Sekali Video';

  @override
  String get chatViewOnceViewed => 'Dilihat';

  @override
  String get chatViewOnceExpired => 'Kedaluwarsa';

  @override
  String get chatViewOnceTap => 'Ketuk untuk melihat';

  @override
  String get chatAutoFaceBlur => 'Wajah otomatis buram';

  @override
  String get chatAutoFaceBlurDesc =>
      'Memburamkan wajah secara otomatis saat mengirim foto';

  @override
  String get threadReplyInThread => 'Balas di thread';

  @override
  String threadReplies(int count) {
    return 'Balasan $count';
  }

  @override
  String get threadReply => '1 balasan';

  @override
  String threadLatestReply(String preview) {
    return 'Terbaru: $preview';
  }

  @override
  String get threadTitle => 'Benang';

  @override
  String get threadReplyPlaceholder => 'Jawab di thread...';

  @override
  String threadParticipants(int count) {
    return 'peserta $count';
  }

  @override
  String get voiceRoomTitle => 'Ruang Suara';

  @override
  String get voiceRoomCreate => 'Buat Ruang Suara';

  @override
  String get voiceRoomJoin => 'Bergabunglah';

  @override
  String get voiceRoomLeave => 'Pergi';

  @override
  String get voiceRoomEnd => 'Ruang Akhir';

  @override
  String get voiceRoomRaiseHand => 'Angkat Tangan';

  @override
  String get voiceRoomLowerHand => 'Tangan Bawah';

  @override
  String get voiceRoomMute => 'Bisu';

  @override
  String get voiceRoomUnmute => 'Suarakan';

  @override
  String get voiceRoomHost => 'Tuan rumah';

  @override
  String get voiceRoomSpeakers => 'Pembicara';

  @override
  String get voiceRoomListeners => 'Pendengar';

  @override
  String get voiceRoomLive => 'LANGSUNG';

  @override
  String get voiceRoomEnded => 'Berakhir';

  @override
  String get voiceRoomScheduled => 'Dijadwalkan';

  @override
  String get voiceRoomApprove => 'Menyetujui';

  @override
  String get voiceRoomDemote => 'Pindah ke Pendengar';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name mengangkat tangan mereka';
  }

  @override
  String get voiceRoomName => 'Nama kamar';

  @override
  String get voiceRoomTopic => 'Topik (opsional)';

  @override
  String get voiceRoomNoActive => 'Tidak ada ruang suara aktif';

  @override
  String get voiceRoomConnecting => 'Menghubungkan...';

  @override
  String get usernameTitle => 'Nama pengguna';

  @override
  String get usernameSet => 'Tetapkan Nama Pengguna';

  @override
  String get usernameChange => 'Ubah Nama Pengguna';

  @override
  String get usernamePlaceholder => 'Masukkan nama pengguna';

  @override
  String get usernameAvailable => 'Nama pengguna tersedia';

  @override
  String get usernameUnavailable => 'Nama pengguna sudah dipakai';

  @override
  String get usernameInvalid =>
      '3-30 karakter, huruf kecil, angka, garis bawah. Harus dimulai dengan surat.';

  @override
  String get usernameReserved => 'Nama pengguna ini sudah dipesan';

  @override
  String get usernameSaved => 'Nama pengguna disimpan';

  @override
  String get usernameSearchHint => 'Cari berdasarkan @namapengguna';

  @override
  String get ensName => 'Nama ENS';

  @override
  String get ensLinked => 'Terhubung ke ENS';

  @override
  String get ensResolving => 'Menyelesaikan ENS...';

  @override
  String get ensNotFound => 'Nama ENS tidak ditemukan';

  @override
  String get tokenGateTitle => 'Gerbang Token';

  @override
  String get tokenGateEnable => 'Aktifkan Gerbang Token';

  @override
  String get tokenGateDisable => 'Nonaktifkan Gerbang Token';

  @override
  String get tokenGateAddRule => 'Tambahkan Aturan';

  @override
  String get tokenGateRemoveRule => 'Hapus Aturan';

  @override
  String get tokenGateContractAddress => 'Alamat Kontrak';

  @override
  String get tokenGateMinBalance => 'Saldo Minimal';

  @override
  String get tokenGateTokenId => 'ID Token (ERC-1155)';

  @override
  String get tokenGateChainId => 'ID Rantai';

  @override
  String get tokenGateVerifying => 'Memverifikasi kepemilikan token...';

  @override
  String get tokenGateVerified => 'Verifikasi berhasil';

  @override
  String get tokenGateDenied => 'Anda tidak memenuhi persyaratan token';

  @override
  String get tokenGateOperatorAnd => 'Harus memenuhi SEMUA aturan';

  @override
  String get tokenGateOperatorOr => 'Harus memenuhi aturan APAPUN';

  @override
  String get tokenGateRuleErc20 => 'Token ERC-20';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'Multi-Token (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'Token Asli';

  @override
  String get tokenGateSaved => 'Gerbang token disimpan';

  @override
  String get tokenGateEnableDescription =>
      'Wajibkan anggota untuk memegang token untuk bergabung';

  @override
  String get tokenGateOperator => 'Logika Aturan';

  @override
  String get tokenGateRules => 'Aturan';

  @override
  String get tokenGateSymbol => 'Simbol (opsional)';

  @override
  String get tokenGateChain => 'Rantai';

  @override
  String get tokenGateTokenStandard => 'Standar Token';

  @override
  String get tokenGateDenialMessage => 'Pesan Penolakan';

  @override
  String get tokenGateDenialMessageHint =>
      'Pesan ditampilkan ketika verifikasi gagal';

  @override
  String get tokenGateVerifyTitle => 'Verifikasi Token';

  @override
  String get tokenGateVerifyPassed => 'Verifikasi Lulus';

  @override
  String get tokenGateVerifyFailed => 'Verifikasi Gagal';

  @override
  String get tokenGateRetryVerify => 'Coba lagi';

  @override
  String get tokenGateRequired => 'Diperlukan';

  @override
  String get tokenGateYourBalance => 'Saldo Anda';

  @override
  String get tokenGateRulesActive => 'aturan aktif';

  @override
  String get tokenGateDisabled => 'Dinonaktifkan';

  @override
  String get ensNotBound => 'Tidak terikat';

  @override
  String get liveLocation => 'Lokasi Langsung';

  @override
  String get stopLiveLocation => 'Berhenti Berbagi';

  @override
  String get startLiveLocation => 'Mulai Berbagi';

  @override
  String get selectDuration => 'Pilih Durasi';

  @override
  String get groupChatFiles => 'File Obrolan';

  @override
  String get groupLinks => 'Tautan';

  @override
  String get groupNoLinks => 'Belum ada tautan';

  @override
  String get chatBackground => 'Latar Belakang Obrolan';

  @override
  String get solidColors => 'Warna Padat';

  @override
  String get gradients => 'Gradien';

  @override
  String get defaultBackground => 'Bawaan';

  @override
  String get settingsFontSizeSlider => 'Ukuran Huruf';

  @override
  String get autoDownload => 'Unduh Otomatis';

  @override
  String get images => 'Gambar';

  @override
  String get voice => 'Suara';

  @override
  String get video => 'Video';

  @override
  String get files => 'File';

  @override
  String get mobileData => 'Data Seluler';

  @override
  String get roaming => 'Berkeliaran';

  @override
  String get storageManagement => 'Penyimpanan';

  @override
  String get totalUsage => 'Jumlah Penggunaan';

  @override
  String get cache => 'Tembolok';

  @override
  String get other => 'Lainnya';

  @override
  String get clearCache => 'Hapus Tembolok';

  @override
  String get cacheCleared => 'Tembolok dibersihkan';

  @override
  String get clearCacheFailed => 'Gagal menghapus cache';

  @override
  String get confirmClearCache => 'Hapus semua data cache?';

  @override
  String get mapView => 'Tampilan Peta';

  @override
  String liveLocationSharingCount(int count) {
    return '$count orang berbagi lokasi';
  }

  @override
  String get minutes15 => '15 menit';

  @override
  String get minutes30 => '30 menit';

  @override
  String get hour1 => '1 jam';

  @override
  String get hours8 => '8 jam';

  @override
  String get personalCard => 'Kartu Pribadi';

  @override
  String get downloadFailed => 'Pengunduhan gagal';

  @override
  String get locationExpired => 'Kedaluwarsa';

  @override
  String secondsRemaining(int count) {
    return '$count detik';
  }

  @override
  String minutesRemaining(int count) {
    return '$count menit';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours jam $minutes menit';
  }

  @override
  String get favoriteMessages => 'Favorit';

  @override
  String get linksCopied => 'Tautan disalin';

  @override
  String get noLinksFound => 'Tidak ada tautan yang ditemukan';

  @override
  String get roomStorageRanking => 'Peringkat Penyimpanan Ruangan';

  @override
  String get downloadComplete => 'Pengunduhan selesai';

  @override
  String get downloading => 'Mengunduh...';

  @override
  String get draftSaved => 'Draf disimpan';

  @override
  String get voiceRecording => 'Rekaman Suara';

  @override
  String get searchLocation => 'Lokasi Pencarian';

  @override
  String get tapToSearch => 'Ketuk untuk mencari';

  @override
  String get settingsThisDevice => 'Perangkat ini';

  @override
  String get settingsJustNow => 'Baru saja';

  @override
  String get settingsDeviceId => 'ID Perangkat';

  @override
  String get settingsStatus => 'Status';

  @override
  String get settingsLastActive => 'Terakhir aktif';

  @override
  String get settingsIpAddress => 'alamat IP';

  @override
  String get settingsRenameDevice => 'Ganti nama perangkat';

  @override
  String get settingsDeviceNameHint => 'Masukkan nama perangkat';

  @override
  String get settingsDeviceRenamed => 'Perangkat diganti namanya';

  @override
  String get settingsRenameFailed => 'Gagal mengganti nama';

  @override
  String get settingsRemoteLogout => 'Logout jarak jauh';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return 'Apakah Anda yakin ingin keluar \"$deviceName\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get settingsDeviceLoggedOut => 'Perangkat keluar';

  @override
  String get settingsLogoutFailed => 'Gagal keluar';

  @override
  String get settingsLogout => 'Keluar';

  @override
  String get settingsVerifyIdentity => 'Verifikasi identitas';

  @override
  String get settingsEnterPasswordToConfirm =>
      'Masukkan kata sandi Anda untuk mengonfirmasi tindakan ini.';

  @override
  String get scheduledSendTitle => 'Jadwalkan pesan';

  @override
  String get scheduledSendInOneHour => 'Dalam 1 jam';

  @override
  String get scheduledSendTonight => 'Malam ini (20.00)';

  @override
  String get scheduledSendTomorrowMorning => 'Besok pagi (09.00)';

  @override
  String get scheduledSendCustom => 'Pilih tanggal & waktu';

  @override
  String get scheduledMessageLabel => 'Dijadwalkan';

  @override
  String get scheduledMessageCancel => 'Batalkan pesan terjadwal';

  @override
  String get chatLockTitle => 'Kunci obrolan';

  @override
  String get chatLockEnable => 'Kunci obrolan ini';

  @override
  String get chatLockDisable => 'Buka kunci obrolan ini';

  @override
  String get chatLockDescription =>
      'Obrolan yang terkunci memerlukan verifikasi biometrik atau PIN untuk dapat dibuka';

  @override
  String get chatLockVerifyTitle => 'Obrolan terkunci';

  @override
  String get chatLockVerifySubtitle => 'Verifikasi untuk mengakses obrolan ini';

  @override
  String get chatLockVerifyFailed => 'Verifikasi gagal';

  @override
  String get chatLockEnabled => 'Obrolan terkunci';

  @override
  String get chatLockDisabled => 'Obrolan tidak terkunci';

  @override
  String get chatLockPinTitle => 'Masukkan PIN';

  @override
  String get chatLockPinSetTitle => 'Setel PIN';

  @override
  String get chatLockPinConfirmTitle => 'Konfirmasi PIN';

  @override
  String get chatLockPinMismatch => 'PIN tidak cocok';

  @override
  String get chatLockUseBiometric => 'Gunakan biometrik';

  @override
  String get chatLockUsePin => 'Gunakan PIN';

  @override
  String get mediaEditorUndo => 'Membatalkan';

  @override
  String get mediaEditorRedo => 'Ulangi';

  @override
  String get mediaEditorCrop => 'Pangkas';

  @override
  String get mediaEditorFilter => 'Menyaring';

  @override
  String get mediaEditorDraw => 'Menggambar';

  @override
  String get mediaEditorText => 'Teks';

  @override
  String get aiAssistant => 'Asisten AI';

  @override
  String get aiAssistantWelcome =>
      'Halo! Saya Asisten AI N42. Apa yang bisa saya bantu?';

  @override
  String get aiAssistantNotConfigured => 'Layanan AI tidak dikonfigurasi';

  @override
  String get aiAssistantSettings => 'Pengaturan AI';

  @override
  String get aiAssistantClearHistory => 'Hapus riwayat obrolan';

  @override
  String get aiAssistantClearHistoryConfirm =>
      'Apakah Anda yakin ingin menghapus semua riwayat obrolan AI?';

  @override
  String get aiAssistantStopGenerating => 'Berhenti menghasilkan';

  @override
  String get aiAssistantModel => 'Model';

  @override
  String get aiAssistantTemperature => 'Suhu';

  @override
  String get aiAssistantMaxTokens => 'Token maksimal';

  @override
  String get aiAssistantContextWindow => 'Jendela konteks';

  @override
  String get aiAssistantServiceStatus => 'Status layanan';

  @override
  String get aiAssistantAvailable => 'Tersedia';

  @override
  String get aiAssistantUnavailable => 'Tidak tersedia';

  @override
  String get aiSummarize => 'Ringkasan AI';

  @override
  String aiSummarizeUnread(int count) {
    return 'Ringkaslah $count pesan yang belum dibaca';
  }

  @override
  String get aiSummarizeLoading => 'Meringkas...';

  @override
  String get aiSummarizeError => 'Gagal meringkas';

  @override
  String get aiRewrite => 'Penulisan Ulang AI';

  @override
  String get aiRewriteFormal => 'Resmi';

  @override
  String get aiRewriteCasual => 'Santai';

  @override
  String get aiRewritePlayful => 'Menyenangkan';

  @override
  String get aiRewriteProfessional => 'Profesional';

  @override
  String get aiRewriteAccept => 'Gunakan';

  @override
  String get aiRewriteCancel => 'Batalkan';

  @override
  String get aiRewriteLoading => 'Menulis ulang...';

  @override
  String get aiLinkSummary => 'Ringkasan AI';

  @override
  String get aiLinkSummaryAnalyzing => 'Menganalisis...';

  @override
  String get chatFolderManagement => 'Kelola Folder';

  @override
  String get chatFolderSystem => 'Folder Sistem';

  @override
  String get chatFolderCustom => 'Folder Khusus';

  @override
  String get chatFolderEmpty => 'Belum ada folder khusus';

  @override
  String get chatFolderCreate => 'Buat Folder';

  @override
  String get chatFolderEdit => 'Sunting Map';

  @override
  String get chatFolderNameHint => 'Nama folder';

  @override
  String get chatFolderAll => 'Semua';

  @override
  String get chatFolderUnread => 'Belum dibaca';

  @override
  String get chatFolderPersonal => 'Pribadi';

  @override
  String get chatFolderGroups => 'Grup';

  @override
  String get chatFolderChannels => 'Saluran';

  @override
  String get chatFolderMuted => 'Dibungkam';

  @override
  String get storyAddMusic => 'Tambahkan Musik';

  @override
  String get storyChangeMusic => 'Ganti Musik';

  @override
  String get storyBackgroundMusic => 'Musik Latar Belakang';

  @override
  String get storyMusicPreview => 'Pratinjau (maks 15 detik)';

  @override
  String get storyChooseFromDevice => 'Pilih dari Perangkat';

  @override
  String get storyUseThisMusic => 'Gunakan Musik Ini';

  @override
  String get authPasskeyNotSupported =>
      'Kunci sandi tidak didukung pada perangkat ini';

  @override
  String get authPasskeyRegister => 'Daftarkan Kunci Sandi';

  @override
  String get authPasskeyNoRegistered => 'Tidak ada kunci sandi yang terdaftar';

  @override
  String get authPasskeyRegisterHint =>
      'Daftarkan kunci sandi untuk akun ini. Proses masuk dengan kunci sandi mandiri akan diaktifkan nanti.';

  @override
  String get authPasskeyNameYours => 'Beri nama Kunci Sandi Anda';

  @override
  String get authPasskeyRegistered => 'Kunci sandi disimpan ke akun ini';

  @override
  String get authPasskeyDeleted => 'Kunci sandi dihapus dari akun ini';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return 'Hapus kunci sandi \"$name\"? Anda harus mendaftarkannya lagi sebelum menggunakan login kunci sandi nanti.';
  }

  @override
  String get momentVisibilityPublic => 'Publik';

  @override
  String get momentVisibilityPrivate => 'Pribadi';

  @override
  String get momentVisibilityPartial => 'Teman Terpilih';

  @override
  String get momentVisibilityExcluded => 'Kecualikan Beberapa Teman';

  @override
  String momentUserMoments(String userName) {
    return 'Momen $userName';
  }

  @override
  String get momentForwardTo => 'Teruskan ke';

  @override
  String get momentForwardSuccess => 'Berhasil diteruskan';

  @override
  String get momentSelectFriends => 'Pilih Teman';

  @override
  String get momentSelectTags => 'Pilih berdasarkan Tag';

  @override
  String momentSelectedCount(int count) {
    return 'Dipilih ($count)';
  }

  @override
  String get momentNoMomentsYet => 'Belum ada momen';

  @override
  String get momentForwardMoment => 'Momen Maju';

  @override
  String get momentAddComment => 'Tambahkan komentar...';

  @override
  String momentForwardContent(String content) {
    return '[Momen] $content';
  }

  @override
  String get momentDeleteMoment => 'Hapus Momen';

  @override
  String get momentDeleteConfirm =>
      'Apakah Anda yakin ingin menghapus momen ini?';

  @override
  String get momentComment => 'Komentar';

  @override
  String get momentWriteComment => 'Tulis komentar...';

  @override
  String get momentLike => 'Suka';

  @override
  String get momentUnlike => 'Berbeda dengan';

  @override
  String get momentForward => 'Maju';

  @override
  String get momentDelete => 'Hapus';

  @override
  String get momentReply => 'membalas';

  @override
  String get momentMoment => 'Momen';

  @override
  String momentLikesCount(int count) {
    return '$count suka';
  }

  @override
  String momentCommentsCount(int count) {
    return 'Komentar $count';
  }

  @override
  String get momentNoComments => 'Belum ada komentar';

  @override
  String get momentFailedToLoad => 'Gagal memuat gambar';

  @override
  String momentReplyTo(String userName) {
    return 'Membalas ke $userName...';
  }

  @override
  String get momentNoConversations => 'Tidak ada percakapan';

  @override
  String get momentJustNow => 'sekarang';

  @override
  String momentMinutesAgo(int count) {
    return '${count}m yang lalu';
  }

  @override
  String momentHoursAgo(int count) {
    return '${count}h yang lalu';
  }

  @override
  String momentDaysAgo(int count) {
    return '${count}d yang lalu';
  }

  @override
  String get chatGroupAnnouncementHint => 'Masukkan pengumuman grup';

  @override
  String get chatGroupAnnouncementEmpty => 'Tidak ada pengumuman';

  @override
  String get chatEditNickname => 'Edit Nama Panggilan';

  @override
  String get chatNicknameHint => 'Masukkan nama panggilan Anda di grup ini';

  @override
  String get contactAddPhoneHint => 'Masukkan nomor telepon';

  @override
  String get contactNotesHint => 'Tambahkan catatan tentang kontak ini';

  @override
  String get reportTitle => 'Laporkan';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonHarassment => 'Pelecehan';

  @override
  String get reportReasonFraud => 'Penipuan';

  @override
  String get reportReasonOther => 'Lainnya';

  @override
  String get reportSubmitted => 'Laporan diserahkan';

  @override
  String get reportDescription => 'Deskripsi tambahan (opsional)';

  @override
  String get qrcodeSaved => 'Kode QR disimpan ke album';

  @override
  String get chatSendRedPacketInChat => 'Silakan kirim paket merah di chat';

  @override
  String get commonSaveFailed => 'Gagal menyimpan';

  @override
  String get reportSelectReason => 'Silakan pilih alasannya';

  @override
  String get gameCenter => 'Permainan';

  @override
  String get gameHighScore => 'Terbaik';

  @override
  String get gameScore => 'Skor';

  @override
  String get gameOver => 'Permainan Selesai';

  @override
  String get gamePlayAgain => 'Main Lagi';

  @override
  String get gameLeaderboard => 'Papan Peringkat';

  @override
  String get gamePause => 'Dijeda';

  @override
  String get gameResume => 'Ketuk untuk lanjut';

  @override
  String get gameConfirmExit => 'Keluar dari permainan?';

  @override
  String get gameNoScores => 'Belum ada skor';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'Gabungkan ubin hingga 2048';

  @override
  String get gameBlockDrop => 'Blokir Jatuhkan';

  @override
  String get gameBlockDropDesc => 'Jatuhkan dan hapus baris';

  @override
  String get gameMinesweeper => 'Penyapu Ranjau';

  @override
  String get gameMinesweeperDesc => 'Temukan semua sel aman';

  @override
  String get gameMatch3 => 'Cocokkan 3';

  @override
  String get gameMatch3Desc => 'Cocokkan 3 permata atau lebih';

  @override
  String get gameMinesweeperEasy => 'Mudah';

  @override
  String get gameMinesweeperMedium => 'Sedang';

  @override
  String get gameMinesLeft => 'Sisa Ranjau';

  @override
  String get gameTimeLeft => 'Waktu';

  @override
  String get gameLevel => 'Tingkat';

  @override
  String get gameNext => 'Berikutnya';

  @override
  String get gameBestTime => 'Waktu Terbaik';

  @override
  String get gameNewRecord => 'Rekor Baru!';

  @override
  String get gameLines => 'Baris';

  @override
  String get storyMyStory => 'Kisahku';

  @override
  String get storageSmartCleanup => 'Pembersihan Cerdas';

  @override
  String get storageOldMediaFiles => 'File Media Lama';

  @override
  String get storageLargeFiles => 'File Besar';

  @override
  String get storageAppCache => 'Tembolok Aplikasi';

  @override
  String get storageSettings => 'Pengaturan Penyimpanan';

  @override
  String get storageAutoCleanup => 'Pembersihan Otomatis';

  @override
  String storageAutoCleanupDesc(int days) {
    return 'Secara otomatis membersihkan file yang lebih lama dari $days hari';
  }

  @override
  String get storageCleanupPeriod => 'Periode Pembersihan';

  @override
  String get storagePreserveThumbnails => 'Pertahankan Thumbnail';

  @override
  String get storagePreserveThumbnailsDesc =>
      'Simpan thumbnail gambar selama pembersihan';

  @override
  String get storageWarningHigh =>
      'Penggunaan penyimpanan tinggi. Pertimbangkan untuk membersihkan file lama.';

  @override
  String get storageWarningCritical =>
      'Penyimpanan sangat rendah. Harap bersihkan untuk mengosongkan ruang.';

  @override
  String storageFreed(String size, int count) {
    return 'Membebaskan $size (file $count)';
  }

  @override
  String storageDays(int days) {
    return '$days hari';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'Lihat semua ruangan $count';
  }

  @override
  String get storageNoFiles => 'Tidak ada file yang ditemukan';

  @override
  String get storageFilePinned => 'Disematkan';

  @override
  String storageDeleteSelected(int count) {
    return 'Hapus file $count yang dipilih? Mereka dapat diunduh ulang dari server.';
  }

  @override
  String get backupRestore => 'Cadangkan & Pulihkan';

  @override
  String get backupCreate => 'Buat Cadangan';

  @override
  String get backupCreateDesc =>
      'Cadangkan pengaturan dan kunci enkripsi Anda. Pesan akan dipulihkan dari server setelah login ulang.';

  @override
  String get backupIncludeKeys => 'Sertakan kunci enkripsi';

  @override
  String get backupIncludeKeysDesc =>
      'Diperlukan untuk membaca pesan terenkripsi';

  @override
  String get backupPasswordProtect => 'Perlindungan kata sandi';

  @override
  String get backupEnterPassword => 'Masukkan kata sandi cadangan';

  @override
  String get backupHistory => 'Riwayat Cadangan';

  @override
  String get backupNoBackups => 'Belum ada cadangan';

  @override
  String get backupRestore2 => 'Pulihkan';

  @override
  String get backupDelete => 'Hapus';

  @override
  String get backupDeleteConfirm =>
      'Apakah Anda yakin ingin menghapus cadangan ini? Hal ini tidak dapat dibatalkan.';

  @override
  String get backupRestoreFromFile => 'Pulihkan dari File';

  @override
  String get backupRestoreFromFileDesc =>
      'Impor file .n42backup dari perangkat lain atau cadangan sebelumnya.';

  @override
  String get backupChooseFile => 'Pilih File Cadangan';

  @override
  String get backupRestoring => 'Memulihkan...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'Cadangan dibuat: ruang $rooms, pesan $messages';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return 'Memulihkan pengaturan $settings dari ruang $rooms';
  }

  @override
  String backupFailed(String error) {
    return 'Pencadangan gagal: $error';
  }

  @override
  String get backupPasswordRequired => 'Cadangan ini dilindungi kata sandi';

  @override
  String get blocGroupNotFound => 'Grup tidak ditemukan';

  @override
  String blocGroupMembersInvited(int count) {
    return 'Anggota $count yang diundang';
  }

  @override
  String get blocGroupMemberRemoved => 'Anggota dihapus';

  @override
  String get blocGroupAdminRemoved => 'Adminnya dihapus';

  @override
  String get blocGroupLeft => 'Keluar dari grup';

  @override
  String get blocGroupDisbanded => 'Grup dibubarkan';

  @override
  String get blocGroupJoined => 'Bergabung dengan grup';

  @override
  String get blocGroupInviteDeclined => 'Undangan ditolak';

  @override
  String get blocGroupTokenGateUpdated => 'Gerbang token diperbarui';

  @override
  String get blocTransferProcessing => 'Memproses transfer...';

  @override
  String get blocTransferCancelled => 'Pemindahan dibatalkan';

  @override
  String get blocTransferFailed => 'Transfer gagal';

  @override
  String get blocPaymentProcessing => 'Memproses pembayaran...';

  @override
  String get blocPaymentFailed => 'Pembayaran gagal';

  @override
  String get groupMaxMembers => 'Batas Anggota';

  @override
  String get groupMaxMembersUnlimited => 'Tidak terbatas';

  @override
  String get groupMaxMembersHint =>
      'Masukkan batas (biarkan kosong hingga tidak terbatas)';

  @override
  String get groupMaxMembersUpdated => 'Batas anggota diperbarui';

  @override
  String get groupFull => 'Grup sudah mencapai kapasitasnya';

  @override
  String get groupChannels => 'Saluran Topik';

  @override
  String get groupChannelsEmpty => 'Belum ada saluran';

  @override
  String get groupChannelsCount => 'saluran';

  @override
  String get groupChannelCreate => 'Saluran Baru';

  @override
  String get groupChannelName => 'Nama Saluran';

  @override
  String get groupChannelTopic => 'Topik Saluran (opsional)';

  @override
  String get groupChannelDelete => 'Hapus Saluran';

  @override
  String get groupChannelDeleteConfirm =>
      'Hapus saluran ini? Semua pesan akan hilang.';

  @override
  String get groupBotSettings => 'Pengaturan Bot';

  @override
  String get groupBotEnabled => 'Aktifkan Bot';

  @override
  String get groupBotWelcomeMessage => 'Templat Pesan Selamat Datang';

  @override
  String get groupBotWelcomeHint =>
      'Gunakan \'nama\' sebagai pengganti nama anggota baru';

  @override
  String get groupBotConfigUpdated => 'Pengaturan bot diperbarui';

  @override
  String get groupContentFilter => 'Filter Konten';

  @override
  String get groupContentFilterEnabled => 'Aktifkan Filter Kata Kunci';

  @override
  String get groupContentFilterReplace => 'Ganti dengan ***';

  @override
  String get groupContentFilterHide => 'Sembunyikan Pesan';

  @override
  String get groupContentFilterAddWord => 'Tambahkan Kata Kunci';

  @override
  String get groupContentFilterUpdated => 'Filter konten diperbarui';

  @override
  String get chatSlashCommands => 'Perintah';

  @override
  String get chatCommandPoll => '/poll — Membuat jajak pendapat';

  @override
  String get chatCommandAnnounce => '/announce — Mengirim pengumuman';

  @override
  String get chatCommandWelcome =>
      '/selamat datang — Mengatur pesan selamat datang';

  @override
  String get chatReportMessage => 'Laporkan';

  @override
  String get chatReportReason => 'Alasan Laporan';

  @override
  String get chatReportSpam => 'Spam';

  @override
  String get chatReportHarassment => 'Pelecehan';

  @override
  String get chatReportInappropriate => 'Konten Tidak Pantas';

  @override
  String get chatReportOther => 'Lainnya';

  @override
  String get chatReportSuccess => 'Laporan diserahkan';

  @override
  String get spacesName => 'Nama Komunitas';

  @override
  String get spacesNameHint => 'misalnya Pedagang Kripto';

  @override
  String get spacesNameRequired => 'Nama wajib diisi';

  @override
  String get spacesDescription => 'Deskripsi';

  @override
  String get spacesDescriptionHint => 'Tentang apa komunitas ini?';

  @override
  String get spacesType => 'Tipe Komunitas';

  @override
  String get spacesPublicDesc => 'Siapa pun dapat menemukan dan bergabung';

  @override
  String get spacesPrivateDesc =>
      'Hanya anggota yang diundang yang dapat bergabung';

  @override
  String get spacesNotFound => 'Komunitas tidak ditemukan';

  @override
  String get spacesSearch => 'Telusuri komunitas...';

  @override
  String get spacesMembers => 'Anggota';

  @override
  String get spacesNoChannels => 'Belum ada saluran';

  @override
  String get spacesLeave => 'Keluar dari Komunitas';

  @override
  String spacesLeaveConfirm(String name) {
    return 'Apakah Anda yakin ingin keluar dari \"$name\"?';
  }

  @override
  String get spacesDelete => 'Hapus Komunitas';

  @override
  String spacesDeleteConfirm(String name) {
    return 'Tindakan ini akan menghapus \"$name\" dan semua salurannya secara permanen. Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get spacesCreateChannel => 'Tambahkan Saluran';

  @override
  String get spacesChannelName => 'Nama Saluran';

  @override
  String get spacesChannelTopic => 'Topik (opsional)';

  @override
  String get spacesDeleteChannel => 'Hapus Saluran';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return 'Apakah Anda yakin ingin menghapus \"#$name\"?';
  }

  @override
  String get spacesEditName => 'Sunting Nama';

  @override
  String get spacesEditDescription => 'Sunting Deskripsi';

  @override
  String spacesViewAllMembers(int count) {
    return 'Lihat semua anggota $count';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return 'Tendangan $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'Larangan $name';
  }

  @override
  String get spacesPromoteAdmin => 'Promosikan ke Admin';

  @override
  String get spacesDemoteAdmin => 'Hapus Admin';

  @override
  String get spacesInviteMember => 'Undang Anggota';

  @override
  String get spacesInviteMemberUserId =>
      'ID Pengguna (misalnya @user:server.com)';

  @override
  String get spacesSave => 'Simpan';

  @override
  String get settingsScreenshotProtection => 'Perlindungan Tangkapan Layar';

  @override
  String get settingsScreenshotProtectionDesc =>
      'Cegah tangkapan layar dan perekaman layar';

  @override
  String get chatSelfDestructTimer => 'Penghancuran diri';

  @override
  String get chatTimerPickerTitle => 'Timer penghancuran diri';

  @override
  String get chatTimerOff => 'Mati';

  @override
  String get onChainNotificationsTitle => 'Peristiwa On-chain';

  @override
  String get onChainMarkAllRead => 'Tandai semua dibaca';

  @override
  String get onChainNoNotifications => 'Belum ada peristiwa on-chain';

  @override
  String get onChainNoNotificationsDesc =>
      'Peristiwa dari saluran yang dilanggani akan muncul di sini';

  @override
  String get onChainViewDetails => 'Lihat detail';

  @override
  String get chatCommandHelp => '/help — Lihat semua perintah';

  @override
  String get chatCommandPrice => '/price — Dapatkan harga token';

  @override
  String get chatCommandBalance => '/balance — Lihat saldo dompet';

  @override
  String get chatCommandChains => '/chains — Daftar 236+ jaringan';

  @override
  String get chatMiniApps => 'Aplikasi';

  @override
  String get miniAppMarketTitle => 'Mini App';

  @override
  String get miniAppCategoryAll => 'Semua';

  @override
  String get miniAppSearch => 'Cari aplikasi...';

  @override
  String get miniAppFeatured => 'Unggulan';

  @override
  String get miniAppAllApps => 'Semua Aplikasi';

  @override
  String get miniAppNoResults => 'Aplikasi tidak ditemukan';

  @override
  String get slideToPayLabel => '→→→  Geser untuk konfirmasi';

  @override
  String get slideToPayConfirming => 'Mengkonfirmasi...';

  @override
  String get redPacketBestLuck => 'Keberuntungan terbaik';

  @override
  String get redPacketBestLuckCongrats =>
      'Keberuntungan terbaik! Kamu dapat paling banyak!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total diklaim';
  }

  @override
  String get redPacketStatsTotal => 'jumlah';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 Mendapat amplop merah • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id  •  alamat 0x  •  name.eth';

  @override
  String get web3SearchPlaceholder =>
      'Cari berdasarkan ID, dompet, atau ENS...';

  @override
  String get web3WalletAddress => 'Alamat dompet';

  @override
  String get web3AddressCopied => 'Alamat disalin';

  @override
  String get web3Copy => 'Salin';

  @override
  String get web3SendMessage => 'Kirim pesan';

  @override
  String get web3SendToWallet => 'Pesan ke dompet';

  @override
  String get web3WalletOnlyHint =>
      'Alamat ini belum memiliki akun N42. Pesan akan terkirim setelah bergabung.';

  @override
  String get web3NftAvatar => 'Avatar NFT';

  @override
  String get web3ResolveFailed => 'Gagal memuat identitas';

  @override
  String web3EnsNotFound(String name) {
    return 'Nama ENS \"$name\" tidak ditemukan';
  }

  @override
  String get web3NoN42AccountTitle => 'Tidak ada akun N42';

  @override
  String get web3NoN42AccountDesc =>
      'Alamat dompet ini belum memiliki akun N42. Anda dapat membagikan tautan undangan N42 Anda kepada mereka untuk memulai.';

  @override
  String get web3ShareInvite => 'Bagikan undangan';

  @override
  String get nftPickerTitle => 'Pilih avatar NFT';

  @override
  String get nftPickerTabPopular => 'Populer';

  @override
  String get nftPickerTabCustom => 'Kustom';

  @override
  String get nftPickerChain => 'Rantai';

  @override
  String get nftPickerContract => 'Alamat Kontrak';

  @override
  String get nftPickerTokenId => 'ID Token';

  @override
  String get nftPickerVerifyOwnership => 'Verifikasi kepemilikan & pratinjau';

  @override
  String get nftPickerUseAsAvatar => 'Gunakan sebagai avatar';

  @override
  String get nftPickerPreview => 'Pratinjau';

  @override
  String get nftPickerNotOwned => 'Anda tidak memiliki NFT ini';

  @override
  String get nftPickerInvalidTokenId => 'ID token tidak valid';

  @override
  String get nftPickerEnterBoth => 'Masukkan alamat kontrak dan ID token';

  @override
  String get nftPickerInfoTitle => 'Avatar NFT — Terverifikasi on-chain';

  @override
  String get nftPickerInfoDesc =>
      'Ikat NFT yang Anda miliki sebagai avatar Anda. Siapa pun dapat memverifikasi kepemilikan secara on-chain. Ditampilkan dengan cincin emas di N42.';

  @override
  String get nftPickerPopularCollections => 'Koleksi populer';

  @override
  String get nftPickerWalletHint =>
      'Hubungkan dompet N42 Anda untuk menemukan NFT Anda di 236+ rantai.';

  @override
  String get profileBindNftAvatar => 'Ikat Avatar NFT';

  @override
  String get profileChangeAvatar => 'Ubah Avatar';

  @override
  String get groupTopics => 'Topik';

  @override
  String get groupTopicsEmpty => 'Belum ada topik';

  @override
  String get syncInProgress => 'Menyinkronkan riwayat pesan...';

  @override
  String get recoveryKeyReminderTitle => 'Lindungi pesan Anda';

  @override
  String get recoveryKeyReminderDesc =>
      'Buat kunci pemulihan untuk menyinkronkan pesan terenkripsi dengan aman di seluruh perangkat';

  @override
  String get recoveryKeySetupNow => 'Siapkan sekarang';

  @override
  String get recoveryKeyRemindLater => 'Ingatkan saya nanti';

  @override
  String get channelReadOnly =>
      'Hanya admin yang dapat memposting di saluran ini';

  @override
  String get channelSubscribers => 'pelanggan';

  @override
  String get channelVerified => 'Saluran terverifikasi';

  @override
  String get redPacketHistory => 'Sejarah Paket Merah';

  @override
  String get redPacketSent => 'Terkirim';

  @override
  String get redPacketReceived => 'Diterima';

  @override
  String get redPacketExpired => 'Kedaluwarsa';

  @override
  String get redPacketClaimed => 'Diklaim';

  @override
  String get redPacketInsufficientBalance => 'Saldo tidak mencukupi';

  @override
  String selfDestructCountdown(String time) {
    return 'Penghancuran diri di $time';
  }

  @override
  String get messageDestroyed => 'Pesan hancur';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'Izin ditolak: $permission';
  }

  @override
  String get aiSuggestionGasFee => 'Berapa biaya Gas?';

  @override
  String get aiSuggestionDefi => 'Panduan Pemula DeFi';

  @override
  String get aiSuggestionSecurity => 'Cara memeriksa keamanan kontrak';

  @override
  String get aiSuggestionBridge => 'Jembatan lintas rantai';

  @override
  String get channelDiscoverTitle => 'Temukan Saluran';

  @override
  String get channelDiscoverSearch => 'Cari saluran...';

  @override
  String get channelJoin => 'Bergabunglah';

  @override
  String get channelJoined => 'Bergabung';

  @override
  String get channelCategory => 'Kategori';

  @override
  String slowModeCooldown(int seconds) {
    return 'Mode lambat: tunggu ${seconds}s';
  }

  @override
  String get addressCopyAction => 'Salin Alamat';

  @override
  String get addressSendMessage => 'Kirim Pesan';

  @override
  String get addressViewProfile => 'Lihat Profil';

  @override
  String get sendToAddress => 'Kirim ke alamat dompet';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'Gagal mengirim kode verifikasi';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'Server ini tidak mendukung pengaturan ulang kata sandi email';

  @override
  String get blocAuthResetPasswordFailed => 'Gagal menyetel ulang sandi';

  @override
  String get blocAuthChangePasswordFailed => 'Gagal mengubah kata sandi';

  @override
  String get blocAuthOldPasswordWrong => 'Kata sandi saat ini salah';

  @override
  String get blocAuthLoginCancelled => 'Masuk dibatalkan';

  @override
  String get blocAuthGoogleLoginFailed => 'Gagal masuk Google';

  @override
  String get blocAuthAppleLoginFailed => 'Gagal masuk Apple';

  @override
  String get blocAuthSsoLoginFailed => 'Gagal masuk SSO';

  @override
  String get blocAuthFacebookLoginFailed => 'Gagal masuk Facebook';

  @override
  String get blocAuthTwitterLoginFailed => 'Gagal masuk Twitter';

  @override
  String get blocAuthWeChatLoginFailed => 'Login WeChat gagal';

  @override
  String get blocAuthWeChatNotConfigured => 'Login WeChat tidak dikonfigurasi';

  @override
  String get blocAuthWeChatNotInstalled =>
      'Silakan instal WeChat terlebih dahulu';

  @override
  String get blocAuthPasswordWrong => 'Kata sandi salah';

  @override
  String get blocAuthEmailAlreadyBound =>
      'Email ini sudah terikat dengan akun lain';

  @override
  String get blocAuthChangeEmailFailed => 'Gagal mengubah email';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'Kode verifikasi salah atau kedaluwarsa';

  @override
  String get blocAuthSessionExpired =>
      'Sesi telah habis, silakan login kembali';

  @override
  String get blocAuthSessionIncomplete =>
      'Data sesi tidak lengkap, silakan login kembali';
}

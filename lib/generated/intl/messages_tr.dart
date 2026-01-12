// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'tr';

  static String m0(value) => "Ben ${value}";

  static String m1(value) => "Sohbet üyesi(${value})";

  static String m2(value) =>
      "${value} kişisini arkadaş olarak eklemek istediğinizden emin misiniz";

  static String m3(value) =>
      "Zaten bağlandınız ve şu anda yeniden bağlanamıyorsunuz. Bağlama adresi: ${value}.";

  static String m4(value) => "Bağlama başarılı. Bağlama adresi: ${value}";

  static String m5(value) => "${value} cüzdanında N42chain yok!";

  static String m6(value) => "Eşleşme başarılı. Adres:${value}.";

  static String m7(value) => "${value} değerinden büyük miktar.";

  static String m8(value) => "Bu cüzdan zaten mevcut, cüzdan adı \"${value}\"";

  static String m9(value) => "${value} değerinden fazla bir miktar girin.";

  static String m10(value) =>
      "${value} kişisini silmek istediğinizden emin misiniz?";

  static String m11(value) => "Yeterli \"${value}\" bakiyeniz yok";

  static String m12(value) => "\"${value}\" hesabı alınamadı";

  static String m13(value) => "İlk transfer için minimum ${value} XRP";

  static String m14(value) => "${value} zinciri eklenmedi.";

  static String m15(value) =>
      "${value} için tamamlanmamış işlemler var, lütfen daha sonra tekrar deneyin.";

  static String m16(value) => "${value} için adres bulunamadı.";

  static String m17(value) => "${value} bakiyesi yetersiz.";

  static String m18(value, value1) =>
      "Her XRP hesabı, harcanamayan temel olarak ${value} XRP (${value1} damla) ayırmalıdır.";

  static String m19(value, value1) =>
      "Hesabın sahip olduğu her nesne için ${value} XRP (${value1} damla) rezerve eklenir.";

  static String m20(value, value1) =>
      "Bu hesap ${value} nesneye sahip, yani ek ${value1} XRP ayrılmış.";

  static String m21(value) =>
      "Desen şifresi giriş hatası, ${value} hakkınız kaldı";

  static String m22(value) =>
      "Desen şifresi giriş hatası, ${value} hakkınız kaldı";

  static String m23(value) =>
      "Başarıyla bir ${value} kurdunuz ve N42Wallet ile doğrulamaya başlayacaksınız!";

  static String m24(value) =>
      "@N42Wallet\'ta ${value} grubuma katılarak bir Layer 1 zincirinin erken madencisi olun ve telefonunuzda kripto kazanın!";

  static String m25(value) =>
      "Doğrulayıcı çalıştırmak için ${value} N kilitleyin.";

  static String m26(value) => "İçe aktarma başarısız:${value}";

  static String m27(value, value1) =>
      "Her ${value1} blok kazıldığında ${value} N";

  static String m28(value) => "${value} karakter olmalı";

  static String m29(value) => "${value} Yetersiz Bakiye.";

  static String m30(value) => "${value} geliyor...";

  static String m31(value) =>
      "Uygulama içinde takas edilen ${value}, kısa süre içinde cüzdanınıza dağıtılacak ve bu işlemle satılamaz. Düğüm çalıştırmak için kullanılabilir.";

  static String m32(value) => "Maksimum ${value} karakter";

  static String m33(value) =>
      "${value} zinciri uygulama tarafından zaten destekleniyor!";

  static String m34(value) =>
      "${value} zinciri uygulama tarafından zaten destekleniyor, eklemek istiyor musunuz?";

  static String m35(value) => "${value} adres test bağlantısı başarısız!";

  static String m36(value) =>
      "Uygulama ${value} saniye içinde kilidini açacak.";

  static String m37(value) =>
      "Desen şifresi giriş hatası, ${value} hakkınız kaldı";

  static String m38(value) => "Şifre giriş hatası, ${value} hakkınız kaldı";

  static String m39(value) => "Şifre giriş hatası, ${value} hakkınız kaldı";

  static String m40(value) => "${value} şifresini girin";

  static String m41(value) => "0~${value} karakter";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("Kayıt ol"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Hesabınızı oluşturun",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Düzenle"),
    "Verification": MessageLookupByLibrary.simpleMessage("Doğrulama"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Adres Bilgisi",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Hesap bir günlüğüne geçici olarak kilitlendi",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "Kod yanlış. Lütfen tekrar deneyin.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Başarıyla kopyalandı"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Adresi Kopyala"),
    "descO": MessageLookupByLibrary.simpleMessage("Açıklama(İsteğe bağlı)"),
    "editPhoto": MessageLookupByLibrary.simpleMessage("Fotoğrafı düzenle"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Doğrulama kodu alınamadı",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Doğrulama kodu başarıyla gönderildi, lütfen e-postanızı kontrol edin",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Doğrulama kodu hatası",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Geçersiz e-posta adresi",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "E-posta Adresi Doğrulama",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "E-posta Adresi Doğrulayıcı uygulaması, çekimlerinizi ve N42Wallet hesabınızı korur.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "E-posta doğrulaması eklensin mi?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Dosya"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Tokenlar yalnızca aynı ağ içinde gönderilebilir. Diğer ağlardan gönderim kayba neden olabilir.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Almak için tarayın",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage("Lütfen URL girin"),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("Açıklama girin"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Tarayıcı"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Tarayıcı Önbelleğini Temizle",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "DApp\'e otomatik bağlan",
    ),
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Lütfen DApp\'e bağlanmayı onaylayın",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Tümünü kapat"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Tamam"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Yer İmleri"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Henüz yer imi eklenmedi",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Yer İmi"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Ad"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage("Lütfen ad girin"),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Açıklama"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage("Grup sohbeti başlat"),
    "g_chat_key_10": m0,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Arkadaş davet et"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("Kişi seç"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Bitti"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage("En az 2 kişi seçin"),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Arkadaş detayı"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Grup detayı"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "Daha fazla grup üyesini görüntüle",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Grup adı"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Yeni arkadaş"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "Grubu dağıtmak istediğinizden emin misiniz?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "Bu gruptan ayrılmak istediğinizden emin misiniz?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("Grubu dağıt"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Gruptan ayrıl"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage(
      "Grup sohbet adını değiştir",
    ),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "Grup sohbet adı değiştiğinde, diğer üyeler grup içinde bilgilendirilecektir.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Bitti"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage(
      "Arkadaş ekleme isteği",
    ),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Sizi arkadaş olarak ekleme isteği",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "Arkadaşlık isteği onaylandı",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Eklendi"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "Arkadaş olarak eklendiz",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("kabul et"),
    "g_chat_key_32": m1,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "Şifre düzgün ayrıştırılamıyor ve mesaj geçici olarak gönderilemiyor. Lütfen gruba girerken cüzdanı içe aktarın",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage(
      "Sohbet geçmişi silinsin mi?",
    ),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("Üyeyi kaldır"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("QR Kodum"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Süresi doldu"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Şikayet Et"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("Yeni Sohbet"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Yeni Grup"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("QR Kodu"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage(
      "Şikayet Et ve Engelle",
    ),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "Bu mesaj N42Wallet\'a iletilecek. Bu kişi bilgilendirilmeyecek.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Video"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Fotoğraf"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("Mesajı Sil"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage("Cihazımdan sil"),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Bekle"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Kabul Et"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage("Şikayet Nedeni"),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      "Şikayet nedeninizi girin",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "Şikayetinizi doğrulayacak ve 24 saat içinde yanıt vereceğiz.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "Bunu şikayet ettiniz - Görmek için tıklayın",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Kara Liste"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Kaldır"),
    "g_chat_key_6": m2,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage("Henüz kişi yok"),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Bugün"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage(
      "3 günden fazla önce",
    ),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Engelle"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "Hey, sohbet etmek ve para göndermek için N42Wallet kullanıyorum. Wallet\'ı kurun ve bana mesaj atın",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Yanıtla"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage("Mesaj silindi"),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage(
      "Birisi beni etiketledi",
    ),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Merhaba de"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Arkadaş ekle"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage("başvuru nedeni"),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("İşlemler"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Bağlan"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage(
      "Kullanılabilir Ağlar",
    ),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("Mesaj imzalama"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Bağlanıyor"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Eşleştiriliyor, lütfen bekleyin.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Bağlantıyı Kes"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Reddet"),
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Biyometrik Tarama İpuçları",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Kimlik doğrulama için parmak izinizi veya yüzünüzü tarayın.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "Biyometrik tarama başarısız oldu",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("İpuçları"),
    "g_face_4": MessageLookupByLibrary.simpleMessage(
      "Biyometrik tarama başarılı",
    ),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Ayarla"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "Biyometrik giriş ayarlamadınız. Ayarlamak için Sistem Ayarlarına gidin.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Devam etmek için yüzünüzü veya parmak izinizi tarayın.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Geri"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "Biyometriği yeniden etkinleştirmeniz önerilir.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Yüz eşleştirme yöntemi",
    ),
    "g_face_match_key10": m3,
    "g_face_match_key11": m4,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage("Yeniden bağla"),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Bağla"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Doğrula"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "Yüz verilerinizi doğrudan bir cüzdan adresine bağlayabilirsiniz (daha önce bağladıysanız, eski cüzdan adresi üzerine yazılır) veya daha önce bir cüzdan adresi bağladıysanız, bağlı cüzdan adresini almak için manuel olarak doğrulayabilirsiniz.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "Yüz verilerinize bağlı cüzdan adresi aşağıdaki gibi tespit edildi, ancak bu cüzdanı henüz cüzdan listenize aktarmadınız.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "Yüz verilerinizi bu cüzdanla bağladınız.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage(
      "Kullanıcı Bildirimi",
    ),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "Yüz Bağlama Nedir?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "Yüz bağlama, biyometrik yüz özelliklerinizi blokzincir cüzdan adresinizle eşleştirmek için yüz tanıma teknolojisini kullanır.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "Bu süreç yalnızca işlem kolaylığını artırmakla kalmaz, aynı zamanda hesap güvenliğini de güçlendirir ve her eylemin sizin tarafınızdan yetkilendirilmesini sağlar.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "Yüz Bağlama Neden Gerekli?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "Yüz verilerinizi bağlayarak, kimliğiniz doğrudan işlem etkinliklerine bağlanır, kimlik doğrulama sürecini basitleştirir ve operasyonel verimliliği artırır. Bu teknoloji, varlık transferi veya sözleşmelerle etkileşim gibi hassas işlemler gerçekleştirirken hızlı ve güvenli kimlik doğrulaması sağlar.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "Yüz Verilerim Nasıl Saklanır ve Güvenli mi?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "Yüz verileriniz, herhangi bir merkezi veritabanında değil, genel bir blokzincirde şifreli formda saklanır. Bu, sistemin yalnızca sizin tarafınızdan yetkilendirildiğinde verilerinizi şifre çözerek kimlik doğrulama için kullanabileceği anlamına gelir, gizliliğinizi ve veri güvenliğinizi sağlar.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "Yüz Bağlama Hesap Güvenliğimi Nasıl Etkiler?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "Yüz bağlama, tüm hassas işlemlerin yalnızca açık yetkinizle gerçekleştirilmesini sağlayarak hesap güvenliğinizi artırır. Biyometrik verilerinizi korumak ve yetkisiz erişimi önlemek için sektör lideri şifreleme teknolojisi kullanıyoruz.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "Yüz Verilerim Güvenli mi?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Kesinlikle. Tüm biyometrik veriler sıkı şifrelemeden geçer ve veri iletimi ve depolama için en yüksek güvenlik standartları izlenir. Sistem bu verileri yalnızca kimlik doğrulamayı tamamlamak için gerekli olduğunda şifre çözecektir.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage(
      "Eşleşme başarısız!",
    ),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Anladım"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Cüzdan adresi seç",
    ),
    "g_face_match_key32": m5,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage(
      "Bağlantıyı kaldırma",
    ),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Yüz verisi doğrulaması başarısız!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Yüz verisi bağlantı kaldırma başarısız!",
    ),
    "g_face_match_key4": m6,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage("Adres hatası!"),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Yüz Verisi Bağlama",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage("Yüz eşleştirme"),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("Yeniden seç"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Eşleştir"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Haberler"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Doğrulama"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Mesajlar"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Öğren"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Arkadaş davet et"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Kaldırma başarısız!"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Gönder"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Gas limiti"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("Daha fazla yok"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Yükleniyor "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Adres Defteri"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Cüzdan içe aktar"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Yönet"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Yeni adres"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Sil"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Kaydet"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Kopyala"),
    "g_key_12": MessageLookupByLibrary.simpleMessage(
      "Cüzdan oluştur/içe aktar",
    ),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Tema"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("Sistem"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Açık"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Koyu"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Cüzdan Listesi"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Veri yok"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Geçersiz miktar"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Ana Cüzdan"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("İşlem başarılı"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Yanlış şifre"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Test ağı"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Ana ağ"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Sistem dili"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Ana Cüzdan Olarak Ayarla",
    ),
    "g_key_154": MessageLookupByLibrary.simpleMessage("Gönder"),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Cüzdan adresi"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Adresi kopyalamak için tarayın",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Ekle"),
    "g_key_16": MessageLookupByLibrary.simpleMessage("Doğrulama Cüzdanı Seç"),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Sembol"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Yapıştır"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Zincir Seç"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("İşlem başarısız"),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "Bu benim cüzdan adresim",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Diğer"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Başarıyla kaydedildi"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Başarılı"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Cüzdanı silmek istediğinizden emin misiniz?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Aktif"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Kameraya erişim izni yok.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Gezgin"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Maksimum"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Varlıklar"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("Defter boş!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("İşlem Özeti"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Bağlantı hatası, QR kodunu tekrar tarayın.",
    ),
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "Fotoğraf albümüne erişim izni yok.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Şifre Düzenle"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Eski Şifre"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Bakiyeler senkronize ediliyor...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Özel Anahtar"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("Cüzdan şifresini girin"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Özel anahtar hatası"),
    "g_key_211": MessageLookupByLibrary.simpleMessage("Satın Al"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Sat"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Piyasa Bilgisi"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage("Şifreler eşleşmiyor."),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Bakiye"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Ekleme başarısız!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Al"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Transfer"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("Alıcı"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("QR kodu tara"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("Cüzdan adresi girin"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Kullanılabilir Bakiye"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Miktar"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Bu işlemi karşılamak için yeterli bakiye yok.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Gönder"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Yükleme başarısız!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Cüzdan"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Oluştur"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("Gönderen"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Onayla"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("İptal"),
    "g_key_8": MessageLookupByLibrary.simpleMessage("Not"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Kurtarma ifadesi"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Tüm tokenlar"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Ayarlar"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Adres"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Lütfen bir ad girin",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Lütfen adres girin",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Lütfen bir coin türü seçin",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("Adresi düzenle"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage(
      "Başarıyla silindi",
    ),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Coin Seç"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Coin ara"),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "Yanıt verisi ayrıştırma hatası!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Dio Hatası"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "İstek sözdizimi hatası",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Yetkisiz, lütfen giriş yapın",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Erişim reddedildi"),
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Yanlış hesap veya şifre",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("İstek hatası"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "Başka bir telefonda zaten giriş yaptınız ve zorla çıkış yapıldı.",
    ),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "İstek zaman aşımına uğradı",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("Sunucu anormal"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Hizmet uygulanmadı",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Ağ geçidi hatası"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Hizmet kullanılamıyor",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Ağ geçidi zaman aşımı",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "HTTP sürümü desteklenmiyor",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "İstek başarısız, hata kodu:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "Sistem meşgul, lütfen daha sonra tekrar deneyin",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "İstek sıklığı çok yüksek",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage("Çözme başarısız"),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "İşlem zaten zincirde",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Sertifika yapılandırma hatası!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Durum kodu yapılandırma hatası!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("Bilinmeyen hata!"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Ağ bağlantısı zaman aşımına uğradı, lütfen ağ ayarlarını kontrol edin!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "Sunucu anormal. Lütfen daha sonra tekrar deneyin!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "İstek iptal edildi, lütfen tekrar deneyin!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Keystore Dışa Aktar",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "Yedekleme İpuçları",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Saklamak için şifre yönetim aracı kullanın.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Kopyalandı"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Kopyalama iptal edildi",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Kimlik cüzdanı",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Şifreli özel anahtar dosyası.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "İçe aktarma yöntemi",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Keystore dosyası",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Lütfen Keystore bilgisini girin.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Özel Anahtarı Dışa Aktar",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Keystore ve şifrenin elde edilmesi, sahibine cüzdan varlıkları üzerinde tam kontrol sağlar.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Dikkatlice kaydedin ve güvenli bir yerde saklayın. Birden fazla fiziksel kopya tutmak en güvenli saklama yöntemidir.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Özel anahtarınız kaybolursa, geri alınamaz. Fiziksel olarak yedekleyin ve güvenli bir şekilde saklayın.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Çevrimdışı kaydet",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Güvenli olmayan herhangi bir e-posta, not defteri, ağ sürücüsü veya sohbet yazılımına kaydetmeyin.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Lütfen ağ iletimi kullanın",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Lütfen ağ araçları aracılığıyla ilettiğinizden emin olun, Hackerlar elde ederse, onarılamaz ekonomik kayıplara neden olur",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Kaydetmek için araçlar kullanın",
    ),
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Geri Bildirim"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Lütfen geri bildirim bilgisini doldurun",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "Yüklenmemiş ekler var",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage(
      "Gönderim Başarısız",
    ),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage(
      "Başarıyla gönderildi",
    ),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Ekler"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "En fazla 5 ek yükleyin, her ek 100MB\'dan büyük olamaz",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Başarısız"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage("Tekrar deneyin"),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage(
      "Lütfen giriş yapın",
    ),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Mevcut para birimi cüzdanı zaten var.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Keystore okunamadı",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Giriş Yap"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Çıkış Yap"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Uygulamadan çıkmak istediğinizden emin misiniz?",
    ),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Tarayıcı"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Piyasa Değeri"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("İşlem Hacmi"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Toplam Arz"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("Dolaşımda"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Hakkında"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Daha Fazla"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Bağlantılar"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Web sitesi"),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Lütfen kurtarma ifadesini girin",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Toplam"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Kamera"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Fotoğraf seç"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("İçerik"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Ad"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Geri"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("İşlem gönderildi"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Video seç"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Telefon galerisinden seç",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "QR kodunu paylaş",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Bağlantı paylaş"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Paylaşım yöntemi",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Sohbet"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Dosya yüklemek için çok büyük",
    ),
    "g_key_squad_k15": m10,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("Kişi Ekle"),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Kişi"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage("E-posta ile ara"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Tamamlandı"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Gas fiyatı"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Maksimum gas ücreti"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Gas başına maksimum ücret",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Beklemede"),
    "g_key_t_29": m11,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Başarısız"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("Madenci Ücreti"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Devam"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Cüzdan şifresi"),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "Cüzdan şifresi boş olamaz",
    ),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage("Yanlış cüzdan şifresi"),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Lütfen cüzdan şifresini girin",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("Gas Ücret Oranı"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "En son blok Gas Ücret Oranı ortalaması",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Giden transfer"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "0\'dan büyük tam sayı girin.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage("Veri alınamadı"),
    "g_key_t_45": m12,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Alıcı adres hesabını kontrol et",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Bul"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Hesap yok"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Gelen transfer"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Geçersiz adres"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Hesap doğrulaması başarılı",
    ),
    "g_key_t_52": m13,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "Alıcı adresin hesabı yok ve ilk transfer en az 10XRP olmalıdır",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Kullanılan Gas"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("İşlem geçmişi"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("İşlem Detayı"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Lütfen işlem makbuzlarını geçmişte görüntüleyin",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Harcanan miktar"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Alınan miktar"),
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("NFT Türleri"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Takipçiler"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Kullanıcı Türleri"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Web sitesi"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Ürün bağlantısı"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("Medya platformları"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("Cüzdan adresi"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Takma ad"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage(
      "Avatar yükleme başarısız",
    ),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Açıklama"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage("Sanatçı bilgisi"),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage("Sanatçı değilsiniz"),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Sanatçı olmak için başvurmak üzere buraya tıklayın",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Ad"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Gelir"),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage(
      "Okudum ve kabul ediyorum ",
    ),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage(
      "Şartlar ve Koşullar",
    ),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Gizlilik Politikası ve Kişisel Bilgi Toplama Beyanı",
    ),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage("En son sürüm bulundu"),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Hemen güncelle"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("Yeni sürüm bulundu"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Zaten en son sürümdasınız",
    ),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Kurtarma İfadesini Görüntüle",
    ),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Lütfen kurtarma ifadenizi kaydettiğinizden ve güvenli bir şekilde sakladığınızdan emin olun.",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Şimdi kurtarma ifadenizi tekrar yazmayı deneyin.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("Hesap İçe Aktar"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Hesap Oluştur"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("Hazırsınız!"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Artık cüzdanınızın keyfini tam olarak çıkarabilirsiniz.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Başla"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("Şimdilik atla"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Şimdilik kurtarma ifadesini yedeklemeyi atlayabilir ve gerektiğinde Ayarlar\'da tekrar yapabilirsiniz.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage(
      "Doğrudan oluştur",
    ),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "başarıyla oluşturuldu",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Cüzdan detaylarınızı kontrol etmek veya keystore dışa aktarmak istiyorsanız, Kenar Çubuğu > Cüzdanı Yönet bölümüne gidebilirsiniz",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Keystore\'umu dışa aktar",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Cüzdanınızı yedekleyerek güvence altına alın",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Keystore, güvenlik sertifikaları ve ilişkili özel anahtarların deposudur.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Adım 1: Cüzdanı Yönet\'e gidin.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Adım 2: Cüzdan Adresi seçin.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Adım 3: Keystore Dışa Aktar\'a basın.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Cüzdanı Yönet\'e Git",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage("Ana sayfaya dön"),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("Cüzdan Ekle"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Kurtarma ifadesi kullanarak cüzdan oluşturun.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Cüzdan adı girin",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Cüzdan kurtarma ifadenizi yedeklemediniz!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("Şimdi Yedekle"),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Cüzdan Şifresi Belirle",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage("Cüzdanı Yedekle"),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Lütfen aşağıdaki kurtarma ifadesini kaydedin",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Başla"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "İnternete bağlı cihazlar bilgilerinizi açığa çıkarabilir. Kurtarma ifadesini yazmanızı ve güvenli bir şekilde saklamanızı öneririz.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Uyarı: Kurtarma ifadenizi kimseye açıklamayın. N42Wallet asla bu bilgiyi istemez. Lütfen son derece dikkatli olun ve çevrimdışı güvenli bir şekilde saklayın. Kurtarma ifadeniz açığa çıkarsa, tüm varlıklarınızı kaybedebilir ve kurtaramayabilirsiniz.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Uyarı: Kurtarma ifadesi, cüzdan varlıklarınızı kurtarmanın tek yoludur.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("Sonraki adım"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Kurtarma ifadesini görüntülemek için tıklayın",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Lütfen etrafınızda başka kişi veya kamera olmadığından emin olun",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Kurtarma İfadesini Onayla",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage("Cüzdan Bilgisi"),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("Cüzdan adı"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Lütfen önce cüzdan kurtarma ifadenizi yedekleyin!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Kurtarma İfadesini Kontrol Et",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Şimdi kurtarma ifadenizi girin.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("İfade Ayarla"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Lütfen kurtarma ifadenizi kaydettiğinizden ve güvenli bir şekilde sakladığınızdan emin olun. Kripto para cüzdanınızı içe aktarmak veya kurtarmak için buna ihtiyacınız olacak.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage("Cüzdan düzenle"),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Zaman"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Sonuç"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage("İşlem hash\'i"),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Ekle"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Yol"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Blok"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Değer"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Hızlandır"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Not"),
    "g_key_wallet_m1": m14,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Hesabınızı iptal etmek istediğinizden emin misiniz?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage("Çıkışı onayla"),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Lütfen Google doğrulama kodunu girin.",
    ),
    "g_key_wallet_m19": m15,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Mevcut token eklenmedi.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Kurtarma ifadenizi boşluklarla ayrılmış kelimelerle girin",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Cüzdan İçe Aktar",
    ),
    "g_key_wallet_m3": m16,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Mevcut token bakiyesi yetersiz.",
    ),
    "g_key_wallet_m5": m17,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("İmzalama hatası"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage("Hesap iptali"),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "E-posta doğrulama kodunu girin.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Cüzdanı Yönet",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Ayrılmış"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Temel Rezerv"),
    "g_key_xml_11": m18,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Artımlı Rezerv"),
    "g_key_xml_22": m19,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Sahip Olunan Nesne Sayısı",
    ),
    "g_key_xml_33": m20,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Toplam ayrılmış miktar nasıl hesaplanır",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Toplam Rezerv = Temel Rezerv + (Sahip Olunan Nesne Sayısı × Artımlı Rezerv)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID ve Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Mevcut şifre"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("Yeni şifre"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage("Yeni şifreyi onayla"),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("6 haneli sayı"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage(
      "Şifreler ve biyometrik",
    ),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Desen şifresi"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Desen şifresi belirle",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Hesap güvenliğiniz için lütfen bir grup şifresi belirleyin",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "İkinci desen şifresi çizimi",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage("Desen şifresi çiz"),
    "g_lock_key21": m21,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Desen şifresini sıfırla",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Çok fazla hatalı giriş, lütfen şifreyi sıfırlayın",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Cüzdan Şifresi Eklensin mi?",
    ),
    "g_lock_key25": m22,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage("Kilit ekranı sayfası"),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("Otomatik kilitleme"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Başarılı"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Başarısız"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Biyometrik tanıma etkin değil",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Biyometrik doğrulama eklensin mi?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage("Şifreyi sıfırla"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("N kilidini aç?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Bulut Doğrulama Etkinliği",
    ),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "Kurulum gas için küçük bir miktar gerektirir.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "N42Wallet\'ta bir Grup Düğüme başarıyla katıldınız. Arkadaşları davet etmek, Düğümü etkinleştirmek ve doğrulamaya başlamak için bağlantıyı paylaşın!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Arkadaşlarla paylaş",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Devam"),
    "g_mining_key63": m23,
    "g_mining_key73": m24,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "@N42Wallet\'ta bir düğüm kurdum ve mobil cihazlarda doğrulamaya başladım! Gel bana katıl. Merkeziyetsiz gelecek mobilde!",
    ),
    "g_mining_key76": m25,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "768 saniye sonra kullanım mümkün.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Bundan önce yapılan istekler işlenmeyecektir.",
    ),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("Bugünün ödülü"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Lütfen aşağıdaki verileri önemli bir anahtar olarak değerlendirin. Hemen güvenilir bir konuma kopyalayıp yedeklemenizi öneririz.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Veriyi Kopyala"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Aktif Değil"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage(
      "Doğrulayıcı Listesi",
    ),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage(
      "İçe aktarma başarılı",
    ),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Şifreli veri boş olamaz!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "Şifre boş olamaz!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Şifre çözme başarısız. Lütfen şifrenin doğru olup olmadığını kontrol edin!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Desteklenmeyen şifreli veri biçimi!",
    ),
    "g_mining_key_109": m26,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage("Dünkü Ödüller"),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage("Şifreli veri"),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage(
      "Dosyaları içe aktar",
    ),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Lütfen şifreli veri girin.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage(
      "İçe aktarılıyor...",
    ),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Onay"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Kullanım biraz zaman alır, lütfen bekleyin!",
    ),
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Ödül her gün birikir ve yalnızca ~0.5 N\'ye ulaştığında N cüzdanınıza gönderilir.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("Toplam Ödüller"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Kazılan Değer"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "N\'nin piyasa fiyatı * toplam N ödüllerine göre hesaplanır.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("Doğrulama sayısı"),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("Plan Seç"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Kilit Açma Süresi: Her zaman kilidi açılabilir",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Yıllık Maksimum Ödül",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage("Ödül Dağıtımı"),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("Günlük Limit"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Hız"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage(
      "Doğrulama Planları",
    ),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Ödeme yöntemini seçin",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("Ödeme Yöntemleri"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("N ile öde"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("Cüzdan Bakiyesi"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "Bu işlem için yeterli N bakiyeniz yok",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Devre Dışı"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Daha fazla gör"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage("Doğrulama Durumu"),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Doğrulama ödüllerini başlatmak için N kilitleyin.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Giriş"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Gelişmiş Düğüm"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Giriş Düğümü"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Pro Düğüm"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blok/gün~70 dakika",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Plan Seç"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blok/gün~15 dakika",
    ),
    "g_mining_key_71": m27,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "Kontrol başına 128 saniye",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Bulut Doğrulaması Başladı",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "Test zinciri güncelleniyor ve bloklar geçici olarak doğrulanamıyor.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Dört gün üst üste görevleri tamamlamamak kazanç kaybına ve ceza riskine neden olur.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("Risk Puanı"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Kullan"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Lütfen önce doğrulayıcının açık ve özel anahtar çiftini kaydedin.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Dışa Aktar"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Transfer için yetersiz bakiye.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "Doğrulayıcı Listesi",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Doğrulayıcı içe aktar",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "Doğrulayıcı zaten mevcut",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Düşük Risk"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("Orta Düşük Risk"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage("Orta Yüksek Risk"),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Yüksek Risk"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "Sözleşme yükleniyor ve şu anda doğrulama yapılamıyor. Lütfen bir süre bekleyin!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage(
      "Güvenlik İpuçları",
    ),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage(
      "Arka Plan Doğrulaması",
    ),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Lütfen özel anahtarınızı veya kurtarma ifadenizi güvende tutun.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Özel anahtarınız veya kurtarma ifadeniz, cüzdan varlıklarınıza erişmek için tek kimlik bilgisidir.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Lütfen güvenli bir yerde saklayın (kağıt, şifre yöneticisi vb.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Ekran görüntüsü almayın, internete yüklemeyin veya kimseyle paylaşmayın.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Kaybolur veya ele geçirilirse, cüzdan varlıklarınız kurtarılamaz.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage("Onayla ve kaydet"),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Şifre belirle ve şifrele",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Lütfen şifreleme şifresini girin",
    ),
    "g_mining_key_98": m28,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Doğruluğundan emin olmak için lütfen şifrenizi tekrar girin",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage("Bildirimler"),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Paylaş"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Davet"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Arkadaşlarınızı davet edin ve N Token kazanın!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage(
      "Davetiniz doğrulamaya başladığında ",
    ),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N\'ye kadar kazanırsınız!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage(
      "Şununla davet et",
    ),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Bağlantı"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("kod"),
    "g_swap_key_14": m29,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Coin fiyatı alınamadı.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Devam ederek aşağıdakileri kabul etmiş olursunuz ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Şartlar ve Koşullar.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Bitir"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Takasınız kısa süre içinde dağıtılacaktır. Lütfen sabırlı olun.",
    ),
    "g_swap_key_20": m30,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Düğüm çalıştırma maliyetleri: Grup Doğrulaması 1-49 N Temel Düğüm: 50 N Premium Düğüm: 100 N Pro Düğüm: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Süresi doldu"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Ödenmedi"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage("Ödeme onaylanıyor"),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("Dağıtılacak"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("Takas Özeti"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Yeni Bakiye"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Ödediğiniz"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Tarih"),
    "g_swap_key_31": m31,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Takaslar ilgili zincir gezginlerinde (Etherscan, BscScan, TRONSCAN ve kendi gezginimiz) görüntülenebilir.",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("N\'ye Takas Et"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Takas"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Aldığınız"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Takas Önizlemesi"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Tekrar dene"),
    "g_token_m_key_1": m32,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Herkes mevcut tokenlerin sahte sürümleri dahil token oluşturabilir. İçe aktarmadan önce her zaman bir tokeni araştırın.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Tokenlar"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Token Ara"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("Zincir Adı"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("Zincir sembolü"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("Zincir ID"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Ondalık"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Özel zincir ekle",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 birim"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Token Ekle"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Biçim Hatası!"),
    "g_token_m_key_22": m33,
    "g_token_m_key_23": m34,
    "g_token_m_key_24": m35,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Token içe aktar"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Tüm ağlar"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("Özel Token"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Token adresi"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Token sembolü"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("Token ondalık"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("İçe Aktar"),
    "g_unlock_key10": m36,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Parmak izi veya yüz tanıma etkin değil mi?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage("Desen şifresi çiz"),
    "g_unlock_key4": m37,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Şifre girin"),
    "g_unlock_key6": m38,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Kimlik doğrulama başarısız",
    ),
    "g_unlock_key8": m39,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Ayrıca "),
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Google Doğrulama",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Bağla",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Google Authentication İndir",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Talimatlar",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator\'ı açın.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "Ekranda 6 haneli bir doğrulama kodu göreceksiniz.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "6 haneli kodu kopyalayın ve N42Wallet\'a yapıştırın.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "Ardından, Authenticator\'ınız başarıyla bağlanacaktır.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Yedek Anahtar",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Anahtarı Google Authentication\'a kopyalayın",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Google doğrulama kodunu girin",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "E-posta doğrulama kodunu girin",
    ),
    "google_verification_message21": m40,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Google anahtarı alınamadı",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "İki Faktörlü Kimlik Doğrulama(2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "Hesabınızı korumak için en az bir 2FA\'yı açmanız önerilir.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator uygulaması, çekimlerinizi ve N42Wallet hesabınızı korur.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "İndir ve Kur",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Lütfen Google Authenticator\'ı indirip kurun. Ardından N42Wallet hesabınızı bağlamak için \'Bağla\'ya basın.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Önemli Bildirim"),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Giriş yap"),
    "login_email": MessageLookupByLibrary.simpleMessage("E-posta"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Şifrenizi mi unuttunuz?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage("Davet kodu"),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Davet kodu",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage(
      "Hesabınız yok mu? ",
    ),
    "login_message_10": MessageLookupByLibrary.simpleMessage(
      "Başarıyla oluşturuldu",
    ),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Başarıyla sıfırlandı",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage(
      "Zaten hesabınız var mı? ",
    ),
    "login_message_6": MessageLookupByLibrary.simpleMessage(
      "Kodu yeniden gönder ",
    ),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Kod başarıyla gönderildi",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "E-posta kayıtlı değil",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage(
      "Kod gönderilemedi",
    ),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "lütfen önce giriş yapın",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Şifre"),
    "next": MessageLookupByLibrary.simpleMessage("Sonraki"),
    "nicknameMessage": m41,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "Şifreler eşleşmiyor",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Profili Düzenle",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Fotoğraf"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Doğrulama kodunu girin",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "Lütfen e-posta girin",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Lütfen şifre girin",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Lütfen Adres Girin",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Şifreyi Tekrar Girin",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Şifre seçin (8~18 karakter)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Şifreyi Onayla",
    ),
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Şifreyi tekrar girin",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage("Kodu girin"),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage("OTP Kodu"),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Şifrenizi sıfırlayın",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Cüzdanı Yönet"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Uygulama Hakkında"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Güvenlik"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("Yeni Sohbet Kullan"),
    "s_key_13": MessageLookupByLibrary.simpleMessage(
      "Gelişmiş Sohbet deneyimini etkinleştir",
    ),
    "s_key_2": MessageLookupByLibrary.simpleMessage("Cüzdan Adresleri"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("İşlem"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Dil"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Tema"),
    "search": MessageLookupByLibrary.simpleMessage("Ara"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Lütfen sözleşmeyi okuyun ve onaylayın",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("doğrulama"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Gizli ifademi kaybedersem, varlıklarım sonsuza kadar kaybolur.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Kurtarma ifademi birine açıklar veya paylaşırsam, varlıklarım çalınabilir.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "Kurtarma ifademi güvende tutmak benim sorumluluğumdur.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage(
      "Kurtarma ifadesi yanlış.",
    ),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "İçe aktarmak istediğiniz cüzdanın kurtarma ifadesini girin.",
    ),
  };
}

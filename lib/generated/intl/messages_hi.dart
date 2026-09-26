// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a hi locale. All the
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
  String get localeName => 'hi';

  static String m0(deviceName, os) =>
      "आपका खाता अभी ${deviceName} (${os}) पर लॉग इन हुआ था। यदि यह आप नहीं थे, तो हम आपको अपना पासवर्ड बदलने की सलाह देते हैं।";

  static String m1(price) => "वर्तमान कीमत: \$${price}";

  static String m2(symbol) => "मूल्य चेतावनी · ${symbol}";

  static String m3(s) => "${s}s में पुनः भेजें";

  static String m4(message) => "खरीदारी विफल: ${message}";

  static String m5(productId) => "खरीदारी सफल: ${productId}";

  static String m6(productId) => "पुनर्स्थापित: ${productId}";

  static String m7(value) => "${value} से अधिक राशि.";

  static String m8(value) =>
      "वॉलेट पहले से मौजूद है, वॉलेट का नाम \"${value}\" है";

  static String m9(value) => "${value} से अधिक राशि दर्ज करें.";

  static String m10(value) => "पंक्ति ${value} पर डुप्लिकेट पता";

  static String m11(value) =>
      "अपर्याप्त शेष: कुल राशि उपलब्ध ${value} से अधिक होगी";

  static String m12(value) => "पंक्ति ${value} पर अमान्य पता";

  static String m13(value) => "पंक्ति ${value} पर अमान्य राशि";

  static String m14(value) => "अधिकतम ${value} प्राप्तकर्ता";

  static String m15(token) => "जारी रखने के लिए ${token} को स्वीकृत करें";

  static String m16(impact) =>
      "उच्च कीमत प्रभाव (${impact})! सावधानी के साथ आगे बढ़ना।";

  static String m17(secs) => "कोटेशन ${secs}s में समाप्त होता है";

  static String m18(value) => "${value}% APY तक कमाएँ";

  static String m19(value) => "हर ${value} सेकंड में ऑटो-रिफ्रेश करें";

  static String m20(address) => "खाता ${address} जोड़ा गया";

  static String m21(address, network) =>
      "क्या आप इस हार्डवेयर वॉलेट खाते को ट्रैक करना चाहते हैं?\n\nपता: ${address}\nनेटवर्क: ${network}";

  static String m22(app) => "वर्तमान ऐप: ${app}";

  static String m23(days) => "${days} दिन पहले";

  static String m24(value) => "खाता आयात करने में विफल: ${value}";

  static String m25(date) => "अंतिम बार कनेक्ट: ${date}";

  static String m26(app) => "सुनिश्चित करें कि ${app} ऐप आपके लेजर पर खुला है";

  static String m27(name) =>
      "क्या आप वाकई सहेजे गए डिवाइस से \"${name}\" हटाना चाहते हैं?";

  static String m28(value) => "${value} अंक कमाएं";

  static String m29(amount, symbol, network) =>
      "${network} पर ${amount} ${symbol} की अनुरोध करें";

  static String m30(value) =>
      "कस्टम नेटवर्क ${value} हटाएं? इस नेटवर्क पर बैलेंस अब दिखाई नहीं देंगे। चेन पर आपकी संपत्ति प्रभावित नहीं होगी।";

  static String m31(value) => "स्था. गैस: ~${value} इकाइयाँ";

  static String m32(reason) => "कारण: ${reason}";

  static String m33(value) => "${value}d बंधन मुक्त";

  static String m34(value) => "${value} दिन शेष हैं";

  static String m35(value) =>
      "अनस्टैकिंग में ${value} दिन लगते हैं। इस अवधि के दौरान आपके टोकन लॉक कर दिये जायेंगे।";

  static String m36(value) => "आपके पास पर्याप्त \"${value}\" नहीं है";

  static String m37(value) => "\"${value}\" खाता प्राप्त करने में विफल";

  static String m38(value) => "पहले स्थानांतरण के लिए न्यूनतम ${value} XRP";

  static String m39(count) => "जोड़ें (${count})";

  static String m40(count) =>
      "${Intl.plural(count, one: '1 नये टोकन का पता चला', other: '${count} नए टोकन का पता चला')} — समीक्षा करने के लिए टैप करें";

  static String m41(value) => "कोई ${value} श्रृंखला नहीं जोड़ी गई।";

  static String m42(value) =>
      "${value} में लेनदेन अधूरा है, कृपया बाद में पुनः प्रयास करें।";

  static String m43(value) => "${value} के लिए कोई पता नहीं मिला.";

  static String m44(value) => "${value} का अपर्याप्त संतुलन।";

  static String m45(value, value1) =>
      "प्रत्येक XRP खाते को आधार रेखा के रूप में ${value} XRP (${value1} ड्रॉप्स) आरक्षित करना होगा, जिसे खर्च नहीं किया जा सकता है।";

  static String m46(value, value1) =>
      "खाते के स्वामित्व वाली प्रत्येक वस्तु के लिए, ${value} XRP (${value1} ड्रॉप्स) रिजर्व में जोड़ा जाता है।";

  static String m47(value, value1) =>
      "यह खाता ${value} ऑब्जेक्ट का स्वामी है, जिसका अर्थ है कि एक अतिरिक्त ${value1} XRP आरक्षित है।";

  static String m48(message) => "रूम में प्रवेश विफल\n${message}";

  static String m49(value) => "गलत पैटर्न, ${value} प्रयास शेष";

  static String m50(value) => "गलत पैटर्न, ${value} प्रयास शेष";

  static String m51(value) =>
      "आपने सफलतापूर्वक ${value} सेट अप कर लिया है और N42Wallet के साथ सत्यापन शुरू कर देंगे!";

  static String m52(value) =>
      "लेयर 1 श्रृंखला के प्रारंभिक खनिक बनने के लिए @N42Wallet पर मेरे ${value} समूह में शामिल हों, और अपने फ़ोन पर क्रिप्टो प्राप्त करें!";

  static String m53(value, value1) =>
      "क्या आप वाकई नोड चलाने के लिए ${value} N को ${value1} तक लॉक करना चाहते हैं?";

  static String m54(value) => "आयात विफल:${value}";

  static String m55(value) =>
      "पुरस्कार अर्जित करने के लिए कम से कम ${value} का स्टेकिंग बैलेंस आवश्यक है।";

  static String m56(value, value1) =>
      "${value} N प्रत्येक ${value1} ब्लॉक का खनन किया गया";

  static String m57(value) => "${value} वर्ण होने चाहिए";

  static String m58(symbol) => "राशि (${symbol})";

  static String m59(amount, symbol) => "शेष: ${amount} ${symbol}";

  static String m60(label) =>
      "«${label}» को विजेता घोषित कर निपटाएँ? यह पूर्ववत नहीं होगा।";

  static String m61(n) => "${n} मिनट";

  static String m62(n) => "परिणाम ${n}";

  static String m63(label, pct) => "${label} जीतता है (${pct}%)";

  static String m64(shares, avg, after) =>
      "अनु. ${shares} शेयर · औसत ${avg}% · बाद ${after}%";

  static String m65(reason) => "रिडीम विफल: ${reason}";

  static String m66(label) => "परिणाम: ${label}";

  static String m67(n) => "बेचें ${n}";

  static String m68(value) => "${value} अपर्याप्त शेष।";

  static String m69(value) => "${value} इनकमिंग...";

  static String m70(value) =>
      "${value} स्वैप-इन-ऐप शीघ्र ही आपके वॉलेट में वितरित किया जाएगा और इस प्रक्रिया के माध्यम से बेचा नहीं जा सकता है। इसका उपयोग नोड को चलाने के लिए किया जा सकता है।";

  static String m71(value) => "अधिकतम ${value} वर्ण";

  static String m72(value) => "${value} श्रृंखला एपीपी पहले से ही समर्थित है!";

  static String m73(value) =>
      "${value} श्रृंखला एपीपी पहले से ही समर्थित है, क्या आप इसे जोड़ना चाहते हैं?";

  static String m74(value) => "${value} पता परीक्षण लिंक विफल!";

  static String m75(value) =>
      "RPC ने चेन आईडी ${value} रिपोर्ट किया है, जो आपके द्वारा दर्ज किए गए मान से मेल नहीं खाता।";

  static String m76(asset, contract, address) =>
      "एसेट ${asset} (${contract}) खाता ${address} में जोड़ा नहीं गया है।";

  static String m77(imported, skipped) =>
      "बटुए आयात किए गए: ${imported}। नज़रअंदाज़ किए गए: ${skipped}।";

  static String m78(value) => "बैलेंस: ${value}";

  static String m79(value) => "बेस फी: ${value} गीवी";

  static String m80(value) =>
      "क्लिपबोर्ड ${value} सेकंड में स्वतः साफ हो जाएगा";

  static String m81(value) => "पंक्ति ${value}: फ़ील्ड अनुपलब्ध हैं";

  static String m82(value) => "${value} दिन";

  static String m83(value) => "${value} से जुड़ा हुआ";

  static String m84(value) => "गैस: ${value}";

  static String m85(value) => "${value} घंटे";

  static String m86(value) => "वैध प्राप्तकर्ता आयात किए गए (${value})";

  static String m87(quote, base) => "सीमा मूल्य (${quote} प्रति ${base})";

  static String m88(value) => "लिमिट ${value}";

  static String m89(value) => "बाजार (${value})";

  static String m90(value) => "न्यूनतम बैलेंस: ${value}";

  static String m91(value) => "आदेश (${value})";

  static String m92(value) => "पोजीशन (${value})";

  static String m93(value) => "प्राप्तकर्ता: ${value}";

  static String m94(value) => "टोकन मिला: ${value}";

  static String m95(value) => "टोकन: ${value}";

  static String m96(value) => "लेन-देन: ${value}";

  static String m97(valid, issues) => "वैध: ${valid}. समस्याएं: ${issues}.";

  static String m98(value) => "… और ${value} अधिक समस्याएं";

  static String m99(volume, interest) => "आयतन: ${volume} · OI: ${interest}";

  static String m100(value) => "बटुआ ${value}";

  static String m101(value) => "${value} घंटे पहले अपडेट किया गया";

  static String m102(value) => "${value} मिनट पहले अपडेट किया गया";

  static String m103(value) => "0~${value} अक्षर";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("संपादित करें"),
    "Verification": MessageLookupByLibrary.simpleMessage("सत्यापन"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "पते की जानकारी",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("सफलतापूर्वक कॉपी किया गया"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("पता कॉपी करें"),
    "descO": MessageLookupByLibrary.simpleMessage("विवरण(वैकल्पिक)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "पासवर्ड बदलें",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("समझ गया"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "नया डिवाइस लॉगिन",
    ),
    "file": MessageLookupByLibrary.simpleMessage("फ़ाइल"),
    "g_aggregate_cached_balance": MessageLookupByLibrary.simpleMessage(
      "सहेजा गया बैलेंस · ताजा करने में विफलता",
    ),
    "g_aggregate_known_balance": MessageLookupByLibrary.simpleMessage(
      "ज्ञात बैलेंस",
    ),
    "g_aggregate_mainnet_note": MessageLookupByLibrary.simpleMessage(
      "केवल मेननेट के बैलेंस। किसी नेटवर्क की जानकारी न मिलने या अनुरोध विफल होने पर उसका बैलेंस शून्य नहीं माना जाता।",
    ),
    "g_aggregate_network_balances": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क के अनुसार बैलेंस",
    ),
    "g_aggregate_no_mainnet": MessageLookupByLibrary.simpleMessage(
      "इस नेटवर्क के लिए कोई सक्रिय मेननेट खाता नहीं है",
    ),
    "g_aggregate_not_loaded": MessageLookupByLibrary.simpleMessage(
      "बैलेंस लोड नहीं हुआ",
    ),
    "g_aggregate_open_network": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क खोलें",
    ),
    "g_aggregate_unavailable": MessageLookupByLibrary.simpleMessage(
      "इस एसेट को चयनित बटुए में अब उपलब्ध नहीं किया जा रहा है। बटुए में लौटें और एक एसेट चुनें।",
    ),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("ऊपर जाता है ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("नीचे गिरता है ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "कीमत होने पर मुझे सचेत करें",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage(
      "इस चेतावनी को सक्षम करें",
    ),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "कृपया 0 से अधिक का वैध मूल्य दर्ज करें",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("हटाओ"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("अलर्ट सेट करें"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "लक्ष्य मूल्य (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage("अद्यतन चेतावनी"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "टोकन केवल एक ही नेटवर्क के भीतर भेजे जा सकते हैं। दूसरे नेटवर्क से भेजने पर नुकसान हो सकता है.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "प्राप्त करने के लिए स्कैन करें",
    ),
    "g_audit_aa_history_external": MessageLookupByLibrary.simpleMessage(
      "इस स्मार्ट अकाउंट की ब्लॉकचेन गतिविधि देखने के लिए ब्लॉक एक्सप्लोरर खोलें।",
    ),
    "g_audit_about_desc": MessageLookupByLibrary.simpleMessage(
      "संस्करण, वेबसाइट और सहायता",
    ),
    "g_audit_activity_error": MessageLookupByLibrary.simpleMessage(
      "लेन-देन इतिहास लोड करने में असमर्थ।",
    ),
    "g_audit_activity_local": MessageLookupByLibrary.simpleMessage(
      "आपके बटुओं में स्थानीय लेन-देन इतिहास। किसी संपत्ति को खोलें ताकि इसकी नवीनतम गतिविधि सिंक हो सके।",
    ),
    "g_audit_all": MessageLookupByLibrary.simpleMessage("सब"),
    "g_audit_approval_spender": MessageLookupByLibrary.simpleMessage(
      "खर्च करने की अनुमति",
    ),
    "g_audit_approval_token": MessageLookupByLibrary.simpleMessage(
      "टोकन कॉन्ट्रैक्ट",
    ),
    "g_audit_batch": MessageLookupByLibrary.simpleMessage("बैच स्थानांतरण"),
    "g_audit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "एक से अधिक प्राप्तकर्ताओं को भेजें या CSV आयात करें",
    ),
    "g_audit_biometrics": MessageLookupByLibrary.simpleMessage(
      "बायोमेट्रिक प्रमाणीकरण",
    ),
    "g_audit_biometrics_desc": MessageLookupByLibrary.simpleMessage(
      "फेस आईडी / उंगली के निशान की सेटिंग्स",
    ),
    "g_audit_connections_desc": MessageLookupByLibrary.simpleMessage(
      "सत्रों को प्रबंधित करें; अलग करने से टोकन अनुमतियाँ वापस नहीं ली जाती हैं।",
    ),
    "g_audit_currency": MessageLookupByLibrary.simpleMessage("प्रदर्शन मुद्रा"),
    "g_audit_currency_usd": MessageLookupByLibrary.simpleMessage(
      "पोर्टफोलियो के मूल्य वर्तमान में अमेरिकी डॉलर में दिखाए जा रहे हैं।",
    ),
    "g_audit_defi_error": MessageLookupByLibrary.simpleMessage(
      "DeFi स्थितियाँ लोड करने में असमर्थ। पुनः प्रयास करने के लिए टैप करें।",
    ),
    "g_audit_defi_loading": MessageLookupByLibrary.simpleMessage(
      "DeFi स्थितियाँ लोड हो रही हैं…",
    ),
    "g_audit_defi_positions": MessageLookupByLibrary.simpleMessage(
      "DeFi स्थितियाँ",
    ),
    "g_audit_display_language": MessageLookupByLibrary.simpleMessage(
      "एप्लिकेशन दिखावट भाषा",
    ),
    "g_audit_encrypted_backup": MessageLookupByLibrary.simpleMessage(
      "एक एन्क्रिप्टेड बटुआ बैकअप निर्यात करें",
    ),
    "g_audit_funding": MessageLookupByLibrary.simpleMessage(
      "वर्तमान फंडिंग दर",
    ),
    "g_audit_gas": MessageLookupByLibrary.simpleMessage("गैस ट्रैकर"),
    "g_audit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क शुल्क और कीमत चेतावनियाँ",
    ),
    "g_audit_hardware": MessageLookupByLibrary.simpleMessage("हार्डवेयर बटुआ"),
    "g_audit_load_more": MessageLookupByLibrary.simpleMessage("अधिक लोड करें"),
    "g_audit_mainnet": MessageLookupByLibrary.simpleMessage("मेननेट"),
    "g_audit_manage_settings": MessageLookupByLibrary.simpleMessage(
      "अपने बटुआ और प्राथमिकताओं का प्रबंधन करें",
    ),
    "g_audit_manage_wallets": MessageLookupByLibrary.simpleMessage(
      "बटुआ बनाएँ, आयात करें और प्रबंधित करें",
    ),
    "g_audit_mark_price": MessageLookupByLibrary.simpleMessage("चिह्नित कीमत"),
    "g_audit_max_leverage": MessageLookupByLibrary.simpleMessage(
      "अधिकतम लीवरेज",
    ),
    "g_audit_network_desc": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क और RPC एंडपॉइंट्स को प्रबंधित करें",
    ),
    "g_audit_open_interest": MessageLookupByLibrary.simpleMessage(
      "खुली दिलचस्पी",
    ),
    "g_audit_oracle_price": MessageLookupByLibrary.simpleMessage("ओरेकल कीमत"),
    "g_audit_protect_wallet": MessageLookupByLibrary.simpleMessage(
      "प्रमाणीकरण और बटुआ सुरक्षा",
    ),
    "g_audit_quote_changed": MessageLookupByLibrary.simpleMessage(
      "स्वैप कीमत का प्रस्ताव बदल गया या समाप्त हो गया। पुष्टि करने से पहले नवीनतम स्वैप कीमत का प्रस्ताव देखें।",
    ),
    "g_audit_rate": MessageLookupByLibrary.simpleMessage("N42 को रेट करें"),
    "g_audit_rate_desc": MessageLookupByLibrary.simpleMessage(
      "एप्लिकेशन स्टोर खोलें",
    ),
    "g_audit_saved_addresses": MessageLookupByLibrary.simpleMessage(
      "सहेजे गए प्राप्तकर्ता पते",
    ),
    "g_audit_show_less": MessageLookupByLibrary.simpleMessage("कम दिखाएँ"),
    "g_audit_testnet": MessageLookupByLibrary.simpleMessage("टेस्टनेट"),
    "g_audit_theme_desc": MessageLookupByLibrary.simpleMessage(
      "दिखावट और प्रदर्शन मोड",
    ),
    "g_audit_volume": MessageLookupByLibrary.simpleMessage(
      "24 घंटे का वॉल्यूम (USD)",
    ),
    "g_audit_wallet_management": MessageLookupByLibrary.simpleMessage(
      "बटुआ प्रबंधन",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "कृपया यूआरएल दर्ज करें",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("विवरण दर्ज करें"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("ब्राउज़र"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "ब्राउज़र कैश साफ़ करें",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "डीएपी को स्वचालित रूप से कनेक्ट करें",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("सब बंद करो"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("हो गया"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("इतिहास"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "सारा इतिहास साफ़ करें",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "संपूर्ण ब्राउज़िंग इतिहास साफ़ करें?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage(
      "इतिहास साफ हो गया",
    ),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("आज"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("कल"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("डीएपी खोजें"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("लोकप्रिय"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("डेक्स"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("डेफी"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("एनएफटी"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("पुल"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("बुकमार्क"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("उपकरण"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "अभी तक कोई बुकमार्क नहीं जोड़ा गया",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("बुकमार्क"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("नाम"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "कृपया नाम दर्ज करें",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("यूआरएल"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("विवरण"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("सहमत"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "संदेश हटा दिया गया है",
    ),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("लेन-देन"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("कनेक्ट करें"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("उपलब्ध नेटवर्क"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("संदेश चिह्न"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("जुड़ रहा है"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "जोड़ी जा रही है, कृपया प्रतीक्षा करें।",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("डिस्कनेक्ट करें"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("अस्वीकार करें"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage("अवरुद्ध"),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("सावधानी"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("सुरक्षित"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "सत्यापित",
    ),
    "g_dex_account_unavailable": MessageLookupByLibrary.simpleMessage(
      "इस नेटवर्क के लिए एक उपयोगी मेननेट बटुआ चुनें। वॉच-केवल खाते स्वैप के लिए हस्ताक्षर नहीं कर सकते।",
    ),
    "g_dex_execution_invalid": MessageLookupByLibrary.simpleMessage(
      "लेन-देन के पैरामीटर अमान्य हैं या क्रियान्वयन विफल रहा। स्वैप कीमत के प्रस्ताव को ताजा करें और फिर से प्रयास करें।",
    ),
    "g_dex_history_record_failed": MessageLookupByLibrary.simpleMessage(
      "स्वैप प्रस्तुत किया गया, लेकिन इतिहास को अपडेट नहीं किया जा सका। इसे फिर से प्रस्तुत न करें।",
    ),
    "g_dex_smart_account_fees": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क शुल्क इस स्मार्ट खाते द्वारा भुगतान किए जाते हैं।",
    ),
    "g_dex_spending_account": MessageLookupByLibrary.simpleMessage(
      "खर्च करने वाला खाता",
    ),
    "g_dex_use_smart_account": MessageLookupByLibrary.simpleMessage(
      "स्मार्ट खाता का उपयोग करें",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("कोड पुनः भेजें"),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "बायोमेट्रिक स्कैन युक्तियाँ",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "प्रमाणीकरण के लिए अपना फिंगरप्रिंट या चेहरा स्कैन करें।",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("युक्तियाँ"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("सेट करना"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "जारी रखने के लिए अपना चेहरा या फिंगरप्रिंट स्कैन करें।",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("वापसी"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator",
    ),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator ऐप से QR कोड स्कैन करें",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "या कुंजी मैन्युअली दर्ज करें:",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage(
      "6 अंकों का सत्यापन कोड दर्ज करें",
    ),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "प्रत्येक ट्रांसफर की पुष्टि के लिए Google Authenticator आवश्यक है।",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "गलत कोड, पुनः प्रयास करें",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator कॉन्फ़िगर नहीं है",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage("बाइंडिंग सफल"),
    "g_history_clear_dates": MessageLookupByLibrary.simpleMessage(
      "तारीखें साफ करें",
    ),
    "g_history_export_all": MessageLookupByLibrary.simpleMessage(
      "स्थानीय रिकॉर्ड निर्यात करें (CSV)",
    ),
    "g_history_export_error": MessageLookupByLibrary.simpleMessage(
      "लेन-देन इतिहास निर्यात करने में असमर्थ। कृपया फिर से प्रयास करें।",
    ),
    "g_history_local_scope": MessageLookupByLibrary.simpleMessage(
      "फ़िल्टर और CSV निर्यात में इस उपकरण पर सहेजे गए सभी मेल वाले रिकॉर्ड शामिल हैं। नवीनतम ब्लॉकचेन गतिविधि के लिए एसेट खोलें।",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("प्रोफाइल"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("समाचार"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("सत्यापन"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage(
      "किसी मित्र को आमंत्रित करें",
    ),
    "g_home_market": MessageLookupByLibrary.simpleMessage("बाजार"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("रद्द किया गया"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "अपना नेटवर्क कनेक्शन जांचें और पुनः प्रयास करें",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "कोई उत्पाद उपलब्ध नहीं",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage(
      "खरीदारी पुनर्स्थापित करें",
    ),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "खरीदारी पुनर्स्थापित हो रही है…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("पुनः प्रयास करें"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "ऐप स्टोर अनुपलब्ध है",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("खरीदें"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("हटाने में विफल!"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("गैस सीमा"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("अब और नहीं"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("लोड हो रहा है "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("पता पुस्तिका"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("बटुआ आयात करें"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("प्रबंधित करें"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("नया पता"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("हटाएँ"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("सहेजें"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("प्रतिलिपि"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("वॉलेट बनाएं/आयात करें"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("थीम"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("सिस्टम"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("रोशनी"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("अंधेरा"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("वॉलेट सूची"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("कोई डेटा नहीं"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("राशि मान्य नहीं है"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("मुख्य बटुआ"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("लेनदेन सफल"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("ग़लत पासवर्ड"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("टेस्टनेट"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("मेननेट"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("सिस्टम भाषा"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "मुख्य वॉलेट के रूप में सेट करें",
    ),
    "g_key_155": MessageLookupByLibrary.simpleMessage("बटुआ पता"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "पता कॉपी करने के लिए स्कैन करें",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("जोड़ें"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "वैलेट सत्यापित करें का चयन करें",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("प्रतीक"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("चिपकाएँ"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("चेन चुनें"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("लेन-देन विफल"),
    "g_key_179": MessageLookupByLibrary.simpleMessage("यह मेरा बटुआ पता है"),
    "g_key_181": MessageLookupByLibrary.simpleMessage("अन्य"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("सफलतापूर्वक सहेजा गया"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("सफलता"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "क्या आप वाकई बटुआ हटाना चाहते हैं?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("सक्रिय"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "कैमरे तक पहुंचने की अनुमति नहीं.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("एक्सप्लोरर"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("अधिकतम"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("संपत्ति"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("खाता बही खाली है!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("लेन-देन अवलोकन"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "लिंक त्रुटि, क्यूआर कोड को दोबारा स्कैन करें।",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("पासवर्ड संपादित करें"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("पुराना पासवर्ड"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "शेष राशियाँ समन्वयित हो रही हैं...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("निजी कुंजी"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("वॉलेट पासवर्ड दर्ज करें"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("निजी कुंजी त्रुटि"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("बाज़ार की जानकारी"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage("पासवर्ड मेल नहीं खाता."),
    "g_key_29": MessageLookupByLibrary.simpleMessage("संतुलन"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("जोड़ने में विफल!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("प्राप्त करें"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("स्थानांतरण"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("को"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("QR कोड स्कैन करें"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("वॉलेट पता दर्ज करें"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("उपलब्ध शेष"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("रकम"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "इस लेनदेन को कवर करने के लिए अपर्याप्त धनराशि उपलब्ध है।",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("भेजें"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("लोड करने में विफल!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("बटुआ"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("बनाएँ"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("से"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("पुष्टि करें"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("रद्द करें"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("सभी टोकन"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("सेटिंग्स"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "खाता सफलतापूर्वक बनाया गया",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "खाता विवरण",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage("खाता नाम"),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "खाता नाम दर्ज करें",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "खाता प्रकार",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("सक्रिय"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "अपना पहला ऑपरेशन जोड़ें",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "ऑपरेशन जोड़ें",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "पते की गणना की जा रही है...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "पते की गणना करने में विफल. कृपया पुन: प्रयास करें।",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("स्वीकृत करें"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("बैच"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "परमाणु निष्पादन",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "एक साथ कई ऑपरेशन निष्पादित करें",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "एक ही ऑपरेशन में एकाधिक लेनदेन भेजें",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "बैच निष्पादन विफल रहा",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "कोई सहेजा गया टेम्पलेट नहीं",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "बैच संचालन",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "गैस बचाएं",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "टेम्पलेट के रूप में सहेजें",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "सबमिट किया जा रहा है...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "बैच सफलतापूर्वक सबमिट हो गया",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "टेम्पलेट लोड करें",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "टेम्पलेट का नाम",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "टेम्प्लेट नाम दर्ज करें",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "टेम्प्लेट सहेजा गया",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage(
      "टेम्पलेट्स",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "बैच लेनदेन",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "एक लेन-देन में स्वीकृत करें और स्वैप करें - अब दो-चरणीय पुष्टि नहीं होगी",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "एक-क्लिक बैच क्रियाएँ",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "ईटीएच के बजाय ईआरसी-20 टोकन के साथ लेनदेन प्रायोजित करें या शुल्क का भुगतान करें",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "किसी भी टोकन से गैस का भुगतान करें",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "यदि आप अपनी निजी कुंजी खो देते हैं तो विश्वसनीय संपर्कों के माध्यम से पहुंच पुनर्प्राप्त करें",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "सामाजिक पुनर्प्राप्ति",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "गैस रहित लेनदेन समर्थन के साथ मॉड्यूलर ईआरसी-7579 स्मार्ट खाता",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("द्वारा"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("जंजीर"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("चेन आईडी"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("परिवर्तन"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "स्थिति जांचें",
    ),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage(
      "जल्द आ रहा है",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "यह एक प्रतितथ्यात्मक संबोधन है. इसे आपके पहले लेनदेन पर तैनात किया जाएगा।",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "स्मार्ट अकाउंट बनाएं",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "अपना पहला स्मार्ट खाता बनाएं",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "सत्र कुंजी बनाएँ",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("बनाया गया"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("कस्टम"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "आपके पहले लेनदेन पर खाता स्वचालित रूप से तैनात हो जाएगा",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("तैनात"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("तैनाती..."),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "आपके पहले लेनदेन के साथ ही परिनियोजन स्वचालित रूप से हो जाएगा।",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "उन्नत सुविधाओं के साथ एथेरियम खातों की अगली पीढ़ी का अनुभव लें",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("विवरण"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "हाइब्रिड ईओए/स्मार्ट खाता - किसी परिनियोजन की आवश्यकता नहीं है",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("त्रुटि"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "अनुमानित गैस",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "बैच निष्पादित करें",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("समाप्त हो गया"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage(
      "समाप्त हो रहा है",
    ),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("फ़ैक्टरी"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("मुफ़्त"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "डिफ़ॉल्ट का उपयोग करते हुए गैस अनुमान विफल रहा",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("गैस भुगतान"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "गैस भुगतान विकल्प",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "गैस प्रायोजित",
    ),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("गैस रहित"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "गैस रहित लेनदेन और बैच संचालन",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "ZeroDev से प्लगइन समर्थन के साथ मॉड्यूलर खाता",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("लेबल"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "अंतिम गतिविधि",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "मेरे स्मार्ट खाते",
    ),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "अभी तक कोई स्मार्ट खाता नहीं",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "कोई भी खाता आपके फ़िल्टर से मेल नहीं खाता",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "कोई संचालन नहीं जोड़ा गया",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "कोई सत्र कुंजियाँ नहीं",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage("तैनात नहीं"),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "स्मार्ट खाता बनाएं (निःशुल्क, ETH की आवश्यकता नहीं)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "इसे फंड करें - कोई भी ईवीएम टोकन प्राप्त करें",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "पेमास्टर के साथ गैस रहित लेनदेन करें",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("संचालन"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("मालिक"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "टोकन से गैस का भुगतान करें",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "अपने ETH से गैस का भुगतान करें",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage(
      "के साथ भुगतान करें",
    ),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "ETH से भुगतान करें",
    ),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "जंजीरों का समर्थन किया गया",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "उपलब्धता की जाँच की जा रही है...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "चेन कवरेज",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "चुनें कि आप लेनदेन गैस शुल्क का भुगतान कैसे करना चाहते हैं",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "स्था. लागत",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "गैस विकल्प लोड करने में विफल",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "पुनः प्रयास करें",
    ),
    "g_key_aa_paymaster_unavailable": MessageLookupByLibrary.simpleMessage(
      "गैस स्पॉन्सरशिप अभी उपलब्ध नहीं है। कृपया अपने बैलेंस से गैस का भुगतान करें।",
    ),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("लंबित"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("अनुमति"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "पूर्वावलोकन पता",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("तैयार"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "पता प्राप्त करें",
    ),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("पुनः प्रयास करें"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("निरस्त करें"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "क्या आप वाकई इस सत्र कुंजी को निरस्त करना चाहते हैं? अधिकृत डीएपी अब लेनदेन निष्पादित नहीं कर पाएगा।",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "सत्र कुंजी निरस्त करें",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "सत्र कुंजी निरस्त कर दी गई",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage(
      "निरस्त किया गया",
    ),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "सत्र कुंजी निरस्त की जा रही है...",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "उन्नत सुरक्षा सुविधाओं के साथ बहु-हस्ताक्षर खाता",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("बचाया"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "चेन का चयन करें",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "पेमास्टर का चयन करें",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("चयनित"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "अपने स्मार्ट खाते का उपयोग करके टोकन भेजें",
    ),
    "g_key_aa_send_failed": MessageLookupByLibrary.simpleMessage(
      "लेन-देन विफल",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 दिन"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 घंटा"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 दिन"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 दिन"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "जैसे 100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "अधिकतम राशि",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "मैं इस कुंजी की अनुमतियों को समझता हूं",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "अनुमोदित डीएपी अनुबंधों के साथ बातचीत करें",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "सत्र कुंजी बनाने में विफल",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "सत्र कुंजी बनाई गई",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "जैसे यूनिस्वैप, आवे...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "लेबल/डीएपी नाम",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "सत्र मुख्य विवरण",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "के लिए मान्य",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "उच्च जोखिम - केवल सत्यापित डीएपी पर भरोसा करें",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "सत्र कुंजियाँ",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "अपने स्मार्ट खाते तक अस्थायी पहुंच के साथ DApps को अधिकृत करें",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "डीएपी एक्सेस",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "पूर्ण नियंत्रण",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "केवल भेजें",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "उच्च जोखिम",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "कम जोखिम",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "मध्यम जोखिम",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "पुष्टि करने से पहले अनुमतियों की समीक्षा करें",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "अनुमति स्तर चुनें",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "निर्धारित सीमा के भीतर टोकन स्थानांतरित करें",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "एकल स्वामी वाला बुनियादी स्मार्ट खाता - अधिकांश उपयोगकर्ताओं के लिए अनुशंसित",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "स्मार्ट खाते",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "स्मार्ट वॉलेट",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "खर्च सीमा",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "प्रायोजित (मुक्त)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("स्मार्ट खाता"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("कुल गैस"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("लेन-देन"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("सभी देखें"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("पता"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "कृपया एक नाम दर्ज करें",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "कृपया पता दर्ज करें",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "कृपया सिक्के का प्रकार चुनें",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("पता संपादित करें"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage(
      "सफलतापूर्वक हटा दिया गया",
    ),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("सिक्के चुनें"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("सिक्के खोजें"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "उन्नत सुविधाएँ",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("सक्रिय"),
    "g_key_airdrop_discover": MessageLookupByLibrary.simpleMessage("खोजें"),
    "g_key_airdrop_distribute": MessageLookupByLibrary.simpleMessage(
      "वितरित करें",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("समाप्त"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "कोई सत्यापित अभियान उपलब्ध नहीं है",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("लंबित"),
    "g_key_airdrop_sources": MessageLookupByLibrary.simpleMessage("स्रोत"),
    "g_key_airdrop_sources_hint": MessageLookupByLibrary.simpleMessage(
      "प्रदाता-द्वारा बनाए गए अभियान निर्देशिकाओं को ब्राउज़ करने के लिए स्रोत खोलें।",
    ),
    "g_key_airdrop_thirdparty_warning": MessageLookupByLibrary.simpleMessage(
      "तीसरे पक्ष के अभियान अशांतिपूर्ण हो सकते हैं। हस्ताक्षर करने से पहले प्रोजेक्ट डोमेन और लेन-देन विवरण की पुष्टि करें।",
    ),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage("एयरड्रॉप"),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("आगामी"),
    "g_key_badge_hot": MessageLookupByLibrary.simpleMessage("हॉट"),
    "g_key_badge_live": MessageLookupByLibrary.simpleMessage("लाइव"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "प्राप्तकर्ता जोड़ें",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "प्रसारण...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "सभी साफ़ करें",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "बैच स्थानांतरण की पुष्टि करें",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("जारी रखें"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "सीएसवी प्रारूप: पता, राशि, लेबल",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("हो गया"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "गैस का अनुमान...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "बैच स्थानांतरण केवल ईवीएम श्रृंखलाओं का समर्थन करता है",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "सीएसवी निर्यात करें",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "बैच स्थानांतरण सहायता",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "सीएसवी आयात करें",
    ),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "मेमो वैकल्पिक है",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "कम गैस शुल्क के लिए मल्टीकॉल3 का उपयोग करें",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "कोई समर्थित टोकन नहीं",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "प्राप्तकर्ता",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "टोकन चुनें",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "एक लेन-देन में अनेक पतों पर टोकन भेजें",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage(
      "हस्ताक्षर करना...",
    ),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "किसी प्राप्तकर्ता को हटाने के लिए बाएँ स्वाइप करें",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage("बैच स्थानांतरण"),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "कुल राशि",
    ),
    "g_key_block_explorer_optional": MessageLookupByLibrary.simpleMessage(
      "ब्लॉक एक्सप्लोरर URL (वैकल्पिक)",
    ),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "चेन समर्थित नहीं है",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("सबसे सस्ता"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "आपको प्राप्त होगा (अनुमानित)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("सबसे तेज़"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "उद्धरण प्राप्त करें",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "पुल का इतिहास",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "कोई मार्ग उपलब्ध नहीं",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "अनुशंसित",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("ताज़ा करें"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("मार्ग"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "खोज शृंखला...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("चयन करें"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "टोकन चुनें",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("फिसलन"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "पूरा हुआ",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage("असफल"),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "प्रगति पर है",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "लंबित",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("पुल"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage("पुल विफल"),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "लेनदेन लंबित",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "ब्रिज सफल",
    ),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "तक ताला लगा दिया",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "अपना रिडेम्प्शन सबमिट करने से पहले सत्यापित करें कि लॉक अवधि समाप्त हो गई है।",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "बीटीसी अभी भी लॉक है",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "वीबीटीसी भुनाएं",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "अनलॉक - छुड़ाने के लिए तैयार",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "मैं जोखिमों को समझता हूं और आगे बढ़ना चाहता हूं",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "दांव लगाना जारी रखें",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "यह कैसे काम करता है",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "टाइमलॉक समाप्त होने तक बीटीसी लॉक रहेगा। नीचे दिए गए इंटरफ़ेस में स्टेकिंग प्रक्रिया को पूरा करें।",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "आपकी बीटीसी पूरी हिस्सेदारी अवधि के लिए लॉक कर दी जाएगी। जल्दी निकासी संभव नहीं है.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "लॉक को बिटकॉइन OP_CHECKLOCKTIMEVERIFY (CLTV) द्वारा लागू किया जाता है और इसे बायपास नहीं किया जा सकता है।",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "स्मार्ट अनुबंध जोखिम: यद्यपि ऑडिट किया गया है, कोई भी प्रोटोकॉल पूरी तरह से जोखिम-मुक्त नहीं है।",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "न्यूनतम हिस्सेदारी: 0.001 बीटीसी। न्यूनतम लॉक अवधि: 0.125 दिन (~3 घंटे)।",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "जोखिम चेतावनी",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "आपका बीटीसी टाइम-लॉक (सीएलटीवी) के साथ 2-में-2 मल्टीसिग पते में बंद है, जो आपकी कुंजी और एन42 कनस्तर कुंजी द्वारा सुरक्षित है।",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "अपना बीटीसी लॉक करें",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "ऑन-चेन पुष्टिकरण के बाद, vBTC को आपके वॉलेट में 1:1 के अनुपात में भेज दिया जाता है।",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "मिंट वीबीटीसी",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "स्टेकिंग पुरस्कार अर्जित करने के लिए vBTC को पकड़ें। vBTC DeFi प्रोटोकॉल में भी प्रयोग योग्य है।",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "पुरस्कार अर्जित करें",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "जब लॉक अवधि समाप्त हो जाए, तो अपना मूल बीटीसी वापस पाने के लिए अपना वीबीटीसी जला दें।",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "अनलॉक के बाद रिडीम करें",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "बीटीसी सेल्फ-कस्टडी स्टेकिंग",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("समझ गया"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. एनएफटी समर्थन वाला एक टोकन चुनें",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. एनएफटी टैब पर जाएं",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. वह एनएफटी चुनें जिसे आप बर्न करना चाहते हैं",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. \"बर्न\" बटन पर टैप करें",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("कदम:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "एनएफटी को बर्न करने के लिए, कृपया एनएफटी विवरण पृष्ठ पर जाएं और \"बर्न\" बटन पर टैप करें।",
    ),
    "g_key_chain_presets": MessageLookupByLibrary.simpleMessage(
      "लोकप्रिय नेटवर्क (भरने के लिए टैप करें)",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "यह श्रृंखला अभी तक स्थानांतरण का समर्थन नहीं करती है, बने रहें",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "सभी संपत्तियाँ \$1 से नीचे हैं",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "अन्य परिसंपत्तियाँ",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "सभी दिखाने के लिए टैप करें",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("हाल का"),
    "g_key_dapp_connect_account": MessageLookupByLibrary.simpleMessage("खाता"),
    "g_key_dapp_connect_desc": MessageLookupByLibrary.simpleMessage(
      "यह साइट आपके बटुआ पता को देखने और लेन-देन के सुझाव देने के लिए कह रही है। यह आपकी अनुमति के बिना फंड नहीं हटा सकता है।",
    ),
    "g_key_dapp_connect_title": MessageLookupByLibrary.simpleMessage(
      "बटुआ कनेक्ट करें",
    ),
    "g_key_device_security_warning_message": MessageLookupByLibrary.simpleMessage(
      "लगता है कि यह डिवाइस रूट या जेलब्रेक किया गया है। असुरक्षित डिवाइस पर वॉलेट का इस्तेमाल करने से निजी कुंजी की चोरी और अनधिकृत पहुँच का जोखिम बढ़ जाता है। सावधानी से आगे बढ़ें।",
    ),
    "g_key_device_security_warning_title": MessageLookupByLibrary.simpleMessage(
      "डिवाइस सुरक्षा चेतावनी",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "स्वीकृत! जारी रखने के लिए स्वैप टैप करें.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "सटीक मात्रा",
    ),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "असीमित",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "असीमित अनुमोदन: राउटर इस टोकन को किसी भी समय खर्च कर सकता है। मानक अभ्यास, लेकिन यदि अनुबंध से समझौता किया जाता है तो जोखिम होता है।",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("अनुमोदन..."),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage(
      "सर्वोत्तम मार्ग",
    ),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "सर्वोत्तम स्रोत",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("जंजीर"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "स्वैप की पुष्टि करें",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "गैस अनुमान",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "डेक्स इतिहास",
    ),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "न्यूनतम. प्राप्त हुआ",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage(
      "कोई टोकन नहीं",
    ),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "कोई टोकन नहीं मिला",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "मूल्य चार्ट",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "मूल्य प्रभाव",
    ),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "उद्धरण विफल रहा",
    ),
    "g_key_dex_quote_unavailable": MessageLookupByLibrary.simpleMessage(
      "स्वैप कीमत प्रस्ताव सेवा अस्थायी रूप से उपलब्ध नहीं है। कृपया बाद में पुनः प्रयास करें।",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "खोज चिह्न/नाम/पता",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("चयन करें"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "अधिकतम फिसलन",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "पुष्टि की गई",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("असफल"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage("लंबित"),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("उद्धृत"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("स्वैप"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "स्वैप सफलतापूर्वक सबमिट किया गया",
    ),
    "g_key_dex_tokens_offline": MessageLookupByLibrary.simpleMessage(
      "टोकन सेवा उपलब्ध नहीं है। सीमित ऑफलाइन सूची दिखाई जा रही है।",
    ),
    "g_key_dex_untrusted_router": MessageLookupByLibrary.simpleMessage(
      "स्वैप ब्लॉक किया गया: राउटर पता पहचाना नहीं गया। आपकी सुरक्षा के लिए, इस लेन-देन को रद्द कर दिया गया।",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("आप भुगतान करें"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "आप प्राप्त करें",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "सक्रिय उत्पाद",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage("बैच"),
    "g_key_earn_best_apy": MessageLookupByLibrary.simpleMessage(
      "सर्वोत्तम APY",
    ),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("जलाना"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("एन खरीदें"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "N42 प्रोटोकॉल के साथ एन खरीदें",
    ),
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage(
      "प्रमाणित तीसरे पक्ष के अभियानों को खोजें",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "क्रॉस-चेन स्थानांतरण",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "दैनिक ऑन-चेन अंक",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("डेक्स स्वैप"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("गैस"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "दांव लगाना शुरू करें",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("बही"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "APY लोड हो रहा है...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("खनन"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("अधिक कमाएँ"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "मूल निवासी सोलाना हिस्सेदारी",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "कोई सक्रिय पद नहीं",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "नोड खनन में भाग लेकर पुरस्कार अर्जित करें",
    ),
    "g_key_earn_perps": MessageLookupByLibrary.simpleMessage("पर्प्स"),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "त्वरित उपकरण",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage("अनुशंसित"),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "स्वैप प्रकार चुनें",
    ),
    "g_key_earn_stablecoin_deposit": MessageLookupByLibrary.simpleMessage(
      "जमा करें",
    ),
    "g_key_earn_stablecoin_desc": MessageLookupByLibrary.simpleMessage(
      "USDC / USDT / DAI पर दैनिक आय प्राप्त करें",
    ),
    "g_key_earn_stablecoin_empty": MessageLookupByLibrary.simpleMessage(
      "अभी इस समय कोई स्थिर मुद्रा बाजार उपलब्ध नहीं है",
    ),
    "g_key_earn_stablecoin_title": MessageLookupByLibrary.simpleMessage(
      "स्थिर मुद्रा अर्जित करें",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "लिडो के साथ ETH को दांव पर लगाएं",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("स्वैप"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("कमाओ"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "कुल कमाई",
    ),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("सभी देखें"),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "समाधान पता अद्यतन किया गया",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("उन्नत"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage(
      "वार्षिक शुल्क",
    ),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("उपलब्ध"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("आधार मूल्य"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "उपलब्धता की जाँच की जा रही है...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("प्रतिबद्ध"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "प्रतिबद्धता विफल रही",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "पंजीकरण प्रतिबद्धता समाप्त हो गई. कृपया पंजीकरण प्रक्रिया फिर से शुरू करें।",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "प्रतिबद्ध...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "नवीनीकरण की पुष्टि करें",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "पुष्टि करें और भेजें",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "ईएनएस संकल्प की पुष्टि करें",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "पता कॉपी किया गया",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "वर्तमान समाप्ति",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("दिन बचे हैं"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "अपने .eth डोमेन नाम पंजीकृत करें और प्रबंधित करें",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "ईएनएस नाम का पता चला",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("समाप्त हो गया"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage(
      "समाप्त हो रहा है",
    ),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "पंजीकरण अवधि बढ़ाएँ",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("असफल"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "पंजीकरण को अंतिम रूप दिया जा रहा है",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "ईएनएस से शुरुआत करें",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "अपना .eth नाम प्राप्त करें",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "अमान्य पता (0x + 40 हेक्स वर्ण होना चाहिए)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "अमान्य ईएनएस नाम",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage(
      "अब तुम्हारा है!",
    ),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "कृपया पंजीकरण के दौरान ऐप को खुला रखें",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "अपनी Web3 पहचान प्रबंधित करें",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "न्यूनतम 3 अक्षर",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("मेरे डोमेन"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("ईएनएस नाम"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage("नई समाप्ति"),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "नये मालिक का पता",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "अभी तक कोई डोमेन नहीं",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("मालिक"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "कृपया प्रतीक्षा करें",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "प्रीमियम नाम",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "कीमत का टूटना",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("प्राथमिक"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "प्राथमिक नाम सफलतापूर्वक सेट हो गया",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "प्रसंस्करण...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "ईएनएस पंजीकृत करें",
    ),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("रजिस्टर करें"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "एथेरियम पर आपकी विकेंद्रीकृत पहचान",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "पंजीकरण विफल रहा",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "अभी पंजीकरण करें",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "पंजीकरण हो रहा है...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "पंजीकरण जानकारी",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "पंजीकरण अवधि",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "समाप्ति अनुस्मारक सक्षम करें",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "समाप्ति से 30, 7 और 1 दिन पहले सूचित करें",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("नवीनीकृत करें"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "अपना डोमेन पंजीकरण बढ़ाएँ",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "नवीनीकरण सफल",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "समाधान पता",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "ईएनएस का समाधान किया जा रहा है...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("खोजें"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "उपलब्ध .eth नाम खोजें",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      ".eth नाम खोजें",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "खोजने के लिए एक ENS नाम दर्ज करें",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "खोजें और रजिस्टर करें",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "ईएनएस खोजें",
    ),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "आपके अपने पते पर नहीं भेजा जा सकता",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "एथेरियम नाम सेवा",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "प्राथमिक के रूप में सेट करें",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage("मानक नाम"),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "पंजीकरण प्रारंभ करें",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("चरण 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("चरण 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("चरण 3"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "उपडोमेन बनाएं",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "उपडोमेन बनाया गया",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "उपडोमेन हटाएँ",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "यह उपडोमेन स्थायी रूप से हटा दिया जाएगा.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "उपडोमेन हटा दिया गया",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "अभी तक कोई उपडोमेन नहीं",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "केवल अक्षरों, संख्याओं और हाइफ़न का उपयोग करें",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "उपडोमेन लेबल",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "जैसे ब्लॉग, मेल, ऐप",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "मालिक का पता",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "वर्तमान वॉलेट का उपयोग करने के लिए इसे खाली छोड़ दें",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("उपडोमेन"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("सफलता!"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage("सुझाव"),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "पाठ अभिलेख",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ईएनएस प्रबंधक"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("कुल"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("स्थानांतरण"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "स्वामित्व को दूसरे पते पर स्थानांतरित करें",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "स्थानांतरण सफल",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "स्थानांतरण अपरिवर्तनीय है. सुनिश्चित करें कि नए मालिक का पता सही है।",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "कोई दूसरा नाम आज़माएं",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "ईएनएस पंजीकरण दो चरणों वाली प्रक्रिया है",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage("अनुपलब्ध"),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("रुको"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "प्रतीक्षा अवधि सामने चल रहे हमलों को रोकती है",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "प्रतीक्षा अवधि आगे बढ़ने से रोकती है",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage(
      "इंतज़ार कर रहा हूँ...",
    ),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "कृपया आगे बढ़ने से पहले समाधान किए गए पते को सत्यापित करें। ईएनएस नाम उनके स्वामी द्वारा स्थानांतरित या बदले जा सकते हैं।",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("वर्ष"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("साल"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "आपकी पहचान",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "प्रतिक्रिया डेटा पार्स करने में त्रुटि!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("डियो त्रुटि"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "सिंटैक्स त्रुटि का अनुरोध करें",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "अनधिकृत, कृपया लॉग इन करें",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("प्रवेश निषेध"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage(
      "त्रुटि का अनुरोध करें",
    ),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "अनुरोध का समय समाप्त हो गया",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("सर्वर असामान्य"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "सेवा लागू नहीं की गई",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("गेटवे त्रुटि"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "सेवा उपलब्ध नहीं है",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage("गेटवे टाइमआउट"),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "HTTP संस्करण समर्थित नहीं है",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "अनुरोध विफल, त्रुटि कोड:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "सिस्टम व्यस्त है, कृपया बाद में पुनः प्रयास करें",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "अनुरोध आवृत्ति बहुत तेज़ है",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage("डिकोडिंग विफल"),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "लेन-देन पहले से ही श्रृंखला पर है",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "प्रमाणपत्र कॉन्फ़िगरेशन त्रुटि!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "स्थिति कोड कॉन्फ़िगरेशन त्रुटि!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("अज्ञात त्रुटि!"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क कनेक्शन का समय समाप्त हो गया, कृपया नेटवर्क सेटिंग्स जांचें!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "सर्वर असामान्य है. कृपया बाद में पुन: प्रयास करें!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "अनुरोध रद्द कर दिया गया है, कृपया पुनः अनुरोध करें!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "निर्यात कीस्टोर",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "बैकअप युक्तियाँ",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "स्टोर करने के लिए पासवर्ड प्रबंधन टूल का उपयोग करें.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("नकल की गई"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "प्रतिलिपि रद्द कर दी गई",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage("पहचान बटुआ"),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "एन्क्रिप्टेड निजी कुंजी फ़ाइल.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage("आयात विधि"),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "कीस्टोर फ़ाइल",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "कृपया कीस्टोर जानकारी दर्ज करें।",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "प्राइवेटकी निर्यात करें",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "कीस्टोर और पासवर्ड प्राप्त करने से धारक को वॉलेट संपत्तियों पर पूर्ण नियंत्रण मिल जाएगा।",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "सावधानीपूर्वक रिकॉर्ड करें और सुरक्षित स्थान पर संग्रहित करें। एकाधिक भौतिक प्रतियाँ रखना सबसे सुरक्षित भंडारण विधि है।",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "यदि आपकी निजी कुंजी खो जाती है, तो उसे पुनः प्राप्त नहीं किया जा सकता है। इसका भौतिक रूप से बैकअप लें और इसे सुरक्षित रूप से संग्रहीत करें।",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "ऑफ़लाइन सहेजें",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "किसी भी मेलबॉक्स, नोटपैड, नेटवर्क डिस्क या चैट सॉफ़्टवेयर में सेव न करें जो सुरक्षित नहीं है।",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "कृपया नेटवर्क ट्रांसमिशन का उपयोग करें",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "कृपया इसे नेटवर्क टूल के माध्यम से प्रसारित करना सुनिश्चित करें, एक बार हैकर्स इसे प्राप्त कर लेते हैं, तो इससे अपूरणीय आर्थिक क्षति होगी",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "बचाने के लिए टूल का उपयोग करें",
    ),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "मैं समझता हूं कि जो कोई भी यह फ़ाइल और पासवर्ड प्राप्त करता है, उसका मेरे फंड पर पूरा नियंत्रण है - हानि स्थायी और अप्राप्य है",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "निर्यात की पुष्टि के लिए वॉलेट पासवर्ड दर्ज करें",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "निजी कुंजी देखने के लिए वॉलेट पासवर्ड दर्ज करें",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("फ़िल्टर करें"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("गैस चेतावनी"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "ऊपर होने पर अलर्ट करें",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "नीचे होने पर अलर्ट करें",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("सहेजें"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "दहलीज (ग्वेई)",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("आधार शुल्क"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("कस्टम"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("तेज"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क मांग के आधार पर गैस की कीमतों में उतार-चढ़ाव होता है। कम गैस = धीमी पुष्टि, उच्च गैस = तेज़ पुष्टि।",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("अधिकतम शुल्क"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क व्यस्त है",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क निष्क्रिय है",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क सामान्य है",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "मूल्य प्रवृत्ति",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "प्राथमिकता शुल्क",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "वास्तविक समय गैस की कीमतें",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage("गैस सेटिंग्स"),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("धीरे"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("मानक"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("गैस ट्रैकर"),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "खाता पहले ही आयात किया जा चुका है",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("जोड़ें"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage("खाता जोड़ें"),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "पता कॉपी किया गया",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "कनेक्ट करने से पहले सुनिश्चित करें कि आपका डिवाइस अनलॉक है और ब्लूटूथ सक्षम है।",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("ऐप जांचें"),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "नया डिवाइस कनेक्ट करें",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "कीस्टोन (क्यूआर) के साथ एयर-गैप",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "कनेक्ट लेजर (ब्लूटूथ)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "ट्रेज़ोर कनेक्ट करें (यूएसबी)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("जुड़ा हुआ"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "कनेक्ट हो रहा है...",
    ),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage(
      "डिस्कनेक्ट करें",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("वापस जाओ"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "कीस्टोन कनेक्ट करें",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "लेनदेन पर हस्ताक्षर करने के लिए इस क्यूआर कोड को अपने कीस्टोन डिवाइस से स्कैन करें",
    ),
    "g_key_hw_keystone_scan_response_hint": MessageLookupByLibrary.simpleMessage(
      "अपने कैमरे को अपने कीस्टोन डिवाइस पर प्रदर्शित क्यूआर कोड पर इंगित करें",
    ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("कीस्टोन हस्ताक्षर स्कैन करें"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "खातों को आयात करने के लिए अपने कीस्टोन डिवाइस से क्यूआर कोड को स्कैन करें",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "कीस्टोन प्रतिक्रिया को स्कैन करने के लिए टैप करें",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("अधिक लोड करें"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "खाते लोड हो रहे हैं...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "संकेत मिलने पर कृपया अपने डिवाइस पर पुष्टि करें",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "कोई खाता नहीं मिला",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "फिलहाल कोई ऐप खुला नहीं है",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "डिवाइस कनेक्ट नहीं है",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "कनेक्टेड नहीं",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("हटाओ"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "डिवाइस हटाएँ",
    ),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "सहेजे गए उपकरण",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "समर्थित उपकरण",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("आज"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "ट्रेज़ोर से कनेक्ट करने में विफल. सुनिश्चित करें कि USB कनेक्ट है.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "ट्रेज़ोर कनेक्ट करें",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "ट्रेज़ोर सफलतापूर्वक कनेक्ट हुआ",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "ट्रेज़ोर से कनेक्ट हो रहा है...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "अपने ट्रेज़ोर डिवाइस को यूएसबी केबल के माध्यम से कनेक्ट करें और इसे अनलॉक करें",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "खाते देखें",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "वॉलेट खाते",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("कल"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "एक चालू मुद्रा बटुआ पहले से मौजूद है।",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "कीस्टोर नहीं पढ़ सका",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("कीस्टोर"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("लॉग इन करें"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("लॉग आउट करें"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "क्या आप वाकई ऐप से बाहर निकलना चाहते हैं?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "उपलब्ध अंक",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "आज चेक-इन कर लिया गया है",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "चेक-इन करें",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage(
      "हो गया",
    ),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "चेक-इन विफल",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "N42 पर चेक-इन पुष्टि कर ली गई",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("प्रतिलिपि"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "दैनिक चेक-इन",
    ),
    "g_key_loyalty_earn_points": m28,
    "g_key_loyalty_empty_leaderboard": MessageLookupByLibrary.simpleMessage(
      "लीडरबोर्ड खाली है",
    ),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage("इतिहास"),
    "g_key_loyalty_invite_description": MessageLookupByLibrary.simpleMessage(
      "अपना रेफरल कोड साझा करें",
    ),
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "दोस्तों को आमंत्रित करें",
    ),
    "g_key_loyalty_leaderboard": MessageLookupByLibrary.simpleMessage(
      "शीर्ष सूची",
    ),
    "g_key_loyalty_no_history": MessageLookupByLibrary.simpleMessage(
      "कोई अंक इतिहास नहीं है",
    ),
    "g_key_loyalty_no_referrals": MessageLookupByLibrary.simpleMessage(
      "अभी तक कोई रेफरल नहीं है। शुरू करने के लिए अपना कोड साझा करें।",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "कोई पुरस्कार उपलब्ध नहीं है",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "कोई कार्य उपलब्ध नहीं है",
    ),
    "g_key_loyalty_no_wallet": MessageLookupByLibrary.simpleMessage(
      "कोई सक्रिय बटुआ नहीं",
    ),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("रेफरल"),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage("पुरस्कार"),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("कार्य"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("अंक"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "कुल कमाए गए",
    ),
    "g_key_loyalty_unavailable": MessageLookupByLibrary.simpleMessage(
      "सेवा उपलब्ध नहीं",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("उपयोग किए गए"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("फेसबुक"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("ट्विटर"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("ब्राउज़र"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("टेलीग्राम"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("कलह"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("यूट्यूब"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("इंस्टाग्राम"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("मार्केट कैप"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("ट्रेडिंग वॉल्यूम"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("कुल आपूर्ति"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("प्रचलन में"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("के बारे में"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("अधिक"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("कड़ियाँ"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("वेबसाइट"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "जंजीरों का प्रबंधन करें",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("उपलब्ध"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "स्टेकिंग की आवश्यकता है",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "कृपया बीज वाक्यांश दर्ज करें",
    ),
    "g_key_msgsign_btn": MessageLookupByLibrary.simpleMessage("हस्ताक्षर करें"),
    "g_key_msgsign_empty": MessageLookupByLibrary.simpleMessage(
      "कृपया पहले कोई संदेश दर्ज करें",
    ),
    "g_key_msgsign_failed": MessageLookupByLibrary.simpleMessage(
      "हस्ताक्षर विफल",
    ),
    "g_key_msgsign_input_hint": MessageLookupByLibrary.simpleMessage(
      "हस्ताक्षर करने के लिए संदेश दर्ज करें",
    ),
    "g_key_msgsign_result": MessageLookupByLibrary.simpleMessage("हस्ताक्षर"),
    "g_key_msgsign_title": MessageLookupByLibrary.simpleMessage(
      "संदेश हस्ताक्षर करें",
    ),
    "g_key_msgsign_unsupported": MessageLookupByLibrary.simpleMessage(
      "इस श्रृंखला के लिए संदेश हस्ताक्षर समर्थित नहीं हैं",
    ),
    "g_key_msgsign_warning": MessageLookupByLibrary.simpleMessage(
      "केवल उन्हीं संदेशों पर हस्ताक्षर करें जिन पर आपको पूरा भरोसा हो। दुर्भावनापूर्ण संदेश का उपयोग आपकी ओर से कार्यों को अधिकृत करने के लिए किया जा सकता है।",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("कुल"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("नाम"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("वापस"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage(
      "लेन-देन प्रस्तुत किया गया",
    ),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "अमान्य बटुआ पता",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("संतुलन"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "यह क्रिया अपरिवर्तनीय है. एनएफटी बर्न पते पर भेजा जाएगा।",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage(
      "एनएफटी जलाएं",
    ),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("संग्रह"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("अनुबंध"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("विवरण"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "एनएफटी लोड करने में विफल. पुन: प्रयास करने के लिए ठोकिए।",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("सब"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("वीडियो"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("मंजिल"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("एनएफटी गैलरी"),
    "g_key_nft_hide_spam": MessageLookupByLibrary.simpleMessage("स्पैम छिपाएं"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage("शिलालेख #"),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "कोई एनएफटी नहीं मिला",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "कोई एक्सप्लोरर लिंक उपलब्ध नहीं है",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "वीडियो प्लेबैक समर्थित नहीं है",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("साधारण"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "सामान्य स्थानांतरण अभी तक समर्थित नहीं हैं",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("मात्रा"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "नाम या संग्रह के आधार पर खोजें",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("एनएफटी भेजें"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "सोलाना एनएफटी हस्तांतरण जल्द ही आ रहे हैं",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("टोकन आईडी"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("प्रकार"),
    "g_key_nft_uncategorized": MessageLookupByLibrary.simpleMessage("अन्य"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "पासवर्ड मेल नहीं खाते",
    ),
    "g_key_perps_read_only": MessageLookupByLibrary.simpleMessage(
      "पढ़ने के लिए मात्रा। इस संस्करण में ऑर्डर रखना समर्थित नहीं है।",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "फ़ोन गैलरी से चयन करें",
    ),
    "g_key_pubkey": MessageLookupByLibrary.simpleMessage("सार्वजनिक कुंजी"),
    "g_key_receive_payment_request": MessageLookupByLibrary.simpleMessage(
      "भुगतान अनुरोध",
    ),
    "g_key_receive_request_line": m29,
    "g_key_remove_network": MessageLookupByLibrary.simpleMessage(
      "नेटवर्क हटाएं",
    ),
    "g_key_remove_network_confirm": m30,
    "g_key_reset": MessageLookupByLibrary.simpleMessage("रीसेट करें"),
    "g_key_retry": MessageLookupByLibrary.simpleMessage("पुनः प्रयास करें"),
    "g_key_scan_pay_unsupported": MessageLookupByLibrary.simpleMessage(
      "भुगतान अनुरोध टोकन या श्रृंखला इस बटुए में नहीं है",
    ),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "सावधानी बरतें",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "अनुबंध सुरक्षा की जाँच की जा रही है...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "उच्च जोखिम का पता चला",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "गो प्लस",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "अनुबंध सत्यापित सुरक्षित",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage("मेमो/नोट"),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "मेमो/नोट (वैकल्पिक)",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "QR कोड साझा करें",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("लिंक साझा करें"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage("शेयर विधि"),
    "g_key_sim_gas_estimate": m31,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "लेन-देन विफल होने की संभावना है",
    ),
    "g_key_sim_reverted_reason": m32,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "लेन-देन का अनुकरण किया जा रहा है...",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "लेन-देन सिमुलेशन पारित हुआ",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "इस नेटवर्क के लिए सिमुलेशन उपलब्ध नहीं है",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("बातचीत"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("सक्रिय"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "सक्रिय पद",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("रकम"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "दांव से हटाने की राशि",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("एपीवाई"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("औसत एपीवाई"),
    "g_key_stake_broadcast_unsupported": MessageLookupByLibrary.simpleMessage(
      "लेन-देन बनाया गया है, लेकिन इस चेन के लिए वॉलेट के अंदर ब्रॉडकास्ट करना अभी समर्थित नहीं है।",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("आयोग"),
    "g_key_stake_d_unbond": m33,
    "g_key_stake_days_remaining": m34,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "स्था. दैनिक इनाम",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "स्था. वार्षिक पुरस्कार",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "स्वैप पर जाएं",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "तरल स्टेकिंग",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("तरल"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "आपके लिक्विड टोकन का सीधे DEX पर कारोबार किया जा सकता है। इसे वापस मूल परिसंपत्ति में बदलने के लिए स्वैप का उपयोग करें।",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "न्यूनतम हिस्सेदारी",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "हिस्सेदारी हटाने के लिए कोई सक्रिय स्थिति नहीं",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage(
      "कोई ताला नहीं",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "अभी तक कोई दांव लगाने की स्थिति नहीं है",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "कोई सत्यापनकर्ता नहीं मिला",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "वॉलेट का पता उपलब्ध नहीं है",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "कुल स्टेकिंग अवलोकन",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "मेरी स्थिति",
    ),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("प्रोटोकॉल"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("पुरस्कार"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "सत्यापनकर्ता खोजें...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "एक सत्यापनकर्ता का चयन करें",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "हिस्सेदारी हटाने के लिए एक स्थिति का चयन करें",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "सत्यापनकर्ता का चयन करें",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage(
      "क्रमबद्ध करें",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("दांव"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage(
      "दाँव पर लगा हुआ",
    ),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "दांव लगाना शुरू करें",
    ),
    "g_key_stake_submitted": MessageLookupByLibrary.simpleMessage(
      "दांव लगाने का लेन-देन प्रस्तुत कर दिया गया है",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("दांव लगाना"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "लेन-देन सफलतापूर्वक तैयार हो गया",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "बंधन मुक्त करना",
    ),
    "g_key_stake_unbonding_warning": m35,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage(
      "दाँव से उतारना",
    ),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "अद्यतन किया जा रहा है...",
    ),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage(
      "सत्यापनकर्ता",
    ),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "तुम्हें प्राप्त होगा",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("पूर्ण"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("गैस की कीमत"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("अधिकतम गैस शुल्क"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "प्रति गैस अधिकतम शुल्क",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("लंबित"),
    "g_key_t_29": m36,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("विफलता"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("आगे बढ़ें"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("वॉलेट पासवर्ड"),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage("गलत वॉलेट पासवर्ड"),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "कृपया वॉलेट पासवर्ड दर्ज करें",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("गैस शुल्क दर"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "नवीनतम ब्लॉक गैस शुल्क दर औसत",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("बाहर स्थानांतरित करें"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "0 से बड़ी पूर्ण संख्या दर्ज करें.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage(
      "डेटा प्राप्त करने में विफल",
    ),
    "g_key_t_45": m37,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "प्राप्तकर्ता पता खाते की जाँच करें",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("खोजें"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("कोई हिसाब नहीं"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("में स्थानांतरण"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("अमान्य पता"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage("खाता सत्यापन सफल हुआ"),
    "g_key_t_52": m38,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "प्राप्तकर्ता पते पर कोई खाता नहीं है, और पहला स्थानांतरण कम से कम 10XRP है",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("प्रयुक्त गैस"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("गैस"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage("जोड़ें"),
    "g_key_token_discovery_add_selected": m39,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "टोकन जोड़ा गया",
    ),
    "g_key_token_discovery_banner": m40,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "सभी का चयन रद्द करें",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "कोई नया टोकन नहीं मिला",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "नजरअंदाज करें",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "सभी का चयन करें",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "खोजे गए टोकन",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("लेन-देन का इतिहास"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("लेन-देन विवरण"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "कृपया इतिहास में लेनदेन रसीदें देखें",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("राशि खर्च करें"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("राशि प्राप्त करें"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "आरंभ तिथि",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "दिनांक सीमा",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage(
      "समाप्ति तिथि",
    ),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage("दिशा"),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "कोई भी लेन-देन आपके फ़िल्टर से मेल नहीं खाता",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("यूयूआईडी"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage("नवीनतम संस्करण ढूंढें"),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("तुरंत अपडेट करें"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("नया संस्करण मिला"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "पहले से ही नवीनतम संस्करण",
    ),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "बीज वाक्यांश देखें",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "अब अपना बीज वाक्यांश दोबारा डालने का प्रयास करें।",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("आयात खाता"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("खाता बनाएँ"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage(
      "आपका काम पूरा हो गया!",
    ),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "अब आप अपने बटुए का पूरा आनंद ले सकते हैं।",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("आरंभ करें"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage(
      "अभी के लिए छोड़ें",
    ),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "आप अभी के लिए बीज वाक्यांश का बैकअप लेना छोड़ सकते हैं, और यदि आपको आवश्यकता हो तो किसी भी समय सेटिंग्स में इसे दोबारा कर सकते हैं।",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage("सीधे बनाएं"),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "सफलतापूर्वक बनाया गया",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "यदि आप अपना वॉलेट विवरण जांचना चाहते हैं या कीस्टोर निर्यात करना चाहते हैं, तो आप साइडबार > वॉलेट प्रबंधित करें पर जा सकते हैं ",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "मेरा कीस्टोर निर्यात करें",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "अपने बटुए का बैकअप लेकर उसे सुरक्षित करें",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "कीस्टोर सुरक्षा प्रमाणपत्रों और संबंधित निजी कुंजियों का भंडार है।",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "चरण 1: वॉलेट प्रबंधित करें पर जाएं।",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "चरण 2: वॉलेट पता चुनें।",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "चरण 3: एक्सपोर्ट कीस्टोर दबाएँ।",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "वॉलेट प्रबंधित करें पर जाएँ",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "मुखपृष्ठ पर वापस जाएँ",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("वॉलेट जोड़ें"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "बीज वाक्यांश का उपयोग करके एक बटुआ बनाएं।",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "बटुए का नाम दर्ज करें",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "आपने अपने वॉलेट बीज वाक्यांश का बैकअप नहीं लिया है!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("अभी बैकअप लें"),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "वॉलेट पासवर्ड सेट करें",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage("बैकअप वॉलेट"),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "कृपया निम्नलिखित बीज वाक्यांश रिकॉर्ड करें",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("प्रारंभ करें"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "इंटरनेट से जुड़े उपकरण आपकी जानकारी को उजागर कर सकते हैं। हमारा सुझाव है कि आप बीज वाक्यांश लिख लें और इसे सुरक्षित रूप से संग्रहीत कर लें।",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "चेतावनी: अपना बीज वाक्यांश किसी के सामने प्रकट न करें। N42Wallet आपसे कभी भी यह जानकारी नहीं मांगेगा। कृपया बेहद सतर्क रहें और इसे ऑफ़लाइन सुरक्षित रूप से संग्रहीत करें। यदि आपका बीज वाक्यांश उजागर हो जाता है, तो आप अपनी सारी संपत्ति खो सकते हैं और उन्हें पुनर्प्राप्त करने में असमर्थ हो सकते हैं।",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "चेतावनी: बीज वाक्यांश आपकी वॉलेट संपत्ति को पुनर्प्राप्त करने का एकमात्र तरीका है।",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("अगला कदम"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "बीज वाक्यांश देखने के लिए क्लिक करें",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "कृपया सुनिश्चित करें कि आसपास कोई अन्य व्यक्ति या कैमरा न हो",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "बीज वाक्यांश की पुष्टि करें",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage("वॉलेट सूचना"),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("बटुए का नाम"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "कृपया पहले अपने वॉलेट बीज वाक्यांश का बैकअप लें!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "बीज वाक्यांश की जाँच करें",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "अब अपना बीज वाक्यांश दर्ज करें।",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage(
      "वाक्यांश सेट करें",
    ),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "कृपया सुनिश्चित करें कि आप अपना बीज वाक्यांश रिकॉर्ड करें और इसे सुरक्षित रूप से संग्रहीत करें। आपको अपने क्रिप्टोकरेंसी वॉलेट को आयात करने या पुनर्प्राप्त करने के लिए इसकी आवश्यकता होगी।",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage(
      "बटुआ संपादित करें",
    ),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("समय"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("नतीजा"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage("लेनदेन हैश"),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("जोड़ें"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("पथ"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("ब्लॉक"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("मूल्य"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("गैर"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("तेज़ करो"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("नोट"),
    "g_key_wallet_m1": m41,
    "g_key_wallet_m19": m42,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "वर्तमान टोकन नहीं जोड़ा गया है.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "रिक्त स्थान से अलग किए गए शब्दों के साथ अपना बीज वाक्यांश दर्ज करें",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("वॉलेट आयात करें"),
    "g_key_wallet_m3": m43,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "वर्तमान टोकन शेष अपर्याप्त है.",
    ),
    "g_key_wallet_m5": m44,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage(
      "हस्ताक्षर करने में त्रुटि",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "वॉलेट प्रबंधित करें",
    ),
    "g_key_wallet_tx_replace_hint": MessageLookupByLibrary.simpleMessage(
      "उसी nonce और लगभग 20% अधिक गैस शुल्क के साथ एक प्रतिस्थापन लेनदेन प्रसारित किया जाएगा। यह केवल तभी प्रभावी होगा जब मूल लेनदेन अभी भी लंबित हो।",
    ),
    "g_key_wallet_tx_replace_submitted": MessageLookupByLibrary.simpleMessage(
      "प्रतिस्थापन लेन-देन प्रस्तुत किया गया",
    ),
    "g_key_wallet_tx_speedup": MessageLookupByLibrary.simpleMessage(
      "त्वरित करें",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "एथेरियम पता दर्ज करें (0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "केवल घड़ी वाला वॉलेट लेनदेन नहीं भेज सकता या उस पर हस्ताक्षर नहीं कर सकता",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage("वॉलेट देखें"),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "निजी कुंजी के बिना किसी भी ईवीएम पते को ट्रैक करें",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("आरक्षित"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("बेस रिजर्व"),
    "g_key_xml_11": m45,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("वृद्धिशील रिजर्व"),
    "g_key_xml_22": m46,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "स्वामित्व वाली वस्तुओं की संख्या",
    ),
    "g_key_xml_33": m47,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "कुल आरक्षित राशि की गणना कैसे करें",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "कुल रिज़र्व = बेस रिज़र्व + (स्वामित्व वाली वस्तुओं की संख्या × वृद्धिशील रिज़र्व)",
    ),
    "g_live_ended": MessageLookupByLibrary.simpleMessage(
      "लाइव स्ट्रीम समाप्त हो गई है",
    ),
    "g_live_enter_room_failed": m48,
    "g_live_follow": MessageLookupByLibrary.simpleMessage("फ़ॉलो"),
    "g_live_follow_wip": MessageLookupByLibrary.simpleMessage(
      "फ़ॉलो सुविधा जल्द आ रही है",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("टच आईडी और फेस आईडी"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("जेस्चर पासवर्ड"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "जेस्चर पासवर्ड सेट करें",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "अपना जेस्चर पैटर्न बनाएं",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "अपना जेस्चर पैटर्न पुष्टि करें",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "वर्तमान जेस्चर बनाएं",
    ),
    "g_lock_key21": m49,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "जेस्चर पासवर्ड रीसेट करें",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "बहुत अधिक असफल प्रयास, पुनः प्रयास करें",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "वॉलेट पासवर्ड जोड़ें?",
    ),
    "g_lock_key25": m50,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage("लेन-देन पुष्टि"),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "प्रत्येक बटुआ लेन-देन की पुष्टि करने के लिए बायोमेट्रिक प्रमाणीकरण (फेस आईडी / उंगली के निशान) की आवश्यकता होती है।",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage(
      "जेस्चर पासवर्ड सेट नहीं है",
    ),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "प्रत्येक ट्रांसफर की पुष्टि के लिए जेस्चर प्रमाणीकरण आवश्यक है।",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("सफल हुआ"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("असफल"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "बायोमेट्रिक पहचान सक्षम नहीं है",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "बायोमेट्रिक सत्यापन जोड़ें?",
    ),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage(
      "30डी परिवर्तन",
    ),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("7डी परिवर्तन"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("एटीएच"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("एटीएल"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("बाज़ार की गहराई"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "अभी तक कोई निगरानी सूची नहीं है",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("एफडीवी"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("उच्च 24एच"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "तरलता स्कोर",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("निम्न 24H"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("समाचार"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "कोई चार्ट डेटा नहीं",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage(
      "कोई परिणाम नहीं",
    ),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("पद"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("खोजें"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "सिक्के खोजें...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("ट्रेंडिंग"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage("निगरानी सूची"),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "सत्यापनकर्ता निष्क्रियता स्कोर उच्च है. दंड से बचने के लिए अपने नोड की स्थिति जांचें।",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("अनलॉक एन?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "क्लाउड सत्यापन गतिविधि",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage("सत्यापन सेटिंग्स"),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "पृष्ठभूमि सत्यापन संगीत",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("डिफ़ॉल्ट"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("मूक"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "जब पृष्ठभूमि सत्यापन सक्षम हो जाता है, तो संगीत पृष्ठभूमि में चलेगा। अगर संगीत बंद हो जाएगा तो सत्यापन भी बंद हो जाएगा.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("आपका स्तर"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "सेटअप के लिए गैस की थोड़ी मात्रा की आवश्यकता होती है।",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "आप N42Wallet पर एक ग्रुप नोड में सफलतापूर्वक शामिल हो गए हैं। मित्रों को आमंत्रित करने के लिए लिंक साझा करें, नोड सक्रिय करें और सत्यापन शुरू करें!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "मित्रों को साझा करें",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("जारी रखें"),
    "g_mining_key63": m51,
    "g_mining_key73": m52,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "मैंने अभी @N42Wallet पर एक नोड स्थापित किया है और मोबाइल उपकरणों पर सत्यापन शुरू किया है! आओ और मेरे साथ जुड़ो. विकेन्द्रीकृत भविष्य मोबाइल है!",
    ),
    "g_mining_key76": m53,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("खनिज"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("नोड"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("नेटवर्क"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "क्लाउड माइनिंग के लिए टेस्टनेट और मेननेट के बीच स्विच करें।",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "मुक्ति 768 के बाद उपलब्ध है।",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "इससे पहले के अनुरोधों पर कार्रवाई नहीं की जाएगी.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("घर"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("आज का इनाम"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "कृपया नीचे दिए गए डेटा को एक महत्वपूर्ण कुंजी मानें। हम अनुशंसा करते हैं कि इसे तुरंत किसी विश्वसनीय स्थान पर कॉपी और बैकअप कर लें।",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("डेटा कॉपी करें"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("निष्क्रिय"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage("आयात सफल"),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "एन्क्रिप्टेड डेटा खाली नहीं हो सकता!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "पासवर्ड खाली नहीं हो सकता!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "डिक्रिप्शन विफल. कृपया जांचें कि पासवर्ड सही है या नहीं!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "असमर्थित एन्क्रिप्टेड डेटा प्रारूप!",
    ),
    "g_mining_key_109": m54,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage("कल के पुरस्कार"),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage(
      "एन्क्रिप्टेड डेटा",
    ),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage(
      "फ़ाइलें आयात करें",
    ),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "कृपया एन्क्रिप्टेड डेटा दर्ज करें.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage(
      "आयात किया जा रहा है...",
    ),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("पुष्टि"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "मुक्ति में कुछ समय लगता है, कृपया एक क्षण प्रतीक्षा करें!",
    ),
    "g_mining_key_116": m55,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "इनाम प्रतिदिन जमा होता है और आपके एन वॉलेट में तभी भेजा जाता है जब यह ~0.5 एन तक पहुंच जाता है।",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("कुल पुरस्कार"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("खनन मूल्य"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage("कार्य विवरण"),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("सारांश"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("गतिविधियाँ"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "खनन किया गया कुल मूल्य",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage(
      "सत्यापन के बाद से",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("मुनाफ़ा गिनती"),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage("सत्यापित मूल्य"),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("योजनाएं चुनें"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "अनलॉक अवधि: किसी भी समय अनलॉक किया जा सकता है",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "वार्षिक अधिकतम पुरस्कार",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage("पुरस्कार वितरण"),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("दैनिक सीमा"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("गति"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage("सत्यापन योजनाएँ"),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "भुगतान विधि चुनें",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("भुगतान के तरीके"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage(
      "एन का उपयोग करके भुगतान करें",
    ),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("वॉलेट बैलेंस"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "इस लेन-देन के लिए आपके पास पर्याप्त N नहीं है",
    ),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "क्या आप वाकई छोड़ना चाहते हैं?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "जब तक आप कोई एक योजना नहीं चुनते, आपको कोई सत्यापन पुरस्कार नहीं मिलेगा।",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("विकलांग"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("इनाम"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("और देखें"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage("सत्यापन स्थिति"),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage(
      "अनलॉक करने के लिए",
    ),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("छोड़ें"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("पिछले 7 दिन"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage("संचित पुरस्कार"),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "पुरस्कारों का सत्यापन शुरू करने के लिए एन को लॉक करें।",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage(
      "पुरस्कार प्राप्त हुआ",
    ),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("उन्नत"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("प्रवेश"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("प्रो"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("पूर्ण नोड"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("मिनट/दिन"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("उन्नत नोड"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("प्रवेश नोड"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("प्रो नोड"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 ब्लॉक/दिन~70 मिनट",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("अनलॉक तिथि"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 ब्लॉक/दिन~15 मिनट",
    ),
    "g_mining_key_71": m56,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "प्रति चेक 128 सेकंड",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "परीक्षण श्रृंखला को उन्नत किया जा रहा है और ब्लॉकों को अस्थायी रूप से सत्यापित नहीं किया जा सकता है।",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "लगातार चार दिनों तक कार्य पूरा करने में विफल रहने पर कोई कमाई नहीं होगी और दंड का जोखिम होगा।",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("जोखिम स्कोर"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("छुड़ाओ"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "कृपया पहले सत्यापनकर्ता की सार्वजनिक और निजी कुंजी जोड़ी को सहेजें।",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("निर्यात करें"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage("आज का सत्यापन समय"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "स्थानांतरण के लिए अपर्याप्त धनराशि.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "सत्यापनकर्ता सूची",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "सत्यापनकर्ता आयात करें",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "सत्यापनकर्ता पहले से मौजूद है",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("कम जोखिम"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("मध्यम जोखिम"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "7-दिवसीय पुरस्कार",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("उच्च जोखिम"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "अनुबंध लोड हो रहा है और इस समय सत्यापित नहीं किया जा सकता है। कृपया कुछ देर इंतज़ार करें!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage(
      "सुरक्षा युक्तियाँ",
    ),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage("पृष्ठभूमि सत्यापन"),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "कृपया अपनी निजी कुंजी या स्मरणीय वाक्यांश सुरक्षित रखें।",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "आपकी निजी कुंजी या स्मरणीय वाक्यांश आपके वॉलेट संपत्तियों तक पहुंचने के लिए एकमात्र प्रमाण है।",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "कृपया इसे किसी सुरक्षित स्थान (कागज, पासवर्ड मैनेजर, आदि) में रखें।",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "स्क्रीनशॉट न लें, उन्हें इंटरनेट पर अपलोड न करें, या किसी के साथ साझा न करें।",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "एक बार खो जाने या समझौता हो जाने पर, आपकी वॉलेट संपत्ति वापस नहीं पाई जा सकती।",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage(
      "पुष्टि करें और सहेजें",
    ),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "एक पासवर्ड सेट करें और एन्क्रिप्ट करें",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "कृपया एन्क्रिप्शन पासवर्ड दर्ज करें",
    ),
    "g_mining_key_98": m57,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "कृपया यह सुनिश्चित करने के लिए अपना पासवर्ड पुनः दर्ज करें कि यह सही है",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "पूर्ण नोड विवरण",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("नोड आईडी"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage(
      "डब्ल्यूएस कनेक्टेड",
    ),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage(
      "WS डिस्कनेक्ट हो गया",
    ),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS पुन: कनेक्ट हो रहा है",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("समाप्ति"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "अनलॉक अवधि:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "किसी भी समय अनलॉक करने योग्य",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage(
      "कोई समाचार उपलब्ध नहीं है",
    ),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "वापस जाओ (सुरक्षित)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "वैसे भी आगे बढ़ें",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "इस वेबसाइट की पहचान संभावित रूप से दुर्भावनापूर्ण के रूप में की गई है। यह आपकी क्रिप्टो संपत्ति या निजी कुंजी चुराने का प्रयास कर सकता है।",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "सुरक्षा चेतावनी",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "संदिग्ध यूआरएल:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage("व्यापार जोड़ें"),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("औसत लागत"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "खरीदें मूल्य (USD)",
    ),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("लागत का आधार"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("मात्रा"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("सहेजें"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage(
      "अवास्तविक पी एंड एल",
    ),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("24 घंटे परिवर्तन"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "सभी होल्डिंग्स",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "परिसंपत्ति आवंटन",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage("टॉप गेनर्स"),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage(
      "शीर्ष हारने वाले",
    ),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage(
      "24 घंटे मूवर्स",
    ),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "कोई संपत्ति नहीं मिली",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("अन्य"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("कुल"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("पोर्टफोलियो"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("कुल मूल्य"),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage("परिणाम जोड़ें"),
    "g_pred_amount_input": m58,
    "g_pred_balance": m59,
    "g_pred_buy": MessageLookupByLibrary.simpleMessage("खरीदें"),
    "g_pred_cancel_refund": MessageLookupByLibrary.simpleMessage(
      "रद्द करें और रिफंड",
    ),
    "g_pred_close_only": MessageLookupByLibrary.simpleMessage("केवल बंद करें"),
    "g_pred_closed_waiting": MessageLookupByLibrary.simpleMessage(
      "बंद, परिणाम प्रतीक्षित",
    ),
    "g_pred_confirm_resolve": MessageLookupByLibrary.simpleMessage(
      "निपटान की पुष्टि करें",
    ),
    "g_pred_confirm_resolve_msg": m60,
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage(
      "भविष्यवाणी शुरू करें",
    ),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("बना रहे हैं…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("समय सीमा"),
    "g_pred_err_amount_low": MessageLookupByLibrary.simpleMessage(
      "राशि 0 से अधिक होनी चाहिए",
    ),
    "g_pred_err_insufficient_balance": MessageLookupByLibrary.simpleMessage(
      "अपर्याप्त शेष",
    ),
    "g_pred_err_insufficient_shares": MessageLookupByLibrary.simpleMessage(
      "अपर्याप्त शेयर",
    ),
    "g_pred_err_invalid_outcome": MessageLookupByLibrary.simpleMessage(
      "अमान्य परिणाम",
    ),
    "g_pred_err_invalid_state": MessageLookupByLibrary.simpleMessage(
      "मार्केट पहले ही सेटल हो चुका है, क्रिया की अनुमति नहीं है",
    ),
    "g_pred_err_market_closed": MessageLookupByLibrary.simpleMessage(
      "मार्केट बंद, ट्रेडिंग अनुपलब्ध",
    ),
    "g_pred_err_market_not_found": MessageLookupByLibrary.simpleMessage(
      "मार्केट नहीं मिला",
    ),
    "g_pred_err_not_resolved": MessageLookupByLibrary.simpleMessage(
      "मार्केट अनसुलझा, रिडीम नहीं कर सकते",
    ),
    "g_pred_err_not_resolver": MessageLookupByLibrary.simpleMessage(
      "केवल उस मेजबान को ही इस कार्य करने की अनुमति है जिसने इस मार्केट को बनाया था",
    ),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "कम से कम दो मान्य परिणाम",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage(
      "कृपया प्रश्न दर्ज करें",
    ),
    "g_pred_err_slippage": MessageLookupByLibrary.simpleMessage(
      "स्लिपेज पार, पुनः प्रयास करें",
    ),
    "g_pred_minutes": m61,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("नहीं"),
    "g_pred_outcome_n": m62,
    "g_pred_outcome_win": m63,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("परिणाम"),
    "g_pred_pick_winner": MessageLookupByLibrary.simpleMessage(
      "निपटान हेतु विजेता परिणाम चुनें (धन परिणाम अनुसार)",
    ),
    "g_pred_processing": MessageLookupByLibrary.simpleMessage(
      "प्रोसेस हो रहा है…",
    ),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("प्रकाशित करें"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "भविष्यवाणी प्रश्न, जैसे: इस दौर में कौन जीतेगा?",
    ),
    "g_pred_quote_info": m64,
    "g_pred_redeem_failed": m65,
    "g_pred_resolved": MessageLookupByLibrary.simpleMessage("सुलझाया गया"),
    "g_pred_result_label": m66,
    "g_pred_sell_n": m67,
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage(
      "असीमित (मैनुअल बंद)",
    ),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("हाँ"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage(
      "डाउनलोड किया गया",
    ),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "कोड आमंत्रित करें",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("आमंत्रित"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("खनन नोड्स"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("इनाम (एन)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "क्लासिक खनन (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "खनन (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "खनन इंटरफ़ेस",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("साझा करें"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("रेफरल"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "मित्रों को रेफर करें और एन टोकन प्राप्त करें!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("तुम ऊपर उठो "),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " एन जब आपका रेफरल सत्यापन शुरू करता है!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage(
      "के माध्यम से देखें",
    ),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("लिंक"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("कोड"),
    "g_swap_key_14": m68,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "सिक्का मूल्य त्रुटि प्राप्त करें.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "आगे बढ़ते हुए, आप निम्नलिखित से सहमत हैं ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage("नियम एवं शर्तें."),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("ख़त्म करो"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "आपका स्वैप शीघ्र ही वितरित किया जाएगा। कृपया धैर्य रखें।",
    ),
    "g_swap_key_20": m69,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "एक नोड चलाने की लागत: समूह सत्यापन 1-49 एन मूल नोड: 50 एन प्रीमियम नोड: 100 एन प्रो नोड: 500 एन।",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("समाप्ति"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("अवैतनिक"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage("भुगतान की पुष्टि"),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage(
      "वितरित किया जाना है",
    ),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("स्वैप सारांश"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("नया संतुलन"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("आप भुगतान करें"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("दिनांक"),
    "g_swap_key_31": m70,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "स्वैप को संबंधित श्रृंखला खोजकर्ताओं (इथरस्कैन, बीएससीस्कैन, ट्रॉनस्कैन और हमारे अपने) पर देखा जा सकता है।",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("एन पर स्वैप करें"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("स्वैप"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("तुम्हें मिल गया"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("पूर्वावलोकन स्वैप"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("पुनः प्रयास करें"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage("एक्सेंट रंग"),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "डिफ़ॉल्ट पर रीसेट करें",
    ),
    "g_theme_mode": MessageLookupByLibrary.simpleMessage("दृश्य"),
    "g_theme_style": MessageLookupByLibrary.simpleMessage("शैली"),
    "g_theme_style_custom": MessageLookupByLibrary.simpleMessage("कस्टम"),
    "g_token_m_key_1": m71,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "कोई भी टोकन बना सकता है, जिसमें मौजूदा टोकन के नकली संस्करण बनाना भी शामिल है। किसी टोकन को आयात करने से पहले हमेशा उस पर शोध करें।",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("टोकन"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("टोकन खोजें"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("श्रृंखला का नाम"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("जंजीर का प्रतीक"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("चेन आईडी"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("दशमलव"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("आरपीसी"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "कस्टम श्रृंखला जोड़ें",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 यूइंट"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("टोकन जोड़ें"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("प्रारूप त्रुटि!"),
    "g_token_m_key_22": m72,
    "g_token_m_key_23": m73,
    "g_token_m_key_24": m74,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("टोकन आयात करें"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("सभी नेटवर्क"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("कस्टम टोकन"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("सांकेतिक पता"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("सांकेतिक चिह्न"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("सांकेतिक दशमलव"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("आयात करें"),
    "g_token_m_key_chainid_conflict": MessageLookupByLibrary.simpleMessage(
      "इस चेन आईडी का उपयोग पहले से किसी अन्य नेटवर्क द्वारा किया जा रहा है।",
    ),
    "g_token_m_key_chainid_mismatch": m75,
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("सावधानी"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("उच्च जोखिम"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("सुरक्षित"),
    "g_ui_aave_lending": MessageLookupByLibrary.simpleMessage(
      "Aave V3 लेंडिंग",
    ),
    "g_ui_account_email": MessageLookupByLibrary.simpleMessage("खाता ईमेल"),
    "g_ui_algo_asset_add_fee": MessageLookupByLibrary.simpleMessage(
      "इस एसेट को जोड़ने के लिए नेटवर्क शुल्क की आवश्यकता है। जारी रखने के लिए जोड़ें दबाएं।",
    ),
    "g_ui_algo_asset_missing": m76,
    "g_ui_assistant_hint": MessageLookupByLibrary.simpleMessage(
      "बैलेंस, पोर्टफोलियो, गैस के बारे में पूछें",
    ),
    "g_ui_back_code": MessageLookupByLibrary.simpleMessage("कोड पर वापस जाएँ"),
    "g_ui_back_email": MessageLookupByLibrary.simpleMessage(
      "ईमेल पर वापस जाएँ",
    ),
    "g_ui_backup_create_save": MessageLookupByLibrary.simpleMessage(
      "बैकअप बनाएं और सहेजें",
    ),
    "g_ui_backup_empty": MessageLookupByLibrary.simpleMessage(
      "बैकअप फ़ाइल में कोई बटुआ नहीं मिला",
    ),
    "g_ui_backup_encryption_hint": MessageLookupByLibrary.simpleMessage(
      "आपका बैकअप AES-256 + PBKDF2 द्वारा एन्क्रिप्ट किया गया है। केवल सही पासवर्ड ही इसे पुनर्स्थापित कर सकता है।",
    ),
    "g_ui_backup_enter_password": MessageLookupByLibrary.simpleMessage(
      "कृपया बैकअप पासवर्ड दर्ज करें",
    ),
    "g_ui_backup_export": MessageLookupByLibrary.simpleMessage(
      "क्लाउड बैकअप निर्यात करें",
    ),
    "g_ui_backup_export_failed": MessageLookupByLibrary.simpleMessage(
      "बैकअप नहीं बनाया जा सका। कृपया फिर से प्रयास करें।",
    ),
    "g_ui_backup_file": MessageLookupByLibrary.simpleMessage("बैकअप फ़ाइल"),
    "g_ui_backup_file_access": MessageLookupByLibrary.simpleMessage(
      "चयनित फ़ाइल तक पहुँच नहीं हो रही है",
    ),
    "g_ui_backup_import": MessageLookupByLibrary.simpleMessage(
      "क्लाउड बैकअप आयात करें",
    ),
    "g_ui_backup_import_failed": MessageLookupByLibrary.simpleMessage(
      "बैकअप को पुनर्स्थापित करने में असमर्थ। पासवर्ड और बैकअप फ़ाइल की जांच करें, फिर पुनः प्रयास करें।",
    ),
    "g_ui_backup_import_result": m77,
    "g_ui_backup_import_wallets": MessageLookupByLibrary.simpleMessage(
      "बटुए आयात करें",
    ),
    "g_ui_backup_invalid_file": MessageLookupByLibrary.simpleMessage(
      "वैध N42Wallet बैकअप फ़ाइल नहीं है",
    ),
    "g_ui_backup_no_file": MessageLookupByLibrary.simpleMessage(
      "कोई फ़ाइल चयनित नहीं",
    ),
    "g_ui_backup_no_selection": MessageLookupByLibrary.simpleMessage(
      "बैकअप के लिए कोई मान्य बटुआ चुनी नहीं गई",
    ),
    "g_ui_backup_password": MessageLookupByLibrary.simpleMessage(
      "बैकअप पासवर्ड",
    ),
    "g_ui_backup_password_hint": MessageLookupByLibrary.simpleMessage(
      "एक मजबूत बैकअप पासवर्ड सेट करें (न्यूनतम 8 अक्षर)",
    ),
    "g_ui_backup_password_min": MessageLookupByLibrary.simpleMessage(
      "पासवर्ड कम से कम 8 अक्षर का होना चाहिए",
    ),
    "g_ui_backup_password_repeat": MessageLookupByLibrary.simpleMessage(
      "बैकअप पासवर्ड को फिर से दर्ज करें",
    ),
    "g_ui_backup_restore_hint": MessageLookupByLibrary.simpleMessage(
      "आइक्लाउड ड्राइव या गूगल ड्राइव पर संग्रहित एन्क्रिप्टेड बैकअप से अपने बटुओं को पुनर्स्थापित करें।",
    ),
    "g_ui_backup_restore_none": MessageLookupByLibrary.simpleMessage(
      "इस बैकअप से कोई बटुआ पुनर्स्थापित नहीं किया जा सका",
    ),
    "g_ui_backup_restore_password_hint": MessageLookupByLibrary.simpleMessage(
      "बैकअप बनाते समय उपयोग किए गए पासवर्ड को दर्ज करें",
    ),
    "g_ui_backup_select_file_first": MessageLookupByLibrary.simpleMessage(
      "कृपया पहले एक बैकअप फ़ाइल चुनें",
    ),
    "g_ui_backup_select_wallet": MessageLookupByLibrary.simpleMessage(
      "बैकअप के लिए कम से कम एक बटुआ चुनें",
    ),
    "g_ui_backup_select_wallets": MessageLookupByLibrary.simpleMessage(
      "बैकअप के लिए बटुआ चुनें",
    ),
    "g_ui_backup_share_subject": MessageLookupByLibrary.simpleMessage(
      "N42Wallet बैकअप",
    ),
    "g_ui_backup_warning": MessageLookupByLibrary.simpleMessage(
      "इस बैकअप में आपकी निजी कुंजियाँ / मनेमोनिक्स, बटुआ पासवर्ड और बटुआ सेटिंग्स शामिल हैं। बैकअप फ़ाइल और पासवर्ड को सुरक्षित रखें। किसी के साथ इन्हें कभी साझा न करें।",
    ),
    "g_ui_balance_value": m78,
    "g_ui_base_fee_value": m79,
    "g_ui_buy_n_description": MessageLookupByLibrary.simpleMessage(
      "N42 प्रोटोकॉल के माध्यम से N खरीदें",
    ),
    "g_ui_calldata_hex": MessageLookupByLibrary.simpleMessage(
      "कॉलडेटा (हेक्स)",
    ),
    "g_ui_camera_permission": MessageLookupByLibrary.simpleMessage(
      "कोड स्कैन करने के लिए कैमरा की अनुमति आवश्यक है।",
    ),
    "g_ui_cancel_order": MessageLookupByLibrary.simpleMessage(
      "लेन-देन रद्द करें",
    ),
    "g_ui_change_email": MessageLookupByLibrary.simpleMessage("ईमेल बदलें"),
    "g_ui_checking_approval": MessageLookupByLibrary.simpleMessage(
      "अनुमति जांची जा रही है…",
    ),
    "g_ui_clipboard_clear": m80,
    "g_ui_clipboard_empty": MessageLookupByLibrary.simpleMessage(
      "क्लिपबोर्ड खाली है",
    ),
    "g_ui_coins_load_failed": MessageLookupByLibrary.simpleMessage(
      "क्रिप्टोकरेंसी लोड करने में विफलता। कृपया फिर से प्रयास करें।",
    ),
    "g_ui_confirm_password": MessageLookupByLibrary.simpleMessage(
      "पासवर्ड की पुष्टि करें",
    ),
    "g_ui_confirm_update": MessageLookupByLibrary.simpleMessage(
      "अपडेट की पुष्टि करें",
    ),
    "g_ui_contract_info": MessageLookupByLibrary.simpleMessage(
      "कॉन्ट्रैक्ट जानकारी",
    ),
    "g_ui_create_wallet": MessageLookupByLibrary.simpleMessage("बटुआ बनाएं"),
    "g_ui_csv_header_only": MessageLookupByLibrary.simpleMessage(
      "कोई डेटा पंक्ति नहीं मिली (केवल हेडर पाया गया)।",
    ),
    "g_ui_csv_missing_fields": m81,
    "g_ui_csv_no_data": MessageLookupByLibrary.simpleMessage(
      "टिप्पणियों को हटाने के बाद कोई डेटा नहीं मिला।",
    ),
    "g_ui_custom_tag": MessageLookupByLibrary.simpleMessage("कस्टम टैग..."),
    "g_ui_days": m82,
    "g_ui_destination_tag": MessageLookupByLibrary.simpleMessage("गंतव्य टैग"),
    "g_ui_device_connected": m83,
    "g_ui_dex_description": MessageLookupByLibrary.simpleMessage(
      "Uniswap / 1inch / Jupiter के माध्यम से टोकन स्वैप करें",
    ),
    "g_ui_email_code_accepted": MessageLookupByLibrary.simpleMessage(
      "सत्यापन कोड स्वीकृत किया गया",
    ),
    "g_ui_email_code_sent": MessageLookupByLibrary.simpleMessage(
      "सत्यापन कोड का अनुरोध भेजा गया",
    ),
    "g_ui_ens_price_failed": MessageLookupByLibrary.simpleMessage(
      "ENS नवीनीकरण मूल्य लोड करने में असमर्थ। कृपया पुनः प्रयास करें।",
    ),
    "g_ui_ens_renew_failed": MessageLookupByLibrary.simpleMessage(
      "ENS नवीनीकरण विफल। कृपया पुनः प्रयास करें।",
    ),
    "g_ui_entry_price": MessageLookupByLibrary.simpleMessage("प्रवेश मूल्य"),
    "g_ui_expires_in": MessageLookupByLibrary.simpleMessage("समाप्त होता है:"),
    "g_ui_fear_greed": MessageLookupByLibrary.simpleMessage("डर और लालच"),
    "g_ui_file_picker_failed": MessageLookupByLibrary.simpleMessage(
      "फ़ाइल पिकर खोल नहीं पाया गया। कृपया फिर से प्रयास करें।",
    ),
    "g_ui_file_read_failed": MessageLookupByLibrary.simpleMessage(
      "चयनित फ़ाइल को पढ़ने में असमर्थ। कृपया फिर से प्रयास करें।",
    ),
    "g_ui_free_margin": MessageLookupByLibrary.simpleMessage("फ्री"),
    "g_ui_gas_prediction": MessageLookupByLibrary.simpleMessage(
      "अगले ब्लॉक गैस अनुमान",
    ),
    "g_ui_gas_value": m84,
    "g_ui_hours": m85,
    "g_ui_import_valid": m86,
    "g_ui_invalid_email": MessageLookupByLibrary.simpleMessage(
      "एक मान्य ईमेल पता दर्ज करें",
    ),
    "g_ui_issues_label": MessageLookupByLibrary.simpleMessage("समस्याएं:"),
    "g_ui_keystone_paired": MessageLookupByLibrary.simpleMessage(
      "काइस्टोन सफलतापूर्वक जोड़ा गया",
    ),
    "g_ui_limit_orders": MessageLookupByLibrary.simpleMessage("सीमा लेन-देन"),
    "g_ui_limit_price": MessageLookupByLibrary.simpleMessage("सीमा मूल्य"),
    "g_ui_limit_price_pair": m87,
    "g_ui_limit_value": m88,
    "g_ui_liquidation_price": MessageLookupByLibrary.simpleMessage(
      "लिक्विडेशन मूल्य",
    ),
    "g_ui_margin_utilization": MessageLookupByLibrary.simpleMessage("उपयोगिता"),
    "g_ui_markets_count": m89,
    "g_ui_memo": MessageLookupByLibrary.simpleMessage("मेमो"),
    "g_ui_mempool": MessageLookupByLibrary.simpleMessage("मेमपूल"),
    "g_ui_message": MessageLookupByLibrary.simpleMessage("संदेश"),
    "g_ui_min_balance_value": m90,
    "g_ui_mnemonic_wallet": MessageLookupByLibrary.simpleMessage(
      "मनेमोनिक बटुआ",
    ),
    "g_ui_mpc_intro": MessageLookupByLibrary.simpleMessage(
      "सुरक्षित MPC वॉलेट बनाने के लिए अपने सोशल अकाउंट से साइन इन करें। आपकी निजी कुंजी एन्क्रिप्ट किए गए हिस्सों में बाँटी जाती है, इसलिए खोने के लिए कोई सीड फ़्रेज़ नहीं होता।",
    ),
    "g_ui_mpc_no_phrase": MessageLookupByLibrary.simpleMessage(
      "बीज वाक्य की आवश्यकता नहीं",
    ),
    "g_ui_mpc_security": MessageLookupByLibrary.simpleMessage(
      "MPC-TSS द्वारा संचालित। आपकी कुंजी आपके डिवाइस, हमारे सर्वर और एक रिकवरी बैकअप में तीन एन्क्रिप्टेड शेयर में विभाजित होती है।",
    ),
    "g_ui_new_email": MessageLookupByLibrary.simpleMessage("नया ईमेल पता"),
    "g_ui_no_cached_email": MessageLookupByLibrary.simpleMessage(
      "इस उपकरण पर कोई ईमेल कैश नहीं है",
    ),
    "g_ui_no_coins": MessageLookupByLibrary.simpleMessage(
      "अभी तक कोई क्रिप्टोकरेंसी नहीं",
    ),
    "g_ui_no_dapps": MessageLookupByLibrary.simpleMessage("कोई DApps नहीं"),
    "g_ui_no_limit_orders": MessageLookupByLibrary.simpleMessage(
      "कोई सीमा लेन-देन नहीं",
    ),
    "g_ui_no_orders": MessageLookupByLibrary.simpleMessage(
      "कोई खुले आदेश नहीं",
    ),
    "g_ui_no_positions": MessageLookupByLibrary.simpleMessage(
      "कोई खुली पोजीशन नहीं",
    ),
    "g_ui_no_wallet": MessageLookupByLibrary.simpleMessage(
      "अभी तक कोई बटुआ नहीं",
    ),
    "g_ui_optional": MessageLookupByLibrary.simpleMessage("वैकल्पिक"),
    "g_ui_order_cancel_failed": MessageLookupByLibrary.simpleMessage(
      "रद्द करने में विफलता",
    ),
    "g_ui_order_cancelled": MessageLookupByLibrary.simpleMessage(
      "लेन-देन रद्द कर दिया गया",
    ),
    "g_ui_order_create_failed": MessageLookupByLibrary.simpleMessage(
      "लेन-देन बनाने में विफलता",
    ),
    "g_ui_order_created": MessageLookupByLibrary.simpleMessage(
      "सीमा लेन-देन बनाया गया",
    ),
    "g_ui_order_executed": MessageLookupByLibrary.simpleMessage("निष्पादित"),
    "g_ui_order_place": MessageLookupByLibrary.simpleMessage(
      "सीमा लेन-देन रखें",
    ),
    "g_ui_order_triggered": MessageLookupByLibrary.simpleMessage(
      "सक्रिय किया गया",
    ),
    "g_ui_orders_count": m91,
    "g_ui_orders_load_failed": MessageLookupByLibrary.simpleMessage(
      "सीमा लेन-देन लोड करने में असमर्थ",
    ),
    "g_ui_password_mismatch": MessageLookupByLibrary.simpleMessage(
      "पासवर्ड मेल नहीं खाते",
    ),
    "g_ui_paste_connection": MessageLookupByLibrary.simpleMessage(
      "कनेक्शन लिंक पेस्ट करें",
    ),
    "g_ui_pending_mempool": MessageLookupByLibrary.simpleMessage(
      "लंबित (मेमपूल)",
    ),
    "g_ui_popular_tokens": MessageLookupByLibrary.simpleMessage(
      "लोकप्रिय टोकन",
    ),
    "g_ui_position_size": MessageLookupByLibrary.simpleMessage("आकार"),
    "g_ui_positions_count": m92,
    "g_ui_private_key_wallet": MessageLookupByLibrary.simpleMessage(
      "निजी कुंजी बटुआ",
    ),
    "g_ui_read_only": MessageLookupByLibrary.simpleMessage("केवल पढ़ने के लिए"),
    "g_ui_recipients_count": m93,
    "g_ui_room_id": MessageLookupByLibrary.simpleMessage("रूम आईडी"),
    "g_ui_save_failed": MessageLookupByLibrary.simpleMessage(
      "सेव करना विफल। कृपया फिर से प्रयास करें।",
    ),
    "g_ui_send_code": MessageLookupByLibrary.simpleMessage("कोड भेजें"),
    "g_ui_sending_request": MessageLookupByLibrary.simpleMessage(
      "अनुरोध भेजा जा रहा है...",
    ),
    "g_ui_swap_mode": MessageLookupByLibrary.simpleMessage("स्वैप मोड चुनें"),
    "g_ui_tags": MessageLookupByLibrary.simpleMessage("टैग"),
    "g_ui_template_copied": MessageLookupByLibrary.simpleMessage(
      "टेम्पलेट कॉपी किया गया",
    ),
    "g_ui_token_contract_hint": MessageLookupByLibrary.simpleMessage(
      "टोकन कॉन्ट्रैक्ट (0x...)",
    ),
    "g_ui_token_found": m94,
    "g_ui_token_lookup": MessageLookupByLibrary.simpleMessage(
      "टोकन जानकारी खोजी जा रही है…",
    ),
    "g_ui_token_manual": MessageLookupByLibrary.simpleMessage(
      "टोकन सूची में नहीं मिला — कृपया प्रतीक और दशमलव स्थान स्वतः भरें",
    ),
    "g_ui_token_value": m95,
    "g_ui_trade_delete_failed": MessageLookupByLibrary.simpleMessage(
      "लेन-देन हटाने में असमर्थ। कृपया पुनः प्रयास करें।",
    ),
    "g_ui_trade_save_failed": MessageLookupByLibrary.simpleMessage(
      "लेन-देन सहेजने में असमर्थ। कृपया पुनः प्रयास करें।",
    ),
    "g_ui_transaction_hash_value": m96,
    "g_ui_unknown_status": MessageLookupByLibrary.simpleMessage(
      "अज्ञात स्थिति",
    ),
    "g_ui_update": MessageLookupByLibrary.simpleMessage("अपडेट करें"),
    "g_ui_update_email": MessageLookupByLibrary.simpleMessage(
      "ईमेल अपडेट करें",
    ),
    "g_ui_validation_counts": m97,
    "g_ui_validation_issues": MessageLookupByLibrary.simpleMessage(
      "सत्यापन समस्याएं",
    ),
    "g_ui_validation_more": m98,
    "g_ui_verification_code": MessageLookupByLibrary.simpleMessage(
      "सत्यापन कोड",
    ),
    "g_ui_verify_code": MessageLookupByLibrary.simpleMessage(
      "कोड की पुष्टि करें",
    ),
    "g_ui_view_market": MessageLookupByLibrary.simpleMessage(
      "मार्केट डेटा देखें",
    ),
    "g_ui_volume_24h": MessageLookupByLibrary.simpleMessage("24h वॉल्यूम"),
    "g_ui_volume_interest": m99,
    "g_ui_wallet_ai": MessageLookupByLibrary.simpleMessage("वॉलेट एआई"),
    "g_ui_wallet_get_started": MessageLookupByLibrary.simpleMessage(
      "शुरुआत करने के लिए बटुआ बनाएं या आयात करें",
    ),
    "g_ui_wallet_load_failed": MessageLookupByLibrary.simpleMessage(
      "बटुआ लोड करने में विफलता",
    ),
    "g_ui_wallet_loading": MessageLookupByLibrary.simpleMessage(
      "बटुआ लोड हो रहा है...",
    ),
    "g_ui_wallet_number": m100,
    "g_version_later": MessageLookupByLibrary.simpleMessage("बाद में"),
    "g_wallet_balance_warning": MessageLookupByLibrary.simpleMessage(
      "बैलेंस को ताजा करने में असमर्थ",
    ),
    "g_wallet_coin_total_value": MessageLookupByLibrary.simpleMessage(
      "कुल मूल्य",
    ),
    "g_wallet_coin_unit_price": MessageLookupByLibrary.simpleMessage("कीमत"),
    "g_wallet_group_hd": MessageLookupByLibrary.simpleMessage(
      "HD वॉलेट · निमॉनिक",
    ),
    "g_wallet_group_single": MessageLookupByLibrary.simpleMessage(
      "सिंगल-चेन · आयातित",
    ),
    "g_wallet_pin_token": MessageLookupByLibrary.simpleMessage("टोकन पिन करें"),
    "g_wallet_prices_cached": MessageLookupByLibrary.simpleMessage(
      "सहेजी गई कीमतें",
    ),
    "g_wallet_prices_hours": m101,
    "g_wallet_prices_just_updated": MessageLookupByLibrary.simpleMessage(
      "अभी अपडेट किया गया",
    ),
    "g_wallet_prices_minutes": m102,
    "g_wallet_prices_partial": MessageLookupByLibrary.simpleMessage(
      "आंशिक कीमतें",
    ),
    "g_wallet_prices_unavailable": MessageLookupByLibrary.simpleMessage(
      "कीमतें उपलब्ध नहीं",
    ),
    "g_wallet_receiver_address": MessageLookupByLibrary.simpleMessage(
      "प्राप्तकर्ता का पता",
    ),
    "g_wallet_sender_address": MessageLookupByLibrary.simpleMessage(
      "प्रेषक का पता",
    ),
    "g_wallet_unpin_token": MessageLookupByLibrary.simpleMessage(
      "टोकन पिन हटाएं",
    ),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "कनेक्शन टूट गया. कृपया पुनः कनेक्ट करें.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "डीएपी डिस्कनेक्ट हो गया है",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "सभी को डिस्कनेक्ट करें",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "सभी DApps से डिस्कनेक्ट करें?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "इस DApp से डिस्कनेक्ट करें?",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "कोई सक्रिय कनेक्शन नहीं",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "DApp से कनेक्ट करने के लिए QR कोड को स्कैन करें",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "कनेक्शन अनुरोध का समय समाप्त हो गया",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "सत्र समाप्त हो गया है",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("कनेक्टेड डीएपी"),
    "g_xrp_dest_tag_hint": MessageLookupByLibrary.simpleMessage(
      "एक्सचेंज पर भेजते समय आमतौर पर आवश्यक",
    ),
    "g_xrp_optional": MessageLookupByLibrary.simpleMessage("(वैकल्पिक)"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "लिंक",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("महत्वपूर्ण सूचना"),
    "login_email": MessageLookupByLibrary.simpleMessage("ईमेल"),
    "login_password": MessageLookupByLibrary.simpleMessage("पासवर्ड"),
    "next": MessageLookupByLibrary.simpleMessage("अगला"),
    "nicknameMessage": m103,
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "प्रोफ़ाइल संपादित करें",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("फ़ोटोग्राफ़"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "कृपया पता इनपुट करें",
    ),
    "push_bg_delivery_dialog_content": MessageLookupByLibrary.simpleMessage(
      "इस उपकरण में पृष्ठभूमि एप्लिकेशन को सीमित किया गया है, इसलिए आप चैट संदेश और लेन-देन अलर्ट्स को मिस कर सकते हैं जब एप्लिकेशन पृष्ठभूमि में हो या बंद हो।\n\nपृष्ठभूमि गतिविधि की अनुमति देने के लिए \"सेटिंग्स में जाएँ\" पर टैप करें, फिर इस एप्लिकेशन के लिए ऑटोस्टार्ट सक्षम करें।",
    ),
    "push_bg_delivery_dialog_title": MessageLookupByLibrary.simpleMessage(
      "पृष्ठभूमि डिलीवरी सीमित हो सकती है",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "याद न दिलाएं",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage(
      "बाद में",
    ),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "सेटिंग पर जाएं",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "पुश नोटिफिकेशन अक्षम हैं। आप चैट संदेश और ट्रांसफर अलर्ट मिस कर सकते हैं।\n\nकृपया सिस्टम सेटिंग में इस ऐप के लिए नोटिफिकेशन सक्षम करें।",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "सूचनाएं अक्षम हैं",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "पासवर्ड पुनः दर्ज करें",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "एक पासवर्ड चुनें (8~18 अक्षर)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "पासवर्ड की पुष्टि करें",
    ),
    "s_key_10": MessageLookupByLibrary.simpleMessage("ऐप के बारे में"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("सुरक्षा"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("लेन-देन"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("भाषा"),
    "search": MessageLookupByLibrary.simpleMessage("खोजें"),
    "verification": MessageLookupByLibrary.simpleMessage("सत्यापन"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "यदि मैं अपना गुप्त वाक्यांश खो दूं, तो मेरा धन हमेशा के लिए नष्ट हो जाएगा।",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "अगर मैं अपना बीज वाक्यांश किसी को बताता हूं या साझा करता हूं, तो मेरा पैसा चोरी हो सकता है।",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "अपने बीज वाक्यांश को सुरक्षित रखना मेरी जिम्मेदारी है।",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage("बीज वाक्यांश गलत."),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "जिस वॉलेट को आप आयात करना चाहते हैं उसके लिए बीज वाक्यांश दर्ज करें।",
    ),
  };
}

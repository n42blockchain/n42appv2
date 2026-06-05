// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(deviceName, os) =>
      "あなたのアカウントが${deviceName}（${os}）でログインされました。心当たりがない場合は、パスワードの変更をお勧めします。";

  static String m1(price) => "現在の価格: \$${price}";

  static String m2(symbol) => "価格アラート · ${symbol}";

  static String m3(s) => "${s} で再送信";

  static String m4(message) => "購入失敗：${message}";

  static String m5(productId) => "購入成功：${productId}";

  static String m6(productId) => "復元済み：${productId}";

  static String m7(value) => "${value}より大きい金額です。";

  static String m8(value) => "ウォレットは既に存在します。ウォレット名は「${value}」です";

  static String m9(value) => "${value}以上の金額を入力してください。";

  static String m10(value) => "行${value}のアドレスが重複しています";

  static String m11(value) => "残高が不十分です: 合計金額が利用可能な ${value} を超える可能性があります";

  static String m12(value) => "行${value}のアドレスが無効です";

  static String m13(value) => "行${value}の金額が無効です";

  static String m14(value) => "最大${value}人の受取人";

  static String m15(token) => "続行するには${token}を承認してください";

  static String m16(impact) => "高価格インパクト(${impact})！慎重に作業を進めてください。";

  static String m17(secs) => "見積もりの有効期限は ${secs}s です";

  static String m18(value) => "最大${value}% APYを獲得";

  static String m19(value) => "${value}秒ごとに自動更新";

  static String m20(address) => "アカウント${address}を追加しました";

  static String m21(address, network) =>
      "このハードウェアウォレットアカウントを追跡しますか？\n\nアドレス: ${address}\nネットワーク: ${network}";

  static String m22(app) => "現在のアプリ: ${app}";

  static String m23(days) => "${days} 日前";

  static String m24(value) => "アカウントのインポートに失敗しました: ${value}";

  static String m25(date) => "最後に接続しました: ${date}";

  static String m26(app) => "Ledgerで${app}アプリが開いていることを確認してください";

  static String m27(name) => "保存されたデバイスから「${name}」を削除してもよろしいですか?";

  static String m28(value) => "推定ガス: ~${value} 単位";

  static String m29(reason) => "理由: ${reason}";

  static String m30(value) => "${value}d 結合解除";

  static String m31(value) => "残り ${value} 日";

  static String m32(value) => "アンステークには ${value} 日かかります。この期間中、トークンはロックされます。";

  static String m33(value) => "「${value}」が不足しています";

  static String m34(value) => "「${value}」アカウントの取得に失敗しました";

  static String m35(value) => "初回送金には最低${value} XRPが必要です";

  static String m36(count) => "追加 (${count})";

  static String m37(count) =>
      "${Intl.plural(count, one: '1 個の新しいトークンが検出されました', other: '${count} 新しいトークンが検出されました')} — タップして確認してください";

  static String m38(value) => "${value}チェーンが追加されていません。";

  static String m39(value) => "${value}には未完了の取引があります。後でもう一度お試しください。";

  static String m40(value) => "${value}のアドレスが見つかりません。";

  static String m41(value) => "${value}の残高が不足しています。";

  static String m42(value, value1) =>
      "すべてのXRPアカウントはベースラインとして${value} XRP（${value1}ドロップ）を準備金として確保する必要があり、これは使用できません。";

  static String m43(value, value1) =>
      "アカウントが所有するオブジェクトごとに、${value} XRP（${value1}ドロップ）が準備金に追加されます。";

  static String m44(value, value1) =>
      "このアカウントは${value}個のオブジェクトを所有しているため、追加で${value1} XRPが準備金として確保されています。";

  static String m45(value) => "パターンが違います、残り${value}回";

  static String m46(value) => "パターンが違います、残り${value}回";

  static String m47(value) => "${value}のセットアップに成功しました。N42Walletで認証を開始します！";

  static String m48(value) =>
      "@N42Walletで私の${value}グループに参加して、Layer 1チェーンの初期マイナーになり、スマホで暗号資産を獲得しよう！";

  static String m49(value, value1) =>
      "ノードを実行するために${value1}まで${value} Nをロックしてもよろしいですか？";

  static String m50(value) => "インポートに失敗しました：${value}";

  static String m51(value) => "報酬を得るには、最低${value}のステーキング残高が必要です。";

  static String m52(value, value1) => "${value1}ブロックマイニングごとに${value} N";

  static String m53(value) => "${value}文字である必要があります";

  static String m54(n) => "${n} 分";

  static String m55(n) => "結果 ${n}";

  static String m56(value) => "${value}の残高が不足しています。";

  static String m57(value) => "${value}を受取中...";

  static String m58(value) =>
      "アプリ内でスワップされた${value}はまもなくウォレットに配布され、このプロセスでは売却できません。ノードの運用に使用できます。";

  static String m59(value) => "最大${value}文字";

  static String m60(value) => "${value}チェーンは既にアプリでサポートされています！";

  static String m61(value) => "${value}チェーンは既にアプリでサポートされています。追加しますか？";

  static String m62(value) => "${value}アドレスのテストリンクに失敗しました！";

  static String m63(value) => "0〜${value}文字";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("編集"),
    "Verification": MessageLookupByLibrary.simpleMessage("確認"),
    "address_Information": MessageLookupByLibrary.simpleMessage("アドレス情報"),
    "copy": MessageLookupByLibrary.simpleMessage("コピーしました"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("アドレスをコピー"),
    "descO": MessageLookupByLibrary.simpleMessage("説明（任意）"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "パスワードを変更",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("了解"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage("新しいデバイスでログイン"),
    "file": MessageLookupByLibrary.simpleMessage("ファイル"),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("↑を超える"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("以下にドロップ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage("価格が上がったら通知する"),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage("このアラートを有効にする"),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "0 より大きい有効な価格を入力してください",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("削除"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("アラートを設定する"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage("目標株価（米ドル）"),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage("アップデートアラート"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "トークンは同じネットワーク内でのみ送信できます。他のネットワークから送信すると、損失が発生する可能性があります。",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage("スキャンして受取"),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage("URLを入力してください"),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("説明を入力"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("ブラウザ"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage("ブラウザキャッシュをクリア"),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage("DAppに自動接続"),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("すべて閉じる"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("完了"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("履歴"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage("すべての履歴を消去"),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage("すべての閲覧履歴を消去しますか？"),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage("履歴を消去しました"),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("今日"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("昨日"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("DAppsを探す"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("人気"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("デックス"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("ブリッジ"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("ブックマーク"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("ツール"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "ブックマークがまだ追加されていません",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("ブックマーク"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("名前"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage("名前を入力してください"),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("説明"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("同意"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage("メッセージは削除されました"),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("取引"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("接続"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("利用可能なネットワーク"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("メッセージ署名"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("接続中"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage("ペアリング中、お待ちください。"),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("切断"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("拒否"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage(
      "ブロックされました",
    ),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("注意"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("安全"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage("確認済み"),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("コードを再送信する"),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage("生体認証スキャンのヒント"),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "認証のために指紋または顔をスキャンしてください。",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("ヒント"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("設定する"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "続行するには顔または指紋をスキャンしてください。",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("戻る"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage("Google 認証システム"),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator アプリで QR コードをスキャン",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage("またはキーを手動で入力:"),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage("6桁の確認コードを入力"),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "ウォレット送金の確認に Google 認証が必要です。",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "コードが違います、もう一度お試しください",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google 認証システム未設定",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage("連携成功"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("プロフィール"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("ニュース"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("認証"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("友達を招待"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("キャンセルしました"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "ネットワーク接続を確認して再試行してください",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage("購入できる商品がありません"),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage("購入を復元"),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage("購入を復元中…"),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("再試行"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "ストアを利用できません",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("購入"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("削除に失敗しました！"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("ガスリミット"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("これ以上ありません"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("読み込み中"),
    "g_key_108": MessageLookupByLibrary.simpleMessage("アドレス帳"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("ウォレットをインポート"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("管理"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("新しいアドレス"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("削除"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("保存"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("コピー"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("ウォレットを作成/インポート"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("テーマ"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("システム"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("ライト"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("ダーク"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("ウォレット一覧"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("データなし"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("金額が無効です"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("メインウォレット"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("取引が成功しました"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("パスワードが正しくありません"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("テストネット"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("メインネット"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("システム言語"),
    "g_key_15": MessageLookupByLibrary.simpleMessage("メインウォレットに設定"),
    "g_key_155": MessageLookupByLibrary.simpleMessage("ウォレットアドレス"),
    "g_key_156": MessageLookupByLibrary.simpleMessage("スキャンしてアドレスをコピー"),
    "g_key_159": MessageLookupByLibrary.simpleMessage("追加"),
    "g_key_16": MessageLookupByLibrary.simpleMessage("確認ウォレットを選択"),
    "g_key_163": MessageLookupByLibrary.simpleMessage("シンボル"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("貼り付け"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("チェーンを選択"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("取引が失敗しました"),
    "g_key_179": MessageLookupByLibrary.simpleMessage("これは私のウォレットアドレスです"),
    "g_key_181": MessageLookupByLibrary.simpleMessage("その他"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("保存に成功しました"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("成功"),
    "g_key_192": MessageLookupByLibrary.simpleMessage("ウォレットを削除してもよろしいですか？"),
    "g_key_193": MessageLookupByLibrary.simpleMessage("アクティブ"),
    "g_key_195": MessageLookupByLibrary.simpleMessage("カメラへのアクセス許可がありません。"),
    "g_key_196": MessageLookupByLibrary.simpleMessage("エクスプローラー"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("最大"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("資産"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("台帳が空です！"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("取引概要"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "リンクエラー、QRコードを再度スキャンしてください。",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("パスワード変更"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("現在のパスワード"),
    "g_key_208": MessageLookupByLibrary.simpleMessage("残高を同期中..."),
    "g_key_209": MessageLookupByLibrary.simpleMessage("秘密鍵"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("ウォレットパスワードを入力"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("秘密鍵エラー"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("市場情報"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage("パスワードが一致しません。"),
    "g_key_29": MessageLookupByLibrary.simpleMessage("残高"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("追加に失敗しました！"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("受取"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("送金"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("宛先"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("QRコードをスキャン"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("ウォレットアドレスを入力"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("利用可能残高"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("金額"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "この取引をカバーするための残高が不足しています。",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("送信"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("読み込みに失敗しました！"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("ウォレット"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("作成"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("送信元"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("確認"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("全てのトークン"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("設定"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "アカウントが正常に作成されました",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "アカウントの詳細",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage("アカウント名"),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "アカウント名を入力してください",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage("アカウントの種類"),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("アクティブ"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "最初のオペレーションを追加する",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage("追加操作"),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "アドレスを計算中...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "アドレスの計算に失敗しました。もう一度お試しください。",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("承認する"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("バッチ"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage("アトミック実行"),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "複数の操作を一度に実行する",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "1 回の操作で複数のトランザクションを送信する",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "バッチ実行に失敗しました",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "保存されたテンプレートはありません",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage("バッチ操作"),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage("ガスを節約する"),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "テンプレートとして保存",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage("送信中..."),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "バッチが正常に送信されました",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "テンプレートのロード",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "テンプレート名",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "テンプレート名を入力してください",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "テンプレートが保存されました",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage("テンプレート"),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "バッチトランザクション",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "1 回のトランザクションで承認と交換 - 2 段階の確認は不要",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "ワンクリックのバッチアクション",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "ETH の代わりに ERC-20 トークンを使用して取引をスポンサーしたり、手数料を支払います",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "任意のトークンでガソリンを支払う",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "秘密キーを紛失した場合は、信頼できる連絡先を介してアクセスを回復します",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "社会的回復",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "ガスレストランザクションをサポートするモジュラーERC-7579スマートアカウント",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("によって"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("チェーン"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("チェーンID"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("変更"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage("ステータスの確認"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("近日公開予定"),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "これは事実に反するアドレスです。これは最初のトランザクションでデプロイされます。",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "スマートアカウントの作成",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "最初のスマート アカウントを作成する",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "セッションキーの作成",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("作成されました"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "アカウントは最初のトランザクションで自動的にデプロイされます",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("導入済み"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("導入中..."),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "デプロイメントは、最初のトランザクションで自動的に行われます。",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "強化された機能を備えた次世代のイーサリアム アカウントを体験してください",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("詳細"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "ハイブリッド EOA/スマート アカウント - 導入は不要",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("エラー"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage("推定ガス量"),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage("バッチの実行"),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("期限切れ"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("有効期限が切れます"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("工場"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("無料"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "デフォルトを使用すると、ガスの推定に失敗しました",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("ガスの支払い"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "ガス支払いオプション",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage("ガススポンサー付き"),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("ガスレス"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "ガスレストランザクションとバッチ操作",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "ZeroDev のプラグイン サポートを備えたモジュラー アカウント",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("ラベル"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "最後のアクティビティ",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage("私のスマートアカウント"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "スマート アカウントはまだありません",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "フィルターに一致するアカウントはありません",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "操作は追加されていません",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "セッションキーがありません",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage("未展開"),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "スマートアカウントを作成（無料、ETHは不要）",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "資金を提供する — EVM トークンを受け取る",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Paymaster でガスレスで取引",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("運営"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("オーナー"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "トークンでガソリンを支払う",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "ETH でガスを支払う",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("で支払う"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage("ETHで支払う"),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "チェーン対応",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "利用可能性を確認中...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "チェーンカバレッジ",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "トランザクションガス料金の支払い方法を選択してください",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "推定コスト",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "ガスオプションの読み込み失敗",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage("再試行"),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("保留中"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("許可"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "プレビューアドレス",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("準備完了"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage("受信アドレス"),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("再試行"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("取り消し"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "このセッションキーを取り消してもよろしいですか?承認された DApp はトランザクションを実行できなくなります。",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "セッションキーを取り消す",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "セッションキーが取り消されました",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("取り消されました"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "セッションキーを取り消しています...",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "高度なセキュリティ機能を備えたマルチシグネチャ アカウント",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("保存されました"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage("チェーンの選択"),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "支払主を選択してください",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("選択済み"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "スマート アカウントを使用してトークンを送信する",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1日"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1時間"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30日間"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7日間"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "例：100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "最大金額",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "このキーの権限を理解しました",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "承認済みDAppコントラクトと対話",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "セッションキーの作成に失敗しました",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "セッションキーを作成しました",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "例：Uniswap、Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "ラベル / DApp名",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "セッションキーの詳細",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage("有効期間"),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "高リスク — 信頼できるDAppのみ",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage("セッションキー"),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "スマート アカウントへの一時的なアクセスで DApps を承認する",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "DAppアクセス",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "フル制御",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "送信のみ",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage("高リスク"),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage("低リスク"),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "中リスク",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "確認前に権限を確認してください",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "権限レベルを選択",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "設定した上限内でトークンを転送",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "単一所有者の基本的なスマート アカウント - ほとんどのユーザーに推奨",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "スマートアカウント",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage("スマートウォレット"),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage("支出制限"),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage("スポンサーあり（無料）"),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("スマートアカウント"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("総ガス量"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("トランザクション"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("すべて見る"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("アドレス"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage("名前を入力してください"),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage("アドレスを入力してください"),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage("コインタイプを選択してください"),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("アドレスを編集"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage("削除に成功しました"),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("コインを選択"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("コインを検索"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage("高度な機能"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage("受取人追加"),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage("放送中..."),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage("全クリア"),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "一括転送の確認",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("続ける"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "CSV形式: アドレス,金額,ラベル",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("完了"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "ガスを見積もっています...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "一括転送はEVMチェーンのみをサポート",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage("CSVエクスポート"),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage("一括転送のヘルプ"),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage("CSVインポート"),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "メモはオプションです",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Multicall3 を使用するとガス料金が安くなります",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "サポートされているトークンがありません",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage("受取人"),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage("トークンを選択"),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "1つのトランザクションで複数のアドレスにトークンを送信",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("署名中..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "左にスワイプして受信者を削除します",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage("一括送金"),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage("合計金額"),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "チェーンはサポートされていません",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("最安"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "受取予定額",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("最速"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage("見積もり取得"),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage("ブリッジ履歴"),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "利用可能なルートがありません",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage("おすすめ"),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("更新"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("ルート"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "チェーン検索...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("選択"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage("トークン選択"),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("スリッページ"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage("完了"),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage(
      "失敗しました",
    ),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "進行中",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage("保留中"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("ブリッジ"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage("ブリッジ失敗"),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "トランザクション処理中",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage("ブリッジ成功"),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "までロックされます",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "引き換えを送信する前に、ロック期間が期限切れであることを確認してください。",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTCはまだロックされています",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "vBTCを引き換える",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "ロック解除済み — 引き換える準備ができています",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "リスクを理解した上で続行したいと考えています",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "ステークを続ける",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage("仕組み"),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC はタイムロックが期限切れになるまでロックされます。以下のインターフェースでステーキングプロセスを完了してください。",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "あなたの BTC はステーキング期間全体にわたってロックされます。早期撤退はできません。",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "ロックはビットコイン OP_CHECKLOCKTIMEVERIFY (CLTV) によって強制され、バイパスできません。",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "スマート コントラクトのリスク: 監査は行われていますが、完全にリスクのないプロトコルはありません。",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "最小ステーキング: 0.001 BTC。最小ロック期間: 0.125 日 (~3 時間)。",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "リスク警告",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "あなたの BTC は、タイムロック (CLTV) を備えた 2-of-2 マルチシグ アドレスにロックされ、キーと N42 キャニスター キーによって保護されます。",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "BTCをロックする",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "オンチェーンでの確認後、vBTC が 1:1 の比率でウォレットに鋳造されます。",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "ミント vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "vBTC を保持してステーキング報酬を獲得します。 vBTC は DeFi プロトコルでも使用できます。",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "報酬を獲得する",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "ロック期間が終了したら、vBTC を書き込み、元の BTC を取り戻します。",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "ロック解除後に引き換える",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "BTC セルフカストディステーキング",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("了解"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. NFTサポートのトークンを選択",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage("2. NFTタブに移動"),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. 焼却するNFTを選択",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. 「焼却」ボタンをタップ",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("手順："),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "NFTを焼却するには、NFT詳細ページに移動して「焼却」ボタンをタップしてください。",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "このチェーンはまだ転送をサポートしていません。しばらくお待ちください",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "すべての資産が 1 ドル未満",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage("その他の資産"),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "タップしてすべて表示",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("最近の"),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "承認されました！ 「交換」をタップして続行します。",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage("正確な金額"),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage("無制限"),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "無制限承認：ルーターはいつでもこのトークンを使用できます。標準的な方法ですが、コントラクトが侵害された場合はリスクがあります。",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("承認中…"),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage("最適ルート"),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage("最適ソース"),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("チェーン"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage("スワップを確認"),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage("ガス見積もり"),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage("DEX 履歴"),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage("分。受け取りました"),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("トークンなし"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "トークンが見つかりません",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage("価格チャート"),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage("価格インパクト"),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage("見積もり失敗"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "シンボル / 名前 / アドレスで検索",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("選択"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage("最大滑り"),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage("確認済み"),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("失敗"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage("保留中"),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("見積もり済み"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("スワップ"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "スワップを送信しました",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("支払い"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage("受取り"),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "アクティブな製品",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage("バッチ転送"),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("バーン"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Nを購入"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "ASTプロトコルでNを購入",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage("クロスチェーン転送"),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("DEXスワップ"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("ガス"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage("ステーキング開始"),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("レジャー"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "APY読み込み中...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("マイニング"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("もっと稼ぐ"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "ネイティブSolanaステーキング",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "アクティブなポジションなし",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "ノードマイニングに参加して報酬を獲得",
    ),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage("クイックツール"),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage("おすすめ"),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "スワップタイプを選択",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "LidoでETHをステーク",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("スワップ"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("稼ぐ"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage("総収益"),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("すべて表示"),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "解決済みアドレスが更新されました",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("上級者向け"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("年会費"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("利用可能"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("基本価格"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage("空き状況を確認中..."),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("コミット"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "コミットに失敗しました",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "登録コミットメントの有効期限が切れました。登録プロセスをやり直してください。",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage("コミット中..."),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage("更新の確認"),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage("確認して送信"),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage("ENS解決の確認"),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "アドレスをコピーしました",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage("現在の有効期限"),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("残り日数"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      ".eth ドメイン名の登録と管理",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage("ENS名を検出しました"),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("期限切れ"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("有効期限が切れます"),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage("登録期間の延長"),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("失敗しました"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage("登録を完了しています"),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "ENS を始めましょう",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      ".eth 名を取得する",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "無効なアドレス (0x + 40 の 16 進数文字である必要があります)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage("無効なENS名"),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("今はあなたのものです！"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "登録中はアプリを開いたままにしてください",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Web3 ID を管理する",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage("最低 3 文字"),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("私のドメイン"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("ENS名"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage("新しい有効期限"),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage("新しい所有者の住所"),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "まだドメインがありません",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("オーナー"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage("お待ちください"),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage("プレミアム名"),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage("価格の内訳"),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("プライマリー"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "プライマリ名が正常に設定されました",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage("処理中..."),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "ENSを登録する",
    ),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("登録する"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "イーサリアム上の分散型アイデンティティ",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "登録に失敗しました",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage("今すぐ登録"),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage("登録中..."),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage("登録情報"),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "登録期間",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "期限リマインダーを有効にする",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "期限の 30 日、7 日、1 日前に通知",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("更新する"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage("ドメイン登録を延長する"),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage("更新成功"),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "解決されたアドレス",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage("ENSを解決中..."),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("検索"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "利用可能な .eth 名を検索する",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      ".eth 名を検索する",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "ENS 名を入力して検索します",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage("検索＆登録"),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage("ENSを検索"),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "自分のアドレスには送信できません",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage("イーサリアムネームサービス"),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage("プライマリとして設定"),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage("規格名"),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "登録を開始する",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("ステップ1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("ステップ2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("ステップ3"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "サブドメインの作成",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "サブドメインが作成されました",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "サブドメインの削除",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "このサブドメインは完全に削除されます。",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "サブドメインが削除されました",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "まだサブドメインがありません",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "文字、数字、ハイフンのみを使用してください",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "サブドメインラベル",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "例:ブログ、メール、アプリ",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage("所有者の住所"),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "現在のウォレットを使用するには空のままにしてください",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("サブドメイン"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("成功!"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage("提案"),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage("テキストレコード"),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ENSマネージャー"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("合計"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("転送"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "所有権を別のアドレスに移転する",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage("転送成功"),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "転送は元に戻せません。新しい所有者の住所が正しいことを確認してください。",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "別の名前を試してください",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "ENS の登録は 2 段階のプロセスです",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage("利用不可"),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("待ってください"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "待機期間により先手攻撃を防止",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "待機期間により前倒しが防止される",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("待っています..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "続行する前に解決されたアドレスを確認してください。ENS名は所有者によって転送または変更される可能性があります。",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("年"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("年"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "あなたのアイデンティティ",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage("レスポンスデータの解析エラー！"),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("通信エラー"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage("リクエスト構文エラー"),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "認証されていません。ログインしてください",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("アクセスが拒否されました"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("リクエストエラー"),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage("リクエストがタイムアウトしました"),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("サーバー異常"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage("サービスが実装されていません"),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("ゲートウェイエラー"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage("サービスが利用できません"),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage("ゲートウェイタイムアウト"),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "HTTPバージョンがサポートされていません",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "リクエストが失敗しました。エラーコード：",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "システムがビジー状態です。後でもう一度お試しください",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage("リクエスト頻度が高すぎます"),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage("デコードに失敗しました"),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage("取引は既にチェーン上にあります"),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage("証明書の設定エラー！"),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage("ステータスコードの設定エラー！"),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("不明なエラー！"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "ネットワーク接続がタイムアウトしました。ネットワーク設定を確認してください！",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "サーバーに異常が発生しました。後でもう一度お試しください！",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "リクエストがキャンセルされました。再度リクエストしてください！",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage("キーストアをエクスポート"),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage("バックアップのヒント"),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "パスワード管理ツールを使用して保存してください。",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("コピーしました"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "コピーがキャンセルされました",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage("IDウォレット"),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "暗号化された秘密鍵ファイル。",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage("インポート方法"),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage("キーストアファイル"),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "キーストア情報を入力してください。",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage("秘密鍵をエクスポート"),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "キーストアとパスワードを取得すると、所持者はウォレット資産を完全に管理できます。",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "注意深く記録し、安全な場所に保管してください。複数の物理コピーを保持することが最も安全な保管方法です。",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "秘密鍵を紛失した場合、回復できません。物理的にバックアップし、安全に保管してください。",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage("オフラインで保存"),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "安全でないメール、メモ帳、ネットワークドライブ、チャットソフトウェアには保存しないでください。",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "ネットワーク転送を使用してください",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "ネットワークツールを通じて転送してください。ハッカーに取得されると、取り返しのつかない経済的損失が発生します",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage("ツールを使用して保存"),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "このファイルとパスワードを入手した人は誰でも私の資金を完全に管理できます。損失は永続的で回復不能です。",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "エクスポートを確認するにはウォレットのパスワードを入力してください",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "秘密鍵を表示するにはウォレットのパスワードを入力してください",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("フィルター"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Gasアラート"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage("以上でアラート"),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage("以下でアラート"),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("保存"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "しきい値 (Gwei)",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("基本料金"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("高速"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "ガス価格はネットワーク需要に基づいて変動します。低いガス=遅い確認、高いガス=速い確認。",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("最大料金"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage("ネットワーク混雑中"),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage("ネットワーク空き"),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "ネットワーク正常",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage("価格推移"),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage("優先料金"),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "リアルタイムガス価格",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage("ガス設定"),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("低速"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("標準"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Gasトラッカー"),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "アカウントはすでにインポートされています",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("追加"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage("アカウント追加"),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "アドレスをコピーしました",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "接続する前に、デバイスのロックが解除されており、Bluetooth が有効になっていることを確認してください。",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("アプリをチェックする"),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "新しいデバイスを接続する",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "キーストーン付きエアギャップ (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "台帳の接続 (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Trezor を接続する (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("接続済み"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage("接続中..."),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("切断する"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("戻る"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "キーストーンを接続する",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Keystone デバイスでこの QR コードをスキャンして、トランザクションに署名します",
    ),
    "g_key_hw_keystone_scan_response_hint":
        MessageLookupByLibrary.simpleMessage(
          "Keystone デバイスに表示されている QR コードにカメラを向けます。",
        ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("キーストーン署名のスキャン"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Keystone デバイスから QR コードをスキャンしてアカウントをインポートします",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "タップしてキーストーン応答をスキャンします",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("さらに読み込む"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "アカウントを読み込み中...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "求められた場合はデバイスで確認してください",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "アカウントが見つかりません",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "現在開いているアプリはありません",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "デバイスが接続されていません",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "接続されていません",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("削除"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage("デバイスの削除"),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage("保存されたデバイス"),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "サポートされているデバイス",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("今日"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Trezor への接続に失敗しました。 USB が接続されていることを確認してください。",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "トレザーを接続する",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor は正常に接続されました",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Trezor に接続中...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Trezor デバイスを USB ケーブルで接続し、ロックを解除します",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "アカウントを表示する",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "ウォレットアカウント",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("昨日"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "現在の通貨ウォレットは既に存在します。",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "キーストアを読み取れませんでした",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("キーストア"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("ログイン"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("ログアウト"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "アプリを終了してもよろしいですか？",
    ),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("フェイスブック"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("ツイッター"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("レディット"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("ブラウザ"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("電報"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("不和"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("ユーチューブ"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("インスタグラム"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("時価総額"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("取引量"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("総供給量"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("流通量"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("概要"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("詳細"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("リンク"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("ウェブサイト"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage("チェーンの管理"),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("利用可能"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "ステーキングが必要です",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage("シードフレーズを入力してください"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("合計"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("名前"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("戻る"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("取引が送信されました"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "無効なウォレットアドレス",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("バランス"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "この操作は元に戻せません。 NFT は書き込みアドレスに送信されます。",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("NFTを書き込む"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("コレクション"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("契約書"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("説明"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "NFTの読み込みに失敗しました。タップして再試行します。",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("すべて"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("ビデオ"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("床"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("NFTギャラリー"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage("碑文番号"),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "NFTが見つかりませんでした",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "使用可能なエクスプローラー リンクがありません",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "ビデオ再生はサポートされていません",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("序数"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "序数転送はまだサポートされていません",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("数量"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "名前またはコレクションで検索",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("NFTを送信する"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana NFT 転送が間もなく開始されます",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("トークンID"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("種類"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "パスワードが一致しません",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage("ギャラリーから選択"),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("リセット"),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "使用上の注意",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "契約のセキュリティを確認しています...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "高リスクが検出されました",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "ゴープラス",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "契約確認済みの金庫",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage("メモ/メモ"),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "メモ/メモ (オプション)",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("QRコードを共有"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("リンクを共有"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage("共有方法"),
    "g_key_sim_gas_estimate": m28,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "トランザクションが失敗する可能性が高い",
    ),
    "g_key_sim_reverted_reason": m29,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "トランザクションをシミュレートしています…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "トランザクションシミュレーションに合格しました",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "このネットワークではシミュレーションを使用できません",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("チャット"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("アクティブ"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "アクティブなポジション",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("金額"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "ステークを解除する金額",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("年利"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("平均APY"),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("手数料"),
    "g_key_stake_d_unbond": m30,
    "g_key_stake_days_remaining": m31,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "推定毎日の報酬",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "推定年間報酬",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage("スワップに行く"),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "リキッドステーキング",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("液体"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "リキッドトークンはDEXで直接取引できます。 Swap を使用してネイティブ アセットに戻します。",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage("最低ステーク額"),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "ステーキングを解除するアクティブなポジションがありません",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("ロックなし"),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "まだステーキングポジションはありません",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "バリデータが見つかりません",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "ウォレットアドレスが利用できません",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "トータルステーキングの概要",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage("マイポジション"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("プロトコル"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("報酬"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "バリデータを検索...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "バリデーターを選択してください",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "ステーキングを解除するポジションを選択してください",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "バリデーター選択",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage("並べ替え順"),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("ステーク"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("杭打ち"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "ステーキングを開始する",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("ステーキング"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "トランザクションが正常に準備されました",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage("アンボンディング中"),
    "g_key_stake_unbonding_warning": m32,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("アンステーク"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage("更新中..."),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("バリデーター"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage("受け取ります"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("完了"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("ガス価格"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("最大ガス手数料"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("ガスあたりの最大手数料"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("保留中"),
    "g_key_t_29": m33,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("失敗"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("続行"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("ウォレットパスワード"),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage("ウォレットパスワードが間違っています"),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage("ウォレットパスワードを入力してください"),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("ガス手数料率"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage("最新ブロックのガス手数料率の平均"),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("送金"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage("0より大きい整数を入力してください。"),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage("データの取得に失敗しました"),
    "g_key_t_45": m34,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage("受取アドレスアカウントを確認"),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("検索"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("アカウントなし"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("入金"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("無効なアドレス"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage("アカウント確認成功"),
    "g_key_t_52": m35,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "受取アドレスにはアカウントがなく、初回送金には最低10XRPが必要です",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("使用ガス"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("ガス"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage("追加"),
    "g_key_token_discovery_add_selected": m36,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "トークンが追加されました",
    ),
    "g_key_token_discovery_banner": m37,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "すべての選択を解除します",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "新しいトークンが見つかりませんでした",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "無視する",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "すべて選択",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "検出されたトークン",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("取引履歴"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("取引詳細"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage("取引レシートは履歴でご確認ください"),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("支払い金額"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("受取金額"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage("開始日"),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage("日付範囲"),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage("終了日"),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage("方向"),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "フィルタに一致するトランザクションはありません",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage("最新バージョンが見つかりました"),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("今すぐアップデート"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("新しいバージョンが見つかりました"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage("既に最新バージョンです"),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage("シードフレーズを表示"),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "シードフレーズを再度入力してください。",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("アカウントをインポート"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("アカウントを作成"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("設定が完了しました！"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "ウォレットを存分にお楽しみください。",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("はじめる"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("今はスキップ"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "シードフレーズのバックアップは今すぐスキップでき、必要な場合はいつでも設定で再度行えます。",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage("直接作成"),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage("作成に成功しました"),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "ウォレットの詳細を確認したり、キーストアをエクスポートしたい場合は、サイドバー > ウォレット管理 にアクセスしてください",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage("キーストアをエクスポート"),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "ウォレットをバックアップして安全に保護",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "キーストアはセキュリティ証明書と関連する秘密鍵のリポジトリです。",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "ステップ1：ウォレット管理に移動。",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "ステップ2：ウォレットアドレスを選択。",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "ステップ3：キーストアをエクスポートを押す。",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage("ウォレット管理へ"),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage("ホームページに戻る"),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("ウォレットを追加"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "シードフレーズを使用してウォレットを作成。",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage("ウォレット名を入力"),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "ウォレットのシードフレーズがバックアップされていません！",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("今すぐバックアップ"),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage("ウォレットパスワードを設定"),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage("ウォレットをバックアップ"),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "以下のシードフレーズを記録してください",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("開始"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "インターネット接続されたデバイスは情報を露出させる可能性があります。シードフレーズを書き留めて安全に保管することをお勧めします。",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "警告：シードフレーズを誰にも開示しないでください。N42Walletがこの情報をお尋ねすることはありません。細心の注意を払い、オフラインで安全に保管してください。シードフレーズが露出すると、すべての資産を失い、回復できなくなる可能性があります。",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "警告：シードフレーズはウォレット資産を回復する唯一の方法です。",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("次のステップ"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "クリックしてシードフレーズを表示",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "周囲に他の人やカメラがないことを確認してください",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage("シードフレーズを確認"),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage("ウォレット情報"),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("ウォレット名"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "まずウォレットのシードフレーズをバックアップしてください！",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage("シードフレーズを確認"),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "シードフレーズを入力してください。",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("フレーズを設定"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "シードフレーズを記録し、安全に保管してください。暗号資産ウォレットのインポートまたは復元に必要です。",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage("ウォレット編集"),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("時間"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("結果"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage("取引ハッシュ"),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("追加"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("パス"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("ブロック"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("値"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("ノンス"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("高速化"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("メモ"),
    "g_key_wallet_m1": m38,
    "g_key_wallet_m19": m39,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "現在のトークンが追加されていません。",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "シードフレーズをスペースで区切って入力してください",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("ウォレットをインポート"),
    "g_key_wallet_m3": m40,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "現在のトークン残高が不足しています。",
    ),
    "g_key_wallet_m5": m41,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("署名エラー"),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage("ウォレット管理"),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "イーサリアムアドレスを入力してください (0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "監視専用ウォレットではトランザクションの送信または署名ができません",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage("ウォッチウォレット"),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "秘密キーなしであらゆるEVMアドレスを追跡",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("予約済み"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("基本準備金"),
    "g_key_xml_11": m42,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("増分準備金"),
    "g_key_xml_22": m43,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage("所有オブジェクト数"),
    "g_key_xml_33": m44,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage("合計準備金額の計算方法"),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "合計準備金 = 基本準備金 +（所有オブジェクト数 × 増分準備金）",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch IDとFace ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("ジェスチャーパスワード"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage("ジェスチャーパスワードを設定"),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage("ジェスチャーパターンを描いてください"),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage("ジェスチャーパターンを確認してください"),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage("現在のジェスチャーを描いてください"),
    "g_lock_key21": m45,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage("ジェスチャーパスワードをリセット"),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "試行回数が多すぎます、もう一度お試しください",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage("ウォレットパスワードを追加しますか？"),
    "g_lock_key25": m46,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage(
      "Transfer Verification",
    ),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "Require biometric authentication (Face ID / fingerprint) to confirm each wallet transfer.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage("ジェスチャーパスワード未設定"),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "ウォレット送金の確認にジェスチャー認証が必要です。",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("成功"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("失敗"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage("生体認証が有効になっていません"),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage("生体認証を追加しますか？"),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage("30D変化"),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("7Dチェンジ"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("マーケットデプス"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "ウォッチリストはまだありません",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("高24時間"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage("流動性スコア"),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("低 24 時間"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("ニュース"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage("チャートデータがありません"),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage("結果はありません"),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("ランク"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("検索"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage("コインを検索..."),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("トレンド"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage("ウォッチリスト"),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "バリデーターの非活動スコアが高いです。ペナルティを避けるため、ノードのステータスを確認してください。",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Nをアンロックしますか？"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage("クラウド認証アクティビティ"),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage("検証設定"),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage("バックグラウンド検証音楽"),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("デフォルト"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("ミュート"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "バックグラウンド検証が有効になっている場合、音楽はバックグラウンドで再生されます。音楽が止まると検証も止まります。",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("あなたの階層"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "セットアップには少量のガスが必要です。",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "N42Walletのグループノードに正常に参加しました。リンクを共有して友達を招待し、ノードをアクティブ化して認証を開始しましょう！",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage("友達に共有"),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("続行"),
    "g_mining_key63": m47,
    "g_mining_key73": m48,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "@N42Walletでノードをセットアップし、モバイルデバイスで認証を開始しました！ぜひ参加してください。分散化された未来はモバイルです！",
    ),
    "g_mining_key76": m49,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("ミネラル"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("ノード"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("ネットワーク"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "クラウド マイニング用にテストネットとメインネットを切り替えます。",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage("768秒後に引き換え可能です。"),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "それ以前のリクエストは処理されません。",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("ホーム"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("本日の報酬"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "以下のデータを重要な鍵として扱ってください。すぐにコピーして信頼できる場所にバックアップすることをお勧めします。",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("データをコピー"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("非アクティブ"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage("インポート成功"),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "暗号化データを空にすることはできません！",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "パスワードを空にすることはできません！",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "復号に失敗しました。パスワードが正しいか確認してください！",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "サポートされていない暗号化データ形式です！",
    ),
    "g_mining_key_109": m50,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage("昨日の報酬"),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage("暗号化データ"),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("ファイルをインポート"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "暗号化データを入力してください。",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("インポート中..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("確認"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "引き換えには時間がかかります。しばらくお待ちください！",
    ),
    "g_mining_key_116": m51,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "報酬は毎日蓄積され、約0.5 Nに達した時にのみNウォレットに送信されます。",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("累計報酬"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("マイニング価値"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage("タスクの詳細"),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("概要"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("活動内容"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage("マイニングされた合計価値"),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage("検証以降"),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("利益回数"),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage("検証値"),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("プランを選択"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "アンロック期間：いつでもアンロック可能",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage("年間最大報酬"),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage("報酬配布"),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("1日の上限"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("速度"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage("認証プラン"),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage("支払い方法を選択"),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("支払い方法"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("Nで支払う"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("ウォレット残高"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "この取引に必要なNが不足しています",
    ),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage("スキップしてもよろしいですか?"),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "いずれかのプランを選択するまで、認証報酬は受け取りません。",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("無効"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("報酬"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("詳細を見る"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage("認証ステータス"),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("ロックを解除するには"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("スキップ"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("過去 7 日間"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage("累計報酬"),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Nをロックして報酬認証を開始します。",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage("受け取った報酬"),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("上級者向け"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("エントリー"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("プロ"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("フルノード"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("分/日"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("アドバンスドノード"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("エントリーノード"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("プロノード"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage("1日500ブロック〜約70分"),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("ロック解除日"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage("1日100ブロック〜約15分"),
    "g_mining_key_71": m52,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage("128秒ごとにチェック"),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "テストチェーンはアップグレード中のため、一時的にブロックを検証できません。",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "4日連続でタスクを完了しないと、報酬がなくなり、ペナルティのリスクがあります。",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("リスクスコア"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("引き換え"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "まずバリデーターの公開鍵と秘密鍵のペアを保存してください。",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("エクスポート"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage("今日の検証時間"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "送金するための資金が不足しています。",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage("バリデーター一覧"),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage("バリデーターをインポート"),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage("バリデーターは既に存在します"),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("低リスク"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("中程度のリスク"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage("過去7日間の報酬"),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("高リスク"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "コントラクトを読み込み中のため、現在認証できません。しばらくお待ちください！",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage("セキュリティのヒント"),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage("バックグラウンド認証"),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "秘密鍵またはシードフレーズを安全に保管してください。",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "秘密鍵またはシードフレーズは、ウォレット資産にアクセスするための唯一の認証情報です。",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "安全な場所（紙、パスワードマネージャーなど）に保管してください。",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "スクリーンショットを撮ったり、インターネットにアップロードしたり、誰かと共有したりしないでください。",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "紛失または漏洩した場合、ウォレット資産は回復できません。",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage("確認して保存"),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage("パスワードを設定して暗号化"),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "暗号化パスワードを入力してください",
    ),
    "g_mining_key_98": m53,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "正確であることを確認するために、パスワードを再入力してください",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage("フルノード詳細"),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("ノード ID"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS 接続中"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage("WS 切断"),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage("WS 再接続中"),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("有効期限"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage("アンロック期間:"),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "いつでもアンロック可能",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage("ニュースはありません"),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage("戻る（安全）"),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "それでも続ける",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "このウェブサイトは潜在的に悪意があると識別されました。あなたの暗号資産や秘密鍵を盗もうとしている可能性があります。",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "セキュリティ警告",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "不審なURL：",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage("取引の追加"),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("平均コスト"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage("購入価格 (USD)"),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("コストベース"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("数量"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("保存"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage("未実現損益"),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("24時間変更"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage("全保有資産"),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage("資産配分"),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage("トップゲイン者"),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage("トップ下落"),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage("24時間引越し業者"),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "アセットが見つかりません",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("その他"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("合計"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("ポートフォリオ"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("合計値"),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage("結果を追加"),
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage("予測を開始"),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("作成中…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("締切"),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "有効な結果が2つ以上必要です",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage("質問を入力してください"),
    "g_pred_minutes": m54,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("いいえ"),
    "g_pred_outcome_n": m55,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("結果の選択肢"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("予測を公開"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage("予測の質問（例：今回は誰が勝つ？）"),
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage("無制限（手動で締切）"),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("はい"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage("招待コード"),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("招待済み"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("マイニングノード"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("報酬 (N)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "クラシックマイニング (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "マイニング (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage("マイニング画面"),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("共有"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("紹介"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "友達を紹介してNトークンをゲット！",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("最大"),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      "Nがもらえます（紹介した友達が認証を開始した時）！",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("紹介方法"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("リンク"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("コード"),
    "g_swap_key_14": m56,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage("コイン価格の取得エラー。"),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "続行すると、以下に同意したことになります：",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage("利用規約"),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("完了"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "スワップはまもなく配布されます。しばらくお待ちください。",
    ),
    "g_swap_key_20": m57,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "ノード運用コスト：グループ認証 1-49 N、ベーシックノード：50 N、プレミアムノード：100 N、プロノード：500 N。",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("期限切れ"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("未払い"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage("支払い確認中"),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("配布待ち"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("スワップ概要"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("新残高"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("支払い"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("日付"),
    "g_swap_key_31": m58,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "スワップは関連するチェーンエクスプローラー（Etherscan、BscScan、TRONSCAN、および当社独自のエクスプローラー）で確認できます。",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Nにスワップ"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("スワップ"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("受取"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("スワッププレビュー"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("再試行"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage("アクセントカラー"),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "デフォルトにリセットする",
    ),
    "g_token_m_key_1": m59,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "誰でもトークンを作成できます。既存のトークンの偽バージョンを作成することも可能です。インポートする前に必ずトークンを調査してください。",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("トークン"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("トークンを検索"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("チェーン名"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("チェーンシンボル"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("チェーンID"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("桁数"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage("カスタムチェーンを追加"),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0〜18の整数"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("トークンを追加"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("フォーマットエラー！"),
    "g_token_m_key_22": m60,
    "g_token_m_key_23": m61,
    "g_token_m_key_24": m62,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("トークンをインポート"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("全てのネットワーク"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("カスタムトークン"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("トークンアドレス"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("トークンシンボル"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("トークン桁数"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("インポート"),
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("注意"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("高リスク"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("安全"),
    "g_version_later": MessageLookupByLibrary.simpleMessage("後で"),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "接続が切れました。再接続してください。",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "DAppが切断されました",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage("すべて切断"),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "すべてのDAppから切断しますか？",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "このDAppから切断しますか？",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage("アクティブな接続はありません"),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "QRコードをスキャンしてDAppに接続",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "接続リクエストがタイムアウトしました",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "セッションの有効期限が切れました",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("接続中のDApp"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "リンク",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("重要なお知らせ"),
    "login_email": MessageLookupByLibrary.simpleMessage("メールアドレス"),
    "login_password": MessageLookupByLibrary.simpleMessage("パスワード"),
    "next": MessageLookupByLibrary.simpleMessage("次へ"),
    "nicknameMessage": m63,
    "personalInformation": MessageLookupByLibrary.simpleMessage("プロフィール編集"),
    "photograph": MessageLookupByLibrary.simpleMessage("撮影"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "アドレスを入力してください",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "次から表示しない",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage("後で"),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "設定に移動",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "プッシュ通知が無効になっています。チャットメッセージや送金アラートを見逃す可能性があります。\n\nシステム設定でこのアプリの通知を有効にしてください。",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "通知が無効です",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage("パスワードを再入力"),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "パスワードを選択（8〜18文字）",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage("パスワードを確認"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("アプリについて"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("セキュリティ"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("取引"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("言語"),
    "search": MessageLookupByLibrary.simpleMessage("検索"),
    "verification": MessageLookupByLibrary.simpleMessage("確認"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "シードフレーズを紛失すると、資金は永久に失われます。",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "シードフレーズを誰かに明かしたり共有すると、資金が盗まれる可能性があります。",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "シードフレーズを安全に保管するのは私の責任です。",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage("シードフレーズが正しくありません。"),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "インポートしたいウォレットのシードフレーズを入力してください。",
    ),
  };
}

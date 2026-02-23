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

  static String m1(price) => "Current price: \$${price}";

  static String m2(symbol) => "Price Alert · ${symbol}";

  static String m3(value) => "私は${value}です";

  static String m4(value) => "チャットメンバー（${value}）";

  static String m5(value) => "${value}を友達として追加してもよろしいですか";

  static String m6(email) => "Verification code sent to ${email}";

  static String m7(s) => "Resend in ${s}s";

  static String m8(value) => "既にバインド済みのため、現在再バインドできません。バインドアドレス：${value}";

  static String m9(value) => "バインド成功。バインドアドレス：${value}";

  static String m10(value) => "${value}ウォレットにN42チェーンがありません！";

  static String m11(value) => "マッチング成功。アドレス：${value}";

  static String m12(value) => "${value}より大きい金額です。";

  static String m13(value) => "ウォレットは既に存在します。ウォレット名は「${value}」です";

  static String m14(value) => "${value}以上の金額を入力してください。";

  static String m15(gas) =>
      "実行ガス(${gas})が高くなっています。呼び出したコントラクトが予想以上のガスを消費する可能性があります。";

  static String m16(gas) =>
      "最初のトランザクションにはアカウントのデプロイが含まれます（~${gas}ガス）。以降のトランザクションは安くなります。";

  static String m17(gas) =>
      "Paymasterガスオーバーヘッド(${gas})が高くなっています。ガスフリートランザクションのコストが増加する可能性があります。";

  static String m18(gas) =>
      "推定総ガス(${gas})が異常に高くなっています。トランザクションにエラーがないか確認してください。";

  static String m19(gas) =>
      "検証ガス(${gas})が高すぎる可能性があります。複雑なアカウントロジックで発生することがあります。";

  static String m20(value) => "残り${value}日";

  static String m21(value) => "行${value}のアドレスが重複しています";

  static String m22(value) => "行${value}のアドレスが無効です";

  static String m23(value) => "行${value}の金額が無効です";

  static String m24(value) => "最大${value}人の受取人";

  static String m25(value) => "+${value}ポイント/日";

  static String m26(value) => "最大${value}% APYを獲得";

  static String m27(value) => "Congratulations! You now own ${value}";

  static String m28(value) => "Please wait ${value} seconds";

  static String m29(value) => "${value}秒ごとに自動更新";

  static String m30(address) => "アカウント${address}を追加しました";

  static String m31(address, network) =>
      "このハードウェアウォレットアカウントを追跡しますか？\n\nアドレス: ${address}\nネットワーク: ${network}";

  static String m32(app) => "Current app: ${app}";

  static String m33(days) => "${days} days ago";

  static String m34(value) => "アカウントのインポートに失敗しました: ${value}";

  static String m35(date) => "Last connected: ${date}";

  static String m36(value) => "デバイスで${value}アプリを開いてください";

  static String m37(app) => "Ledgerで${app}アプリが開いていることを確認してください";

  static String m38(name) =>
      "Are you sure you want to remove \"${name}\" from saved devices?";

  static String m39(value) => "Earn ${value} points";

  static String m40(value) => "Earn ${value} points for each friend who joins!";

  static String m41(value) => "次のランクまで${value}ポイント";

  static String m42(amount, token) => "≈ ${amount}${token}";

  static String m43(amount) => "≈ ${amount} USDT";

  static String m44(value) => "連絡先${value}を削除してもよろしいですか？";

  static String m45(value) => "${value}d unbond";

  static String m46(value) => "残り${value}日";

  static String m47(value) => "${value} days remaining";

  static String m48(value) => "「${value}」が不足しています";

  static String m49(value) => "「${value}」アカウントの取得に失敗しました";

  static String m50(value) => "初回送金には最低${value} XRPが必要です";

  static String m51(value) => "${value}d ago";

  static String m52(value) => "${value}h ago";

  static String m53(value) => "${value}m ago";

  static String m54(value) => "Verification code sent to ${value}";

  static String m55(value) => "${value}チェーンが追加されていません。";

  static String m56(value) => "${value}には未完了の取引があります。後でもう一度お試しください。";

  static String m57(value) => "${value}のアドレスが見つかりません。";

  static String m58(value) => "${value}の残高が不足しています。";

  static String m59(value, value1) =>
      "すべてのXRPアカウントはベースラインとして${value} XRP（${value1}ドロップ）を準備金として確保する必要があり、これは使用できません。";

  static String m60(value, value1) =>
      "アカウントが所有するオブジェクトごとに、${value} XRP（${value1}ドロップ）が準備金に追加されます。";

  static String m61(value, value1) =>
      "このアカウントは${value}個のオブジェクトを所有しているため、追加で${value1} XRPが準備金として確保されています。";

  static String m62(value) => "パターンパスワードの入力エラー、あと${value}回試行できます";

  static String m63(value) => "パターンパスワードの入力エラー、あと${value}回試行できます";

  static String m64(value) => "${value}のセットアップに成功しました。N42Walletで認証を開始します！";

  static String m65(value) =>
      "@N42Walletで私の${value}グループに参加して、Layer 1チェーンの初期マイナーになり、スマホで暗号資産を獲得しよう！";

  static String m66(value, value1) =>
      "ノードを実行するために${value1}まで${value} Nをロックしてもよろしいですか？";

  static String m67(value) => "インポートに失敗しました：${value}";

  static String m68(value) => "報酬を得るには、最低${value}のステーキング残高が必要です。";

  static String m69(value, value1) => "${value1}ブロックマイニングごとに${value} N";

  static String m70(value) => "${value}文字である必要があります";

  static String m71(value) => "${value}の残高が不足しています。";

  static String m72(value) => "${value}を受取中...";

  static String m73(value) =>
      "アプリ内でスワップされた${value}はまもなくウォレットに配布され、このプロセスでは売却できません。ノードの運用に使用できます。";

  static String m74(value) => "最大${value}文字";

  static String m75(value) => "${value}チェーンは既にアプリでサポートされています！";

  static String m76(value) => "${value}チェーンは既にアプリでサポートされています。追加しますか？";

  static String m77(value) => "${value}アドレスのテストリンクに失敗しました！";

  static String m78(value) => "アプリケーションは${value}秒後にロック解除されます。";

  static String m79(value) => "パターンパスワードの入力エラー、あと${value}回試行できます";

  static String m80(value) => "パスワードの入力エラー、あと${value}回試行できます";

  static String m81(value) => "パスワードの入力エラー、あと${value}回試行できます";

  static String m82(value) => "${value}パスワードを入力";

  static String m83(value) => "0〜${value}文字";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("新規登録"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage("アカウントを作成"),
    "Edit": MessageLookupByLibrary.simpleMessage("編集"),
    "Verification": MessageLookupByLibrary.simpleMessage("確認"),
    "address_Information": MessageLookupByLibrary.simpleMessage("アドレス情報"),
    "code_403": MessageLookupByLibrary.simpleMessage("アカウントが1日間一時的にロックされました"),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "コードが正しくありません。もう一度お試しください。",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("コピーしました"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("アドレスをコピー"),
    "descO": MessageLookupByLibrary.simpleMessage("説明（任意）"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "パスワードを変更",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("了解"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage("新しいデバイスでログイン"),
    "editPhoto": MessageLookupByLibrary.simpleMessage("写真を編集"),
    "email_code_error": MessageLookupByLibrary.simpleMessage("認証コードの取得に失敗しました"),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "認証コードが正常に送信されました。メールを確認してください",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage("認証コードエラー"),
    "email_error": MessageLookupByLibrary.simpleMessage("無効なメールアドレス"),
    "email_verification": MessageLookupByLibrary.simpleMessage("メールアドレス認証"),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "メールアドレス認証アプリは、出金とN42Walletアカウントを保護します。",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "メール認証を追加しますか？",
    ),
    "file": MessageLookupByLibrary.simpleMessage("ファイル"),
    "g_2fa_backup_hint": MessageLookupByLibrary.simpleMessage(
      "このキーを保存してください — スマートフォンを紛失した場合に必要です。",
    ),
    "g_2fa_backup_share": MessageLookupByLibrary.simpleMessage("共有"),
    "g_2fa_backup_share_text": MessageLookupByLibrary.simpleMessage(
      "N42ウォレット Google Authenticator バックアップキー",
    ),
    "g_2fa_disable_confirm_hint": MessageLookupByLibrary.simpleMessage(
      "Google Authenticatorの6桁のコードを入力して2FAを無効にしてください。",
    ),
    "g_2fa_disable_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Google 2FAを無効化",
    ),
    "g_2fa_disable_error": MessageLookupByLibrary.simpleMessage(
      "Google 2FAの無効化に失敗しました。コードを確認して再試行してください。",
    ),
    "g_2fa_disable_success": MessageLookupByLibrary.simpleMessage(
      "Google 2FAが無効になりました",
    ),
    "g_2fa_invalid_format": MessageLookupByLibrary.simpleMessage(
      "有効な6桁のコードを入力してください",
    ),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Goes Above ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Drops Below ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Alert me when price",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage("Enable this alert"),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid price greater than 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("Set Alert"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Target price (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage("Update Alert"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "トークンは同じネットワーク内でのみ送信できます。他のネットワークから送信すると、損失が発生する可能性があります。",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage("スキャンして受取"),
    "g_biometric_locked_out": MessageLookupByLibrary.simpleMessage(
      "試行回数超過。生体認証がロックされました。パスコードをお使いください。",
    ),
    "g_biometric_not_enrolled": MessageLookupByLibrary.simpleMessage(
      "生体認証が設定されていません。設定から有効にしてください。",
    ),
    "g_biometric_retry": MessageLookupByLibrary.simpleMessage(
      "Face ID / Touch IDを使う",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage("URLを入力してください"),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("説明を入力"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("ブラウザ"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage("ブラウザキャッシュをクリア"),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage("DAppに自動接続"),
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "DAppへの接続を確認してください",
    ),
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
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
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
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage("グループチャットを開始"),
    "g_chat_key_10": m3,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("友達を招待"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("連絡先を選択"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("完了"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "少なくとも2人の連絡先を選択してください",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("友達詳細"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("グループ詳細"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage("グループメンバーをもっと見る"),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("グループ名"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("新しい友達"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage("本当に解散しますか？"),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "このグループを退出してもよろしいですか？",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("グループ解散"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("グループを退出"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage("グループチャット名を変更"),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "グループチャット名を変更すると、グループ内の他のメンバーに通知されます。",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("完了"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage("友達追加リクエスト"),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage("友達として追加リクエスト"),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage("友達リクエストが承認されました"),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("追加済み"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage("友達として追加されました"),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("同意"),
    "g_chat_key_32": m4,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "パスワードを正しく解析できず、一時的にメッセージを送信できません。グループに入る時にウォレットをインポートしてください",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage("チャット履歴を削除しますか？"),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("メンバーを削除"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("マイQRコード"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("期限切れ"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("報告"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("新規チャット"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("新規グループ"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("QRコード"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage("報告してブロック"),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "このメッセージはN42Walletに転送されます。この連絡先には通知されません。",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("動画"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("写真"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("メッセージを削除"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage("このデバイスから削除"),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("待機中"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("同意"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage("報告理由"),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage("報告理由を入力してください"),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "報告を確認し、24時間以内に返信します。",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage("報告しました - クリックして確認"),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("ブラックリスト"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("削除"),
    "g_chat_key_6": m5,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage("まだ連絡先がありません"),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("今日"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage("3日以上前"),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("ブロック"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "こんにちは、N42Walletでチャットや送金をしています。ウォレットをインストールして私にメッセージを送ってください：",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("返信"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage("メッセージは削除されました"),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage("誰かがあなたをメンションしました"),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("挨拶する"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("友達を追加"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage("申請理由"),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("取引"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("接続"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("利用可能なネットワーク"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("メッセージ署名"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("接続中"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage("ペアリング中、お待ちください。"),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("切断"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("拒否"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage("Blocked"),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("Caution"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Safe"),
    "g_dapp_security_title": MessageLookupByLibrary.simpleMessage(
      "DApp Security",
    ),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Verified",
    ),
    "g_email_also_sync": MessageLookupByLibrary.simpleMessage(
      "Also sync Chat account email",
    ),
    "g_email_back_to_email": MessageLookupByLibrary.simpleMessage(
      "← Change email address",
    ),
    "g_email_both_success": MessageLookupByLibrary.simpleMessage(
      "Both accounts updated successfully!",
    ),
    "g_email_change_title": MessageLookupByLibrary.simpleMessage(
      "Change Email",
    ),
    "g_email_chat_code_hint": MessageLookupByLibrary.simpleMessage(
      "Enter 6-digit Chat code",
    ),
    "g_email_chat_code_sent_to": MessageLookupByLibrary.simpleMessage(
      "Chat code sent to",
    ),
    "g_email_chat_confirm": MessageLookupByLibrary.simpleMessage(
      "Confirm Chat Sync",
    ),
    "g_email_chat_send_fail": MessageLookupByLibrary.simpleMessage(
      "Failed to send Chat code",
    ),
    "g_email_chat_sending": MessageLookupByLibrary.simpleMessage(
      "Sending Chat verification code...",
    ),
    "g_email_chat_sync_title": MessageLookupByLibrary.simpleMessage(
      "Sync Chat Account Email",
    ),
    "g_email_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Please enter the 6-digit code",
    ),
    "g_email_code_resent": MessageLookupByLibrary.simpleMessage("Code resent"),
    "g_email_code_sent_to": m6,
    "g_email_code_wrong": MessageLookupByLibrary.simpleMessage(
      "Incorrect code, please try again",
    ),
    "g_email_confirm_change": MessageLookupByLibrary.simpleMessage(
      "Confirm Change",
    ),
    "g_email_confirm_continue": MessageLookupByLibrary.simpleMessage(
      "Confirm & Continue to Chat Sync",
    ),
    "g_email_current_label": MessageLookupByLibrary.simpleMessage(
      "Current email",
    ),
    "g_email_enter_code": MessageLookupByLibrary.simpleMessage(
      "Enter 6-digit code",
    ),
    "g_email_error_empty": MessageLookupByLibrary.simpleMessage(
      "Please enter a new email address",
    ),
    "g_email_error_invalid": MessageLookupByLibrary.simpleMessage(
      "Invalid email address",
    ),
    "g_email_error_same": MessageLookupByLibrary.simpleMessage(
      "New email must differ from current email",
    ),
    "g_email_n42_only": MessageLookupByLibrary.simpleMessage(
      "N42 email updated. Chat email can be updated in Chat > Settings.",
    ),
    "g_email_n42_updated": MessageLookupByLibrary.simpleMessage(
      "N42 account email updated",
    ),
    "g_email_new_hint": MessageLookupByLibrary.simpleMessage(
      "Enter new email address",
    ),
    "g_email_new_label": MessageLookupByLibrary.simpleMessage(
      "New email address",
    ),
    "g_email_pwd_hint": MessageLookupByLibrary.simpleMessage("Enter password"),
    "g_email_pwd_label": MessageLookupByLibrary.simpleMessage(
      "Current password (for Chat)",
    ),
    "g_email_pwd_required": MessageLookupByLibrary.simpleMessage(
      "Password required for Chat sync",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("Resend code"),
    "g_email_resend_countdown": m7,
    "g_email_send_code": MessageLookupByLibrary.simpleMessage(
      "Send Verification Code",
    ),
    "g_email_skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "g_email_skip_full": MessageLookupByLibrary.simpleMessage(
      "Skip – N42 email is already updated",
    ),
    "g_email_success": MessageLookupByLibrary.simpleMessage(
      "Email updated successfully",
    ),
    "g_face_1": MessageLookupByLibrary.simpleMessage("生体認証スキャンのヒント"),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "認証のために指紋または顔をスキャンしてください。",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage("生体認証スキャンが機能しませんでした"),
    "g_face_3": MessageLookupByLibrary.simpleMessage("ヒント"),
    "g_face_4": MessageLookupByLibrary.simpleMessage("生体認証スキャン成功"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("設定する"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "生体認証ログインが設定されていません。システム設定で設定してください。",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "続行するには顔または指紋をスキャンしてください。",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("戻る"),
    "g_face_9": MessageLookupByLibrary.simpleMessage("生体認証を再度有効にすることをお勧めします。"),
    "g_face_liveness_failed": MessageLookupByLibrary.simpleMessage(
      "顔が検出されませんでした。カメラを正面から見て、もう一度お試しください。",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage("顔認証方法"),
    "g_face_match_key10": m8,
    "g_face_match_key11": m9,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage("再バインド"),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("バインド"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("確認"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "顔データをウォレットアドレスに直接バインドできます（以前にバインドしたことがある場合、古いウォレットアドレスは上書きされます）。以前にウォレットアドレスをバインドしたことがある場合は、手動で確認してバインドされたウォレットアドレスを取得することもできます。",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "顔データにリンクされたウォレットアドレスが検出されましたが、このウォレットはまだウォレット一覧にインポートされていません。",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "このウォレットと顔データがリンクされています。",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage("ユーザー通知"),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage("顔バインディングとは？"),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "顔バインディングは、顔認識技術を利用して、生体顔特徴とブロックチェーンウォレットアドレスをマッチングさせます。",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "このプロセスにより、取引の利便性が向上するだけでなく、アカウントのセキュリティが強化され、すべてのアクションがあなたによって承認されていることが保証されます。",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "なぜ顔バインディングが必要なのですか？",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "顔データをバインドすることで、あなたの身元が取引活動に直接リンクされ、本人確認プロセスが簡素化され、操作効率が向上します。この技術により、資産の転送やコントラクトとのやり取りなどの機密操作を行う際に、迅速かつ安全な本人確認が保証されます。",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "私の顔データはどのように保存され、安全ですか？",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "顔データは暗号化された形式でパブリックブロックチェーンに保存され、中央集権型データベースには保存されません。これにより、あなたの承認がある場合にのみシステムがデータを復号して本人確認に使用でき、プライバシーとデータセキュリティが確保されます。",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "顔バインディングはアカウントセキュリティにどのように影響しますか？",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "顔バインディングにより、すべての機密アクションがあなたの明示的な承認がある場合にのみ実行されることが保証され、アカウントセキュリティが強化されます。業界最高レベルの暗号化技術を使用して生体データを保護し、不正アクセスを防止します。",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage("私の顔データは安全ですか？"),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "はい。すべての生体データは厳格な暗号化が施され、データ転送と保存には最高のセキュリティ基準が適用されます。システムは、本人確認を完了するために必要な場合にのみこのデータを復号します。",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage("マッチングに失敗しました！"),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("了解しました"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage("ウォレットアドレスを選択"),
    "g_face_match_key32": m10,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("バインド解除"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "顔データの確認に失敗しました！",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "顔データのバインド解除に失敗しました！",
    ),
    "g_face_match_key4": m11,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage("アドレスエラー！"),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage("顔データバインディング"),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage("顔認証マッチング"),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("再選択"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("マッチング"),
    "g_face_network_error": MessageLookupByLibrary.simpleMessage(
      "ネットワークエラーです。接続を確認してもう一度お試しください。",
    ),
    "g_face_sdk_init_failed": MessageLookupByLibrary.simpleMessage(
      "顔認証を開始できませんでした。もう一度お試しください。",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("プロフィール"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("ニュース"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("認証"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("メッセージ"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("学習"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("友達を招待"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("削除に失敗しました！"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("送信"),
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
    "g_key_135": m12,
    "g_key_14": MessageLookupByLibrary.simpleMessage("メインウォレット"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("取引が成功しました"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("パスワードが正しくありません"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("テストネット"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("メインネット"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("システム言語"),
    "g_key_15": MessageLookupByLibrary.simpleMessage("メインウォレットに設定"),
    "g_key_154": MessageLookupByLibrary.simpleMessage("送信"),
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
    "g_key_205": MessageLookupByLibrary.simpleMessage("フォトアルバムへのアクセス許可がありません。"),
    "g_key_206": MessageLookupByLibrary.simpleMessage("パスワード変更"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("現在のパスワード"),
    "g_key_208": MessageLookupByLibrary.simpleMessage("残高を同期中..."),
    "g_key_209": MessageLookupByLibrary.simpleMessage("秘密鍵"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("ウォレットパスワードを入力"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("秘密鍵エラー"),
    "g_key_211": MessageLookupByLibrary.simpleMessage("購入"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("売却"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("市場情報"),
    "g_key_214": m13,
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
    "g_key_46": m14,
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
    "g_key_8": MessageLookupByLibrary.simpleMessage("備考"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("シードフレーズ"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("全てのトークン"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("設定"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Account Created Successfully",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Account Details",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Account Name",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter account name",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Account Type",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Active"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Add your first operation",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Add Operation",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "アドレスを計算中...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "アドレスの計算に失敗しました。もう一度お試しください。",
    ),
    "g_key_aa_address_preview": MessageLookupByLibrary.simpleMessage(
      "This address is pre-computed and will be deployed when you make your first transaction.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Approve"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Batch"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Atomic Execution",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Execute multiple operations at once",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Send multiple transactions in a single operation",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Batch execution failed",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "No saved templates",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Batch Operations",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage("Save Gas"),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Save as Template",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Submitting...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Batch submitted successfully",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Load Template",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Template Name",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter template name",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Template saved",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage(
      "Templates",
    ),
    "g_key_aa_batch_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Batch Transaction",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Approve and swap in one transaction — no more two-step confirmations",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "One-Click Batch Actions",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Sponsor transactions or pay fees with ERC-20 tokens instead of ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Pay Gas with Any Token",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Recover access via trusted contacts if you lose your private key",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Social Recovery",
    ),
    "g_key_aa_biconomy_account": MessageLookupByLibrary.simpleMessage(
      "Biconomyアカウント",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "ガスレストランザクションをサポートするモジュラーERC-7579スマートアカウント",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("by"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Chain"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("Chain ID"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Change"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Check Status",
    ),
    "g_key_aa_clear_all": MessageLookupByLibrary.simpleMessage("Clear All"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
    "g_key_aa_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_aa_contract": MessageLookupByLibrary.simpleMessage("Contract"),
    "g_key_aa_counterfactual_address": MessageLookupByLibrary.simpleMessage(
      "Counterfactual Address",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "This is a counterfactual address. It will be deployed on your first transaction.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Create Smart Account",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Create your first smart account",
    ),
    "g_key_aa_create_first_account": MessageLookupByLibrary.simpleMessage(
      "Create a smart account to get started",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Create Session Key",
    ),
    "g_key_aa_create_session_desc": MessageLookupByLibrary.simpleMessage(
      "Session keys allow DApps to execute transactions on your behalf with limited permissions and time constraints.",
    ),
    "g_key_aa_create_smart_account": MessageLookupByLibrary.simpleMessage(
      "Create Smart Account",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Created"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "g_key_aa_deploy": MessageLookupByLibrary.simpleMessage("Deploy"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Account will be deployed automatically on your first transaction",
    ),
    "g_key_aa_deploy_failed": MessageLookupByLibrary.simpleMessage(
      "Deploy Failed",
    ),
    "g_key_aa_deploy_failed_desc": MessageLookupByLibrary.simpleMessage(
      "Deployment failed. Please try again.",
    ),
    "g_key_aa_deploy_started": MessageLookupByLibrary.simpleMessage(
      "Deployment started",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Deployed"),
    "g_key_aa_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Account is ready to use",
    ),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("Deploying..."),
    "g_key_aa_deploying_desc": MessageLookupByLibrary.simpleMessage(
      "Deployment transaction is being processed",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Deployment will occur automatically with your first transaction.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Experience the next generation of Ethereum accounts with enhanced features",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Details"),
    "g_key_aa_eip7702_account": MessageLookupByLibrary.simpleMessage(
      "EIP-7702 Account",
    ),
    "g_key_aa_eip7702_badge": MessageLookupByLibrary.simpleMessage("EIP-7702"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Hybrid EOA/Smart Account - No deployment needed",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Error"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Estimated Gas",
    ),
    "g_key_aa_estimating": MessageLookupByLibrary.simpleMessage(
      "Estimating...",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Execute Batch",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Factory"),
    "g_key_aa_feature_batch": MessageLookupByLibrary.simpleMessage(
      "Batch multiple transactions",
    ),
    "g_key_aa_feature_gas": MessageLookupByLibrary.simpleMessage(
      "Pay gas in any token",
    ),
    "g_key_aa_feature_security": MessageLookupByLibrary.simpleMessage(
      "Enhanced security",
    ),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("FREE"),
    "g_key_aa_full_access": MessageLookupByLibrary.simpleMessage("Full Access"),
    "g_key_aa_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Gas Estimate",
    ),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Gas estimate failed, using default",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("Gas Payment"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Gas Payment Options",
    ),
    "g_key_aa_gas_savings": MessageLookupByLibrary.simpleMessage("Gas Savings"),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gas Sponsored",
    ),
    "g_key_aa_gas_warn_call_high": MessageLookupByLibrary.simpleMessage(
      "実行ガスが高い",
    ),
    "g_key_aa_gas_warn_call_high_desc": m15,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "デプロイメントガスオーバーヘッド",
    ),
    "g_key_aa_gas_warn_deploy_desc": m16,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Paymasterオーバーヘッドが高い",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m17,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "ガスリミットが非常に高い",
    ),
    "g_key_aa_gas_warn_total_high_desc": m18,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "ガスの過小評価の可能性",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "実際に使用されるガスが推定値を超える可能性があります。より大きなバッファを追加することをご検討ください。",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "検証ガスが高い",
    ),
    "g_key_aa_gas_warn_verify_high_desc": m19,
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Gasless"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Gasless transactions & batch operations",
    ),
    "g_key_aa_home_title": MessageLookupByLibrary.simpleMessage(
      "Account Abstraction",
    ),
    "g_key_aa_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_aa_kernel_account": MessageLookupByLibrary.simpleMessage(
      "Kernel Account",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Modular account with plugin support from ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Label"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Last Activity",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "My Smart Accounts",
    ),
    "g_key_aa_never": MessageLookupByLibrary.simpleMessage("Never"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "No smart accounts yet",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "No accounts match your filter",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "No operations added",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "No session keys",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Not Deployed",
    ),
    "g_key_aa_not_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Account will be deployed on first transaction",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Create smart account (free, no ETH needed)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Fund it — receive any EVM token",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Transact gaslessly with Paymaster",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operations"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Pay gas with token",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Pay gas with your ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Pay with"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Pay with ETH",
    ),
    "g_key_aa_paymaster_balance": MessageLookupByLibrary.simpleMessage("残高"),
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
      "Choose how you want to pay for transaction gas fees",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "推定コスト",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "ガスオプションの読み込み失敗",
    ),
    "g_key_aa_paymaster_not_supported": MessageLookupByLibrary.simpleMessage(
      "このチェーンでは利用不可",
    ),
    "g_key_aa_paymaster_quote_expired": MessageLookupByLibrary.simpleMessage(
      "見積もり期限切れ",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage("再試行"),
    "g_key_aa_paymaster_sponsored_unavailable":
        MessageLookupByLibrary.simpleMessage("スポンサーシップ利用不可"),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Permission"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Preview Address",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Ready"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Receive Address",
    ),
    "g_key_aa_recommended": MessageLookupByLibrary.simpleMessage("Recommended"),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Revoke"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to revoke this session key? The authorized DApp will no longer be able to execute transactions.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Revoke Session Key",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Session key revoked",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Revoked"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Revoking session key...",
    ),
    "g_key_aa_safe_account": MessageLookupByLibrary.simpleMessage(
      "Safe Account",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Multi-signature account with advanced security features",
    ),
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage("ガーディアン"),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage("しきい値"),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("saved"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Select Chain",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Select Paymaster",
    ),
    "g_key_aa_select_type": MessageLookupByLibrary.simpleMessage(
      "Select Account Type",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Send tokens using your smart account",
    ),
    "g_key_aa_send_title": MessageLookupByLibrary.simpleMessage("AA Transfer"),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1日"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1時間"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30日間"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7日間"),
    "g_key_aa_session_allowed": MessageLookupByLibrary.simpleMessage("許可"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "例：100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "最大金額",
    ),
    "g_key_aa_session_blocked": MessageLookupByLibrary.simpleMessage("ブロック"),
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
      "Session Key Details",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage("有効期間"),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "高リスク — 信頼できるDAppのみ",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Session Keys",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Authorize DApps with temporary access to your smart account",
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
    "g_key_aa_simple_account": MessageLookupByLibrary.simpleMessage(
      "Simple Account",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Basic smart account with single owner - recommended for most users",
    ),
    "g_key_aa_smart_account": MessageLookupByLibrary.simpleMessage(
      "Smart Account",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Smart Accounts",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Smart Wallet",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Spending Limit",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsored (Free)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("Smart Account"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Total Gas"),
    "g_key_aa_total_value": MessageLookupByLibrary.simpleMessage("Total Value"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage(
      "Transactions",
    ),
    "g_key_aa_unavailable": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "g_key_aa_version_v07": MessageLookupByLibrary.simpleMessage("v0.7"),
    "g_key_aa_version_v08": MessageLookupByLibrary.simpleMessage("v0.8"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "g_key_account_linked": MessageLookupByLibrary.simpleMessage(
      "Account linked successfully",
    ),
    "g_key_account_unlinked": MessageLookupByLibrary.simpleMessage(
      "Account unlinked successfully",
    ),
    "g_key_address": MessageLookupByLibrary.simpleMessage("アドレス"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage("名前を入力してください"),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage("アドレスを入力してください"),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage("コインタイプを選択してください"),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("アドレスを編集"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage("削除に成功しました"),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("コインを選択"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("コインを検索"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Advanced Features",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("進行中"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "資格確認",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("請求"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("請求済み"),
    "g_key_airdrop_days_left": m20,
    "g_key_airdrop_deadline": MessageLookupByLibrary.simpleMessage("締切"),
    "g_key_airdrop_eligible": MessageLookupByLibrary.simpleMessage("対象"),
    "g_key_airdrop_estimated_value": MessageLookupByLibrary.simpleMessage(
      "推定価値",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("期限切れ"),
    "g_key_airdrop_filter": MessageLookupByLibrary.simpleMessage("フィルター"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "利用可能なエアドロップなし",
    ),
    "g_key_airdrop_not_eligible": MessageLookupByLibrary.simpleMessage("対象外"),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("保留中"),
    "g_key_airdrop_priority_high": MessageLookupByLibrary.simpleMessage("高優先度"),
    "g_key_airdrop_priority_low": MessageLookupByLibrary.simpleMessage("低優先度"),
    "g_key_airdrop_priority_medium": MessageLookupByLibrary.simpleMessage(
      "中優先度",
    ),
    "g_key_airdrop_requirement_met": MessageLookupByLibrary.simpleMessage(
      "条件達成",
    ),
    "g_key_airdrop_requirement_not_met": MessageLookupByLibrary.simpleMessage(
      "未達成",
    ),
    "g_key_airdrop_requirements": MessageLookupByLibrary.simpleMessage("条件"),
    "g_key_airdrop_sort_by": MessageLookupByLibrary.simpleMessage("並び替え"),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage("エアドロップ追跡"),
    "g_key_airdrop_total_claimed": MessageLookupByLibrary.simpleMessage("請求総額"),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("近日開始"),
    "g_key_apple_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Apple sign-in cancelled",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage("受取人追加"),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Broadcasting...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage("全クリア"),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm Batch Transfer",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "CSV形式: アドレス,金額,ラベル",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_batch_duplicate_address": m21,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimating Gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "一括転送はEVMチェーンのみをサポート",
    ),
    "g_key_batch_execute": MessageLookupByLibrary.simpleMessage("一括実行"),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage("CSVエクスポート"),
    "g_key_batch_gas_savings": MessageLookupByLibrary.simpleMessage("ガス節約額"),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer Help",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage("CSVインポート"),
    "g_key_batch_invalid_address": m22,
    "g_key_batch_invalid_amount": m23,
    "g_key_batch_max_recipients": m24,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Memo is optional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Use Multicall3 for lower gas fees",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "サポートされているトークンがありません",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage("受取人"),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage("トークンを選択"),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "1つのトランザクションで複数のアドレスにトークンを送信",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("Signing..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Swipe left to remove a recipient",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage("一括送金"),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage("合計金額"),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("金額"),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("最安"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "受取予定額",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("最速"),
    "g_key_bridge_fee": MessageLookupByLibrary.simpleMessage("ブリッジ手数料"),
    "g_key_bridge_from_chain": MessageLookupByLibrary.simpleMessage("送信元チェーン"),
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
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage("トークン選択"),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("スリッページ"),
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("ブリッジ"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage("予想時間"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("ブリッジ"),
    "g_key_bridge_to_chain": MessageLookupByLibrary.simpleMessage("送信先チェーン"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage("ブリッジ失敗"),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "トランザクション処理中",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage("ブリッジ成功"),
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
    "g_key_burn_nft_title": MessageLookupByLibrary.simpleMessage("NFTを焼却"),
    "g_key_change_email": MessageLookupByLibrary.simpleMessage("Change Email"),
    "g_key_change_password": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "g_key_change_password_desc": MessageLookupByLibrary.simpleMessage(
      "Enter your current password and set a new password",
    ),
    "g_key_code_length": MessageLookupByLibrary.simpleMessage(
      "Please enter 6-digit code",
    ),
    "g_key_code_required": MessageLookupByLibrary.simpleMessage(
      "Verification code is required",
    ),
    "g_key_code_sent": MessageLookupByLibrary.simpleMessage(
      "Verification code sent",
    ),
    "g_key_confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "g_key_continue_with_apple": MessageLookupByLibrary.simpleMessage(
      "Continue with Apple",
    ),
    "g_key_continue_with_google": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "g_key_deadline_reminders": MessageLookupByLibrary.simpleMessage(
      "Deadline reminders",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage("正確な金額"),
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage("無制限"),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "無制限承認：ルーターはいつでもこのトークンを使用できます。標準的な方法ですが、コントラクトが侵害された場合はリスクがあります。",
    ),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage("最適ルート"),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage("最適ソース"),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("チェーン"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage("スワップを確認"),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage("ガス見積もり"),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage("DEX 履歴"),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("トークンなし"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "トークンが見つかりません",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage("価格チャート"),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage("価格インパクト"),
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage("見積もり失敗"),
    "g_key_dex_quote_refreshed": MessageLookupByLibrary.simpleMessage(
      "見積もりが更新されました",
    ),
    "g_key_dex_retry": MessageLookupByLibrary.simpleMessage("再試行"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "シンボル / 名前 / アドレスで検索",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("選択"),
    "g_key_dex_slippage": MessageLookupByLibrary.simpleMessage("スリッページ許容値"),
    "g_key_dex_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana DEX スワップはアプリ内でまだサポートされていません",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage("確認済み"),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("失敗"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage("保留中"),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("見積もり済み"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("スワップ"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "スワップを送信しました",
    ),
    "g_key_dex_tx_failed": MessageLookupByLibrary.simpleMessage("トランザクション失敗"),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("支払い"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage("受取り"),
    "g_key_domain_resolve_hint": MessageLookupByLibrary.simpleMessage(
      "ENS (.eth)・Unstoppable Domains (.crypto/.wallet/…)・Solana SNS (.sol) に対応",
    ),
    "g_key_domain_sns_name": MessageLookupByLibrary.simpleMessage(
      "Solana ネームサービス",
    ),
    "g_key_domain_sns_not_found": MessageLookupByLibrary.simpleMessage(
      "Solanaドメインが見つかりません",
    ),
    "g_key_domain_ud_name": MessageLookupByLibrary.simpleMessage(
      "Unstoppable Domains",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Unstoppableドメインが見つからないか、このチェーンのアドレスがありません",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "アクティブな製品",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage("バッチ転送"),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("バーン"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Nを購入"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "ASTプロトコルでNを購入",
    ),
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage("無料トークンを獲得"),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage("クロスチェーン転送"),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "毎日のチェックインボーナス",
    ),
    "g_key_earn_dex_desc": MessageLookupByLibrary.simpleMessage(
      "Uniswap / 1inchを通じて任意のトークンをスワップ",
    ),
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
    "g_key_earn_node_mining": MessageLookupByLibrary.simpleMessage("ノードマイニング"),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "ノードマイニングに参加して報酬を獲得",
    ),
    "g_key_earn_points_daily": MessageLookupByLibrary.simpleMessage(
      "毎日ポイントを獲得",
    ),
    "g_key_earn_pts_day": m25,
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
    "g_key_earn_up_to_apy": m26,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("すべて表示"),
    "g_key_eligibility_alerts": MessageLookupByLibrary.simpleMessage(
      "Eligibility alerts",
    ),
    "g_key_eligible_only": MessageLookupByLibrary.simpleMessage(
      "Eligible only",
    ),
    "g_key_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "g_key_email_required": MessageLookupByLibrary.simpleMessage(
      "Email is required",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Resolved address updated",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("Annual Fee"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Base Price"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Checking availability...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Commit"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Commit failed",
    ),
    "g_key_ens_commit_tx": MessageLookupByLibrary.simpleMessage(
      "Committing transaction...",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "登録コミットメントの有効期限が切れました。登録プロセスをやり直してください。",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Committing...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Confirm Renewal",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage("確認して送信"),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage("ENS解決の確認"),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "アドレスをコピーしました",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Current Expiry",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("days left"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Register and manage your .eth domain names",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage("ENS名を検出しました"),
    "g_key_ens_duration": MessageLookupByLibrary.simpleMessage(
      "Registration Period",
    ),
    "g_key_ens_edit_records": MessageLookupByLibrary.simpleMessage(
      "Edit Records",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "g_key_ens_expiring_soon": MessageLookupByLibrary.simpleMessage(
      "Expiring Soon",
    ),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Extend Registration Period",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Finalizing registration",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Get started with ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Get your .eth name",
    ),
    "g_key_ens_home_title": MessageLookupByLibrary.simpleMessage("ENS Manager"),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Invalid address (must be 0x + 40 hex chars)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage("無効なENS名"),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("is now yours!"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Please keep the app open during registration",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Manage your Web3 identity",
    ),
    "g_key_ens_management_title": MessageLookupByLibrary.simpleMessage(
      "Manage ENS",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Minimum 3 characters",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("My Domains"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("ENS名"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage("New Expiry"),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "New Owner Address",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "No domains yet",
    ),
    "g_key_ens_no_names": MessageLookupByLibrary.simpleMessage(
      "You don\'t own any ENS names yet",
    ),
    "g_key_ens_owned_names": MessageLookupByLibrary.simpleMessage(
      "My ENS Names",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Please wait",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Premium Name",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Price Breakdown",
    ),
    "g_key_ens_price_per_year": MessageLookupByLibrary.simpleMessage(
      "per year",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Primary"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Primary name set successfully",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Processing...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Register ENS",
    ),
    "g_key_ens_records": MessageLookupByLibrary.simpleMessage("Records"),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("Register"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Your decentralized identity on Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Registration failed",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Register Now",
    ),
    "g_key_ens_register_tx": MessageLookupByLibrary.simpleMessage(
      "Registering name...",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Registering...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Registration Info",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Registration Period",
    ),
    "g_key_ens_reminder_disabled": MessageLookupByLibrary.simpleMessage(
      "リマインダーが無効です",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "期限リマインダーを有効にする",
    ),
    "g_key_ens_reminder_enabled": MessageLookupByLibrary.simpleMessage(
      "リマインダーが有効です",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "期限の 30 日、7 日、1 日前に通知",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Renew"),
    "g_key_ens_renew_cost": MessageLookupByLibrary.simpleMessage(
      "Renewal Cost",
    ),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Extend your domain registration",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Renewal successful",
    ),
    "g_key_ens_renew_title": MessageLookupByLibrary.simpleMessage("Renew ENS"),
    "g_key_ens_resolution_failed": MessageLookupByLibrary.simpleMessage(
      "ENS解決に失敗しました",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "解決されたアドレス",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage("ENSを解決中..."),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Search"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Find available .eth names",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search for a .eth name",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Enter an ENS name to search",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Search & Register",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "Search ENS",
    ),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "自分のアドレスには送信できません",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Ethereum Name Service",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Set as Primary",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Standard Name",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Start Registration",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Step 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Step 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Step 3"),
    "g_key_ens_step_commit": MessageLookupByLibrary.simpleMessage("Commit"),
    "g_key_ens_step_register": MessageLookupByLibrary.simpleMessage("Register"),
    "g_key_ens_step_success": MessageLookupByLibrary.simpleMessage("Success"),
    "g_key_ens_step_wait": MessageLookupByLibrary.simpleMessage("Wait"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Create Subdomain",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Subdomain created",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Delete Subdomain",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "This subdomain will be permanently deleted.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Subdomain deleted",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "No subdomains yet",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Use letters, numbers and hyphens only",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Subdomain label",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "e.g. blog, mail, app",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Owner address",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Leave empty to use current wallet",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Subdomains"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Success!"),
    "g_key_ens_success_message": m27,
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Suggestions",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Text Records",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ENS Manager"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_ens_total_cost": MessageLookupByLibrary.simpleMessage("Total Cost"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Transfer ownership to another address",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Transfer successful",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Transfer is irreversible. Make sure the new owner address is correct.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Try another name",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "ENS registration is a two-step process",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Unavailable",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Wait"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Waiting period prevents front-running attacks",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "A waiting period prevents front-running",
    ),
    "g_key_ens_wait_timer": m28,
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Waiting..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "続行する前に解決されたアドレスを確認してください。ENS名は所有者によって転送または変更される可能性があります。",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("year"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("years"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Your Identity",
    ),
    "g_key_enter_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Re-enter new password",
    ),
    "g_key_enter_email": MessageLookupByLibrary.simpleMessage(
      "Enter your email address",
    ),
    "g_key_enter_new_password": MessageLookupByLibrary.simpleMessage(
      "Enter new password",
    ),
    "g_key_enter_old_password": MessageLookupByLibrary.simpleMessage(
      "Enter current password",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage("レスポンスデータの解析エラー！"),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("通信エラー"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage("リクエスト構文エラー"),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "認証されていません。ログインしてください",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("アクセスが拒否されました"),
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "アカウントまたはパスワードが正しくありません",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("リクエストエラー"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "別のデバイスで既にログインしているため、強制的にログアウトされました。",
    ),
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
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("フィードバック"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "フィードバック情報を入力してください",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "未アップロードの添付ファイルがあります",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage("送信に失敗しました"),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage("送信に成功しました"),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("添付ファイル"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "最大5つの添付ファイル、各添付ファイルは100MB以下",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("失敗"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage("クリックして再試行"),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage("ログインしてください"),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "g_key_filter_type": MessageLookupByLibrary.simpleMessage("Type"),
    "g_key_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Forgot Password?",
    ),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Gasアラート"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage("以上でアラート"),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage("以下でアラート"),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("保存"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "しきい値 (Gwei)",
    ),
    "g_key_gas_auto_refresh": m29,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("基本料金"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage("予想時間"),
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
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("中程度"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("強い"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "パターンが簡単すぎます。ノードをもっと追加してください",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("弱い"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Google sign-in cancelled",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "High value only",
    ),
    "g_key_hw_account_added": m30,
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("アカウント"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("追加"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage("アカウント追加"),
    "g_key_hw_add_account_content": m31,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "アドレスをコピーしました",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Make sure your device is unlocked and Bluetooth is enabled before connecting.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("Check App"),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "デバイスで確認してください",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage("ハードウェアウォレット接続"),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Connect New Device",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Air-gap with Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Connect Ledger (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Connect Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Connecting...",
    ),
    "g_key_hw_current_app_label": m32,
    "g_key_hw_days_ago": m33,
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage("導出パス"),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage("切断済み"),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Bluetoothを有効にしてください",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage("ファームウェアバージョン"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("戻る"),
    "g_key_hw_import_failed": m34,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connect Keystone",
    ),
    "g_key_hw_keystone_invalid_response": MessageLookupByLibrary.simpleMessage(
      "Invalid response from Keystone device",
    ),
    "g_key_hw_keystone_scan_error": MessageLookupByLibrary.simpleMessage(
      "Failed to parse QR code. Please try again.",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Scan this QR code with your Keystone device to sign the transaction",
    ),
    "g_key_hw_keystone_scan_response_hint":
        MessageLookupByLibrary.simpleMessage(
          "Point your camera at the QR code displayed on your Keystone device",
        ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Scan Keystone Signature"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Scan the QR code from your Keystone device to import accounts",
    ),
    "g_key_hw_keystone_signature_received":
        MessageLookupByLibrary.simpleMessage("Signature received successfully"),
    "g_key_hw_keystone_signing": MessageLookupByLibrary.simpleMessage(
      "Waiting for Keystone signature...",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Tap to scan Keystone response",
    ),
    "g_key_hw_last_connected": m35,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
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
      "No app is currently open",
    ),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage("デバイスが見つかりません"),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "デバイスが接続されていません",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Not Connected",
    ),
    "g_key_hw_open_app": m36,
    "g_key_hw_open_ledger_app_hint": m37,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage("デバイスで拒否されました"),
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Remove Device",
    ),
    "g_key_hw_remove_device_confirm": m38,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Saved Devices",
    ),
    "g_key_hw_scanning": MessageLookupByLibrary.simpleMessage("デバイス検索中..."),
    "g_key_hw_select_device": MessageLookupByLibrary.simpleMessage("デバイス選択"),
    "g_key_hw_sign_message": MessageLookupByLibrary.simpleMessage("メッセージ署名"),
    "g_key_hw_sign_tx": MessageLookupByLibrary.simpleMessage("トランザクション署名"),
    "g_key_hw_signal_strength": MessageLookupByLibrary.simpleMessage("信号強度"),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Supported Devices",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage("接続タイムアウト"),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage("ハードウェアウォレット"),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Today"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Trezor"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Failed to connect to Trezor. Make sure USB is connected.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connect Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor connected successfully",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Connecting to Trezor...",
    ),
    "g_key_hw_trezor_passphrase_required": MessageLookupByLibrary.simpleMessage(
      "Enter passphrase on your Trezor device",
    ),
    "g_key_hw_trezor_pin_required": MessageLookupByLibrary.simpleMessage(
      "Enter PIN on your Trezor device",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Connect your Trezor device via USB cable and unlock it",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "View Accounts",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "ウォレットアカウント",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "現在の通貨ウォレットは既に存在します。",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "キーストアを読み取れませんでした",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("キーストア"),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage("Link Account"),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Linked Accounts",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("ログイン"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("ログアウト"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "アプリを終了してもよろしいですか？",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "利用可能ポイント",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Checked in today!",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Check In",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Check-in failed, please try again",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Check-in successful!",
    ),
    "g_key_loyalty_claim_points": MessageLookupByLibrary.simpleMessage(
      "ポイント獲得",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Task failed, please try again",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Task completed!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "デイリーチェックイン",
    ),
    "g_key_loyalty_earn_points": m39,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("獲得"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage("ポイント履歴"),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Invite"),
    "g_key_loyalty_invite_bonus": m40,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Invite Friends",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "招待した友達",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Max Level",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_loyalty_next_tier": MessageLookupByLibrary.simpleMessage("次のランク"),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "利用可能な特典なし",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "利用可能なタスクなし",
    ),
    "g_key_loyalty_points": MessageLookupByLibrary.simpleMessage("ポイント"),
    "g_key_loyalty_points_to_next": m41,
    "g_key_loyalty_redeem": MessageLookupByLibrary.simpleMessage("交換"),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("紹介"),
    "g_key_loyalty_referral_bonus": MessageLookupByLibrary.simpleMessage(
      "紹介ボーナス",
    ),
    "g_key_loyalty_referral_code": MessageLookupByLibrary.simpleMessage(
      "紹介コード",
    ),
    "g_key_loyalty_referral_link": MessageLookupByLibrary.simpleMessage(
      "紹介リンク",
    ),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage("特典"),
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Share"),
    "g_key_loyalty_spent": MessageLookupByLibrary.simpleMessage("使用"),
    "g_key_loyalty_task_complete": MessageLookupByLibrary.simpleMessage(
      "タスク完了",
    ),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("タスク"),
    "g_key_loyalty_tier": MessageLookupByLibrary.simpleMessage("ランク"),
    "g_key_loyalty_tier_bronze": MessageLookupByLibrary.simpleMessage("ブロンズ"),
    "g_key_loyalty_tier_diamond": MessageLookupByLibrary.simpleMessage(
      "ダイヤモンド",
    ),
    "g_key_loyalty_tier_gold": MessageLookupByLibrary.simpleMessage("ゴールド"),
    "g_key_loyalty_tier_platinum": MessageLookupByLibrary.simpleMessage("プラチナ"),
    "g_key_loyalty_tier_silver": MessageLookupByLibrary.simpleMessage("シルバー"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("ポイント"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Total Earned",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage("総ポイント"),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Used"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("ブラウザ"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("時価総額"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("取引量"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("総供給量"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("流通量"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("概要"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("詳細"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("リンク"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("ウェブサイト"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Manage Chains",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requires staking",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage("シードフレーズを入力してください"),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage("New airdrops"),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "New password must be different from current password",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("合計"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("カメラ"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("写真を選択"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("コンテンツ"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("名前"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("戻る"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("取引が送信されました"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("動画を選択"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Invalid wallet address",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Balance"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "This action is irreversible. The NFT will be sent to the burn address.",
    ),
    "g_key_nft_burn_evm_only": MessageLookupByLibrary.simpleMessage(
      "Burn is only supported on EVM chains",
    ),
    "g_key_nft_burn_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana NFT burn is coming soon",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("Burn NFT"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Collection"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Contract"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "Failed to load NFTs. Tap to retry.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("All"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Video"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Floor"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("NFT Gallery"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage(
      "Inscription #",
    ),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage("No NFTs found"),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "No explorer link available",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "Video playback not supported",
    ),
    "g_key_nft_open_browser": MessageLookupByLibrary.simpleMessage(
      "View on Explorer",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("Ordinals"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "Ordinals transfers are not yet supported",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search by name or collection",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Send NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana NFT transfers are coming soon",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("Token ID"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Type"),
    "g_key_no_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "No linked accounts",
    ),
    "g_key_notification_settings": MessageLookupByLibrary.simpleMessage(
      "Notification Settings",
    ),
    "g_key_oidc_login": MessageLookupByLibrary.simpleMessage(
      "Enterprise Login (SSO)",
    ),
    "g_key_oidc_not_configured": MessageLookupByLibrary.simpleMessage(
      "Enterprise SSO not configured",
    ),
    "g_key_old_password": MessageLookupByLibrary.simpleMessage(
      "Current Password",
    ),
    "g_key_or": MessageLookupByLibrary.simpleMessage("or"),
    "g_key_password_changed_success": MessageLookupByLibrary.simpleMessage(
      "Password changed successfully",
    ),
    "g_key_password_min_length": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "g_key_password_req_different": MessageLookupByLibrary.simpleMessage(
      "Different from current password",
    ),
    "g_key_password_req_length": MessageLookupByLibrary.simpleMessage(
      "At least 6 characters",
    ),
    "g_key_password_required": MessageLookupByLibrary.simpleMessage(
      "Password is required",
    ),
    "g_key_password_requirements": MessageLookupByLibrary.simpleMessage(
      "Password Requirements",
    ),
    "g_key_password_reset_success": MessageLookupByLibrary.simpleMessage(
      "Password reset successfully",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "g_key_payment_amount_invalid": MessageLookupByLibrary.simpleMessage(
      "無効な金額",
    ),
    "g_key_payment_approx_token": m42,
    "g_key_payment_approx_usdt": m43,
    "g_key_payment_code_title": MessageLookupByLibrary.simpleMessage("支払いQR"),
    "g_key_payment_confirm": MessageLookupByLibrary.simpleMessage("確認"),
    "g_key_payment_history": MessageLookupByLibrary.simpleMessage("支払い履歴"),
    "g_key_payment_history_btn": MessageLookupByLibrary.simpleMessage("履歴"),
    "g_key_payment_incoming": MessageLookupByLibrary.simpleMessage("受取"),
    "g_key_payment_load_failed": MessageLookupByLibrary.simpleMessage("読み込み失敗"),
    "g_key_payment_name_not_set": MessageLookupByLibrary.simpleMessage("未設定"),
    "g_key_payment_native_insufficient": MessageLookupByLibrary.simpleMessage(
      "ネイティブ残高が不足しています！",
    ),
    "g_key_payment_native_not_found": MessageLookupByLibrary.simpleMessage(
      "メインチェーンが見つかりません！",
    ),
    "g_key_payment_outgoing": MessageLookupByLibrary.simpleMessage("支払"),
    "g_key_payment_set_amount_title": MessageLookupByLibrary.simpleMessage(
      "受取金額を設定",
    ),
    "g_key_payment_success": MessageLookupByLibrary.simpleMessage("支払い成功！"),
    "g_key_payment_title": MessageLookupByLibrary.simpleMessage("支払い"),
    "g_key_payment_usdt_insufficient": MessageLookupByLibrary.simpleMessage(
      "USDTの残高が不足しています！",
    ),
    "g_key_payment_usdt_not_found": MessageLookupByLibrary.simpleMessage(
      "USDTトークンを追加してください！",
    ),
    "g_key_payment_wallet": MessageLookupByLibrary.simpleMessage("ウォレット"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage("ギャラリーから選択"),
    "g_key_resend_code": MessageLookupByLibrary.simpleMessage("Resend Code"),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "g_key_reset_password": MessageLookupByLibrary.simpleMessage(
      "Reset Password",
    ),
    "g_key_reset_password_email_desc": MessageLookupByLibrary.simpleMessage(
      "Enter your email address to receive a verification code",
    ),
    "g_key_saml_login": MessageLookupByLibrary.simpleMessage("SAML Login"),
    "g_key_saml_not_configured": MessageLookupByLibrary.simpleMessage(
      "SAML not configured",
    ),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Use Caution",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Checking contract security...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "High Risk Detected",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GoPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Contract Verified Safe",
    ),
    "g_key_send_code": MessageLookupByLibrary.simpleMessage(
      "Send Verification Code",
    ),
    "g_key_set_new_password_desc": MessageLookupByLibrary.simpleMessage(
      "Set your new password",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("QRコードを共有"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("リンクを共有"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage("共有方法"),
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Sign in failed",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage("Social Login"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("チャット"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "ファイルが大きすぎてアップロードできません",
    ),
    "g_key_squad_k15": m44,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("連絡先を追加"),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("連絡先"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage("メールで検索"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("アクティブ"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Active Positions",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("年利"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Avg APY"),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage("報酬を請求"),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("手数料"),
    "g_key_stake_d_unbond": m45,
    "g_key_stake_days_left": m46,
    "g_key_stake_days_remaining": m47,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage("委任者数"),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage("リキッドステーキング"),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Liquid"),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage("最低ステーク額"),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("No lock"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "ステーキングポジションなし",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "No staking positions yet",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Total Staking Overview",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "未請求報酬",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage("マイポジション"),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("プロトコル"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocols"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("再ステーク"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("報酬"),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "バリデーター選択",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("ステーク"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Staked"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Start Staking",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("ステーキング"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage("ステーク総額"),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage("アンボンディング中"),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "アンボンディング期間",
    ),
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("アンステーク"),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("稼働率"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("バリデーター"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage("バリデーター一覧"),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Password"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("完了"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("ガス価格"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("最大ガス手数料"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("ガスあたりの最大手数料"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("保留中"),
    "g_key_t_29": m48,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("失敗"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("マイナー手数料"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("続行"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("ウォレットパスワード"),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage("ウォレットパスワードを入力してください"),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage("ウォレットパスワードが間違っています"),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage("ウォレットパスワードを入力してください"),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("ガス手数料率"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage("最新ブロックのガス手数料率の平均"),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("送金"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage("0より大きい整数を入力してください。"),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage("データの取得に失敗しました"),
    "g_key_t_45": m49,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage("受取アドレスアカウントを確認"),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("検索"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("アカウントなし"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("入金"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("無効なアドレス"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage("アカウント確認成功"),
    "g_key_t_52": m50,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "受取アドレスにはアカウントがなく、初回送金には最低10XRPが必要です",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("使用ガス"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("ガス"),
    "g_key_time_days_ago": m51,
    "g_key_time_hours_ago": m52,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_time_minutes_ago": m53,
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("取引履歴"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("取引詳細"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage("取引レシートは履歴でご確認ください"),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("支払い金額"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("受取金額"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Start Date",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Date Range",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage("End Date"),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Direction",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "No transactions match your filter",
    ),
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("NFTタイプ"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("フォロワー"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("ユーザータイプ"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("ウェブサイト"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("製品リンク"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("メディアプラットフォーム"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("ウォレットアドレス"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("ニックネーム"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage("アバターのアップロードに失敗しました"),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("説明"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage("アーティスト情報"),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage("あなたはアーティストではありません"),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "こちらをクリックしてアーティストになるための申請をしてください",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("名前"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("収益"),
    "g_key_unlink_account": MessageLookupByLibrary.simpleMessage(
      "Unlink Account",
    ),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage("以下を読み、同意しました："),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage("利用規約"),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "プライバシーポリシーおよび個人情報収集に関する声明",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage("最新バージョンが見つかりました"),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("今すぐアップデート"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("新しいバージョンが見つかりました"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage("既に最新バージョンです"),
    "g_key_verification_code": MessageLookupByLibrary.simpleMessage(
      "Verification Code",
    ),
    "g_key_verification_code_sent": m54,
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage("シードフレーズを表示"),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "シードフレーズを記録し、安全に保管してください。",
    ),
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
    "g_key_wallet_m1": m55,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "本当にアカウントを削除しますか？",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage("ログアウトを確認"),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Google認証コードを入力してください。",
    ),
    "g_key_wallet_m19": m56,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "現在のトークンが追加されていません。",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "シードフレーズをスペースで区切って入力してください",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("ウォレットをインポート"),
    "g_key_wallet_m3": m57,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "現在のトークン残高が不足しています。",
    ),
    "g_key_wallet_m5": m58,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("署名エラー"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage("アカウント削除"),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "メール認証コードを入力してください。",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage("ウォレット管理"),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Enter Ethereum address (0x...)",
    ),
    "g_key_watch_only_banner": MessageLookupByLibrary.simpleMessage(
      "Watch-only",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "Watch-only wallet cannot send or sign transactions",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage("Watch Wallet"),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Track any EVM address without private key",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("予約済み"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("基本準備金"),
    "g_key_xml_11": m59,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("増分準備金"),
    "g_key_xml_22": m60,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage("所有オブジェクト数"),
    "g_key_xml_33": m61,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage("合計準備金額の計算方法"),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "合計準備金 = 基本準備金 +（所有オブジェクト数 × 増分準備金）",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch IDとFace ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("現在のパスワード"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("新しいパスワード"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage("新しいパスワードを確認"),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("6桁の数字"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage("パスワードと生体認証"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("パターンパスワード"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage("パターンパスコードを設定"),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "アカウントのセキュリティのため、グループパスワードを設定してください",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage("2回目のパターンパスワード描画"),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage("パターンパスワードを描画"),
    "g_lock_key21": m62,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage("パターンパスワードをリセット"),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "入力エラーが多すぎます。パスワードをリセットしてください",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage("ウォレットパスワードを追加しますか？"),
    "g_lock_key25": m63,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage("ロック画面ページ"),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("自動ロック"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("成功"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("失敗"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage("生体認証が有効になっていません"),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage("生体認証を追加しますか？"),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage("パスワードをリセット"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "No watchlist yet",
    ),
    "g_market_empty_watchlist_hint": MessageLookupByLibrary.simpleMessage(
      "Tap ★ on any coin to add",
    ),
    "g_market_news": MessageLookupByLibrary.simpleMessage("News"),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage("No results"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Search"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search coins...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Trending"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage("Watchlist"),
    "g_mining_key15": MessageLookupByLibrary.simpleMessage("Task detail"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Nをアンロックしますか？"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage("クラウド認証アクティビティ"),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Verification Settings",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Background Verification Music",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("Default"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Mute"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "When background verification is enabled, the music will play in the background. If the music stops, verification will also stop.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Your Tier"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "セットアップには少量のガスが必要です。",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "N42Walletのグループノードに正常に参加しました。リンクを共有して友達を招待し、ノードをアクティブ化して認証を開始しましょう！",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage("友達に共有"),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("続行"),
    "g_mining_key63": m64,
    "g_mining_key7": MessageLookupByLibrary.simpleMessage("Unlock Date"),
    "g_mining_key73": m65,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "@N42Walletでノードをセットアップし、モバイルデバイスで認証を開始しました！ぜひ参加してください。分散化された未来はモバイルです！",
    ),
    "g_mining_key76": m66,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("Mineral"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Node"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Network"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Switch between testnet and mainnet for cloud mining.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage("768秒後に引き換え可能です。"),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "それ以前のリクエストは処理されません。",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Home"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("本日の報酬"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "以下のデータを重要な鍵として扱ってください。すぐにコピーして信頼できる場所にバックアップすることをお勧めします。",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("データをコピー"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("非アクティブ"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage("バリデーター一覧"),
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
    "g_mining_key_109": m67,
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
    "g_mining_key_116": m68,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "報酬は毎日蓄積され、約0.5 Nに達した時にのみNウォレットに送信されます。",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("累計報酬"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("マイニング価値"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage("Task detail"),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Summary"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Activities"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Total Value Mined",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage(
      "Verification Since",
    ),
    "g_mining_key_22": MessageLookupByLibrary.simpleMessage(
      "Reward Distribution",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("利益回数"),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage("Verified Value"),
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
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to skip?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "You will not receive any verification rewards until you choose 1 of the plans.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("無効"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Reward"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("詳細を見る"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage("認証ステータス"),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("To unlock"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Skip"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("Past 7 Days"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage(
      "Accumulated Rewards",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Nをロックして報酬認証を開始します。",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage("Rewards Received"),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Advanced"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("エントリー"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Pro"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("FULL NODE"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("MINS/DAY"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("アドバンスドノード"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("エントリーノード"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("プロノード"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage("1日500ブロック〜約70分"),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Unlock Date"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage("1日100ブロック〜約15分"),
    "g_mining_key_71": m69,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage("128秒ごとにチェック"),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage("クラウド認証が開始されました"),
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
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Today\'s Verification Time",
    ),
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
    "g_mining_key_98": m70,
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
    "g_news_empty": MessageLookupByLibrary.simpleMessage("No news available"),
    "g_news_source": MessageLookupByLibrary.simpleMessage("Source"),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage("通知"),
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
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage("Add Trade"),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Avg Cost"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Buy Price (USD)",
    ),
    "g_pnl_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Cost Basis"),
    "g_pnl_no_trades": MessageLookupByLibrary.simpleMessage(
      "No trades recorded",
    ),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Save"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage("Unrealized P&L"),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("24h Change"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage("全保有資産"),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Asset Allocation",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage("Top Gainers"),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage("トップ下落"),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage("24h Movers"),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "No assets found",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("Others"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("合計"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Portfolio"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("Total Value"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage("招待コード"),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("招待済み"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("マイニングノード"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("報酬 (N)"),
    "g_referral_stats_title": MessageLookupByLibrary.simpleMessage("招待統計"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "クラシックマイニング (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "クラウドマイニング (V2)",
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
    "g_swap_key_14": m71,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage("コイン価格の取得エラー。"),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "続行すると、以下に同意したことになります：",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage("利用規約"),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("完了"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "スワップはまもなく配布されます。しばらくお待ちください。",
    ),
    "g_swap_key_20": m72,
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
    "g_swap_key_31": m73,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "スワップは関連するチェーンエクスプローラー（Etherscan、BscScan、TRONSCAN、および当社独自のエクスプローラー）で確認できます。",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Nにスワップ"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("スワップ"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("受取"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("スワッププレビュー"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("再試行"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage(
      "Accent Color",
    ),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Reset to default",
    ),
    "g_token_m_key_1": m74,
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
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage("カスタムチェーンを追加"),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0〜18の整数"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("トークンを追加"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("フォーマットエラー！"),
    "g_token_m_key_22": m75,
    "g_token_m_key_23": m76,
    "g_token_m_key_24": m77,
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
    "g_unlock_key10": m78,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "指紋または顔認証が有効になっていませんか？",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage("パターンパスワードを描画"),
    "g_unlock_key4": m79,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("パスワードを入力"),
    "g_unlock_key6": m80,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage("認証に失敗しました"),
    "g_unlock_key8": m81,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("または"),
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
    "g_wc_new_connection": MessageLookupByLibrary.simpleMessage("新しい接続"),
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
    "google_verification": MessageLookupByLibrary.simpleMessage("Google認証"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "リンク",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Google認証をダウンロード",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage("手順"),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Google認証を開きます。",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "画面に6桁の認証コードが表示されます。",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "6桁のコードをコピーしてN42Walletに貼り付けます。",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "すると、認証が正常にリンクされます。",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "バックアップキー",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "キーをGoogle認証にコピー",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Google認証コードを入力",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "メール認証コードを入力",
    ),
    "google_verification_message21": m82,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Googleキーの取得に失敗しました",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "二要素認証（2FA）",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "アカウントを保護するため、少なくとも1つの2FAを有効にすることをお勧めします。",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "Google認証アプリは、出金とN42Walletアカウントを保護します。",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "ダウンロードとインストール",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Google認証をダウンロードしてインストールしてください。その後、「リンク」を押してN42Walletアカウントをリンクしてください。",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("重要なお知らせ"),
    "login_button_text": MessageLookupByLibrary.simpleMessage("ログイン"),
    "login_email": MessageLookupByLibrary.simpleMessage("メールアドレス"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "パスワードをお忘れですか？",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage("紹介コード"),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage("紹介コード"),
    "login_message_1": MessageLookupByLibrary.simpleMessage("アカウントをお持ちでないですか？"),
    "login_message_10": MessageLookupByLibrary.simpleMessage("作成に成功しました"),
    "login_message_11": MessageLookupByLibrary.simpleMessage("リセットに成功しました"),
    "login_message_2": MessageLookupByLibrary.simpleMessage("既にアカウントをお持ちですか？"),
    "login_message_6": MessageLookupByLibrary.simpleMessage("コード再送信まで"),
    "login_message_7": MessageLookupByLibrary.simpleMessage("コードの送信に成功しました"),
    "login_message_8": MessageLookupByLibrary.simpleMessage("メールアドレスが未登録です"),
    "login_message_9": MessageLookupByLibrary.simpleMessage("コードの送信に失敗しました"),
    "login_need_login": MessageLookupByLibrary.simpleMessage("まずログインしてください"),
    "login_password": MessageLookupByLibrary.simpleMessage("パスワード"),
    "next": MessageLookupByLibrary.simpleMessage("次へ"),
    "nicknameMessage": m83,
    "password_diff": MessageLookupByLibrary.simpleMessage("パスワードが一致しません"),
    "personalInformation": MessageLookupByLibrary.simpleMessage("プロフィール編集"),
    "photograph": MessageLookupByLibrary.simpleMessage("撮影"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage("認証コードを入力"),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "メールアドレスを入力してください",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "パスワードを入力してください",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "アドレスを入力してください",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage("パスワードを再入力"),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "パスワードを選択（8〜18文字）",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage("パスワードを確認"),
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "パスワードを再入力",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage("コードを入力"),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage(
      "ワンタイムパスワード",
    ),
    "rest_your_password": MessageLookupByLibrary.simpleMessage("パスワードをリセット"),
    "s_key_1": MessageLookupByLibrary.simpleMessage("ウォレット管理"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("アプリについて"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("セキュリティ"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("新しいチャットを使用"),
    "s_key_13": MessageLookupByLibrary.simpleMessage("拡張チャット体験を有効にする"),
    "s_key_2": MessageLookupByLibrary.simpleMessage("ウォレットアドレス"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("取引"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("言語"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("テーマ"),
    "search": MessageLookupByLibrary.simpleMessage("検索"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "利用規約を読み、確認してください",
    ),
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

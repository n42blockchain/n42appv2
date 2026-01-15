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

  static String m0(value) => "私は${value}です";

  static String m1(value) => "チャットメンバー（${value}）";

  static String m2(value) => "${value}を友達として追加してもよろしいですか";

  static String m3(value) => "既にバインド済みのため、現在再バインドできません。バインドアドレス：${value}";

  static String m4(value) => "バインド成功。バインドアドレス：${value}";

  static String m5(value) => "${value}ウォレットにN42チェーンがありません！";

  static String m6(value) => "マッチング成功。アドレス：${value}";

  static String m7(value) => "${value}より大きい金額です。";

  static String m8(value) => "ウォレットは既に存在します。ウォレット名は「${value}」です";

  static String m9(value) => "${value}以上の金額を入力してください。";

  static String m10(value) => "連絡先${value}を削除してもよろしいですか？";

  static String m11(value) => "「${value}」が不足しています";

  static String m12(value) => "「${value}」アカウントの取得に失敗しました";

  static String m13(value) => "初回送金には最低${value} XRPが必要です";

  static String m14(value) => "${value}チェーンが追加されていません。";

  static String m15(value) => "${value}には未完了の取引があります。後でもう一度お試しください。";

  static String m16(value) => "${value}のアドレスが見つかりません。";

  static String m17(value) => "${value}の残高が不足しています。";

  static String m18(value, value1) =>
      "すべてのXRPアカウントはベースラインとして${value} XRP（${value1}ドロップ）を準備金として確保する必要があり、これは使用できません。";

  static String m19(value, value1) =>
      "アカウントが所有するオブジェクトごとに、${value} XRP（${value1}ドロップ）が準備金に追加されます。";

  static String m20(value, value1) =>
      "このアカウントは${value}個のオブジェクトを所有しているため、追加で${value1} XRPが準備金として確保されています。";

  static String m21(value) => "パターンパスワードの入力エラー、あと${value}回試行できます";

  static String m22(value) => "パターンパスワードの入力エラー、あと${value}回試行できます";

  static String m23(value) => "${value}のセットアップに成功しました。N42Walletで認証を開始します！";

  static String m24(value) =>
      "@N42Walletで私の${value}グループに参加して、Layer 1チェーンの初期マイナーになり、スマホで暗号資産を獲得しよう！";

  static String m25(value) => "バリデーターを実行するには${value} Nをロックしてください。";

  static String m26(value) => "インポートに失敗しました：${value}";

  static String m27(value) => "報酬を得るには、最低${value}のステーキング残高が必要です。";

  static String m28(value, value1) => "${value1}ブロックマイニングごとに${value} N";

  static String m29(value) => "${value}文字である必要があります";

  static String m30(value) => "${value}の残高が不足しています。";

  static String m31(value) => "${value}を受取中...";

  static String m32(value) =>
      "アプリ内でスワップされた${value}はまもなくウォレットに配布され、このプロセスでは売却できません。ノードの運用に使用できます。";

  static String m33(value) => "最大${value}文字";

  static String m34(value) => "${value}チェーンは既にアプリでサポートされています！";

  static String m35(value) => "${value}チェーンは既にアプリでサポートされています。追加しますか？";

  static String m36(value) => "${value}アドレスのテストリンクに失敗しました！";

  static String m37(value) => "アプリケーションは${value}秒後にロック解除されます。";

  static String m38(value) => "パターンパスワードの入力エラー、あと${value}回試行できます";

  static String m39(value) => "パスワードの入力エラー、あと${value}回試行できます";

  static String m40(value) => "パスワードの入力エラー、あと${value}回試行できます";

  static String m41(value) => "${value}パスワードを入力";

  static String m42(value) => "0〜${value}文字";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Create_account": MessageLookupByLibrary.simpleMessage("新規登録"),
        "Create_your_account": MessageLookupByLibrary.simpleMessage("アカウントを作成"),
        "Edit": MessageLookupByLibrary.simpleMessage("編集"),
        "Verification": MessageLookupByLibrary.simpleMessage("確認"),
        "address_Information": MessageLookupByLibrary.simpleMessage("アドレス情報"),
        "code_403":
            MessageLookupByLibrary.simpleMessage("アカウントが1日間一時的にロックされました"),
        "code_err_tips":
            MessageLookupByLibrary.simpleMessage("コードが正しくありません。もう一度お試しください。"),
        "copy": MessageLookupByLibrary.simpleMessage("コピーしました"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("アドレスをコピー"),
        "descO": MessageLookupByLibrary.simpleMessage("説明（任意）"),
        "editPhoto": MessageLookupByLibrary.simpleMessage("写真を編集"),
        "email_code_error":
            MessageLookupByLibrary.simpleMessage("認証コードの取得に失敗しました"),
        "email_code_finish": MessageLookupByLibrary.simpleMessage(
            "認証コードが正常に送信されました。メールを確認してください"),
        "email_code_input_error":
            MessageLookupByLibrary.simpleMessage("認証コードエラー"),
        "email_error": MessageLookupByLibrary.simpleMessage("無効なメールアドレス"),
        "email_verification": MessageLookupByLibrary.simpleMessage("メールアドレス認証"),
        "email_verification_message1": MessageLookupByLibrary.simpleMessage(
            "メールアドレス認証アプリは、出金とN42Walletアカウントを保護します。"),
        "email_verification_message2":
            MessageLookupByLibrary.simpleMessage("メール認証を追加しますか？"),
        "file": MessageLookupByLibrary.simpleMessage("ファイル"),
        "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
            "トークンは同じネットワーク内でのみ送信できます。他のネットワークから送信すると、損失が発生する可能性があります。"),
        "g_app_share_key_2": MessageLookupByLibrary.simpleMessage("スキャンして受取"),
        "g_browser_key1": MessageLookupByLibrary.simpleMessage("URLを入力してください"),
        "g_browser_key10": MessageLookupByLibrary.simpleMessage("説明を入力"),
        "g_browser_key11": MessageLookupByLibrary.simpleMessage("ブラウザ"),
        "g_browser_key12":
            MessageLookupByLibrary.simpleMessage("ブラウザキャッシュをクリア"),
        "g_browser_key13": MessageLookupByLibrary.simpleMessage("DAppに自動接続"),
        "g_browser_key14":
            MessageLookupByLibrary.simpleMessage("DAppへの接続を確認してください"),
        "g_browser_key16": MessageLookupByLibrary.simpleMessage("すべて閉じる"),
        "g_browser_key17": MessageLookupByLibrary.simpleMessage("完了"),
        "g_browser_key3": MessageLookupByLibrary.simpleMessage("ブックマーク"),
        "g_browser_key4":
            MessageLookupByLibrary.simpleMessage("ブックマークがまだ追加されていません"),
        "g_browser_key5": MessageLookupByLibrary.simpleMessage("ブックマーク"),
        "g_browser_key6": MessageLookupByLibrary.simpleMessage("名前"),
        "g_browser_key7": MessageLookupByLibrary.simpleMessage("名前を入力してください"),
        "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
        "g_browser_key9": MessageLookupByLibrary.simpleMessage("説明"),
        "g_chat_key_1": MessageLookupByLibrary.simpleMessage("グループチャットを開始"),
        "g_chat_key_10": m0,
        "g_chat_key_11": MessageLookupByLibrary.simpleMessage("友達を招待"),
        "g_chat_key_12": MessageLookupByLibrary.simpleMessage("連絡先を選択"),
        "g_chat_key_13": MessageLookupByLibrary.simpleMessage("完了"),
        "g_chat_key_14":
            MessageLookupByLibrary.simpleMessage("少なくとも2人の連絡先を選択してください"),
        "g_chat_key_16": MessageLookupByLibrary.simpleMessage("友達詳細"),
        "g_chat_key_17": MessageLookupByLibrary.simpleMessage("グループ詳細"),
        "g_chat_key_18": MessageLookupByLibrary.simpleMessage("グループメンバーをもっと見る"),
        "g_chat_key_19": MessageLookupByLibrary.simpleMessage("グループ名"),
        "g_chat_key_2": MessageLookupByLibrary.simpleMessage("新しい友達"),
        "g_chat_key_20": MessageLookupByLibrary.simpleMessage("本当に解散しますか？"),
        "g_chat_key_21":
            MessageLookupByLibrary.simpleMessage("このグループを退出してもよろしいですか？"),
        "g_chat_key_22": MessageLookupByLibrary.simpleMessage("グループ解散"),
        "g_chat_key_23": MessageLookupByLibrary.simpleMessage("グループを退出"),
        "g_chat_key_24": MessageLookupByLibrary.simpleMessage("グループチャット名を変更"),
        "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
            "グループチャット名を変更すると、グループ内の他のメンバーに通知されます。"),
        "g_chat_key_26": MessageLookupByLibrary.simpleMessage("完了"),
        "g_chat_key_27": MessageLookupByLibrary.simpleMessage("友達追加リクエスト"),
        "g_chat_key_28": MessageLookupByLibrary.simpleMessage("友達として追加リクエスト"),
        "g_chat_key_29":
            MessageLookupByLibrary.simpleMessage("友達リクエストが承認されました"),
        "g_chat_key_3": MessageLookupByLibrary.simpleMessage("追加済み"),
        "g_chat_key_30": MessageLookupByLibrary.simpleMessage("友達として追加されました"),
        "g_chat_key_31": MessageLookupByLibrary.simpleMessage("同意"),
        "g_chat_key_32": m1,
        "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
            "パスワードを正しく解析できず、一時的にメッセージを送信できません。グループに入る時にウォレットをインポートしてください"),
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
            "このメッセージはN42Walletに転送されます。この連絡先には通知されません。"),
        "g_chat_key_46": MessageLookupByLibrary.simpleMessage("動画"),
        "g_chat_key_47": MessageLookupByLibrary.simpleMessage("写真"),
        "g_chat_key_48": MessageLookupByLibrary.simpleMessage("メッセージを削除"),
        "g_chat_key_49": MessageLookupByLibrary.simpleMessage("このデバイスから削除"),
        "g_chat_key_5": MessageLookupByLibrary.simpleMessage("待機中"),
        "g_chat_key_50": MessageLookupByLibrary.simpleMessage("同意"),
        "g_chat_key_54": MessageLookupByLibrary.simpleMessage("報告理由"),
        "g_chat_key_55": MessageLookupByLibrary.simpleMessage("報告理由を入力してください"),
        "g_chat_key_56":
            MessageLookupByLibrary.simpleMessage("報告を確認し、24時間以内に返信します。"),
        "g_chat_key_57":
            MessageLookupByLibrary.simpleMessage("報告しました - クリックして確認"),
        "g_chat_key_58": MessageLookupByLibrary.simpleMessage("ブラックリスト"),
        "g_chat_key_59": MessageLookupByLibrary.simpleMessage("削除"),
        "g_chat_key_6": m2,
        "g_chat_key_60": MessageLookupByLibrary.simpleMessage("まだ連絡先がありません"),
        "g_chat_key_61": MessageLookupByLibrary.simpleMessage("今日"),
        "g_chat_key_62": MessageLookupByLibrary.simpleMessage("3日以上前"),
        "g_chat_key_63": MessageLookupByLibrary.simpleMessage("ブロック"),
        "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
            "こんにちは、N42Walletでチャットや送金をしています。ウォレットをインストールして私にメッセージを送ってください："),
        "g_chat_key_66": MessageLookupByLibrary.simpleMessage("返信"),
        "g_chat_key_67": MessageLookupByLibrary.simpleMessage("メッセージは削除されました"),
        "g_chat_key_68":
            MessageLookupByLibrary.simpleMessage("誰かがあなたをメンションしました"),
        "g_chat_key_69": MessageLookupByLibrary.simpleMessage("挨拶する"),
        "g_chat_key_8": MessageLookupByLibrary.simpleMessage("友達を追加"),
        "g_chat_key_9": MessageLookupByLibrary.simpleMessage("申請理由"),
        "g_coin_key_1": MessageLookupByLibrary.simpleMessage("取引"),
        "g_connect_key1": MessageLookupByLibrary.simpleMessage("接続"),
        "g_connect_key11": MessageLookupByLibrary.simpleMessage("利用可能なネットワーク"),
        "g_connect_key12": MessageLookupByLibrary.simpleMessage("メッセージ署名"),
        "g_connect_key13": MessageLookupByLibrary.simpleMessage("接続中"),
        "g_connect_key14":
            MessageLookupByLibrary.simpleMessage("ペアリング中、お待ちください。"),
        "g_connect_key2": MessageLookupByLibrary.simpleMessage("切断"),
        "g_connect_key3": MessageLookupByLibrary.simpleMessage("拒否"),
        "g_face_1": MessageLookupByLibrary.simpleMessage("生体認証スキャンのヒント"),
        "g_face_10":
            MessageLookupByLibrary.simpleMessage("認証のために指紋または顔をスキャンしてください。"),
        "g_face_2": MessageLookupByLibrary.simpleMessage("生体認証スキャンが機能しませんでした"),
        "g_face_3": MessageLookupByLibrary.simpleMessage("ヒント"),
        "g_face_4": MessageLookupByLibrary.simpleMessage("生体認証スキャン成功"),
        "g_face_5": MessageLookupByLibrary.simpleMessage("設定する"),
        "g_face_6": MessageLookupByLibrary.simpleMessage(
            "生体認証ログインが設定されていません。システム設定で設定してください。"),
        "g_face_7":
            MessageLookupByLibrary.simpleMessage("続行するには顔または指紋をスキャンしてください。"),
        "g_face_8": MessageLookupByLibrary.simpleMessage("戻る"),
        "g_face_9":
            MessageLookupByLibrary.simpleMessage("生体認証を再度有効にすることをお勧めします。"),
        "g_face_match_key1": MessageLookupByLibrary.simpleMessage("顔認証方法"),
        "g_face_match_key10": m3,
        "g_face_match_key11": m4,
        "g_face_match_key12": MessageLookupByLibrary.simpleMessage("再バインド"),
        "g_face_match_key13": MessageLookupByLibrary.simpleMessage("バインド"),
        "g_face_match_key14": MessageLookupByLibrary.simpleMessage("確認"),
        "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
            "顔データをウォレットアドレスに直接バインドできます（以前にバインドしたことがある場合、古いウォレットアドレスは上書きされます）。以前にウォレットアドレスをバインドしたことがある場合は、手動で確認してバインドされたウォレットアドレスを取得することもできます。"),
        "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
            "顔データにリンクされたウォレットアドレスが検出されましたが、このウォレットはまだウォレット一覧にインポートされていません。"),
        "g_face_match_key17":
            MessageLookupByLibrary.simpleMessage("このウォレットと顔データがリンクされています。"),
        "g_face_match_key18": MessageLookupByLibrary.simpleMessage("ユーザー通知"),
        "g_face_match_key19":
            MessageLookupByLibrary.simpleMessage("顔バインディングとは？"),
        "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
            "顔バインディングは、顔認識技術を利用して、生体顔特徴とブロックチェーンウォレットアドレスをマッチングさせます。"),
        "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
            "このプロセスにより、取引の利便性が向上するだけでなく、アカウントのセキュリティが強化され、すべてのアクションがあなたによって承認されていることが保証されます。"),
        "g_face_match_key22":
            MessageLookupByLibrary.simpleMessage("なぜ顔バインディングが必要なのですか？"),
        "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
            "顔データをバインドすることで、あなたの身元が取引活動に直接リンクされ、本人確認プロセスが簡素化され、操作効率が向上します。この技術により、資産の転送やコントラクトとのやり取りなどの機密操作を行う際に、迅速かつ安全な本人確認が保証されます。"),
        "g_face_match_key24":
            MessageLookupByLibrary.simpleMessage("私の顔データはどのように保存され、安全ですか？"),
        "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
            "顔データは暗号化された形式でパブリックブロックチェーンに保存され、中央集権型データベースには保存されません。これにより、あなたの承認がある場合にのみシステムがデータを復号して本人確認に使用でき、プライバシーとデータセキュリティが確保されます。"),
        "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
            "顔バインディングはアカウントセキュリティにどのように影響しますか？"),
        "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
            "顔バインディングにより、すべての機密アクションがあなたの明示的な承認がある場合にのみ実行されることが保証され、アカウントセキュリティが強化されます。業界最高レベルの暗号化技術を使用して生体データを保護し、不正アクセスを防止します。"),
        "g_face_match_key28":
            MessageLookupByLibrary.simpleMessage("私の顔データは安全ですか？"),
        "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
            "はい。すべての生体データは厳格な暗号化が施され、データ転送と保存には最高のセキュリティ基準が適用されます。システムは、本人確認を完了するために必要な場合にのみこのデータを復号します。"),
        "g_face_match_key3":
            MessageLookupByLibrary.simpleMessage("マッチングに失敗しました！"),
        "g_face_match_key30": MessageLookupByLibrary.simpleMessage("了解しました"),
        "g_face_match_key31":
            MessageLookupByLibrary.simpleMessage("ウォレットアドレスを選択"),
        "g_face_match_key32": m5,
        "g_face_match_key33": MessageLookupByLibrary.simpleMessage("バインド解除"),
        "g_face_match_key34":
            MessageLookupByLibrary.simpleMessage("顔データの確認に失敗しました！"),
        "g_face_match_key35":
            MessageLookupByLibrary.simpleMessage("顔データのバインド解除に失敗しました！"),
        "g_face_match_key4": m6,
        "g_face_match_key5": MessageLookupByLibrary.simpleMessage("アドレスエラー！"),
        "g_face_match_key6":
            MessageLookupByLibrary.simpleMessage("顔データバインディング"),
        "g_face_match_key7": MessageLookupByLibrary.simpleMessage("顔認証マッチング"),
        "g_face_match_key8": MessageLookupByLibrary.simpleMessage("再選択"),
        "g_face_match_key9": MessageLookupByLibrary.simpleMessage("マッチング"),
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
        "g_key_135": m7,
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
        "g_key_192":
            MessageLookupByLibrary.simpleMessage("ウォレットを削除してもよろしいですか？"),
        "g_key_193": MessageLookupByLibrary.simpleMessage("アクティブ"),
        "g_key_195": MessageLookupByLibrary.simpleMessage("カメラへのアクセス許可がありません。"),
        "g_key_196": MessageLookupByLibrary.simpleMessage("エクスプローラー"),
        "g_key_197": MessageLookupByLibrary.simpleMessage("最大"),
        "g_key_198": MessageLookupByLibrary.simpleMessage("資産"),
        "g_key_2": MessageLookupByLibrary.simpleMessage("台帳が空です！"),
        "g_key_202": MessageLookupByLibrary.simpleMessage("取引概要"),
        "g_key_203":
            MessageLookupByLibrary.simpleMessage("リンクエラー、QRコードを再度スキャンしてください。"),
        "g_key_205":
            MessageLookupByLibrary.simpleMessage("フォトアルバムへのアクセス許可がありません。"),
        "g_key_206": MessageLookupByLibrary.simpleMessage("パスワード変更"),
        "g_key_207": MessageLookupByLibrary.simpleMessage("現在のパスワード"),
        "g_key_208": MessageLookupByLibrary.simpleMessage("残高を同期中..."),
        "g_key_209": MessageLookupByLibrary.simpleMessage("秘密鍵"),
        "g_key_21": MessageLookupByLibrary.simpleMessage("ウォレットパスワードを入力"),
        "g_key_210": MessageLookupByLibrary.simpleMessage("秘密鍵エラー"),
        "g_key_211": MessageLookupByLibrary.simpleMessage("購入"),
        "g_key_212": MessageLookupByLibrary.simpleMessage("売却"),
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
        "g_key_47":
            MessageLookupByLibrary.simpleMessage("この取引をカバーするための残高が不足しています。"),
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
        "g_key_address": MessageLookupByLibrary.simpleMessage("アドレス"),
        "g_key_address_1": MessageLookupByLibrary.simpleMessage("名前を入力してください"),
        "g_key_address_2":
            MessageLookupByLibrary.simpleMessage("アドレスを入力してください"),
        "g_key_address_3":
            MessageLookupByLibrary.simpleMessage("コインタイプを選択してください"),
        "g_key_address_4": MessageLookupByLibrary.simpleMessage("アドレスを編集"),
        "g_key_address_5": MessageLookupByLibrary.simpleMessage("削除に成功しました"),
        "g_key_address_6": MessageLookupByLibrary.simpleMessage("コインを選択"),
        "g_key_address_7": MessageLookupByLibrary.simpleMessage("コインを検索"),
        "g_key_error_1":
            MessageLookupByLibrary.simpleMessage("レスポンスデータの解析エラー！"),
        "g_key_error_10": MessageLookupByLibrary.simpleMessage("通信エラー"),
        "g_key_error_11": MessageLookupByLibrary.simpleMessage("リクエスト構文エラー"),
        "g_key_error_12":
            MessageLookupByLibrary.simpleMessage("認証されていません。ログインしてください"),
        "g_key_error_13": MessageLookupByLibrary.simpleMessage("アクセスが拒否されました"),
        "g_key_error_1301":
            MessageLookupByLibrary.simpleMessage("アカウントまたはパスワードが正しくありません"),
        "g_key_error_14": MessageLookupByLibrary.simpleMessage("リクエストエラー"),
        "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
            "別のデバイスで既にログインしているため、強制的にログアウトされました。"),
        "g_key_error_15":
            MessageLookupByLibrary.simpleMessage("リクエストがタイムアウトしました"),
        "g_key_error_16": MessageLookupByLibrary.simpleMessage("サーバー異常"),
        "g_key_error_17":
            MessageLookupByLibrary.simpleMessage("サービスが実装されていません"),
        "g_key_error_18": MessageLookupByLibrary.simpleMessage("ゲートウェイエラー"),
        "g_key_error_19": MessageLookupByLibrary.simpleMessage("サービスが利用できません"),
        "g_key_error_20": MessageLookupByLibrary.simpleMessage("ゲートウェイタイムアウト"),
        "g_key_error_21":
            MessageLookupByLibrary.simpleMessage("HTTPバージョンがサポートされていません"),
        "g_key_error_22":
            MessageLookupByLibrary.simpleMessage("リクエストが失敗しました。エラーコード："),
        "g_key_error_23":
            MessageLookupByLibrary.simpleMessage("システムがビジー状態です。後でもう一度お試しください"),
        "g_key_error_24": MessageLookupByLibrary.simpleMessage("リクエスト頻度が高すぎます"),
        "g_key_error_25": MessageLookupByLibrary.simpleMessage("デコードに失敗しました"),
        "g_key_error_26":
            MessageLookupByLibrary.simpleMessage("取引は既にチェーン上にあります"),
        "g_key_error_27": MessageLookupByLibrary.simpleMessage("証明書の設定エラー！"),
        "g_key_error_28":
            MessageLookupByLibrary.simpleMessage("ステータスコードの設定エラー！"),
        "g_key_error_3": MessageLookupByLibrary.simpleMessage("不明なエラー！"),
        "g_key_error_4": MessageLookupByLibrary.simpleMessage(
            "ネットワーク接続がタイムアウトしました。ネットワーク設定を確認してください！"),
        "g_key_error_5": MessageLookupByLibrary.simpleMessage(
            "サーバーに異常が発生しました。後でもう一度お試しください！"),
        "g_key_error_8": MessageLookupByLibrary.simpleMessage(
            "リクエストがキャンセルされました。再度リクエストしてください！"),
        "g_key_ex_keystore":
            MessageLookupByLibrary.simpleMessage("キーストアをエクスポート"),
        "g_key_ex_keystore_1":
            MessageLookupByLibrary.simpleMessage("バックアップのヒント"),
        "g_key_ex_keystore_10":
            MessageLookupByLibrary.simpleMessage("パスワード管理ツールを使用して保存してください。"),
        "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("コピーしました"),
        "g_key_ex_keystore_12":
            MessageLookupByLibrary.simpleMessage("コピーがキャンセルされました"),
        "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage("IDウォレット"),
        "g_key_ex_keystore_15":
            MessageLookupByLibrary.simpleMessage("暗号化された秘密鍵ファイル。"),
        "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage("インポート方法"),
        "g_key_ex_keystore_17":
            MessageLookupByLibrary.simpleMessage("キーストアファイル"),
        "g_key_ex_keystore_18":
            MessageLookupByLibrary.simpleMessage("キーストア情報を入力してください。"),
        "g_key_ex_keystore_19":
            MessageLookupByLibrary.simpleMessage("秘密鍵をエクスポート"),
        "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
            "キーストアとパスワードを取得すると、所持者はウォレット資産を完全に管理できます。"),
        "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
            "注意深く記録し、安全な場所に保管してください。複数の物理コピーを保持することが最も安全な保管方法です。"),
        "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
            "秘密鍵を紛失した場合、回復できません。物理的にバックアップし、安全に保管してください。"),
        "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage("オフラインで保存"),
        "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
            "安全でないメール、メモ帳、ネットワークドライブ、チャットソフトウェアには保存しないでください。"),
        "g_key_ex_keystore_7":
            MessageLookupByLibrary.simpleMessage("ネットワーク転送を使用してください"),
        "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
            "ネットワークツールを通じて転送してください。ハッカーに取得されると、取り返しのつかない経済的損失が発生します"),
        "g_key_ex_keystore_9":
            MessageLookupByLibrary.simpleMessage("ツールを使用して保存"),
        "g_key_feedback": MessageLookupByLibrary.simpleMessage("フィードバック"),
        "g_key_feedback_1":
            MessageLookupByLibrary.simpleMessage("フィードバック情報を入力してください"),
        "g_key_feedback_2":
            MessageLookupByLibrary.simpleMessage("未アップロードの添付ファイルがあります"),
        "g_key_feedback_3": MessageLookupByLibrary.simpleMessage("送信に失敗しました"),
        "g_key_feedback_4": MessageLookupByLibrary.simpleMessage("送信に成功しました"),
        "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("添付ファイル"),
        "g_key_feedback_6":
            MessageLookupByLibrary.simpleMessage("最大5つの添付ファイル、各添付ファイルは100MB以下"),
        "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("失敗"),
        "g_key_feedback_8": MessageLookupByLibrary.simpleMessage("クリックして再試行"),
        "g_key_feedback_9": MessageLookupByLibrary.simpleMessage("ログインしてください"),
        "g_key_keystore_19":
            MessageLookupByLibrary.simpleMessage("現在の通貨ウォレットは既に存在します。"),
        "g_key_keystore_21":
            MessageLookupByLibrary.simpleMessage("キーストアを読み取れませんでした"),
        "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("キーストア"),
        "g_key_login": MessageLookupByLibrary.simpleMessage("ログイン"),
        "g_key_logout": MessageLookupByLibrary.simpleMessage("ログアウト"),
        "g_key_logout_sure":
            MessageLookupByLibrary.simpleMessage("アプリを終了してもよろしいですか？"),
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
        "g_key_mnemonic":
            MessageLookupByLibrary.simpleMessage("シードフレーズを入力してください"),
        "g_key_nft_141": MessageLookupByLibrary.simpleMessage("合計"),
        "g_key_nft_16": MessageLookupByLibrary.simpleMessage("カメラ"),
        "g_key_nft_17": MessageLookupByLibrary.simpleMessage("写真を選択"),
        "g_key_nft_18": MessageLookupByLibrary.simpleMessage("コンテンツ"),
        "g_key_nft_2": MessageLookupByLibrary.simpleMessage("名前"),
        "g_key_nft_220": MessageLookupByLibrary.simpleMessage("戻る"),
        "g_key_nft_41": MessageLookupByLibrary.simpleMessage("取引が送信されました"),
        "g_key_nft_47": MessageLookupByLibrary.simpleMessage("動画を選択"),
        "g_key_personal_1": MessageLookupByLibrary.simpleMessage("ギャラリーから選択"),
        "g_key_share_code": MessageLookupByLibrary.simpleMessage("QRコードを共有"),
        "g_key_share_link": MessageLookupByLibrary.simpleMessage("リンクを共有"),
        "g_key_share_method": MessageLookupByLibrary.simpleMessage("共有方法"),
        "g_key_squad": MessageLookupByLibrary.simpleMessage("チャット"),
        "g_key_squad_k11":
            MessageLookupByLibrary.simpleMessage("ファイルが大きすぎてアップロードできません"),
        "g_key_squad_k15": m10,
        "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("連絡先を追加"),
        "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("連絡先"),
        "g_key_squad_k25": MessageLookupByLibrary.simpleMessage("メールで検索"),
        "g_key_t_1": MessageLookupByLibrary.simpleMessage("完了"),
        "g_key_t_15": MessageLookupByLibrary.simpleMessage("ガス価格"),
        "g_key_t_16": MessageLookupByLibrary.simpleMessage("最大ガス手数料"),
        "g_key_t_17": MessageLookupByLibrary.simpleMessage("ガスあたりの最大手数料"),
        "g_key_t_2": MessageLookupByLibrary.simpleMessage("保留中"),
        "g_key_t_29": m11,
        "g_key_t_3": MessageLookupByLibrary.simpleMessage("失敗"),
        "g_key_t_30": MessageLookupByLibrary.simpleMessage("マイナー手数料"),
        "g_key_t_31": MessageLookupByLibrary.simpleMessage("続行"),
        "g_key_t_32": MessageLookupByLibrary.simpleMessage("ウォレットパスワード"),
        "g_key_t_33":
            MessageLookupByLibrary.simpleMessage("ウォレットパスワードを入力してください"),
        "g_key_t_34":
            MessageLookupByLibrary.simpleMessage("ウォレットパスワードが間違っています"),
        "g_key_t_35":
            MessageLookupByLibrary.simpleMessage("ウォレットパスワードを入力してください"),
        "g_key_t_36": MessageLookupByLibrary.simpleMessage("ガス手数料率"),
        "g_key_t_37": MessageLookupByLibrary.simpleMessage("最新ブロックのガス手数料率の平均"),
        "g_key_t_4": MessageLookupByLibrary.simpleMessage("送金"),
        "g_key_t_43":
            MessageLookupByLibrary.simpleMessage("0より大きい整数を入力してください。"),
        "g_key_t_44": MessageLookupByLibrary.simpleMessage("データの取得に失敗しました"),
        "g_key_t_45": m12,
        "g_key_t_46": MessageLookupByLibrary.simpleMessage("受取アドレスアカウントを確認"),
        "g_key_t_47": MessageLookupByLibrary.simpleMessage("検索"),
        "g_key_t_49": MessageLookupByLibrary.simpleMessage("アカウントなし"),
        "g_key_t_5": MessageLookupByLibrary.simpleMessage("入金"),
        "g_key_t_50": MessageLookupByLibrary.simpleMessage("無効なアドレス"),
        "g_key_t_51": MessageLookupByLibrary.simpleMessage("アカウント確認成功"),
        "g_key_t_52": m13,
        "g_key_t_54": MessageLookupByLibrary.simpleMessage(
            "受取アドレスにはアカウントがなく、初回送金には最低10XRPが必要です"),
        "g_key_t_6": MessageLookupByLibrary.simpleMessage("使用ガス"),
        "g_key_t_7": MessageLookupByLibrary.simpleMessage("ガス"),
        "g_key_tran_1": MessageLookupByLibrary.simpleMessage("取引履歴"),
        "g_key_tran_4": MessageLookupByLibrary.simpleMessage("取引詳細"),
        "g_key_tran_6":
            MessageLookupByLibrary.simpleMessage("取引レシートは履歴でご確認ください"),
        "g_key_tran_7": MessageLookupByLibrary.simpleMessage("支払い金額"),
        "g_key_tran_8": MessageLookupByLibrary.simpleMessage("受取金額"),
        "g_key_u_10": MessageLookupByLibrary.simpleMessage("NFTタイプ"),
        "g_key_u_11": MessageLookupByLibrary.simpleMessage("フォロワー"),
        "g_key_u_12": MessageLookupByLibrary.simpleMessage("ユーザータイプ"),
        "g_key_u_13": MessageLookupByLibrary.simpleMessage("ウェブサイト"),
        "g_key_u_14": MessageLookupByLibrary.simpleMessage("製品リンク"),
        "g_key_u_15": MessageLookupByLibrary.simpleMessage("メディアプラットフォーム"),
        "g_key_u_16": MessageLookupByLibrary.simpleMessage("ウォレットアドレス"),
        "g_key_u_2": MessageLookupByLibrary.simpleMessage("ニックネーム"),
        "g_key_u_23":
            MessageLookupByLibrary.simpleMessage("アバターのアップロードに失敗しました"),
        "g_key_u_3": MessageLookupByLibrary.simpleMessage("説明"),
        "g_key_u_5": MessageLookupByLibrary.simpleMessage("アーティスト情報"),
        "g_key_u_6": MessageLookupByLibrary.simpleMessage("あなたはアーティストではありません"),
        "g_key_u_7": MessageLookupByLibrary.simpleMessage(
            "こちらをクリックしてアーティストになるための申請をしてください"),
        "g_key_u_8": MessageLookupByLibrary.simpleMessage("名前"),
        "g_key_u_9": MessageLookupByLibrary.simpleMessage("収益"),
        "g_key_user_p1": MessageLookupByLibrary.simpleMessage("以下を読み、同意しました："),
        "g_key_user_p2": MessageLookupByLibrary.simpleMessage("利用規約"),
        "g_key_user_p3":
            MessageLookupByLibrary.simpleMessage("プライバシーポリシーおよび個人情報収集に関する声明"),
        "g_key_v_k1": MessageLookupByLibrary.simpleMessage("最新バージョンが見つかりました"),
        "g_key_v_k2": MessageLookupByLibrary.simpleMessage("今すぐアップデート"),
        "g_key_v_k3": MessageLookupByLibrary.simpleMessage("新しいバージョンが見つかりました"),
        "g_key_v_k4": MessageLookupByLibrary.simpleMessage("既に最新バージョンです"),
        "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage("シードフレーズを表示"),
        "g_key_wallet_c11":
            MessageLookupByLibrary.simpleMessage("シードフレーズを記録し、安全に保管してください。"),
        "g_key_wallet_c12":
            MessageLookupByLibrary.simpleMessage("シードフレーズを再度入力してください。"),
        "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("アカウントをインポート"),
        "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("アカウントを作成"),
        "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("設定が完了しました！"),
        "g_key_wallet_c16":
            MessageLookupByLibrary.simpleMessage("ウォレットを存分にお楽しみください。"),
        "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("はじめる"),
        "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("今はスキップ"),
        "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
            "シードフレーズのバックアップは今すぐスキップでき、必要な場合はいつでも設定で再度行えます。"),
        "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage("直接作成"),
        "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage("作成に成功しました"),
        "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
            "ウォレットの詳細を確認したり、キーストアをエクスポートしたい場合は、サイドバー > ウォレット管理 にアクセスしてください"),
        "g_key_wallet_c24":
            MessageLookupByLibrary.simpleMessage("キーストアをエクスポート"),
        "g_key_wallet_c25":
            MessageLookupByLibrary.simpleMessage("ウォレットをバックアップして安全に保護"),
        "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
            "キーストアはセキュリティ証明書と関連する秘密鍵のリポジトリです。"),
        "g_key_wallet_c27":
            MessageLookupByLibrary.simpleMessage("ステップ1：ウォレット管理に移動。"),
        "g_key_wallet_c28":
            MessageLookupByLibrary.simpleMessage("ステップ2：ウォレットアドレスを選択。"),
        "g_key_wallet_c29":
            MessageLookupByLibrary.simpleMessage("ステップ3：キーストアをエクスポートを押す。"),
        "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage("ウォレット管理へ"),
        "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage("ホームページに戻る"),
        "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("ウォレットを追加"),
        "g_key_wallet_c33":
            MessageLookupByLibrary.simpleMessage("シードフレーズを使用してウォレットを作成。"),
        "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage("ウォレット名を入力"),
        "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
            "ウォレットのシードフレーズがバックアップされていません！"),
        "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("今すぐバックアップ"),
        "g_key_wallet_c37":
            MessageLookupByLibrary.simpleMessage("ウォレットパスワードを設定"),
        "g_key_wallet_c38":
            MessageLookupByLibrary.simpleMessage("ウォレットをバックアップ"),
        "g_key_wallet_c39":
            MessageLookupByLibrary.simpleMessage("以下のシードフレーズを記録してください"),
        "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("開始"),
        "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
            "インターネット接続されたデバイスは情報を露出させる可能性があります。シードフレーズを書き留めて安全に保管することをお勧めします。"),
        "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
            "警告：シードフレーズを誰にも開示しないでください。N42Walletがこの情報をお尋ねすることはありません。細心の注意を払い、オフラインで安全に保管してください。シードフレーズが露出すると、すべての資産を失い、回復できなくなる可能性があります。"),
        "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
            "警告：シードフレーズはウォレット資産を回復する唯一の方法です。"),
        "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("次のステップ"),
        "g_key_wallet_c44":
            MessageLookupByLibrary.simpleMessage("クリックしてシードフレーズを表示"),
        "g_key_wallet_c45":
            MessageLookupByLibrary.simpleMessage("周囲に他の人やカメラがないことを確認してください"),
        "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage("シードフレーズを確認"),
        "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage("ウォレット情報"),
        "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("ウォレット名"),
        "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
            "まずウォレットのシードフレーズをバックアップしてください！"),
        "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage("シードフレーズを確認"),
        "g_key_wallet_c7":
            MessageLookupByLibrary.simpleMessage("シードフレーズを入力してください。"),
        "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("フレーズを設定"),
        "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
            "シードフレーズを記録し、安全に保管してください。暗号資産ウォレットのインポートまたは復元に必要です。"),
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
        "g_key_wallet_m1": m14,
        "g_key_wallet_m11":
            MessageLookupByLibrary.simpleMessage("本当にアカウントを削除しますか？"),
        "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage("ログアウトを確認"),
        "g_key_wallet_m17":
            MessageLookupByLibrary.simpleMessage("Google認証コードを入力してください。"),
        "g_key_wallet_m19": m15,
        "g_key_wallet_m2":
            MessageLookupByLibrary.simpleMessage("現在のトークンが追加されていません。"),
        "g_key_wallet_m21":
            MessageLookupByLibrary.simpleMessage("シードフレーズをスペースで区切って入力してください"),
        "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("ウォレットをインポート"),
        "g_key_wallet_m3": m16,
        "g_key_wallet_m4":
            MessageLookupByLibrary.simpleMessage("現在のトークン残高が不足しています。"),
        "g_key_wallet_m5": m17,
        "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("署名エラー"),
        "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage("アカウント削除"),
        "g_key_wallet_m9":
            MessageLookupByLibrary.simpleMessage("メール認証コードを入力してください。"),
        "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage("ウォレット管理"),
        "g_key_xml_0": MessageLookupByLibrary.simpleMessage("予約済み"),
        "g_key_xml_1": MessageLookupByLibrary.simpleMessage("基本準備金"),
        "g_key_xml_11": m18,
        "g_key_xml_2": MessageLookupByLibrary.simpleMessage("増分準備金"),
        "g_key_xml_22": m19,
        "g_key_xml_3": MessageLookupByLibrary.simpleMessage("所有オブジェクト数"),
        "g_key_xml_33": m20,
        "g_key_xml_4": MessageLookupByLibrary.simpleMessage("合計準備金額の計算方法"),
        "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
            "合計準備金 = 基本準備金 +（所有オブジェクト数 × 増分準備金）"),
        "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch IDとFace ID"),
        "g_lock_key10": MessageLookupByLibrary.simpleMessage("現在のパスワード"),
        "g_lock_key11": MessageLookupByLibrary.simpleMessage("新しいパスワード"),
        "g_lock_key12": MessageLookupByLibrary.simpleMessage("新しいパスワードを確認"),
        "g_lock_key13": MessageLookupByLibrary.simpleMessage("6桁の数字"),
        "g_lock_key15": MessageLookupByLibrary.simpleMessage("パスワードと生体認証"),
        "g_lock_key16": MessageLookupByLibrary.simpleMessage("パターンパスワード"),
        "g_lock_key17": MessageLookupByLibrary.simpleMessage("パターンパスコードを設定"),
        "g_lock_key18": MessageLookupByLibrary.simpleMessage(
            "アカウントのセキュリティのため、グループパスワードを設定してください"),
        "g_lock_key19": MessageLookupByLibrary.simpleMessage("2回目のパターンパスワード描画"),
        "g_lock_key20": MessageLookupByLibrary.simpleMessage("パターンパスワードを描画"),
        "g_lock_key21": m21,
        "g_lock_key22": MessageLookupByLibrary.simpleMessage("パターンパスワードをリセット"),
        "g_lock_key23": MessageLookupByLibrary.simpleMessage(
            "入力エラーが多すぎます。パスワードをリセットしてください"),
        "g_lock_key24":
            MessageLookupByLibrary.simpleMessage("ウォレットパスワードを追加しますか？"),
        "g_lock_key25": m22,
        "g_lock_key3": MessageLookupByLibrary.simpleMessage("ロック画面ページ"),
        "g_lock_key4": MessageLookupByLibrary.simpleMessage("自動ロック"),
        "g_lock_key5": MessageLookupByLibrary.simpleMessage("成功"),
        "g_lock_key6": MessageLookupByLibrary.simpleMessage("失敗"),
        "g_lock_key7": MessageLookupByLibrary.simpleMessage("生体認証が有効になっていません"),
        "g_lock_key8": MessageLookupByLibrary.simpleMessage("生体認証を追加しますか？"),
        "g_lock_key9": MessageLookupByLibrary.simpleMessage("パスワードをリセット"),
        "g_mining_key20": MessageLookupByLibrary.simpleMessage("Nをアンロックしますか？"),
        "g_mining_key31": MessageLookupByLibrary.simpleMessage("クラウド認証アクティビティ"),
        "g_mining_key46":
            MessageLookupByLibrary.simpleMessage("セットアップには少量のガスが必要です。"),
        "g_mining_key60": MessageLookupByLibrary.simpleMessage(
            "N42Walletのグループノードに正常に参加しました。リンクを共有して友達を招待し、ノードをアクティブ化して認証を開始しましょう！"),
        "g_mining_key61": MessageLookupByLibrary.simpleMessage("友達に共有"),
        "g_mining_key62": MessageLookupByLibrary.simpleMessage("続行"),
        "g_mining_key63": m23,
        "g_mining_key73": m24,
        "g_mining_key74": MessageLookupByLibrary.simpleMessage(
            "@N42Walletでノードをセットアップし、モバイルデバイスで認証を開始しました！ぜひ参加してください。分散化された未来はモバイルです！"),
        "g_mining_key76": m25,
        "g_mining_key86":
            MessageLookupByLibrary.simpleMessage("768秒後に引き換え可能です。"),
        "g_mining_key87":
            MessageLookupByLibrary.simpleMessage("それ以前のリクエストは処理されません。"),
        "g_mining_key_10": MessageLookupByLibrary.simpleMessage("本日の報酬"),
        "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
            "以下のデータを重要な鍵として扱ってください。すぐにコピーして信頼できる場所にバックアップすることをお勧めします。"),
        "g_mining_key_101": MessageLookupByLibrary.simpleMessage("データをコピー"),
        "g_mining_key_102": MessageLookupByLibrary.simpleMessage("非アクティブ"),
        "g_mining_key_103": MessageLookupByLibrary.simpleMessage("バリデーター一覧"),
        "g_mining_key_104": MessageLookupByLibrary.simpleMessage("インポート成功"),
        "g_mining_key_105":
            MessageLookupByLibrary.simpleMessage("暗号化データを空にすることはできません！"),
        "g_mining_key_106":
            MessageLookupByLibrary.simpleMessage("パスワードを空にすることはできません！"),
        "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
            "復号に失敗しました。パスワードが正しいか確認してください！"),
        "g_mining_key_108":
            MessageLookupByLibrary.simpleMessage("サポートされていない暗号化データ形式です！"),
        "g_mining_key_109": m26,
        "g_mining_key_11": MessageLookupByLibrary.simpleMessage("昨日の報酬"),
        "g_mining_key_110": MessageLookupByLibrary.simpleMessage("暗号化データ"),
        "g_mining_key_111": MessageLookupByLibrary.simpleMessage("ファイルをインポート"),
        "g_mining_key_112":
            MessageLookupByLibrary.simpleMessage("暗号化データを入力してください。"),
        "g_mining_key_113": MessageLookupByLibrary.simpleMessage("インポート中..."),
        "g_mining_key_114": MessageLookupByLibrary.simpleMessage("確認"),
        "g_mining_key_115":
            MessageLookupByLibrary.simpleMessage("引き換えには時間がかかります。しばらくお待ちください！"),
        "g_mining_key_116": m27,
        "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
            "報酬は毎日蓄積され、約0.5 Nに達した時にのみNウォレットに送信されます。"),
        "g_mining_key_13": MessageLookupByLibrary.simpleMessage("累計報酬"),
        "g_mining_key_14": MessageLookupByLibrary.simpleMessage("マイニング価値"),
        "g_mining_key_15":
            MessageLookupByLibrary.simpleMessage("Nの市場価格 × 累計N報酬に基づいて計算されます。"),
        "g_mining_key_23": MessageLookupByLibrary.simpleMessage("利益回数"),
        "g_mining_key_31": MessageLookupByLibrary.simpleMessage("プランを選択"),
        "g_mining_key_32":
            MessageLookupByLibrary.simpleMessage("アンロック期間：いつでもアンロック可能"),
        "g_mining_key_33": MessageLookupByLibrary.simpleMessage("年間最大報酬"),
        "g_mining_key_34": MessageLookupByLibrary.simpleMessage("報酬配布"),
        "g_mining_key_35": MessageLookupByLibrary.simpleMessage("1日の上限"),
        "g_mining_key_36": MessageLookupByLibrary.simpleMessage("速度"),
        "g_mining_key_37": MessageLookupByLibrary.simpleMessage("認証プラン"),
        "g_mining_key_38": MessageLookupByLibrary.simpleMessage("支払い方法を選択"),
        "g_mining_key_39": MessageLookupByLibrary.simpleMessage("支払い方法"),
        "g_mining_key_40": MessageLookupByLibrary.simpleMessage("Nで支払う"),
        "g_mining_key_42": MessageLookupByLibrary.simpleMessage("ウォレット残高"),
        "g_mining_key_43":
            MessageLookupByLibrary.simpleMessage("この取引に必要なNが不足しています"),
        "g_mining_key_47": MessageLookupByLibrary.simpleMessage("無効"),
        "g_mining_key_49": MessageLookupByLibrary.simpleMessage("詳細を見る"),
        "g_mining_key_5": MessageLookupByLibrary.simpleMessage("認証ステータス"),
        "g_mining_key_6":
            MessageLookupByLibrary.simpleMessage("Nをロックして報酬認証を開始します。"),
        "g_mining_key_62": MessageLookupByLibrary.simpleMessage("エントリー"),
        "g_mining_key_66": MessageLookupByLibrary.simpleMessage("アドバンスドノード"),
        "g_mining_key_67": MessageLookupByLibrary.simpleMessage("エントリーノード"),
        "g_mining_key_68": MessageLookupByLibrary.simpleMessage("プロノード"),
        "g_mining_key_69":
            MessageLookupByLibrary.simpleMessage("1日500ブロック〜約70分"),
        "g_mining_key_7": MessageLookupByLibrary.simpleMessage("プランを選択"),
        "g_mining_key_70":
            MessageLookupByLibrary.simpleMessage("1日100ブロック〜約15分"),
        "g_mining_key_71": m28,
        "g_mining_key_72": MessageLookupByLibrary.simpleMessage("128秒ごとにチェック"),
        "g_mining_key_73":
            MessageLookupByLibrary.simpleMessage("クラウド認証が開始されました"),
        "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
            "テストチェーンはアップグレード中のため、一時的にブロックを検証できません。"),
        "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
            "4日連続でタスクを完了しないと、報酬がなくなり、ペナルティのリスクがあります。"),
        "g_mining_key_76": MessageLookupByLibrary.simpleMessage("リスクスコア"),
        "g_mining_key_77": MessageLookupByLibrary.simpleMessage("引き換え"),
        "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
            "まずバリデーターの公開鍵と秘密鍵のペアを保存してください。"),
        "g_mining_key_79": MessageLookupByLibrary.simpleMessage("エクスポート"),
        "g_mining_key_80":
            MessageLookupByLibrary.simpleMessage("送金するための資金が不足しています。"),
        "g_mining_key_81": MessageLookupByLibrary.simpleMessage("バリデーター一覧"),
        "g_mining_key_82": MessageLookupByLibrary.simpleMessage("バリデーターをインポート"),
        "g_mining_key_83":
            MessageLookupByLibrary.simpleMessage("バリデーターは既に存在します"),
        "g_mining_key_84": MessageLookupByLibrary.simpleMessage("低リスク"),
        "g_mining_key_85": MessageLookupByLibrary.simpleMessage("中程度のリスク"),
        "g_mining_key_86": MessageLookupByLibrary.simpleMessage("過去7日間の報酬"),
        "g_mining_key_87": MessageLookupByLibrary.simpleMessage("高リスク"),
        "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
            "コントラクトを読み込み中のため、現在認証できません。しばらくお待ちください！"),
        "g_mining_key_89": MessageLookupByLibrary.simpleMessage("セキュリティのヒント"),
        "g_mining_key_9": MessageLookupByLibrary.simpleMessage("バックグラウンド認証"),
        "g_mining_key_90":
            MessageLookupByLibrary.simpleMessage("秘密鍵またはシードフレーズを安全に保管してください。"),
        "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
            "秘密鍵またはシードフレーズは、ウォレット資産にアクセスするための唯一の認証情報です。"),
        "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
            "安全な場所（紙、パスワードマネージャーなど）に保管してください。"),
        "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
            "スクリーンショットを撮ったり、インターネットにアップロードしたり、誰かと共有したりしないでください。"),
        "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
            "紛失または漏洩した場合、ウォレット資産は回復できません。"),
        "g_mining_key_95": MessageLookupByLibrary.simpleMessage("確認して保存"),
        "g_mining_key_96":
            MessageLookupByLibrary.simpleMessage("パスワードを設定して暗号化"),
        "g_mining_key_97":
            MessageLookupByLibrary.simpleMessage("暗号化パスワードを入力してください"),
        "g_mining_key_98": m29,
        "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
            "正確であることを確認するために、パスワードを再入力してください"),
        "g_notification_key_1": MessageLookupByLibrary.simpleMessage("通知"),
        "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("共有"),
        "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("紹介"),
        "g_share_v3_key_3":
            MessageLookupByLibrary.simpleMessage("友達を紹介してNトークンをゲット！"),
        "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("最大"),
        "g_share_v3_key_5":
            MessageLookupByLibrary.simpleMessage("Nがもらえます（紹介した友達が認証を開始した時）！"),
        "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("紹介方法"),
        "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("リンク"),
        "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("コード"),
        "g_swap_key_14": m30,
        "g_swap_key_15": MessageLookupByLibrary.simpleMessage("コイン価格の取得エラー。"),
        "g_swap_key_16":
            MessageLookupByLibrary.simpleMessage("続行すると、以下に同意したことになります："),
        "g_swap_key_17": MessageLookupByLibrary.simpleMessage("利用規約"),
        "g_swap_key_18": MessageLookupByLibrary.simpleMessage("完了"),
        "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
            "スワップはまもなく配布されます。しばらくお待ちください。"),
        "g_swap_key_20": m31,
        "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
            "ノード運用コスト：グループ認証 1-49 N、ベーシックノード：50 N、プレミアムノード：100 N、プロノード：500 N。"),
        "g_swap_key_22": MessageLookupByLibrary.simpleMessage("期限切れ"),
        "g_swap_key_23": MessageLookupByLibrary.simpleMessage("未払い"),
        "g_swap_key_24": MessageLookupByLibrary.simpleMessage("支払い確認中"),
        "g_swap_key_25": MessageLookupByLibrary.simpleMessage("配布待ち"),
        "g_swap_key_28": MessageLookupByLibrary.simpleMessage("スワップ概要"),
        "g_swap_key_29": MessageLookupByLibrary.simpleMessage("新残高"),
        "g_swap_key_3": MessageLookupByLibrary.simpleMessage("支払い"),
        "g_swap_key_30": MessageLookupByLibrary.simpleMessage("日付"),
        "g_swap_key_31": m32,
        "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
            "スワップは関連するチェーンエクスプローラー（Etherscan、BscScan、TRONSCAN、および当社独自のエクスプローラー）で確認できます。"),
        "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Nにスワップ"),
        "g_swap_key_35": MessageLookupByLibrary.simpleMessage("スワップ"),
        "g_swap_key_4": MessageLookupByLibrary.simpleMessage("受取"),
        "g_swap_key_5": MessageLookupByLibrary.simpleMessage("スワッププレビュー"),
        "g_swap_key_6": MessageLookupByLibrary.simpleMessage("再試行"),
        "g_token_m_key_1": m33,
        "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
            "誰でもトークンを作成できます。既存のトークンの偽バージョンを作成することも可能です。インポートする前に必ずトークンを調査してください。"),
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
        "g_token_m_key_22": m34,
        "g_token_m_key_23": m35,
        "g_token_m_key_24": m36,
        "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("トークンをインポート"),
        "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("全てのネットワーク"),
        "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("カスタムトークン"),
        "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("トークンアドレス"),
        "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("トークンシンボル"),
        "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("トークン桁数"),
        "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("インポート"),
        "g_unlock_key10": m37,
        "g_unlock_key2":
            MessageLookupByLibrary.simpleMessage("指紋または顔認証が有効になっていませんか？"),
        "g_unlock_key3": MessageLookupByLibrary.simpleMessage("パターンパスワードを描画"),
        "g_unlock_key4": m38,
        "g_unlock_key5": MessageLookupByLibrary.simpleMessage("パスワードを入力"),
        "g_unlock_key6": m39,
        "g_unlock_key7": MessageLookupByLibrary.simpleMessage("認証に失敗しました"),
        "g_unlock_key8": m40,
        "g_unlock_key9": MessageLookupByLibrary.simpleMessage("または"),
        "google_verification": MessageLookupByLibrary.simpleMessage("Google認証"),
        "google_verification_message10":
            MessageLookupByLibrary.simpleMessage("リンク"),
        "google_verification_message11":
            MessageLookupByLibrary.simpleMessage("Google認証をダウンロード"),
        "google_verification_message12":
            MessageLookupByLibrary.simpleMessage("手順"),
        "google_verification_message13":
            MessageLookupByLibrary.simpleMessage("Google認証を開きます。"),
        "google_verification_message14":
            MessageLookupByLibrary.simpleMessage("画面に6桁の認証コードが表示されます。"),
        "google_verification_message15": MessageLookupByLibrary.simpleMessage(
            "6桁のコードをコピーしてN42Walletに貼り付けます。"),
        "google_verification_message16":
            MessageLookupByLibrary.simpleMessage("すると、認証が正常にリンクされます。"),
        "google_verification_message17":
            MessageLookupByLibrary.simpleMessage("バックアップキー"),
        "google_verification_message18":
            MessageLookupByLibrary.simpleMessage("キーをGoogle認証にコピー"),
        "google_verification_message19":
            MessageLookupByLibrary.simpleMessage("Google認証コードを入力"),
        "google_verification_message20":
            MessageLookupByLibrary.simpleMessage("メール認証コードを入力"),
        "google_verification_message21": m41,
        "google_verification_message3":
            MessageLookupByLibrary.simpleMessage("Googleキーの取得に失敗しました"),
        "google_verification_message5":
            MessageLookupByLibrary.simpleMessage("二要素認証（2FA）"),
        "google_verification_message6": MessageLookupByLibrary.simpleMessage(
            "アカウントを保護するため、少なくとも1つの2FAを有効にすることをお勧めします。"),
        "google_verification_message7": MessageLookupByLibrary.simpleMessage(
            "Google認証アプリは、出金とN42Walletアカウントを保護します。"),
        "google_verification_message8":
            MessageLookupByLibrary.simpleMessage("ダウンロードとインストール"),
        "google_verification_message9": MessageLookupByLibrary.simpleMessage(
            "Google認証をダウンロードしてインストールしてください。その後、「リンク」を押してN42Walletアカウントをリンクしてください。"),
        "importantNotice": MessageLookupByLibrary.simpleMessage("重要なお知らせ"),
        "login_button_text": MessageLookupByLibrary.simpleMessage("ログイン"),
        "login_email": MessageLookupByLibrary.simpleMessage("メールアドレス"),
        "login_forgot_password":
            MessageLookupByLibrary.simpleMessage("パスワードをお忘れですか？"),
        "login_invite_code": MessageLookupByLibrary.simpleMessage("紹介コード"),
        "login_invite_code_title":
            MessageLookupByLibrary.simpleMessage("紹介コード"),
        "login_message_1":
            MessageLookupByLibrary.simpleMessage("アカウントをお持ちでないですか？"),
        "login_message_10": MessageLookupByLibrary.simpleMessage("作成に成功しました"),
        "login_message_11": MessageLookupByLibrary.simpleMessage("リセットに成功しました"),
        "login_message_2":
            MessageLookupByLibrary.simpleMessage("既にアカウントをお持ちですか？"),
        "login_message_6": MessageLookupByLibrary.simpleMessage("コード再送信まで"),
        "login_message_7":
            MessageLookupByLibrary.simpleMessage("コードの送信に成功しました"),
        "login_message_8":
            MessageLookupByLibrary.simpleMessage("メールアドレスが未登録です"),
        "login_message_9":
            MessageLookupByLibrary.simpleMessage("コードの送信に失敗しました"),
        "login_need_login":
            MessageLookupByLibrary.simpleMessage("まずログインしてください"),
        "login_password": MessageLookupByLibrary.simpleMessage("パスワード"),
        "next": MessageLookupByLibrary.simpleMessage("次へ"),
        "nicknameMessage": m42,
        "password_diff": MessageLookupByLibrary.simpleMessage("パスワードが一致しません"),
        "personalInformation": MessageLookupByLibrary.simpleMessage("プロフィール編集"),
        "photograph": MessageLookupByLibrary.simpleMessage("撮影"),
        "please_enter_code": MessageLookupByLibrary.simpleMessage("認証コードを入力"),
        "please_enter_email":
            MessageLookupByLibrary.simpleMessage("メールアドレスを入力してください"),
        "please_enter_password":
            MessageLookupByLibrary.simpleMessage("パスワードを入力してください"),
        "please_input_address":
            MessageLookupByLibrary.simpleMessage("アドレスを入力してください"),
        "repeatPassword": MessageLookupByLibrary.simpleMessage("パスワードを再入力"),
        "rest_Choose_password":
            MessageLookupByLibrary.simpleMessage("パスワードを選択（8〜18文字）"),
        "rest_Confirm_password":
            MessageLookupByLibrary.simpleMessage("パスワードを確認"),
        "rest_Enter_the_password_again":
            MessageLookupByLibrary.simpleMessage("パスワードを再入力"),
        "rest_Please_enter": MessageLookupByLibrary.simpleMessage("コードを入力"),
        "rest_Verification_code":
            MessageLookupByLibrary.simpleMessage("ワンタイムパスワード"),
        "rest_your_password":
            MessageLookupByLibrary.simpleMessage("パスワードをリセット"),
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
        "selected_user_protocol":
            MessageLookupByLibrary.simpleMessage("利用規約を読み、確認してください"),
        "verification": MessageLookupByLibrary.simpleMessage("確認"),
        "w_item_1":
            MessageLookupByLibrary.simpleMessage("シードフレーズを紛失すると、資金は永久に失われます。"),
        "w_item_2": MessageLookupByLibrary.simpleMessage(
            "シードフレーズを誰かに明かしたり共有すると、資金が盗まれる可能性があります。"),
        "w_item_3":
            MessageLookupByLibrary.simpleMessage("シードフレーズを安全に保管するのは私の責任です。"),
        "w_key_12": MessageLookupByLibrary.simpleMessage("シードフレーズが正しくありません。"),
        "w_key_8": MessageLookupByLibrary.simpleMessage(
            "インポートしたいウォレットのシードフレーズを入力してください。")
      };
}

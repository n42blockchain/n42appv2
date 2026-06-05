// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_TW locale. All the
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
  String get localeName => 'zh_TW';

  static String m0(deviceName, os) =>
      "您的帳號剛剛登入 ${deviceName} (${os})。如果這不是您本人所為，我們建議您更改密碼。";

  static String m1(price) => "目前價格：\$${price}";

  static String m2(symbol) => "價格提醒 · ${symbol}";

  static String m3(s) => "${s} 秒後重新發送";

  static String m4(message) => "購買失敗：${message}";

  static String m5(productId) => "購買成功：${productId}";

  static String m6(productId) => "已恢復購買：${productId}";

  static String m7(value) => "金額大於 ${value}。";

  static String m8(value) => "錢包已存在，錢包名稱為“${value}”";

  static String m9(value) => "輸入超過 ${value} 的金額。";

  static String m10(value) => "第 ${value} 行的位址重複";

  static String m11(value) => "餘額不足：總金額將超過可用的${value}";

  static String m12(value) => "第 ${value} 行位址無效";

  static String m13(value) => "第 ${value} 行的金額無效";

  static String m14(value) => "最多 ${value} 個收件人";

  static String m15(token) => "批准 ${token} 繼續";

  static String m16(impact) => "高價影響 (${impact})！謹慎行事。";

  static String m17(secs) => "報價將在 ${secs} 秒後過期";

  static String m18(value) => "賺取高達 ${value}% APY";

  static String m19(value) => "每 ${value} 秒自動刷新";

  static String m20(address) => "已新增帳戶 ${address}";

  static String m21(address, network) =>
      "您想追蹤這個硬體錢包帳戶嗎？\n\n地址：${address}\n網路：${network}";

  static String m22(app) => "目前應用程式：${app}";

  static String m23(days) => "${days} 天前";

  static String m24(value) => "匯入帳戶失敗：${value}";

  static String m25(date) => "上次連線：${date}";

  static String m26(app) => "確保 ${app} 應用在您的 Ledger 上開啟";

  static String m27(name) => "您確定要從已儲存的裝置中刪除「${name}」嗎？";

  static String m28(value) => "預計。氣體：~${value} 單位";

  static String m29(reason) => "原因：${reason}";

  static String m30(value) => "${value}d 解除綁定";

  static String m31(value) => "剩餘 ${value} 天";

  static String m32(value) => "取消質押需要 ${value} 天。在此期間您的代幣將被鎖定。";

  static String m33(value) => "您沒有足夠的“${value}”";

  static String m34(value) => "無法取得「${value}」帳戶";

  static String m35(value) => "首次轉帳最低需要 ${value} XRP";

  static String m36(count) => "新增 (${count})";

  static String m37(count) =>
      "${Intl.plural(count, one: '偵測到 1 個新代幣', other: '偵測到 ${count} 個新代幣')}，點按查看";

  static String m38(value) => "未加入${value}鏈。";

  static String m39(value) => "${value} 有未完成的交易，請稍後重試。";

  static String m40(value) => "找不到 ${value} 的位址。";

  static String m41(value) => "${value} 餘額不足。";

  static String m42(value, value1) =>
      "每個 XRP 帳戶必須保留 ${value} XRP（${value1} 下降）作為基線，該基線不能被花費。";

  static String m43(value, value1) =>
      "對於帳戶擁有的每個對象，${value} XRP（${value1} 掉落）都會加入到儲備中。";

  static String m44(value, value1) =>
      "該帳戶擁有 ${value} 對象，這表示額外保留了 ${value1} XRP。";

  static String m45(value) => "手勢圖案輸入錯誤，還剩 ${value} 次機會";

  static String m46(value) => "手勢圖案輸入錯誤，還剩 ${value} 次機會";

  static String m47(value) => "您已成功設定 ${value}，並將開始使用 N42Wallet 進行驗證！";

  static String m48(value) =>
      "加入我在 @N42Wallet 上的 ${value} 群組，成為第 1 層鏈的早期礦工，並在您的手機上獲取加密貨幣！";

  static String m49(value, value1) => "您確定要鎖定 ${value} N 直到 ${value1} 來執行節點嗎？";

  static String m50(value) => "匯入失敗：${value}";

  static String m51(value) => "需要至少 ${value} 的質押餘額才能獲得獎勵。";

  static String m52(value, value1) => "${value} N / 每開採 ${value1} 個區塊";

  static String m53(value) => "必須是 ${value} 個字符";

  static String m54(n) => "${n} 分鐘";

  static String m55(n) => "結果 ${n}";

  static String m56(value) => "${value} 餘額不足。";

  static String m57(value) => "${value} 即將轉入...";

  static String m58(value) =>
      "在 App 內兌換的 ${value} 將很快發放到您的錢包，且無法透過此流程出售。它可用於運行節點。";

  static String m59(value) => "最大 ${value} 個字符";

  static String m60(value) => "已支援${value}鏈APP！";

  static String m61(value) => "已支援${value}鏈APP，是否要新增？";

  static String m62(value) => "${value}地址測試連結失敗！";

  static String m63(value) => "0~${value} 個字符";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("編輯"),
    "Verification": MessageLookupByLibrary.simpleMessage("確認"),
    "address_Information": MessageLookupByLibrary.simpleMessage("地址資訊"),
    "copy": MessageLookupByLibrary.simpleMessage("複製成功"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("複製地址"),
    "descO": MessageLookupByLibrary.simpleMessage("描述（可選）"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "更改密碼",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("知道了"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage("新裝置登入"),
    "file": MessageLookupByLibrary.simpleMessage("文件"),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("上面 ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("下降如下↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage("價格時提醒我"),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage("啟用此警報"),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "請輸入大於 0 的有效價格",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("消除"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("設定警報"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage("目標價（美元）"),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage("更新提醒"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "代幣只能在同一網路內發送。從其他網路發送可能會導致遺失。",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage("掃描接收"),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage("請輸入網址"),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("輸入描述"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("瀏覽器"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage("清除瀏覽器快取"),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage("自動連接DApp"),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("全部關閉"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("完成"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("歷史"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage("清除所有歷史記錄"),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage("清除所有瀏覽記錄？"),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage("歷史記錄已清除"),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("今天"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("昨天"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("發現 DApp"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("受歡迎的"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("去中心化金融"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("橋"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("書籤"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("工具"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage("尚未加書籤"),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("書籤"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("名稱"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage("請輸入名稱"),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("網址"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("描述"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("同意"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage("該訊息已被刪除"),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("交易"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("連接"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("可用網路"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("訊息簽名"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("連接中"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage("正在配對，請稍候。"),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("斷開"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("拒絕"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage("被阻止"),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("警告"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("安全的"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage("已驗證"),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("重新發送驗證碼"),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage("生物辨識掃描提示"),
    "g_face_10": MessageLookupByLibrary.simpleMessage("掃描您的指紋或臉部進行身份驗證。"),
    "g_face_3": MessageLookupByLibrary.simpleMessage("提示"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("設定"),
    "g_face_7": MessageLookupByLibrary.simpleMessage("掃描您的臉部或指紋以繼續。"),
    "g_face_8": MessageLookupByLibrary.simpleMessage("返回"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage("Google 身份驗證器"),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "使用 Google Authenticator App 掃描二維碼",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage("或手動輸入金鑰："),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage("輸入 6 位驗證碼"),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "開啟後，每次發起轉帳時需透過 Google 驗證器進行身份驗證。",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage("驗證碼錯誤，請重試"),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "尚未綁定 Google 驗證器",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage("綁定成功"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("個人資料"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("訊息"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("確認"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("邀請朋友"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("已取消"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage("請檢查網路連線後重試"),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage("暫無可購買商品"),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage("恢復購買"),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage("正在恢復購買…"),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("重試"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage("應用商店暫不可用"),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("購買"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("刪除失敗！"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Gas 限額"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("沒有更多了"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("載入中"),
    "g_key_108": MessageLookupByLibrary.simpleMessage("地址簿"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("匯入錢包"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("管理"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("新增地址"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("刪除"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("儲存"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("複製"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("建立/匯入錢包"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("主題"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("系統"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("淺色"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("深色"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("錢包列表"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("暫無資料"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("金額無效"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("主錢包"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("交易成功"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("密碼錯誤"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("測試網"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("主網"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("系統語言"),
    "g_key_15": MessageLookupByLibrary.simpleMessage("設為主錢包"),
    "g_key_155": MessageLookupByLibrary.simpleMessage("錢包地址"),
    "g_key_156": MessageLookupByLibrary.simpleMessage("掃描以複製地址"),
    "g_key_159": MessageLookupByLibrary.simpleMessage("新增"),
    "g_key_16": MessageLookupByLibrary.simpleMessage("選擇驗證錢包"),
    "g_key_163": MessageLookupByLibrary.simpleMessage("代號"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("貼上"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("選擇鏈"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("交易失敗"),
    "g_key_179": MessageLookupByLibrary.simpleMessage("這是我的錢包地址"),
    "g_key_181": MessageLookupByLibrary.simpleMessage("其他"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("已成功儲存"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("成功"),
    "g_key_192": MessageLookupByLibrary.simpleMessage("確定要刪除此錢包嗎？"),
    "g_key_193": MessageLookupByLibrary.simpleMessage("啟用"),
    "g_key_195": MessageLookupByLibrary.simpleMessage("沒有存取相機的權限。"),
    "g_key_196": MessageLookupByLibrary.simpleMessage("區塊瀏覽器"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("最大"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("資產"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("帳本是空的！"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("交易概覽"),
    "g_key_203": MessageLookupByLibrary.simpleMessage("連結錯誤，請重新掃描 QR Code。"),
    "g_key_206": MessageLookupByLibrary.simpleMessage("修改密碼"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("舊密碼"),
    "g_key_208": MessageLookupByLibrary.simpleMessage("正在同步餘額..."),
    "g_key_209": MessageLookupByLibrary.simpleMessage("私鑰"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("請輸入錢包密碼"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("私鑰錯誤"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("市集資訊"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage("密碼不符。"),
    "g_key_29": MessageLookupByLibrary.simpleMessage("餘額"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("添加失敗！"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("接收"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("轉帳"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("到"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("掃描QR Code"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("輸入錢包位址"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("可用餘額"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("數量"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage("可用餘額不足，無法支付此交易。"),
    "g_key_48": MessageLookupByLibrary.simpleMessage("發送"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("加載失敗！"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("錢包"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("建立"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("從"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("確認"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("取消"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("所有代幣"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("設定"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage("帳戶建立成功"),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage("帳戶詳情"),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage("帳戶名稱"),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage("輸入帳號名"),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage("帳戶類型"),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("啟用"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "新增您的第一個操作",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage("新增操作"),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "正在計算地址...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "無法計算地址。請再試一次。",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("核准"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("批次"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage("原子執行"),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage("一次執行多個操作"),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "在單一操作中發送多個交易",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage("批次執行失敗"),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "沒有儲存的模板",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage("批量操作"),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage("節省汽油"),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "另存為模板",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "正在提交...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage("批量提交成功"),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "載入模板",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "模板名稱",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "輸入模板名稱",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "模板已儲存",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage("範本"),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage("大量交易"),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "批准並交換一筆交易－不再需要兩步驟確認",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "一鍵批次操作",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "使用 ERC-20 代幣而非 ETH 贊助交易或支付費用",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "使用任何代幣支付 Gas",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "如果您遺失私鑰，可以透過可信任聯絡人恢復存取權限",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "社會復健",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "支援無gas交易的模組化ERC-7579智慧帳戶",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("經過"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("鏈"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("鏈號"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("改變"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage("檢查狀態"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("即將推出"),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "這是一個反事實地址。它將部署在您的第一筆交易上。",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage("建立智慧帳戶"),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "建立您的第一個智慧型帳戶",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage("建立工作階段金鑰"),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("已建立"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("風俗"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "帳戶將在您的第一筆交易時自動部署",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("已部署"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("正在部署..."),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "部署將在您的第一筆交易時自動進行。",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "體驗具有增強功能的下一代以太坊帳戶",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("細節"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "混合 EOA/智慧帳戶 - 無需部署",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("錯誤"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage("估計氣體"),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage("執行批次"),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("已到期"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("過期"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("工廠"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("自由的"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Gas 估算失敗，使用預設值",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("瓦斯支付"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Gas 支付選項",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage("氣體贊助"),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("無氣"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "無 Gas 交易和批量操作",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "具有 ZeroDev 插件支援的模組化帳戶",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("標籤"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage("上次活動"),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage("我的智慧帳戶"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage("尚無智慧帳戶"),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "沒有符合您的篩選條件的帳戶",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage("未新增任何操作"),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "沒有工作階段金鑰",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage("未部署"),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "建立智慧帳戶（免費，無需 ETH）",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "為其提供資金 — 接收任何 EVM 代幣",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "與 Paymaster 進行無 Gas 交易",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("營運"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("擁有者"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "用代幣支付gas",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "用你的 ETH 支付 Gas 費",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("付款方式"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage("使用 ETH 支付"),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "支援的鏈",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "正在檢查可用性...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "鏈覆蓋範圍",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "選擇您想要支付交易汽油費的方式",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "預計。成本",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "無法加載氣體選項",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage("重試"),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("待辦的"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("允許"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage("預覽地址"),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("準備好"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage("接收地址"),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("重試"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("撤銷"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "您確定要撤銷此工作階段金鑰嗎？已授權的 DApp 將無法再執行交易。",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage("撤銷工作階段金鑰"),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage("工作階段金鑰已撤銷"),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("已撤銷"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage("正在撤銷工作階段金鑰..."),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "具有高級安全功能的多重簽名帳戶",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("已儲存"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage("選擇鏈"),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "選擇 Paymaster",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("已選擇"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage("使用您的智慧帳戶發送代幣"),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 天"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1小時"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30天"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7天"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "例如100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "最大金額",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "我了解此金鑰的權限",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "與已授權的 DApp 合約互動",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "建立工作階段金鑰失敗",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "工作階段金鑰已建立",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "例如Uniswap、Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "標籤/DApp名稱",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "工作階段金鑰詳情",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage("有效期限"),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "高風險－僅信任經過驗證的 DApp",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage("工作階段金鑰"),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "授權 DApp 暫時存取您的智慧帳戶",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "DApp 訪問",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "完全控制",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "僅發送",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage("高風險"),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage("低風險"),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "中等風險",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "確認前檢查權限",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "選擇權限級別",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "在設定額度內轉移代幣",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "單一所有者的基本智慧帳戶 - 推薦給大多數使用者",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage("智慧帳戶"),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage("智慧錢包"),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage("消費限額"),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage("贊助（免費）"),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("智慧帳戶"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("總氣體"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("交易"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("看全部"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("地址"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage("請輸入名稱"),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage("請輸入地址"),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage("請選擇硬幣類型"),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("編輯地址"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage("刪除成功"),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("選擇硬幣"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("搜尋硬幣"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage("進階功能"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage("新增收件者"),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage("廣播..."),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage("全部清除"),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage("確認批量轉帳"),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("繼續"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "CSV 格式：地址、金額、標籤",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("完成"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "估算氣體...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage("批量傳輸僅支援EVM鏈"),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage("匯出 CSV"),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage("大量傳輸幫助"),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage("匯入 CSV"),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage("備註是可選的"),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "使用 Multicall3 降低汽油費",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage("沒有支援的代幣"),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage("收件者"),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage("選擇代幣"),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "在一筆交易中將代幣發送到多個地址",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("簽約..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "向左滑動即可刪除收件人",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage("大量傳輸"),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage("總金額"),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "不支援鏈",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("最便宜"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "您將收到（預計）",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("最快"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage("取得報價"),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage("橋樑歷史"),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage("沒有可用的路線"),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage("受到推崇的"),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("重新整理"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("路線"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage("搜尋鏈..."),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("選擇"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage("選擇代幣"),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("滑移"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "完全的",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage("失敗的"),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "進行中",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage("待辦的"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("橋"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage("橋接失敗"),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage("交易待處理"),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage("橋樑成功"),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "鎖定直至",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "在提交兌換之前，請先驗證鎖定期是否已過期。",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC仍處於鎖定狀態",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage("兌換vBTC"),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "已解鎖 — 準備兌換",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "我了解風險並希望繼續",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage("繼續質押"),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "它是如何運作的",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC將被鎖定，直到時間鎖到期。在下面的介面中完成質押過程。",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "您的 BTC 將在整個質押期內被鎖定。提前取款是不可能的。",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "該鎖定由比特幣 OP_CHECKLOCKTIMEVERIFY (CLTV) 強制執行，無法繞過。",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "智能合約風險：儘管經過審計，但沒有任何協議是完全無風險的。",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "最低質押：0.001 BTC。最短鎖定期：0.125 天（約 3 小時）。",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "風險提示",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "您的 BTC 被鎖定在帶有時間鎖 (CLTV) 的 2-of-2 多重簽名地址中，並由您的金鑰和 N42 罐金鑰保護。",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "鎖定你的比特幣",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "鏈上確認後，vBTC 將以 1:1 的比例鑄造到您的錢包中。",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "薄荷vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "持有vBTC即可賺取質押獎勵。 vBTC 也可用於 DeFi 協定。",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage("賺取獎勵"),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "當鎖定期到期時，銷毀您的 vBTC 以收回您的原始 BTC。",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "解鎖後兌換",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage("BTC自我託管質押"),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("知道了"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. 選擇支援NFT的代幣",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage("2. 進入NFT標籤"),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3.選擇您要燒錄的NFT",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage("4. 點選「刻錄」按鈕"),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("步驟："),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "要刻錄 NFT，請進入 NFT 詳細資料頁面並點擊「刻錄」按鈕。",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "該鏈暫不支援轉賬，敬請期待",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "所有資產均低於 1 美元",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage("其他資產"),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "點選即可顯示全部",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("最近的"),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "得到正式認可的！點擊“交換”以繼續。",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage("確切金額"),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage("無限"),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "無限批准：路由器可以隨時使用此代幣。標準做法，但如果合約受到損害，就會帶來風險。",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("正在批准…"),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage("最佳路線"),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage("最佳來源"),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("鏈"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage("確認兌換"),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage("氣體估算"),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "去中心化交易所歷史",
    ),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage("分鐘。已收到"),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("沒有代幣"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage("未找到代幣"),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage("價格走勢圖"),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage("價格影響"),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage("報價失敗"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage("搜尋符號/名稱/地址"),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("選擇"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage("最大滑點"),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage("確認的"),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("失敗的"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage("待辦的"),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("引"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("交換"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage("交換提交成功"),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("你付錢"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage("您收到"),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage("活躍產品"),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage("批次"),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("燒傷"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("買N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "使用 AST 協議購買 N",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage("跨鏈轉帳"),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("DEX 互換"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("氣體"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage("開始質押"),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("分類帳"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage("載入APY..."),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("礦業"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("賺取更多"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "原生 Solana 質押",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage("沒有活躍職位"),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "參與節點挖礦賺取獎勵",
    ),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage("快速工具"),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage("受到推崇的"),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage("選擇兌換類型"),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "用 Lido 質押 ETH",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("交換"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("賺"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage("總獲利"),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("看全部"),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "已更新解析位址",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("先進的"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("年費"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("可用的"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("基價"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage("正在檢查可用性..."),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("犯罪"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage("提交失敗"),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "註冊承諾已過期。請重新開始註冊程序。",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage("承諾..."),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage("確認續訂"),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage("確認並發送"),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "確認 ENS 分辨率",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage("地址已複製"),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage("目前到期日"),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("剩餘天數"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "註冊並管理您的 .eth 域名",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage("偵測到 ENS 名稱"),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("已到期"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("過期"),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage("延長註冊期限"),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("失敗的"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage("完成註冊"),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage("開始使用 ENS"),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "取得您的 .eth 名稱",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "位址無效（必須是 0x + 40 個十六進位字元）",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage("ENS 名稱無效"),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("現在是你的了！"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "註冊期間請保持應用程式打開",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "管理您的 Web3 身份",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage("最少 3 個字符"),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("我的域名"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("ENS 名稱"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage("新到期"),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage("新所有者地址"),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage("還沒有域名"),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("擁有者"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage("請稍等"),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage("進階名稱"),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage("價格細目"),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("基本的"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage("主名稱設定成功"),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage("加工..."),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage("註冊 ENS"),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("登記"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "您在以太坊上的去中心化身份",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage("註冊失敗"),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage("立即註冊"),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage("註冊..."),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage("註冊資訊"),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "報名期間",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage("啟用到期提醒"),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "到期前30天、7天及1天通知",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("更新"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage("擴展您的網域註冊"),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage("續訂成功"),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage("解析位址"),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage("解決 ENS..."),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("搜尋"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "尋找可用的 .eth 名稱",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage("搜尋 .eth 名稱"),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "輸入 ENS 名稱進行搜尋",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage("搜尋並註冊"),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage("搜尋 ENS"),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "無法傳送到您自己的地址",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage("以太坊名稱服務"),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage("設定為主要"),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage("標準名稱"),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "開始註冊",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("步驟1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("步驟2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("步驟3"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage("建立子網域"),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "子網域已建立",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage("刪除子網域"),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "該子網域將會永久刪除。",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "子網域已刪除",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage("還沒有子域"),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "僅使用字母、數字和連字符",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage("子網域標籤"),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "例如部落格、郵件、應用程式",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage("業主地址"),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "留空以使用當前錢包",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("子域"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("成功！"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage("建議"),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage("文字記錄"),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ENS 經理"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("全部的"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("轉帳"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "將所有權轉移至另一個地址",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage("轉帳成功"),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "轉移作業不可逆，請確認新擁有者地址正確。",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage("嘗試另一個名字"),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "ENS 註冊過程分為兩步",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage("不可用"),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("等待"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "等待期可防止搶先交易攻擊",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "等待期可防止搶先交易",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("等待..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "請先驗證已解析的位址，然後再繼續。 ENS 名稱可由其所有者轉讓或更改。",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("年"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("年"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage("您的身分"),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage("解析響應資料錯誤！"),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Dio 錯誤"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage("請求語法錯誤"),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage("未授權，請登入"),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("拒絕訪問"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("請求錯誤"),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage("請求超時"),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("伺服器異常"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage("服務尚未實作"),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("網關錯誤"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage("服務目前不可用"),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage("網關逾時"),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage("不支援HTTP版本"),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage("請求失敗，錯誤碼："),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage("系統繁忙，請稍後重試"),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage("請求頻率太快"),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage("解碼失敗"),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage("交易已經上鍊"),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage("證書配置錯誤！"),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage("狀態碼配置錯誤！"),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("未知錯誤！"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage("網路連線逾時，請檢查網路設定！"),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage("伺服器異常。請稍後再試！"),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage("請求已取消，請重新請求！"),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage("匯出金鑰庫"),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage("備份技巧"),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "使用密碼管理工具來儲存。",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("已複製"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage("複製已取消"),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage("身份錢包"),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage("加密的私鑰檔案。"),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage("匯入方式"),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage("金鑰庫文件"),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage("請輸入密鑰庫資訊。"),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage("匯出私鑰"),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "獲得Keystore和密碼將使持有者完全控制錢包資產。",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "仔細記錄並存放在安全的地方。保留多個實體副本是最安全的儲存方法。",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "如果您的私鑰遺失，則無法找回。對其進行實體備份並安全存放。",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage("離線保存"),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "不要儲存到任何不安全的信箱、記事本、網盤或聊天軟體。",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage("請使用網路傳輸"),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "請務必透過網路工具傳輸，一旦被駭客獲取，將造成難以挽回的經濟損失",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage("使用工具保存"),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "我了解任何獲得此文件和密碼的人都可以完全控制我的資金 - 損失是永久性的且無法挽回",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "輸入錢包密碼確認導出",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage("輸入錢包密碼查看私鑰"),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("篩選"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("氣體警報"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage("高於以上時發出警報"),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage("低於時發出警報"),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("儲存"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "閾值（Gwei）",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("基本費用"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("風俗"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("快速地"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Gas 價格會隨網路需求波動。較低的 Gas = 較慢的確認速度，較高的 Gas = 較快的確認速度。",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("最高費用"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage("網路繁忙"),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage("網路空閒"),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage("網路正常"),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage("價格趨勢"),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage("優先費"),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "即時 Gas 價格",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage("氣體設定"),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("慢的"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("標準"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("氣體追蹤器"),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "帳號已匯入",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("新增"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage("新增帳戶"),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage("地址已複製"),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "連線前請確保您的裝置已解鎖且藍牙已啟用。",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("檢查應用程式"),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "連接新設備",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "帶有梯形校正的氣隙 (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "連接 Ledger（藍牙）",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "連接 Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("已連接"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage("正在連接..."),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("斷開"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("回去"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "連結梯形校正",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "使用 Keystone 設備掃描此QR Code以簽署交易",
    ),
    "g_key_hw_keystone_scan_response_hint":
        MessageLookupByLibrary.simpleMessage("將相機對準 Keystone 裝置上顯示的QR Code"),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("掃描梯形校正簽名"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "從 Keystone 裝置掃描QR Code以匯入帳戶",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "點擊掃描 Keystone 回應",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("加載更多"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "正在載入帳戶...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "如果出現提示，請在您的裝置上確認",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "沒有找到帳戶",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "目前沒有開啟任何應用程式",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage("裝置未連接"),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage("未連接"),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("消除"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage("刪除設備"),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage("已儲存的設備"),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage("支援的設備"),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("今天"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "無法連接到 Trezor。確保 USB 已連接。",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "連接特雷佐",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor 連結成功",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "正在連接到 Trezor...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "透過 USB 線連接您的 Trezor 裝置並解鎖",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage("查看帳戶"),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage("錢包帳戶"),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("昨天"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage("當前的貨幣錢包已經存在。"),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage("無法讀取金鑰庫"),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("金鑰庫"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("登入"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("退出"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage("您確定要退出該應用程式嗎？"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("嘰嘰喳喳"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("紅迪網"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("瀏覽器"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("電報"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("不和諧"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("市值"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("交易量"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("總供應量"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("流通中"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("關於"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("更多的"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("連結"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("網站"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage("管理鏈"),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("可用的"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "需要質押",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage("請輸入助記詞"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("全部的"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("名稱"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("後退"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("交易已提交"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage("錢包地址無效"),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("餘額"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "此操作是不可逆轉的。 NFT 將被發送至銷毀地址。",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("燒毀NFT"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("收藏"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("合約"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("描述"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "加載 NFT 失敗。點擊重試。",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("全部"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("影片"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("地面"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("NFT畫廊"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage("銘文#"),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage("未找到 NFT"),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage("沒有可用的瀏覽器連結"),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "不支援影片播放",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("序數詞"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "尚不支援序數傳輸",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("數量"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage("按名稱或集合搜尋"),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("發送 NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana NFT 轉帳即將推出",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("代幣ID"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("類型"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage("密碼不匹配"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage("從手機圖庫中選擇"),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("重置"),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "使用小心",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "檢查合約安全性...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "偵測到高風險",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GOPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "合約已驗證安全",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage("備忘錄/註釋"),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage("備忘錄/註釋（可選）"),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("分享QR Code"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("分享連結"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage("分享方法"),
    "g_key_sim_gas_estimate": m28,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage("交易可能會失敗"),
    "g_key_sim_reverted_reason": m29,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage("模擬交易..."),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage("交易模擬透過"),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage("該網路無法進行模擬"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("聊天"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("啟用"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "活躍職位",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("數量"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "解除質押金額",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("平均年產量"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("平均年收益"),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("委員會"),
    "g_key_stake_d_unbond": m30,
    "g_key_stake_days_remaining": m31,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "預計。每日獎勵",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "預計。年度獎勵",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage("前往交換"),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "流動質押",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("液體"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "您的流動性代幣可以直接在 DEX 上進行交易。使用 Swap 將其兌換回原生資產。",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage("最低投注額"),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "沒有可取消質押的活躍部位",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("無鎖"),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "還沒有質押倉位",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage("未找到驗證器"),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage("錢包地址不可用"),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage("總質押概述"),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage("我的職位"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("協定"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("獎勵"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "搜尋驗證器...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "選擇驗證器",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "選擇要取消質押的位置",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "選擇驗證器",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage("排序方式"),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("賭注"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("質押"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage("開始質押"),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("質押"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage("交易準備成功"),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage("脫鉤"),
    "g_key_stake_unbonding_warning": m32,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("取消質押"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage("更新中..."),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("驗證器"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage("您將收到"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("完全的"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("汽油價格"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("最高汽油費"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("每份汽油的最高費用"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("待辦的"),
    "g_key_t_29": m33,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("失敗"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("繼續"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("錢包密碼"),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage("錢包密碼錯誤"),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage("請輸入錢包密碼"),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("瓦斯費率"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage("最新區塊平均Gas費率"),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("轉出"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage("輸入大於 0 的整數。"),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage("取得數據失敗"),
    "g_key_t_45": m34,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage("檢查收貨地址帳戶"),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("尋找"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("沒有帳戶"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("轉入"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("地址無效"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage("帳戶驗證成功"),
    "g_key_t_52": m35,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage("收款地址沒有帳戶，首次轉帳至少10XRP"),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("使用氣體"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("氣體"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage("新增"),
    "g_key_token_discovery_add_selected": m36,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "已新增代幣",
    ),
    "g_key_token_discovery_banner": m37,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "取消全選",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "沒有發現新的代幣",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage("忽略"),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "選擇全部",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "發現的代幣",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("交易記錄"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("交易詳情"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage("請查看歷史交易收據"),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("支出金額"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("收到金額"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage("開始日期"),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage("日期範圍"),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage("結束日期"),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage("方向"),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage("沒有交易符合您的篩選條件"),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("通用唯一識別符"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage("尋找最新版本"),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("立即更新"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("發現新版本"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage("已經是最新版本了"),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage("查看助記詞"),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage("現在嘗試再次輸入助記詞。"),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("匯入帳戶"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("建立帳戶"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("你都完成了！"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage("現在您可以充分享受您的錢包了。"),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("開始使用"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("暫時跳過"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "現在您可以跳過備份助記詞，如果需要，可以隨時在「設定」中再次執行此操作。",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage("直接建立"),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage("建立成功"),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "如果您想查看您的錢包詳細資訊或匯出金鑰庫，您可以前往側邊欄 > 管理錢包",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage("匯出我的金鑰庫"),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage("透過備份來保護您的錢包"),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "金鑰庫是安全憑證和關聯私鑰的儲存庫。",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage("步驟一：進入管理錢包。"),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage("步驟2：選擇錢包位址。"),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage("步驟 3：按匯出金鑰庫。"),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage("前往管理錢包"),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage("回首頁"),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("添加錢包"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage("使用助記詞建立錢包。"),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage("輸入錢包名稱"),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage("您還沒有備份您的錢包助記詞！"),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("立即備份"),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage("設定錢包密碼"),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage("備份錢包"),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage("請記錄以下助記詞"),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("開始"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "連接網路的裝置可能會洩漏您的資訊。我們建議您記下助記詞並安全存放。",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "警告：請勿向任何人透露您的助記詞。 N42Wallet 絕不會要求您提供此資訊。請極度謹慎並安全地離線儲存。如果您的助記詞被暴露，您可能會失去所有資產並且無法恢復。",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "警告：助記詞是恢復您錢包資產的唯一方法。",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("下一步"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage("點擊看助記詞"),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage("請確保周圍沒有其他人或攝影機"),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage("確認助記詞"),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage("錢包資訊"),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("錢包名稱"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage("請先備份您的錢包助記詞！"),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage("檢查助記詞"),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage("現在輸入您的助記詞。"),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("設定短語"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "請確保記錄您的助記詞並安全儲存。您將需要它來匯入或恢復您的加密貨幣錢包。",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage("錢包編輯"),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("時間"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("結果"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage("交易哈希"),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("新增"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("小路"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("堵塞"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("價值"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("隨機數"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("加速"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("筆記"),
    "g_key_wallet_m1": m38,
    "g_key_wallet_m19": m39,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage("當前代幣尚未新增。"),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage("輸入助記詞，單字之間用空格分隔"),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("匯入錢包"),
    "g_key_wallet_m3": m40,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage("當前代幣餘額不足。"),
    "g_key_wallet_m5": m41,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("簽名錯誤"),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage("管理錢包"),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "輸入以太坊地址（0x...）",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "僅限手錶的錢包無法發送或簽署交易",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage("手錶錢包"),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "無需私鑰即可追蹤任何 EVM 位址",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("預訂的"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("基礎儲備"),
    "g_key_xml_11": m42,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("增量儲備"),
    "g_key_xml_22": m43,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage("擁有的對象計數"),
    "g_key_xml_33": m44,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage("如何計算總預留金額"),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "總儲備 = 基礎儲備 +（擁有物件數 × 增量儲備）",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("觸碰 ID 和麵容 ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("手勢密碼"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage("設置手勢密碼"),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage("繪製您的手勢圖案"),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage("再次繪製手勢圖案確認"),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage("繪製當前手勢密碼"),
    "g_lock_key21": m45,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage("重置手勢密碼"),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage("輸入錯誤次數過多，請重新設置"),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage("新增錢包密碼？"),
    "g_lock_key25": m46,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage("轉帳驗證"),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "開啟後，每次發起轉帳時需透過面容 ID 或指紋進行身份驗證。",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage("未設置手勢密碼"),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "開啟後，每次發起轉帳時需透過手勢密碼進行身份驗證。",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("成功了"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("失敗的"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage("生物特徵識別未啟用"),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage("新增生物辨識驗證？"),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage("30D變化"),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("7D變化"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("亞泰"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("市場深度"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage("還沒有關注列表"),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("高24小時"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage("流動性評分"),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("24小時低"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("訊息"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage("無圖表數據"),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage("沒有結果"),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("秩"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("搜尋"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage("搜尋硬幣..."),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("流行趨勢"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage("注意列表"),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "驗證者閒置分數偏高。請檢查您的節點狀態以避免受罰。",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("解鎖N？"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage("雲端驗證活動"),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage("驗證設定"),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage("背景驗證音樂"),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("預設"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("沉默的"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "啟用後台驗證後，音樂將在背景播放。如果音樂停止，驗證也會停止。",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("你的等級"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage("安裝需要少量氣體。"),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "您已成功加入N42Wallet上的群組節點。分享連結邀請好友，啟動節點並開始驗證！",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage("分享給朋友"),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("繼續"),
    "g_mining_key63": m47,
    "g_mining_key73": m48,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "我剛剛在@N42Wallet上設置了一個節點並開始在行動裝置上進行驗證！來加入我吧。去中心化的未來是移動的！",
    ),
    "g_mining_key76": m49,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("礦物"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("節點"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("網路"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "在測試網和主網之間切換以進行雲端挖礦。",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage("768後即可兌換。"),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage("在此之前的請求將不會被處理。"),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("家"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("今天的獎勵"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "請將以下數據視為重要的關鍵。我們建議立即將其複製並備份到受信任的位置。",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("複製數據"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("不活躍"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage("匯入成功"),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage("加密資料不能為空！"),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage("密碼不能為空！"),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage("解密失敗。請檢查密碼是否正確！"),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage("不支援的加密資料格式！"),
    "g_mining_key_109": m50,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage("昨天的獎勵"),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage("加密數據"),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("匯入檔案"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage("請輸入加密資料。"),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("輸入..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("確認"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage("兌換需要一定時間，請稍等！"),
    "g_mining_key_116": m51,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "獎勵每天累積，只有達到 ~0.5 N 時才會發送到您的 N 錢包。",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("總獎勵"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("開採價值"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage("任務詳情"),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("概括"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("活動"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage("開採總價值"),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage("驗證自"),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("利潤數"),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage("驗證值"),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("選擇計劃"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage("解鎖期限：可隨時解鎖"),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage("每年最高獎勵"),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage("獎勵分配"),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("每日限額"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("速度"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage("驗證計劃"),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage("選擇付款方式"),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("付款方式"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("使用 N 支付"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("錢包餘額"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage("您沒有足夠的 N 來進行此交易"),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage("您確定要跳過嗎？"),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "在您選擇其中一項計劃之前，您將不會收到任何驗證獎勵。",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("已停用"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("報酬"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("看更多"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage("驗證狀態"),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("解鎖"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("跳過"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("過去 7 天"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage("累積獎勵"),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage("鎖定N開始驗證獎勵。"),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage("收到的獎勵"),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("先進的"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("入門"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("專業版"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("全節點"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("分鐘/天"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("進階節點"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("入門節點"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("專業節點"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage("500 個區塊/天~70 分鐘"),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("解鎖日期"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage("100 個區塊/天~15 分鐘"),
    "g_mining_key_71": m52,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage("每次檢查 128 秒"),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "測試鏈正在升級，暫時無法驗證區塊。",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "連續四天未能完成任務將導致沒有收入並有被處罰的風險。",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("風險評分"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("贖回"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage("請先儲存驗證者的公私鑰對。"),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("出口"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage("今天的驗證時間"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage("轉帳餘額不足。"),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage("驗證者列表"),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage("匯入驗證器"),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage("驗證器已經存在"),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("低風險"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("中等風險"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage("7 天獎勵"),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("高風險"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "合約正在加載，目前無法驗證。請稍等！",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage("安全提示"),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage("背景驗證"),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage("請妥善保管您的私鑰或助記詞。"),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "您的私鑰或助記詞是存取您錢包資產的唯一憑證。",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "請將其保存在安全的地方（紙張、密碼管理器等）。",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "請勿截取螢幕截圖、上傳至網路或與任何人分享。",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "一旦遺失或洩露，您的錢包資產將無法恢復。",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage("確認並保存"),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage("設定密碼並加密"),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage("請輸入加密密碼"),
    "g_mining_key_98": m53,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage("請重新輸入您的密碼以確保其正確"),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage("完整節點詳情"),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("節點 ID"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS連接"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage("WS 已斷開"),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage("WS 重新連接"),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("到期日"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage("解鎖期限："),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "隨時可解鎖",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage("無可用訊息"),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage("返回（安全）"),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "無論如何都要繼續",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "該網站已被確定為潛在惡意網站。它可能試圖竊取您的加密資產或私鑰。",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage("安全警告"),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "可疑網址：",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage("添加貿易"),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("平均成本"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage("買入價（美元）"),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("成本基礎"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("數量"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("儲存"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage("未實現損益"),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("24小時變化"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage("所有控股"),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage("資產配置"),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage("漲幅最大者"),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage("最大輸家"),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage("24小時搬運工"),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage("未找到資產"),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("其他的"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("全部的"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("資料夾"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("總價值"),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage("新增結果"),
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage("開啟預測"),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("建立中…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("截止"),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage("至少兩個有效結果"),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage("請填寫預測問題"),
    "g_pred_minutes": m54,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("否"),
    "g_pred_outcome_n": m55,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("結果選項"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("發布預測"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage("預測問題，例如：本局誰贏？"),
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage("不限（手動停盤）"),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("是"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("已下載"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage("邀請碼"),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("受邀"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("挖礦節點"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("獎勵（N）"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "經典挖礦（V1）",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage("採礦（V2）"),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage("挖礦介面"),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("分享"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("推薦"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage("推薦朋友並獲得 N 代幣！"),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("你起床到"),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage("N 當您的推薦人開始驗證時！"),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("參考透過"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("關聯"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("代碼"),
    "g_swap_key_14": m56,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage("取得幣價錯誤。"),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage("繼續操作即表示您同意以下內容"),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage("條款與條件。"),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("完成"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage("您的兌換將很快發放，請耐心等待。"),
    "g_swap_key_20": m57,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "運行節點的成本：群組驗證 1-49 N 基本節點：50 N 高階節點：100 N 專業節點：500 N。",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("到期"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("未付"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage("確認付款"),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("待分發"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("兌換摘要"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("新餘額"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("你支付"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("日期"),
    "g_swap_key_31": m58,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "兌換可在相應鏈的區塊瀏覽器（Etherscan、BscScan、TRONSCAN 及我們自己的瀏覽器）中查看。",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("交換到N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("交換"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("你收到"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("預覽交換"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("再試一次"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage("強調色"),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage("重設為預設值"),
    "g_token_m_key_1": m59,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "任何人都可以建立代幣，包括冒充現有代幣的假代幣。匯入前請務必自行做好研究。",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("代幣"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("搜尋代幣"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("鏈名稱"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("鏈代號"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("鏈號"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("十進位"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage("新增自訂鏈"),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18個單位"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("添加代幣"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("格式錯誤！"),
    "g_token_m_key_22": m60,
    "g_token_m_key_23": m61,
    "g_token_m_key_24": m62,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("匯入代幣"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("所有網路"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("自訂代幣"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("代幣地址"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("代幣符號"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("代幣十進位"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("匯入"),
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("警告"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("高風險"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("安全的"),
    "g_version_later": MessageLookupByLibrary.simpleMessage("之後"),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage("連線遺失。請重新連接。"),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage("DApp已斷開連接"),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage("全部斷開"),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "與所有 DApp 斷開連線？",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "與該 DApp 斷開連線？",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage("沒有活動連接"),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "掃描QR Code連接DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage("連線請求逾時"),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage("工作階段已過期"),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("連接的 DApp"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage("關聯"),
    "importantNotice": MessageLookupByLibrary.simpleMessage("重要通知"),
    "login_email": MessageLookupByLibrary.simpleMessage("電子郵件"),
    "login_password": MessageLookupByLibrary.simpleMessage("密碼"),
    "next": MessageLookupByLibrary.simpleMessage("下一個"),
    "nicknameMessage": m63,
    "personalInformation": MessageLookupByLibrary.simpleMessage("編輯個人資料"),
    "photograph": MessageLookupByLibrary.simpleMessage("照片"),
    "please_input_address": MessageLookupByLibrary.simpleMessage("請輸入地址"),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage("不再提醒"),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage("稍後再說"),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage("去設定"),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "您尚未開啟推送通知權限，將無法及時收到聊天訊息和轉帳提醒。\n\n建議前往系統設定為本應用開啟通知權限。",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "推送通知未開啟",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage("重新輸入密碼"),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "選擇密碼（8~18個字元）",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage("確認密碼"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("關於應用程式"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("安全"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("交易"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("語言"),
    "search": MessageLookupByLibrary.simpleMessage("搜尋"),
    "verification": MessageLookupByLibrary.simpleMessage("確認"),
    "w_item_1": MessageLookupByLibrary.simpleMessage("如果我失去了我的密語，我的資金將永遠失去。"),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "如果我向任何人透露或分享我的助記詞，我的資金可能會被偷走。",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage("我有責任確保我的助記詞的安全。"),
    "w_key_12": MessageLookupByLibrary.simpleMessage("助記詞不正確。"),
    "w_key_8": MessageLookupByLibrary.simpleMessage("輸入您要匯入的錢包的助記詞。"),
  };
}

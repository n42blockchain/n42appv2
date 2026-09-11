// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
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
  String get localeName => 'ko';

  static String m0(deviceName, os) =>
      "회원님의 계정이 ${deviceName} (${os})에서 로그인되었습니다. 본인이 아닌 경우 비밀번호를 변경하는 것을 권장합니다.";

  static String m1(price) => "현재 가격: \$${price}";

  static String m2(symbol) => "가격 알림 · ${symbol}";

  static String m3(s) => "${s}로 다시 보내기";

  static String m4(message) => "구매 실패: ${message}";

  static String m5(productId) => "구매 성공: ${productId}";

  static String m6(productId) => "복원됨: ${productId}";

  static String m7(value) => "${value}보다 큰 금액입니다.";

  static String m8(value) => "지갑이 이미 존재합니다. 지갑 이름: \"${value}\"";

  static String m9(value) => "${value} 이상의 금액을 입력하세요.";

  static String m10(value) => "${value}행의 주소가 중복됨";

  static String m11(value) => "잔액 부족: 총 금액이 사용 가능한 ${value}를 초과합니다.";

  static String m12(value) => "${value}행의 주소가 잘못됨";

  static String m13(value) => "${value}행의 금액이 잘못됨";

  static String m14(value) => "최대 ${value}명의 수신자";

  static String m15(token) => "계속하려면 ${token}를 승인하세요.";

  static String m16(impact) => "높은 가격 충격(${impact})! 주의해서 진행하세요.";

  static String m17(secs) => "견적은 ${secs}s에 만료됩니다.";

  static String m18(value) => "최대 ${value}% APY 획득";

  static String m19(value) => "${value}초마다 자동 새로고침";

  static String m20(address) => "계정 ${address} 추가됨";

  static String m21(address, network) =>
      "이 하드웨어 지갑 계정을 추적하시겠습니까?\n\n주소: ${address}\n네트워크: ${network}";

  static String m22(app) => "현재 앱: ${app}";

  static String m23(days) => "${days}일 전";

  static String m24(value) => "계정 가져오기 실패: ${value}";

  static String m25(date) => "마지막 연결: ${date}";

  static String m26(app) => "Ledger에서 ${app} 앱이 열려 있는지 확인하세요";

  static String m27(name) => "저장된 장치에서 \"${name}\"을 제거하시겠습니까?";

  static String m28(value) => "${value} 포인트 획득";

  static String m29(amount, symbol, network) =>
      "${network}에서 ${amount} ${symbol} 요청";

  static String m30(value) =>
      "사용자 정의 네트워크 ${value}를 제거하시겠습니까? 이 네트워크의 잔액은 더 이상 표시되지 않습니다. 체인上的 자산에는 영향이 없습니다.";

  static String m31(value) => "예상 가스: ~${value} 단위";

  static String m32(reason) => "이유: ${reason}";

  static String m33(value) => "${value}d 결합 해제";

  static String m34(value) => "${value}일 남음";

  static String m35(value) => "언스테이킹에는 ${value}일이 소요됩니다. 이 기간 동안 귀하의 토큰은 잠깁니다.";

  static String m36(value) => "\"${value}\"이(가) 부족합니다";

  static String m37(value) => "\"${value}\" 계정 가져오기 실패";

  static String m38(value) => "첫 송금 시 최소 ${value} XRP 필요";

  static String m39(count) => "(${count}) 추가";

  static String m40(count) =>
      "${Intl.plural(count, one: '1개의 새 토큰이 감지되었습니다.', other: '${count} 새 토큰이 감지되었습니다.')} — 검토하려면 탭하세요.";

  static String m41(value) => "${value} 체인이 추가되지 않았습니다.";

  static String m42(value) => "${value}에 미완료 거래가 있습니다. 나중에 다시 시도하세요.";

  static String m43(value) => "${value}에 대한 주소를 찾을 수 없습니다.";

  static String m44(value) => "${value} 잔액이 부족합니다.";

  static String m45(value, value1) =>
      "모든 XRP 계정은 기준선으로 ${value} XRP(${value1} drops)를 예약해야 하며, 이는 사용할 수 없습니다.";

  static String m46(value, value1) =>
      "계정이 소유한 각 객체에 대해 ${value} XRP(${value1} drops)가 준비금에 추가됩니다.";

  static String m47(value, value1) =>
      "이 계정은 ${value}개의 객체를 소유하고 있으며, 이는 추가로 ${value1} XRP가 예약됨을 의미합니다.";

  static String m48(message) => "라이브룸 입장 실패\n${message}";

  static String m49(value) => "잘못된 패턴, 남은 시도 횟수 ${value}회";

  static String m50(value) => "잘못된 패턴, 남은 시도 횟수 ${value}회";

  static String m51(value) => "${value}을(를) 성공적으로 설정했으며 N42Wallet으로 검증을 시작합니다!";

  static String m52(value) =>
      "@N42Wallet에서 내 ${value} 그룹에 참여하여 레이어 1 체인의 초기 채굴자가 되고, 폰으로 암호화폐를 받으세요!";

  static String m53(value, value1) =>
      "${value1}까지 노드를 실행하기 위해 ${value} N을 잠그시겠습니까?";

  static String m54(value) => "가져오기 실패:${value}";

  static String m55(value) => "보상을 받으려면 최소 ${value}의 스테이킹 잔액이 필요합니다.";

  static String m56(value, value1) => "${value1}블록 채굴 시 ${value} N";

  static String m57(value) => "${value}자여야 합니다";

  static String m58(symbol) => "투입 금액 (${symbol})";

  static String m59(amount, symbol) => "잔액: ${amount} ${symbol}";

  static String m60(label) => "「${label}」을(를) 승자로 정산하시겠습니까? 되돌릴 수 없습니다.";

  static String m61(n) => "${n}분";

  static String m62(n) => "결과 ${n}";

  static String m63(label, pct) => "${label} 승리 (${pct}%)";

  static String m64(shares, avg, after) =>
      "예상 ${shares} 지분 · 평균 ${avg}% · 체결 후 ${after}%";

  static String m65(reason) => "환급 실패: ${reason}";

  static String m66(label) => "결과: ${label}";

  static String m67(n) => "매도 ${n}";

  static String m68(value) => "${value} 잔액이 부족합니다.";

  static String m69(value) => "${value} 입금 중...";

  static String m70(value) =>
      "앱 내에서 스왑된 ${value}은(는) 곧 지갑으로 분배되며 이 프로세스를 통해 판매할 수 없습니다. 노드 운영에 사용할 수 있습니다.";

  static String m71(value) => "최대 ${value}자";

  static String m72(value) => "${value} 체인은 앱에서 이미 지원됩니다!";

  static String m73(value) => "${value} 체인은 앱에서 이미 지원됩니다. 추가하시겠습니까?";

  static String m74(value) => "${value} 주소 테스트 링크 실패!";

  static String m75(value) =>
      "RPC가 보고한 Chain ID는 ${value}이며, 입력하신 값과 일치하지 않습니다.";

  static String m76(asset, contract, address) =>
      "자산 ${asset} (${contract})가 계정 ${address}에 추가되지 않았습니다.";

  static String m77(imported, skipped) =>
      "지갑 가져오기: ${imported}. 건너뛴 항목: ${skipped}.";

  static String m78(value) => "잔액: ${value}";

  static String m79(value) => "기본 수수료: ${value} Gwei";

  static String m80(value) => "${value}초 후 클립보드가 자동으로 지워집니다";

  static String m81(value) => "행 ${value}: 누락된 필드";

  static String m82(value) => "${value}일";

  static String m83(value) => "${value}에 연결됨";

  static String m84(value) => "가스: ${value}";

  static String m85(value) => "${value}시간";

  static String m86(value) => "유효한 수신자 수입 (${value})";

  static String m87(quote, base) => "지정가 (${quote}당 ${base})";

  static String m88(value) => "한도 ${value}";

  static String m89(value) => "시장 (${value})";

  static String m90(value) => "최소 잔액: ${value}";

  static String m91(value) => "주문 (${value})";

  static String m92(value) => "포지션 (${value})";

  static String m93(value) => "수신자: ${value}";

  static String m94(value) => "토큰을 찾음: ${value}";

  static String m95(value) => "토큰: ${value}";

  static String m96(value) => "거래: ${value}";

  static String m97(valid, issues) => "유효: ${valid}. 문제: ${issues}.";

  static String m98(value) => "… 및 ${value}개의 기타 문제";

  static String m99(volume, interest) => "거래량: ${volume} · 관심: ${interest}";

  static String m100(value) => "지갑 ${value}";

  static String m101(value) => "${value}시간 전 업데이트됨";

  static String m102(value) => "${value}분 전 업데이트됨";

  static String m103(value) => "0~${value}자";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("편집"),
    "Verification": MessageLookupByLibrary.simpleMessage("인증"),
    "address_Information": MessageLookupByLibrary.simpleMessage("주소 정보"),
    "copy": MessageLookupByLibrary.simpleMessage("복사 완료"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("주소 복사"),
    "descO": MessageLookupByLibrary.simpleMessage("설명(선택사항)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "비밀번호 변경",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("확인"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage("새 기기 로그인"),
    "file": MessageLookupByLibrary.simpleMessage("파일"),
    "g_aggregate_cached_balance": MessageLookupByLibrary.simpleMessage(
      "저장된 잔액 · 새로 고침 실패",
    ),
    "g_aggregate_known_balance": MessageLookupByLibrary.simpleMessage("알려진 잔액"),
    "g_aggregate_mainnet_note": MessageLookupByLibrary.simpleMessage(
      "메인넷 잔액만 표시됩니다. 누락되거나 실패한 네트워크 쿼리는 0으로 간주되지 않습니다.",
    ),
    "g_aggregate_network_balances": MessageLookupByLibrary.simpleMessage(
      "네트워크별 잔액",
    ),
    "g_aggregate_no_mainnet": MessageLookupByLibrary.simpleMessage(
      "이 네트워크용 활성 메인넷 계정이 없습니다",
    ),
    "g_aggregate_not_loaded": MessageLookupByLibrary.simpleMessage(
      "잔액을 불러오지 못했습니다",
    ),
    "g_aggregate_open_network": MessageLookupByLibrary.simpleMessage("네트워크 열기"),
    "g_aggregate_unavailable": MessageLookupByLibrary.simpleMessage(
      "이 자산은 선택된 지갑에서 더 이상 사용할 수 없습니다. 지갑으로 돌아가서 자산을 선택하세요.",
    ),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("위로 ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("아래 드롭 ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage("가격이 책정되면 알림"),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage("이 알림을 활성화하세요"),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "0보다 큰 유효한 가격을 입력하세요.",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("제거"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("알림 설정"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage("목표주가(USD)"),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage("업데이트 알림"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "토큰은 동일한 네트워크 내에서만 전송할 수 있습니다. 다른 네트워크에서 전송하면 손실이 발생할 수 있습니다.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage("스캔하여 받기"),
    "g_audit_aa_history_external": MessageLookupByLibrary.simpleMessage(
      "스마트 계정의 블록체인 활동을 보려면 블록체인 탐색기 열기",
    ),
    "g_audit_about_desc": MessageLookupByLibrary.simpleMessage("버전, 웹사이트 및 지원"),
    "g_audit_activity_error": MessageLookupByLibrary.simpleMessage(
      "거래 내역을 로드할 수 없습니다.",
    ),
    "g_audit_activity_local": MessageLookupByLibrary.simpleMessage(
      "지갑 간 로컬 거래 내역. 자산을 열어 최신 활동을 동기화하세요.",
    ),
    "g_audit_all": MessageLookupByLibrary.simpleMessage("모두"),
    "g_audit_approval_spender": MessageLookupByLibrary.simpleMessage("지출 승인"),
    "g_audit_approval_token": MessageLookupByLibrary.simpleMessage("토큰 계약"),
    "g_audit_batch": MessageLookupByLibrary.simpleMessage("일괄 전송"),
    "g_audit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "여러 수신자에게 전송하거나 CSV 파일 가져오기",
    ),
    "g_audit_biometrics": MessageLookupByLibrary.simpleMessage("생체 인식 인증"),
    "g_audit_biometrics_desc": MessageLookupByLibrary.simpleMessage(
      "얼굴 인식 / 지문 설정",
    ),
    "g_audit_connections_desc": MessageLookupByLibrary.simpleMessage(
      "세션 관리; 연결 해제는 토큰 승인을 취소하지 않습니다.",
    ),
    "g_audit_currency": MessageLookupByLibrary.simpleMessage("표시 통화"),
    "g_audit_currency_usd": MessageLookupByLibrary.simpleMessage(
      "포트폴리오 가치는 현재 미국 달러로 표시됩니다.",
    ),
    "g_audit_defi_error": MessageLookupByLibrary.simpleMessage(
      "DeFi 포지션을 로드할 수 없습니다. 다시 시도하려면 탭하세요.",
    ),
    "g_audit_defi_loading": MessageLookupByLibrary.simpleMessage(
      "DeFi 포지션을 로딩 중…",
    ),
    "g_audit_defi_positions": MessageLookupByLibrary.simpleMessage("DeFi 포지션"),
    "g_audit_display_language": MessageLookupByLibrary.simpleMessage("앱 표시 언어"),
    "g_audit_encrypted_backup": MessageLookupByLibrary.simpleMessage(
      "암호화된 지갑 백업 내보내기",
    ),
    "g_audit_funding": MessageLookupByLibrary.simpleMessage("현재 펀딩 레이트"),
    "g_audit_gas": MessageLookupByLibrary.simpleMessage("가스 트래커"),
    "g_audit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "네트워크 수수료 및 가격 알림",
    ),
    "g_audit_hardware": MessageLookupByLibrary.simpleMessage("하드웨어 지갑"),
    "g_audit_load_more": MessageLookupByLibrary.simpleMessage("더 보기"),
    "g_audit_mainnet": MessageLookupByLibrary.simpleMessage("메인넷"),
    "g_audit_manage_settings": MessageLookupByLibrary.simpleMessage(
      "지갑 및 설정 관리",
    ),
    "g_audit_manage_wallets": MessageLookupByLibrary.simpleMessage(
      "지갑 생성, 가져오기 및 관리",
    ),
    "g_audit_mark_price": MessageLookupByLibrary.simpleMessage("마크 가격"),
    "g_audit_max_leverage": MessageLookupByLibrary.simpleMessage("최대 레버리지"),
    "g_audit_network_desc": MessageLookupByLibrary.simpleMessage(
      "네트워크 및 RPC 엔드포인트 관리",
    ),
    "g_audit_open_interest": MessageLookupByLibrary.simpleMessage("미결제 포지션"),
    "g_audit_oracle_price": MessageLookupByLibrary.simpleMessage("오라클 가격"),
    "g_audit_protect_wallet": MessageLookupByLibrary.simpleMessage(
      "인증 및 지갑 보호",
    ),
    "g_audit_quote_changed": MessageLookupByLibrary.simpleMessage(
      "스왑 가격 제안이 변경되었거나 만료되었습니다. 확인하기 전에 최신 스왑 가격 제안을 다시 확인하세요.",
    ),
    "g_audit_rate": MessageLookupByLibrary.simpleMessage("N42 평가하기"),
    "g_audit_rate_desc": MessageLookupByLibrary.simpleMessage("앱 스토어 열기"),
    "g_audit_saved_addresses": MessageLookupByLibrary.simpleMessage(
      "저장된 수신자 주소",
    ),
    "g_audit_show_less": MessageLookupByLibrary.simpleMessage("더 적게 보기"),
    "g_audit_testnet": MessageLookupByLibrary.simpleMessage("테스트넷"),
    "g_audit_theme_desc": MessageLookupByLibrary.simpleMessage("외관 및 표시 모드"),
    "g_audit_volume": MessageLookupByLibrary.simpleMessage("24시간 거래량 (USD)"),
    "g_audit_wallet_management": MessageLookupByLibrary.simpleMessage("지갑 관리"),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage("URL을 입력하세요"),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("설명 입력"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("브라우저"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage("브라우저 캐시 삭제"),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage("DApp 자동 연결"),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("모두 닫기"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("완료"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("기록"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage("모든 기록 삭제"),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "모든 탐색 기록을 삭제하시겠습니까?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage("기록이 삭제되었습니다"),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("오늘"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("어제"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("DApp 탐색"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("인기"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("덱스"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("디파이"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("브릿지"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("북마크"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("도구"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage("아직 북마크가 없습니다"),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("북마크"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("이름"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage("이름을 입력하세요"),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("설명"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("수락"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage("메시지가 삭제되었습니다"),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("거래"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("연결"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("사용 가능한 네트워크"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("메시지 서명"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("연결 중"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "페어링 중, 잠시 기다려 주세요.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("연결 해제"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("거부"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage("차단됨"),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("주의"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("안전함"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage("확인됨"),
    "g_dex_account_unavailable": MessageLookupByLibrary.simpleMessage(
      "이 네트워크용 지출 가능한 메인넷 지갑을 선택하세요. 읽기 전용 계정은 스왑을 서명할 수 없습니다.",
    ),
    "g_dex_execution_invalid": MessageLookupByLibrary.simpleMessage(
      "거래 파라미터가 유효하지 않거나 실행에 실패했습니다. 스왑 가격 제안을 새로 고치고 다시 시도하세요.",
    ),
    "g_dex_history_record_failed": MessageLookupByLibrary.simpleMessage(
      "스왑이 제출되었으나 내역 업데이트에 실패했습니다. 다시 제출하지 마세요.",
    ),
    "g_dex_smart_account_fees": MessageLookupByLibrary.simpleMessage(
      "네트워크 수수료는 이 스마트 계정에서 지불됩니다.",
    ),
    "g_dex_spending_account": MessageLookupByLibrary.simpleMessage("지출 계정"),
    "g_dex_use_smart_account": MessageLookupByLibrary.simpleMessage(
      "스마트 계정 사용",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("코드 재전송"),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage("생체 인식 스캔 안내"),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "인증을 위해 지문 또는 얼굴을 스캔하세요.",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("안내"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("설정하기"),
    "g_face_7": MessageLookupByLibrary.simpleMessage("계속하려면 얼굴 또는 지문을 스캔하세요."),
    "g_face_8": MessageLookupByLibrary.simpleMessage("돌아가기"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage("Google OTP"),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator 앱으로 QR 코드 스캔",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "또는 키를 수동으로 입력:",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage("6자리 인증 코드 입력"),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "지갑 이체 확인 시 Google OTP 인증이 필요합니다.",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "잘못된 코드, 다시 시도해주세요",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google OTP 미설정",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage("연결 성공"),
    "g_history_clear_dates": MessageLookupByLibrary.simpleMessage("날짜 지우기"),
    "g_history_export_all": MessageLookupByLibrary.simpleMessage(
      "로컬 기록 일치 항목 내보내기 (CSV)",
    ),
    "g_history_export_error": MessageLookupByLibrary.simpleMessage(
      "거래 내역을 내보낼 수 없습니다. 다시 시도해 주세요.",
    ),
    "g_history_local_scope": MessageLookupByLibrary.simpleMessage(
      "필터 및 CSV 내보내기에는 이 장치에 저장된 모든 일치하는 기록이 포함됩니다. 최신 블록체인 활동을 동기화하려면 자산을 열어 주세요.",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("프로필"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("뉴스"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("검증"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("친구 초대"),
    "g_home_market": MessageLookupByLibrary.simpleMessage("시장"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("취소됨"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "네트워크 연결을 확인하고 다시 시도하세요",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "구매 가능한 상품이 없습니다",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage("구매 복원"),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage("구매 복원 중…"),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("다시 시도"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "스토어를 사용할 수 없습니다",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("구매"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("삭제 실패!"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("가스 한도"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("더 이상 없음"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("로딩 중 "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("주소록"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("지갑 가져오기"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("관리"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("새 주소"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("삭제"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("저장"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("복사"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("지갑 생성/가져오기"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("테마"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("시스템"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("라이트"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("다크"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("지갑 목록"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("데이터 없음"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("유효하지 않은 금액"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("메인 지갑"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("거래 성공"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("비밀번호가 틀렸습니다"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("테스트넷"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("메인넷"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("시스템 언어"),
    "g_key_15": MessageLookupByLibrary.simpleMessage("메인 지갑으로 설정"),
    "g_key_155": MessageLookupByLibrary.simpleMessage("지갑 주소"),
    "g_key_156": MessageLookupByLibrary.simpleMessage("스캔하여 주소 복사"),
    "g_key_159": MessageLookupByLibrary.simpleMessage("추가"),
    "g_key_16": MessageLookupByLibrary.simpleMessage("인증 지갑 선택"),
    "g_key_163": MessageLookupByLibrary.simpleMessage("심볼"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("붙여넣기"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("체인 선택"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("거래 실패"),
    "g_key_179": MessageLookupByLibrary.simpleMessage("내 지갑 주소입니다"),
    "g_key_181": MessageLookupByLibrary.simpleMessage("기타"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("저장 완료"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("성공"),
    "g_key_192": MessageLookupByLibrary.simpleMessage("지갑을 삭제하시겠습니까?"),
    "g_key_193": MessageLookupByLibrary.simpleMessage("활성"),
    "g_key_195": MessageLookupByLibrary.simpleMessage("카메라 접근 권한이 없습니다."),
    "g_key_196": MessageLookupByLibrary.simpleMessage("탐색기"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("최대"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("자산"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("원장이 비어 있습니다!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("거래 개요"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "링크 오류, QR 코드를 다시 스캔하세요.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("비밀번호 변경"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("기존 비밀번호"),
    "g_key_208": MessageLookupByLibrary.simpleMessage("잔액 동기화 중..."),
    "g_key_209": MessageLookupByLibrary.simpleMessage("개인키"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("지갑 비밀번호 입력"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("개인키 오류"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("시장 정보"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage("비밀번호가 일치하지 않습니다."),
    "g_key_29": MessageLookupByLibrary.simpleMessage("잔액"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("추가 실패!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("받기"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("송금"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("받는 주소"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("QR 코드 스캔"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("지갑 주소 입력"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("사용 가능한 잔액"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("금액"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage("이 거래를 처리하기에 잔액이 부족합니다."),
    "g_key_48": MessageLookupByLibrary.simpleMessage("보내기"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("로드 실패!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("지갑"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("생성"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("보내는 주소"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("확인"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("취소"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("모든 토큰"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("설정"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "계정이 성공적으로 생성되었습니다",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage("계정 세부정보"),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage("계정 이름"),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "계정 이름을 입력하세요",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage("계정 유형"),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("활성"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "첫 번째 작업 추가",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage("작업 추가"),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "주소 계산 중...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "주소 계산에 실패했습니다. 다시 시도해주세요.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("승인하다"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("배치"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage("원자적 실행"),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "한 번에 여러 작업 실행",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "단일 작업으로 여러 트랜잭션 보내기",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage("일괄 실행 실패"),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "저장된 템플릿이 없습니다.",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage("일괄 작업"),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage("가스 절약"),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "템플릿으로 저장",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "제출 중...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "배치가 성공적으로 제출되었습니다.",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "템플릿 로드",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "템플릿 이름",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "템플릿 이름을 입력하세요.",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "템플릿이 저장되었습니다.",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage("템플릿"),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage("일괄 거래"),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "한 번의 거래로 승인 및 교환 — 더 이상 2단계 확인이 필요하지 않습니다.",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "원클릭 일괄 작업",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "ETH 대신 ERC-20 토큰으로 거래를 후원하거나 수수료를 지불하세요.",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "모든 토큰으로 가스 지불",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "개인 키를 분실한 경우 신뢰할 수 있는 연락처를 통해 액세스 복구",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "사회 회복",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "가스리스 트랜잭션을 지원하는 모듈식 ERC-7579 스마트 계정",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("에 의해"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("체인"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("체인 ID"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("변경"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage("상태 확인"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("출시 예정"),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "이것은 반사실적 주소입니다. 첫 번째 트랜잭션에 배포됩니다.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "스마트 어카운트 생성",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "첫 번째 스마트 계정 만들기",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage("세션 키 생성"),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("생성됨"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("맞춤"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "첫 번째 거래에서 계정이 자동으로 배포됩니다.",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("배포됨"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("배포 중..."),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "배포는 첫 번째 트랜잭션에서 자동으로 발생합니다.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "향상된 기능을 갖춘 차세대 이더리움 계정을 경험해보세요",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("세부정보"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "하이브리드 EOA/스마트 어카운트 - 배포가 필요하지 않습니다.",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("오류"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage("추정 가스"),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage("일괄 실행"),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("만료됨"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("만료"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("공장"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("무료"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "기본값을 사용하여 가스 추정에 실패했습니다.",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("가스 지불"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "가스 지불 옵션",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage("가스 후원"),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("무가스"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "무가스 거래 및 일괄 작업",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "ZeroDev의 플러그인 지원이 포함된 모듈형 계정",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("라벨"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage("마지막 활동"),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage("내 스마트 어카운트"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "아직 스마트 계정이 없습니다.",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "필터와 일치하는 계정이 없습니다.",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "추가된 작업이 없습니다.",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage("세션 키 없음"),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage("배포되지 않음"),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "스마트 계정 생성(무료, ETH 필요 없음)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "자금을 조달하세요 - EVM 토큰을 받으세요",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Paymaster로 가스 없이 거래하세요",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("운영"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("소유자"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "토큰으로 가스 지불",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "ETH로 가스를 지불하세요",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("다음으로 결제"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage("ETH로 결제"),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "체인 지원",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "가용성 확인 중...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "체인 커버리지",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "거래 가스 수수료 지불 방법을 선택하세요.",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "예상 비용",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "가스 옵션 로드 실패",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage("다시 시도"),
    "g_key_aa_paymaster_unavailable": MessageLookupByLibrary.simpleMessage(
      "가스 후원 기능이 아직 사용할 수 없습니다. 가스는 계정 잔액으로 지불해 주세요.",
    ),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("보류 중"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("허가"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage("미리보기 주소"),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("준비"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage("수신주소"),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("재시도"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("취소"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "이 세션 키를 취소하시겠습니까? 승인된 DApp은 더 이상 거래를 실행할 수 없습니다.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage("세션 키 취소"),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage("세션 키가 취소되었습니다."),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("취소됨"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "세션 키를 취소하는 중...",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "고급 보안 기능을 갖춘 다중 서명 계정",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("저장됨"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage("체인 선택"),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Paymaster 선택",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("선택됨"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "스마트 계정을 사용하여 토큰 보내기",
    ),
    "g_key_aa_send_failed": MessageLookupByLibrary.simpleMessage("거래 실패"),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1일"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1시간"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30일"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7일"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "예: 100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "최대 금액",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "이 키의 권한을 이해합니다",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "승인된 DApp 계약과 상호 작용",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "세션 키 생성 실패",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "세션 키가 생성되었습니다",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "예: Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "레이블 / DApp 이름",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "세션 키 세부정보",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage("유효 기간"),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "높은 위험 — 검증된 DApp만 사용",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage("세션 키"),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "스마트 계정에 대한 임시 액세스로 DApp에 권한을 부여하세요.",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "DApp 접근",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "전체 제어",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "전송만",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage("높은 위험"),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage("낮은 위험"),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "중간 위험",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "확인 전 권한을 검토하세요",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "권한 수준 선택",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "설정된 한도 내에서 토큰 전송",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "단일 소유자의 기본 스마트 계정 - 대부분의 사용자에게 권장됩니다.",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage("스마트 어카운트"),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage("스마트 지갑"),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage("지출 한도"),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage("후원 (무료)"),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("스마트 어카운트"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("총 가스"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("거래"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("모두 보기"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("주소"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage("이름을 입력하세요"),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage("주소를 입력하세요"),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage("코인 유형을 선택하세요"),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("주소 편집"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage("삭제 완료"),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("코인 선택"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("코인 검색"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage("고급 기능"),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("활성"),
    "g_key_airdrop_discover": MessageLookupByLibrary.simpleMessage("탐색"),
    "g_key_airdrop_distribute": MessageLookupByLibrary.simpleMessage("배포"),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("종료됨"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "확인된 캠페인이 없습니다",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("대기 중"),
    "g_key_airdrop_sources": MessageLookupByLibrary.simpleMessage("소스"),
    "g_key_airdrop_sources_hint": MessageLookupByLibrary.simpleMessage(
      "소스를 열어 제공자 유지 관리 캠페인 디렉토리를 탐색하세요.",
    ),
    "g_key_airdrop_thirdparty_warning": MessageLookupByLibrary.simpleMessage(
      "제3자 캠페인은 악성일 수 있습니다. 서명하기 전에 프로젝트 도메인과 거래 세부 정보를 확인하세요.",
    ),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage("에어드롭"),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("upcoming"),
    "g_key_badge_hot": MessageLookupByLibrary.simpleMessage("인기"),
    "g_key_badge_live": MessageLookupByLibrary.simpleMessage("실시간"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage("수신자 추가"),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage("방송 중..."),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage("전체 삭제"),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "일괄 전송 확인",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("계속"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "CSV 형식: 주소,금액,라벨",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("완료"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "가스 추정 중...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "일괄 전송은 EVM 체인만 지원",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage("CSV 내보내기"),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage("일괄 전송 도움말"),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage("CSV 가져오기"),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "메모는 선택사항입니다",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "가스 요금을 낮추려면 Multicall3을 사용하세요.",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "지원되는 토큰 없음",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage("수신자"),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage("토큰 선택"),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "하나의 트랜잭션으로 여러 주소에 토큰 전송",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("서명 중..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "수신자를 삭제하려면 왼쪽으로 스와이프하세요.",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage("일괄 전송"),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage("총 금액"),
    "g_key_block_explorer_optional": MessageLookupByLibrary.simpleMessage(
      "블록 탐색기 URL (선택 사항)",
    ),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "체인은 지원되지 않습니다",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("가장 저렴"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "예상 수령액",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("가장 빠름"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage("견적 받기"),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage("브릿지 내역"),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "이용 가능한 경로 없음",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage("추천"),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("새로고침"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("경로"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "체인 검색...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("선택"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage("토큰 선택"),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("슬리피지"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "완료됨",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage("실패"),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "진행 중",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage("보류 중"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("브릿지"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage("브릿지 실패"),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage("거래 처리 중"),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage("브릿지 성공"),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "잠금 기간",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "환매를 제출하기 전에 잠금 기간이 만료되었는지 확인하세요.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC 아직 잠금 중",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage("vBTC 환매"),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "잠금 해제됨 — 환매 준비 완료",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "위험을 이해하고 진행하겠습니다",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "스테이킹 계속하기",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "작동 방식",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC는 타임락이 만료될 때까지 잠금됩니다. 아래 인터페이스에서 프로세스를 완료하세요.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "BTC는 스테이킹 기간 동안 잠금됩니다. 조기 출금은 불가능합니다.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "잠금은 비트코인 OP_CHECKLOCKTIMEVERIFY(CLTV)로 강제되며 우회할 수 없습니다.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "스마트 컨트랙트 위험: 감사를 받았지만, 어떤 프로토콜도 완전히 위험이 없지 않습니다.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "최소 스테이킹: 0.001 BTC. 최소 잠금 기간: 0.125일 (약 3시간).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "위험 경고",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "BTC는 타임락(CLTV)이 포함된 2-of-2 멀티시그 주소에 잠금되며, 귀하의 키와 N42 캐니스터 키로 보호됩니다.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "BTC 잠금",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "온체인 확인 후 지갑에 1:1 비율로 vBTC가 발행됩니다.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "vBTC 발행",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "vBTC를 보유하여 스테이킹 보상을 받으세요. vBTC는 DeFi 프로토콜에서도 사용 가능합니다.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "보상 획득",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "잠금 기간이 만료되면 vBTC를 소각하여 원래 BTC를 돌려받으세요.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "잠금 해제 후 환매",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "BTC 자기수탁 스테이킹",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("확인"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. NFT 지원 토큰 선택",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. NFT 탭으로 이동",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. 소각할 NFT 선택",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. \"소각\" 버튼 누르기",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("단계:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "NFT를 소각하려면 NFT 상세 페이지에서 \"소각\" 버튼을 눌러주세요.",
    ),
    "g_key_chain_presets": MessageLookupByLibrary.simpleMessage(
      "인기 있는 네트워크 (탭하여 채우기)",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "이 체인은 아직 전송을 지원하지 않습니다. 계속 지켜봐 주시기 바랍니다",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "모든 자산이 1달러 미만입니다.",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage("기타 자산"),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "모두 표시하려면 탭하세요.",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("최근"),
    "g_key_dapp_connect_account": MessageLookupByLibrary.simpleMessage("계정"),
    "g_key_dapp_connect_desc": MessageLookupByLibrary.simpleMessage(
      "이 사이트는 지갑 주소를 확인하고 거래를 제안받는 것을 요청하고 있습니다. 사용자의 승인 없이는 자금을 이동할 수 없습니다.",
    ),
    "g_key_dapp_connect_title": MessageLookupByLibrary.simpleMessage("지갑 연결"),
    "g_key_device_security_warning_message": MessageLookupByLibrary.simpleMessage(
      "이 기기는 루팅되었거나 탈옥된 것으로 보입니다. 보안이 손상된 기기에서 지갑을 사용하면 키 도난과 무단 접근의 위험이 커집니다. 주의하여 진행하세요.",
    ),
    "g_key_device_security_warning_title": MessageLookupByLibrary.simpleMessage(
      "기기 보안 경고",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "승인되었습니다! 계속하려면 교환을 탭하세요.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage("정확한 금액"),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage("무제한"),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "무제한 승인: 라우터가 언제든지 이 토큰을 사용할 수 있습니다. 표준적인 방법이지만 계약이 침해될 경우 위험합니다.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("승인 중…"),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage("최적 경로"),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage("최적 소스"),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("체인"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage("스왑 확인"),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage("가스 추정"),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage("DEX 내역"),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage("최소 접수됨"),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("토큰 없음"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "토큰을 찾을 수 없음",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage("가격 차트"),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage("가격 영향"),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage("견적 실패"),
    "g_key_dex_quote_unavailable": MessageLookupByLibrary.simpleMessage(
      "교환 가격 제안 서비스가 일시적으로 사용 불가입니다. 나중에 다시 시도하세요.",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "심볼 / 이름 / 주소 검색",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("선택"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage("최대 미끄러짐"),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage("확인됨"),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("실패"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage("대기 중"),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("견적됨"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("스왑"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "스왑이 성공적으로 제출되었습니다",
    ),
    "g_key_dex_tokens_offline": MessageLookupByLibrary.simpleMessage(
      "토큰 서비스가 사용 불가합니다. 제한된 오프라인 목록을 표시합니다.",
    ),
    "g_key_dex_untrusted_router": MessageLookupByLibrary.simpleMessage(
      "스왑이 차단됨: 라우터 주소가 인식되지 않습니다. 안전을 위해 이 거래가 취소되었습니다.",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("지불 금액"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage("받는 금액"),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage("활성 상품"),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage("일괄"),
    "g_key_earn_best_apy": MessageLookupByLibrary.simpleMessage("최고의 APY"),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("소각"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("N 구매"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "N42 프로토콜로 N 구매",
    ),
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage(
      "검증된 제3자 캠페인을 찾으세요",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage("크로스체인 전송"),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "일일 블록체인 포인트",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("DEX 스왑"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("가스"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage("스테이킹 시작"),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("레저"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "APY 로딩 중...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("채굴"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("더 많이 벌기"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "네이티브 솔라나 스테이킹",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "활성 포지션 없음",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "노드 채굴에 참여하여 보상을 받으세요",
    ),
    "g_key_earn_perps": MessageLookupByLibrary.simpleMessage("퍼프스"),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage("빠른 도구"),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage("추천"),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage("스왑 유형 선택"),
    "g_key_earn_stablecoin_deposit": MessageLookupByLibrary.simpleMessage("예치"),
    "g_key_earn_stablecoin_desc": MessageLookupByLibrary.simpleMessage(
      "USDC / USDT / DAI에 대해 매일 수익을 얻으세요",
    ),
    "g_key_earn_stablecoin_empty": MessageLookupByLibrary.simpleMessage(
      "현재 안정화 토큰 시장이 없습니다",
    ),
    "g_key_earn_stablecoin_title": MessageLookupByLibrary.simpleMessage(
      "스테이블코인 수익",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Lido로 ETH 스테이킹",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("스왑"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("수익"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage("총 수익"),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("전체 보기"),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "해결된 주소가 업데이트되었습니다.",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("고급"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("연회비"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("가능"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("기본 가격"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "이용 가능 여부 확인 중...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("커밋"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage("커밋 실패"),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "등록 커밋이 만료되었습니다. 등록 프로세스를 다시 시작하세요.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage("커밋 중..."),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage("갱신 확인"),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage("확인 및 전송"),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage("ENS 확인"),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage("주소 복사됨"),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage("현재 만료"),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("일 남음"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      ".eth 도메인 이름 등록 및 관리",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage("ENS 이름 감지됨"),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("만료됨"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("만료"),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage("등록기간 연장"),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("실패"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage("등록 마무리 중"),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage("ENS 시작하기"),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      ".eth 이름을 받으세요",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "잘못된 주소(0x + 40개의 16진수 문자여야 함)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "잘못된 ENS 이름",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("이제 당신 것입니다!"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "등록하는 동안 앱을 열어두세요",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Web3 신원 관리",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage("최소 3자"),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("내 도메인"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("ENS 이름"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage("새로운 만료"),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage("새 소유자 주소"),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "아직 도메인이 없습니다.",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("소유자"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage("기다려주세요"),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage("프리미엄 이름"),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage("가격 내역"),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("기본"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "기본 이름이 설정되었습니다.",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage("처리 중..."),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage("ENS 등록"),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("등록"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Ethereum의 분산 신원",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage("등록 실패"),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage("지금 등록하세요"),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage("등록 중..."),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage("등록정보"),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "등록기간",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "만료 알림 활성화",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "만료 30일, 7일, 1일 전에 알림",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("갱신"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage("도메인 등록 연장"),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage("갱신 성공"),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "확인된 주소",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage("ENS 확인 중..."),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("검색"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "사용 가능한 .eth 이름 찾기",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(".eth 이름 검색"),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "검색하려면 ENS 이름을 입력하세요.",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "검색 및 등록",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage("ENS 검색"),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "자신의 주소로는 전송할 수 없습니다",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage("이더리움 네임 서비스"),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage("기본으로 설정"),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage("표준 이름"),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "등록 시작",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("1단계"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("2단계"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("3단계"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "하위 도메인 생성",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "하위 도메인이 생성되었습니다.",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "하위 도메인 삭제",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "이 하위 도메인은 영구적으로 삭제됩니다.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "하위 도메인이 삭제되었습니다.",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "아직 하위 도메인이 없습니다.",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "문자, 숫자, 하이픈만 사용하세요.",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "하위 도메인 라벨",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "예를 들어 블로그, 메일, 앱",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage("소유자 주소"),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "현재 지갑을 사용하려면 비워두세요.",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("하위 도메인"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("성공!"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage("제안"),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage("텍스트 기록"),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ENS 관리자"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("합계"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("환승"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "소유권을 다른 주소로 이전",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage("전송 성공"),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "이전은 되돌릴 수 없습니다. 새 소유자 주소가 올바른지 확인하세요.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "다른 이름을 사용해 보세요",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "ENS 등록은 2단계 프로세스입니다.",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage("이용 불가"),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("잠깐"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "대기 기간으로 전방 공격 방지",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "대기 기간으로 인해 선행 실행이 방지됩니다.",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("기다리는 중..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "진행하기 전에 확인된 주소를 검증해 주세요. ENS 이름은 소유자에 의해 이전되거나 변경될 수 있습니다.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("년"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("년"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage("당신의 신원"),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage("응답 데이터 파싱 오류!"),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Dio 오류"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage("요청 구문 오류"),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage("인증되지 않음, 로그인하세요"),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("접근 거부"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("요청 오류"),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage("요청 시간 초과"),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("서버 이상"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage("서비스가 구현되지 않음"),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("게이트웨이 오류"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage("서비스를 사용할 수 없음"),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage("게이트웨이 시간 초과"),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage("HTTP 버전이 지원되지 않음"),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage("요청 실패, 오류 코드:"),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "시스템이 바쁩니다. 나중에 다시 시도하세요",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage("요청 빈도가 너무 빠릅니다"),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage("디코딩 실패"),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage("거래가 이미 체인에 있습니다"),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage("인증서 설정 오류!"),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage("상태 코드 설정 오류!"),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("알 수 없는 오류!"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "네트워크 연결 시간 초과, 네트워크 설정을 확인하세요!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "서버 이상입니다. 나중에 다시 시도하세요!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "요청이 취소되었습니다. 다시 요청하세요!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage("키스토어 내보내기"),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage("백업 팁"),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "비밀번호 관리 도구를 사용하여 저장하세요.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("복사됨"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage("복사 취소됨"),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage("신원 지갑"),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "암호화된 개인키 파일.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage("가져오기 방법"),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage("키스토어 파일"),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "키스토어 정보를 입력하세요.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage("개인키 내보내기"),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "키스토어와 비밀번호를 획득하면 지갑 자산을 완전히 통제할 수 있습니다.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "주의해서 기록하고 안전한 장소에 보관하세요. 여러 개의 실물 사본을 보관하는 것이 가장 안전한 저장 방법입니다.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "개인키를 분실하면 복구할 수 없습니다. 물리적으로 백업하고 안전하게 보관하세요.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage("오프라인 저장"),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "안전하지 않은 이메일, 메모장, 네트워크 드라이브 또는 채팅 소프트웨어에 저장하지 마세요.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "네트워크 전송을 사용하세요",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "네트워크 도구를 통해 전송하세요. 해커가 획득하면 복구할 수 없는 경제적 손실이 발생합니다",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage("도구를 사용하여 저장"),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "이 파일과 비밀번호를 얻는 사람은 누구든 제 자산을 완전히 제어할 수 있습니다 — 손실은 영구적이며 복구할 수 없습니다",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "내보내기를 확인하려면 지갑 비밀번호를 입력하세요",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "개인 키를 보려면 지갑 비밀번호를 입력하세요",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("필터"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("가스 알림"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage("이상 알림"),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage("이하 알림"),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("저장"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "임계값 (Gwei)",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("기본 수수료"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("빠름"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "가스 가격은 네트워크 수요에 따라 변동됩니다. 낮은 가스 = 느린 확인, 높은 가스 = 빠른 확인.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("최대 수수료"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage("네트워크 혼잡"),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage("네트워크 여유"),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage("네트워크 정상"),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage("가격 추세"),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage("우선 수수료"),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "실시간 가스 가격",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage("가스 설정"),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("느림"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("표준"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("가스 트래커"),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "계정을 이미 가져왔습니다.",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("추가"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage("계정 추가"),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "주소가 복사되었습니다",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "연결하기 전에 장치가 잠금 해제되어 있고 Bluetooth가 활성화되어 있는지 확인하십시오.",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("앱 확인"),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "새 장치 연결",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "키스톤(QR)을 사용한 에어갭",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Connect Ledger(블루투스)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Trezor(USB) 연결",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("연결됨"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage("연결 중..."),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("연결 끊기"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("뒤로"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "키스톤 연결",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "거래에 서명하려면 Keystone 장치로 이 QR 코드를 스캔하세요.",
    ),
    "g_key_hw_keystone_scan_response_hint":
        MessageLookupByLibrary.simpleMessage(
          "Keystone 장치에 표시된 QR 코드를 카메라로 향하게 하세요.",
        ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("키스톤 서명 스캔"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "계정을 가져오려면 Keystone 장치에서 QR 코드를 스캔하세요.",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Keystone 응답을 스캔하려면 탭하세요.",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("더 불러오기"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "계정 불러오는 중...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "요청 시 기기에서 확인해주세요",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "계정을 찾을 수 없음",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "현재 열려 있는 앱이 없습니다.",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "기기가 연결되지 않음",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "연결되지 않음",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("제거"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage("장치 제거"),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage("저장된 장치"),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "지원되는 장치",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("오늘"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Trezor에 연결하지 못했습니다. USB가 연결되어 있는지 확인하세요.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Trezor 연결",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor가 성공적으로 연결되었습니다.",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Trezor에 연결하는 중...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "USB 케이블을 통해 Trezor 장치를 연결하고 잠금을 해제하세요.",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage("계정 보기"),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage("지갑 계정"),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("어제"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "현재 통화 지갑이 이미 존재합니다.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "키스토어를 읽을 수 없습니다",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("키스토어"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("로그인"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("로그아웃"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage("앱을 종료하시겠습니까?"),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "사용 가능한 포인트",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "오늘 체크인 완료",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage("체크인"),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage("완료"),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "체크인 실패",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "N42에서 체크인 확인됨",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("복사"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "일일 체크인",
    ),
    "g_key_loyalty_earn_points": m28,
    "g_key_loyalty_empty_leaderboard": MessageLookupByLibrary.simpleMessage(
      "리더보드가 비어 있습니다",
    ),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage("기록"),
    "g_key_loyalty_invite_description": MessageLookupByLibrary.simpleMessage(
      "당신의 추천 코드 공유",
    ),
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "친구 초대",
    ),
    "g_key_loyalty_leaderboard": MessageLookupByLibrary.simpleMessage("순위표"),
    "g_key_loyalty_no_history": MessageLookupByLibrary.simpleMessage(
      "포인트 기록 없음",
    ),
    "g_key_loyalty_no_referrals": MessageLookupByLibrary.simpleMessage(
      "아직 추천된 사람이 없습니다. 시작하려면 코드를 공유하세요.",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "사용 가능한 보상이 없습니다",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "사용 가능한 작업이 없습니다",
    ),
    "g_key_loyalty_no_wallet": MessageLookupByLibrary.simpleMessage("활성 지갑 없음"),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("추천"),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage("보상"),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("작업"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("포인트"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "총 획득 포인트",
    ),
    "g_key_loyalty_unavailable": MessageLookupByLibrary.simpleMessage(
      "서비스 사용 불가",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("사용됨"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("페이스북"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("트위터"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("레딧"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("브라우저"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("텔레그램"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("디스코드"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("유튜브"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("인스타그램"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("시가총액"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("거래량"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("총 공급량"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("유통량"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("소개"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("더 보기"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("링크"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("웹사이트"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage("체인 관리"),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("가능"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "스테이킹 필요",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage("시드 문구를 입력하세요"),
    "g_key_msgsign_btn": MessageLookupByLibrary.simpleMessage("서명"),
    "g_key_msgsign_empty": MessageLookupByLibrary.simpleMessage(
      "먼저 메시지를 입력하세요",
    ),
    "g_key_msgsign_failed": MessageLookupByLibrary.simpleMessage("서명 실패"),
    "g_key_msgsign_input_hint": MessageLookupByLibrary.simpleMessage(
      "서명할 메시지를 입력하세요",
    ),
    "g_key_msgsign_result": MessageLookupByLibrary.simpleMessage("서명"),
    "g_key_msgsign_title": MessageLookupByLibrary.simpleMessage("메시지 서명"),
    "g_key_msgsign_unsupported": MessageLookupByLibrary.simpleMessage(
      "이 체인에서는 메시지 서명이 아직 지원되지 않습니다",
    ),
    "g_key_msgsign_warning": MessageLookupByLibrary.simpleMessage(
      "완전히 신뢰할 수 있는 메시지에만 서명하세요. 악성 메시지는 귀하의 대리 권한을 부여하는 데 사용될 수 있습니다.",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("합계"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("이름"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("뒤로"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("거래 제출됨"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "잘못된 지갑 주소",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("잔액"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "이 작업은 되돌릴 수 없습니다. NFT는 소각 주소로 전송됩니다.",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("NFT 굽기"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("컬렉션"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("계약"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("설명"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "NFT를 로드하지 못했습니다. 다시 시도하려면 탭하세요.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("모두"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("비디오"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("바닥"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("NFT 갤러리"),
    "g_key_nft_hide_spam": MessageLookupByLibrary.simpleMessage("스팸 숨기기"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage("비문 #"),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "NFT를 찾을 수 없습니다.",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "사용 가능한 탐색기 링크가 없습니다.",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "비디오 재생이 지원되지 않습니다",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("서수"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "서수 전송은 아직 지원되지 않습니다.",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("수량"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "이름이나 컬렉션으로 검색",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("NFT 보내기"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana NFT 전송이 곧 시작됩니다",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("토큰 ID"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("유형"),
    "g_key_nft_uncategorized": MessageLookupByLibrary.simpleMessage("기타"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "비밀번호가 일치하지 않습니다.",
    ),
    "g_key_perps_read_only": MessageLookupByLibrary.simpleMessage(
      "읽기 전용 시장 데이터입니다. 이 버전에서는 주문 제출이 지원되지 않습니다.",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage("휴대폰 갤러리에서 선택"),
    "g_key_pubkey": MessageLookupByLibrary.simpleMessage("공개 키"),
    "g_key_receive_payment_request": MessageLookupByLibrary.simpleMessage(
      "결제 요청",
    ),
    "g_key_receive_request_line": m29,
    "g_key_remove_network": MessageLookupByLibrary.simpleMessage("네트워크 제거"),
    "g_key_remove_network_confirm": m30,
    "g_key_reset": MessageLookupByLibrary.simpleMessage("재설정"),
    "g_key_retry": MessageLookupByLibrary.simpleMessage("다시 시도"),
    "g_key_scan_pay_unsupported": MessageLookupByLibrary.simpleMessage(
      "결제 요청 토큰 또는 체인이 이 지갑에 없습니다",
    ),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "주의 사용",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "계약 보안을 확인하는 중...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "고위험 감지",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "고플러스",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "계약 확인 안전",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage("메모/메모"),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage("메모/메모(선택)"),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("QR 코드 공유"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("링크 공유"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage("공유 방법"),
    "g_key_sim_gas_estimate": m31,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "거래가 실패할 가능성이 높습니다",
    ),
    "g_key_sim_reverted_reason": m32,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage("거래 시뮬레이션 중…"),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage("거래 시뮬레이션 통과"),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "이 네트워크에서는 시뮬레이션을 사용할 수 없습니다.",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("채팅"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("활성"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "활성 포지션",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("금액"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "언스테이크 금액",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("연이율"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("평균 APY"),
    "g_key_stake_broadcast_unsupported": MessageLookupByLibrary.simpleMessage(
      "거래가 생성되었으나, 이 체인에 대해 지갑 내에서 거래를 브로드캐스트하는 기능은 아직 지원되지 않습니다.",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("수수료"),
    "g_key_stake_d_unbond": m33,
    "g_key_stake_days_remaining": m34,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "예상 일일 보상",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "예상 연간 보상",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage("스왑으로 이동"),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "리퀴드 스테이킹",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("액체"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "귀하의 유동 토큰은 DEX에서 직접 거래될 수 있습니다. Swap을 사용하여 기본 자산으로 다시 교환하세요.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage("최소 스테이킹"),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "스테이크를 해제할 활성 포지션이 없습니다.",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("잠금 없음"),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "아직 스테이킹 포지션이 없습니다",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "유효성 검사기를 찾을 수 없습니다.",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "지갑 주소를 사용할 수 없습니다.",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage("총 스테이킹 개요"),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage("내 포지션"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("프로토콜"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("보상"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "유효성 검사기 검색...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "검증인을 선택하세요",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "언스테이킹할 포지션을 선택하세요",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "검증인 선택",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage("정렬 기준"),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("스테이크"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("스테이킹됨"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "스테이킹 시작",
    ),
    "g_key_stake_submitted": MessageLookupByLibrary.simpleMessage(
      "스테이킹 거래가 제출되었습니다",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("스테이킹"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "거래가 성공적으로 준비되었습니다.",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage("언본딩 중"),
    "g_key_stake_unbonding_warning": m35,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("언스테이크"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage("업데이트 중..."),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("검증인"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "당신은 받게됩니다",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("완료"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("가스 가격"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("최대 가스 수수료"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("가스당 최대 수수료"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("대기 중"),
    "g_key_t_29": m36,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("실패"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("진행"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("지갑 비밀번호"),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage("지갑 비밀번호가 틀렸습니다"),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage("지갑 비밀번호를 입력하세요"),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("가스 수수료 비율"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage("최신 블록 가스 수수료 비율 평균"),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("출금"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage("0보다 큰 정수를 입력하세요."),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage("데이터 가져오기 실패"),
    "g_key_t_45": m37,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage("받는 주소 계정 확인"),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("찾기"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("계정 없음"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("입금"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("유효하지 않은 주소"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage("계정 인증 성공"),
    "g_key_t_52": m38,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "받는 주소에 계정이 없으며, 첫 송금 시 최소 10XRP가 필요합니다",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("사용된 가스"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("가스"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage("추가"),
    "g_key_token_discovery_add_selected": m39,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "토큰이 추가되었습니다",
    ),
    "g_key_token_discovery_banner": m40,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "모두 선택 취소",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "새 토큰을 찾을 수 없습니다.",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage("무시"),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "모두 선택",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "발견된 토큰",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("거래 내역"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("거래 상세"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage("거래 영수증은 내역에서 확인하세요"),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("지출 금액"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("받는 금액"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage("시작일"),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage("기간"),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage("종료일"),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage("방향"),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "필터와 일치하는 거래가 없습니다.",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage("최신 버전 발견"),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("즉시 업데이트"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("새 버전 발견"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage("이미 최신 버전입니다"),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage("시드 문구 보기"),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "시드 문구를 다시 입력하세요.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("계정 가져오기"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("계정 생성"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("모두 완료되었습니다!"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "이제 지갑을 마음껏 사용할 수 있습니다.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("시작하기"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("지금은 건너뛰기"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "지금은 시드 문구 백업을 건너뛸 수 있으며, 필요할 때 언제든지 설정에서 다시 할 수 있습니다.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage("바로 생성"),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage("생성 완료"),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "지갑 상세 정보를 확인하거나 키스토어를 내보내려면 사이드바 > 지갑 관리로 이동하세요",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage("키스토어 내보내기"),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage("백업하여 지갑을 보호하세요"),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "키스토어는 보안 인증서와 관련 개인키의 저장소입니다.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "1단계: 지갑 관리로 이동합니다.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "2단계: 지갑 주소를 선택합니다.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "3단계: 키스토어 내보내기를 누릅니다.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage("지갑 관리로 이동"),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage("홈으로 돌아가기"),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("지갑 추가"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "시드 문구를 사용하여 지갑을 생성합니다.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage("지갑 이름 입력"),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "지갑 시드 문구를 백업하지 않았습니다!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("지금 백업"),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage("지갑 비밀번호 설정"),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage("지갑 백업"),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage("다음 시드 문구를 기록하세요"),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("시작"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "인터넷에 연결된 기기는 정보를 노출할 수 있습니다. 시드 문구를 적어서 안전하게 보관하는 것을 권장합니다.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "경고: 시드 문구를 누구에게도 공개하지 마세요. N42Wallet은 절대로 이 정보를 요청하지 않습니다. 매우 주의하고 오프라인에서 안전하게 보관하세요. 시드 문구가 노출되면 모든 자산을 잃고 복구할 수 없습니다.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "경고: 시드 문구는 지갑 자산을 복구하는 유일한 방법입니다.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("다음 단계"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage("클릭하여 시드 문구 보기"),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "주변에 다른 사람이나 카메라가 없는지 확인하세요",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage("시드 문구 확인"),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage("지갑 정보"),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("지갑 이름"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "먼저 지갑 시드 문구를 백업하세요!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage("시드 문구 확인"),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage("시드 문구를 입력하세요."),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("문구 설정"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "시드 문구를 기록하고 안전하게 보관하세요. 암호화폐 지갑을 가져오거나 복구할 때 필요합니다.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage("지갑 편집"),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("시간"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("결과"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage("거래 해시"),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("추가"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("경로"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("블록"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("값"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("논스"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("가속"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("메모"),
    "g_key_wallet_m1": m41,
    "g_key_wallet_m19": m42,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "현재 토큰이 추가되지 않았습니다.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "단어 사이에 공백을 두고 시드 문구를 입력하세요",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("지갑 가져오기"),
    "g_key_wallet_m3": m43,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage("현재 토큰 잔액이 부족합니다."),
    "g_key_wallet_m5": m44,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("서명 오류"),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage("지갑 관리"),
    "g_key_wallet_tx_replace_hint": MessageLookupByLibrary.simpleMessage(
      "동일한 nonce와 약 20% 높은 가스를 사용하여 교체 거래가 브로드캐스트됩니다. 원래 거래가 여전히 보류 중일 때만 적용됩니다.",
    ),
    "g_key_wallet_tx_replace_submitted": MessageLookupByLibrary.simpleMessage(
      "교체 거래가 제출되었습니다",
    ),
    "g_key_wallet_tx_speedup": MessageLookupByLibrary.simpleMessage("속도 증가"),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "이더리움 주소를 입력하세요(0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "감시 전용 지갑은 거래를 보내거나 서명할 수 없습니다.",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage("시계 지갑"),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "개인 키 없이 모든 EVM 주소 추적",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("예약됨"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("기본 준비금"),
    "g_key_xml_11": m45,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("증분 준비금"),
    "g_key_xml_22": m46,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage("소유 객체 수"),
    "g_key_xml_33": m47,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage("총 예약 금액 계산 방법"),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "총 준비금 = 기본 준비금 + (소유 객체 수 × 증분 준비금)",
    ),
    "g_live_ended": MessageLookupByLibrary.simpleMessage("라이브 스트림이 종료되었습니다"),
    "g_live_enter_room_failed": m48,
    "g_live_follow": MessageLookupByLibrary.simpleMessage("팔로우"),
    "g_live_follow_wip": MessageLookupByLibrary.simpleMessage("팔로우 기능 준비 중"),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID 및 Face ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("제스처 비밀번호"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage("제스처 비밀번호 설정"),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage("제스처 패턴을 그려주세요"),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage("제스처 패턴을 확인해주세요"),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage("현재 제스처를 그려주세요"),
    "g_lock_key21": m49,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage("제스처 비밀번호 재설정"),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage("시도 횟수 초과, 다시 시도해주세요"),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage("지갑 비밀번호를 추가하시겠습니까?"),
    "g_lock_key25": m50,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage("이체 확인"),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "지갑 이체를 확인할 때 생체 인증(얼굴 인식/지문)을 요구합니다.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage("제스처 비밀번호 미설정"),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "지갑 이체 확인 시 제스처 인증이 필요합니다.",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("성공"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("실패"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage("생체 인식이 활성화되지 않았습니다"),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage("생체 인증을 추가하시겠습니까?"),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage("30D 변경"),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("7D 변화"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("시장 깊이"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "아직 관심 목록이 없습니다.",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("높은 24시간"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage("유동성 점수"),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("낮은 24시간"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("뉴스"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage("차트 데이터 없음"),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage("결과 없음"),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("순위"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("검색"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage("동전 검색..."),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("인기 급상승"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage("관심 목록"),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "유효성 검사기 비활동 점수가 높습니다. 페널티를 피하려면 노드 상태를 확인하세요.",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("N 잠금 해제?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage("클라우드 검증 활동"),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage("검증 설정"),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage("백그라운드 확인 음악"),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("기본값"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("음소거"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "백그라운드 확인이 활성화되면 음악이 백그라운드에서 재생됩니다. 음악이 중지되면 인증도 중지됩니다.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("귀하의 등급"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "설정에는 소량의 가스가 필요합니다.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "N42Wallet에서 그룹 노드에 성공적으로 참여했습니다. 링크를 공유하여 친구를 초대하고 노드를 활성화하여 검증을 시작하세요!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage("친구에게 공유"),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("계속"),
    "g_mining_key63": m51,
    "g_mining_key73": m52,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "@N42Wallet에서 노드를 설정하고 모바일 기기에서 검증을 시작했습니다! 함께하세요. 탈중앙화 미래는 모바일입니다!",
    ),
    "g_mining_key76": m53,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("미네랄"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("노드"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("네트워크"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "클라우드 마이닝을 위해 테스트넷과 메인넷 간을 전환하세요.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage("768초 후 상환 가능."),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "그 전의 요청은 처리되지 않습니다.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("홈"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("오늘의 보상"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "아래 데이터를 중요한 키로 취급하세요. 즉시 복사하여 신뢰할 수 있는 위치에 백업하는 것을 권장합니다.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("데이터 복사"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("비활성"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage("가져오기 성공"),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "암호화된 데이터는 비워둘 수 없습니다!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "비밀번호는 비워둘 수 없습니다!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "복호화 실패. 비밀번호가 올바른지 확인하세요!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "지원되지 않는 암호화 데이터 형식입니다!",
    ),
    "g_mining_key_109": m54,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage("어제의 보상"),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage("암호화된 데이터"),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("파일 가져오기"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "암호화된 데이터를 입력하세요.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("가져오는 중..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("확인"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "상환에는 시간이 걸립니다. 잠시만 기다려 주세요!",
    ),
    "g_mining_key_116": m55,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "보상은 매일 누적되며 ~0.5 N에 도달하면 N 지갑으로 전송됩니다.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("총 보상"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("채굴 가치"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage("작업 세부정보"),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("요약"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("활동"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage("채굴된 총 가치"),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage("검증 이후"),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("수익 횟수"),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage("검증된 값"),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("플랜 선택"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "잠금 해제 기간: 언제든지 잠금 해제 가능",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage("연간 최대 보상"),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage("보상 분배"),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("일일 한도"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("속도"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage("검증 플랜"),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage("결제 방법 선택"),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("결제 방법"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("N으로 결제"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("지갑 잔액"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "이 거래에 필요한 N이 부족합니다",
    ),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage("건너뛰시겠습니까?"),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "플랜 중 하나를 선택하기 전까지는 인증 보상을 받을 수 없습니다.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("비활성화됨"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("보상"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("더 보기"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage("검증 상태"),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("잠금을 해제하려면"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("건너뛰기"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("지난 7일"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage("누적된 보상"),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "N을 잠그고 검증 보상을 시작하세요.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage("받은 보상"),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("고급"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("엔트리"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("프로"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("풀노드"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("분/일"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("어드밴스드 노드"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("엔트리 노드"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("프로 노드"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage("하루 500블록~70분"),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("잠금 해제 날짜"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage("하루 100블록~15분"),
    "g_mining_key_71": m56,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage("검증당 128초"),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "테스트 체인이 업그레이드 중이며 일시적으로 블록을 검증할 수 없습니다.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "4일 연속 작업을 완료하지 않으면 수익이 없으며 패널티 위험이 있습니다.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("위험 점수"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("상환"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "먼저 검증자의 공개키와 개인키 쌍을 저장하세요.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("내보내기"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage("오늘의 확인 시간"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "송금에 필요한 자금이 부족합니다.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage("검증자 목록"),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage("검증자 가져오기"),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage("검증자가 이미 존재합니다"),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("저위험"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("중간 위험"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage("최근 7일 보상"),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("고위험"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "계약을 로딩 중이며 현재 검증할 수 없습니다. 잠시만 기다려 주세요!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage("안전 팁"),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage("백그라운드 검증"),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "개인키 또는 시드 문구를 안전하게 보관하세요.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "개인키 또는 시드 문구는 지갑 자산에 접근하는 유일한 자격 증명입니다.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "안전한 장소(종이, 비밀번호 관리자 등)에 보관하세요.",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "스크린샷을 찍거나, 인터넷에 업로드하거나, 누구와도 공유하지 마세요.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "분실하거나 유출되면 지갑 자산을 복구할 수 없습니다.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage("확인 및 저장"),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage("비밀번호 설정 및 암호화"),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage("암호화 비밀번호를 입력하세요"),
    "g_mining_key_98": m57,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "비밀번호가 올바른지 확인하기 위해 다시 입력하세요",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage("풀 노드 상세"),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("노드 ID"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS 연결됨"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage("WS 연결 끊김"),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage("WS 재연결 중"),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("만료"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage("잠금 해제 기간:"),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "언제든지 잠금 해제 가능",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage("뉴스가 없습니다."),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage("뒤로 가기 (안전)"),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage("어쨌든 계속"),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "이 웹사이트는 잠재적으로 악의적인 사이트로 식별되었습니다. 암호화폐 자산이나 개인 키를 훔치려 할 수 있습니다.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage("보안 경고"),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "의심스러운 URL:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage("거래 추가"),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("평균 비용"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage("구매 가격(USD)"),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("비용 기준"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("수량"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("저장"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage("미실현 손익"),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("24시간 변경"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "전체 보유 자산",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage("자산배분"),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage("최고 상승자"),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage("하락 순위"),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage("24시간 이사"),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "자산을 찾을 수 없습니다.",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("기타"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("합계"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("포트폴리오"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("총 가치"),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage("결과 추가"),
    "g_pred_amount_input": m58,
    "g_pred_balance": m59,
    "g_pred_buy": MessageLookupByLibrary.simpleMessage("매수"),
    "g_pred_cancel_refund": MessageLookupByLibrary.simpleMessage("취소 및 환불"),
    "g_pred_close_only": MessageLookupByLibrary.simpleMessage("마감만"),
    "g_pred_closed_waiting": MessageLookupByLibrary.simpleMessage("마감됨, 정산 대기"),
    "g_pred_confirm_resolve": MessageLookupByLibrary.simpleMessage("정산 확인"),
    "g_pred_confirm_resolve_msg": m60,
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage("예측 시작"),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("생성 중…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("마감"),
    "g_pred_err_amount_low": MessageLookupByLibrary.simpleMessage(
      "금액은 0보다 커야 합니다",
    ),
    "g_pred_err_insufficient_balance": MessageLookupByLibrary.simpleMessage(
      "잔액 부족",
    ),
    "g_pred_err_insufficient_shares": MessageLookupByLibrary.simpleMessage(
      "보유 지분 부족",
    ),
    "g_pred_err_invalid_outcome": MessageLookupByLibrary.simpleMessage(
      "잘못된 결과",
    ),
    "g_pred_err_invalid_state": MessageLookupByLibrary.simpleMessage(
      "시장이 이미 정산되었으므로, 이 작업은 허용되지 않습니다",
    ),
    "g_pred_err_market_closed": MessageLookupByLibrary.simpleMessage(
      "마켓이 마감되어 거래할 수 없습니다",
    ),
    "g_pred_err_market_not_found": MessageLookupByLibrary.simpleMessage(
      "마켓을 찾을 수 없습니다",
    ),
    "g_pred_err_not_resolved": MessageLookupByLibrary.simpleMessage(
      "마켓 미정산, 환급 불가",
    ),
    "g_pred_err_not_resolver": MessageLookupByLibrary.simpleMessage(
      "이 시장의 주최자만이 이 작업을 수행할 수 있습니다",
    ),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "유효한 결과가 2개 이상 필요합니다",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage("질문을 입력하세요"),
    "g_pred_err_slippage": MessageLookupByLibrary.simpleMessage(
      "슬리피지 초과, 다시 시도하세요",
    ),
    "g_pred_minutes": m61,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("아니오"),
    "g_pred_outcome_n": m62,
    "g_pred_outcome_win": m63,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("결과 옵션"),
    "g_pred_pick_winner": MessageLookupByLibrary.simpleMessage(
      "승리 결과를 선택해 정산 (자금은 결과에 따라 지급)",
    ),
    "g_pred_processing": MessageLookupByLibrary.simpleMessage("처리 중…"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("예측 게시"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "예측 질문, 예: 이번 판에서 누가 이길까요?",
    ),
    "g_pred_quote_info": m64,
    "g_pred_redeem_failed": m65,
    "g_pred_resolved": MessageLookupByLibrary.simpleMessage("정산 완료"),
    "g_pred_result_label": m66,
    "g_pred_sell_n": m67,
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage("무제한 (수동 마감)"),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("예"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("다운로드"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage("초대 코드"),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("초대됨"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("채굴 노드"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("보상 (N)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "클래식 채굴 (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "채굴 (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "채굴 인터페이스",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("공유"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("추천"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "친구를 추천하고 N 토큰을 받으세요!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("최대 "),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " 추천인이 검증을 시작하면 N을 받습니다!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("추천 방법"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("링크"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("코드"),
    "g_swap_key_14": m68,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage("코인 가격 조회 오류."),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage("진행 시 다음에 동의하게 됩니다 "),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage("이용약관."),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("완료"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "스왑이 곧 분배됩니다. 잠시만 기다려 주세요.",
    ),
    "g_swap_key_20": m69,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "노드 운영 비용: 그룹 검증 1-49 N 기본 노드: 50 N 프리미엄 노드: 100 N 프로 노드: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("만료"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("미결제"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage("결제 확인 중"),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("분배 예정"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("스왑 요약"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("새 잔액"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("지불 금액"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("날짜"),
    "g_swap_key_31": m70,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "스왑은 관련 체인 탐색기(Etherscan, BscScan, TRONSCAN 및 자체 탐색기)에서 확인할 수 있습니다.",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("N으로 스왑"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("스왑"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("받는 금액"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("스왑 미리보기"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("다시 시도"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage("악센트 색상"),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage("기본값으로 재설정"),
    "g_theme_mode": MessageLookupByLibrary.simpleMessage("외관"),
    "g_theme_style": MessageLookupByLibrary.simpleMessage("스타일"),
    "g_theme_style_custom": MessageLookupByLibrary.simpleMessage("맞춤"),
    "g_token_m_key_1": m71,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "누구나 기존 토큰의 가짜 버전을 포함하여 토큰을 만들 수 있습니다. 가져오기 전에 항상 토큰을 조사하세요.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("토큰"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("토큰 검색"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("체인 이름"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("체인 심볼"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("체인 ID"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("소수점"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage("커스텀 체인 추가"),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 정수"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("토큰 추가"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("형식 오류!"),
    "g_token_m_key_22": m72,
    "g_token_m_key_23": m73,
    "g_token_m_key_24": m74,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("토큰 가져오기"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("모든 네트워크"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("커스텀 토큰"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("토큰 주소"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("토큰 심볼"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("토큰 소수점"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("가져오기"),
    "g_token_m_key_chainid_conflict": MessageLookupByLibrary.simpleMessage(
      "이 Chain ID는 이미 다른 네트워크에서 사용 중입니다.",
    ),
    "g_token_m_key_chainid_mismatch": m75,
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("주의"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("고위험"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("안전"),
    "g_ui_aave_lending": MessageLookupByLibrary.simpleMessage("Aave V3 대출"),
    "g_ui_account_email": MessageLookupByLibrary.simpleMessage("계정 이메일"),
    "g_ui_algo_asset_add_fee": MessageLookupByLibrary.simpleMessage(
      "이 자산을 추가하려면 네트워크 수수료가 필요합니다. 추가를 계속하려면 추가를 탭하세요.",
    ),
    "g_ui_algo_asset_missing": m76,
    "g_ui_assistant_hint": MessageLookupByLibrary.simpleMessage(
      "잔액, 포트폴리오, 가스에 대해 문의하세요",
    ),
    "g_ui_back_code": MessageLookupByLibrary.simpleMessage("코드로 돌아가기"),
    "g_ui_back_email": MessageLookupByLibrary.simpleMessage("이메일로 돌아가기"),
    "g_ui_backup_create_save": MessageLookupByLibrary.simpleMessage(
      "백업 생성 및 저장",
    ),
    "g_ui_backup_empty": MessageLookupByLibrary.simpleMessage(
      "백업 파일에 지갑이 없습니다",
    ),
    "g_ui_backup_encryption_hint": MessageLookupByLibrary.simpleMessage(
      "백업은 AES-256 + PBKDF2로 암호화되어 있습니다. 올바른 비밀번호만이 복원을 가능하게 합니다.",
    ),
    "g_ui_backup_enter_password": MessageLookupByLibrary.simpleMessage(
      "백업 비밀번호를 입력하세요",
    ),
    "g_ui_backup_export": MessageLookupByLibrary.simpleMessage("클라우드 백업 내보내기"),
    "g_ui_backup_export_failed": MessageLookupByLibrary.simpleMessage(
      "백업을 생성할 수 없습니다. 다시 시도해 주세요.",
    ),
    "g_ui_backup_file": MessageLookupByLibrary.simpleMessage("백업 파일"),
    "g_ui_backup_file_access": MessageLookupByLibrary.simpleMessage(
      "선택한 파일에 접근할 수 없습니다",
    ),
    "g_ui_backup_import": MessageLookupByLibrary.simpleMessage("클라우드 백업 가져오기"),
    "g_ui_backup_import_failed": MessageLookupByLibrary.simpleMessage(
      "백업을 복원할 수 없습니다. 비밀번호와 백업 파일을 확인한 후 다시 시도하세요.",
    ),
    "g_ui_backup_import_result": m77,
    "g_ui_backup_import_wallets": MessageLookupByLibrary.simpleMessage(
      "지갑 가져오기",
    ),
    "g_ui_backup_invalid_file": MessageLookupByLibrary.simpleMessage(
      "유효한 N42Wallet 백업 파일이 아닙니다",
    ),
    "g_ui_backup_no_file": MessageLookupByLibrary.simpleMessage(
      "파일이 선택되지 않았습니다",
    ),
    "g_ui_backup_no_selection": MessageLookupByLibrary.simpleMessage(
      "백업할 유효한 지갑이 선택되지 않았습니다",
    ),
    "g_ui_backup_password": MessageLookupByLibrary.simpleMessage("백업 비밀번호"),
    "g_ui_backup_password_hint": MessageLookupByLibrary.simpleMessage(
      "강력한 백업 비밀번호 설정 (최소 8자)",
    ),
    "g_ui_backup_password_min": MessageLookupByLibrary.simpleMessage(
      "비밀번호는 최소 8자 이상이어야 합니다",
    ),
    "g_ui_backup_password_repeat": MessageLookupByLibrary.simpleMessage(
      "백업 비밀번호 다시 입력",
    ),
    "g_ui_backup_restore_hint": MessageLookupByLibrary.simpleMessage(
      "iCloud 드라이브 또는 Google 드라이브에 저장된 암호화된 백업에서 지갑을 복원하세요.",
    ),
    "g_ui_backup_restore_none": MessageLookupByLibrary.simpleMessage(
      "이 백업에서 지갑을 복원할 수 없습니다",
    ),
    "g_ui_backup_restore_password_hint": MessageLookupByLibrary.simpleMessage(
      "백업을 생성할 때 사용한 비밀번호를 입력하세요",
    ),
    "g_ui_backup_select_file_first": MessageLookupByLibrary.simpleMessage(
      "먼저 백업 파일을 선택하세요",
    ),
    "g_ui_backup_select_wallet": MessageLookupByLibrary.simpleMessage(
      "백업할 최소한의 지갑을 선택하세요",
    ),
    "g_ui_backup_select_wallets": MessageLookupByLibrary.simpleMessage(
      "백업할 지갑 선택",
    ),
    "g_ui_backup_share_subject": MessageLookupByLibrary.simpleMessage(
      "N42Wallet 백업",
    ),
    "g_ui_backup_warning": MessageLookupByLibrary.simpleMessage(
      "이 백업 파일에는 개인키/멘모닉, 지갑 비밀번호 및 지갑 설정이 포함되어 있습니다. 백업 파일과 비밀번호를 안전하게 보관하세요. 절대 누구에게도 공유하지 마세요.",
    ),
    "g_ui_balance_value": m78,
    "g_ui_base_fee_value": m79,
    "g_ui_buy_n_description": MessageLookupByLibrary.simpleMessage(
      "N42 프로토콜을 통해 N 구매",
    ),
    "g_ui_calldata_hex": MessageLookupByLibrary.simpleMessage("캘ldata (16진수)"),
    "g_ui_camera_permission": MessageLookupByLibrary.simpleMessage(
      "코드를 스캔하려면 카메라 권한이 필요합니다.",
    ),
    "g_ui_cancel_order": MessageLookupByLibrary.simpleMessage("주문 취소"),
    "g_ui_change_email": MessageLookupByLibrary.simpleMessage("이메일 변경"),
    "g_ui_checking_approval": MessageLookupByLibrary.simpleMessage("승인 확인 중…"),
    "g_ui_clipboard_clear": m80,
    "g_ui_clipboard_empty": MessageLookupByLibrary.simpleMessage(
      "클립보드가 비어 있습니다",
    ),
    "g_ui_coins_load_failed": MessageLookupByLibrary.simpleMessage(
      "코인 로딩에 실패했습니다. 다시 시도해 주세요.",
    ),
    "g_ui_confirm_password": MessageLookupByLibrary.simpleMessage("비밀번호 확인"),
    "g_ui_confirm_update": MessageLookupByLibrary.simpleMessage("업데이트 확인"),
    "g_ui_contract_info": MessageLookupByLibrary.simpleMessage("계약 정보"),
    "g_ui_create_wallet": MessageLookupByLibrary.simpleMessage("지갑 생성"),
    "g_ui_csv_header_only": MessageLookupByLibrary.simpleMessage(
      "데이터 행이 없음 (헤더만 감지됨).",
    ),
    "g_ui_csv_missing_fields": m81,
    "g_ui_csv_no_data": MessageLookupByLibrary.simpleMessage(
      "주석을 제거한 후 데이터를 찾을 수 없습니다.",
    ),
    "g_ui_custom_tag": MessageLookupByLibrary.simpleMessage("사용자 정의 태그..."),
    "g_ui_days": m82,
    "g_ui_destination_tag": MessageLookupByLibrary.simpleMessage("수신자 태그"),
    "g_ui_device_connected": m83,
    "g_ui_dex_description": MessageLookupByLibrary.simpleMessage(
      "Uniswap / 1inch / Jupiter를 통해 토큰 스왑",
    ),
    "g_ui_email_code_accepted": MessageLookupByLibrary.simpleMessage(
      "인증 코드 수락됨",
    ),
    "g_ui_email_code_sent": MessageLookupByLibrary.simpleMessage(
      "인증 코드 요청 전송됨",
    ),
    "g_ui_ens_price_failed": MessageLookupByLibrary.simpleMessage(
      "ENS 갱신 가격을 불러올 수 없습니다. 다시 시도해 주세요.",
    ),
    "g_ui_ens_renew_failed": MessageLookupByLibrary.simpleMessage(
      "ENS 갱신에 실패했습니다. 다시 시도해 주세요.",
    ),
    "g_ui_entry_price": MessageLookupByLibrary.simpleMessage("입장 가격"),
    "g_ui_expires_in": MessageLookupByLibrary.simpleMessage("만료 시간:"),
    "g_ui_fear_greed": MessageLookupByLibrary.simpleMessage("공포 및 탐욕"),
    "g_ui_file_picker_failed": MessageLookupByLibrary.simpleMessage(
      "파일 선택기를 열 수 없습니다. 다시 시도해 주세요.",
    ),
    "g_ui_file_read_failed": MessageLookupByLibrary.simpleMessage(
      "선택한 파일을 읽을 수 없습니다. 다시 시도해 주세요.",
    ),
    "g_ui_free_margin": MessageLookupByLibrary.simpleMessage("사용 가능"),
    "g_ui_gas_prediction": MessageLookupByLibrary.simpleMessage("다음 블록 가스 예측"),
    "g_ui_gas_value": m84,
    "g_ui_hours": m85,
    "g_ui_import_valid": m86,
    "g_ui_invalid_email": MessageLookupByLibrary.simpleMessage(
      "올바른 이메일 주소를 입력하세요",
    ),
    "g_ui_issues_label": MessageLookupByLibrary.simpleMessage("문제:"),
    "g_ui_keystone_paired": MessageLookupByLibrary.simpleMessage(
      "키스톤이 성공적으로 연결되었습니다",
    ),
    "g_ui_limit_orders": MessageLookupByLibrary.simpleMessage("지정가 주문"),
    "g_ui_limit_price": MessageLookupByLibrary.simpleMessage("지정가"),
    "g_ui_limit_price_pair": m87,
    "g_ui_limit_value": m88,
    "g_ui_liquidation_price": MessageLookupByLibrary.simpleMessage("청산 가격"),
    "g_ui_margin_utilization": MessageLookupByLibrary.simpleMessage("사용률"),
    "g_ui_markets_count": m89,
    "g_ui_memo": MessageLookupByLibrary.simpleMessage("메모"),
    "g_ui_mempool": MessageLookupByLibrary.simpleMessage("메모풀"),
    "g_ui_message": MessageLookupByLibrary.simpleMessage("메시지"),
    "g_ui_min_balance_value": m90,
    "g_ui_mnemonic_wallet": MessageLookupByLibrary.simpleMessage("멘모닉 지갑"),
    "g_ui_mpc_intro": MessageLookupByLibrary.simpleMessage(
      "소셜 계정으로 로그인하여 보안 MPC 지갑을 생성하세요. 개인 키는 암호화된 조각으로 분할되며, 시드 페이즈를 잃을 염려가 없습니다.",
    ),
    "g_ui_mpc_no_phrase": MessageLookupByLibrary.simpleMessage(
      "시드 페이즈가 필요 없습니다",
    ),
    "g_ui_mpc_security": MessageLookupByLibrary.simpleMessage(
      "MPC-TSS 기반. 개인 키는 디바이스, 서버, 복구 백업에 분할되어 암호화된 3개의 조각으로 저장됩니다.",
    ),
    "g_ui_new_email": MessageLookupByLibrary.simpleMessage("새 이메일 주소"),
    "g_ui_no_cached_email": MessageLookupByLibrary.simpleMessage(
      "이 기기에는 캐시된 이메일이 없습니다",
    ),
    "g_ui_no_coins": MessageLookupByLibrary.simpleMessage("아직 코인이 없습니다"),
    "g_ui_no_dapps": MessageLookupByLibrary.simpleMessage("DApp 없음"),
    "g_ui_no_limit_orders": MessageLookupByLibrary.simpleMessage("지정가 주문 없음"),
    "g_ui_no_orders": MessageLookupByLibrary.simpleMessage("오픈된 주문이 없습니다"),
    "g_ui_no_positions": MessageLookupByLibrary.simpleMessage("오픈된 포지션이 없습니다"),
    "g_ui_no_wallet": MessageLookupByLibrary.simpleMessage("아직 지갑이 없습니다"),
    "g_ui_optional": MessageLookupByLibrary.simpleMessage("선택 사항"),
    "g_ui_order_cancel_failed": MessageLookupByLibrary.simpleMessage(
      "취소에 실패했습니다",
    ),
    "g_ui_order_cancelled": MessageLookupByLibrary.simpleMessage("주문이 취소되었습니다"),
    "g_ui_order_create_failed": MessageLookupByLibrary.simpleMessage(
      "주문 생성에 실패했습니다",
    ),
    "g_ui_order_created": MessageLookupByLibrary.simpleMessage("지정가 주문 생성됨"),
    "g_ui_order_executed": MessageLookupByLibrary.simpleMessage("실행됨"),
    "g_ui_order_place": MessageLookupByLibrary.simpleMessage("지정가 주문 등록"),
    "g_ui_order_triggered": MessageLookupByLibrary.simpleMessage("트리거됨"),
    "g_ui_orders_count": m91,
    "g_ui_orders_load_failed": MessageLookupByLibrary.simpleMessage(
      "지정가 주문을 불러올 수 없습니다",
    ),
    "g_ui_password_mismatch": MessageLookupByLibrary.simpleMessage(
      "비밀번호가 일치하지 않습니다",
    ),
    "g_ui_paste_connection": MessageLookupByLibrary.simpleMessage("연결 링크 붙여넣기"),
    "g_ui_pending_mempool": MessageLookupByLibrary.simpleMessage("대기 중 (메모풀)"),
    "g_ui_popular_tokens": MessageLookupByLibrary.simpleMessage("인기 토큰"),
    "g_ui_position_size": MessageLookupByLibrary.simpleMessage("포지션 크기"),
    "g_ui_positions_count": m92,
    "g_ui_private_key_wallet": MessageLookupByLibrary.simpleMessage("개인키 지갑"),
    "g_ui_read_only": MessageLookupByLibrary.simpleMessage("읽기 전용"),
    "g_ui_recipients_count": m93,
    "g_ui_room_id": MessageLookupByLibrary.simpleMessage("룸 ID"),
    "g_ui_save_failed": MessageLookupByLibrary.simpleMessage(
      "저장 실패. 다시 시도하세요.",
    ),
    "g_ui_send_code": MessageLookupByLibrary.simpleMessage("코드 전송"),
    "g_ui_sending_request": MessageLookupByLibrary.simpleMessage("요청 전송 중..."),
    "g_ui_swap_mode": MessageLookupByLibrary.simpleMessage("스왑 모드 선택"),
    "g_ui_tags": MessageLookupByLibrary.simpleMessage("태그"),
    "g_ui_template_copied": MessageLookupByLibrary.simpleMessage("템플릿 복사됨"),
    "g_ui_token_contract_hint": MessageLookupByLibrary.simpleMessage(
      "토큰 계약 (0x...)",
    ),
    "g_ui_token_found": m94,
    "g_ui_token_lookup": MessageLookupByLibrary.simpleMessage(
      "토큰 정보를 검색 중입니다…",
    ),
    "g_ui_token_manual": MessageLookupByLibrary.simpleMessage(
      "목록에 토큰이 없음 — 심볼 및 소수 자릿수를 수동으로 입력하세요",
    ),
    "g_ui_token_value": m95,
    "g_ui_trade_delete_failed": MessageLookupByLibrary.simpleMessage(
      "거래를 삭제할 수 없습니다. 다시 시도해 주세요.",
    ),
    "g_ui_trade_save_failed": MessageLookupByLibrary.simpleMessage(
      "거래를 저장할 수 없습니다. 다시 시도해 주세요.",
    ),
    "g_ui_transaction_hash_value": m96,
    "g_ui_unknown_status": MessageLookupByLibrary.simpleMessage("알 수 없는 상태"),
    "g_ui_update": MessageLookupByLibrary.simpleMessage("업데이트"),
    "g_ui_update_email": MessageLookupByLibrary.simpleMessage("이메일 업데이트"),
    "g_ui_validation_counts": m97,
    "g_ui_validation_issues": MessageLookupByLibrary.simpleMessage("검증 문제"),
    "g_ui_validation_more": m98,
    "g_ui_verification_code": MessageLookupByLibrary.simpleMessage("인증 코드"),
    "g_ui_verify_code": MessageLookupByLibrary.simpleMessage("코드 인증"),
    "g_ui_view_market": MessageLookupByLibrary.simpleMessage("시장 데이터 보기"),
    "g_ui_volume_24h": MessageLookupByLibrary.simpleMessage("24시간 거래량"),
    "g_ui_volume_interest": m99,
    "g_ui_wallet_ai": MessageLookupByLibrary.simpleMessage("지갑 AI"),
    "g_ui_wallet_get_started": MessageLookupByLibrary.simpleMessage(
      "시작하려면 지갑을 생성하거나 가져오세요",
    ),
    "g_ui_wallet_load_failed": MessageLookupByLibrary.simpleMessage(
      "지갑 로딩에 실패했습니다",
    ),
    "g_ui_wallet_loading": MessageLookupByLibrary.simpleMessage("지갑을 로딩 중..."),
    "g_ui_wallet_number": m100,
    "g_version_later": MessageLookupByLibrary.simpleMessage("나중에"),
    "g_wallet_balance_warning": MessageLookupByLibrary.simpleMessage(
      "잔액을 새로 고칠 수 없습니다",
    ),
    "g_wallet_group_hd": MessageLookupByLibrary.simpleMessage("HD 지갑 · 니모닉"),
    "g_wallet_group_single": MessageLookupByLibrary.simpleMessage(
      "단일 체인 · 가져오기",
    ),
    "g_wallet_pin_token": MessageLookupByLibrary.simpleMessage("토큰 고정"),
    "g_wallet_prices_cached": MessageLookupByLibrary.simpleMessage("저장된 가격"),
    "g_wallet_prices_hours": m101,
    "g_wallet_prices_just_updated": MessageLookupByLibrary.simpleMessage(
      "지금 업데이트됨",
    ),
    "g_wallet_prices_minutes": m102,
    "g_wallet_prices_partial": MessageLookupByLibrary.simpleMessage("부분 가격"),
    "g_wallet_prices_unavailable": MessageLookupByLibrary.simpleMessage(
      "가격 정보 없음",
    ),
    "g_wallet_unpin_token": MessageLookupByLibrary.simpleMessage("토큰 고정 해제"),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "연결이 끊어졌습니다. 다시 연결해 주세요.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "DApp이 연결을 해제했습니다",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage("모두 연결 해제"),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "모든 DApp에서 연결을 해제하시겠습니까?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "이 DApp에서 연결을 해제하시겠습니까?",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage("활성 연결 없음"),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "QR 코드를 스캔하여 DApp에 연결하세요",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "연결 요청 시간이 초과되었습니다",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage("세션이 만료되었습니다"),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("연결된 DApp"),
    "g_xrp_dest_tag_hint": MessageLookupByLibrary.simpleMessage(
      "거래소로 보낼 때 보통 필수",
    ),
    "g_xrp_optional": MessageLookupByLibrary.simpleMessage("(선택)"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage("연결"),
    "importantNotice": MessageLookupByLibrary.simpleMessage("중요 공지"),
    "login_email": MessageLookupByLibrary.simpleMessage("이메일"),
    "login_password": MessageLookupByLibrary.simpleMessage("비밀번호"),
    "next": MessageLookupByLibrary.simpleMessage("다음"),
    "nicknameMessage": m103,
    "personalInformation": MessageLookupByLibrary.simpleMessage("프로필 편집"),
    "photograph": MessageLookupByLibrary.simpleMessage("사진 촬영"),
    "please_input_address": MessageLookupByLibrary.simpleMessage("주소를 입력하세요"),
    "push_bg_delivery_dialog_content": MessageLookupByLibrary.simpleMessage(
      "이 기기는 백그라운드 앱을 제한하므로, 앱이 백그라운드 또는 종료된 상태일 때 채팅 메시지와 이체 알림을 놓칠 수 있습니다.\n\n\"설정으로 이동\"을 탭하여 백그라운드 활동을 허용한 후, 이 앱의 자동 시작을 활성화하세요.",
    ),
    "push_bg_delivery_dialog_title": MessageLookupByLibrary.simpleMessage(
      "백그라운드 전달이 제한될 수 있습니다",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "다시 알리지 않기",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage("나중에"),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "설정으로 이동",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "푸시 알림이 비활성화되어 있습니다. 채팅 메시지와 이체 알림을 놓칠 수 있습니다.\n\n시스템 설정에서 이 앱의 알림을 활성화하세요.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "알림이 비활성화됨",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage("비밀번호 다시 입력"),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "비밀번호 선택(8~18자)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage("비밀번호 확인"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("앱 정보"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("보안"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("거래"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("언어"),
    "search": MessageLookupByLibrary.simpleMessage("검색"),
    "verification": MessageLookupByLibrary.simpleMessage("인증"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "시드 문구를 잃어버리면 자금을 영원히 잃게 됩니다.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "시드 문구를 누구에게 공개하거나 공유하면 자금이 도난당할 수 있습니다.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "시드 문구를 안전하게 보관하는 것은 본인의 책임입니다.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage("시드 문구가 올바르지 않습니다."),
    "w_key_8": MessageLookupByLibrary.simpleMessage("가져오려는 지갑의 시드 문구를 입력하세요."),
  };
}

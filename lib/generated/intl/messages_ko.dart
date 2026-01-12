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

  static String m0(value) => "저는 ${value}입니다";

  static String m1(value) => "채팅 멤버(${value})";

  static String m2(value) => "${value}을(를) 친구로 추가하시겠습니까";

  static String m3(value) => "이미 바인딩되어 있어 현재 다시 바인딩할 수 없습니다. 바인딩 주소: ${value}.";

  static String m4(value) => "바인딩 성공. 바인딩 주소: ${value}";

  static String m5(value) => "${value} 지갑에 N42체인이 없습니다!";

  static String m6(value) => "매칭 성공. 주소:${value}.";

  static String m7(value) => "${value}보다 큰 금액입니다.";

  static String m8(value) => "지갑이 이미 존재합니다. 지갑 이름: \"${value}\"";

  static String m9(value) => "${value} 이상의 금액을 입력하세요.";

  static String m10(value) => "연락처 ${value}을(를) 삭제하시겠습니까?";

  static String m11(value) => "\"${value}\"이(가) 부족합니다";

  static String m12(value) => "\"${value}\" 계정 가져오기 실패";

  static String m13(value) => "첫 송금 시 최소 ${value} XRP 필요";

  static String m14(value) => "${value} 체인이 추가되지 않았습니다.";

  static String m15(value) => "${value}에 미완료 거래가 있습니다. 나중에 다시 시도하세요.";

  static String m16(value) => "${value}에 대한 주소를 찾을 수 없습니다.";

  static String m17(value) => "${value} 잔액이 부족합니다.";

  static String m18(value, value1) =>
      "모든 XRP 계정은 기준선으로 ${value} XRP(${value1} drops)를 예약해야 하며, 이는 사용할 수 없습니다.";

  static String m19(value, value1) =>
      "계정이 소유한 각 객체에 대해 ${value} XRP(${value1} drops)가 준비금에 추가됩니다.";

  static String m20(value, value1) =>
      "이 계정은 ${value}개의 객체를 소유하고 있으며, 이는 추가로 ${value1} XRP가 예약됨을 의미합니다.";

  static String m21(value) => "패턴 비밀번호 입력 오류, ${value}번의 기회가 남았습니다";

  static String m22(value) => "패턴 비밀번호 입력 오류, ${value}번의 기회가 남았습니다";

  static String m23(value) => "${value}을(를) 성공적으로 설정했으며 N42Wallet으로 검증을 시작합니다!";

  static String m24(value) =>
      "@N42Wallet에서 내 ${value} 그룹에 참여하여 레이어 1 체인의 초기 채굴자가 되고, 폰으로 암호화폐를 받으세요!";

  static String m25(value) => "검증자를 실행하려면 ${value} N을 잠그세요.";

  static String m26(value) => "가져오기 실패:${value}";

  static String m27(value, value1) => "${value1}블록 채굴 시 ${value} N";

  static String m28(value) => "${value}자여야 합니다";

  static String m29(value) => "${value} 잔액이 부족합니다.";

  static String m30(value) => "${value} 입금 중...";

  static String m31(value) =>
      "앱 내에서 스왑된 ${value}은(는) 곧 지갑으로 분배되며 이 프로세스를 통해 판매할 수 없습니다. 노드 운영에 사용할 수 있습니다.";

  static String m32(value) => "최대 ${value}자";

  static String m33(value) => "${value} 체인은 앱에서 이미 지원됩니다!";

  static String m34(value) => "${value} 체인은 앱에서 이미 지원됩니다. 추가하시겠습니까?";

  static String m35(value) => "${value} 주소 테스트 링크 실패!";

  static String m36(value) => "${value}초 후 앱이 잠금 해제됩니다.";

  static String m37(value) => "패턴 비밀번호 입력 오류, ${value}번의 기회가 남았습니다";

  static String m38(value) => "비밀번호 입력 오류, ${value}번의 기회가 남았습니다";

  static String m39(value) => "비밀번호 입력 오류, ${value}번의 기회가 남았습니다";

  static String m40(value) => "${value} 비밀번호 입력";

  static String m41(value) => "0~${value}자";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("회원가입"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage("계정 생성"),
    "Edit": MessageLookupByLibrary.simpleMessage("편집"),
    "Verification": MessageLookupByLibrary.simpleMessage("인증"),
    "address_Information": MessageLookupByLibrary.simpleMessage("주소 정보"),
    "code_403": MessageLookupByLibrary.simpleMessage("계정이 하루 동안 일시적으로 잠겼습니다"),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "코드가 올바르지 않습니다. 다시 시도하세요.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("복사 완료"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("주소 복사"),
    "descO": MessageLookupByLibrary.simpleMessage("설명(선택사항)"),
    "editPhoto": MessageLookupByLibrary.simpleMessage("사진 편집"),
    "email_code_error": MessageLookupByLibrary.simpleMessage("인증 코드 가져오기 실패"),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "인증 코드가 성공적으로 전송되었습니다. 이메일을 확인하세요",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage("인증 코드 오류"),
    "email_error": MessageLookupByLibrary.simpleMessage("유효하지 않은 이메일 주소"),
    "email_verification": MessageLookupByLibrary.simpleMessage("이메일 주소 인증"),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "이메일 주소 인증 앱은 출금 및 N42Wallet 계정을 보호합니다.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "이메일 인증을 추가하시겠습니까?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("파일"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "토큰은 동일한 네트워크 내에서만 전송할 수 있습니다. 다른 네트워크에서 전송하면 손실이 발생할 수 있습니다.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage("스캔하여 받기"),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage("URL을 입력하세요"),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("설명 입력"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("브라우저"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage("브라우저 캐시 삭제"),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage("DApp 자동 연결"),
    "g_browser_key14": MessageLookupByLibrary.simpleMessage("DApp 연결을 확인하세요"),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("모두 닫기"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("완료"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("북마크"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage("아직 북마크가 없습니다"),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("북마크"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("이름"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage("이름을 입력하세요"),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("설명"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage("그룹 채팅 시작"),
    "g_chat_key_10": m0,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("친구 초대"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("연락처 선택"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("완료"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage("최소 2명의 연락처를 선택하세요"),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("친구 상세"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("그룹 상세"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage("더 많은 그룹 멤버 보기"),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("그룹 이름"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("새 친구"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage("해산하시겠습니까?"),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage("이 그룹을 나가시겠습니까?"),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("그룹 해산"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("그룹 나가기"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage("그룹 채팅 이름 변경"),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "그룹 채팅 이름이 변경되면 다른 멤버들에게 그룹 내에서 알림이 전송됩니다.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("완료"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage("친구 추가 요청"),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage("친구로 추가 요청"),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage("친구 요청 승인됨"),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("추가됨"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage("친구로 추가되었습니다"),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("수락"),
    "g_chat_key_32": m1,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "비밀번호를 제대로 파싱할 수 없어 일시적으로 메시지를 보낼 수 없습니다. 그룹에 들어갈 때 지갑을 가져오세요",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage("채팅 기록을 삭제하시겠습니까?"),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("멤버 제거"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("내 QR 코드"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("만료됨"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("신고"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("새 채팅"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("새 그룹"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("QR 코드"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage("신고 및 차단"),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "이 메시지는 N42Wallet으로 전달됩니다. 이 연락처에는 알림이 가지 않습니다.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("영상"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("사진"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("메시지 삭제"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage("내 기기에서 삭제"),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("대기"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("수락"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage("신고 사유"),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage("신고 사유를 입력하세요"),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "신고 내용을 확인하고 24시간 내에 응답하겠습니다.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage("신고했습니다 - 클릭하여 보기"),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("차단 목록"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("제거"),
    "g_chat_key_6": m2,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage("아직 연락처가 없습니다"),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("오늘"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage("3일 이상 전"),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("차단"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "안녕하세요, N42Wallet으로 채팅하고 송금하고 있어요. 지갑을 설치하고 연락주세요",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("답장"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage("메시지가 삭제되었습니다"),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage("누군가 나를 @했습니다"),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("인사하기"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("친구 추가"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage("신청 사유"),
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
    "g_face_1": MessageLookupByLibrary.simpleMessage("생체 인식 스캔 안내"),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "인증을 위해 지문 또는 얼굴을 스캔하세요.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage("생체 인식 스캔 실패"),
    "g_face_3": MessageLookupByLibrary.simpleMessage("안내"),
    "g_face_4": MessageLookupByLibrary.simpleMessage("생체 인식 스캔 성공"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("설정하기"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "생체 인식 로그인이 설정되지 않았습니다. 시스템 설정으로 이동하여 설정하세요.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage("계속하려면 얼굴 또는 지문을 스캔하세요."),
    "g_face_8": MessageLookupByLibrary.simpleMessage("돌아가기"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "생체 인식을 다시 활성화하는 것이 좋습니다.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage("얼굴 매칭 방법"),
    "g_face_match_key10": m3,
    "g_face_match_key11": m4,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage("다시 바인딩"),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("바인딩"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("인증"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "얼굴 데이터를 지갑 주소에 직접 바인딩할 수 있습니다(이전에 바인딩한 경우 기존 지갑 주소가 덮어씌워집니다). 또는 이전에 지갑 주소를 바인딩한 경우 수동으로 인증하여 바인딩된 지갑 주소를 검색할 수도 있습니다.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "얼굴 데이터에 연결된 지갑 주소가 다음과 같이 감지되었지만, 아직 이 지갑을 지갑 목록에 가져오지 않았습니다.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "이 지갑에 얼굴 데이터를 연결했습니다.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage("사용자 안내"),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage("얼굴 바인딩이란?"),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "얼굴 바인딩은 얼굴 인식 기술을 활용하여 생체 얼굴 특징을 블록체인 지갑 주소와 매칭합니다.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "이 프로세스는 거래 편의성을 높일 뿐만 아니라 계정 보안을 강화하여 모든 작업이 본인에 의해 승인되도록 합니다.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "왜 얼굴 바인딩이 필요한가요?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "얼굴 데이터를 바인딩하면 신원이 거래 활동에 직접 연결되어 신원 확인 프로세스가 간소화되고 운영 효율성이 향상됩니다. 이 기술은 자산 전송이나 컨트랙트 상호작용과 같은 민감한 작업을 수행할 때 빠르고 안전한 신원 확인을 보장합니다.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "내 얼굴 데이터는 어떻게 저장되며 안전한가요?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "얼굴 데이터는 중앙화된 데이터베이스가 아닌 퍼블릭 블록체인에 암호화된 형태로 저장됩니다. 즉, 시스템은 본인이 승인할 때만 데이터를 복호화하여 신원 확인에 사용할 수 있어 개인정보와 데이터 보안이 보장됩니다.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "얼굴 바인딩이 계정 보안에 어떤 영향을 미치나요?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "얼굴 바인딩은 모든 민감한 작업이 본인의 명시적 승인이 있을 때만 수행되도록 하여 계정 보안을 강화합니다. 업계 최고의 암호화 기술을 사용하여 생체 데이터를 보호하고 무단 접근을 방지합니다.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "내 얼굴 데이터는 안전한가요?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "물론입니다. 모든 생체 데이터는 엄격한 암호화를 거치며, 데이터 전송 및 저장에 최고의 보안 표준을 따릅니다. 시스템은 신원 확인을 완료하는 데 필요한 경우에만 이 데이터를 복호화합니다.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage("매칭 실패!"),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("알겠습니다"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage("지갑 주소 선택"),
    "g_face_match_key32": m5,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("바인딩 해제"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage("얼굴 데이터 인증 실패!"),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "얼굴 데이터 바인딩 해제 실패!",
    ),
    "g_face_match_key4": m6,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage("주소 오류!"),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage("얼굴 데이터 바인딩"),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage("얼굴 매칭"),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("다시 선택"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("매칭"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("프로필"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("뉴스"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("검증"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("메시지"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("학습"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("친구 초대"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("삭제 실패!"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("보내기"),
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
    "g_key_154": MessageLookupByLibrary.simpleMessage("제출"),
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
    "g_key_205": MessageLookupByLibrary.simpleMessage("사진 앨범 접근 권한이 없습니다."),
    "g_key_206": MessageLookupByLibrary.simpleMessage("비밀번호 변경"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("기존 비밀번호"),
    "g_key_208": MessageLookupByLibrary.simpleMessage("잔액 동기화 중..."),
    "g_key_209": MessageLookupByLibrary.simpleMessage("개인키"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("지갑 비밀번호 입력"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("개인키 오류"),
    "g_key_211": MessageLookupByLibrary.simpleMessage("구매"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("판매"),
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
    "g_key_8": MessageLookupByLibrary.simpleMessage("메모"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("시드 문구"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("모든 토큰"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("설정"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("주소"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage("이름을 입력하세요"),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage("주소를 입력하세요"),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage("코인 유형을 선택하세요"),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("주소 편집"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage("삭제 완료"),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("코인 선택"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("코인 검색"),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage("응답 데이터 파싱 오류!"),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Dio 오류"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage("요청 구문 오류"),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage("인증되지 않음, 로그인하세요"),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("접근 거부"),
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "계정 또는 비밀번호가 틀렸습니다",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("요청 오류"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "다른 기기에서 이미 로그인되어 있어 강제 로그아웃되었습니다.",
    ),
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
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("피드백"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage("피드백 정보를 입력하세요"),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "업로드되지 않은 첨부 파일이 있습니다",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage("제출 실패"),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage("제출 완료"),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("첨부 파일"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "최대 5개의 첨부 파일 업로드 가능, 각 첨부 파일은 100MB를 초과할 수 없습니다",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("실패"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage("클릭하여 재시도"),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage("로그인하세요"),
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
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage("시드 문구를 입력하세요"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("합계"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("카메라"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("사진 선택"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("콘텐츠"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("이름"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("뒤로"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("거래 제출됨"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("영상 선택"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage("휴대폰 갤러리에서 선택"),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("QR 코드 공유"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("링크 공유"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage("공유 방법"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("채팅"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "파일이 너무 커서 업로드할 수 없습니다",
    ),
    "g_key_squad_k15": m10,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("연락처 추가"),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("연락처"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage("이메일로 검색"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("완료"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("가스 가격"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("최대 가스 수수료"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("가스당 최대 수수료"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("대기 중"),
    "g_key_t_29": m11,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("실패"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("채굴자 수수료"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("진행"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("지갑 비밀번호"),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage("지갑 비밀번호는 비워둘 수 없습니다"),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage("지갑 비밀번호가 틀렸습니다"),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage("지갑 비밀번호를 입력하세요"),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("가스 수수료 비율"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage("최신 블록 가스 수수료 비율 평균"),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("출금"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage("0보다 큰 정수를 입력하세요."),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage("데이터 가져오기 실패"),
    "g_key_t_45": m12,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage("받는 주소 계정 확인"),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("찾기"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("계정 없음"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("입금"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("유효하지 않은 주소"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage("계정 인증 성공"),
    "g_key_t_52": m13,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "받는 주소에 계정이 없으며, 첫 송금 시 최소 10XRP가 필요합니다",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("사용된 가스"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("가스"),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("거래 내역"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("거래 상세"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage("거래 영수증은 내역에서 확인하세요"),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("지출 금액"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("받는 금액"),
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("NFT 유형"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("팔로워"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("사용자 유형"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("웹사이트"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("제품 링크"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("미디어 플랫폼"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("지갑 주소"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("닉네임"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage("아바타 업로드 실패"),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("설명"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage("아티스트 정보"),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage("아티스트가 아닙니다"),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage("아티스트 신청을 하려면 여기를 클릭하세요"),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("이름"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("수익"),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage("다음을 읽고 동의했습니다 "),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage("이용약관"),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "개인정보 처리방침 및 개인정보 수집 안내",
    ),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage("최신 버전 발견"),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("즉시 업데이트"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("새 버전 발견"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage("이미 최신 버전입니다"),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage("시드 문구 보기"),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "시드 문구를 기록하고 안전하게 보관하세요.",
    ),
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
    "g_key_wallet_m1": m14,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage("계정을 탈퇴하시겠습니까?"),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage("로그아웃 확인"),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Google 인증 코드를 입력하세요.",
    ),
    "g_key_wallet_m19": m15,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "현재 토큰이 추가되지 않았습니다.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "단어 사이에 공백을 두고 시드 문구를 입력하세요",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("지갑 가져오기"),
    "g_key_wallet_m3": m16,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage("현재 토큰 잔액이 부족합니다."),
    "g_key_wallet_m5": m17,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("서명 오류"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage("계정 탈퇴"),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "이메일 인증 코드를 입력하세요.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage("지갑 관리"),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("예약됨"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("기본 준비금"),
    "g_key_xml_11": m18,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("증분 준비금"),
    "g_key_xml_22": m19,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage("소유 객체 수"),
    "g_key_xml_33": m20,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage("총 예약 금액 계산 방법"),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "총 준비금 = 기본 준비금 + (소유 객체 수 × 증분 준비금)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID 및 Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("현재 비밀번호"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("새 비밀번호"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage("새 비밀번호 확인"),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("6자리 숫자"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage("비밀번호 및 생체 인식"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("패턴 비밀번호"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage("패턴 비밀번호 설정"),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "계정 보안을 위해 그룹 비밀번호를 설정하세요",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage("패턴 비밀번호 두 번째 그리기"),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage("패턴 비밀번호 그리기"),
    "g_lock_key21": m21,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage("패턴 비밀번호 재설정"),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "입력 오류가 너무 많습니다. 비밀번호를 재설정하세요",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage("지갑 비밀번호를 추가하시겠습니까?"),
    "g_lock_key25": m22,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage("잠금 화면 페이지"),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("자동 잠금"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("성공"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("실패"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage("생체 인식이 활성화되지 않았습니다"),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage("생체 인증을 추가하시겠습니까?"),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage("비밀번호 재설정"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("N 잠금 해제?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage("클라우드 검증 활동"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "설정에는 소량의 가스가 필요합니다.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "N42Wallet에서 그룹 노드에 성공적으로 참여했습니다. 링크를 공유하여 친구를 초대하고 노드를 활성화하여 검증을 시작하세요!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage("친구에게 공유"),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("계속"),
    "g_mining_key63": m23,
    "g_mining_key73": m24,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "@N42Wallet에서 노드를 설정하고 모바일 기기에서 검증을 시작했습니다! 함께하세요. 탈중앙화 미래는 모바일입니다!",
    ),
    "g_mining_key76": m25,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage("768초 후 상환 가능."),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "그 전의 요청은 처리되지 않습니다.",
    ),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("오늘의 보상"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "아래 데이터를 중요한 키로 취급하세요. 즉시 복사하여 신뢰할 수 있는 위치에 백업하는 것을 권장합니다.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("데이터 복사"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("비활성"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage("검증자 목록"),
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
    "g_mining_key_109": m26,
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
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "보상은 매일 누적되며 ~0.5 N에 도달하면 N 지갑으로 전송됩니다.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("총 보상"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("채굴 가치"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "N 시장 가격 * 총 N 보상을 기준으로 계산됩니다.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("검증 횟수"),
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
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("비활성화됨"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("더 보기"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage("검증 상태"),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "N을 잠그고 검증 보상을 시작하세요.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("엔트리"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("어드밴스드 노드"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("엔트리 노드"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("프로 노드"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage("하루 500블록~70분"),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("플랜 선택"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage("하루 100블록~15분"),
    "g_mining_key_71": m27,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage("검증당 128초"),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage("클라우드 검증 시작됨"),
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
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "송금에 필요한 자금이 부족합니다.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage("검증자 목록"),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage("검증자 가져오기"),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage("검증자가 이미 존재합니다"),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("저위험"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("중저위험"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage("중고위험"),
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
    "g_mining_key_98": m28,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "비밀번호가 올바른지 확인하기 위해 다시 입력하세요",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage("알림"),
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
    "g_swap_key_14": m29,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage("코인 가격 조회 오류."),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage("진행 시 다음에 동의하게 됩니다 "),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage("이용약관."),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("완료"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "스왑이 곧 분배됩니다. 잠시만 기다려 주세요.",
    ),
    "g_swap_key_20": m30,
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
    "g_swap_key_31": m31,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "스왑은 관련 체인 탐색기(Etherscan, BscScan, TRONSCAN 및 자체 탐색기)에서 확인할 수 있습니다.",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("N으로 스왑"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("스왑"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("받는 금액"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("스왑 미리보기"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("다시 시도"),
    "g_token_m_key_1": m32,
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
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage("커스텀 체인 추가"),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 정수"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("토큰 추가"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("형식 오류!"),
    "g_token_m_key_22": m33,
    "g_token_m_key_23": m34,
    "g_token_m_key_24": m35,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("토큰 가져오기"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("모든 네트워크"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("커스텀 토큰"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("토큰 주소"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("토큰 심볼"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("토큰 소수점"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("가져오기"),
    "g_unlock_key10": m36,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "지문 또는 얼굴 인식이 활성화되지 않았습니까?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage("패턴 비밀번호 그리기"),
    "g_unlock_key4": m37,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("비밀번호 입력"),
    "g_unlock_key6": m38,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage("인증 실패"),
    "g_unlock_key8": m39,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("또한 "),
    "google_verification": MessageLookupByLibrary.simpleMessage("Google 인증"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage("연결"),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator 다운로드",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage("안내"),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator를 엽니다.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "화면에 6자리 인증 코드가 표시됩니다.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "6자리 코드를 복사하여 N42Wallet에 붙여넣으세요.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "그러면 Authenticator가 성공적으로 연결됩니다.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "백업 키",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "키를 Google Authenticator에 복사",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Google 인증 코드 입력",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "이메일 인증 코드 입력",
    ),
    "google_verification_message21": m40,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Google 키 가져오기 실패",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "2단계 인증(2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "계정을 보호하려면 최소 하나의 2FA를 활성화하는 것이 좋습니다.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator 앱은 출금 및 N42Wallet 계정을 보호합니다.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "다운로드 및 설치",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator를 다운로드하여 설치하세요. 그런 다음 \'연결\'을 눌러 N42Wallet 계정을 연결하세요.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("중요 공지"),
    "login_button_text": MessageLookupByLibrary.simpleMessage("로그인"),
    "login_email": MessageLookupByLibrary.simpleMessage("이메일"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "비밀번호를 잊으셨나요?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage("추천 코드"),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage("추천 코드"),
    "login_message_1": MessageLookupByLibrary.simpleMessage("계정이 없으신가요? "),
    "login_message_10": MessageLookupByLibrary.simpleMessage("생성 완료"),
    "login_message_11": MessageLookupByLibrary.simpleMessage("재설정 완료"),
    "login_message_2": MessageLookupByLibrary.simpleMessage("이미 계정이 있으신가요? "),
    "login_message_6": MessageLookupByLibrary.simpleMessage("코드 재전송 "),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "코드가 성공적으로 전송되었습니다",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage("등록되지 않은 이메일"),
    "login_message_9": MessageLookupByLibrary.simpleMessage("코드 전송 실패"),
    "login_need_login": MessageLookupByLibrary.simpleMessage("먼저 로그인하세요"),
    "login_password": MessageLookupByLibrary.simpleMessage("비밀번호"),
    "next": MessageLookupByLibrary.simpleMessage("다음"),
    "nicknameMessage": m41,
    "password_diff": MessageLookupByLibrary.simpleMessage("비밀번호가 일치하지 않습니다"),
    "personalInformation": MessageLookupByLibrary.simpleMessage("프로필 편집"),
    "photograph": MessageLookupByLibrary.simpleMessage("사진 촬영"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage("인증 코드 입력"),
    "please_enter_email": MessageLookupByLibrary.simpleMessage("이메일을 입력하세요"),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "비밀번호를 입력하세요",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage("주소를 입력하세요"),
    "repeatPassword": MessageLookupByLibrary.simpleMessage("비밀번호 다시 입력"),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "비밀번호 선택(8~18자)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage("비밀번호 확인"),
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "비밀번호 다시 입력",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage("코드 입력"),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage("OTP 코드"),
    "rest_your_password": MessageLookupByLibrary.simpleMessage("비밀번호 재설정"),
    "s_key_1": MessageLookupByLibrary.simpleMessage("지갑 관리"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("앱 정보"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("보안"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("새 채팅 사용"),
    "s_key_13": MessageLookupByLibrary.simpleMessage("향상된 채팅 환경 활성화"),
    "s_key_2": MessageLookupByLibrary.simpleMessage("지갑 주소"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("거래"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("언어"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("테마"),
    "search": MessageLookupByLibrary.simpleMessage("검색"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "약관을 읽고 확인하세요",
    ),
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

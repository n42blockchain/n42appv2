// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
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
  String get localeName => 'vi';

  static String m0(value) => "Tôi là ${value}";

  static String m1(value) => "Thành viên chat (${value})";

  static String m2(value) =>
      "Bạn có chắc chắn muốn thêm ${value} làm bạn bè không";

  static String m3(value) =>
      "Bạn đã liên kết và không thể liên kết lại vào lúc này. Địa chỉ liên kết: ${value}.";

  static String m4(value) => "Liên kết thành công. Địa chỉ liên kết: ${value}";

  static String m5(value) => "Không có N42chain trong ví ${value}!";

  static String m6(value) => "Khớp thành công. Địa chỉ:${value}.";

  static String m7(value) => "Số lượng lớn hơn ${value}.";

  static String m8(value) => "Ví đã tồn tại, tên ví là \"${value}\"";

  static String m9(value) => "Nhập số lượng lớn hơn ${value}.";

  static String m10(value) =>
      "Bạn có chắc chắn muốn xóa liên hệ ${value} không?";

  static String m11(value) => "Bạn không có đủ \"${value}\"";

  static String m12(value) => "Không thể lấy tài khoản \"${value}\"";

  static String m13(value) => "Tối thiểu ${value} XRP cho lần chuyển đầu tiên";

  static String m14(value) => "Chưa thêm chuỗi ${value}.";

  static String m15(value) =>
      "${value} có giao dịch chưa hoàn tất, vui lòng thử lại sau.";

  static String m16(value) => "Không tìm thấy địa chỉ cho ${value}.";

  static String m17(value) => "Số dư ${value} không đủ.";

  static String m18(value, value1) =>
      "Mỗi tài khoản XRP phải dự trữ ${value} XRP (${value1} drops) làm mức cơ bản, không thể chi tiêu.";

  static String m19(value, value1) =>
      "Với mỗi đối tượng tài khoản sở hữu, ${value} XRP (${value1} drops) được thêm vào dự trữ.";

  static String m20(value, value1) =>
      "Tài khoản này sở hữu ${value} đối tượng, có nghĩa là thêm ${value1} XRP được dự trữ.";

  static String m21(value) => "Nhập sai mật khẩu hình vẽ, bạn còn ${value} lần";

  static String m22(value) => "Nhập sai mật khẩu hình vẽ, bạn còn ${value} lần";

  static String m23(value) =>
      "Bạn đã thiết lập thành công ${value} và sẽ bắt đầu xác minh với N42Wallet!";

  static String m24(value) =>
      "Tham gia nhóm ${value} của tôi trên @N42Wallet để trở thành thợ đào sớm của chuỗi Layer 1 và nhận tiền mã hóa trên điện thoại!";

  static String m25(value) => "Khóa ${value} N để vận hành người xác thực.";

  static String m26(value) => "Nhập thất bại:${value}";

  static String m27(value, value1) => "${value} N mỗi ${value1} khối đã đào";

  static String m28(value) => "Phải có ${value} ký tự";

  static String m29(value) => "${value} Số dư không đủ.";

  static String m30(value) => "${value} đang đến...";

  static String m31(value) =>
      "${value} hoán đổi trong ứng dụng sẽ được phân phối đến ví của bạn trong thời gian ngắn và không thể bán qua quy trình này. Có thể sử dụng để vận hành node.";

  static String m32(value) => "Tối đa ${value} ký tự";

  static String m33(value) => "Ứng dụng đã hỗ trợ chuỗi ${value}!";

  static String m34(value) =>
      "Ứng dụng đã hỗ trợ chuỗi ${value}, bạn có muốn thêm không?";

  static String m35(value) => "Kết nối thử nghiệm địa chỉ ${value} thất bại!";

  static String m36(value) => "Ứng dụng sẽ mở khóa sau ${value} giây.";

  static String m37(value) => "Nhập sai mật khẩu hình vẽ, bạn còn ${value} lần";

  static String m38(value) => "Nhập sai mật khẩu, bạn còn ${value} lần";

  static String m39(value) => "Nhập sai mật khẩu, bạn còn ${value} lần";

  static String m40(value) => "Nhập mật khẩu ${value}";

  static String m41(value) => "0~${value} ký tự";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("Đăng ký"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Tạo tài khoản của bạn",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Sửa"),
    "Verification": MessageLookupByLibrary.simpleMessage("Xác minh"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Thông tin địa chỉ",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Tài khoản tạm thời bị khóa một ngày",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "Mã không đúng. Vui lòng thử lại.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Sao chép thành công"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Sao chép địa chỉ"),
    "descO": MessageLookupByLibrary.simpleMessage("Mô tả (Tùy chọn)"),
    "editPhoto": MessageLookupByLibrary.simpleMessage("Sửa ảnh"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Không thể lấy mã xác thực",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Mã xác thực đã được gửi thành công, vui lòng kiểm tra email của bạn",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Lỗi mã xác thực",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Địa chỉ email không hợp lệ",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "Xác thực địa chỉ email",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "Ứng dụng xác thực địa chỉ email bảo vệ các khoản rút tiền và tài khoản N42Wallet của bạn.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "Thêm xác minh email?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Tệp"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Token chỉ có thể gửi trong cùng một mạng. Gửi từ mạng khác có thể dẫn đến mất mát.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage("Quét để nhận"),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage("Vui lòng nhập URL"),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("Nhập mô tả"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Trình duyệt"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Xóa bộ nhớ đệm trình duyệt",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Tự động kết nối DApp",
    ),
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Vui lòng xác nhận kết nối với DApp",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Đóng tất cả"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Xong"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Dấu trang"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Chưa có dấu trang nào",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Dấu trang"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Tên"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage("Vui lòng nhập tên"),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Mô tả"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage(
      "Bắt đầu trò chuyện nhóm",
    ),
    "g_chat_key_10": m0,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Mời bạn bè"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("Chọn liên hệ"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Xong"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "Chọn ít nhất 2 liên hệ",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Chi tiết bạn bè"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Chi tiết nhóm"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "Xem thêm thành viên nhóm",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Tên nhóm"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Bạn mới"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "Bạn có chắc chắn muốn giải tán không?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "Bạn có chắc chắn muốn rời khỏi nhóm này không?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("Giải tán nhóm"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Rời nhóm"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage("Đổi tên nhóm chat"),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "Khi tên nhóm chat được thay đổi, các thành viên khác sẽ được thông báo trong nhóm.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Xong"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage(
      "Yêu cầu thêm bạn bè",
    ),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Yêu cầu thêm bạn làm bạn bè",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "Yêu cầu kết bạn đã được chấp thuận",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Đã thêm"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "Bạn đã được thêm làm bạn bè",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("đồng ý"),
    "g_chat_key_32": m1,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "Không thể phân tích mật khẩu đúng cách, tạm thời không thể gửi tin nhắn. Vui lòng nhập ví khi vào nhóm",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage("Xóa lịch sử chat?"),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("Xóa thành viên"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("Mã QR của tôi"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Đã hết hạn"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Báo cáo"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("Chat mới"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Nhóm mới"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("Mã QR"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage("Báo cáo và chặn"),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "Tin nhắn này sẽ được chuyển tiếp đến N42Wallet. Liên hệ này sẽ không được thông báo.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Video"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Ảnh"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("Xóa tin nhắn"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage(
      "Xóa trên thiết bị của tôi",
    ),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Đợi"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Đồng ý"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage("Lý do báo cáo"),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      "Nhập lý do báo cáo của bạn",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "Chúng tôi sẽ xác minh báo cáo của bạn và phản hồi trong vòng 24 giờ.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "Bạn đã báo cáo điều này - Nhấn để xem",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Danh sách đen"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Xóa"),
    "g_chat_key_6": m2,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage(
      "Chưa có liên hệ nào",
    ),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Hôm nay"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage("Hơn 3 ngày trước"),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Chặn"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "Này, tôi đang sử dụng N42Wallet để chat và gửi tiền. Cài đặt Ví và nhắn tin cho tôi tại",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Trả lời"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage("Tin nhắn đã bị xóa"),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage("Ai đó đã @ tôi"),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Chào"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Thêm bạn bè"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage("Lý do đăng ký"),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Giao dịch"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Kết nối"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("Mạng khả dụng"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("Ký tin nhắn"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Đang kết nối"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Đang ghép nối, vui lòng đợi.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Ngắt kết nối"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Từ chối"),
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Hướng dẫn quét sinh trắc học",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Quét vân tay hoặc khuôn mặt để xác thực.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "Quét sinh trắc học không thành công",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Gợi ý"),
    "g_face_4": MessageLookupByLibrary.simpleMessage(
      "Quét sinh trắc học thành công",
    ),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Đi cài đặt"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "Bạn chưa cài đặt đăng nhập sinh trắc học. Đi tới Cài đặt hệ thống để thiết lập.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Quét khuôn mặt hoặc vân tay để tiếp tục.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Quay lại"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "Khuyến nghị bạn kích hoạt lại sinh trắc học.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Phương thức khớp khuôn mặt",
    ),
    "g_face_match_key10": m3,
    "g_face_match_key11": m4,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage("Liên kết lại"),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Liên kết"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Xác minh"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "Bạn có thể liên kết dữ liệu khuôn mặt với địa chỉ ví trực tiếp (nếu bạn đã liên kết trước đó, địa chỉ ví cũ sẽ bị ghi đè), hoặc nếu bạn đã liên kết địa chỉ ví trước đó, bạn cũng có thể xác minh thủ công để lấy địa chỉ ví đã liên kết.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "Địa chỉ ví liên kết với dữ liệu khuôn mặt của bạn đã được phát hiện như sau, nhưng bạn chưa nhập ví này vào danh sách ví của mình.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "Bạn đã liên kết dữ liệu khuôn mặt với ví này.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage(
      "Thông báo người dùng",
    ),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "Liên kết khuôn mặt là gì?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "Liên kết khuôn mặt sử dụng công nghệ nhận dạng khuôn mặt để khớp các đặc điểm sinh trắc học khuôn mặt của bạn với địa chỉ ví blockchain.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "Quy trình này không chỉ tăng cường sự tiện lợi giao dịch mà còn tăng cường bảo mật tài khoản, đảm bảo mọi hành động đều được bạn ủy quyền.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "Tại sao cần liên kết khuôn mặt?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "Bằng cách liên kết dữ liệu khuôn mặt, danh tính của bạn được liên kết trực tiếp với hoạt động giao dịch, đơn giản hóa quy trình xác minh danh tính và cải thiện hiệu quả hoạt động. Công nghệ này đảm bảo xác minh danh tính nhanh chóng và an toàn khi thực hiện các hoạt động nhạy cảm như chuyển tài sản hoặc tương tác với hợp đồng.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "Dữ liệu khuôn mặt của tôi được lưu trữ như thế nào và có an toàn không?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "Dữ liệu khuôn mặt của bạn được lưu trữ dưới dạng mã hóa trên blockchain công khai, không phải trong bất kỳ cơ sở dữ liệu tập trung nào. Điều này có nghĩa là hệ thống chỉ có thể giải mã và sử dụng dữ liệu của bạn để xác minh danh tính khi được bạn ủy quyền, đảm bảo quyền riêng tư và bảo mật dữ liệu của bạn.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "Liên kết khuôn mặt ảnh hưởng đến bảo mật tài khoản của tôi như thế nào?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "Liên kết khuôn mặt tăng cường bảo mật tài khoản của bạn bằng cách đảm bảo tất cả các hành động nhạy cảm chỉ được thực hiện khi có sự ủy quyền rõ ràng của bạn. Chúng tôi sử dụng công nghệ mã hóa hàng đầu ngành để bảo vệ dữ liệu sinh trắc học của bạn, ngăn chặn truy cập trái phép.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "Dữ liệu khuôn mặt của tôi có an toàn không?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Hoàn toàn. Tất cả dữ liệu sinh trắc học đều được mã hóa nghiêm ngặt, và các tiêu chuẩn bảo mật cao nhất được tuân thủ cho việc truyền tải và lưu trữ dữ liệu. Hệ thống chỉ giải mã dữ liệu này khi cần thiết để hoàn thành xác minh danh tính.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage("Khớp thất bại!"),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Đã hiểu"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Chọn địa chỉ ví",
    ),
    "g_face_match_key32": m5,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Hủy liên kết"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Xác minh dữ liệu khuôn mặt thất bại!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Hủy liên kết dữ liệu khuôn mặt thất bại!",
    ),
    "g_face_match_key4": m6,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage("Lỗi địa chỉ!"),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Liên kết dữ liệu khuôn mặt",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage("Khớp khuôn mặt"),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("Chọn lại"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Khớp"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Hồ sơ"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Tin tức"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Xác minh"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Tin nhắn"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Học hỏi"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Mời bạn bè"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Xóa thất bại!"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Gửi"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Giới hạn Gas"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("Không còn nữa"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Đang tải "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Danh bạ địa chỉ"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Nhập ví"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Quản lý"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Địa chỉ mới"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Xóa"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Lưu"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Sao chép"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("Tạo/Nhập ví"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Giao diện"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("Hệ thống"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Sáng"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Tối"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Danh sách ví"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Không có dữ liệu"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Số lượng không hợp lệ"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Ví chính"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Giao dịch thành công"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Mật khẩu không đúng"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Mạng thử nghiệm"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Mạng chính"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Ngôn ngữ hệ thống"),
    "g_key_15": MessageLookupByLibrary.simpleMessage("Đặt làm ví chính"),
    "g_key_154": MessageLookupByLibrary.simpleMessage("Gửi"),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Địa chỉ ví"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Quét để sao chép địa chỉ",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Thêm"),
    "g_key_16": MessageLookupByLibrary.simpleMessage("Chọn ví xác minh"),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Ký hiệu"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Dán"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Chọn chuỗi"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("Giao dịch thất bại"),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "Đây là địa chỉ ví của tôi",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Khác"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Lưu thành công"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Thành công"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Bạn có chắc chắn muốn xóa ví không?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Đang hoạt động"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Không có quyền truy cập camera.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Trình duyệt"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Tối đa"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Tài sản"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("Sổ cái trống!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("Tổng quan giao dịch"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Lỗi liên kết, quét lại mã QR.",
    ),
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "Không có quyền truy cập thư viện ảnh.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Sửa mật khẩu"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Mật khẩu cũ"),
    "g_key_208": MessageLookupByLibrary.simpleMessage("Đang đồng bộ số dư..."),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Khóa riêng tư"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("Nhập mật khẩu ví"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Lỗi khóa riêng tư"),
    "g_key_211": MessageLookupByLibrary.simpleMessage("Mua"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Bán"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Thông tin thị trường"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage("Mật khẩu không khớp."),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Số dư"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Thêm thất bại!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Nhận"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Chuyển"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("Đến"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Quét mã QR"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("Nhập địa chỉ ví"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Số dư khả dụng"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Số lượng"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Số dư không đủ để thực hiện giao dịch này.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Gửi"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Tải thất bại!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Ví"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Tạo"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("Từ"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Xác nhận"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Hủy"),
    "g_key_8": MessageLookupByLibrary.simpleMessage("Ghi chú"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Cụm từ khôi phục"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Tất cả token"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Cài đặt"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Địa chỉ"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập tên",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập địa chỉ",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Vui lòng chọn loại coin",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("Sửa địa chỉ"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage("Xóa thành công"),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Chọn coin"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Tìm kiếm coin"),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "Lỗi phân tích dữ liệu phản hồi!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Lỗi Dio"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Lỗi cú pháp yêu cầu",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Chưa xác thực, vui lòng đăng nhập",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage(
      "Truy cập bị từ chối",
    ),
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Tài khoản hoặc mật khẩu không đúng",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Lỗi yêu cầu"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "Bạn đã đăng nhập trên điện thoại khác và bị buộc đăng xuất.",
    ),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "Yêu cầu hết thời gian",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage(
      "Máy chủ bất thường",
    ),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Dịch vụ chưa được triển khai",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Lỗi cổng"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Dịch vụ không khả dụng",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Cổng hết thời gian",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "Phiên bản HTTP không được hỗ trợ",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "Yêu cầu thất bại, mã lỗi:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "Hệ thống đang bận, vui lòng thử lại sau",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Tần suất yêu cầu quá nhanh",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage("Giải mã thất bại"),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "Giao dịch đã được ghi nhận trên chuỗi",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Lỗi cấu hình chứng chỉ!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Lỗi cấu hình mã trạng thái!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage(
      "Lỗi không xác định!",
    ),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Kết nối mạng hết thời gian, vui lòng kiểm tra cài đặt mạng!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "Máy chủ bất thường. Vui lòng thử lại sau!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "Yêu cầu đã bị hủy, vui lòng yêu cầu lại!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage("Xuất Keystore"),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage("Mẹo sao lưu"),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Sử dụng công cụ quản lý mật khẩu để lưu trữ.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Đã sao chép"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Đã hủy sao chép",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Ví danh tính",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Tệp khóa riêng tư được mã hóa.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Phương thức nhập",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Tệp Keystore",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập thông tin Keystore.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Xuất khóa riêng tư",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Việc có được Keystore và mật khẩu sẽ cho phép người sở hữu toàn quyền kiểm soát tài sản ví.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Ghi lại cẩn thận và lưu trữ ở nơi an toàn. Giữ nhiều bản sao vật lý là phương pháp lưu trữ an toàn nhất.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Nếu khóa riêng tư bị mất, không thể khôi phục được. Sao lưu vật lý và lưu trữ an toàn.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Lưu ngoại tuyến",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Không lưu vào bất kỳ hộp thư, ghi chú, ổ đĩa mạng hoặc phần mềm chat không an toàn.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Vui lòng sử dụng truyền tải mạng",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Hãy chắc chắn truyền tải qua các công cụ mạng. Khi hacker có được, sẽ gây ra tổn thất kinh tế không thể khắc phục",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Sử dụng công cụ để lưu",
    ),
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Phản hồi"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Vui lòng điền thông tin phản hồi",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "Có tệp đính kèm chưa tải lên",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage("Gửi thất bại"),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage("Gửi thành công"),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Tệp đính kèm"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "Tải lên tối đa 5 tệp đính kèm, mỗi tệp không quá 100MB",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Thất bại"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage("Nhấn thử"),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage(
      "Vui lòng đăng nhập",
    ),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Ví tiền tệ hiện tại đã tồn tại.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Không thể đọc Keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Đăng nhập"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Đăng xuất"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Bạn có chắc chắn muốn thoát ứng dụng không?",
    ),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Trình duyệt"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Vốn hóa thị trường"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Khối lượng giao dịch"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Tổng cung"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("Đang lưu hành"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Giới thiệu"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Xem thêm"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Liên kết"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Trang web"),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập cụm từ khôi phục",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Tổng"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Máy ảnh"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Chọn ảnh"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Nội dung"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Tên"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Quay lại"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Giao dịch đã gửi"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Chọn video"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Chọn từ thư viện ảnh điện thoại",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("Chia sẻ mã QR"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage(
      "Chia sẻ liên kết",
    ),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Phương thức chia sẻ",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chat"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Tệp quá lớn để tải lên",
    ),
    "g_key_squad_k15": m10,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("Thêm liên hệ"),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Liên hệ"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage(
      "Tìm kiếm theo email",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Hoàn tất"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Giá Gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Phí Gas tối đa"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Phí tối đa mỗi Gas"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Đang chờ"),
    "g_key_t_29": m11,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Thất bại"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("Phí thợ đào"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Tiếp tục"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Mật khẩu ví"),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "Mật khẩu ví không được để trống",
    ),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage("Sai mật khẩu ví"),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập mật khẩu ví",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("Tỷ lệ phí Gas"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "Tỷ lệ phí Gas trung bình của khối mới nhất",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Chuyển đi"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Nhập số nguyên lớn hơn 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage("Không thể lấy dữ liệu"),
    "g_key_t_45": m12,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Kiểm tra tài khoản địa chỉ nhận",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Tìm"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Không có tài khoản"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Chuyển đến"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Địa chỉ không hợp lệ"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Xác minh tài khoản thành công",
    ),
    "g_key_t_52": m13,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "Địa chỉ nhận chưa có tài khoản, và lần chuyển đầu tiên tối thiểu 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas đã dùng"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("Lịch sử giao dịch"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("Chi tiết giao dịch"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Vui lòng xem biên lai giao dịch trong lịch sử",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Số tiền chi tiêu"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Số tiền nhận"),
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("Loại NFT"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Người theo dõi"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Loại người dùng"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Trang web"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Liên kết sản phẩm"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("Nền tảng truyền thông"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("Địa chỉ ví"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Biệt danh"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage(
      "Tải lên ảnh đại diện thất bại",
    ),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Mô tả"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage("Thông tin nghệ sĩ"),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage(
      "Bạn không phải là nghệ sĩ",
    ),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Nhấn vào đây để đăng ký trở thành nghệ sĩ",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Tên"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Doanh thu"),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage(
      "Tôi đã đọc và chấp nhận ",
    ),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage(
      "Điều khoản & Điều kiện",
    ),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Chính sách bảo mật và Tuyên bố thu thập thông tin cá nhân",
    ),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Tìm thấy phiên bản mới nhất",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Cập nhật ngay"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage(
      "Phát hiện phiên bản mới",
    ),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Đã là phiên bản mới nhất",
    ),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Xem cụm từ khôi phục",
    ),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Hãy đảm bảo bạn ghi lại cụm từ khôi phục và lưu giữ an toàn.",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Bây giờ hãy thử nhập lại cụm từ khôi phục của bạn.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("Nhập tài khoản"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Tạo tài khoản"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage(
      "Bạn đã hoàn tất!",
    ),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Bạn có thể tận hưởng đầy đủ ví của mình ngay bây giờ.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Bắt đầu"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("Bỏ qua bây giờ"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Bạn có thể bỏ qua sao lưu cụm từ khôi phục bây giờ và thực hiện lại trong Cài đặt bất kỳ lúc nào nếu cần.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage("Tạo trực tiếp"),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage("Tạo thành công"),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Nếu bạn muốn kiểm tra chi tiết ví hoặc xuất keystore, bạn có thể vào Thanh bên > Quản lý ví",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Xuất keystore của tôi",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Bảo mật ví của bạn bằng cách sao lưu",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Keystore là kho lưu trữ chứng chỉ bảo mật và khóa riêng tư liên quan.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Bước 1: Đi đến Quản lý ví.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Bước 2: Chọn Địa chỉ ví.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Bước 3: Nhấn Xuất Keystore.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Đi đến Quản lý ví",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Quay lại trang chủ",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("Thêm ví"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Tạo ví bằng cụm từ khôi phục.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage("Nhập tên ví"),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Bạn chưa sao lưu cụm từ khôi phục ví!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("Sao lưu ngay"),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage("Đặt mật khẩu ví"),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage("Sao lưu ví"),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Vui lòng ghi lại cụm từ khôi phục sau đây",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Bắt đầu"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Các thiết bị kết nối internet có thể làm lộ thông tin của bạn. Chúng tôi khuyến nghị bạn viết ra cụm từ khôi phục và lưu trữ an toàn.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Cảnh báo: Không tiết lộ cụm từ khôi phục cho bất kỳ ai. N42Wallet sẽ không bao giờ yêu cầu thông tin này. Hãy cực kỳ cẩn thận và lưu trữ ngoại tuyến an toàn. Nếu cụm từ khôi phục bị lộ, bạn có thể mất tất cả tài sản và không thể khôi phục được.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Cảnh báo: Cụm từ khôi phục là cách duy nhất để khôi phục tài sản ví của bạn.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("Bước tiếp theo"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Nhấn để xem cụm từ khôi phục",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Hãy đảm bảo không có người khác hoặc camera xung quanh",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Xác nhận cụm từ khôi phục",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage("Thông tin ví"),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("Tên ví"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Vui lòng sao lưu cụm từ khôi phục ví của bạn trước!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Kiểm tra cụm từ khôi phục",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Bây giờ nhập cụm từ khôi phục của bạn.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Đặt cụm từ"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Hãy đảm bảo bạn ghi lại cụm từ khôi phục và lưu giữ an toàn. Bạn sẽ cần nó để nhập hoặc khôi phục ví tiền mã hóa của mình.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage("Chỉnh sửa ví"),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Thời gian"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Kết quả"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage(
      "Mã băm giao dịch",
    ),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Thêm"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Đường dẫn"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Khối"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Giá trị"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Tăng tốc"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Ghi chú"),
    "g_key_wallet_m1": m14,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Bạn có chắc chắn muốn hủy tài khoản không?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Xác nhận đăng xuất",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập mã xác minh Google.",
    ),
    "g_key_wallet_m19": m15,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Token hiện tại chưa được thêm.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Nhập cụm từ khôi phục với các từ cách nhau bằng dấu cách",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("Nhập ví"),
    "g_key_wallet_m3": m16,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Số dư token hiện tại không đủ.",
    ),
    "g_key_wallet_m5": m17,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Lỗi ký"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage("Hủy tài khoản"),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "Nhập mã xác minh email.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage("Quản lý ví"),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Dự trữ"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Dự trữ cơ bản"),
    "g_key_xml_11": m18,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Dự trữ gia tăng"),
    "g_key_xml_22": m19,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Số lượng đối tượng sở hữu",
    ),
    "g_key_xml_33": m20,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Cách tính tổng số tiền dự trữ",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Tổng dự trữ = Dự trữ cơ bản + (Số lượng đối tượng sở hữu × Dự trữ gia tăng)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID và Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Mật khẩu hiện tại"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("Mật khẩu mới"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage(
      "Xác nhận mật khẩu mới",
    ),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("Số 6 chữ số"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage(
      "Mật khẩu và sinh trắc học",
    ),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Mật khẩu hình vẽ"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage("Đặt mã hình vẽ"),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Để bảo mật tài khoản, vui lòng đặt mật khẩu nhóm",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Vẽ lại mật khẩu hình vẽ",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage("Vẽ mật khẩu hình vẽ"),
    "g_lock_key21": m21,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Đặt lại mật khẩu hình vẽ",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Nhập sai quá nhiều lần, vui lòng đặt lại mật khẩu",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage("Thêm mật khẩu ví?"),
    "g_lock_key25": m22,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage("Trang màn hình khóa"),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("Tự động khóa"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Thành công"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Thất bại"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Nhận dạng sinh trắc học chưa được bật",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Thêm xác minh sinh trắc học?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage("Đặt lại mật khẩu"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Mở khóa N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Hoạt động xác minh đám mây",
    ),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "Thiết lập cần một lượng nhỏ để trả phí gas.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Bạn đã tham gia thành công Node nhóm trên N42Wallet. Chia sẻ liên kết để mời bạn bè, kích hoạt Node và bắt đầu xác minh!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Chia sẻ cho bạn bè",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Tiếp tục"),
    "g_mining_key63": m23,
    "g_mining_key73": m24,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Tôi vừa thiết lập một node trên @N42Wallet và bắt đầu xác minh trên thiết bị di động! Hãy tham gia cùng tôi. Tương lai phi tập trung là di động!",
    ),
    "g_mining_key76": m25,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Có thể đổi thưởng sau 768 giây.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Các yêu cầu trước đó sẽ không được xử lý.",
    ),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "Phần thưởng hôm nay",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Vui lòng coi dữ liệu dưới đây như một khóa quan trọng. Chúng tôi khuyến nghị sao chép và sao lưu ngay đến một vị trí đáng tin cậy.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage(
      "Sao chép dữ liệu",
    ),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Không hoạt động"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage(
      "Danh sách người xác thực",
    ),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage("Nhập thành công"),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Dữ liệu mã hóa không được để trống!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "Mật khẩu không được để trống!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Giải mã thất bại. Vui lòng kiểm tra mật khẩu có đúng không!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Định dạng dữ liệu mã hóa không được hỗ trợ!",
    ),
    "g_mining_key_109": m26,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Phần thưởng hôm qua",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage("Dữ liệu mã hóa"),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("Nhập tệp"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập dữ liệu mã hóa.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("Đang nhập..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Xác nhận"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Đổi thưởng cần một chút thời gian, vui lòng đợi một lát!",
    ),
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Phần thưởng tích lũy hàng ngày và chỉ được gửi đến ví N của bạn khi đạt ~0.5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("Tổng phần thưởng"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Giá trị đã đào"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Tính toán dựa trên giá thị trường của N nhân tổng phần thưởng N.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Số lượng xác thực",
    ),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("Chọn gói"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Thời gian mở khóa: Có thể mở khóa bất kỳ lúc nào",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Phần thưởng tối đa hàng năm",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Phân phối phần thưởng",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage(
      "Giới hạn hàng ngày",
    ),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Tốc độ"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage("Gói xác minh"),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Chọn phương thức thanh toán",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage(
      "Phương thức thanh toán",
    ),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage(
      "Thanh toán bằng N",
    ),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("Số dư ví"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "Bạn không có đủ N cho giao dịch này",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Đã tắt"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Xem thêm"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Trạng thái xác minh",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Khóa N để bắt đầu nhận phần thưởng xác minh.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Nhập cuộc"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Node nâng cao"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Node nhập cuộc"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Node Pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 khối/ngày~70 phút",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Chọn gói"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 khối/ngày~15 phút",
    ),
    "g_mining_key_71": m27,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 giây mỗi lần kiểm tra",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Xác minh đám mây đã bắt đầu",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "Chuỗi thử nghiệm đang được nâng cấp và tạm thời không thể xác minh khối.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Không hoàn thành nhiệm vụ trong bốn ngày liên tiếp sẽ không có thu nhập và có nguy cơ bị phạt.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("Điểm rủi ro"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Đổi thưởng"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Vui lòng lưu cặp khóa công khai và khóa riêng tư của người xác minh trước.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Xuất"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Số dư không đủ để chuyển.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "Danh sách người xác thực",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Nhập người xác thực",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "Người xác thực đã tồn tại",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Rủi ro thấp"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage(
      "Rủi ro tương đối thấp",
    ),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Rủi ro tương đối cao",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Rủi ro cao"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "Hợp đồng đang tải và không thể xác minh vào lúc này. Vui lòng đợi một lát!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage("Mẹo an toàn"),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage("Xác minh nền"),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Vui lòng giữ khóa riêng tư hoặc cụm từ khôi phục của bạn an toàn.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Khóa riêng tư hoặc cụm từ khôi phục của bạn là thông tin xác thực duy nhất để truy cập tài sản ví của bạn.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Vui lòng lưu giữ ở nơi an toàn (giấy, trình quản lý mật khẩu, v.v.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Không chụp ảnh màn hình, tải lên internet hoặc chia sẻ với bất kỳ ai.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Một khi bị mất hoặc lộ, tài sản ví của bạn không thể khôi phục được.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage("Xác nhận và lưu"),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Đặt mật khẩu và mã hóa",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập mật khẩu mã hóa",
    ),
    "g_mining_key_98": m28,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập lại mật khẩu để đảm bảo chính xác",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage("Thông báo"),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Chia sẻ"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Giới thiệu"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Giới thiệu bạn bè và nhận Token N!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage(
      "Bạn nhận được tới ",
    ),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N khi người được giới thiệu bắt đầu xác minh!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Giới thiệu qua"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Liên kết"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("mã"),
    "g_swap_key_14": m29,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage("Lỗi lấy giá coin."),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Bằng việc tiếp tục, bạn đồng ý với ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Điều khoản và Điều kiện.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Hoàn tất"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Giao dịch hoán đổi của bạn sẽ được phân phối trong thời gian ngắn. Vui lòng kiên nhẫn.",
    ),
    "g_swap_key_20": m30,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Chi phí vận hành node: Xác minh nhóm 1-49 N Node cơ bản: 50 N Node cao cấp: 100 N Node Pro: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Hết hạn"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Chưa thanh toán"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage(
      "Đang xác nhận thanh toán",
    ),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("Chờ phân phối"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("Tóm tắt hoán đổi"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Số dư mới"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Bạn trả"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Ngày"),
    "g_swap_key_31": m31,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Các giao dịch hoán đổi có thể xem trên các trình duyệt chuỗi liên quan (Etherscan, BscScan, TRONSCAN và của chúng tôi).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Hoán đổi sang N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Hoán đổi"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Bạn nhận"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Xem trước hoán đổi"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Thử lại"),
    "g_token_m_key_1": m32,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Bất kỳ ai cũng có thể tạo token, bao gồm cả việc tạo phiên bản giả của token hiện có. Luôn nghiên cứu token trước khi nhập.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Token"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Tìm kiếm token"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("Tên chuỗi"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("Ký hiệu chuỗi"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("ID chuỗi"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Số thập phân"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Thêm chuỗi tùy chỉnh",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 đơn vị"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Thêm token"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Lỗi định dạng!"),
    "g_token_m_key_22": m33,
    "g_token_m_key_23": m34,
    "g_token_m_key_24": m35,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Nhập token"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Tất cả mạng"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("Token tùy chỉnh"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Địa chỉ token"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Ký hiệu token"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage(
      "Số thập phân token",
    ),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Nhập"),
    "g_unlock_key10": m36,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Chưa bật nhận dạng vân tay hoặc khuôn mặt?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Vẽ mật khẩu hình vẽ",
    ),
    "g_unlock_key4": m37,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Nhập mật khẩu"),
    "g_unlock_key6": m38,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage("Xác thực thất bại"),
    "g_unlock_key8": m39,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Bạn cũng có thể "),
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Xác thực Google",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Liên kết",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Tải Google Authenticator",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Hướng dẫn",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Mở Google Authenticator.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "Bạn sẽ thấy mã xác minh 6 chữ số trên màn hình.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "Sao chép mã 6 chữ số và dán vào N42Wallet.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "Sau đó, Authenticator của bạn sẽ được liên kết thành công.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Khóa sao lưu",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Sao chép khóa vào Google Authenticator",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Nhập mã xác minh Google",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "Nhập mã xác minh email",
    ),
    "google_verification_message21": m40,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Không thể lấy khóa Google",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "Xác thực hai yếu tố (2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "Để bảo vệ tài khoản của bạn, khuyến nghị bật ít nhất một 2FA.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "Ứng dụng Google Authenticator bảo vệ các khoản rút tiền và tài khoản N42Wallet của bạn.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "Tải xuống và cài đặt",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Vui lòng tải xuống và cài đặt Google Authenticator. Sau đó nhấn \'Liên kết\' để liên kết tài khoản N42Wallet của bạn.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage(
      "Thông báo quan trọng",
    ),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Đăng nhập"),
    "login_email": MessageLookupByLibrary.simpleMessage("Email"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Quên mật khẩu?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage("Mã giới thiệu"),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Mã giới thiệu",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage(
      "Chưa có tài khoản? ",
    ),
    "login_message_10": MessageLookupByLibrary.simpleMessage("Tạo thành công"),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Đặt lại thành công",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage(
      "Đã có tài khoản? ",
    ),
    "login_message_6": MessageLookupByLibrary.simpleMessage("Gửi lại mã sau "),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Gửi mã thành công",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "Email chưa đăng ký",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage("Gửi mã thất bại"),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "vui lòng đăng nhập trước",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Mật khẩu"),
    "next": MessageLookupByLibrary.simpleMessage("Tiếp theo"),
    "nicknameMessage": m41,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "Mật khẩu không khớp",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Chỉnh sửa hồ sơ",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Chụp ảnh"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Nhập mã xác minh",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập email",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập mật khẩu",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập địa chỉ",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage("Nhập lại mật khẩu"),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Chọn mật khẩu (8~18 ký tự)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Xác nhận mật khẩu",
    ),
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Nhập lại mật khẩu",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage("Nhập mã"),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage("Mã OTP"),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Đặt lại mật khẩu của bạn",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Quản lý ví"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Về ứng dụng"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Bảo mật"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("Sử dụng Chat mới"),
    "s_key_13": MessageLookupByLibrary.simpleMessage(
      "Bật trải nghiệm Chat nâng cao",
    ),
    "s_key_2": MessageLookupByLibrary.simpleMessage("Địa chỉ ví"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Giao dịch"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Ngôn ngữ"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Giao diện"),
    "search": MessageLookupByLibrary.simpleMessage("Tìm kiếm"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Vui lòng đọc thỏa thuận và xác nhận",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("xác minh"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Nếu tôi mất cụm từ bí mật, tiền của tôi sẽ bị mất vĩnh viễn.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Nếu tôi tiết lộ hoặc chia sẻ cụm từ khôi phục cho bất kỳ ai, tiền của tôi có thể bị đánh cắp.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "Tôi có trách nhiệm giữ an toàn cụm từ khôi phục của mình.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage(
      "Cụm từ khôi phục không đúng.",
    ),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Nhập cụm từ khôi phục cho ví bạn muốn nhập.",
    ),
  };
}

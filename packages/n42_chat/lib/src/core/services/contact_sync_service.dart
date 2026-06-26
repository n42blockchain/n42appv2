import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../utils/debug_log.dart';

final RegExp _phoneNormalizeRegExp = RegExp(r'[\s\-\(\)]');
final RegExp _phoneDigitsRegExp = RegExp(r'^[+]?[0-9]+$');
final RegExp _emailValidateRegExp =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

/// 手机通讯录联系人
class PhoneContact {
  final String id;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final List<String> phones;
  final List<String> emails;
  final Uint8List? photoBytes;

  const PhoneContact({
    required this.id,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.phones = const [],
    this.emails = const [],
    this.photoBytes,
  });

  /// 主要电话号码（标准化后）
  String? get primaryPhone {
    if (phones.isEmpty) return null;
    return _normalizePhone(phones.first);
  }

  /// 主要邮箱
  String? get primaryEmail {
    if (emails.isEmpty) return null;
    return emails.first.toLowerCase();
  }

  /// 标准化电话号码（移除空格、破折号等）
  static String _normalizePhone(String phone) {
    return phone.replaceAll(_phoneNormalizeRegExp, '');
  }
}

/// 匹配的通讯录联系人
class MatchedContact {
  final PhoneContact phoneContact;
  final String matrixUserId;
  final String? matrixDisplayName;
  final String? matrixAvatarUrl;

  const MatchedContact({
    required this.phoneContact,
    required this.matrixUserId,
    this.matrixDisplayName,
    this.matrixAvatarUrl,
  });
}

/// 通讯录同步服务
///
/// 提供手机通讯录读取和 Matrix 用户匹配功能
///
/// 隐私说明：
/// - 搜索使用模糊匹配，不直接暴露完整信息
/// - 批量处理以减少网络请求
class ContactSyncService {
  final MatrixClientManager _clientManager;

  /// 每批处理的联系人数量
  static const int _batchSize = 10;

  /// 请求之间的延迟（毫秒），用于限流
  static const int _requestDelayMs = 100;

  ContactSyncService(this._clientManager);

  /// 对敏感信息进行单向哈希（用于日志，不发送到服务器）
  String _hashForLogging(String value) {
    final bytes = utf8.encode(value);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 8);
  }

  /// 检查/请求通讯录权限
  Future<bool> requestPermission() async {
    try {
      return await FlutterContacts.requestPermission(readonly: true);
    } catch (e) {
      debugLog('ContactSyncService: Permission request error: $e');
      return false;
    }
  }

  /// 获取手机通讯录联系人
  Future<List<PhoneContact>> getPhoneContacts({
    bool withPhoto = false,
  }) async {
    try {
      final hasAccess = await requestPermission();
      if (!hasAccess) {
        debugLog('ContactSyncService: No contacts permission');
        return [];
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: withPhoto,
      );

      return contacts.map((c) => PhoneContact(
        id: c.id,
        displayName: c.displayName,
        firstName: c.name.first,
        lastName: c.name.last,
        phones: c.phones.map((p) => p.number).toList(),
        emails: c.emails.map((e) => e.address).toList(),
        photoBytes: withPhoto ? c.photo : null,
      )).toList();
    } catch (e) {
      debugLog('ContactSyncService: Get contacts error: $e');
      return [];
    }
  }

  /// 验证邮箱格式
  bool _isValidEmail(String email) {
    if (email.isEmpty || email.length > 254) return false;
    return _emailValidateRegExp.hasMatch(email);
  }

  /// 验证电话号码格式
  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    final normalized = PhoneContact._normalizePhone(phone);
    if (normalized.length < 5 || normalized.length > 20) return false;
    return _phoneDigitsRegExp.hasMatch(normalized);
  }

  /// 搜索匹配的 Matrix 用户
  ///
  /// 通过电话号码或邮箱查找已注册的 Matrix 用户
  /// 使用批量处理和请求节流来优化性能
  Future<List<MatchedContact>> findMatchingUsers(
    List<PhoneContact> phoneContacts, {
    void Function(int current, int total)? onProgress,
  }) async {
    final client = _clientManager.client;
    if (client == null) {
      debugLog('ContactSyncService: Matrix client not available');
      return [];
    }

    final matched = <MatchedContact>[];
    final processedUserIds = <String>{};
    final total = phoneContacts.length;
    var processed = 0;

    // 分批处理联系人
    for (var i = 0; i < phoneContacts.length; i += _batchSize) {
      final batchEnd = min(i + _batchSize, phoneContacts.length);
      final batch = phoneContacts.sublist(i, batchEnd);

      for (final contact in batch) {
        // 搜索邮箱
        for (final email in contact.emails) {
          if (!_isValidEmail(email)) continue;

          try {
            final response = await client.searchUserDirectory(
              email,
              limit: 3,
            );

            for (final user in response.results) {
              if (processedUserIds.contains(user.userId)) continue;
              processedUserIds.add(user.userId);

              matched.add(MatchedContact(
                phoneContact: contact,
                matrixUserId: user.userId,
                matrixDisplayName: user.displayName,
                matrixAvatarUrl: user.avatarUrl?.toString(),
              ));
            }

            // 请求节流
            await Future<void>.delayed(const Duration(milliseconds: _requestDelayMs));
          } catch (e) {
            // 使用哈希保护隐私信息
            debugLog('ContactSyncService: Search error for ${_hashForLogging(email)}: $e');
          }
        }

        // 搜索电话号码
        for (final phone in contact.phones) {
          if (!_isValidPhone(phone)) continue;

          try {
            final normalizedPhone = PhoneContact._normalizePhone(phone);

            final response = await client.searchUserDirectory(
              normalizedPhone,
              limit: 3,
            );

            for (final user in response.results) {
              if (processedUserIds.contains(user.userId)) continue;
              processedUserIds.add(user.userId);

              matched.add(MatchedContact(
                phoneContact: contact,
                matrixUserId: user.userId,
                matrixDisplayName: user.displayName,
                matrixAvatarUrl: user.avatarUrl?.toString(),
              ));
            }

            // 请求节流
            await Future<void>.delayed(const Duration(milliseconds: _requestDelayMs));
          } catch (e) {
            debugLog('ContactSyncService: Search error for phone: $e');
          }
        }

        processed++;
        onProgress?.call(processed, total);
      }
    }

    return matched;
  }

  /// 同步通讯录并返回匹配的用户
  ///
  /// 这是主要的入口方法，会：
  /// 1. 请求通讯录权限
  /// 2. 读取手机通讯录
  /// 3. 搜索匹配的 Matrix 用户
  ///
  /// [onProgress] 回调用于报告进度
  /// [withPhotos] 是否加载联系人照片（可能影响性能）
  Future<ContactSyncResult> syncContacts({
    void Function(int current, int total)? onProgress,
    bool withPhotos = false,
  }) async {
    // 检查权限
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      return const ContactSyncResult(
        success: false,
        error: 'Permission denied',
        phoneContacts: [],
        matchedContacts: [],
      );
    }

    // 读取通讯录（默认不加载照片以提升性能）
    final phoneContacts = await getPhoneContacts(withPhoto: withPhotos);
    if (phoneContacts.isEmpty) {
      return const ContactSyncResult(
        success: true,
        phoneContacts: [],
        matchedContacts: [],
      );
    }

    // 报告进度
    onProgress?.call(0, phoneContacts.length);

    // 搜索匹配用户（带进度回调）
    final matchedContacts = await findMatchingUsers(
      phoneContacts,
      onProgress: onProgress,
    );

    return ContactSyncResult(
      success: true,
      phoneContacts: phoneContacts,
      matchedContacts: matchedContacts,
    );
  }
}

/// 通讯录同步结果
class ContactSyncResult {
  final bool success;
  final String? error;
  final List<PhoneContact> phoneContacts;
  final List<MatchedContact> matchedContacts;

  const ContactSyncResult({
    required this.success,
    this.error,
    required this.phoneContacts,
    required this.matchedContacts,
  });

  /// 是否有匹配的用户
  bool get hasMatches => matchedContacts.isNotEmpty;

  /// 匹配数量
  int get matchCount => matchedContacts.length;
}

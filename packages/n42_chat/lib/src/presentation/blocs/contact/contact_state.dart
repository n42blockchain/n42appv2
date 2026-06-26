import 'package:equatable/equatable.dart';

import '../../../domain/entities/contact_entity.dart';
import '../../../domain/repositories/contact_repository.dart';

/// 联系人状态枚举
enum ContactStatus {
  /// 初始状态
  initial,

  /// 加载中
  loading,

  /// 已加载
  loaded,

  /// 开始聊天成功
  chatStarted,

  /// 备注更新成功
  remarkUpdated,

  /// 联系人已删除
  deleted,

  /// 错误
  error,
}

/// 联系人状态（单一 State + copyWith 模式）
class ContactState extends Equatable {
  /// 当前状态
  final ContactStatus status;

  /// 所有联系人
  final List<ContactEntity> contacts;

  /// 过滤后的联系人（搜索结果）
  final List<ContactEntity> filteredContacts;

  /// 搜索结果（全局搜索）
  final List<ContactEntity> searchResults;

  /// 好友请求列表
  final List<FriendRequest> friendRequests;

  /// 按字母分组的联系人
  final Map<String, List<ContactEntity>> groupedContacts;

  /// 索引字母列表
  final List<String> indexLetters;

  /// 搜索关键词
  final String searchQuery;

  /// 是否正在搜索
  final bool isSearching;

  /// 是否正在全局搜索
  final bool isGlobalSearching;

  /// 开始聊天的 roomId
  final String? startedChatRoomId;

  /// 开始聊天的 userId
  final String? startedChatUserId;

  /// 更新备注的 userId
  final String? updatedRemarkUserId;

  /// 更新后的备注
  final String? updatedRemark;

  /// 删除的联系人 userId
  final String? deletedUserId;

  /// 错误消息
  final String? errorMessage;

  const ContactState({
    this.status = ContactStatus.initial,
    this.contacts = const [],
    this.filteredContacts = const [],
    this.searchResults = const [],
    this.friendRequests = const [],
    this.groupedContacts = const {},
    this.indexLetters = const [],
    this.searchQuery = '',
    this.isSearching = false,
    this.isGlobalSearching = false,
    this.startedChatRoomId,
    this.startedChatUserId,
    this.updatedRemarkUserId,
    this.updatedRemark,
    this.deletedUserId,
    this.errorMessage,
  });

  const ContactState.initial() : this();

  /// 是否正在加载
  bool get isLoading => status == ContactStatus.loading;

  /// 是否已加载
  bool get isLoaded => status == ContactStatus.loaded || contacts.isNotEmpty;

  /// 是否有错误
  bool get hasError => status == ContactStatus.error && errorMessage != null;

  ContactState copyWith({
    ContactStatus? status,
    List<ContactEntity>? contacts,
    List<ContactEntity>? filteredContacts,
    List<ContactEntity>? searchResults,
    List<FriendRequest>? friendRequests,
    Map<String, List<ContactEntity>>? groupedContacts,
    List<String>? indexLetters,
    String? searchQuery,
    bool? isSearching,
    bool? isGlobalSearching,
    String? startedChatRoomId,
    String? startedChatUserId,
    String? updatedRemarkUserId,
    String? updatedRemark,
    String? deletedUserId,
    String? errorMessage,
  }) {
    return ContactState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      searchResults: searchResults ?? this.searchResults,
      friendRequests: friendRequests ?? this.friendRequests,
      groupedContacts: groupedContacts ?? this.groupedContacts,
      indexLetters: indexLetters ?? this.indexLetters,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      isGlobalSearching: isGlobalSearching ?? this.isGlobalSearching,
      startedChatRoomId: startedChatRoomId,
      startedChatUserId: startedChatUserId,
      updatedRemarkUserId: updatedRemarkUserId,
      updatedRemark: updatedRemark,
      deletedUserId: deletedUserId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contacts,
        filteredContacts,
        searchResults,
        friendRequests,
        groupedContacts,
        indexLetters,
        searchQuery,
        isSearching,
        isGlobalSearching,
        startedChatRoomId,
        startedChatUserId,
        updatedRemarkUserId,
        updatedRemark,
        deletedUserId,
        errorMessage,
      ];

  @override
  String toString() => 'ContactState(status: $status, contacts: ${contacts.length})';
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/remark_service.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../../domain/repositories/contact_repository.dart';
import 'contact_event.dart';
import 'contact_state.dart';
import '../../../core/utils/debug_log.dart';

/// 联系人BLoC
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final IContactRepository _contactRepository;

  StreamSubscription<List<ContactEntity>>? _contactsSubscription;
  StreamSubscription<Map<String, bool>>? _onlineStatusSubscription;

  ContactBloc(this._contactRepository) : super(const ContactState.initial()) {
    on<LoadContacts>(_onLoadContacts);
    on<RefreshContacts>(_onRefreshContacts);
    on<SearchContacts>(_onSearchContacts);
    on<SearchUsers>(_onSearchUsers);
    on<ClearSearch>(_onClearSearch);
    on<StartChat>(_onStartChat);
    on<IgnoreUser>(_onIgnoreUser);
    on<UnignoreUser>(_onUnignoreUser);
    on<LoadFriendRequests>(_onLoadFriendRequests);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<RejectFriendRequest>(_onRejectFriendRequest);
    on<ContactsUpdated>(_onContactsUpdated);
    on<OnlineStatusUpdated>(_onOnlineStatusUpdated);
    on<SetContactRemark>(_onSetContactRemark);
    on<DeleteContact>(_onDeleteContact);
  }

  Future<void> _onLoadContacts(
    LoadContacts event,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(status: ContactStatus.loading));

    try {
      // 订阅联系人变化
      unawaited(_contactsSubscription?.cancel());
      _contactsSubscription = _contactRepository.watchContacts().listen(
        (contacts) {
          // 防止在 BLoC 关闭后添加事件
          if (!isClosed) {
            add(const ContactsUpdated());
          }
        },
        onError: (Object error) {
          debugLog('ContactBloc: Contacts stream error: $error');
          if (!isClosed) add(const LoadFriendRequests());
        },
      );

      // 订阅在线状态变化
      unawaited(_onlineStatusSubscription?.cancel());
      _onlineStatusSubscription = _contactRepository.watchOnlineStatus().listen(
        (statusMap) {
          // 防止在 BLoC 关闭后添加事件
          if (!isClosed) {
            add(OnlineStatusUpdated(statusMap));
          }
        },
        onError: (Object error) {
          debugLog('ContactBloc: Online status stream error: $error');
        },
      );

      await _refreshContactSnapshot(emit);
    } catch (e) {
      emit(
        state.copyWith(status: ContactStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onRefreshContacts(
    RefreshContacts event,
    Emitter<ContactState> emit,
  ) async {
    debugLog('ContactBloc: RefreshContacts triggered');
    if (state.status == ContactStatus.initial) {
      add(const LoadContacts());
      return;
    }

    try {
      await _refreshContactSnapshot(emit);
    } catch (e) {
      emit(
        state.copyWith(status: ContactStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Invitations must remain available when an unrelated contact lookup fails.
  /// Preserve whichever list could not be refreshed instead of clearing it.
  Future<void> _refreshContactSnapshot(Emitter<ContactState> emit) async {
    List<ContactEntity>? contacts;
    List<FriendRequest>? requests;
    Object? failure;
    // Publish received invitations before potentially slow contact hydration.
    try {
      requests = await _contactRepository.getPendingFriendRequests();
      if (requests.isNotEmpty) {
        emit(state.copyWith(friendRequests: requests));
      }
    } catch (_) {
      // Retry below after contact hydration; preserve the current snapshot.
    }

    try {
      contacts = await _contactRepository.getContacts();
    } catch (e) {
      failure = e;
    }
    try {
      requests = await _contactRepository.getPendingFriendRequests();
    } catch (e) {
      failure ??= e;
    }
    final currentContacts = contacts ?? state.contacts;
    final grouped = _groupContactsByLetter(currentContacts);
    emit(
      state.copyWith(
        status: failure == null ? ContactStatus.loaded : ContactStatus.error,
        errorMessage: failure?.toString(),
        contacts: currentContacts,
        filteredContacts: state.searchQuery.isEmpty
            ? currentContacts
            : state.filteredContacts,
        friendRequests: requests ?? state.friendRequests,
        groupedContacts: grouped,
        indexLetters: grouped.keys.toList()..sort(),
      ),
    );
  }

  Future<void> _onSearchContacts(
    SearchContacts event,
    Emitter<ContactState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(
        state.copyWith(
          filteredContacts: state.contacts,
          searchQuery: '',
          isSearching: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isSearching: true, searchQuery: event.query));

    try {
      final results = await _contactRepository.searchContacts(event.query);
      emit(
        state.copyWith(
          filteredContacts: results,
          searchQuery: event.query,
          isSearching: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSearching: false));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<ContactState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(searchResults: [], isGlobalSearching: false));
      return;
    }

    emit(state.copyWith(isGlobalSearching: true));

    try {
      final results = await _contactRepository.searchUsers(
        event.query,
        limit: event.limit,
      );
      emit(state.copyWith(searchResults: results, isGlobalSearching: false));
    } catch (e) {
      emit(state.copyWith(isGlobalSearching: false));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<ContactState> emit) {
    emit(
      state.copyWith(
        filteredContacts: state.contacts,
        searchResults: [],
        searchQuery: '',
        isSearching: false,
        isGlobalSearching: false,
      ),
    );
  }

  Future<void> _onStartChat(StartChat event, Emitter<ContactState> emit) async {
    try {
      final roomId = await _contactRepository.startDirectChat(event.userId);
      emit(
        state.copyWith(
          status: ContactStatus.chatStarted,
          startedChatRoomId: roomId,
          startedChatUserId: event.userId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ContactStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onIgnoreUser(
    IgnoreUser event,
    Emitter<ContactState> emit,
  ) async {
    try {
      await _contactRepository.ignoreUser(event.userId);
      add(const RefreshContacts());
    } catch (e) {
      emit(
        state.copyWith(status: ContactStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUnignoreUser(
    UnignoreUser event,
    Emitter<ContactState> emit,
  ) async {
    try {
      await _contactRepository.unignoreUser(event.userId);
      add(const RefreshContacts());
    } catch (e) {
      emit(
        state.copyWith(status: ContactStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadFriendRequests(
    LoadFriendRequests event,
    Emitter<ContactState> emit,
  ) async {
    try {
      final friendRequests = await _contactRepository
          .getPendingFriendRequests();
      emit(
        state.copyWith(
          status: ContactStatus.loaded,
          friendRequests: friendRequests,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContactStatus.error,
          errorMessage: 'Failed to load friend requests: $e',
        ),
      );
    }
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequest event,
    Emitter<ContactState> emit,
  ) async {
    try {
      await _contactRepository.acceptFriendRequest(event.requestId);
      add(const RefreshContacts());
    } catch (e) {
      emit(
        state.copyWith(status: ContactStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onRejectFriendRequest(
    RejectFriendRequest event,
    Emitter<ContactState> emit,
  ) async {
    try {
      await _contactRepository.rejectFriendRequest(event.requestId);
      add(const RefreshContacts());
    } catch (e) {
      emit(
        state.copyWith(status: ContactStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onContactsUpdated(
    ContactsUpdated event,
    Emitter<ContactState> emit,
  ) async {
    add(const RefreshContacts());
  }

  void _onOnlineStatusUpdated(
    OnlineStatusUpdated event,
    Emitter<ContactState> emit,
  ) {
    final updatedContacts = state.contacts.map((contact) {
      final isOnline = event.statusMap[contact.userId];
      if (isOnline != null) {
        return contact.copyWith(
          presence: isOnline ? PresenceStatus.online : PresenceStatus.offline,
        );
      }
      return contact;
    }).toList();

    emit(
      state.copyWith(
        contacts: updatedContacts,
        filteredContacts: state.searchQuery.isEmpty
            ? updatedContacts
            : state.filteredContacts,
      ),
    );
  }

  Future<void> _onSetContactRemark(
    SetContactRemark event,
    Emitter<ContactState> emit,
  ) async {
    try {
      debugLog(
        'ContactBloc: Setting remark for ${event.userId} to "${event.remark}"',
      );

      // 同时保存到 RemarkService（全局本地缓存）
      await RemarkService.instance.setRemark(event.userId, event.remark);
      debugLog('ContactBloc: Remark saved to RemarkService');

      // 保存到 ContactRepository
      await _contactRepository.setContactRemark(event.userId, event.remark);
      debugLog('ContactBloc: Remark saved to ContactRepository');

      // 发送成功状态
      emit(
        state.copyWith(
          status: ContactStatus.remarkUpdated,
          updatedRemarkUserId: event.userId,
          updatedRemark: event.remark,
        ),
      );
      debugLog('ContactBloc: Emitted remarkUpdated');

      // 刷新联系人列表以更新备注
      add(const RefreshContacts());
      debugLog('ContactBloc: Added RefreshContacts event');
    } catch (e) {
      debugLog('ContactBloc: Error setting remark - $e');
      emit(
        state.copyWith(status: ContactStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleteContact(
    DeleteContact event,
    Emitter<ContactState> emit,
  ) async {
    try {
      debugLog('ContactBloc: Deleting contact ${event.userId}');

      // 删除联系人
      await _contactRepository.deleteContact(event.userId);
      debugLog('ContactBloc: Contact deleted successfully');

      // 同时清除 RemarkService 中的备注
      await RemarkService.instance.setRemark(event.userId, null);

      // 发送删除成功状态
      emit(
        state.copyWith(
          status: ContactStatus.deleted,
          deletedUserId: event.userId,
        ),
      );
      debugLog('ContactBloc: Emitted deleted');

      // 刷新联系人列表
      add(const RefreshContacts());
      debugLog('ContactBloc: Added RefreshContacts event');
    } catch (e) {
      debugLog('ContactBloc: Error deleting contact - $e');
      emit(
        state.copyWith(status: ContactStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// 按首字母分组联系人
  Map<String, List<ContactEntity>> _groupContactsByLetter(
    List<ContactEntity> contacts,
  ) {
    final grouped = <String, List<ContactEntity>>{};

    for (final contact in contacts) {
      final letter = contact.indexLetter;
      if (!grouped.containsKey(letter)) {
        grouped[letter] = [];
      }
      grouped[letter]!.add(contact);
    }

    // 按名称排序每个组内的联系人
    for (final contacts in grouped.values) {
      contacts.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    }

    return grouped;
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    _onlineStatusSubscription?.cancel();
    return super.close();
  }
}

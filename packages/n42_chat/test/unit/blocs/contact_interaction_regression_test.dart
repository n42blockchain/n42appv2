import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/domain/repositories/contact_repository.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_event.dart';

class MockContactRepository extends Mock implements IContactRepository {}

const _contact1 = ContactEntity(userId: '@alice:hs', displayName: 'Alice');
const _contact2 = ContactEntity(userId: '@bob:hs', displayName: 'Bob');
const _contact3 = ContactEntity(userId: '@carol:hs', displayName: 'Carol');
void main() {
  late MockContactRepository mockRepository;
  setUp(() {
    mockRepository = MockContactRepository();
    when(
      () => mockRepository.watchContacts(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockRepository.watchOnlineStatus(),
    ).thenAnswer((_) => const Stream.empty());
  });
  test(
    'starred friends form the first group without duplicate alphabetical rows',
    () async {
      when(() => mockRepository.getContacts()).thenAnswer(
        (_) async => [_contact1, _contact2.copyWith(isStarred: true)],
      );
      when(
        () => mockRepository.getPendingFriendRequests(),
      ).thenAnswer((_) async => []);
      final bloc = ContactBloc(mockRepository);
      final done = Completer<void>();
      bloc.add(RefreshContacts(completion: done));
      await done.future;
      expect(bloc.state.indexLetters.first, '☆');
      expect(bloc.state.groupedContacts['☆']!.single.userId, _contact2.userId);
      expect(bloc.state.groupedContacts.values.expand((c) => c).length, 2);
      await bloc.close();
    },
  );

  test('late contact search cannot replace the newer query', () async {
    final oldResult = Completer<List<ContactEntity>>();
    final started = Completer<void>();
    when(() => mockRepository.searchContacts('Alice')).thenAnswer((_) {
      started.complete();
      return oldResult.future;
    });
    when(
      () => mockRepository.searchContacts('Bob'),
    ).thenAnswer((_) async => [_contact2]);
    final bloc = ContactBloc(mockRepository);
    bloc.add(const SearchContacts('Alice'));
    await started.future;
    final latest = bloc.stream.firstWhere(
      (s) => s.searchQuery == 'Bob' && !s.isSearching,
    );
    bloc.add(const SearchContacts('Bob'));
    await latest;
    oldResult.complete([_contact1]);
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.searchQuery, 'Bob');
    expect(bloc.state.filteredContacts, [_contact2]);
    await bloc.close();
  });

  test(
    'clearing search invalidates outstanding local and global responses',
    () async {
      final local = Completer<List<ContactEntity>>();
      final global = Completer<List<ContactEntity>>();
      when(
        () => mockRepository.searchContacts('Alice'),
      ).thenAnswer((_) => local.future);
      when(
        () => mockRepository.searchUsers('Alice', limit: 20),
      ).thenAnswer((_) => global.future);
      final bloc = ContactBloc(mockRepository);
      bloc.add(const SearchContacts('Alice'));
      await bloc.stream.firstWhere((s) => s.isSearching);
      bloc.add(const SearchUsers('Alice'));
      await bloc.stream.firstWhere((s) => s.isGlobalSearching);
      bloc.add(const ClearSearch());
      await bloc.stream.firstWhere((s) => s.searchQuery.isEmpty);
      local.complete([_contact1]);
      global.complete([_contact3]);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.searchQuery, isEmpty);
      expect(bloc.state.filteredContacts, isEmpty);
      expect(bloc.state.searchResults, isEmpty);
      expect(bloc.state.isSearching, isFalse);
      expect(bloc.state.isGlobalSearching, isFalse);
      await bloc.close();
    },
  );

  test('failed search exposes retry state and retry clears it', () async {
    when(
      () => mockRepository.searchContacts('Alice'),
    ).thenThrow(StateError('offline'));
    final bloc = ContactBloc(mockRepository);
    bloc.add(const SearchContacts('Alice'));
    await bloc.stream.firstWhere((s) => s.searchFailed);
    when(
      () => mockRepository.searchContacts('Alice'),
    ).thenAnswer((_) async => [_contact1]);
    bloc.add(const SearchContacts('Alice'));
    await bloc.stream.firstWhere((s) => !s.isSearching && !s.searchFailed);
    expect(bloc.state.filteredContacts, [_contact1]);
    await bloc.close();
  });

  test('refresh completion waits for contact hydration', () async {
    final result = Completer<List<ContactEntity>>();
    final started = Completer<void>();
    when(() => mockRepository.getContacts()).thenAnswer((_) {
      started.complete();
      return result.future;
    });
    when(
      () => mockRepository.getPendingFriendRequests(),
    ).thenAnswer((_) async => []);
    final bloc = ContactBloc(mockRepository);
    final completion = Completer<void>();
    bloc.add(RefreshContacts(completion: completion));
    await started.future;
    expect(completion.isCompleted, isFalse);
    result.complete([_contact1]);
    await completion.future;
    expect(bloc.state.contacts, [_contact1]);
    await bloc.close();
  });
}

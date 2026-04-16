import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_search_datasource.dart';

class _MockMatrixClientManager extends Mock implements MatrixClientManager {}

class _MockClient extends Mock implements matrix.Client {}

class _MockRoom extends Mock implements matrix.Room {}

void main() {
  late _MockMatrixClientManager mockClientManager;
  late _MockClient mockClient;
  late MatrixSearchDataSource dataSource;

  setUp(() {
    mockClientManager = _MockMatrixClientManager();
    mockClient = _MockClient();

    when(() => mockClientManager.client).thenReturn(mockClient);
    dataSource = MatrixSearchDataSource(mockClientManager);
  });

  test('searchLocalConversations only returns joined direct chats', () {
    final directRoom = _MockRoom();
    final groupRoom = _MockRoom();
    final invitedDirectRoom = _MockRoom();

    when(() => directRoom.membership).thenReturn(matrix.Membership.join);
    when(() => directRoom.isDirectChat).thenReturn(true);
    when(() => directRoom.getLocalizedDisplayname()).thenReturn('Alice');
    when(() => directRoom.topic).thenReturn('1:1 chat');
    when(() => directRoom.lastEvent).thenReturn(null);

    when(() => groupRoom.membership).thenReturn(matrix.Membership.join);
    when(() => groupRoom.isDirectChat).thenReturn(false);
    when(() => groupRoom.getLocalizedDisplayname()).thenReturn('Dev Group');
    when(() => groupRoom.topic).thenReturn('Engineering');
    when(() => groupRoom.lastEvent).thenReturn(null);

    when(
      () => invitedDirectRoom.membership,
    ).thenReturn(matrix.Membership.invite);
    when(() => invitedDirectRoom.isDirectChat).thenReturn(true);
    when(() => invitedDirectRoom.getLocalizedDisplayname()).thenReturn('Bob');
    when(() => invitedDirectRoom.topic).thenReturn('Pending');
    when(() => invitedDirectRoom.lastEvent).thenReturn(null);

    when(
      () => mockClient.rooms,
    ).thenReturn([directRoom, groupRoom, invitedDirectRoom]);

    final directResults = dataSource.searchLocalConversations('Alice');
    final groupResults = dataSource.searchLocalConversations('Dev');

    expect(directResults, [directRoom]);
    expect(groupResults, isEmpty);
  });
}

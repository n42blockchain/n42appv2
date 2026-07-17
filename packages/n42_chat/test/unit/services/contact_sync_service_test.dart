import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/contact_sync_service.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_contacts');
  final calls = <MethodCall>[];
  var permissionStatus = PermissionStatus.granted.name;

  setUp(() {
    calls.clear();
    permissionStatus = PermissionStatus.granted.name;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'permissions.request') {
            return permissionStatus;
          }
          if (call.method == 'crud.getAll') {
            return [
              Contact(
                id: 'contact-1',
                displayName: 'Ada Lovelace',
                name: const Name(first: 'Ada', last: 'Lovelace'),
                phones: const [Phone(number: '+1 555 0100')],
                emails: const [Email(address: 'ada@example.com')],
                photo: Photo(fullSize: Uint8List.fromList([1, 2, 3])),
              ).toJson(),
            ];
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('maps granted device contacts including requested photo', () async {
    final service = ContactSyncService(MatrixClientManager.instance);

    final contacts = await service.getPhoneContacts(withPhoto: true);

    expect(contacts, hasLength(1));
    expect(contacts.single.id, 'contact-1');
    expect(contacts.single.displayName, 'Ada Lovelace');
    expect(contacts.single.firstName, 'Ada');
    expect(contacts.single.lastName, 'Lovelace');
    expect(contacts.single.phones, ['+1 555 0100']);
    expect(contacts.single.emails, ['ada@example.com']);
    expect(contacts.single.photoBytes, [1, 2, 3]);

    final request = calls.firstWhere((call) => call.method == 'crud.getAll');
    final properties = (request.arguments as Map)['properties'] as List;
    expect(properties, containsAll(['name', 'phone', 'email', 'photoFullRes']));
  });

  test('does not read contacts when permission is denied', () async {
    permissionStatus = PermissionStatus.denied.name;
    final service = ContactSyncService(MatrixClientManager.instance);

    expect(await service.getPhoneContacts(), isEmpty);
    expect(calls.where((call) => call.method == 'crud.getAll'), isEmpty);
  });
}

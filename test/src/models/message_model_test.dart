// Tests for MessageModel (RPC call result/error wrapper).
// Minimal pure Dart class — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/models/message_model.dart';

void main() {
  group('MessageModel default constructor', () {
    test('error defaults to false', () {
      final model = MessageModel();
      expect(model.error, isFalse);
    });

    test('data defaults to null', () {
      final model = MessageModel();
      expect(model.data, isNull);
    });

    test('can assign data after construction', () {
      final model = MessageModel();
      model.data = {'key': 'value'};
      expect(model.data, {'key': 'value'});
    });

    test('data can hold any type', () {
      final model = MessageModel();
      model.data = 42;
      expect(model.data, 42);
    });
  });

  group('MessageModel.error() factory', () {
    test('error is true', () {
      final model = MessageModel.error();
      expect(model.error, isTrue);
    });

    test('data is null', () {
      final model = MessageModel.error();
      expect(model.data, isNull);
    });
  });

  group('MessageModel field mutation', () {
    test('error flag can be changed after construction', () {
      final model = MessageModel();
      expect(model.error, isFalse);
      model.error = true;
      expect(model.error, isTrue);
    });
  });
}

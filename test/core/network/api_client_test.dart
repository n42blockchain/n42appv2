import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:n42_wallet/core/network/api_client.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([SecureStorage, Dio])
void main() {
  late ApiClient apiClient;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorage();

    // 设置默认返回值
    when(mockSecureStorage.getToken()).thenAnswer((_) async => 'test_token');
    when(mockSecureStorage.getUuid()).thenAnswer((_) async => 'test_uuid');

    apiClient = ApiClient(mockSecureStorage);
  });

  group('ApiClient', () {
    test('should be created successfully', () {
      expect(apiClient, isNotNull);
      expect(apiClient.dio, isNotNull);
    });

    test('should have correct base options', () {
      expect(apiClient.dio.options.connectTimeout, const Duration(seconds: 30));
      expect(apiClient.dio.options.receiveTimeout, const Duration(seconds: 30));
      expect(apiClient.dio.options.sendTimeout, const Duration(seconds: 30));
    });

    test('should have interceptors configured', () {
      // ApiClient 自己注册了两个业务拦截器；Dio 可能额外注入内部拦截器。
      expect(apiClient.dio.interceptors.length, greaterThanOrEqualTo(2));
    });
  });

  group('HTTP Methods', () {
    // 这些测试需要 mock Dio 实例
    // 在实际项目中，应该使用 nock 或 MockWebServer 进行集成测试

    test('get method should exist', () {
      expect(apiClient.get, isNotNull);
    });

    test('post method should exist', () {
      expect(apiClient.post, isNotNull);
    });

    test('put method should exist', () {
      expect(apiClient.put, isNotNull);
    });

    test('delete method should exist', () {
      expect(apiClient.delete, isNotNull);
    });

    test('patch method should exist', () {
      expect(apiClient.patch, isNotNull);
    });
  });

  group('Retry policy', () {
    test('should retry idempotent methods only', () {
      expect(
        ApiClient.shouldRetryRequest(
          RequestOptions(path: '/health', method: 'GET'),
        ),
        isTrue,
      );
      expect(
        ApiClient.shouldRetryRequest(
          RequestOptions(path: '/user', method: 'HEAD'),
        ),
        isTrue,
      );
      expect(
        ApiClient.shouldRetryRequest(
          RequestOptions(path: '/login', method: 'POST'),
        ),
        isFalse,
      );
      expect(
        ApiClient.shouldRetryRequest(
          RequestOptions(path: '/wallet', method: 'PATCH'),
        ),
        isFalse,
      );
    });
  });
}

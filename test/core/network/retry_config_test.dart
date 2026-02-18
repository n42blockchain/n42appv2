import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/core/network/retry_config.dart';
import 'package:n42appv2/core/network/retry_interceptor.dart';

void main() {
  group('RetryConfig presets', () {
    test('defaultPolicy has correct values', () {
      const policy = RetryConfig.defaultPolicy;
      expect(policy.maxRetries, 3);
      expect(policy.baseDelay, const Duration(milliseconds: 500));
      expect(policy.retryableMethods, {'GET'});
    });

    test('aggressiveRead has more retries and shorter delay', () {
      const policy = RetryConfig.aggressiveRead;
      expect(policy.maxRetries, 5);
      expect(policy.baseDelay, const Duration(milliseconds: 300));
      expect(policy.retryableMethods, {'GET'});
    });

    test('conservative has fewer retries and longer delay', () {
      const policy = RetryConfig.conservative;
      expect(policy.maxRetries, 2);
      expect(policy.baseDelay, const Duration(seconds: 2));
      expect(policy.retryableMethods, {'GET'});
    });
  });

  group('Options extensions', () {
    test('noRetry sets kRetryEnabled to false', () {
      final options = Options(method: 'GET').noRetry();
      expect(options.extra?[RetryOptions.kRetryEnabled], isFalse);
    });

    test('withRetry sets kRetryEnabled to true', () {
      final options = Options(method: 'POST').withRetry();
      expect(options.extra?[RetryOptions.kRetryEnabled], isTrue);
    });

    test('withRetry preserves maxRetries when provided', () {
      final options = Options(method: 'POST').withRetry(maxRetries: 5);
      expect(options.extra?[RetryOptions.kRetryEnabled], isTrue);
      expect(options.extra?[RetryOptions.kMaxRetries], 5);
    });

    test('withRetry does not set maxRetries when not provided', () {
      final options = Options(method: 'POST').withRetry();
      expect(options.extra?.containsKey(RetryOptions.kMaxRetries), isFalse);
    });
  });
}

// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Failure types for categorizing errors
sealed class Failure {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure(this.message, {this.code, this.originalError});

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.originalError});
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'Operation timed out'])
      : super(message);
}

/// Authentication/Authorization failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.originalError});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.originalError});
}

/// Unexpected/Unknown failures
class UnexpectedFailure extends Failure {
  final StackTrace? stackTrace;

  const UnexpectedFailure(super.message, {this.stackTrace, super.originalError});
}

/// Either type for functional error handling
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get leftOrNull => this is Left<L, R> ? (this as Left<L, R>).value : null;
  R? get rightOrNull => this is Right<L, R> ? (this as Right<L, R>).value : null;

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    if (this is Left<L, R>) {
      return onLeft((this as Left<L, R>).value);
    }
    return onRight((this as Right<L, R>).value);
  }

  Either<L, T> map<T>(T Function(R) transform) {
    if (this is Left<L, R>) {
      return Left((this as Left<L, R>).value);
    }
    return Right(transform((this as Right<L, R>).value));
  }

  Future<Either<L, T>> asyncMap<T>(Future<T> Function(R) transform) async {
    if (this is Left<L, R>) {
      return Left((this as Left<L, R>).value);
    }
    final result = await transform((this as Right<L, R>).value);
    return Right(result);
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Left && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Right && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Safe async call wrapper with automatic error categorization
///
/// Executes [action] and wraps the result in [Either].
/// On success, returns [Right] with the result.
/// On failure, returns [Left] with an appropriate [Failure] type.
///
/// Example:
/// ```dart
/// final result = await safeCall(
///   () => api.fetchUser(id),
///   context: 'fetchUser',
/// );
///
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => displayUser(user),
/// );
/// ```
Future<Either<Failure, T>> safeCall<T>(
  Future<T> Function() action, {
  String? context,
}) async {
  try {
    final result = await action();
    return Right(result);
  } on SocketException catch (e) {
    _logError('Network error', context, e);
    return Left(NetworkFailure(
      'Network connection failed',
      originalError: e,
    ));
  } on HttpException catch (e) {
    _logError('HTTP error', context, e);
    return Left(NetworkFailure(
      e.message,
      originalError: e,
    ));
  } on TimeoutException catch (e) {
    _logError('Timeout', context, e);
    return Left(TimeoutFailure(e.message ?? 'Operation timed out'));
  } on FormatException catch (e) {
    _logError('Format error', context, e);
    return Left(ValidationFailure(
      'Invalid data format: ${e.message}',
      originalError: e,
    ));
  } catch (e, stack) {
    _logError('Unexpected error', context, e, stack);
    return Left(UnexpectedFailure(
      e.toString(),
      stackTrace: stack,
      originalError: e,
    ));
  }
}

/// Safe sync call wrapper
Either<Failure, T> safeSyncCall<T>(
  T Function() action, {
  String? context,
}) {
  try {
    final result = action();
    return Right(result);
  } on FormatException catch (e) {
    _logError('Format error', context, e);
    return Left(ValidationFailure(
      'Invalid data format: ${e.message}',
      originalError: e,
    ));
  } catch (e, stack) {
    _logError('Unexpected error', context, e, stack);
    return Left(UnexpectedFailure(
      e.toString(),
      stackTrace: stack,
      originalError: e,
    ));
  }
}

void _logError(String type, String? context, dynamic error, [StackTrace? stack]) {
  if (kDebugMode) {
    final ctx = context != null ? ' in $context' : '';
    debugPrint('[$type$ctx] $error');
    if (stack != null) {
      debugPrint('$stack');
    }
  }
}

/// Extension to convert Either to Future for async chains
extension EitherFutureExtension<L, R> on Either<L, R> {
  Future<Either<L, R>> toFuture() => Future.value(this);
}

/// Extension to handle nullable results
extension NullableResultExtension<T> on T? {
  Either<Failure, T> toEither(String errorMessage) {
    if (this == null) {
      return Left(ValidationFailure(errorMessage));
    }
    return Right(this as T);
  }
}

// Copyright 2021-2026 N42 Inc. All rights reserved.

/// A type that represents either a success value or an error
///
/// This is a functional approach to error handling that avoids exceptions
/// and makes error states explicit in the type system.
///
/// Usage:
/// ```dart
/// Future<Result<User, AppError>> getUser(String id) async {
///   try {
///     final user = await api.fetchUser(id);
///     return Result.success(user);
///   } catch (e) {
///     return Result.failure(AppError.network('Failed to fetch user'));
///   }
/// }
///
/// // Using the result
/// final result = await getUser('123');
/// result.when(
///   success: (user) => print('Got user: ${user.name}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
sealed class Result<T, E> {
  const Result._();

  /// Creates a success result with the given value
  const factory Result.success(T value) = Success<T, E>;

  /// Creates a failure result with the given error
  const factory Result.failure(E error) = Failure<T, E>;

  /// Returns true if this is a success result
  bool get isSuccess => this is Success<T, E>;

  /// Returns true if this is a failure result
  bool get isFailure => this is Failure<T, E>;

  /// Returns the success value or null if this is a failure
  T? get valueOrNull => switch (this) {
    Success(value: final v) => v,
    Failure() => null,
  };

  /// Returns the error or null if this is a success
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final e) => e,
  };

  /// Returns the value if success, or the result of [orElse] if failure
  T getOrElse(T Function(E error) orElse) {
    return switch (this) {
      Success(value: final v) => v,
      Failure(error: final e) => orElse(e),
    };
  }

  /// Returns the value if success, or throws the error if failure
  T getOrThrow() {
    return switch (this) {
      Success(value: final v) => v,
      Failure(error: final e) => throw e as Object,
    };
  }

  /// Pattern matching for Result
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) {
    return switch (this) {
      Success(value: final v) => success(v),
      Failure(error: final e) => failure(e),
    };
  }

  /// Transform the success value
  Result<R, E> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => Result.success(transform(v)),
      Failure(error: final e) => Result.failure(e),
    };
  }

  /// Transform the error
  Result<T, R> mapError<R>(R Function(E error) transform) {
    return switch (this) {
      Success(value: final v) => Result.success(v),
      Failure(error: final e) => Result.failure(transform(e)),
    };
  }

  /// Chain another Result-returning operation
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => transform(v),
      Failure(error: final e) => Result.failure(e),
    };
  }
}

/// Success case of Result
final class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failure case of Result
final class Failure<T, E> extends Result<T, E> {
  final E error;

  const Failure(this.error) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> && error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Application-wide error types
///
/// Provides structured error handling with categorization
sealed class AppError {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError._({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  /// Network-related errors (connectivity, timeout, server errors)
  factory AppError.network(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) = NetworkError;

  /// Authentication/authorization errors
  factory AppError.auth(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) = AuthError;

  /// Validation errors (invalid input, format errors)
  factory AppError.validation(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) = ValidationError;

  /// Business logic errors
  factory AppError.business(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) = BusinessError;

  /// Storage/database errors
  factory AppError.storage(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) = StorageError;

  /// Blockchain/wallet errors
  factory AppError.blockchain(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) = BlockchainError;

  /// Unknown/unexpected errors
  factory AppError.unknown(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) = UnknownError;

  /// Create from exception
  factory AppError.fromException(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }
    return AppError.unknown(
      error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

final class NetworkError extends AppError {
  const NetworkError(
    String message, {
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super._(message: message);
}

final class AuthError extends AppError {
  const AuthError(
    String message, {
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super._(message: message);
}

final class ValidationError extends AppError {
  const ValidationError(
    String message, {
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super._(message: message);
}

final class BusinessError extends AppError {
  const BusinessError(
    String message, {
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super._(message: message);
}

final class StorageError extends AppError {
  const StorageError(
    String message, {
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super._(message: message);
}

final class BlockchainError extends AppError {
  const BlockchainError(
    String message, {
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super._(message: message);
}

final class UnknownError extends AppError {
  const UnknownError(
    String message, {
    super.code,
    super.originalError,
    super.stackTrace,
  }) : super._(message: message);
}

/// Extension methods for easier Result handling
extension ResultExtensions<T, E> on Result<T, E> {
  /// Execute side effect on success
  Result<T, E> onSuccess(void Function(T value) action) {
    if (this case Success(value: final v)) action(v);
    return this;
  }

  /// Execute side effect on failure
  Result<T, E> onFailure(void Function(E error) action) {
    if (this case Failure(error: final e)) action(e);
    return this;
  }
}

/// Extension for converting Future to Result
extension FutureResultExtension<T> on Future<T> {
  /// Convert a Future to a Result, catching any exceptions
  Future<Result<T, AppError>> toResult() async {
    try {
      final value = await this;
      return Result.success(value);
    } catch (e, st) {
      return Result.failure(AppError.fromException(e, st));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

// **Status: Clean-Arch base class, partially adopted.** The only current
// consumer is `features/mining/domain/usecases/start_mining.dart`, whose
// five use cases are themselves not yet wired into production. Kept as the
// canonical base so any future use-case-based business surface (auth,
// wallet, transfer) has a consistent contract to extend.
//
// See the dartdoc on `start_mining.dart` for the mining-side status.

/// UseCase 基类
///
/// 所有业务用例都应该继承此类
///
/// [T] 返回值类型
/// [Params] 参数类型
///
/// 使用示例：
/// ```dart
/// class GetUserProfile implements UseCase<User, GetUserProfileParams> {
///   final UserRepository repository;
///
///   GetUserProfile(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call(GetUserProfileParams params) {
///     return repository.getUserProfile(params.userId);
///   }
/// }
/// ```
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// 无参数用例
///
/// 当用例不需要参数时使用
///
/// 使用示例：
/// ```dart
/// class GetCurrentUser implements UseCaseNoParams<User> {
///   final AuthRepository repository;
///
///   GetCurrentUser(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call() {
///     return repository.getCurrentUser();
///   }
/// }
/// ```
abstract class UseCaseNoParams<T> {
  Future<Either<Failure, T>> call();
}

/// 流用例
///
/// 返回 Stream 的用例，用于实时数据
///
/// 使用示例：
/// ```dart
/// class WatchWalletBalance implements StreamUseCase<Balance, WatchBalanceParams> {
///   final WalletRepository repository;
///
///   WatchWalletBalance(this.repository);
///
///   @override
///   Stream<Either<Failure, Balance>> call(WatchBalanceParams params) {
///     return repository.watchBalance(params.address);
///   }
/// }
/// ```
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// 无参数流用例
abstract class StreamUseCaseNoParams<T> {
  Stream<Either<Failure, T>> call();
}

/// 同步用例
///
/// 用于不需要异步操作的用例
abstract class SyncUseCase<T, Params> {
  Either<Failure, T> call(Params params);
}

/// 空参数
///
/// 当用例需要符合 `UseCase<Type, Params>` 接口但不需要参数时使用
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// 分页参数
class PaginationParams extends Equatable {
  final int page;
  final int pageSize;

  const PaginationParams({this.page = 1, this.pageSize = 20});

  @override
  List<Object?> get props => [page, pageSize];

  /// 计算偏移量
  int get offset => (page - 1) * pageSize;

  /// 复制并修改
  PaginationParams copyWith({int? page, int? pageSize}) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// 下一页
  PaginationParams get nextPage => copyWith(page: page + 1);

  /// 上一页
  PaginationParams get previousPage => copyWith(page: page > 1 ? page - 1 : 1);
}

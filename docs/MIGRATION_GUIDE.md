# N42Wallet 迁移指南

本文档详细说明如何从现有代码逐步迁移到新架构。

---

## 目录

1. [准备工作](#1-准备工作)
2. [依赖更新](#2-依赖更新)
3. [模块迁移步骤](#3-模块迁移步骤)
4. [代码示例](#4-代码示例)
5. [常见问题](#5-常见问题)

---

## 1. 准备工作

### 1.1 创建迁移分支

```bash
git checkout -b refactor/enterprise-architecture
```

### 1.2 备份关键文件

```bash
cp pubspec.yaml pubspec.yaml.backup
cp analysis_options.yaml analysis_options.yaml.backup
```

### 1.3 验证现有测试

```bash
flutter test
```

---

## 2. 依赖更新

### 2.1 添加新依赖

在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  # 依赖注入
  get_it: ^8.0.3
  injectable: ^2.5.0
  
  # 安全存储
  flutter_secure_storage: ^9.2.4
  
  # 路由
  go_router: ^14.6.2
  
  # 函数式编程
  dartz: ^0.10.1
  freezed_annotation: ^2.4.4
  equatable: ^2.0.7
  
  # 状态管理增强 (可选)
  flutter_bloc: ^8.1.6

dev_dependencies:
  injectable_generator: ^2.6.3
  freezed: ^2.5.7
  go_router_builder: ^2.7.1
  build_runner: ^2.4.13
  mockito: ^5.4.4
  mocktail: ^1.0.4
  very_good_analysis: ^6.0.0
```

### 2.2 运行依赖安装

```bash
flutter pub get
```

### 2.3 生成代码

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 3. 模块迁移步骤

### Phase 1: 基础设施（1-2 周）

#### Step 1: 复制新的 Core 层

新的 Core 层文件已创建在 `lib/core/` 目录下，包括：

- `lib/core/di/` - 依赖注入
- `lib/core/error/` - 错误处理
- `lib/core/network/` - 网络层
- `lib/core/security/` - 安全模块
- `lib/core/config/` - 配置
- `lib/core/platform/` - 平台服务
- `lib/core/usecase/` - UseCase 基类

#### Step 2: 初始化依赖注入

修改 `main.dart`：

```dart
import 'package:n42appv2/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化依赖注入
  await configureDependencies(
    kReleaseMode ? Env.prod : Env.dev,
  );
  
  // ... 其余初始化代码
}
```

#### Step 3: 迁移配置

将 `AppConfig` 的使用逐步迁移到新的 `lib/core/config/app_config.dart`：

```dart
// 旧代码
import 'package:n42appv2/app_config.dart';
final url = AppConfig.apiUrl['marketHost']['main'];

// 新代码
import 'package:n42appv2/core/config/app_config.dart';
final url = AppConfig.marketApiUrl;
```

### Phase 2: 数据层迁移（1-2 周）

#### Step 1: 创建 Domain 层实体

将现有 Model 转换为 Domain Entity：

```dart
// 旧代码: lib/src/models/user_info.dart
class UserInfo {
  String? email;
  String? token;
  // ...
}

// 新代码: lib/domain/entities/user.dart
class User extends Equatable {
  final String uuid;
  final String email;
  // ...
}
```

#### Step 2: 创建 Repository 接口

```dart
// lib/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
}
```

#### Step 3: 实现 Repository

```dart
// lib/data/repositories/auth_repository_impl.dart
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remote.login(email, password);
      await _local.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
```

### Phase 3: 表现层迁移（2 周）

#### Step 1: 迁移 Provider 到新架构

```dart
// 旧代码
class PublicProvider extends ChangeNotifier {
  UserInfo? _userInfo;
  
  Future<void> login(String email, String password) async {
    // 直接调用 API
    final api = LoginApi();
    final result = await api.login(email, password);
    // ...
  }
}

// 新代码 (使用 Bloc)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  
  AuthBloc(this._loginUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
```

#### Step 2: 迁移路由到 go_router

```dart
// 旧代码
Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));

// 新代码
context.go('/home');
// 或
HomeRoute().go(context);
```

---

## 4. 代码示例

### 4.1 完整的 UseCase 示例

```dart
// lib/domain/usecases/auth/login.dart
@injectable
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository _repository;
  
  LoginUseCase(this._repository);
  
  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  
  const LoginParams({required this.email, required this.password});
  
  @override
  List<Object?> get props => [email, password];
}
```

### 4.2 完整的 DataSource 示例

```dart
// lib/data/datasources/remote/auth_remote_datasource.dart
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password);
  Future<void> logout();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;
  
  AuthRemoteDataSourceImpl(this._client);
  
  @override
  Future<UserModel> login(String email, String password) async {
    final response = await _client.post(
      '${AppConfig.userApiUrl}/login',
      data: {'email': email, 'password': password},
    );
    
    if (response.data['code'] == 200) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw ServerException(message: response.data['message']);
    }
  }
}
```

### 4.3 Model 与 Entity 转换

```dart
// lib/data/models/user_model.dart
class UserModel {
  final String uuid;
  final String email;
  final String? name;
  final String? token;
  
  UserModel({
    required this.uuid,
    required this.email,
    this.name,
    this.token,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uuid: json['uuid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      token: json['token'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'email': email,
    'name': name,
    'token': token,
  };
  
  User toEntity() => User(
    uuid: uuid,
    email: email,
    name: name,
  );
  
  static UserModel fromEntity(User user) => UserModel(
    uuid: user.uuid,
    email: user.email,
    name: user.name,
  );
}
```

---

## 5. 常见问题

### Q1: 如何处理现有的 Provider？

**A:** 可以同时使用旧的 Provider 和新的 Bloc/Cubit。通过 Feature Flag 控制：

```dart
if (FeatureFlags.useNewArchitecture) {
  return BlocProvider(
    create: (_) => getIt<AuthBloc>(),
    child: child,
  );
} else {
  return ChangeNotifierProvider(
    create: (_) => PublicProvider(),
    child: child,
  );
}
```

### Q2: 如何保持向后兼容？

**A:** 
1. 保留现有的 `Application` 类，但标记为 `@Deprecated`
2. 创建新的服务类，内部委托给旧实现
3. 逐步迁移调用点

### Q3: 测试如何编写？

**A:** 使用依赖注入可以轻松 mock：

```dart
void main() {
  late MockAuthRepository mockRepo;
  late LoginUseCase useCase;
  
  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LoginUseCase(mockRepo);
  });
  
  test('should return User on successful login', () async {
    when(mockRepo.login(email: any, password: any))
        .thenAnswer((_) async => Right(testUser));
    
    final result = await useCase(testParams);
    
    expect(result.isRight(), true);
  });
}
```

### Q4: 迁移期间如何保证稳定性？

**A:**
1. 每个迁移步骤都创建独立的 PR
2. 保持测试覆盖率
3. 使用 Feature Flag 灰度发布
4. 保持回滚能力

---

## 回滚指南

如果需要回滚到旧版本：

```bash
# 1. 切换到备份分支
git checkout main

# 2. 如果已合并，revert PR
git revert <commit-hash>

# 3. 禁用 Feature Flag
flutter run --dart-define=USE_NEW_ARCHITECTURE=false
```

---

*最后更新: 2024-12-29*


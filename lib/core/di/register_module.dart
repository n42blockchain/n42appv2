import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 第三方依赖注册模块
/// 
/// 用于注册无法直接使用 @injectable 注解的第三方库
@module
abstract class RegisterModule {
  /// 注册 SharedPreferences
  /// 
  /// 使用 @preResolve 确保在应用启动前完成初始化
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// 注册 Dio HTTP 客户端
  /// 
  /// 基础配置，具体拦截器由 ApiClient 添加
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
}


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// 网络状态信息接口
abstract class NetworkInfo {
  /// 检查是否有网络连接
  Future<bool> get isConnected;
  
  /// 获取当前连接类型
  Future<List<ConnectivityResult>> get connectionType;
  
  /// 监听网络状态变化
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

/// 网络状态信息实现
@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl() : _connectivity = Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<List<ConnectivityResult>> get connectionType async {
    return _connectivity.checkConnectivity();
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}

/// 网络状态扩展
extension ConnectivityResultExtension on List<ConnectivityResult> {
  /// 是否是 WiFi 连接
  bool get isWifi => contains(ConnectivityResult.wifi);
  
  /// 是否是移动数据连接
  bool get isMobile => contains(ConnectivityResult.mobile);
  
  /// 是否有网络连接
  bool get hasConnection => !contains(ConnectivityResult.none);
  
  /// 获取网络类型描述
  String get description {
    if (contains(ConnectivityResult.wifi)) return 'WiFi';
    if (contains(ConnectivityResult.mobile)) return '移动数据';
    if (contains(ConnectivityResult.ethernet)) return '以太网';
    if (contains(ConnectivityResult.vpn)) return 'VPN';
    return '无网络';
  }
}


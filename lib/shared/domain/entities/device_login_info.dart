/// 设备登录通知数据模型
///
/// 当另一台设备登录同一账号时，通过 FCM 推送接收
class DeviceLoginInfo {
  final String deviceId;
  final String deviceBrand;
  final String deviceModel;
  final String deviceOs;
  final String? loginTime;
  final String? loginIp;
  final String? loginLocation;

  const DeviceLoginInfo({
    required this.deviceId,
    required this.deviceBrand,
    required this.deviceModel,
    required this.deviceOs,
    this.loginTime,
    this.loginIp,
    this.loginLocation,
  });

  factory DeviceLoginInfo.fromJson(Map<String, dynamic> json) {
    return DeviceLoginInfo(
      deviceId: json['device_id'] ?? '',
      deviceBrand: json['device_brand'] ?? '',
      deviceModel: json['device_model'] ?? '',
      deviceOs: json['device_os'] ?? '',
      loginTime: json['login_time'],
      loginIp: json['login_ip'],
      loginLocation: json['login_location'],
    );
  }

  /// 设备显示名称，例如 "Apple iOS" 或 "samsung android"
  String get displayName {
    final brand = deviceBrand.isNotEmpty ? deviceBrand : 'Unknown';
    final os = deviceOs.isNotEmpty ? deviceOs : '';
    return os.isNotEmpty ? '$brand $os' : brand;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/shared/domain/entities/device_login_info.dart';

void main() {
  group('DeviceLoginInfo', () {
    test('fromJson：完整字段解析', () {
      final info = DeviceLoginInfo.fromJson({
        'device_id': 'dev-1',
        'device_brand': 'Apple',
        'device_model': 'iPhone 15',
        'device_os': 'iOS',
        'login_time': '2026-08-05 10:00:00',
        'login_ip': '1.2.3.4',
        'login_location': 'Shanghai',
      });
      expect(info.deviceId, 'dev-1');
      expect(info.deviceBrand, 'Apple');
      expect(info.deviceModel, 'iPhone 15');
      expect(info.deviceOs, 'iOS');
      expect(info.loginTime, '2026-08-05 10:00:00');
      expect(info.loginIp, '1.2.3.4');
      expect(info.loginLocation, 'Shanghai');
    });

    test('fromJson：缺失字段回退空串/null，不抛异常', () {
      final info = DeviceLoginInfo.fromJson(const {});
      expect(info.deviceId, '');
      expect(info.deviceBrand, '');
      expect(info.deviceModel, '');
      expect(info.deviceOs, '');
      expect(info.loginTime, isNull);
      expect(info.loginIp, isNull);
      expect(info.loginLocation, isNull);
    });

    test('displayName：品牌+系统组合与回退', () {
      const full = DeviceLoginInfo(
        deviceId: '1',
        deviceBrand: 'Apple',
        deviceModel: 'x',
        deviceOs: 'iOS',
      );
      const brandOnly = DeviceLoginInfo(
        deviceId: '1',
        deviceBrand: 'samsung',
        deviceModel: 'x',
        deviceOs: '',
      );
      const empty = DeviceLoginInfo(
        deviceId: '1',
        deviceBrand: '',
        deviceModel: 'x',
        deviceOs: '',
      );
      expect(full.displayName, 'Apple iOS');
      expect(brandOnly.displayName, 'samsung');
      expect(empty.displayName, 'Unknown');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/mini_app_entity.dart';
import 'package:n42_chat/src/presentation/helpers/mini_app_launcher_helper.dart';

void main() {
  group('MiniAppLauncherHelper', () {
    test('finds built-in shop and creator mini apps by id', () {
      final shop = MiniAppLauncherHelper.findBuiltInAppById(
        MiniAppLauncherHelper.shopAppId,
      );
      final creatorPass = MiniAppLauncherHelper.findBuiltInAppById(
        MiniAppLauncherHelper.creatorPassAppId,
      );

      expect(shop, isNotNull);
      expect(shop!.category, MiniAppCategory.commerce);
      expect(creatorPass, isNotNull);
      expect(creatorPass!.category, MiniAppCategory.commerce);
    });

    test('returns commerce quick launch apps in stable order', () {
      final apps = MiniAppLauncherHelper.commerceQuickLaunchApps();

      expect(apps.map((app) => app.id).toList(), [
        MiniAppLauncherHelper.shopAppId,
        MiniAppLauncherHelper.creatorPassAppId,
      ]);
    });
  });
}

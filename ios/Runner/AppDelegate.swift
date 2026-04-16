import Flutter
import ActivityKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private func normalizeConfigValue(_ value: Any?) -> String? {
    guard let stringValue = value as? String else { return nil }
    let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty || trimmed == "null" { return nil }
    if trimmed.hasPrefix("$(") && trimmed.hasSuffix(")") { return nil }
    return trimmed
  }

  private func googleServiceValue(_ key: String) -> String? {
    guard
      let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
      let data = NSDictionary(contentsOfFile: path)
    else {
      return nil
    }
    return normalizeConfigValue(data[key])
  }

  private func socialAuthConfig() -> [String: Any?] {
    let info = Bundle.main.infoDictionary ?? [:]
    return [
      "googleClientId": normalizeConfigValue(info["N42ChatGoogleClientID"]) ?? googleServiceValue("CLIENT_ID"),
      "googleServerClientId": normalizeConfigValue(info["N42ChatGoogleServerClientID"]),
      "twitterApiKey": normalizeConfigValue(info["N42ChatTwitterApiKey"]),
      "twitterApiSecret": normalizeConfigValue(info["N42ChatTwitterApiSecret"]),
      "twitterRedirectUri": normalizeConfigValue(info["N42ChatTwitterRedirectUri"]) ?? "n42://auth/twitter",
      "weChatAppId": normalizeConfigValue(info["N42ChatWeChatAppID"]),
      "weChatUniversalLink": normalizeConfigValue(info["N42ChatWeChatUniversalLink"]),
    ]
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      /*FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(withRegistry: registry)
      }*/

      /// ios notification添加 — FlutterAppDelegate 已遵循 UNUserNotificationCenterDelegate
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }
      GeneratedPluginRegistrant.register(with: self)
      // Mining WebSocket channel
      TrustdartPlugin.register(
        with: self.registrar(forPlugin: "TrustdartPlugin")!
      )
      // Wallet-core channel (trustdart)
      WalletCorePlugin.register(
        with: self.registrar(forPlugin: "WalletCorePlugin")!
      )
      // Passkey (WebAuthn) channel
      if #available(iOS 16.0, *) {
        PasskeyHandler.register(
          with: self.registrar(forPlugin: "PasskeyHandler")!
        )
      }

      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(
          name: "ai.n42.www/app_config",
          binaryMessenger: controller.binaryMessenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
          guard let self else {
            result(FlutterError(code: "unavailable", message: "AppDelegate released", details: nil))
            return
          }
          if call.method == "getSocialAuthConfig" {
            result(self.socialAuthConfig())
          } else {
            result(FlutterMethodNotImplemented)
          }
        }
      }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

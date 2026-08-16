import Flutter
import ActivityKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var mlsHandler: N42MlsHandler?
  private var screenProtectionHandler: ScreenProtectionHandler?

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
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    let registry = engineBridge.pluginRegistry
    GeneratedPluginRegistrant.register(with: registry)

    if let registrar = registry.registrar(forPlugin: "TrustdartPlugin") {
      TrustdartPlugin.register(with: registrar)
    }
    if let registrar = registry.registrar(forPlugin: "WalletCorePlugin") {
      WalletCorePlugin.register(with: registrar)
    }
    if #available(iOS 16.0, *),
       let registrar = registry.registrar(forPlugin: "PasskeyHandler") {
      PasskeyHandler.register(with: registrar)
    }

    let messenger = engineBridge.applicationRegistrar.messenger()
    let appConfigChannel = FlutterMethodChannel(
      name: "ai.n42.www/app_config",
      binaryMessenger: messenger
    )
    appConfigChannel.setMethodCallHandler { [weak self] call, result in
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

    let systemIntegrationChannel = FlutterMethodChannel(
      name: "n42.chat/system_integration",
      binaryMessenger: messenger
    )
    systemIntegrationChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "AppDelegate released", details: nil))
        return
      }
      self.handleSystemIntegration(call, result: result)
    }

    mlsHandler = N42MlsHandler(binaryMessenger: messenger)

    // iOS 截屏 / 录屏防护（对应 Android FLAG_SECURE）：注册
    // ai.n42.www/window_flags 通道的原生处理器。强引用持有，防止被回收。
    screenProtectionHandler = ScreenProtectionHandler(binaryMessenger: messenger)
  }

  /// 处理 n42_chat 系统集成通道：仅接管 iOS Live Activity 相关方法。
  private func handleSystemIntegration(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "isSupported":
      let capability = args["capability"] as? String
      guard capability == "liveActivity" else {
        // 其余能力交给 Dart 兜底
        result(FlutterMethodNotImplemented)
        return
      }
      if #available(iOS 16.1, *) {
        result(ActivityAuthorizationInfo().areActivitiesEnabled)
      } else {
        result(false)
      }

    case "updateLiveActivity":
      guard #available(iOS 16.1, *) else {
        result(false)
        return
      }
      let title = (args["title"] as? String) ?? "N42"
      let body = (args["body"] as? String) ?? ""
      let state = N42ChatCallAttributes.ContentState(body: body)
      // 仅当现有活动仍处于 active 才更新；若系统已消解则落到 else 重新发起，
      // 避免对已结束的活动 update 空转而看不到任何活动。
      if let activity = chatCallActivity, activity.activityState == .active {
        Task { await activity.update(using: state) }
        result(true)
      } else {
        do {
          chatCallActivity = try Activity.request(
            attributes: N42ChatCallAttributes(title: title),
            contentState: state
          )
          result(true)
        } catch {
          result(FlutterError(
            code: "LiveActivityError",
            message: "Failed to start chat call Live Activity: \(error)",
            details: nil
          ))
        }
      }

    case "endLiveActivity":
      guard #available(iOS 16.1, *) else {
        result(true)
        return
      }
      let activity = chatCallActivity
      chatCallActivity = nil
      if let activity = activity {
        let finalState = N42ChatCallAttributes.ContentState(body: "")
        Task { await activity.end(using: finalState, dismissalPolicy: .immediate) }
      }
      result(true)

    default:
      // showConversationBubble / setDynamicShortcuts / setTrayBadge /
      // flashWindow 等交给 Dart 侧插件兜底
      result(FlutterMethodNotImplemented)
    }
  }
}

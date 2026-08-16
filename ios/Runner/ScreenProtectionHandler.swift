import Flutter
import UIKit

/// iOS 截屏 / 录屏防护处理器（对应 Android 的 FLAG_SECURE）。
///
/// Dart 侧 `ScreenshotProtectionService` 通过 MethodChannel
/// `ai.n42.www/window_flags` 调用 `setScreenProtection`(bool)。iOS 没有
/// FLAG_SECURE，这里用业界通行的「secure UITextField 图层寄生」手法达到等效：
/// 把 window 的 layer 挂到一个 `isSecureTextEntry = true` 的隐藏文本框的安全
/// 画布下，系统截屏 / 录屏 / 后台快照对该图层渲染为空白，用户看到的实时内容
/// 不受影响。关闭时把 `isSecureTextEntry` 置回 false 即恢复正常渲染。
///
/// 另监听 `capturedDidChangeNotification`：开启防护且屏幕正被录制 / 镜像时
/// 一并遮蔽（录屏比截屏更容易整段外泄）。截屏发生时回调 Dart `onScreenshotTaken`，
/// 供上层做审计 / 提示（Dart 侧未监听时无副作用）。
///
/// ⚠️ 原生代码，需真机验证：secure-field 图层寄生在不同 iOS 版本 / 多 window
/// 场景下表现需实机确认（模拟器截屏不走该路径）。
final class ScreenProtectionHandler {
  private let channel: FlutterMethodChannel
  private let secureField = UITextField()
  private var enabled = false
  private var blurView: UIVisualEffectView?

  init(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "ai.n42.www/window_flags",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    if #available(iOS 11.0, *) {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(onCaptureChanged),
        name: UIScreen.capturedDidChangeNotification,
        object: nil
      )
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    // Dart 在 iOS 上调 setScreenProtection；同时接受 setFlagSecure 以与
    // Android 方法名对齐，避免调用方分叉。
    case "setScreenProtection", "setFlagSecure":
      let enable = (call.arguments as? Bool)
        ?? ((call.arguments as? [String: Any])?["enable"] as? Bool)
        ?? false
      setProtection(enable)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// 取当前活动的 key window。
  private func keyWindow() -> UIWindow? {
    if #available(iOS 13.0, *) {
      return UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow } ?? UIApplication.shared.windows.first
    }
    return UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
  }

  private func setProtection(_ enable: Bool) {
    enabled = enable
    guard let window = keyWindow() else { return }

    // 首次装配 secure-field 的图层寄生（只挂一次，之后靠 isSecureTextEntry 开关）。
    if secureField.superview == nil {
      secureField.isUserInteractionEnabled = false
      secureField.backgroundColor = .clear
      window.addSubview(secureField)
      secureField.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        secureField.centerXAnchor.constraint(equalTo: window.centerXAnchor),
        secureField.centerYAnchor.constraint(equalTo: window.centerYAnchor),
      ])
      window.layer.superlayer?.addSublayer(secureField.layer)
      if let last = secureField.layer.sublayers?.last {
        last.addSublayer(window.layer)
      }
    }
    secureField.isSecureTextEntry = enable
  }

  @available(iOS 11.0, *)
  @objc private func onCaptureChanged() {
    // 仅在防护开启时对录屏 / 镜像做额外遮蔽。
    guard enabled else { removeBlur(); return }
    if UIScreen.main.isCaptured {
      addBlur()
    } else {
      removeBlur()
    }
  }

  private func addBlur() {
    guard blurView == nil, let window = keyWindow() else { return }
    let effect = UIBlurEffect(style: .systemMaterialDark)
    let view = UIVisualEffectView(effect: effect)
    view.frame = window.bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(view)
    blurView = view
  }

  private func removeBlur() {
    blurView?.removeFromSuperview()
    blurView = nil
  }

  @objc private func onScreenshot() {
    // 无法阻止已发生的截屏，但回调上层用于审计 / 提示。
    channel.invokeMethod("onScreenshotTaken", arguments: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

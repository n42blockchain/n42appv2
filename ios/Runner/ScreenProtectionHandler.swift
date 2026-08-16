import Flutter
import UIKit

/// iOS 截屏 / 录屏防护处理器（对应 Android 的 FLAG_SECURE）。
///
/// Dart 侧 `ScreenshotProtectionService` 通过 MethodChannel
/// `ai.n42.www/window_flags` 调用 `setScreenProtection`(bool)。iOS 没有
/// FLAG_SECURE，这里用业界通行的「secure UITextField 图层寄生」手法达到等效：
/// 把 window 的 layer 挂到一个 `isSecureTextEntry = true` 的隐藏文本框的安全
/// 画布下，系统截屏 / 录屏 / 后台快照对该图层渲染为空白，用户看到的实时内容
/// 不受影响。
///
/// ⚠️ 关键：开启时若 `window.layer.superlayer` 为 nil，则**跳过**图层寄生
/// （否则 window.layer 会同时挂在 window 与 secure 画布下，形成 CALayer 环，
/// 关闭时抛 CALayerInvalid 崩溃——2026-08 真机确认）。关闭时**先**把
/// window.layer 还原回原父层，**再**拆除 secure field，保证拆除前环已解开。
///
/// 另监听 `capturedDidChangeNotification`：开启防护且屏幕正被录制 / 镜像时
/// 叠加遮罩（录屏比截屏更容易整段外泄）。截屏发生回调 Dart `onScreenshotTaken`。
final class ScreenProtectionHandler {
  private let channel: FlutterMethodChannel
  private var secureField: UITextField?
  private weak var protectedWindow: UIWindow?
  private var originalSuperlayer: CALayer?
  private var blurView: UIVisualEffectView?
  private var enabled = false

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
    // 图层操作必须在主线程。
    if Thread.isMainThread {
      enable ? applySecure() : removeSecure()
    } else {
      DispatchQueue.main.async { [weak self] in
        enable ? self?.applySecure() : self?.removeSecure()
      }
    }
  }

  /// 开启：装配 secure-field 图层寄生（幂等，只装一次）。
  private func applySecure() {
    guard secureField == nil, let window = keyWindow() else { return }

    let field = UITextField()
    field.isUserInteractionEnabled = false
    field.backgroundColor = .clear
    field.isSecureTextEntry = true
    window.addSubview(field)
    field.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      field.centerXAnchor.constraint(equalTo: window.centerXAnchor),
      field.centerYAnchor.constraint(equalTo: window.centerYAnchor),
    ])

    // 记录 window.layer 的原始父层，供关闭时还原。
    let superlayer = window.layer.superlayer
    originalSuperlayer = superlayer
    // 仅当存在有效父层时才做寄生：superlayer 为 nil 时寄生会造成层级环，
    // 宁可放弃遮蔽也不冒崩溃风险（真机可见 window 一般都有父层）。
    if let superlayer = superlayer,
       let canvas = field.layer.sublayers?.first {
      superlayer.addSublayer(field.layer)
      canvas.addSublayer(window.layer)
    }

    secureField = field
    protectedWindow = window
  }

  /// 关闭：先解环（还原 window.layer 到原父层），再拆除 secure field。
  private func removeSecure() {
    guard let field = secureField else { return }
    if let window = protectedWindow, let superlayer = originalSuperlayer {
      // 关键顺序：先把 window.layer 挪回原父层，断开与 secure 画布的父子
      // 关系；此时再销毁 field 就不会留下悬挂在已失效画布下的 window.layer。
      superlayer.addSublayer(window.layer)
    }
    field.isSecureTextEntry = false
    field.removeFromSuperview()
    secureField = nil
    originalSuperlayer = nil
    protectedWindow = nil
  }

  @available(iOS 11.0, *)
  @objc private func onCaptureChanged() {
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
    view.isUserInteractionEnabled = false
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

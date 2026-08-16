import Flutter
import UIKit

/// iOS 截屏 / 录屏防护处理器（对应 Android 的 FLAG_SECURE）。
///
/// Dart 侧 `ScreenshotProtectionService` 通过 MethodChannel
/// `ai.n42.www/window_flags` 调用 `setScreenProtection`(bool)。iOS 没有
/// FLAG_SECURE，这里用业界通行的「secure UITextField 图层寄生」手法达到等效：
/// 把 Flutter 内容 layer 挂到一个 `isSecureTextEntry = true` 的文本框安全画布
/// 下，系统截屏 / 录屏 / 后台快照对该图层渲染为空白，用户看到的实时内容不受
/// 影响。不要移动 `UIWindow.layer`：iOS 26 会因此破坏 UIWindow 的 Auto Layout
/// engine，第二次开启时在约束激活处 EXC_BAD_ACCESS。secure field 只装配一次，
/// 开关仅在 window 与安全画布之间移动 Flutter 内容 layer。
///
/// 另监听 `capturedDidChangeNotification`：开启防护且屏幕正被录制 / 镜像时
/// 叠加遮罩（录屏比截屏更容易整段外泄）。截屏发生回调 Dart `onScreenshotTaken`。
final class ScreenProtectionHandler {
  private let channel: FlutterMethodChannel
  private let secureField = UITextField()
  private weak var protectedWindow: UIWindow?
  private weak var protectedContentView: UIView?
  private weak var originalContentSuperlayer: CALayer?
  private weak var secureCanvasLayer: CALayer?
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
      if enable {
        applySecure()
      } else {
        removeSecure()
        removeBlur()
      }
    } else {
      DispatchQueue.main.async { [weak self] in
        if enable {
          self?.applySecure()
        } else {
          self?.removeSecure()
          self?.removeBlur()
        }
      }
    }
  }

  /// 找出 UITextField 内由系统标记为安全内容的 canvas。
  /// 不依赖某个固定的 sublayer 下标，以兼容不同 iOS 版本的内部层级。
  private func findSecureCanvas(in view: UIView) -> UIView? {
    for subview in view.subviews {
      if String(describing: type(of: subview)).localizedCaseInsensitiveContains("canvas") {
        return subview
      }
      if let nested = findSecureCanvas(in: subview) {
        return nested
      }
    }
    return nil
  }

  /// secure field 只装配一次。把它保留在 window 内可避免反复销毁 UIKit 私有
  /// canvas；关闭防护时 canvas 为空，不会影响普通截屏。
  private func prepareSecureCanvas(in window: UIWindow) -> Bool {
    if protectedWindow === window,
       protectedContentView != nil,
       originalContentSuperlayer != nil,
       secureCanvasLayer != nil {
      return true
    }

    // Scene / key window 发生切换时，先恢复旧窗口再重新装配，不能把旧窗口的
    // Flutter 内容留在即将迁移的 secure field canvas 内。
    if protectedWindow != nil, protectedWindow !== window {
      removeSecure()
      secureField.removeFromSuperview()
      protectedWindow = nil
      protectedContentView = nil
      originalContentSuperlayer = nil
      secureCanvasLayer = nil
    }

    guard let contentView = window.rootViewController?.view,
          let originalSuperlayer = contentView.layer.superlayer else {
      return false
    }

    secureField.isUserInteractionEnabled = false
    secureField.backgroundColor = .clear
    secureField.borderStyle = .none
    secureField.isSecureTextEntry = true
    secureField.frame = window.bounds
    secureField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(secureField)
    window.sendSubviewToBack(secureField)
    secureField.layoutIfNeeded()

    guard let canvas = findSecureCanvas(in: secureField) else {
      secureField.removeFromSuperview()
      return false
    }
    canvas.clipsToBounds = false

    protectedWindow = window
    protectedContentView = contentView
    originalContentSuperlayer = originalSuperlayer
    secureCanvasLayer = canvas.layer
    return true
  }

  /// 开启：只移动 Flutter 根视图 layer，不触碰 UIWindow.layer / 约束引擎。
  private func applySecure() {
    guard let window = keyWindow(), prepareSecureCanvas(in: window),
          let contentLayer = protectedContentView?.layer,
          let canvasLayer = secureCanvasLayer,
          contentLayer.superlayer !== canvasLayer else { return }
    canvasLayer.addSublayer(contentLayer)
  }

  /// 关闭：把 Flutter 内容 layer 放回 window；secure field 与安全 canvas 保留，
  /// 避免下一次开启重新创建私有 UIKit 层级。
  private func removeSecure() {
    guard let contentLayer = protectedContentView?.layer,
          let originalSuperlayer = originalContentSuperlayer,
          contentLayer.superlayer !== originalSuperlayer else { return }
    originalSuperlayer.addSublayer(contentLayer)
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

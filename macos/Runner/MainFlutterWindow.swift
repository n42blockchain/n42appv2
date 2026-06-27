import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // n42_chat 系统集成：仅接管 flashWindow（Dock 图标提醒）。
    // 其余能力返回 FlutterMethodNotImplemented，由 Dart 侧插件兜底
    // （flutter_local_notifications / quick_actions / app_badge_plus）。
    let sysChannel = FlutterMethodChannel(
      name: "n42.chat/system_integration",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    sysChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "flashWindow":
        // .criticalRequest：Dock 图标持续弹跳直到 App 被聚焦
        NSApp.requestUserAttention(.criticalRequest)
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}

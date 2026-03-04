import Flutter
import ActivityKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      /*FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(withRegistry: registry)
      }*/

      /// ios notification添加
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
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

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

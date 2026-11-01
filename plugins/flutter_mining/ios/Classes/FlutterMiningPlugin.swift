import Flutter
import UIKit

public class FlutterMiningPlugin: NSObject, FlutterPlugin {
  private let mobileVerify = MobileVerifyHandler()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_mining", binaryMessenger: registrar.messenger())
    let instance = FlutterMiningPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    let verification = FlutterMethodChannel(name: "n42/mobileverify", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: verification)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      mobileVerify.handle(call, result: result)
    }
  }
}

import Flutter
import UIKit
import XCTest
@testable import Runner

private final class ProtectionMessenger: NSObject, FlutterBinaryMessenger {
  var handler: FlutterBinaryMessageHandler?
  func send(onChannel channel: String, message: Data?) {}
  func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply?) {
    callback?(nil)
  }
  func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?) -> FlutterBinaryMessengerConnection {
    self.handler = handler
    return 1
  }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
  func protect(_ enabled: Bool) {
    let data = FlutterStandardMethodCodec.sharedInstance().encode(FlutterMethodCall(methodName: "setScreenProtection", arguments: enabled))
    handler?(data) { _ in }
  }
}

@MainActor
final class RunnerTests: XCTestCase {
  private var messenger: ProtectionMessenger!
  private var protection: ScreenProtectionHandler!
  private var window: UIWindow!
  private var previousWindow: UIWindow?

  override func setUp() {
    super.setUp()
    let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first!
    previousWindow = scene.windows.first { $0.isKeyWindow }
    window = UIWindow(windowScene: scene)
    window.rootViewController = UIViewController()
    window.makeKeyAndVisible()
    window.layoutIfNeeded()
    messenger = ProtectionMessenger()
    protection = ScreenProtectionHandler(binaryMessenger: messenger)
  }

  override func tearDown() {
    messenger.protect(false)
    protection = nil
    window.isHidden = true
    window = nil
    previousWindow?.makeKey()
    messenger = nil
    super.tearDown()
  }

  private func flushLayout() {
    window.setNeedsLayout()
    window.layoutIfNeeded()
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
  }
  private var hasCaptureMask: Bool { window.subviews.contains { $0 is UIVisualEffectView } }

  func testEnablingDuringExistingCaptureMasksImmediately() throws {
    if #available(iOS 17.0, *) {
      window.traitOverrides.sceneCaptureState = .active
      messenger.protect(true)
      XCTAssertTrue(hasCaptureMask)
      messenger.protect(false)
      XCTAssertFalse(hasCaptureMask)
    } else { throw XCTSkip("Scene capture traits require iOS 17") }
  }

  func testSceneCaptureTransitionsWithoutLegacyScreenNotification() throws {
    if #available(iOS 17.0, *) {
      window.traitOverrides.sceneCaptureState = .inactive
      messenger.protect(true)
      XCTAssertFalse(hasCaptureMask)
      window.traitOverrides.sceneCaptureState = .active
      flushLayout()
      XCTAssertTrue(hasCaptureMask)
      window.traitOverrides.sceneCaptureState = .inactive
      flushLayout()
      XCTAssertFalse(hasCaptureMask)
    } else { throw XCTSkip("Scene capture traits require iOS 17") }
  }

  func testReactivationMovesProtectionAndRestoresPreviousWindow() throws {
    if #available(iOS 17.0, *) {
      let oldWindow = window!
      let oldContent = oldWindow.rootViewController!.view!
      let originalSuperlayer = oldContent.layer.superlayer
      window.traitOverrides.sceneCaptureState = .active
      messenger.protect(true)
      window = UIWindow(windowScene: oldWindow.windowScene!)
      window.rootViewController = UIViewController()
      window.traitOverrides.sceneCaptureState = .active
      window.makeKeyAndVisible()
      window.layoutIfNeeded()
      NotificationCenter.default.post(name: UIScene.didActivateNotification, object: window.windowScene)
      XCTAssertNotNil(originalSuperlayer)
      XCTAssertTrue(oldContent.layer.superlayer === originalSuperlayer)
      XCTAssertFalse(oldWindow.subviews.contains { $0 is UIVisualEffectView })
      XCTAssertTrue(hasCaptureMask)
      oldWindow.isHidden = true
    } else { throw XCTSkip("Scene capture traits require iOS 17") }
  }
}

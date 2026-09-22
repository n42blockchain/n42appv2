import EventKit
import EventKitUI
import Flutter
import ActivityKit
import CoreImage
import UIKit
import WebRTC
import flutter_webrtc

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var calendarHandler: N42CalendarHandler?
  private var mlsHandler: N42MlsHandler?
  private var screenProtectionHandler: ScreenProtectionHandler?
  private var videoBeautyHandler: N42VideoBeautyHandler?

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

    calendarHandler = N42CalendarHandler(messenger: messenger)
    mlsHandler = N42MlsHandler(binaryMessenger: messenger)

    // iOS 截屏 / 录屏防护（对应 Android FLAG_SECURE）：注册
    // ai.n42.www/window_flags 通道的原生处理器。强引用持有，防止被回收。
    screenProtectionHandler = ScreenProtectionHandler(binaryMessenger: messenger)
    // Applies beauty/filter settings before WebRTC publishes camera frames.
    // The local preview and remote viewers therefore observe the same output.
    videoBeautyHandler = N42VideoBeautyHandler(binaryMessenger: messenger)
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

/// Owns the n42.chat/virtual_background method channel on iOS and attaches a
/// Core Image processor to flutter_webrtc's local camera track. Background
/// replacement remains a separate capability; this handler intentionally
/// implements only the beauty/filter settings it can apply to the real stream.
private final class N42VideoBeautyHandler {
  private let channel: FlutterMethodChannel
  private let processor = N42VideoBeautyProcessor()
  private weak var attachedTrack: LocalVideoTrack?
  private var attachedTrackId: String?

  init(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "n42.chat/virtual_background",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setBackgroundConfig":
      guard let args = call.arguments as? [String: Any] else {
        result(false)
        return
      }
      processor.update(args)
      let enabled = args["enabled"] as? Bool ?? false
      guard enabled else {
        detach()
        result(true)
        return
      }
      guard let trackId = args["trackId"] as? String, !trackId.isEmpty else {
        result(false)
        return
      }
      result(attach(to: trackId))

    case "clearBackground":
      processor.reset()
      detach()
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func attach(to trackId: String) -> Bool {
    if attachedTrackId == trackId, attachedTrack != nil { return true }
    detach()
    guard
      let plugin = FlutterWebRTCPlugin.sharedSingleton(),
      let track = plugin.localTracks?[trackId] as? LocalVideoTrack
    else {
      return false
    }
    track.addProcessing(processor)
    attachedTrack = track
    attachedTrackId = trackId
    return true
  }

  private func detach() {
    attachedTrack?.removeProcessing(processor)
    attachedTrack = nil
    attachedTrackId = nil
  }
}

private final class N42VideoBeautyProcessor: NSObject, ExternalVideoProcessingDelegate {
  private let context = CIContext(options: [.cacheIntermediates: true])
  private var smooth: Double = 0
  private var brightness: Double = 0
  private var rosy: Double = 0
  private var filterName = "none"
  private var filterStrength: Double = 0
  private var pool: CVPixelBufferPool?
  private var poolSize = CGSize.zero

  func update(_ args: [String: Any]) {
    smooth = Self.unit(args["beauty"])
    brightness = Self.unit(args["brightness"])
    rosy = Self.unit(args["rosy"])
    filterName = args["filter"] as? String ?? "none"
    filterStrength = Self.unit(args["filterStrength"])
  }

  func reset() {
    smooth = 0
    brightness = 0
    rosy = 0
    filterName = "none"
    filterStrength = 0
  }

  @objc func onFrame(_ frame: RTCVideoFrame) -> RTCVideoFrame {
    guard smooth > 0 || brightness > 0 || rosy > 0 ||
      (filterName != "none" && filterStrength > 0),
      let rtcBuffer = frame.buffer as? RTCCVPixelBuffer
    else {
      return frame
    }

    let sourceBuffer = rtcBuffer.pixelBuffer
    let width = CVPixelBufferGetWidth(sourceBuffer)
    let height = CVPixelBufferGetHeight(sourceBuffer)
    let source = CIImage(cvPixelBuffer: sourceBuffer)
    var output = source

    if smooth > 0, let noise = CIFilter(name: "CINoiseReduction") {
      noise.setValue(output, forKey: kCIInputImageKey)
      noise.setValue(0.01 + smooth * 0.055, forKey: "inputNoiseLevel")
      noise.setValue(0.45 - smooth * 0.15, forKey: "inputSharpness")
      if let image = noise.outputImage {
        output = blend(source: output, effect: image, amount: smooth * 0.7)
      }
    }

    if brightness > 0, let controls = CIFilter(name: "CIColorControls") {
      controls.setValue(output, forKey: kCIInputImageKey)
      controls.setValue(brightness * 0.16, forKey: kCIInputBrightnessKey)
      controls.setValue(1.0 + brightness * 0.025, forKey: kCIInputSaturationKey)
      output = controls.outputImage ?? output
    }

    if rosy > 0, let matrix = CIFilter(name: "CIColorMatrix") {
      matrix.setValue(output, forKey: kCIInputImageKey)
      matrix.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector")
      matrix.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
      matrix.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")
      matrix.setValue(
        CIVector(x: rosy * 0.07, y: rosy * 0.012, z: -rosy * 0.018, w: 0),
        forKey: "inputBiasVector"
      )
      output = matrix.outputImage ?? output
    }

    output = applyFilter(to: output)
    guard let destination = makePixelBuffer(width: width, height: height) else {
      return frame
    }
    context.render(output, to: destination, bounds: source.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
    let processed = RTCCVPixelBuffer(pixelBuffer: destination)
    return RTCVideoFrame(
      buffer: processed,
      rotation: frame.rotation,
      timeStampNs: frame.timeStampNs
    )
  }

  private func applyFilter(to source: CIImage) -> CIImage {
    guard filterStrength > 0, filterName != "none" else { return source }
    let effect: CIImage?
    switch filterName {
    case "natural":
      effect = colorControls(source, saturation: 1.06, contrast: 1.025, brightness: 0.012)
    case "warm":
      effect = colorBias(source, red: 0.055, green: 0.012, blue: -0.055)
    case "cool":
      effect = colorBias(source, red: -0.045, green: 0.008, blue: 0.06)
    case "vivid":
      effect = colorControls(source, saturation: 1.38, contrast: 1.08, brightness: 0)
    case "mono":
      let mono = CIFilter(name: "CIPhotoEffectMono")
      mono?.setValue(source, forKey: kCIInputImageKey)
      effect = mono?.outputImage
    default:
      effect = nil
    }
    guard let effect else { return source }
    return blend(source: source, effect: effect, amount: filterStrength)
  }

  private func colorControls(
    _ image: CIImage,
    saturation: Double,
    contrast: Double,
    brightness: Double
  ) -> CIImage? {
    let controls = CIFilter(name: "CIColorControls")
    controls?.setValue(image, forKey: kCIInputImageKey)
    controls?.setValue(saturation, forKey: kCIInputSaturationKey)
    controls?.setValue(contrast, forKey: kCIInputContrastKey)
    controls?.setValue(brightness, forKey: kCIInputBrightnessKey)
    return controls?.outputImage
  }

  private func colorBias(_ image: CIImage, red: Double, green: Double, blue: Double) -> CIImage? {
    let matrix = CIFilter(name: "CIColorMatrix")
    matrix?.setValue(image, forKey: kCIInputImageKey)
    matrix?.setValue(CIVector(x: red, y: green, z: blue, w: 0), forKey: "inputBiasVector")
    return matrix?.outputImage
  }

  private func blend(source: CIImage, effect: CIImage, amount: Double) -> CIImage {
    let transition = CIFilter(name: "CIDissolveTransition")
    transition?.setValue(source, forKey: kCIInputImageKey)
    transition?.setValue(effect, forKey: kCIInputTargetImageKey)
    transition?.setValue(amount, forKey: kCIInputTimeKey)
    return transition?.outputImage ?? effect
  }

  private func makePixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
    let size = CGSize(width: width, height: height)
    if pool == nil || poolSize != size {
      let attributes: [String: Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
        kCVPixelBufferIOSurfacePropertiesKey as String: [:],
      ]
      var newPool: CVPixelBufferPool?
      CVPixelBufferPoolCreate(nil, nil, attributes as CFDictionary, &newPool)
      pool = newPool
      poolSize = size
    }
    var buffer: CVPixelBuffer?
    guard let pool, CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer) == kCVReturnSuccess else {
      return nil
    }
    return buffer
  }

  private static func unit(_ value: Any?) -> Double {
    min(1, max(0, (value as? NSNumber)?.doubleValue ?? 0))
  }
}


/// Presents the system event editor; the user chooses whether to save.
private final class N42CalendarHandler: NSObject, EKEventEditViewDelegate, UIAdaptivePresentationControllerDelegate {
  private let store = EKEventStore()
  private var pending: FlutterResult?
  init(messenger: FlutterBinaryMessenger) {
    super.init()
    FlutterMethodChannel(name: "n42.chat/calendar", binaryMessenger: messenger)
      .setMethodCallHandler { [weak self] call, result in
        guard call.method == "addEvent", let self else {
          result(FlutterMethodNotImplemented); return
        }
        guard self.pending == nil, let args = call.arguments as? [String: Any],
              let title = args["title"] as? String,
              let start = args["starts_at"] as? NSNumber else {
          result(FlutterError(code: "invalid_event", message: "Calendar editor unavailable", details: nil)); return
        }
        self.pending = result
        let present = { [weak self] in
          guard let self else { return }
          DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }),
                  var presenter = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
              self.finish(false); return
            }
            while let top = presenter.presentedViewController { presenter = top }
            let event = EKEvent(eventStore: self.store)
            event.title = title
            event.startDate = Date(timeIntervalSince1970: start.doubleValue / 1000)
            let end = (args["ends_at"] as? NSNumber)?.doubleValue ?? (start.doubleValue + 3600000)
            event.endDate = Date(timeIntervalSince1970: max(end, start.doubleValue) / 1000)
            event.location = args["location"] as? String
            event.notes = args["description"] as? String
            let editor = EKEventEditViewController()
            editor.eventStore = self.store
            editor.event = event
            editor.editViewDelegate = self
            // Swiping the editor closed does not necessarily call its edit delegate.
            // Complete the Flutter request so the next event can open normally.
            editor.presentationController?.delegate = self
            presenter.present(editor, animated: true)
          }
        }
        if #available(iOS 17.0, *) {
          present()
        } else {
          self.store.requestAccess(to: .event) { [weak self] granted, _ in
            if granted { present() } else { DispatchQueue.main.async { self?.finish(false) } }
          }
        }
      }
  }
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    finish(false)
  }
  private func finish(_ saved: Bool) { let result = pending; pending = nil; result?(saved) }
  func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
    controller.dismiss(animated: true) { self.finish(action == .saved) }
  }
}

import Flutter
import UIKit

/// One process-wide miner, including when Flutter creates another engine.
/// iOS grants only a finite grace period to cancel work on backgrounding.
final class IOSMobileVerifyRuntime {
  static let shared = IOSMobileVerifyRuntime()
  let miner: MobileVerifyMinerHost
  private var observers: [NSObjectProtocol] = []

  private init() {
    miner = MobileVerifyMinerHost(
      backend: EvmsdkMobileVerifyBackend(),
      applicationActive: UIApplication.shared.applicationState != .background)
    let center = NotificationCenter.default
    observers.append(center.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                        object: nil, queue: .main) { [weak self] _ in
      guard let self = self else { return }
      let application = UIApplication.shared
      var task = UIBackgroundTaskIdentifier.invalid
      let finish = {
        if task != .invalid {
          application.endBackgroundTask(task)
          task = .invalid
        }
      }
      task = application.beginBackgroundTask(withName: "Pause N42 verification", expirationHandler: finish)
      self.miner.setApplicationActive(false, completion: finish)
    })
    observers.append(center.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                        object: nil, queue: .main) { [weak self] _ in
      self?.miner.setApplicationActive(true)
    })
    observers.append(center.addObserver(forName: UIApplication.willTerminateNotification,
                                        object: nil, queue: .main) { [weak self] _ in
      self?.miner.stop { _ in }
    })
  }
}

final class MobileVerifyHandler {
  private let sessions = MobileVerifySessionHost(backend: EvmsdkMobileVerifyBackend())
  private let miner = IOSMobileVerifyRuntime.shared.miner
  private var backgroundObserver: NSObjectProtocol?

  init() {
    backgroundObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main
    ) { [weak self] _ in self?.sessions.close() }
  }

  deinit {
    if let backgroundObserver = backgroundObserver {
      NotificationCenter.default.removeObserver(backgroundObserver)
    }
    sessions.close()
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    func reply<T>(_ value: Result<T, Error>) {
      switch value {
      case .success(let value): result(value is Void ? nil : value)
      case .failure(let error):
        result(FlutterError(code: "MobileVerify", message: error.localizedDescription, details: nil))
      }
    }
    func argument(_ name: String) throws -> String {
      guard let values = call.arguments as? [String: Any],
            let value = values[name] as? String, !value.isEmpty else {
        throw MobileVerifyBridgeError.missingArgument(name)
      }
      return value
    }
    do {
      switch call.method {
      case "generateKey": sessions.generateKey(completion: reply)
      case "publicKey": sessions.publicKey(try argument("privHex"), completion: reply)
      case "open":
        sessions.open(baseURL: try argument("baseUrl"), privateKey: try argument("privHex"),
                      chain: try argument("chain"), completion: reply)
      case "register": sessions.perform({ try $0.register() }, completion: reply)
      case "latest": sessions.perform({ try $0.latest() }, completion: reply)
      case "verifyBlock":
        let hash = try argument("blockHash")
        sessions.perform({ try $0.verifyBlock(hash) }, completion: reply)
      case "cert":
        let hash = try argument("blockHash")
        sessions.perform({ try $0.cert(hash) }, completion: reply)
      case "health": sessions.perform({ try $0.health() }, completion: reply)
      case "close":
        sessions.close()
        result(nil)
      case "minerStart":
        miner.start(baseURL: try argument("baseUrl"), privateKey: try argument("privHex"),
                    chain: try argument("chain"), completion: reply)
      case "minerStop": miner.stop(completion: reply)
      case "minerStatus": miner.status(completion: reply)
      default: result(FlutterMethodNotImplemented)
      }
    } catch {
      reply(Result<Void, Error>.failure(error))
    }
  }
}

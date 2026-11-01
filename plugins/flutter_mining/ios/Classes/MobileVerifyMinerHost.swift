import Foundation

protocol MobileVerifyMinerBackend: AnyObject {
  var pubkeyHex: String { get }
  var running: Bool { get }
  func start()
  func stop()
  func status() -> String
}

protocol MobileVerifyBackend {
  func generateKey() throws -> String
  func publicKey(_ privateKey: String) throws -> String
  func makeMiner(baseURL: String, privateKey: String, chain: String) throws -> MobileVerifyMinerBackend
  func makeSession(baseURL: String, privateKey: String, chain: String) throws -> MobileVerifySessionBackend
}

enum MobileVerifyBridgeError: Error, LocalizedError {
  case missingArgument(String)
  case noSession
  case cancelled
  case invalidNativeStatus

  var errorDescription: String? {
    switch self {
    case .missingArgument(let name): return "Missing argument: \(name)"
    case .noSession: return "No mobile verification session; call open first."
    case .cancelled: return "Mobile verification session was closed."
    case .invalidNativeStatus: return "The native miner returned invalid status."
    }
  }
}

func mobileVerifyReply<T>(_ value: Result<T, Error>, to completion: @escaping (Result<T, Error>) -> Void) {
  DispatchQueue.main.async { completion(value) }
}

/// Owns the SDK loop independently of Flutter views. All SDK lifecycle work is
/// serialized off the UI thread. iOS background suspension is an explicit pause.
final class MobileVerifyMinerHost {
  private let worker = DispatchQueue(label: "ai.n42.mobileverify.miner")
  private let backend: MobileVerifyBackend
  private let clock: () -> TimeInterval
  private var miner: MobileVerifyMinerBackend?
  private var configuration: String?
  private var requested = false
  private var applicationActive: Bool
  private var sessionID: String?
  private var activeSince: TimeInterval?
  private var elapsed: TimeInterval = 0

  init(backend: MobileVerifyBackend, applicationActive: Bool = true,
       clock: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }) {
    self.backend = backend
    self.applicationActive = applicationActive
    self.clock = clock
  }

  func start(baseURL: String, privateKey: String, chain: String,
             completion: @escaping (Result<Void, Error>) -> Void) {
    worker.async {
      do {
        let publicKey = try self.backend.publicKey(privateKey)
        let configuration = "\(baseURL)|\(chain)|\(publicKey)"
        if !(self.requested && self.configuration == configuration) {
          // Validate a replacement before stopping a working miner.
          let created = try self.backend.makeMiner(baseURL: baseURL, privateKey: privateKey, chain: chain)
          self.freezeDuration()
          self.miner?.stop()
          self.miner = created
          self.configuration = configuration
          self.sessionID = UUID().uuidString
          self.elapsed = 0
          self.requested = true
        }
        self.resumeIfAllowed()
        mobileVerifyReply(.success(()), to: completion)
      } catch {
        mobileVerifyReply(.failure(error), to: completion)
      }
    }
  }

  func stop(completion: @escaping (Result<Void, Error>) -> Void) {
    worker.async {
      self.requested = false
      self.freezeDuration()
      self.miner?.stop()
      mobileVerifyReply(.success(()), to: completion)
    }
  }

  func setApplicationActive(_ active: Bool, completion: (() -> Void)? = nil) {
    worker.async {
      self.applicationActive = active
      if active {
        self.resumeIfAllowed()
      } else {
        self.freezeDuration()
        self.miner?.stop()
      }
      if let completion = completion {
        DispatchQueue.main.async(execute: completion)
      }
    }
  }

  func status(completion: @escaping (Result<String, Error>) -> Void) {
    worker.async {
      do {
        let raw = self.miner?.status() ?? "{\"running\":false,\"phase\":\"idle\"}"
        guard let data = raw.data(using: .utf8),
              var object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
          throw MobileVerifyBridgeError.invalidNativeStatus
        }
        object["pausedForBackground"] = self.requested && !self.applicationActive
        if let sessionID = self.sessionID {
          object["sessionId"] = sessionID
          let current = self.activeSince.map { max(0, self.clock() - $0) } ?? 0
          object["activeDurationMs"] = Int64((self.elapsed + current) * 1000)
        }
        let encoded = try JSONSerialization.data(withJSONObject: object)
        guard let string = String(data: encoded, encoding: .utf8) else {
          throw MobileVerifyBridgeError.invalidNativeStatus
        }
        mobileVerifyReply(.success(string), to: completion)
      } catch {
        mobileVerifyReply(.failure(error), to: completion)
      }
    }
  }

  private func resumeIfAllowed() {
    guard requested, applicationActive, let miner = miner, !miner.running else { return }
    miner.start()
    activeSince = clock()
  }

  private func freezeDuration() {
    if let activeSince = activeSince {
      elapsed += max(0, clock() - activeSince)
      self.activeSince = nil
    }
  }
}

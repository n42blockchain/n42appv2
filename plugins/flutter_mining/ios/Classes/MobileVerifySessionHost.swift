import Foundation

protocol MobileVerifySessionBackend: AnyObject {
  var pubkeyHex: String { get }
  func close()
  func register() throws -> String
  func latest() throws -> String
  func verifyBlock(_ hash: String) throws -> String
  func cert(_ hash: String) throws -> String
  func health() throws -> String
}

/// A separate queue prevents a slow probe HTTP call from delaying miner Stop.
/// Close cancels immediately, including an Open queued behind an earlier call.
final class MobileVerifySessionHost {
  private let worker = DispatchQueue(label: "ai.n42.mobileverify.session")
  private let backend: MobileVerifyBackend
  private let lock = NSLock()
  private var session: MobileVerifySessionBackend?
  private var revision: UInt64 = 0

  init(backend: MobileVerifyBackend) { self.backend = backend }

  func generateKey(completion: @escaping (Result<String, Error>) -> Void) {
    utility({ try self.backend.generateKey() }, completion: completion)
  }

  func publicKey(_ key: String, completion: @escaping (Result<String, Error>) -> Void) {
    utility({ try self.backend.publicKey(key) }, completion: completion)
  }

  func open(baseURL: String, privateKey: String, chain: String,
            completion: @escaping (Result<String, Error>) -> Void) {
    close()
    let expected = currentRevision()
    utility({
      guard self.currentRevision() == expected else { throw MobileVerifyBridgeError.cancelled }
      let opened = try self.backend.makeSession(baseURL: baseURL, privateKey: privateKey, chain: chain)
      self.lock.lock()
      let accepted = self.revision == expected
      if accepted { self.session = opened }
      self.lock.unlock()
      guard accepted else {
        opened.close()
        throw MobileVerifyBridgeError.cancelled
      }
      return opened.pubkeyHex
    }, completion: completion)
  }

  func close() {
    lock.lock()
    revision &+= 1
    let closing = session
    session = nil
    lock.unlock()
    closing?.close()
  }

  func perform(_ action: @escaping (MobileVerifySessionBackend) throws -> String,
               completion: @escaping (Result<String, Error>) -> Void) {
    let expected = currentRevision()
    utility({
      self.lock.lock()
      let current = self.revision == expected ? self.session : nil
      self.lock.unlock()
      guard let current = current else { throw MobileVerifyBridgeError.noSession }
      return try action(current)
    }, completion: completion)
  }

  private func currentRevision() -> UInt64 {
    lock.lock()
    defer { lock.unlock() }
    return revision
  }

  private func utility(_ action: @escaping () throws -> String,
                       completion: @escaping (Result<String, Error>) -> Void) {
    worker.async { mobileVerifyReply(Result { try action() }, to: completion) }
  }
}

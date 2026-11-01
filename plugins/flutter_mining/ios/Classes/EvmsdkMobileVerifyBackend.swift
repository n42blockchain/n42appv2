import Foundation
import N42MobileVerify

/// Only this adapter knows the generated Objective-C binding names.
final class EvmsdkMobileVerifyBackend: MobileVerifyBackend {
  func generateKey() throws -> String {
    var error: NSError?
    let key = MobileverifyGenerateKey(&error)
    if let error = error { throw error }
    return key
  }

  func publicKey(_ privateKey: String) throws -> String {
    var error: NSError?
    let key = MobileverifyPublicKey(privateKey, &error)
    if let error = error { throw error }
    return key
  }

  func makeMiner(baseURL: String, privateKey: String, chain: String) throws -> MobileVerifyMinerBackend {
    var error: NSError?
    let miner = MobileverifyNewMiner(baseURL, privateKey, chain, &error)
    if let error = error { throw error }
    guard let miner = miner else { throw MobileVerifyBridgeError.invalidNativeStatus }
    return BoundMiner(miner)
  }

  func makeSession(baseURL: String, privateKey: String, chain: String) throws -> MobileVerifySessionBackend {
    var error: NSError?
    let session = MobileverifyNewSession(baseURL, privateKey, chain, &error)
    if let error = error { throw error }
    guard let session = session else { throw MobileVerifyBridgeError.noSession }
    return BoundSession(session)
  }
}

private final class BoundMiner: MobileVerifyMinerBackend {
  private let native: MobileverifyMiner
  init(_ native: MobileverifyMiner) { self.native = native }
  var pubkeyHex: String { native.pubkeyHex() }
  var running: Bool { native.running() }
  func start() { native.start() }
  func stop() { native.stop() }
  func status() -> String { native.status() }
}

private final class BoundSession: MobileVerifySessionBackend {
  private let native: MobileverifySession
  init(_ native: MobileverifySession) { self.native = native }
  var pubkeyHex: String { native.pubkeyHex() }
  func close() { native.close() }
  func register() throws -> String { try checked { native.register($0) } }
  func latest() throws -> String { try checked { native.latest($0) } }
  func verifyBlock(_ hash: String) throws -> String { try checked { native.verifyBlock(hash, error: $0) } }
  func cert(_ hash: String) throws -> String { try checked { native.cert(hash, error: $0) } }
  func health() throws -> String { try checked { native.health($0) } }
  private func checked(_ call: (NSErrorPointer) -> String) throws -> String {
    var error: NSError?
    let value = call(&error)
    if let error = error { throw error }
    return value
  }
}

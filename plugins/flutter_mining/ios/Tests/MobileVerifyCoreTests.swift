import Foundation
import XCTest
@testable import MobileVerifyCore

private enum FakeError: Error { case failed }
private final class FakeMiner: MobileVerifyMinerBackend {
  let pubkeyHex = "public-device"
  var running = false
  var starts = 0
  var stops = 0
  func start() { starts += 1; running = true }
  func stop() { stops += 1; running = false }
  func status() -> String {
    "{\"running\":\(running),\"phase\":\"\(running ? "mining" : "idle")\",\"verified\":12,\"startedAtMs\":\(starts * 1000)}"
  }
}
private final class FakeSession: MobileVerifySessionBackend {
  let pubkeyHex = "public-device"
  var closed = false
  var latestAction: (() throws -> String)?
  var closeAction: (() -> Void)?
  func close() { closed = true; closeAction?() }
  func register() throws -> String { "registration" }
  func latest() throws -> String { try latestAction?() ?? "head" }
  func verifyBlock(_ hash: String) throws -> String { "verified-\(hash)" }
  func cert(_ hash: String) throws -> String { "certificate-\(hash)" }
  func health() throws -> String { "health" }
}
private final class FakeBackend: MobileVerifyBackend {
  var miners: [FakeMiner] = []
  var sessions: [FakeSession] = []
  var fail = false
  var sessionAction: (() -> Void)?
  func generateKey() throws -> String { "private-test-fixture" }
  func publicKey(_ privateKey: String) throws -> String {
    if fail { throw FakeError.failed }
    return "public-device"
  }
  func makeMiner(baseURL: String, privateKey: String, chain: String) throws -> MobileVerifyMinerBackend {
    XCTAssertFalse(Thread.isMainThread)
    if fail { throw FakeError.failed }
    let m = FakeMiner(); miners.append(m); return m
  }
  func makeSession(baseURL: String, privateKey: String, chain: String) throws -> MobileVerifySessionBackend {
    XCTAssertFalse(Thread.isMainThread)
    sessionAction?()
    let s = FakeSession(); sessions.append(s); return s
  }
}

final class MobileVerifyCoreTests: XCTestCase {
  private func call<T>(_ action: (@escaping (Result<T, Error>) -> Void) -> Void) throws -> T {
    let done = expectation(description: "reply")
    var value: Result<T, Error>?
    action {
      XCTAssertTrue(Thread.isMainThread)
      value = $0
      done.fulfill()
    }
    wait(for: [done], timeout: 3)
    return try XCTUnwrap(value).get()
  }
  private func status(_ host: MobileVerifyMinerHost) throws -> [String: Any] {
    let string: String = try call { host.status(completion: $0) }
    return try XCTUnwrap(JSONSerialization.jsonObject(with: Data(string.utf8)) as? [String: Any])
  }
  private func start(_ host: MobileVerifyMinerHost, url: String = "http://node:21100") throws {
    let _: Void = try call { host.start(baseURL: url, privateKey: "fixture", chain: "chain", completion: $0) }
  }
  private func active(_ host: MobileVerifyMinerHost, _ active: Bool) {
    let done = expectation(description: "lifecycle")
    host.setApplicationActive(active) { done.fulfill() }
    wait(for: [done], timeout: 3)
  }

  func testDuplicateStartAndExplicitRestart() throws {
    let b = FakeBackend(); let h = MobileVerifyMinerHost(backend: b)
    try start(h); try start(h)
    XCTAssertEqual(b.miners.count, 1)
    XCTAssertEqual(b.miners[0].starts, 1)
    let first = try status(h)["sessionId"] as? String
    let _: Void = try call { h.stop(completion: $0) }
    try start(h)
    XCTAssertEqual(b.miners.count, 2)
    XCTAssertNotEqual(try status(h)["sessionId"] as? String, first)
  }

  func testBackgroundPauseResumesSameCountersAndExcludesSuspendedTime() throws {
    var now: TimeInterval = 0
    let b = FakeBackend(); let h = MobileVerifyMinerHost(backend: b, clock: { now })
    try start(h)
    let first = try status(h)["sessionId"] as? String
    now = 10; active(h, false)
    now = 100
    let paused = try status(h)
    XCTAssertEqual(paused["running"] as? Bool, false)
    XCTAssertEqual(paused["pausedForBackground"] as? Bool, true)
    XCTAssertEqual(paused["activeDurationMs"] as? Int, 10000)
    active(h, true)
    now = 105
    let resumed = try status(h)
    XCTAssertEqual(resumed["activeDurationMs"] as? Int, 15000)
    XCTAssertEqual(resumed["sessionId"] as? String, first)
    XCTAssertEqual(resumed["verified"] as? Int, 12)
    XCTAssertEqual(b.miners.count, 1)
    XCTAssertEqual(b.miners[0].starts, 2)
  }

  func testManualStopWhileBackgroundedPreventsAutomaticResume() throws {
    let b = FakeBackend(); let h = MobileVerifyMinerHost(backend: b)
    try start(h); active(h, false)
    let _: Void = try call { h.stop(completion: $0) }
    active(h, true)
    XCTAssertEqual(b.miners[0].starts, 1)
    XCTAssertEqual(try status(h)["pausedForBackground"] as? Bool, false)
    XCTAssertEqual(try status(h)["running"] as? Bool, false)
  }

  func testStartWhileBackgroundedWaitsForForeground() throws {
    let b = FakeBackend(); let h = MobileVerifyMinerHost(backend: b, applicationActive: false)
    try start(h)
    XCTAssertEqual(b.miners[0].starts, 0)
    XCTAssertEqual(try status(h)["pausedForBackground"] as? Bool, true)
    active(h, true)
    XCTAssertEqual(b.miners[0].starts, 1)
  }

  func testFailedReplacementDoesNotStopWorkingMiner() throws {
    let b = FakeBackend(); let h = MobileVerifyMinerHost(backend: b)
    try start(h); b.fail = true
    XCTAssertThrowsError(try start(h, url: "http://another"))
    XCTAssertTrue(b.miners[0].running)
    XCTAssertEqual(b.miners[0].stops, 0)
  }

  func testStopFreezesActiveDuration() throws {
    var now: TimeInterval = 0
    let b = FakeBackend(); let h = MobileVerifyMinerHost(backend: b, clock: { now })
    try start(h); now = 7
    let _: Void = try call { h.stop(completion: $0) }
    now = 70
    XCTAssertEqual(try status(h)["activeDurationMs"] as? Int, 7000)
  }

  func testSessionDispatchAndNoSessionError() throws {
    let b = FakeBackend(); let h = MobileVerifySessionHost(backend: b)
    XCTAssertThrowsError(try call { h.perform({ try $0.latest() }, completion: $0) } as String)
    let key: String = try call { h.generateKey(completion: $0) }
    XCTAssertEqual(key, "private-test-fixture")
    let publicKey: String = try call { h.open(baseURL: "http://node", privateKey: key, chain: "chain", completion: $0) }
    XCTAssertEqual(publicKey, "public-device")
    let registered: String = try call { h.perform({ try $0.register() }, completion: $0) }
    XCTAssertEqual(registered, "registration")
    let block: String = try call { h.perform({ try $0.verifyBlock("hash") }, completion: $0) }
    XCTAssertEqual(block, "verified-hash")
    h.close()
    XCTAssertTrue(b.sessions[0].closed)
  }

  func testCloseCancelsBlockingRequestWithoutWaitingOnWorkerQueue() throws {
    let b = FakeBackend(); let h = MobileVerifySessionHost(backend: b)
    let _: String = try call { h.open(baseURL: "http://node", privateKey: "fixture", chain: "chain", completion: $0) }
    let entered = DispatchSemaphore(value: 0), released = DispatchSemaphore(value: 0)
    b.sessions[0].latestAction = {
      entered.signal()
      guard released.wait(timeout: .now() + 2) == .success else { throw FakeError.failed }
      throw MobileVerifyBridgeError.cancelled
    }
    b.sessions[0].closeAction = { released.signal() }
    let done = expectation(description: "cancelled request")
    h.perform({ try $0.latest() }) { result in
      if case .success = result { XCTFail("request succeeded after cancellation") }
      done.fulfill()
    }
    XCTAssertEqual(entered.wait(timeout: .now() + 2), .success)
    h.close()
    wait(for: [done], timeout: 3)
  }

  func testCloseDuringOpenClosesTheNewlyCreatedHandle() throws {
    let b = FakeBackend(); let h = MobileVerifySessionHost(backend: b)
    let entered = DispatchSemaphore(value: 0), released = DispatchSemaphore(value: 0)
    b.sessionAction = { entered.signal(); _ = released.wait(timeout: .now() + 2) }
    let done = expectation(description: "cancelled open")
    h.open(baseURL: "http://node", privateKey: "fixture", chain: "chain") { result in
      if case .success = result { XCTFail("cancelled Open installed a session") }
      done.fulfill()
    }
    XCTAssertEqual(entered.wait(timeout: .now() + 2), .success)
    h.close(); released.signal()
    wait(for: [done], timeout: 3)
    XCTAssertTrue(try XCTUnwrap(b.sessions.first).closed)
  }
}

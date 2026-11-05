// Component runner for the unchanged production XCTest method bodies.
var failures = 0
func recordFailure(_ message: String) { failures += 1; if failures <= 10 { print("FAIL: " + message) } }
func XCTAssertTrue(_ value: Bool, _ message: String = "", line: Int = #line) { if !value { recordFailure("assert true line \(line): \(message)") } }
func XCTAssertFalse(_ value: Bool, _ message: String = "", line: Int = #line) { if value { recordFailure("assert false line \(line): \(message)") } }
func XCTAssertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "", line: Int = #line) { if a != b { recordFailure("assert equal line \(line): \(message)") } }
func XCTAssertNil<T>(_ value: T?, _ message: String = "", line: Int = #line) { if value != nil { recordFailure("assert nil line \(line): \(message)") } }
enum HarnessError: Error { case unexpectedNil }
func XCTUnwrap<T>(_ value: T?) throws -> T { guard let value = value else { throw HarnessError.unexpectedNil }; return value }
@main struct Main {
 static func main() {
  let suite = SolanaRawSigningTests()
  let cases: [(String, () throws -> Void)] = [
    ("legacy/v0 signatures", suite.testLegacyAndV0PreserveMessageAndOtherSignatures),
    ("malformed and unauthorized inputs", suite.testNonSignerAndMalformedInputsReturnNil),
    ("ordinary SOL/SPL", suite.testOrdinarySolAndSplTransfersRemainUsable),
    ("BIP-39 addresses and scrypt keystore safety", verifyWalletCoreUpgrade)]
  for (name, run) in cases { let before = failures; do { try run() } catch { recordFailure("\(name): \(error)") }; print("\(name): \(before == failures ? "PASS" : "FAIL")") }
  print("native failures: \(failures)")
  if failures != 0 { exit(1) }
 }
}

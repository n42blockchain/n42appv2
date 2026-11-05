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

// Exercise the production WalletCore bridge, with independent CryptoKit checks.
import WalletCore
import CryptoKit

final class SolanaRawSigningTests: XCTestCase {
  private let seedA = Data(repeating: 1, count: 32)
  private let seedB = Data(repeating: 2, count: 32)

  private func message(v0: Bool) throws -> Data {
    let a = try Curve25519.Signing.PrivateKey(rawRepresentation: seedA)
    let b = try Curve25519.Signing.PrivateKey(rawRepresentation: seedB)
    var bytes = v0 ? [UInt8(0x80)] : []
    bytes += [2, v0 ? 1 : 0, 1, 3]
    bytes += a.publicKey.rawRepresentation + b.publicKey.rawRepresentation + Data(repeating: 0, count: 32)
    bytes += Data(repeating: 9, count: 32)
    // System transfer of one lamport. v0 uses a writable ALT recipient.
    bytes += [1, 2, 2, 0, v0 ? 3 : 1, 12, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]
    if v0 { bytes += [1] + [UInt8](repeating: 7, count: 32) + [1, 0, 0] }
    return Data(bytes)
  }

  private func call(_ transaction: Data, seed: Data, encoding: String = "base64") -> Data? {
    guard let key = PrivateKey(data: seed),
          let encoded = WalletCorePlugin().signSolanaTransaction(wallet: nil, path: "", txData: [
            "type": "WC_SOL", "transaction": transaction.base64EncodedString(), "encodeType": encoding
          ], pk: key) else { return nil }
    return Data(base64Encoded: encoded)
  }

  func testLegacyAndV0PreserveMessageAndOtherSignatures() throws {
    for v0 in [false, true] {
      for ownSlot in [0, 1] {
        let body = try message(v0: v0)
        let keyA = try Curve25519.Signing.PrivateKey(rawRepresentation: seedA)
        let keyB = try Curve25519.Signing.PrivateKey(rawRepresentation: seedB)
        let signatureA = try keyA.signature(for: body)
        let signatureB = try keyB.signature(for: body)
        let zero = Data(repeating: 0, count: 64)
        let input = Data([2]) + (ownSlot == 0 ? zero : signatureA) + (ownSlot == 1 ? zero : signatureB) + body
        let output = try XCTUnwrap(call(input, seed: ownSlot == 0 ? seedA : seedB))
        XCTAssertEqual(output.subdata(in: 129..<output.count), body)
        // Other signatures must be byte-identical. For our own slot, verify
        // cryptographically rather than requiring identical signer nonce bytes.
        if ownSlot != 0 { XCTAssertEqual(output.subdata(in: 1..<65), signatureA) }
        if ownSlot != 1 { XCTAssertEqual(output.subdata(in: 65..<129), signatureB) }
        XCTAssertTrue(keyA.publicKey.isValidSignature(output.subdata(in: 1..<65), for: body))
        XCTAssertTrue(keyB.publicKey.isValidSignature(output.subdata(in: 65..<129), for: body))
        let resigned = try XCTUnwrap(call(output, seed: ownSlot == 0 ? seedA : seedB))
        XCTAssertEqual(resigned.subdata(in: 129..<resigned.count), body)
      }
    }
  }

  func testNonSignerAndMalformedInputsReturnNil() throws {
    for v0 in [false, true] {
      let body = try message(v0: v0)
      let input = Data([2]) + Data(repeating: 0, count: 128) + body
      XCTAssertNil(call(input, seed: Data(repeating: 3, count: 32)))
      XCTAssertNil(call(input, seed: seedA, encoding: "base58"))
      for length in 0..<input.count {
        XCTAssertNil(call(Data(input.prefix(length)), seed: seedA), "prefix \(length), v0=\(v0)")
      }
      XCTAssertNil(call(input + Data([0]), seed: seedA))
      var countMismatch = input; countMismatch[129 + (v0 ? 1 : 0)] = 3
      XCTAssertNil(call(countMismatch, seed: seedA))
      let nonCanonical = Data([0x82, 0]) + input.dropFirst()
      XCTAssertNil(call(nonCanonical, seed: seedA))
      let header = 129 + (v0 ? 1 : 0)
      let instruction = header + 3 + 1 + 96 + 32 + 1
      for (offset, value) in [(header + 1, UInt8(2)), (header + 2, UInt8(2)),
                              (instruction, UInt8(255)), (instruction + 3, UInt8(255))] {
        var invalid = input; invalid[offset] = value
        XCTAssertNil(call(invalid, seed: seedA))
      }
    }
    let plugin = WalletCorePlugin()
    let key = try XCTUnwrap(PrivateKey(data: seedA))
    for transaction in ["", "!!!", String(repeating: "A", count: 90_001)] {
      XCTAssertNil(plugin.signSolanaTransaction(wallet: nil, path: "", txData: ["type": "WC_SOL", "transaction": transaction, "encodeType": "base64"], pk: key))
    }
    XCTAssertNil(plugin.signSolanaTransaction(wallet: nil, path: "", txData: ["type": "WC_SOL"], pk: key))
  }

  func testOrdinarySolAndSplTransfersRemainUsable() throws {
    let plugin = WalletCorePlugin()
    let key = try XCTUnwrap(PrivateKey(data: seedA))
    let sender = CoinType.solana.deriveAddress(privateKey: key)
    let recipient = CoinType.solana.deriveAddress(privateKey: try XCTUnwrap(PrivateKey(data: seedB)))
    let blockhash = Base58.encodeNoCheck(data: Data(repeating: 9, count: 32))
    let transfer: [String: Any] = ["type": "transfer", "encodeType": "base58", "recentBlockhash": blockhash,
      "transferTransaction": ["recipient": recipient, "value": "1"]]
    XCTAssertFalse(try XCTUnwrap(plugin.signSolanaTransaction(wallet: nil, path: "", txData: transfer, pk: key)).isEmpty)
    let token: [String: Any] = ["type": "token", "encodeType": "base58", "recentBlockhash": blockhash,
      "tokenTransferTransaction": ["recipientMainAddress": recipient, "senderTokenAddress": sender,
        "tokenMintAddress": "So11111111111111111111111111111111111111112", "amount": "1", "decimals": "9"]]
    XCTAssertFalse(try XCTUnwrap(plugin.signSolanaTransaction(wallet: nil, path: "", txData: token, pk: key)).isEmpty)
    let mint = "So11111111111111111111111111111111111111112"
    let associated = try XCTUnwrap(SolanaAddress(string: recipient)?.defaultTokenAddress(tokenMintAddress: mint))
    for account in ["", associated] {
      let create: [String: Any] = ["type": "tokenCreate", "encodeType": "base58", "recentBlockhash": blockhash,
        "tokenTransferTransaction": ["recipientTokenAddress": account, "recipientMainAddress": recipient,
          "senderTokenAddress": sender, "tokenMintAddress": mint, "amount": "1", "decimals": "9"]]
      XCTAssertFalse(try XCTUnwrap(plugin.signSolanaTransaction(wallet: nil, path: "", txData: create, pk: key)).isEmpty)
    }
  }
}

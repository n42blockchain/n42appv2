import Flutter
import UIKit

final class N42MlsHandler {
  private static let channelName = "n42.chat/mls"

  private let channel: FlutterMethodChannel
  private var engine: OpaquePointer?

  init(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  deinit {
    if let engine {
      n42_mls_engine_free(engine)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      switch call.method {
      case "isBound":
        result(ensureEngine() != nil)
      case "generateKeyPackage":
        var out = emptyBuf()
        guard n42_mls_generate_key_package(try requiredEngine(), &out) == 0 else {
          throw MlsError.operation("generateKeyPackage failed")
        }
        result(typedData(taking: out))
      case "createGroup":
        let groupId = try requiredStringArg(call, "groupId")
        let engine = try requiredEngine()
        let status = groupIdData(groupId).withUnsafeBytes { rawBuffer in
          n42_mls_create_group(
            engine,
            rawBuffer.bindMemory(to: UInt8.self).baseAddress,
            rawBuffer.count
          )
        }
        guard status == 0 else { throw MlsError.status("createGroup", status) }
        result(FlutterStandardTypedData(bytes: Data()))
      case "addMembers", "addMember":
        try handleAddMembers(call, result: result)
      case "removeMembers", "removeMember":
        try handleRemoveMembers(call, result: result)
      case "processCommit":
        let groupId = try requiredStringArg(call, "groupId")
        let commit = try requiredDataArg(call, "commit")
        let engine = try requiredEngine()
        let status = groupIdData(groupId).withUnsafeBytes { gidBuffer in
          commit.withUnsafeBytes { commitBuffer in
            n42_mls_process_commit(
              engine,
              gidBuffer.bindMemory(to: UInt8.self).baseAddress,
              gidBuffer.count,
              commitBuffer.bindMemory(to: UInt8.self).baseAddress,
              commitBuffer.count
            )
          }
        }
        guard status == 0 else { throw MlsError.status("processCommit", status) }
        result(nil)
      case "processWelcome":
        let welcome = try requiredDataArg(call, "welcome")
        let engine = try requiredEngine()
        var outGid = emptyBuf()
        let status = welcome.withUnsafeBytes { welcomeBuffer in
          n42_mls_process_welcome(
            engine,
            welcomeBuffer.bindMemory(to: UInt8.self).baseAddress,
            welcomeBuffer.count,
            &outGid
          )
        }
        guard status == 0 else { throw MlsError.status("processWelcome", status) }
        let groupIdData = data(taking: outGid)
        let groupId = String(data: groupIdData, encoding: .utf8) ?? ""
        result([
          "groupId": groupId,
          "state": FlutterStandardTypedData(bytes: Data()),
        ])
      case "encrypt":
        try handleCrypt(call, result: result, decrypt: false)
      case "decrypt":
        try handleCrypt(call, result: result, decrypt: true)
      case "selfUpdate":
        let groupId = try requiredStringArg(call, "groupId")
        let engine = try requiredEngine()
        var out = emptyBuf()
        let status = groupIdData(groupId).withUnsafeBytes { gidBuffer in
          n42_mls_self_update(
            engine,
            gidBuffer.bindMemory(to: UInt8.self).baseAddress,
            gidBuffer.count,
            &out
          )
        }
        guard status == 0 else { throw MlsError.status("selfUpdate", status) }
        result(typedData(taking: out))
      default:
        result(FlutterMethodNotImplemented)
      }
    } catch let error as MlsError {
      result(error.flutterError)
    } catch {
      result(FlutterError(code: "MLS_ERROR", message: "\(error)", details: nil))
    }
  }

  private func handleAddMembers(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) throws {
    let groupId = try requiredStringArg(call, "groupId")
    let keyPackage = try firstKeyPackage(call)
    let engine = try requiredEngine()
    var commit = emptyBuf()
    var welcome = emptyBuf()
    let status = groupIdData(groupId).withUnsafeBytes { gidBuffer in
      keyPackage.withUnsafeBytes { kpBuffer in
        n42_mls_add_member(
          engine,
          gidBuffer.bindMemory(to: UInt8.self).baseAddress,
          gidBuffer.count,
          kpBuffer.bindMemory(to: UInt8.self).baseAddress,
          kpBuffer.count,
          &commit,
          &welcome
        )
      }
    }
    guard status == 0 else { throw MlsError.status("addMembers", status) }
    result([
      "commit": typedData(taking: commit),
      "welcome": typedData(taking: welcome),
    ])
  }

  private func handleRemoveMembers(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) throws {
    let groupId = try requiredStringArg(call, "groupId")
    let leafIndex = try firstLeafIndex(call)
    let engine = try requiredEngine()
    var out = emptyBuf()
    let status = groupIdData(groupId).withUnsafeBytes { gidBuffer in
      n42_mls_remove_member(
        engine,
        gidBuffer.bindMemory(to: UInt8.self).baseAddress,
        gidBuffer.count,
        leafIndex,
        &out
      )
    }
    guard status == 0 else { throw MlsError.status("removeMembers", status) }
    result(typedData(taking: out))
  }

  private func handleCrypt(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult,
    decrypt: Bool
  ) throws {
    let groupId = try requiredStringArg(call, "groupId")
    let payload = try requiredDataArg(call, decrypt ? "ciphertext" : "plaintext")
    let engine = try requiredEngine()
    var out = emptyBuf()
    let status = groupIdData(groupId).withUnsafeBytes { gidBuffer in
      payload.withUnsafeBytes { payloadBuffer in
        if decrypt {
          return n42_mls_decrypt(
            engine,
            gidBuffer.bindMemory(to: UInt8.self).baseAddress,
            gidBuffer.count,
            payloadBuffer.bindMemory(to: UInt8.self).baseAddress,
            payloadBuffer.count,
            &out
          )
        }
        return n42_mls_encrypt(
          engine,
          gidBuffer.bindMemory(to: UInt8.self).baseAddress,
          gidBuffer.count,
          payloadBuffer.bindMemory(to: UInt8.self).baseAddress,
          payloadBuffer.count,
          &out
        )
      }
    }
    guard status == 0 else {
      throw MlsError.status(decrypt ? "decrypt" : "encrypt", status)
    }
    result(typedData(taking: out))
  }

  private func ensureEngine() -> OpaquePointer? {
    if let engine {
      return engine
    }
    let identity = "ios:\(UIDevice.current.identifierForVendor?.uuidString ?? Bundle.main.bundleIdentifier ?? "n42")"
    let identityData = Data(identity.utf8)
    engine = identityData.withUnsafeBytes { rawBuffer in
      n42_mls_engine_new(
        rawBuffer.bindMemory(to: UInt8.self).baseAddress,
        rawBuffer.count
      )
    }
    return engine
  }

  private func requiredEngine() throws -> OpaquePointer {
    guard let engine = ensureEngine() else {
      throw MlsError.operation("OpenMLS native engine is unavailable")
    }
    return engine
  }

  private func arguments(_ call: FlutterMethodCall) throws -> [String: Any] {
    guard let args = call.arguments as? [String: Any] else {
      throw MlsError.invalidArgs("\(call.method) expects map arguments")
    }
    return args
  }

  private func requiredStringArg(_ call: FlutterMethodCall, _ key: String) throws -> String {
    guard let value = try arguments(call)[key] as? String, !value.isEmpty else {
      throw MlsError.invalidArgs("\(key) is required")
    }
    return value
  }

  private func requiredDataArg(_ call: FlutterMethodCall, _ key: String) throws -> Data {
    guard let data = dataValue(try arguments(call)[key]) else {
      throw MlsError.invalidArgs("\(key) is required")
    }
    return data
  }

  private func firstKeyPackage(_ call: FlutterMethodCall) throws -> Data {
    let args = try arguments(call)
    if let data = dataValue(args["keyPackage"]) {
      return data
    }
    guard let values = args["keyPackages"] as? [Any], values.count == 1,
          let data = dataValue(values.first) else {
      throw MlsError.invalidArgs(
        "current OpenMLS mobile ABI supports exactly one key package per addMembers call"
      )
    }
    return data
  }

  private func firstLeafIndex(_ call: FlutterMethodCall) throws -> UInt32 {
    let args = try arguments(call)
    if let value = args["memberId"] {
      return try parseLeafIndex(value)
    }
    guard let values = args["memberIds"] as? [Any], values.count == 1,
          let value = values.first else {
      throw MlsError.invalidArgs(
        "current OpenMLS mobile ABI supports exactly one member removal per call"
      )
    }
    return try parseLeafIndex(value)
  }

  private func parseLeafIndex(_ value: Any) throws -> UInt32 {
    if let value = value as? UInt32 {
      return value
    }
    if let value = value as? Int, value >= 0 {
      return UInt32(value)
    }
    if let value = value as? String, let parsed = UInt32(value) {
      return parsed
    }
    throw MlsError.invalidArgs("member id must be a non-negative numeric leaf index")
  }

  private func dataValue(_ value: Any?) -> Data? {
    if let typed = value as? FlutterStandardTypedData {
      return typed.data
    }
    if let data = value as? Data {
      return data
    }
    if let bytes = value as? [UInt8] {
      return Data(bytes)
    }
    return nil
  }

  private func groupIdData(_ groupId: String) -> Data {
    Data(groupId.utf8)
  }

  private func emptyBuf() -> N42Buf {
    N42Buf(ptr: nil, len: 0)
  }

  private func typedData(taking buf: N42Buf) -> FlutterStandardTypedData {
    FlutterStandardTypedData(bytes: data(taking: buf))
  }

  private func data(taking buf: N42Buf) -> Data {
    defer { n42_mls_buf_free(buf) }
    guard let ptr = buf.ptr, buf.len > 0 else {
      return Data()
    }
    return Data(bytes: ptr, count: buf.len)
  }

  private enum MlsError: Error {
    case invalidArgs(String)
    case operation(String)
    case status(String, Int32)

    var flutterError: FlutterError {
      switch self {
      case .invalidArgs(let message):
        return FlutterError(code: "INVALID_ARGS", message: message, details: nil)
      case .operation(let message):
        return FlutterError(code: "MLS_ERROR", message: message, details: nil)
      case .status(let operation, let status):
        return FlutterError(
          code: "MLS_ERROR",
          message: "\(operation) failed with status \(status)",
          details: status
        )
      }
    }
  }
}

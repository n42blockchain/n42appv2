// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.

import Flutter
import AuthenticationServices
import Foundation

/// iOS Passkey handler using ASAuthorizationController.
///
/// Bridges Flutter MethodChannel "n42.wallet/passkey" to the iOS
/// AuthenticationServices framework for WebAuthn Passkey operations.
///
/// Requires:
/// - iOS 16.0+ / macOS 13.0+
/// - Associated Domains entitlement: webcredentials:<rpId>
/// - `.well-known/apple-app-site-association` on rpId domain
@available(iOS 16.0, *)
class PasskeyHandler: NSObject, FlutterPlugin {
    private var pendingResult: FlutterResult?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "n42.wallet/passkey",
            binaryMessenger: registrar.messenger()
        )
        let instance = PasskeyHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isSupported":
            result(true)
        case "register":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Arguments required", details: nil))
                return
            }
            handleRegister(args: args, result: result)
        case "authenticate":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Arguments required", details: nil))
                return
            }
            handleAuthenticate(args: args, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Registration

    private func handleRegister(args: [String: Any], result: @escaping FlutterResult) {
        guard let rpId = args["rpId"] as? String,
              let userId = args["userId"] as? String,
              let userName = args["userName"] as? String,
              let challenge = args["challenge"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
            return
        }

        guard let challengeData = Data(base64URLEncoded: challenge) else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid challenge encoding", details: nil))
            return
        }

        guard let userIdData = userId.data(using: .utf8) else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid userId encoding", details: nil))
            return
        }

        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let request = provider.createCredentialRegistrationRequest(
            challenge: challengeData,
            name: userName,
            userID: userIdData
        )

        // Configure attestation preference
        if #available(iOS 17.0, *) {
            // attestation configuration available in newer versions
        }

        // Exclude existing credentials
        if let excludeIds = args["excludeCredentialIds"] as? [String] {
            let excludeDescriptors = excludeIds.compactMap { id -> ASAuthorizationPlatformPublicKeyCredentialDescriptor? in
                guard let data = Data(base64URLEncoded: id) else { return nil }
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: data)
            }
            request.excludedCredentials = excludeDescriptors
        }

        pendingResult = result
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - Authentication

    private func handleAuthenticate(args: [String: Any], result: @escaping FlutterResult) {
        guard let rpId = args["rpId"] as? String,
              let challenge = args["challenge"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
            return
        }

        guard let challengeData = Data(base64URLEncoded: challenge) else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid challenge encoding", details: nil))
            return
        }

        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)

        // Restrict to specific credentials
        if let allowIds = args["allowCredentialIds"] as? [String], !allowIds.isEmpty {
            let allowDescriptors = allowIds.compactMap { id -> ASAuthorizationPlatformPublicKeyCredentialDescriptor? in
                guard let data = Data(base64URLEncoded: id) else { return nil }
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: data)
            }
            request.allowedCredentials = allowDescriptors
        }

        pendingResult = result
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - Helpers

    /// Parse DER-encoded ECDSA signature into (r, s) hex strings.
    private func parseDerSignature(_ data: Data) -> (String, String)? {
        let bytes = [UInt8](data)
        guard bytes.count > 2, bytes[0] == 0x30 else { return nil }

        var offset = 2

        // Parse r
        guard offset < bytes.count, bytes[offset] == 0x02 else { return nil }
        offset += 1
        let rLen = Int(bytes[offset])
        offset += 1
        let rBytes = Array(bytes[offset..<(offset + rLen)])
        offset += rLen

        // Parse s
        guard offset < bytes.count, bytes[offset] == 0x02 else { return nil }
        offset += 1
        let sLen = Int(bytes[offset])
        offset += 1
        let sBytes = Array(bytes[offset..<(offset + sLen)])

        // Convert to big-endian hex, stripping leading zero if present
        let r = bigIntHex(rBytes)
        let s = bigIntHex(sBytes)

        // Normalize s to low-S form
        let normalizedS = normalizeSigS(s)

        return (r, normalizedS)
    }

    private func bigIntHex(_ bytes: [UInt8]) -> String {
        // Strip leading zero byte (DER positive integer encoding)
        let stripped = bytes.first == 0 ? Array(bytes.dropFirst()) : bytes
        let hex = stripped.map { String(format: "%02x", $0) }.joined()
        return hex.count < 64 ? String(repeating: "0", count: 64 - hex.count) + hex : hex
    }

    /// Normalize s to low-S form for P-256 curve.
    private func normalizeSigS(_ sHex: String) -> String {
        // P-256 curve order
        let n = "ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551"
        // half order
        let halfN = "7fffffff800000007fffffffffffffffde7375d6d53bcf4279dce5617e3192a8"

        if sHex > halfN {
            // s = n - s
            var borrow = 0
            var result = Array(repeating: Character("0"), count: 64)
            let nChars = Array(n)
            let sChars = Array(sHex.count < 64 ? String(repeating: "0", count: 64 - sHex.count) + sHex : sHex)

            for i in stride(from: 63, through: 0, by: -1) {
                let nVal = Int(String(nChars[i]), radix: 16)!
                let sVal = Int(String(sChars[i]), radix: 16)!
                var diff = nVal - sVal - borrow
                if diff < 0 {
                    diff += 16
                    borrow = 1
                } else {
                    borrow = 0
                }
                result[i] = Character(String(diff, radix: 16))
            }
            return String(result)
        }
        return sHex
    }

    /// Extract P-256 public key coordinates from raw public key data.
    /// Expects uncompressed format: 0x04 || x (32 bytes) || y (32 bytes).
    private func extractPublicKeyCoordinates(_ pubKeyData: Data) -> (String, String)? {
        let bytes = [UInt8](pubKeyData)
        // ANSI X9.62 uncompressed point format
        if bytes.count == 65 && bytes[0] == 0x04 {
            let x = bytes[1...32].map { String(format: "%02x", $0) }.joined()
            let y = bytes[33...64].map { String(format: "%02x", $0) }.joined()
            return (x, y)
        }
        // Some platforms may return raw 64-byte key without prefix
        if bytes.count == 64 {
            let x = bytes[0..<32].map { String(format: "%02x", $0) }.joined()
            let y = bytes[32..<64].map { String(format: "%02x", $0) }.joined()
            return (x, y)
        }
        return nil
    }
}

// MARK: - ASAuthorizationControllerDelegate

@available(iOS 16.0, *)
extension PasskeyHandler: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let result = pendingResult else { return }
        pendingResult = nil

        if let registration = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            // Registration response
            let credentialId = registration.credentialID.base64URLEncodedString()
            let clientDataJSON = registration.rawClientDataJSON.base64URLEncodedString()
            let attestationObject = registration.rawAttestationObject?.base64URLEncodedString() ?? ""

            // Extract public key coordinates
            var pubKeyX = String(repeating: "0", count: 64)
            var pubKeyY = String(repeating: "0", count: 64)

            // On iOS 16.6+, the large blob or supplementary data may contain the public key.
            // The primary way is to parse the attestation object (CBOR).
            // For simplicity, we extract from the raw attestation object's authData.
            if let attestData = registration.rawAttestationObject {
                if let coords = extractPublicKeyFromAuthData(attestData) {
                    pubKeyX = coords.0
                    pubKeyY = coords.1
                }
            }

            let response: [String: Any?] = [
                "credentialId": credentialId,
                "clientDataJSON": clientDataJSON,
                "attestationObject": attestationObject,
                "publicKeyX": pubKeyX,
                "publicKeyY": pubKeyY,
                "backedUp": false,
            ]
            result(response)

        } else if let assertion = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            // Authentication response
            let credentialId = assertion.credentialID.base64URLEncodedString()
            let authData = assertion.rawAuthenticatorData.base64URLEncodedString()
            let clientDataJSON = assertion.rawClientDataJSON.base64URLEncodedString()

            // Parse DER signature
            guard let (sigR, sigS) = parseDerSignature(assertion.signature) else {
                result(FlutterError(code: "SIGNATURE_ERROR", message: "Failed to parse signature", details: nil))
                return
            }

            let response: [String: Any?] = [
                "credentialId": credentialId,
                "authenticatorData": authData,
                "clientDataJSON": clientDataJSON,
                "signatureR": sigR,
                "signatureS": sigS,
            ]
            result(response)
        } else {
            result(FlutterError(code: "UNKNOWN", message: "Unknown credential type", details: nil))
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        guard let result = pendingResult else { return }
        pendingResult = nil

        let nsError = error as NSError
        if nsError.domain == ASAuthorizationError.errorDomain {
            switch ASAuthorizationError.Code(rawValue: nsError.code) {
            case .canceled:
                result(FlutterError(code: "CANCELLED", message: "User cancelled", details: nil))
            case .invalidResponse:
                result(FlutterError(code: "INVALID_RESPONSE", message: "Invalid response", details: nil))
            case .notHandled:
                result(FlutterError(code: "NOT_HANDLED", message: "Not handled", details: nil))
            case .failed:
                result(FlutterError(code: "FAILED", message: error.localizedDescription, details: nil))
            case .notInteractive:
                result(FlutterError(code: "NOT_INTERACTIVE", message: "Not interactive", details: nil))
            default:
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
            }
        } else {
            result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
        }
    }

    /// Extract P-256 public key from CBOR attestation object's authData.
    ///
    /// authData layout:
    ///   rpIdHash (32) | flags (1) | signCount (4) | attestedCredData (variable)
    ///   attestedCredData: aaguid (16) | credIdLen (2) | credId (credIdLen) | pubKeyCOSE (variable)
    private func extractPublicKeyFromAuthData(_ attestationObject: Data) -> (String, String)? {
        // Simplified CBOR parsing for attestation object to find authData
        // A full implementation should use a CBOR library
        // For now, search for the authData field by looking for known patterns
        let bytes = [UInt8](attestationObject)

        // Find authData in CBOR map - look for "authData" key
        guard let authDataRange = findCBORByteString(bytes, key: "authData") else {
            return nil
        }

        let authData = Array(bytes[authDataRange])
        guard authData.count > 37 else { return nil }

        let flags = authData[32]
        let hasAttestedCredData = (flags & 0x40) != 0
        guard hasAttestedCredData else { return nil }

        // Skip rpIdHash (32) + flags (1) + signCount (4) = 37
        var offset = 37
        // Skip aaguid (16)
        offset += 16
        guard offset + 2 <= authData.count else { return nil }

        // credIdLen (big-endian uint16)
        let credIdLen = Int(authData[offset]) << 8 | Int(authData[offset + 1])
        offset += 2

        // Skip credId
        offset += credIdLen
        guard offset < authData.count else { return nil }

        // Remaining bytes are COSE public key (CBOR map)
        // For ES256: {1: 2, 3: -7, -1: 1, -2: x, -3: y}
        let coseKey = Array(authData[offset...])
        return extractP256FromCOSE(coseKey)
    }

    /// Simple CBOR map search for a byte string value with given text key.
    private func findCBORByteString(_ bytes: [UInt8], key: String) -> Range<Int>? {
        let keyData = [UInt8](key.utf8)
        // Search for the key string in the CBOR data
        for i in 0..<(bytes.count - keyData.count) {
            if Array(bytes[i..<(i + keyData.count)]) == keyData {
                // Found key, look for the following byte string
                var pos = i + keyData.count
                if pos < bytes.count {
                    let major = bytes[pos] >> 5
                    if major == 2 { // byte string
                        let info = bytes[pos] & 0x1f
                        pos += 1
                        var length = 0
                        if info < 24 {
                            length = Int(info)
                        } else if info == 24 {
                            length = Int(bytes[pos])
                            pos += 1
                        } else if info == 25 {
                            length = Int(bytes[pos]) << 8 | Int(bytes[pos + 1])
                            pos += 2
                        }
                        if length > 0 && pos + length <= bytes.count {
                            return pos..<(pos + length)
                        }
                    }
                }
            }
        }
        return nil
    }

    /// Extract P-256 x, y from a COSE key encoded as CBOR map.
    private func extractP256FromCOSE(_ cose: [UInt8]) -> (String, String)? {
        // Simplified: look for 32-byte values after COSE key markers
        // -2 (0x21 in CBOR negative int) -> x coordinate
        // -3 (0x22 in CBOR negative int) -> y coordinate
        var x: String?
        var y: String?

        for i in 0..<(cose.count - 33) {
            // CBOR negative integer -2 is encoded as 0x21
            if cose[i] == 0x21 {
                let next = cose[i + 1]
                let major = next >> 5
                if major == 2 { // byte string
                    let len = Int(next & 0x1f)
                    if len == 32 || (next & 0x1f) == 24 {
                        let start = (next & 0x1f) == 24 ? i + 3 : i + 2
                        let actualLen = (next & 0x1f) == 24 ? Int(cose[i + 2]) : len
                        if actualLen == 32 && start + 32 <= cose.count {
                            x = Array(cose[start..<(start + 32)])
                                .map { String(format: "%02x", $0) }.joined()
                        }
                    }
                }
            }
            // CBOR negative integer -3 is encoded as 0x22
            if cose[i] == 0x22 {
                let next = cose[i + 1]
                let major = next >> 5
                if major == 2 {
                    let len = Int(next & 0x1f)
                    if len == 32 || (next & 0x1f) == 24 {
                        let start = (next & 0x1f) == 24 ? i + 3 : i + 2
                        let actualLen = (next & 0x1f) == 24 ? Int(cose[i + 2]) : len
                        if actualLen == 32 && start + 32 <= cose.count {
                            y = Array(cose[start..<(start + 32)])
                                .map { String(format: "%02x", $0) }.joined()
                        }
                    }
                }
            }
        }

        if let x = x, let y = y {
            return (x, y)
        }
        return nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

@available(iOS 16.0, *)
extension PasskeyHandler: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

// MARK: - Data Extensions

extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    init?(base64URLEncoded string: String) {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 += "="
        }
        self.init(base64Encoded: base64)
    }
}

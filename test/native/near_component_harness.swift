import Foundation
import WalletCore
import CryptoKit

@main
struct NearComponentHarness {
    static func main() throws {
        // Public fixture only. No stored wallet or network access.
        let wallet = HDWallet(mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about", passphrase: "")!
        let path = "m/44'/397'/0'"
        let key = wallet.getKey(coin: .near, derivationPath: path)!
        let publicKey = key.getPublicKeyEd25519().data
        let implicit = CoinType.near.deriveAddress(privateKey: key)
        precondition(implicit == publicKey.map { String(format: "%02x", $0) }.joined())
        let plugin = WalletCorePlugin()
        let input: [String: Any] = [
            "signerId": "alice.near", "receiverId": "bob.near", "nonce": "4",
            "blockHash": String(repeating: "02", count: 32),
            "amount": "010000a1edccce1bc2d3000000000000"
        ]
        precondition(plugin.signNearTransaction(wallet: nil, path: path, txData: input, pk: nil) == nil)
        for field in ["signerId", "receiverId", "nonce", "blockHash", "amount"] {
            var missing = input; missing.removeValue(forKey: field)
            precondition(plugin.signNearTransaction(wallet: wallet, path: path, txData: missing, pk: nil) == nil)
            var wrong = input; wrong[field] = 123
            precondition(plugin.signNearTransaction(wallet: wallet, path: path, txData: wrong, pk: nil) == nil)
        }
        let signed = plugin.signNearTransaction(wallet: wallet, path: path, txData: input, pk: nil)!
        precondition(plugin.signNearTransaction(wallet: nil, path: path, txData: input, pk: key) == signed)
        let bytes = Array(Data(base64Encoded: signed)!)
        var offset = 0
        func take(_ count: Int) -> [UInt8] {
            precondition(count >= 0 && offset + count <= bytes.count, "offset=\(offset) requested=\(count) total=\(bytes.count)")
            defer { offset += count }
            return Array(bytes[offset..<offset+count])
        }
        func integer(_ size: Int) -> UInt64 {
            var value: UInt64 = 0
            for (i, byte) in take(size).enumerated() { value |= UInt64(byte) << (i * 8) }
            return value
        }
        func string() -> String { String(bytes: take(Int(integer(4))), encoding: .utf8)! }
        precondition(string() == "alice.near")
        precondition(integer(1) == 0)
        precondition(take(32) == Array(publicKey))
        precondition(integer(8) == 4)
        precondition(string() == "bob.near")
        precondition(take(32) == Array(repeating: 2, count: 32))
        precondition(integer(4) == 1) // one action
        precondition(integer(1) == 3) // Transfer Borsh variant
        precondition(take(16) == [1,0,0,161,237,204,206,27,194,211,0,0,0,0,0,0])
        let preimage = Data(bytes.prefix(offset))
        precondition(integer(1) == 0)
        let signature = Data(take(64))
        precondition(offset == bytes.count)
        let verifier = try Curve25519.Signing.PublicKey(rawRepresentation: publicKey)
        precondition(verifier.isValidSignature(signature, for: Data(SHA256.hash(data: preimage))))
        if CommandLine.arguments.count == 2 {
            let fixture: [String: Any] = ["signedTransaction": signed,
                "transactionHashHex": SHA256.hash(data: preimage).map { String(format: "%02x", $0) }.joined(),
                "source": "WalletCore 4.8.7 Swift bridge; independent CryptoKit SHA256 and Ed25519 verification"]
            try JSONSerialization.data(withJSONObject: fixture, options: [.prettyPrinted, .sortedKeys])
                .write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
        }
        print("NEAR native bridge: derivation, credentials, Borsh fields, exact amount and independent signature verification passed")
    }
}

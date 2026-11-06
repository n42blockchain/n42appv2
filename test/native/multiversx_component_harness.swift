import Foundation
import WalletCore

@main struct Main {
    static func main() throws {
        // Public test mnemonic; never used for a real account or network.
        let wallet = HDWallet(mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about", passphrase: "")!
        let path = "m/44'/508'/0'/0'/2'"
        let key = wallet.getKey(coin: .multiversX, derivationPath: path)!
        let sender = CoinType.multiversX.deriveAddress(privateKey: key)
        let recipient = CoinType.multiversX.deriveAddress(privateKey: wallet.getKey(coin: .multiversX, derivationPath: "m/44'/508'/0'/0'/3'")!)
        let plugin = WalletCorePlugin()
        var signatures: [String] = []
        var publicTransactions: [[String: Any]] = []
        var checks = 0
        func check(_ value: Bool, _ label: String) {
            precondition(value, label); checks += 1
        }
        for chain in ["1", "T", "D"] {
            let data: [String: Any] = ["toAddress": recipient, "amount": "10000000000000000000", "nonce": "0", "gasPrice": "1000000000", "gasLimit": "65000", "chainId": chain, "version": "1", "data": "你好🙂"]
            guard let signed = plugin.signMultiversXTransaction(wallet: wallet, path: path, txData: data, pk: nil) else { fatalError("Valid MultiversX transfer rejected") }
            let tx = try JSONSerialization.jsonObject(with: Data(signed.utf8)) as! [String: Any]
            check(tx["sender"] as? String == sender, "sender derivation")
            check(tx["receiver"] as? String == recipient, "recipient")
            check(tx["value"] as? String == "10000000000000000000", "exact large amount")
            check(tx["nonce"] as? Int == 0, "zero nonce")
            check(tx["gasLimit"] as? Int == 65000, "memo gas")
            check(tx["chainID"] as? String == chain, "network")
            check(tx["data"] as? String == Data("你好🙂".utf8).base64EncodedString(), "Unicode data")
            check(plugin.signMultiversXTransaction(wallet: nil, path: path, txData: data, pk: key) == signed, "explicit private key")
            check(plugin.signMultiversXTransaction(wallet: nil, path: path, txData: data, pk: nil) == nil, "missing key")
            check(plugin.signMultiversXTransaction(wallet: wallet, path: "m/44'/508'/0'/0'/4'", txData: data, pk: nil) != signed, "alternate derivation")
            for field in ["toAddress", "amount", "nonce", "gasPrice", "gasLimit", "chainId", "version"] {
                var missing = data; missing.removeValue(forKey: field)
                check(plugin.signMultiversXTransaction(wallet: wallet, path: path, txData: missing, pk: nil) == nil, "missing field")
            }
            var zero = data; zero["amount"] = "0"
            check(plugin.signMultiversXTransaction(wallet: wallet, path: path, txData: zero, pk: nil) != nil, "generic action zero value")
            var invalid = data; invalid["toAddress"] = "invalid"
            check(plugin.signMultiversXTransaction(wallet: wallet, path: path, txData: invalid, pk: nil) == nil, "invalid address")
            publicTransactions.append(tx)
            signatures.append(tx["signature"] as! String)
        }
        check(Set(signatures).count == 3, "network signatures differ")
        if CommandLine.arguments.count == 2 {
            let data = try JSONSerialization.data(withJSONObject: publicTransactions, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
        }
        print("MultiversX native signing: \(checks) checks passed")
    }
}

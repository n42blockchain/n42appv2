import Foundation
import WalletCore

@main struct Main {
    static func main() {
        // Public BIP39 fixture; no account or network access.
        let wallet = HDWallet(mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about", passphrase: "")!
        let path = "m/44'/148'/0'"
        let key = wallet.getKey(coin: .stellar, derivationPath: path)!
        let recipient = CoinType.stellar.deriveAddress(privateKey: wallet.getKey(coin: .stellar, derivationPath: "m/44'/148'/1'")!)
        let plugin = WalletCorePlugin()
        var signatures: [String] = []
        for network in ["Public Global Stellar Network ; September 2015", "Test SDF Network ; September 2015"] {
            let data: [String: Any] = ["toAddress": recipient, "amount": "12500000", "fee": "100", "sequence": "8", "memo": "invoice 42", "passphrase": network]
            let signed = plugin.signStellarTransaction(wallet: wallet, path: path, txData: data, pk: nil)!
            precondition(!signed.isEmpty && Data(base64Encoded: signed) != nil)
            let input = StellarSigningInput.with {
                $0.account = CoinType.stellar.deriveAddress(privateKey: key)
                $0.passphrase = network; $0.fee = 100; $0.sequence = 8; $0.privateKey = key.data
                $0.opPayment = StellarOperationPayment.with { $0.destination = recipient; $0.amount = 12500000 }
                $0.memoText = StellarMemoText.with { $0.text = "invoice 42" }
            }
            let expected: StellarSigningOutput = AnySigner.sign(input: input, coin: .stellar)
            precondition(signed == expected.signature)
            precondition(plugin.signStellarTransaction(wallet: nil, path: path, txData: data, pk: key) == signed)
            var invalid = data; invalid["toAddress"] = "invalid"
            precondition(plugin.signStellarTransaction(wallet: wallet, path: path, txData: invalid, pk: nil) == nil)
            for field in ["toAddress", "amount", "fee", "sequence"] {
                var missing = data; missing.removeValue(forKey: field)
                precondition(plugin.signStellarTransaction(wallet: wallet, path: path, txData: missing, pk: nil) == nil)
            }
            var overflow = data; overflow["fee"] = "2147483648"
            precondition(plugin.signStellarTransaction(wallet: wallet, path: path, txData: overflow, pk: nil) == nil)
            var memo = data; memo["memo"] = String(repeating: "😀", count: 8)
            precondition(plugin.signStellarTransaction(wallet: wallet, path: path, txData: memo, pk: nil) == nil)
            memo["memo"] = String(repeating: "😀", count: 7)
            precondition(!(plugin.signStellarTransaction(wallet: wallet, path: path, txData: memo, pk: nil) ?? "").isEmpty)
            signatures.append(signed)
        }
        precondition(signatures[0] != signatures[1], "Network domain must change the signature")
        print("Stellar native signing: 23 checks passed")
    }
}

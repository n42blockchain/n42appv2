import Foundation
import WalletCore

@main struct Main {
    static func main() {
        // Public BIP39 test mnemonic. No real wallet or network is used.
        let wallet = HDWallet(mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about", passphrase: "")!
        let path = "m/1852'/1815'/0'/0/0"
        let key = wallet.getKey(coin: .cardano, derivationPath: path)!
        let sender = CoinType.cardano.deriveAddress(privateKey: key)
        let recipient = CoinType.cardano.deriveAddress(privateKey: wallet.getKey(coin: .cardano, derivationPath: "m/1852'/1815'/0'/0/1")!)
        let hash = String(repeating: "ab", count: 32)
        let payload: [String: Any] = [
            "toAddress": recipient, "changeAddress": sender, "amount": "2000000", "ttl": "103600",
            "utxos": [["txHash": hash, "outputIndex": 0, "amount": "10000000", "address": sender]],
        ]
        let plugin = WalletCorePlugin()
        guard let signed = plugin.signCardanoTransaction(wallet: wallet, path: path, txData: payload, pk: nil) else {
            fatalError("Normalized ADA payload failed native signing")
        }
        let input = CardanoSigningInput.with {
            $0.ttl = 103600
            $0.privateKey = [key.data]
            $0.utxos = [CardanoTxInput.with {
                $0.outPoint = CardanoOutPoint.with { $0.txHash = Data(hexString: hash)!; $0.outputIndex = 0 }
                $0.address = sender
                $0.amount = 10000000
            }]
            $0.transferMessage = CardanoTransfer.with {
                $0.toAddress = recipient; $0.changeAddress = sender; $0.amount = 2000000
                $0.useMaxAmount = false
            }
        }
        let reference: CardanoSigningOutput = AnySigner.sign(input: input, coin: .cardano)
        precondition(reference.errorMessage.isEmpty && !reference.encoded.isEmpty)
        precondition(signed == "0x" + reference.encoded.hexString, "Bridge changed the signing payload")
        precondition(plugin.signCardanoTransaction(wallet: nil, path: path, txData: payload, pk: key) == signed)
        precondition(plugin.signCardanoTransaction(wallet: nil, path: path, txData: payload, pk: nil) == nil)
        let plan: CardanoTransactionPlan = AnySigner.plan(input: input, coin: .cardano)
        precondition(plan.error == .ok && plan.amount == 2000000 && plan.fee > 0)
        precondition(plan.amount + plan.fee + plan.change == plan.availableAmount)
        let readOnly = plugin.planCardanoTransaction(txData: payload)!
        precondition(readOnly == ["amount": String(plan.amount), "fee": String(plan.fee),
                                  "change": String(plan.change), "available": String(plan.availableAmount)])
        var foreignInput = payload
        foreignInput["changeAddress"] = recipient
        precondition(plugin.planCardanoTransaction(txData: foreignInput) == nil)
        var missingChange = payload; missingChange.removeValue(forKey: "changeAddress")
        precondition(plugin.planCardanoTransaction(txData: missingChange) == nil)
        var count = 9
        for field in ["amount", "ttl", "toAddress", "utxos"] {
            var invalid = payload; invalid.removeValue(forKey: field)
            precondition(plugin.signCardanoTransaction(wallet: wallet, path: path, txData: invalid, pk: nil) == nil)
            count += 1
        }
        var oldPayload = payload
        oldPayload["utxos"] = [["txHash": hash, "outputIndex": 0, "amount": [["unit":"lovelace", "quantity":"10000000"]]]]
        precondition(plugin.signCardanoTransaction(wallet: wallet, path: path, txData: oldPayload, pk: nil) == nil)
        count += 1
        var invalidAddress = payload; invalidAddress["toAddress"] = "not-a-cardano-address"
        precondition(plugin.signCardanoTransaction(wallet: wallet, path: path, txData: invalidAddress, pk: nil) == nil)
        count += 1
        var insufficient = payload; insufficient["amount"] = "100000000"
        precondition(plugin.signCardanoTransaction(wallet: wallet, path: path, txData: insufficient, pk: nil) == nil)
        count += 1
        var metadata = payload; metadata["returnMetadata"] = true
        let ordinaryJSON = plugin.signCardanoTransaction(wallet: wallet, path: path, txData: metadata, pk: nil)!
        let ordinary = try! JSONSerialization.jsonObject(with: Data(ordinaryJSON.utf8)) as! [String: String]
        precondition(ordinary["encoded"] == signed && ordinary["amount"] == String(plan.amount))
        precondition(ordinary["txHash"] == reference.txID.hexString && reference.txID.count == 32)
        precondition(ordinary["fee"] == String(plan.fee) && ordinary["change"] == String(plan.change))
        metadata["useMaxAmount"] = true; metadata["amount"] = "10000000"
        let maxJSON = plugin.signCardanoTransaction(wallet: wallet, path: path, txData: metadata, pk: nil)!
        let maximum = try! JSONSerialization.jsonObject(with: Data(maxJSON.utf8)) as! [String: String]
        precondition(maximum["change"] == "0" && maximum["available"] == "10000000")
        precondition(UInt64(maximum["amount"]!)! + UInt64(maximum["fee"]!)! == 10000000)
        var maxInput = input; maxInput.transferMessage.useMaxAmount = true; maxInput.transferMessage.amount = 10000000
        let maxPlan: CardanoTransactionPlan = AnySigner.plan(input: maxInput, coin: .cardano)
        maxInput.plan = maxPlan
        let maxReference: CardanoSigningOutput = AnySigner.sign(input: maxInput, coin: .cardano)
        precondition(maxReference.error == .ok && maximum["encoded"] == "0x" + maxReference.encoded.hexString)
        metadata.removeValue(forKey: "returnMetadata")
        let maxReadOnly = plugin.planCardanoTransaction(txData: metadata)!
        for key in ["amount", "fee", "change", "available"] {
            precondition(maxReadOnly[key] == maximum[key])
        }
        precondition(plugin.planCardanoTransaction(txData: invalidAddress) == nil)
        precondition(plugin.planCardanoTransaction(txData: insufficient) == nil)
        count += 12
        print("Cardano native signing: \(count) checks passed")
    }
}

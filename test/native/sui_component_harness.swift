import Foundation
import WalletCore

func unhex(_ value: String) -> Data {
    var result = Data(); var index = value.startIndex
    while index < value.endIndex {
        let end = value.index(index, offsetBy: 2)
        result.append(UInt8(value[index..<end], radix: 16)!)
        index = end
    }
    return result
}

@main struct Main {
    static func main() throws {
        let vectors = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[String: String]]
        let plugin = WalletCorePlugin()
        for vector in vectors {
            let key = PrivateKey(data: unhex(vector["seed"]!))!
            let raw = vector["raw"]!
            let actual = plugin.signSuiTransaction(wallet: nil, path: "", txData: ["type": "WC_SUI", "transaction": raw], privateKey: key)
            precondition(actual == vector["signature"], "Sui signature differs from independent Python/Node vector")
            for invalid: Any in ["", "!", "Zg", "Zh==", raw + "\n", 42] {
                precondition(plugin.signSuiTransaction(wallet: nil, path: "", txData: ["type": "WC_SUI", "transaction": invalid], privateKey: key) == nil)
            }
            precondition(plugin.signSuiTransaction(wallet: nil, path: "", txData: ["type": "WC_SUI"], privateKey: key) == nil)
            precondition(plugin.signSuiTransaction(wallet: nil, path: "", txData: ["type": "WC_SUI", "transaction": raw], privateKey: nil) == nil)
        }
        let key = PrivateKey(data: Data(repeating: 1, count: 32))!
        let transfer: [String: Any] = [
            "type": "SUI_TRANSFER", "fromAddress": CoinType.sui.deriveAddress(privateKey: key),
            "toAddress": "0x" + String(repeating: "2", count: 64),
            "amount": "9007199254740993", "gasBudget": "2000000", "referenceGasPrice": "1000",
            "utxo": [["objectId": "0x" + String(repeating: "3", count: 64),
                      "version": "1", "objectDigest": String(repeating: "1", count: 32)]]
        ]
        let signed = plugin.signSuiTransaction(wallet: nil, path: "", txData: transfer, privateKey: key)!
        let parts = signed.components(separatedBy: "|")
        precondition(parts.count == 2)
        precondition(plugin.signSuiTransaction(wallet: nil, path: "", txData: ["type": "WC_SUI", "transaction": parts[0]], privateKey: key) == parts[1])
        for field in ["amount", "gasBudget", "referenceGasPrice"] {
            for invalid: Any in ["0", "-1", "18446744073709551616", "01", true, 1.5] {
                var bad = transfer; bad[field] = invalid
                precondition(plugin.signSuiTransaction(wallet: nil, path: "", txData: bad, privateKey: key) == nil)
            }
        }
        var wrongOwner = transfer; wrongOwner["fromAddress"] = transfer["toAddress"]
        precondition(plugin.signSuiTransaction(wallet: nil, path: "", txData: wrongOwner, privateKey: key) == nil)
        var duplicate = transfer; let coins = transfer["utxo"] as! [[String: String]]
        duplicate["utxo"] = coins + coins
        precondition(plugin.signSuiTransaction(wallet: nil, path: "", txData: duplicate, privateKey: key) == nil)
        print("PASS: ordinary transfer signs exact integer fields; rejects invalid amounts, wrong owner and duplicate coins")
        print("PASS: 4 independent Sui intent vectors through actual Swift entrypoint; malformed/missing input rejected")
    }
}

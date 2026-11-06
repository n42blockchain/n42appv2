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
        print("PASS: 4 independent Sui intent vectors through actual Swift entrypoint; malformed/missing input rejected")
    }
}

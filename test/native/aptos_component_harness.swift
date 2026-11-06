import Foundation
import WalletCore

func unhex(_ value: String) -> Data {
    var result = Data(); var i = value.startIndex
    while i < value.endIndex {
        let end = value.index(i, offsetBy: 2)
        result.append(UInt8(value[i..<end], radix: 16)!)
        i = end
    }
    return result
}

@main struct Main {
    static func main() throws {
        let vectors = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[String: Any]]
        let plugin = WalletCorePlugin()
        for vector in vectors {
            let raw = unhex(vector["raw"] as! String)
            let chain = vector["chain"] as! Int
            let key = PrivateKey(data: unhex(vector["seed"] as! String))!
            let params: [String: Any] = ["type":"WC_APT", "encodedTransaction":raw.base64EncodedString(), "chainId":chain]
            let actual = plugin.signAptosTransaction(wallet:nil,path:"",txData:params,privateKey:key)
            precondition(actual == vector["signed"] as? String, "Node signature/authenticator mismatch")
            let transfer: [String: Any] = [
                "type":"transfer", "fromAddress":"0x" + raw.prefix(32).hexString,
                "toAddress":"0x2", "amount":UInt64(1), "chainId":UInt32(chain),
                "SequenceNumber":Int64(0), "gasUnitPrice":UInt64(100),
                "maxGasAmount":UInt64(10000), "expirationTimestampSecs":UInt64(2000000000),
                "contractAddress":"", "contractModule":"", "contractName":""
            ]
            precondition(plugin.signAptosTransaction(wallet:nil,path:"",txData:transfer,privateKey:key) == actual,
                         "Raw signer differs from WalletCore standard transfer signer")
            precondition(plugin.signWalletConnectAptos(raw,chain:chain == 1 ? 2 : 1,privateKey:key) == nil)
            precondition(plugin.signWalletConnectAptos(raw,chain:chain,privateKey:PrivateKey(data:Data(repeating:2,count:32))!) == nil)
            for length in 0..<67 { precondition(plugin.signWalletConnectAptos(Data(raw.prefix(length)),chain:chain,privateKey:key) == nil) }
            precondition(plugin.signAptosTransaction(wallet:nil,path:"",txData:["type":"WC_APT"],privateKey:key) == nil)
        }
        print("PASS: two Node reference vectors through actual Swift entrypoint; wrong signer/chain and short inputs rejected")
    }
}

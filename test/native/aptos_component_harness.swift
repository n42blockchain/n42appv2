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
        precondition(plugin.aptosUInt64("18446744073709551615") == UInt64.max)
        for invalid: Any in [true, -1, 1.5, "01", "-1", "18446744073709551616"] {
            precondition(plugin.aptosUInt64(invalid) == nil)
        }
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
            let otherKey = PrivateKey(data:Data(repeating:2,count:32))!
            precondition(plugin.signAptosTransaction(wallet:nil,path:"",txData:transfer,privateKey:otherKey) == nil,
                         "ordinary transfer must reject a different signer")
            var wrongOwner = transfer; wrongOwner["fromAddress"] = "0x2"
            precondition(plugin.signAptosTransaction(wallet:nil,path:"",txData:wrongOwner,privateKey:key) == nil)
            var normalized = transfer
            normalized["fromAddress"] = "0x" + raw.prefix(32).hexString.uppercased()
            normalized["toAddress"] = "0x" + String(repeating:"0",count:63) + "2"
            precondition(plugin.signAptosTransaction(wallet:nil,path:"",txData:normalized,privateKey:key) == actual)
            for field in ["fromAddress", "toAddress"] {
                for invalid: Any in [true, 2, "", "0x", "0xgg", "0x2\n", "0x" + String(repeating:"1",count:65)] {
                    var bad = transfer; bad[field] = invalid
                    precondition(plugin.signAptosTransaction(wallet:nil,path:"",txData:bad,privateKey:key) == nil)
                }
            }
            var strings = transfer
            for field in ["amount", "chainId", "SequenceNumber", "gasUnitPrice", "maxGasAmount", "expirationTimestampSecs"] {
                strings[field] = String(plugin.aptosUInt64(transfer[field])!)
            }
            precondition(plugin.signAptosTransaction(wallet:nil,path:"",txData:strings,privateKey:key) == actual)
            var largest = strings
            largest["amount"] = "18446744073709551615"
            largest["SequenceNumber"] = "18446744073709551615"
            var largestRaw = raw
            largestRaw.replaceSubrange(32..<40, with: Data(repeating:255,count:8))
            largestRaw.replaceSubrange((raw.count-33)..<(raw.count-25), with: Data(repeating:255,count:8))
            let largestSigned = plugin.signAptosTransaction(wallet:nil,path:"",txData:largest,privateKey:key)
            precondition(largestSigned != nil)
            precondition(largestSigned!.hasPrefix(largestRaw.hexString), "uint64 amount or sequence truncated")
            precondition(largestSigned == plugin.signWalletConnectAptos(largestRaw,chain:chain,privateKey:key))
            for field in ["amount", "SequenceNumber", "gasUnitPrice", "maxGasAmount", "expirationTimestampSecs"] {
                for invalid: Any in [true, -1, 1.5, "01", "18446744073709551616"] {
                    var bad = strings; bad[field] = invalid
                    precondition(plugin.signAptosTransaction(wallet:nil,path:"",txData:bad,privateKey:key) == nil)
                }
            }
            precondition(plugin.signWalletConnectAptos(raw,chain:chain == 1 ? 2 : 1,privateKey:key) == nil)
            precondition(plugin.signWalletConnectAptos(raw,chain:chain,privateKey:PrivateKey(data:Data(repeating:2,count:32))!) == nil)
            for length in 0..<67 { precondition(plugin.signWalletConnectAptos(Data(raw.prefix(length)),chain:chain,privateKey:key) == nil) }
            precondition(plugin.signAptosTransaction(wallet:nil,path:"",txData:["type":"WC_APT"],privateKey:key) == nil)
        }
        print("PASS: two Node reference vectors through actual Swift entrypoint; wrong signer/chain and short inputs rejected")
    }
}

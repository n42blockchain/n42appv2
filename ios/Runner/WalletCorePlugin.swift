//
//  WalletCorePlugin.swift
//  Runner
//
//  Handles all `trustdart` MethodChannel calls for wallet-core operations.
//

import Flutter
import ActivityKit
import UIKit
import WalletCore

public class WalletCorePlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "trustdart",
            binaryMessenger: registrar.messenger()
        )
        let instance = WalletCorePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "generateMnemonic":
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "arguments_null", message: "arguments is null", details: nil))
            break
        }
        let passphrase: String = (args["passphrase"] as? String) ?? ""
        let leng: Int32 = (args["length"] as? Int32) ?? 128
        if let wallet = HDWallet(strength: leng, passphrase: passphrase) {
            result(wallet.mnemonic)
        } else {
            result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
        }
    break
    case "checkMnemonic":
        guard let args = call.arguments as? [String: String] else {
            result(FlutterError(code: "arguments_null", message: "arguments is null", details: nil))
            break
        }
        guard let mnemonic = args["mnemonic"], !mnemonic.isEmpty else {
            result(FlutterError(code: "arguments_null", message: "[mnemonic] cannot be null", details: nil))
            break
        }
        let passphrase: String = args["passphrase"] ?? ""
        if let wallet = HDWallet(mnemonic: mnemonic, passphrase: passphrase) {
            result(true)
        } else {
            result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
        }
    break
    case "generateAddress":
        let args = call.arguments as! [String: String]
        let path: String? = args["path"]
        let coin: String? = args["coin"]
        let mnemonic: String? = args["mnemonic"]
        let passphrase: String? = args["passphrase"]
        let addressType: String? = args["addressType"]
        let pkStr: String? = args["pk"]
        let isImport: String? = args["isImport"]
        let isTest: String? = args["isTest"]
        if path != nil && coin != nil && mnemonic != nil && pkStr != nil {
            if mnemonic != ""{
                let wallet = HDWallet(mnemonic: mnemonic!, passphrase: passphrase!)
                if wallet != nil {

                    let address: [String: String]? = self.generateAddress(wallet: wallet!, path: path!, coin: coin!, addressType: addressType!,isTest: isTest!)
                    if address == nil {
                        result(FlutterError(code: "address_null",
                                                message: "Failed to generate address",
                                                details: nil))
                    } else {
                        result(address)
                    }
                } else {
                    result(FlutterError(code: "no_wallet",
                                            message: "Could not generate wallet, why?",
                                            details: nil))
                }
            }else if pkStr != ""{
                var d:Data
                if isImport == "true"{
                    d = Data(hexString: pkStr!)!
                }else{
                    d = Base64.decode(string: pkStr!)!
                }

                let pk : PrivateKey = PrivateKey.init(data: d)!
                let address: [String: String]? = self.generateAddress_pk(privateKey: pk, coin: coin!, addressType: addressType!,coinType: nil,isTest: isTest!)
                if address == nil {
                    result(FlutterError(code: "address_null",
                                            message: "Failed to generate address",
                                            details: nil))
                } else {
                    result(address)
                }
            }

        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] and [privateKey] cannot be null",
                                    details: nil))
        }
    break
    case "validateAddress":
        let args = call.arguments as! [String: String]
        let address: String? = args["address"]
        let coin: String? = args["coin"]
        if address != nil && coin != nil {
            let isValid: Bool = self.validateAddress(address: address!, coin: coin!)
            result(isValid)
        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[address] and [coin] cannot be null",
                                    details: nil))
        }
    break
    case "signTransaction":
        let args = call.arguments as! [String: Any]
        let coin: String? = args["coin"] as? String
        let path: String? = args["path"] as? String
        let txData: [String: Any]? = args["txData"] as? [String: Any]
        let mnemonic: String? = args["mnemonic"] as? String
        let passphrase: String? = args["passphrase"] as? String
        let pkStr: String? = args["pk"] as? String
        if coin != nil && path != nil && txData != nil && mnemonic != nil && pkStr != nil {
            if mnemonic != ""{
                let wallet = HDWallet(mnemonic: mnemonic!, passphrase: passphrase!)

                if wallet != nil {
                    let txHash: String? = self.signTransaction(wallet: wallet, coin: coin!, path: path!, txData: txData!, pk: nil)
                    if txHash == nil {
                        result(FlutterError(code: "txhash_null",
                                                message: "Failed to buid and sign transaction",
                                                details: nil))
                    } else {
                        result(txHash)
                    }
                } else {
                    result(FlutterError(code: "no_wallet",
                                            message: "Could not generate wallet, why?",
                                            details: nil))
                }
            }else if pkStr != ""{
                //let pk : PrivateKey = PrivateKey.init(data: Data(hexString: pkStr!)!)!
                let d:Data = Base64.decode(string: pkStr!)!
                let pk : PrivateKey = PrivateKey.init(data: d)!
                let txHash: String? = self.signTransaction(wallet: nil, coin: coin!, path: "", txData: txData!,pk: pk)
                if txHash == nil {
                    result(FlutterError(code: "txhash_null",
                                            message: "Failed to buid and sign transaction",
                                            details: nil))
                } else {
                    result(txHash)
                }
            }else{
                result(FlutterError(code: "no_wallet",
                                        message: "Could not generate wallet, why?",
                                        details: nil))
            }

        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null",
                                    details: nil))
        }
    break
    case "signTransaction_btc_p2wsh":
        let args = call.arguments as! [String: Any]
        let coin: String? = args["coin"] as? String
        let path: String? = args["path"] as? String
        let txData: [String: Any]? = args["txData"] as? [String: Any]
        let mnemonic: String? = args["mnemonic"] as? String
        let passphrase: String? = args["passphrase"] as? String
        let pkStr: String? = args["pk"] as? String
        if coin != nil && path != nil && txData != nil && mnemonic != nil && pkStr != nil {
            if mnemonic != ""{
                let wallet = HDWallet(mnemonic: mnemonic!, passphrase: passphrase!)

                if wallet != nil {
                    let txHash: String? = self.signBitcoinTransaction_p2wsh(wallet: wallet, path: path!, txData: txData!, coinType: CoinType.bitcoin, pk: nil)
                    if txHash == nil {
                        result(FlutterError(code: "txhash_null",
                                                message: "Failed to buid and sign transaction",
                                                details: nil))
                    } else {
                        result(txHash)
                    }
                } else {
                    result(FlutterError(code: "no_wallet",
                                            message: "Could not generate wallet, why?",
                                            details: nil))
                }
            }else if pkStr != ""{
                //let pk : PrivateKey = PrivateKey.init(data: Data(hexString: pkStr!)!)!
                let d:Data = Base64.decode(string: pkStr!)!
                let pk : PrivateKey = PrivateKey.init(data: d)!
                let txHash: String? = self.signBitcoinTransaction_p2wsh(wallet: nil, path: "", txData: txData!, coinType: CoinType.bitcoin, pk: pk)
                if txHash == nil {
                    result(FlutterError(code: "txhash_null",
                                            message: "Failed to buid and sign transaction",
                                            details: nil))
                } else {
                    result(txHash)
                }
            }else{
                result(FlutterError(code: "no_wallet",
                                        message: "Could not generate wallet, why?",
                                        details: nil))
            }

        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null",
                                    details: nil))
        }
    break
    case "signTransaction_byteArray":
        let args = call.arguments as! [String: Any]
        let coin: String? = args["coin"] as? String
        let path: String? = args["path"] as? String
        let txData: [String: Any]? = args["txData"] as? [String: Any]
        let mnemonic: String? = args["mnemonic"] as? String
        let passphrase: String? = args["passphrase"] as? String
        let pkStr: String? = args["pk"] as? String
        if coin != nil && path != nil && txData != nil && mnemonic != nil && pkStr != nil {
            if mnemonic != ""{
                let wallet = HDWallet(mnemonic: mnemonic!, passphrase: passphrase!)

                if wallet != nil {
                    let txHash: String? = self.signTransaction_byteArray(wallet: wallet, coin: coin!, path: path!, txData: txData!, pk: nil)
                    if txHash == nil {
                        result(FlutterError(code: "txhash_null",
                                                message: "Failed to buid and sign transaction",
                                                details: nil))
                    } else {
                        result(txHash)
                    }
                } else {
                    result(FlutterError(code: "no_wallet",
                                            message: "Could not generate wallet, why?",
                                            details: nil))
                }
            }else if pkStr != ""{
                //let pk : PrivateKey = PrivateKey.init(data: Data(hexString: pkStr!)!)!
                let d:Data = Base64.decode(string: pkStr!)!
                let pk : PrivateKey = PrivateKey.init(data: d)!
                let txHash: String? = self.signTransaction_byteArray(wallet: nil, coin: coin!, path: "", txData: txData!,pk: pk)
                if txHash == nil {
                    result(FlutterError(code: "txhash_null",
                                            message: "Failed to buid and sign transaction",
                                            details: nil))
                } else {
                    result(txHash)
                }
            }else{
                result(FlutterError(code: "no_wallet",
                                        message: "Could not generate wallet, why?",
                                        details: nil))
            }

        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null",
                                    details: nil))
        }
    break
    case "signMessage":
        let args = call.arguments as! [String: Any]
        let coin: String? = args["coin"] as? String
        let path: String? = args["path"] as? String
        let txData: String? = args["txData"] as? String
        let mnemonic: String? = args["mnemonic"] as? String
        let passphrase: String? = args["passphrase"] as? String
        let pkStr: String? = args["pk"] as? String
        if coin != nil && path != nil && txData != nil && mnemonic != nil && pkStr != nil {
            if mnemonic != ""{
                let wallet = HDWallet(mnemonic: mnemonic!, passphrase: passphrase!)

                if wallet != nil {
                    let txHash: String? = self.signMessage(wallet: wallet, coin: coin!, path: path!, txData: txData!, pk: nil)
                    if txHash == nil {
                        result(FlutterError(code: "txhash_null",
                                                message: "Failed to buid and sign message",
                                                details: nil))
                    } else {
                        result(txHash)
                    }
                } else {
                    result(FlutterError(code: "no_wallet",
                                            message: "Could not generate wallet, why?",
                                            details: nil))
                }
            }else if pkStr != ""{
                let d:Data = Base64.decode(string: pkStr!)!
                let pk : PrivateKey = PrivateKey.init(data: d)!
                let txHash: String? = self.signMessage(wallet: nil, coin: coin!, path: "", txData: txData!,pk: pk)
                if txHash == nil {
                    result(FlutterError(code: "txhash_null",
                                            message: "Failed to buid and sign message",
                                            details: nil))
                } else {
                    result(txHash)
                }
            }else{
                result(FlutterError(code: "no_wallet",
                                        message: "Could not generate wallet, why?",
                                        details: nil))
            }

        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null",
                                    details: nil))
        }
    break
    case "getPublicKey":
        let args = call.arguments as! [String: String]
        let path: String? = args["path"]
        let coin: String? = args["coin"]
        let mnemonic: String? = args["mnemonic"]
        let passphrase: String? = args["passphrase"]
        let pkStr: String? = args["pk"]
        if path != nil && coin != nil {
            var wallet : HDWallet
            if mnemonic != "" {
                wallet = HDWallet(mnemonic: mnemonic!, passphrase: passphrase!)!
            }else{
                let d:Data = Base64.decode(string: pkStr!)!
                wallet = HDWallet(entropy: d, passphrase: passphrase!)!
            }
            if wallet != nil {
                let publicKey: String? = self.getPublicKey(wallet: wallet, path: path!, coin: coin!)
                if publicKey == nil {
                    result(FlutterError(code: "address_null",
                                            message: "Failed to generate address",
                                            details: nil))
                } else {
                    result(publicKey)
                }
            } else {
                result(FlutterError(code: "no_wallet",
                                        message: "Could not generate wallet, why?",
                                        details: nil))
            }
        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] cannot be null",
                                    details: nil))
        }
        break
    case "getPrivateKey":
        let args = call.arguments as! [String: String]
        let path: String? = args["path"]
        let coin: String? = args["coin"]
        let mnemonic: String? = args["mnemonic"]
        let passphrase: String? = args["passphrase"]
        if path != nil && coin != nil && mnemonic != nil {
            var wallet : HDWallet?
            if mnemonic != "" {
                wallet = HDWallet(mnemonic: mnemonic!, passphrase: "")
            }else{
                wallet = nil
            }
            if wallet != nil {
                let privateKey: String? = self.getPrivateKey(wallet: wallet!, path: path!, coin: coin!)
                if privateKey == nil {
                    result(FlutterError(code: "address_null",
                                            message: "Failed to generate address",
                                            details: nil))
                } else {
                    result(privateKey)
                }
            } else {
                result(FlutterError(code: "no_wallet",
                                        message: "Could not generate wallet, why?",
                                        details: nil))
            }
        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] cannot be null",
                                    details: nil))
        }
        break
    case "getKeyStore":
        let args = call.arguments as! [String: String]
        let path: String? = args["path"]
        let coin: String? = args["coin"]
        let mnemonic: String? = args["mnemonic"]
        let passphrase: String? = args["passphrase"]
        let addressType: String? = args["addressType"]
        let pkStr: String? = args["pk"]
        if path != nil && coin != nil  && passphrase != nil && addressType != nil {
            var wallet: HDWallet?
            if mnemonic == ""{
                let d:Data = Base64.decode(string: pkStr!)!
                wallet = HDWallet(entropy: d, passphrase: "")!
            }else{
                wallet = HDWallet(mnemonic: mnemonic!, passphrase: "")!
            }
            if wallet != nil {
                let keystore: String = self.getKeyStore(wallet: wallet!, path: path!, coin: coin!, passphrase: passphrase!, addressType: addressType!)
                if keystore == "" {
                    result(FlutterError(code: "KeyStore_error",
                                            message: "Failed to KeyStore",
                                            details: nil))
                } else {
                    result(keystore)
                }
            } else {
                result(FlutterError(code: "no_wallet",
                                        message: "Could not generate wallet, why?",
                                        details: nil))
            }
        }else {
            result(FlutterError(code: "arguments_null", message:"[path] and [coin] and [mnemonic] and [passphrase] cannot be null",
                                    details: nil))
        }
        break
    case "getWalletInfoWithKeyStore":
        let args = call.arguments as! [String: String]
        let keyStore: String? = args["keyStore"]
        let coin: String? = args["coin"]
        let passphrase: String? = args["passphrase"]
        if keyStore != nil && coin != nil && passphrase != nil {
            let keystore = self.getWalletInfoWithKeyStore(keyStore:keyStore!,passphrase: passphrase!,coinType: coin!)
            result(keystore)
        }else {
            result(FlutterError(code: "arguments_null", message:"[keyStore] and [coin] and [passphrase] cannot be null",
                                    details: nil))
        }
        break
    case "getTransactionMaxValue":
        let args = call.arguments as! [String: Any]
        let coin: String? = args["coin"] as? String
        let path: String? = args["path"] as? String
        let txData: [String: Any]? = args["txData"] as? [String: Any]
        let mnemonic: String? = args["mnemonic"] as? String
        let passphrase: String? = args["passphrase"] as? String
        let pkStr: String? = args["pk"] as? String
        if coin != nil && path != nil && txData != nil && mnemonic != nil && pkStr != nil {
            if mnemonic != ""{
                let wallet = HDWallet(mnemonic: mnemonic!, passphrase: passphrase!)

                if wallet != nil {
                    let txHash: String? = self.signTransaction_maxValue(wallet: wallet, coin: coin!, path: path!, txData: txData!, pk: nil)
                    if txHash == nil {
                        result(FlutterError(code: "txhash_null",
                                                message: "Failed to buid and sign transaction",
                                                details: nil))
                    } else {
                        result(txHash)
                    }
                } else {
                    result(FlutterError(code: "no_wallet",
                                            message: "Could not generate wallet, why?",
                                            details: nil))
                }
            }else if pkStr != ""{
                //let pk : PrivateKey = PrivateKey.init(data: Data(hexString: pkStr!)!)!
                let d:Data = Base64.decode(string: pkStr!)!
                let pk : PrivateKey = PrivateKey.init(data: d)!
                let txHash: String? = self.signTransaction_maxValue(wallet: nil, coin: coin!, path: "", txData: txData!,pk: pk)
                if txHash == nil {
                    result(FlutterError(code: "txhash_null",
                                            message: "Failed to buid and sign transaction",
                                            details: nil))
                } else {
                    result(txHash)
                }
            }else{
                result(FlutterError(code: "no_wallet",
                                        message: "Could not generate wallet, why?",
                                        details: nil))
            }

        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null",
                                    details: nil))
        }
    break
    case "getPrivateKeyAndPublicKey":
        let args = call.arguments as! [String: String]
        let path: String? = args["path"]
        let coin: String? = args["coin"]
        let mnemonic: String? = args["mnemonic"]
        let pkStr: String? = args["privateKey"]
        let passphrase: String? = args["passphrase"]
        if path != nil && coin != nil {
            var wallet :HDWallet
            if mnemonic != ""{
                wallet = HDWallet(mnemonic: mnemonic!, passphrase: passphrase!)!
            }else {
                let d:Data = Base64.decode(string: pkStr!)!
                wallet = HDWallet(entropy: d, passphrase: passphrase!)!
            }

            let publicKey: String? = self.getPublicKey(wallet: wallet, path: path!, coin: coin!)
            let privateKey: String? = self.getPrivateKey(wallet: wallet, path: path!, coin: coin!)
            if privateKey == nil {
                result(FlutterError(code: "address_null",
                                        message: "Failed to generate address",
                                        details: nil))
            } else {
                let rValue :[String?:String?]=["publicKey":publicKey,"privateKey":privateKey]

                  result(self.objToJson(from: rValue))
            }
        } else {
            result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] cannot be null",
                                    details: nil))
        }
        break
    case "LiveActivityStart":
        let args = call.arguments as! [String: Any]
        var type: Int32? = args["type"] as? Int32
        av_play(type: type!)
        let state = N42Attributes.ContentState(value: 1);
        let attr = N42Attributes(name: "test")

        do {
            if #available(iOS 16.1, *) {
                activity = try Activity.request(attributes: attr, contentState: state)
            } else {
                result(FlutterError(code: "LiveActivityError",
                                        message: "iOS version must be greater than 16.1",
                                        details: nil))
            }

            let toBackgroundControl = UIControl()
            toBackgroundControl.sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
            result("true")
        } catch {
            result(FlutterError(code: "LiveActivityError",
                                    message: "LiveActivity Start Error",
                                    details: nil))
        }

        break
    case "LiveActivityUpdate":
        let args = call.arguments as! [String: Any]
        let value : Int = args["value"] as! Int
        let state = N42Attributes.ContentState(value: value);
        if #available(iOS 13.0, *) {
            Task{
                if #available(iOS 16.1, *) {
                    await activity?.update(using: state)
                    result("true")
                } else {
                    result(FlutterError(code: "LiveActivityError",
                                        message: "iOS version must be greater than 16.1",
                                        details: nil))
                }
            }
        } else {
            // Fallback on earlier versions
        }
        break
    case "LiveActivityEnd":
        av_stop()
        let args = call.arguments as! [String: Any]
        let value : Int = args["value"] as! Int
        let state = N42Attributes.ContentState(value: value);
        if #available(iOS 13.0, *) {
            Task{
                if #available(iOS 16.1, *) {
                    await activity?.end(using: state,dismissalPolicy: .immediate)
                    result("true")
                } else {
                    result(FlutterError(code: "LiveActivityError",
                                        message: "iOS version must be greater than 16.1",
                                        details: nil))
                }
            }
        } else {
            // Fallback on earlier versions
        }
        break
    case "Permissions":
        let args = call.arguments as! [String: String]
        let pName: String? = args["pName"]
        if pName == "Camera" {
            let rData: String = getCameraPermission();
            result(rData)
        }else if pName == "Photo" {
            let rData: String = getPhotoPermission();
            result(rData)
        }else{
            result("")
        }
        break
    case "getPubKeySOL":
        let args = call.arguments as! [String: String]
        let mintAddress: String? = args["mintAddress"]
        let address: String? = args["address"]
        let pubKey: String? = SolanaAddress(string: address!)?.defaultTokenAddress(tokenMintAddress: mintAddress!)
        result(pubKey ?? "")
        break
    case "MiningGenerateBls12381Keypair":
        let keyPairResult = MobileSdk.generateBls12381Keypair()
        switch keyPairResult {
        case .success(let keyPair):
            result(keyPair)
        case .failure(let error):
            result(FlutterError(code: "DepositError", message: "\(error)", details: nil))
        }
        break
    case "MiningCreateDepositUnsignedTx":
        guard let args = call.arguments as? [String: Any],
              let depositContractAddress = args["depositContractAddress"] as? String,
              let validatorPrivateKey = args["validatorPrivateKey"] as? String,
              let withdrawalAddress = args["withdrawalAddress"] as? String,
              let depositValueWeiInHex = args["depositValueWeiInHex"] as? String else {
            result(FlutterError(code: "arguments_null", message: "invalid arguments", details: nil))
            break
        }
        let txResult = MobileSdk.createDepositUnsignedTx(
            depositContractAddress: depositContractAddress,
            validatorPrivateKey: validatorPrivateKey,
            withdrawalAddress: withdrawalAddress,
            depositValueInWei: depositValueWeiInHex
        )
        switch txResult {
        case .success(let tx):
            result(tx)
        case .failure(let error):
            result(FlutterError(code: "DepositError", message: "\(error)", details: nil))
        }
        break
    case "MiningCreateExitUnsignedTx":
        guard let args = call.arguments as? [String: Any],
              let validatorPublicKey = args["validatorPublicKey"] as? String,
              let feeWeiInHex = args["feeWeiInHex"] as? String else {
            result(FlutterError(code: "arguments_null", message: "invalid arguments", details: nil))
            break
        }
        let txResult = MobileSdk.createExitUnsignedTx(validatorPublicKey: validatorPublicKey, feeInWeiOrEmpty: feeWeiInHex)
        switch txResult {
        case .success(let tx):
            result(tx)
        case .failure(let error):
            result(FlutterError(code: "ExitError", message: "\(error)", details: nil))
        }
        break
    case "MiningCreateGetExitFeeUnsignedTx":
        let txResult = MobileSdk.createGetExitFeeUnsignedTx()
        switch txResult {
        case .success(let tx):
            result(tx)
        case .failure(let error):
            result(FlutterError(code: "DepositError", message: "\(error)", details: nil))
        }
        break
    case "MiningRunClient":
        guard let args = call.arguments as? [String: Any],
              let wsUrl = args["wsUrl"] as? String,
              let validatorPrivateKey = args["validatorPrivateKey"] as? String else {
            result(FlutterError(code: "arguments_null", message: "invalid arguments", details: nil))
            break
        }
        let flutterResult = result
        MobileSdk.runClient(
          wsUrl: wsUrl,
          validatorPrivateKey: validatorPrivateKey,
          completion:{ mobileResult in
            switch mobileResult {
            case .success:
                flutterResult("Client started")
            case .failure(let err):
                flutterResult(FlutterError(code: "ClientError", message: "\(err)", details: nil))
            }
        })
        flutterResult("Client started")
        break
    default:
        result(FlutterMethodNotImplemented)
    }
    }
}

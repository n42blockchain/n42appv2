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

    private enum KeyResolution {
        case success(HDWallet?, PrivateKey?)
        case failure(FlutterError)
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "trustdart",
            binaryMessenger: registrar.messenger()
        )
        let instance = WalletCorePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // ── Key resolution helper ─────────────────────────────────────────────
    // Shared by all 5 sign* dispatch cases to eliminate repeated mnemonic/pk logic.
    private func resolveKey(from args: [String: Any]) -> KeyResolution {
        guard let mnemonic = args["mnemonic"] as? String,
              let pkStr = args["pk"] as? String else {
            return .failure(FlutterError(code: "arguments_null", message: "mnemonic or pk missing", details: nil))
        }
        let passphrase = (args["passphrase"] as? String) ?? ""
        if !mnemonic.isEmpty {
            guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: passphrase) else {
                return .failure(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
            }
            return .success(wallet, nil)
        } else if !pkStr.isEmpty {
            guard let d = Base64.decode(string: pkStr), let pk = PrivateKey(data: d) else {
                return .failure(FlutterError(code: "invalid_pk", message: "Could not decode private key", details: nil))
            }
            return .success(nil, pk)
        }
        return .failure(FlutterError(code: "no_wallet", message: "mnemonic and pk both empty", details: nil))
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        // ── Key management ────────────────────────────────────────────────

        case "generateMnemonic":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "arguments_null", message: "arguments is null", details: nil))
                return
            }
            let passphrase = (args["passphrase"] as? String) ?? ""
            let leng = (args["length"] as? Int32) ?? 128
            guard let wallet = HDWallet(strength: leng, passphrase: passphrase) else {
                result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
                return
            }
            result(wallet.mnemonic)

        case "checkMnemonic":
            guard let args = call.arguments as? [String: String],
                  let mnemonic = args["mnemonic"], !mnemonic.isEmpty else {
                result(FlutterError(code: "arguments_null", message: "[mnemonic] cannot be null", details: nil))
                return
            }
            result(Mnemonic.isValid(mnemonic: mnemonic))

        case "generateAddress":
            guard let args = call.arguments as? [String: String],
                  let path = args["path"],
                  let coin = args["coin"],
                  let mnemonic = args["mnemonic"],
                  let pkStr = args["pk"] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] and [privateKey] cannot be null",
                                    details: nil))
                return
            }
            let passphrase = args["passphrase"] ?? ""
            let addressType = args["addressType"] ?? "legacy"
            let isTest = args["isTest"] ?? "false"
            let isImport = args["isImport"]

            if !mnemonic.isEmpty {
                guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: passphrase) else {
                    result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
                    return
                }
                guard let address = generateAddress(wallet: wallet, path: path, coin: coin,
                                                    addressType: addressType, isTest: isTest) else {
                    result(FlutterError(code: "address_null", message: "Failed to generate address", details: nil))
                    return
                }
                result(address)
            } else if !pkStr.isEmpty {
                let rawData: Data?
                if isImport == "true" {
                    rawData = Data(hexString: pkStr)
                } else {
                    rawData = Base64.decode(string: pkStr)
                }
                guard let d = rawData, let pk = PrivateKey(data: d) else {
                    result(FlutterError(code: "invalid_pk", message: "Could not decode private key", details: nil))
                    return
                }
                guard let address = generateAddress_pk(privateKey: pk, coin: coin,
                                                       addressType: addressType, coinType: nil, isTest: isTest) else {
                    result(FlutterError(code: "address_null", message: "Failed to generate address", details: nil))
                    return
                }
                result(address)
            } else {
                result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] and [privateKey] cannot be null",
                                    details: nil))
            }

        case "validateAddress":
            guard let args = call.arguments as? [String: String],
                  let address = args["address"],
                  let coin = args["coin"] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[address] and [coin] cannot be null", details: nil))
                return
            }
            result(validateAddress(address: address, coin: coin))

        case "getPublicKey":
            guard let args = call.arguments as? [String: String],
                  let path = args["path"],
                  let coin = args["coin"] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] cannot be null", details: nil))
                return
            }
            let passphrase = args["passphrase"] ?? ""
            let mnemonic = args["mnemonic"] ?? ""
            let pkStr = args["pk"] ?? ""

            let wallet: HDWallet
            if !mnemonic.isEmpty {
                guard let w = HDWallet(mnemonic: mnemonic, passphrase: passphrase) else {
                    result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
                    return
                }
                wallet = w
            } else {
                guard let d = Base64.decode(string: pkStr),
                      let w = HDWallet(entropy: d, passphrase: passphrase) else {
                    result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
                    return
                }
                wallet = w
            }
            guard let publicKey = getPublicKey(wallet: wallet, path: path, coin: coin) else {
                result(FlutterError(code: "address_null", message: "Failed to generate address", details: nil))
                return
            }
            result(publicKey)

        case "getPrivateKey":
            guard let args = call.arguments as? [String: String],
                  let path = args["path"],
                  let coin = args["coin"],
                  let mnemonic = args["mnemonic"], !mnemonic.isEmpty else {
                result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] cannot be null", details: nil))
                return
            }
            guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
                result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
                return
            }
            let privateKey = getPrivateKey(wallet: wallet, path: path, coin: coin)
            if privateKey.isEmpty {
                result(FlutterError(code: "address_null", message: "Failed to generate address", details: nil))
            } else {
                result(privateKey)
            }

        case "getKeyStore":
            guard let args = call.arguments as? [String: String],
                  let path = args["path"],
                  let coin = args["coin"],
                  let passphrase = args["passphrase"],
                  let addressType = args["addressType"] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] and [passphrase] cannot be null",
                                    details: nil))
                return
            }
            let mnemonic = args["mnemonic"] ?? ""
            let pkStr = args["pk"] ?? ""

            let walletKS: HDWallet
            if mnemonic.isEmpty {
                guard let d = Base64.decode(string: pkStr),
                      let w = HDWallet(entropy: d, passphrase: "") else {
                    result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
                    return
                }
                walletKS = w
            } else {
                guard let w = HDWallet(mnemonic: mnemonic, passphrase: "") else {
                    result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
                    return
                }
                walletKS = w
            }
            let keystore = getKeyStore(wallet: walletKS, path: path, coin: coin,
                                       passphrase: passphrase, addressType: addressType)
            if keystore.isEmpty {
                result(FlutterError(code: "KeyStore_error", message: "Failed to KeyStore", details: nil))
            } else {
                result(keystore)
            }

        case "getWalletInfoWithKeyStore":
            guard let args = call.arguments as? [String: String],
                  let keyStore = args["keyStore"],
                  let coin = args["coin"],
                  let passphrase = args["passphrase"] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[keyStore] and [coin] and [passphrase] cannot be null", details: nil))
                return
            }
            result(getWalletInfoWithKeyStore(keyStore: keyStore, passphrase: passphrase, coinType: coin))

        case "getPrivateKeyAndPublicKey":
            guard let args = call.arguments as? [String: String],
                  let path = args["path"],
                  let coin = args["coin"] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[path] and [coin] and [mnemonic] cannot be null", details: nil))
                return
            }
            let mnemonic = args["mnemonic"] ?? ""
            let pkStr = args["privateKey"] ?? ""
            let passphrase = args["passphrase"] ?? ""

            let walletKP: HDWallet
            if !mnemonic.isEmpty {
                guard let w = HDWallet(mnemonic: mnemonic, passphrase: passphrase) else {
                    result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
                    return
                }
                walletKP = w
            } else {
                guard let d = Base64.decode(string: pkStr),
                      let w = HDWallet(entropy: d, passphrase: passphrase) else {
                    result(FlutterError(code: "no_wallet", message: "Could not generate wallet", details: nil))
                    return
                }
                walletKP = w
            }
            let publicKey = getPublicKey(wallet: walletKP, path: path, coin: coin)
            let privateKey = getPrivateKey(wallet: walletKP, path: path, coin: coin)
            guard !privateKey.isEmpty else {
                result(FlutterError(code: "address_null", message: "Failed to generate address", details: nil))
                return
            }
            result(objToJson(from: ["publicKey": publicKey as Any, "privateKey": privateKey as Any]))

        // ── Transaction signing ───────────────────────────────────────────

        case "signTransaction":
            guard let args = call.arguments as? [String: Any],
                  let coin = args["coin"] as? String,
                  let path = args["path"] as? String,
                  let txData = args["txData"] as? [String: Any] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null", details: nil))
                return
            }
            switch resolveKey(from: args) {
            case .failure(let err): result(err)
            case .success(let wallet, let pk):
                guard let txHash = signTransaction(wallet: wallet, coin: coin, path: path, txData: txData, pk: pk) else {
                    result(FlutterError(code: "txhash_null", message: "Failed to build and sign transaction", details: nil))
                    return
                }
                result(txHash)
            }

        case "signTransaction_btc_p2wsh":
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String,
                  let txData = args["txData"] as? [String: Any] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null", details: nil))
                return
            }
            switch resolveKey(from: args) {
            case .failure(let err): result(err)
            case .success(let wallet, let pk):
                guard let txHash = signBitcoinTransaction_p2wsh(wallet: wallet, path: path, txData: txData,
                                                                coinType: .bitcoin, pk: pk) else {
                    result(FlutterError(code: "txhash_null", message: "Failed to build and sign transaction", details: nil))
                    return
                }
                result(txHash)
            }

        case "signTransaction_byteArray":
            guard let args = call.arguments as? [String: Any],
                  let coin = args["coin"] as? String,
                  let path = args["path"] as? String,
                  let txData = args["txData"] as? [String: Any] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null", details: nil))
                return
            }
            switch resolveKey(from: args) {
            case .failure(let err): result(err)
            case .success(let wallet, let pk):
                guard let txHash = signTransaction_byteArray(wallet: wallet, coin: coin, path: path,
                                                             txData: txData, pk: pk) else {
                    result(FlutterError(code: "txhash_null", message: "Failed to build and sign transaction", details: nil))
                    return
                }
                result(txHash)
            }

        case "signMessage":
            guard let args = call.arguments as? [String: Any],
                  let coin = args["coin"] as? String,
                  let path = args["path"] as? String,
                  let txData = args["txData"] as? String else {
                result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null", details: nil))
                return
            }
            switch resolveKey(from: args) {
            case .failure(let err): result(err)
            case .success(let wallet, let pk):
                guard let txHash = signMessage(wallet: wallet, coin: coin, path: path, txData: txData, pk: pk) else {
                    result(FlutterError(code: "txhash_null", message: "Failed to build and sign message", details: nil))
                    return
                }
                result(txHash)
            }

        case "getTransactionMaxValue":
            guard let args = call.arguments as? [String: Any],
                  let coin = args["coin"] as? String,
                  let path = args["path"] as? String,
                  let txData = args["txData"] as? [String: Any] else {
                result(FlutterError(code: "arguments_null",
                                    message: "[coin], [path] and [txData] cannot be null", details: nil))
                return
            }
            switch resolveKey(from: args) {
            case .failure(let err): result(err)
            case .success(let wallet, let pk):
                guard let txHash = signTransaction_maxValue(wallet: wallet, coin: coin, path: path,
                                                            txData: txData, pk: pk) else {
                    result(FlutterError(code: "txhash_null", message: "Failed to build and sign transaction", details: nil))
                    return
                }
                result(txHash)
            }

        // ── Audio / LiveActivity ──────────────────────────────────────────

        case "LiveActivityStart":
            guard let args = call.arguments as? [String: Any],
                  let type = args["type"] as? Int32 else {
                result(FlutterError(code: "arguments_null", message: "type is null", details: nil))
                return
            }
            guard #available(iOS 16.1, *) else {
                result(FlutterError(code: "LiveActivityError",
                                    message: "iOS version must be greater than 16.1", details: nil))
                return
            }
            av_play(type: type)
            let startState = N42Attributes.ContentState(value: 1)
            let attr = N42Attributes(name: "test")
            do {
                activity = try Activity.request(attributes: attr, contentState: startState)
                let toBackgroundControl = UIControl()
                toBackgroundControl.sendAction(#selector(NSXPCConnection.suspend),
                                               to: UIApplication.shared, for: nil)
                result("true")
            } catch {
                result(FlutterError(code: "LiveActivityError", message: "LiveActivity Start Error", details: nil))
            }

        case "LiveActivityUpdate":
            guard #available(iOS 16.1, *) else {
                result(FlutterError(code: "LiveActivityError",
                                    message: "iOS version must be greater than 16.1", details: nil))
                return
            }
            guard let args = call.arguments as? [String: Any],
                  let value = args["value"] as? Int else {
                result(FlutterError(code: "arguments_null", message: "value is null", details: nil))
                return
            }
            let updateState = N42Attributes.ContentState(value: value)
            Task {
                await activity?.update(using: updateState)
                result("true")
            }

        case "LiveActivityEnd":
            guard #available(iOS 16.1, *) else {
                result(FlutterError(code: "LiveActivityError",
                                    message: "iOS version must be greater than 16.1", details: nil))
                return
            }
            guard let args = call.arguments as? [String: Any],
                  let value = args["value"] as? Int else {
                result(FlutterError(code: "arguments_null", message: "value is null", details: nil))
                return
            }
            av_stop()
            let endState = N42Attributes.ContentState(value: value)
            Task {
                await activity?.end(using: endState, dismissalPolicy: .immediate)
                result("true")
            }

        // ── Permissions ───────────────────────────────────────────────────

        case "Permissions":
            guard let args = call.arguments as? [String: String],
                  let pName = args["pName"] else {
                result("")
                return
            }
            switch pName {
            case "Camera": result(getCameraPermission())
            case "Photo":  result(getPhotoPermission())
            default:       result("")
            }

        case "getPubKeySOL":
            guard let args = call.arguments as? [String: String],
                  let address = args["address"],
                  let mintAddress = args["mintAddress"] else {
                result("")
                return
            }
            result(SolanaAddress(string: address)?.defaultTokenAddress(tokenMintAddress: mintAddress) ?? "")

        // ── Mining ────────────────────────────────────────────────────────

        case "MiningGenerateBls12381Keypair":
            switch MobileSdk.generateBls12381Keypair() {
            case .success(let keyPair): result(keyPair)
            case .failure(let error):   result(FlutterError(code: "DepositError", message: "\(error)", details: nil))
            }

        case "MiningCreateDepositUnsignedTx":
            guard let args = call.arguments as? [String: Any],
                  let depositContractAddress = args["depositContractAddress"] as? String,
                  let validatorPrivateKey = args["validatorPrivateKey"] as? String,
                  let withdrawalAddress = args["withdrawalAddress"] as? String,
                  let depositValueWeiInHex = args["depositValueWeiInHex"] as? String else {
                result(FlutterError(code: "arguments_null", message: "invalid arguments", details: nil))
                return
            }
            switch MobileSdk.createDepositUnsignedTx(
                depositContractAddress: depositContractAddress,
                validatorPrivateKey: validatorPrivateKey,
                withdrawalAddress: withdrawalAddress,
                depositValueInWei: depositValueWeiInHex
            ) {
            case .success(let tx): result(tx)
            case .failure(let error): result(FlutterError(code: "DepositError", message: "\(error)", details: nil))
            }

        case "MiningCreateExitUnsignedTx":
            guard let args = call.arguments as? [String: Any],
                  let validatorPublicKey = args["validatorPublicKey"] as? String,
                  let feeWeiInHex = args["feeWeiInHex"] as? String else {
                result(FlutterError(code: "arguments_null", message: "invalid arguments", details: nil))
                return
            }
            switch MobileSdk.createExitUnsignedTx(validatorPublicKey: validatorPublicKey,
                                                   feeInWeiOrEmpty: feeWeiInHex) {
            case .success(let tx): result(tx)
            case .failure(let error): result(FlutterError(code: "ExitError", message: "\(error)", details: nil))
            }

        case "MiningCreateGetExitFeeUnsignedTx":
            switch MobileSdk.createGetExitFeeUnsignedTx() {
            case .success(let tx): result(tx)
            case .failure(let error): result(FlutterError(code: "DepositError", message: "\(error)", details: nil))
            }

        case "MiningRunClient":
            guard let args = call.arguments as? [String: Any],
                  let wsUrl = args["wsUrl"] as? String,
                  let validatorPrivateKey = args["validatorPrivateKey"] as? String else {
                result(FlutterError(code: "arguments_null", message: "invalid arguments", details: nil))
                return
            }
            MobileSdk.runClient(wsUrl: wsUrl, validatorPrivateKey: validatorPrivateKey) { mobileResult in
                switch mobileResult {
                case .success:          result("Client started")
                case .failure(let err): result(FlutterError(code: "ClientError", message: "\(err)", details: nil))
                }
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

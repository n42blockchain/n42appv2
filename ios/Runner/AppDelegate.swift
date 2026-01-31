import Flutter
import ActivityKit
import UIKit
import WalletCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      /*FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(withRegistry: registry)
      }*/

      /// ios notification添加
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }
      GeneratedPluginRegistrant.register(with: self)
      // ⭐️⭐️⭐️ 关键
          TrustdartPlugin.register(
            with: self.registrar(forPlugin: "TrustdartPlugin")!
          )
      guard let controller = self.window?.rootViewController as? FlutterViewController else {
          return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      }
      let channel = FlutterMethodChannel(name: "trustdart", binaryMessenger: controller as! any FlutterBinaryMessenger as FlutterBinaryMessenger)

      channel.setMethodCallHandler { (call, result) in
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
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    public func getKeyStore(wallet: HDWallet, path: String,coin: String,passphrase:String,addressType:String)->String{
        var coinType: CoinType? = getCoinTypeWithCoinString(coin: coin)
        if coinType == nil{
            return ""
        }
        var pk:PrivateKey=wallet.getKey(coin: coinType!, derivationPath: path)
        var address:String = ""
        switch coin {
        case "BTC":
            let privateKey = wallet.getKey(coin: CoinType.bitcoin, derivationPath: path)
            let publicKey = privateKey.getPublicKeySecp256k1(compressed: true)
            if addressType == "legacy"{
                address=BitcoinAddress(publicKey: publicKey, prefix: 0)!.description
            }else{
                address=CoinType.bitcoin.deriveAddress(privateKey: privateKey)
            }
        case "LTC":
            let privateKey = wallet.getKey(coin: CoinType.litecoin, derivationPath: path)
            let publicKey = privateKey.getPublicKeySecp256k1(compressed: true)
            if addressType == "legacy"{
                address=BitcoinAddress(publicKey: publicKey, prefix: 48)!.description
            }else{
                address=CoinType.litecoin.deriveAddress(privateKey: privateKey)
            }
        default:
            address=""
        }
        
        var key:StoredKey? = StoredKey.importPrivateKey(privateKey: pk.data, name: coin, password: Data(passphrase.utf8), coin: coinType!)
        if address != "" {
            var account: Account = key!.account(index: 0)!
            key!.removeAccountForCoin(coin: account.coin)
            key!.addAccount(address: address, coin: account.coin, derivationPath: path, publicKey: account.publicKey, extendedPublicKey: account.extendedPublicKey)
        }
        let jsonString : String = String(data:key!.exportJSON()!,encoding: String.Encoding.utf8)!
        return jsonString
    }
    public func getWalletInfoWithKeyStore(keyStore:String,passphrase:String,coinType:String) ->[String: Any?]{
        let ksArray : Data? = keyStore.data(using: String.Encoding.utf8)//try? JSONSerialization.data(withJSONObject: keyStore, options: [])
        let pwArray : Data? = passphrase.data(using: String.Encoding.utf8)
        let storedKey = StoredKey.importJSON(json: ksArray!)
        let coint:CoinType = storedKey!.account(index: 0)!.coin
        let privateKey : PrivateKey  = storedKey!.privateKey(coin: coint, password: pwArray!)!
        let path:String = storedKey!.account(index: 0)!.derivationPath
        var addressType : String = "legacy"
        let chainType=self.getChainTypeWithCoinString(coin: coinType)
        var isBitcoin=false
        if chainType == "Bitcoin"{
            isBitcoin=true
        }
        if isBitcoin==true{
            let list84 = path.replacingOccurrences(of: "84", with: "a").split(separator: "a")
            if list84.count > 1{
                addressType="segwit"
            }
        }
        let addressMap=generateAddress_pk(privateKey: privateKey, coin: coinType, addressType: addressType,coinType: coint,isTest: "false")
        return ["address":addressMap,"privateKey":privateKey.data.base64EncodedString(),"addressType":addressType]
    }
    public func generateAddress(wallet: HDWallet, path: String, coin: String,addressType: String,isTest:String) -> [String: String]? {
        let coinType: CoinType? = self.getCoinTypeWithCoinString(coin: coin)
        if coinType == nil{
            return nil
        }
        let privateKey = wallet.getKey(coin: coinType!, derivationPath: path)
        return self.generateAddress_pk(privateKey: privateKey, coin: coin, addressType: addressType,coinType: coinType,isTest: isTest)
    }
    public func generateAddress_pk(privateKey: PrivateKey, coin: String,addressType: String,coinType:CoinType?,isTest:String) -> [String: String]? {
        let chainType:String?=self.getChainTypeWithCoinString(coin: coin)
        var cType:CoinType?=coinType
        if cType == nil{
            cType = self.getCoinTypeWithCoinString(coin: coin)
        }
        if cType == nil{
            return nil
        }
        var addressMap: [String: String]?
        if chainType == "Bitcoin"{
            let publicKey = privateKey.getPublicKeySecp256k1(compressed: true)
            let legacyAddress = BitcoinAddress(publicKey: publicKey, prefix: cType!.p2shPrefix)
            if coin=="BCH" || coin=="DOGE" || coin=="DASH"{
                addressMap = ["legacy": legacyAddress!.description,]
            }else{
                var btcAddr : String
                if isTest == "true"{
                    btcAddr = cType!.deriveAddressFromPublicKeyAndDerivation(publicKey: publicKey, derivation: Derivation.bitcoinTestnet)
                }else{
                    btcAddr = cType!.deriveAddress(privateKey: privateKey)
                }
                addressMap = ["legacy": legacyAddress!.description,
                              "segwit": btcAddr,
                ]
            }
        }else{
            addressMap = ["legacy": cType!.deriveAddress(privateKey: privateKey)]
        }
        return addressMap
    }
    //验证某链地址是否正确
    func validateAddress(address: String, coin: String) -> Bool {
        var coinType:CoinType? = getCoinTypeWithCoinString(coin: coin)
        if coinType != nil{
            return coinType!.validate(address: address)
        }else{
            return false
        }
    }
    
    func getPublicKey(wallet: HDWallet, path: String, coin: String) -> String? {
        let chainType:String = self.getChainTypeWithCoinString(coin: coin)
        let coinType:CoinType? = self.getCoinTypeWithCoinString(coin: coin)
        let privateKey = wallet.getKey(coin: coinType!, derivationPath: path)
        var publicKey: String?
        switch chainType{
        case "Bitcoin":
            publicKey = privateKey.getPublicKeySecp256k1(compressed: true).data.base64EncodedString()
            break
        case "Ethereum":
            publicKey = privateKey.getPublicKeySecp256k1(compressed: true).data.base64EncodedString()
            break
        case "Tron":
            publicKey = privateKey.getPublicKeySecp256k1(compressed: true).data.base64EncodedString()
            break
        case "Tezos":
            publicKey = privateKey.getPublicKeyEd25519().data.base64EncodedString()
            break
        case "Solana":
            publicKey = privateKey.getPublicKeyEd25519().data.base64EncodedString()
            break
        case "Ripple":
            publicKey = privateKey.getPublicKeySecp256k1(compressed: true).data.base64EncodedString()
            break
        case "Cosmos":
            publicKey = privateKey.getPublicKeySecp256k1(compressed: true).data.base64EncodedString()
            break
        case "Filecoin":
            publicKey = privateKey.getPublicKeySecp256k1(compressed: true).data.base64EncodedString()
            break
        default:
            publicKey = nil
        }
        return publicKey
    }
    //返回 某个链的 私钥
    func getPrivateKey(wallet: HDWallet, path: String, coin: String) -> String {
        var coinType:CoinType? = getCoinTypeWithCoinString(coin: coin)
        if coinType != nil{
            var privateKey: String=wallet.getKey(coin: coinType!, derivationPath: path).data.base64EncodedString()
            return privateKey
        }else{
            return ""
        }
    }
    func signTransaction_maxValue(wallet: HDWallet?, coin: String, path: String, txData: [String: Any],pk: PrivateKey?) -> String? {
        let chainType:String = self.getChainTypeWithCoinString(coin: coin)
        let coinType:CoinType? = self.getCoinTypeWithCoinString(coin: coin)
        var txHash: String?
        switch chainType{
        case "Bitcoin":
            txHash = signBitcoinTransaction_maxValue(wallet: wallet, path: path, txData: txData,coinType: coinType!,pk: pk)
            break
        default:
            txHash=nil
        }
        return txHash
    }
    func signTransaction(wallet: HDWallet?, coin: String, path: String, txData: [String: Any],pk: PrivateKey?) -> String? {
        let chainType:String = self.getChainTypeWithCoinString(coin: coin)
        let coinType:CoinType? = self.getCoinTypeWithCoinString(coin: coin)
        var txHash: String?
        switch chainType{
        case "Bitcoin":
            txHash = signBitcoinTransaction(wallet: wallet, path: path, txData: txData,coinType: coinType!,pk: pk)
            break
        case "Ethereum":
            txHash = signEthereumTransaction_erc721(wallet: wallet, path: path, txData: txData,coinType: coinType!,privateKey: pk)
            break
        case "Tron":
            txHash = signTronTransaction(wallet: wallet, path: path, txData: txData,pk: pk)
            break
        case "Tezos":
            txHash = signTezosTransaction(wallet: wallet, path: path, txData: txData,pk: pk)
            break
        case "Solana":
            txHash = signSolanaTransaction(wallet: wallet, path: path, txData: txData,pk: pk)
            break
        case "Ripple":
            txHash = signXrpTransaction(wallet: wallet, path: path, txData: txData,pk: pk)
            break
        case "Cosmos":
            txHash = signCosmosTransaction(wallet: wallet, path: path, txData: txData,pk: pk)
            break
        case "Filecoin":
            txHash = signFilecoinTransaction(wallet: wallet, path: path, txData: txData, coinType: coinType!, privateKey: pk)
            break
        case "Polkadot":
            txHash = signPolkadotTransaction(wallet: wallet, path: path, txData: txData, coinType: coinType!, privateKey: pk)
            break
        case "Acala":
            txHash = signPolkadotTransaction(wallet: wallet, path: path, txData: txData, coinType: coinType!, privateKey: pk)
            break
        case "Kusama":
            txHash = signPolkadotTransaction(wallet: wallet, path: path, txData: txData, coinType: coinType!, privateKey: pk)
            break
        case "Aptos":
            txHash = signAptosTransaction(wallet: wallet, path: path, txData: txData, privateKey: pk)
            break
        case "Sui":
            txHash = signSuiTransaction(wallet: wallet, path: path, txData: txData, privateKey: pk)
            break
        case "Ton":
            txHash = signTonTransaction(wallet: wallet, path: path, txData: txData, privateKey: pk)
            break
        case "Zilliqa":
            txHash = signZilTransaction(wallet: wallet, path: path, txData: txData, privateKey: pk)
            break
        default:
            txHash=nil
        }
        return txHash
    }
    func signTransaction_byteArray(wallet: HDWallet?, coin: String, path: String, txData: [String: Any],pk: PrivateKey?) -> String? {
        var txHash: String?
        switch coin {
        case "ALGO":
            txHash = signAlgorandTransaction(wallet: wallet, path: path, txData: txData,coinType: CoinType.algorand, privateKey: pk)
        
        default:
            txHash = objToJson(from: ["result":false,"signHash":""])
        }
        return txHash

    }
    func signMessage(wallet: HDWallet?, coin: String, path: String, txData: String,pk: PrivateKey?) -> String? {
        let chainType:String = self.getChainTypeWithCoinString(coin: coin)
        let coinType:CoinType? = self.getCoinTypeWithCoinString(coin: coin)
        var txHash: String?
        var privateKey : PrivateKey
        if pk == nil{
            privateKey=wallet!.getKey(coin:  coinType!, derivationPath: path)
        }else {
            privateKey=pk!
        }
        if let curve = coinType?.curve {
            if let digestData = handHexData(from: txData) {
                if let ba = privateKey.sign(digest: digestData, curve: curve) {
                    return ba.hexString
                }
            }
        }
              
        return nil
    }
    private func objToJson(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    func signCosmosTransaction(wallet: HDWallet?,path:String,txData: [String: Any],pk: PrivateKey?)-> String?{
        var privateKey : PrivateKey
        if pk == nil{
            privateKey=wallet!.getKey(coin:  CoinType.cosmos, derivationPath: path)
        }else {
            privateKey=pk!
        }
        let fromAddress : String = CoinType.cosmos.deriveAddress(privateKey: privateKey)
        let toAddress:String = txData["toAddress"] as! String
        let gas : UInt64 = 200000//Int64.init(txData["gas"] as! String)!
        let amount : String = txData["amount"] as! String
        let accountNumber : UInt64 = 1383322//Int64.init(txData["accountNumber"] as! String)!
        let sequence : UInt64 = 0//Int64.init(txData["sequence"] as! String)!
        
        var input = CosmosSigningInput.with{
            $0.privateKey = privateKey.data
            $0.sequence = sequence
            //$0.chainID = "gaia-13003"
            $0.chainID = "cosmoshub-4"
            $0.accountNumber = accountNumber
            $0.memo = ""
            $0.mode = TW_Cosmos_Proto_BroadcastMode.block
            $0.fee=CosmosFee.with{
                $0.gas=gas
                $0.amounts=[
                    CosmosAmount.with{
                        $0.amount="200"
                        $0.denom="uatom"
                    }
                ]
            }
            $0.messages=[
                CosmosMessage.with{
                    $0.sendCoinsMessage=CosmosMessage.Send.with{
                        $0.fromAddress=fromAddress.description
                        $0.toAddress=toAddress
                        $0.amounts=[
                            CosmosAmount.with{
                                $0.amount=amount
                                $0.denom="uatom"
                            }
                        ]
                    }
                }
            ]
        }
        let output: CosmosSigningOutput = AnySigner.sign(input: input, coin: CoinType.cosmos)
        return output.json
    }
    func signTezosTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],pk: PrivateKey?) -> String? {
        var privateKey : PrivateKey
        if pk == nil{
              privateKey=wallet!.getKey(coin: CoinType.tezos, derivationPath: path)
        }else {
            privateKey=pk!
        }
        let branchStr: String = txData["branch"] as! String
        let reveal: Bool = txData["reveal"] as! Bool
        let counter: Int64 = txData["counter"] as! Int64
        let amount: Int64 = txData["amount"] as! Int64
        let toAddress: String = txData["toAddress"] as! String
        let fee : Int64 = txData["fee"] as! Int64
        let gasLimit : Int64 = txData["gasLimit"] as! Int64
        let storageLimit : Int64 = txData["storageLimit"] as! Int64
        let contractAddres : String = txData["contractAddres"] as! String
        let fromAddress : String = CoinType.tezos.deriveAddress(privateKey: privateKey)
        
        var tOperation : TezosOperation = TezosOperation.init()
        tOperation.storageLimit=storageLimit
        tOperation.fee=fee
        tOperation.kind=TW_Tezos_Proto_Operation.OperationKind.transaction
        tOperation.source=fromAddress
        tOperation.gasLimit=gasLimit
        
        var transactionOperationData = TezosTransactionOperationData.init()
        if contractAddres=="" {
            transactionOperationData.amount=amount
            transactionOperationData.destination=toAddress
        }else {
            transactionOperationData.amount=0
            transactionOperationData.destination=contractAddres
            transactionOperationData.parameters.fa12Parameters.entrypoint = "transfer"
            transactionOperationData.parameters.fa12Parameters.from = fromAddress
            transactionOperationData.parameters.fa12Parameters.to = toAddress
            transactionOperationData.parameters.fa12Parameters.value = String(amount)
        }
        tOperation.transactionOperationData=transactionOperationData
        var input = TezosSigningInput.with{
            $0.privateKey = privateKey.data
        }
        if reveal == false {
            tOperation.counter=counter+1
            input.operationList = TezosOperationList.with{
                $0.branch = branchStr
                $0.operations.append(
                   TezosOperation.with{
                       $0.storageLimit=storageLimit
                       $0.fee=fee
                       $0.kind=TW_Tezos_Proto_Operation.OperationKind.reveal
                       $0.source=fromAddress
                       $0.gasLimit=gasLimit
                       $0.counter=counter
                       $0.revealOperationData=TezosRevealOperationData.with{
                           $0.publicKey=privateKey.getPublicKeyEd25519().data
                       }
                   }
                )
                $0.operations.append(tOperation)
            }
        }else{
            tOperation.counter=counter
            input.operationList = TezosOperationList.with{
                $0.branch = branchStr
                $0.operations.append(tOperation)
            }
        }
        let result: TezosSigningOutput = AnySigner.sign(input: input, coin: CoinType.tezos)
        return result.encoded.hexString
    }
    func signXrpTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],pk: PrivateKey?) -> String? {
        var privateKey : PrivateKey
        if pk == nil{
              privateKey=wallet!.getKey(coin: CoinType.xrp, derivationPath: path)
        }else {
              privateKey=pk!
        }
        let amount: Int64 = Int64.init(txData["amount"] as! String)!
        let sequence : Int32 = txData["sequence"] as! Int32
        let ledgerIndex : Int32 = txData["ledgerIndex"] as! Int32
        let fee : Int64 = Int64.init(txData["fee"] as! String)!
        let account : String = CoinType.xrp.deriveAddress(privateKey: privateKey)
        let destination : String = txData["toAddress"] as! String
        let txType : String = txData["txType"] as! String//Trustline,XRP,XRPL,
        let issuer : String = txData["issuer"] as! String
        let currency : String = txData["currency"] as! String
        
        var input = RippleSigningInput.with{
            $0.privateKey=privateKey.data
            $0.fee=fee
            $0.sequence=UInt32(sequence)
            $0.lastLedgerSequence = UInt32(ledgerIndex+20)
            $0.account=account
        }
        
        if txType == "Trustline" {
            input.opTrustSet=RippleOperationTrustSet.with{
                $0.limitAmount=RippleCurrencyAmount.with{
                    $0.currency=currency
                    $0.issuer=issuer
                    $0.value=String(amount)
                }
            }
        }else if txType == "XRPL" {
            input.opPayment=RippleOperationPayment.with{
                $0.currencyAmount=RippleCurrencyAmount.with{
                    $0.currency=currency
                    $0.issuer=issuer
                    $0.value=String(amount)
                }
            }
        }else {
            input.opPayment=RippleOperationPayment.with{
                $0.destination=destination
                $0.amount=amount
            }
        }
        
        
        let result: RippleSigningOutput = AnySigner.sign(input: input, coin: CoinType.xrp)
        return result.encoded.hexString
     }
    
    func signEthereumTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],coinType:CoinType,privateKey: PrivateKey?) -> String? {

//        let privateKey = wallet!.getKey(coin: coinType, derivationPath: path)
        var pk: PrivateKey
        if privateKey == nil{
            pk=wallet!.getKey(coin: coinType, derivationPath: path)
        }else{
            pk = privateKey!
        }
        
        let chainId : String = txData["chainId"] as! String
        let gasLimit : String = txData["gasLimit"] as! String
        let gasPrice : String = txData["gasPrice"] as! String
        let nonce : String = txData["nonce"] as! String
        let toAddress : String = txData["toAddress"] as! String
        let amount : String = txData["amount"] as! String
        
        var input = EthereumSigningInput.with{
            //Data(hexString: gasPrice)!
            $0.chainID = handHexData(from: chainId)!
            $0.gasPrice = handHexData(from: gasPrice)!
            $0.gasLimit = handHexData(from: gasLimit)!
            $0.nonce = handHexData(from: nonce)!
            $0.privateKey=pk.data
        }
        let contract: String = txData["contract"] as! String
        if contract == "" {
            input.toAddress=toAddress
            input.transaction=EthereumTransaction.with{
                $0.transfer = EthereumTransaction.Transfer.with {
//                    $0.amount = Data(hexString: amount)
                    $0.amount = handHexData(from: amount)!
                }
            }
        }else{
            input.toAddress=contract
            input.transaction=EthereumTransaction.with{
                $0.erc20Transfer=EthereumTransaction.ERC20Transfer.with{
//                    $0.amount=Data(hexString: amount)!
                    $0.amount = handHexData(from: amount)!
                    $0.to=toAddress
                }
            }
        }
        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: coinType)
        return output.encoded.hexString
        /*let privateKey = wallet.getKey(coin: CoinType.ethereum, derivationPath: path)
        let opJson =  objToJson(from:txData)
        let result = AnySigner.signJSON(opJson!, key: privateKey.data, coin: CoinType.ethereum)
        return result*/
      }
    func signEthereumTransaction_erc721(wallet: HDWallet?, path: String, txData:  [String: Any],coinType:CoinType,privateKey: PrivateKey?) -> String? {
        var pk: PrivateKey
        if privateKey == nil{
            pk=wallet!.getKey(coin: coinType, derivationPath: path)
        }else{
            pk = privateKey!
        }

        let chainId : String = txData["chainId"] as! String
        let gasLimit : String = txData["gasLimit"] as! String
        let gasPrice : String = txData["gasPrice"] as! String
        let gasPrice2 : String = txData["gasPrice2"] as! String
        let nonce : String = txData["nonce"] as! String
        let toAddress : String = txData["toAddress"] as! String
        let amount : String = txData["amount"] as! String
        let erc721Or1155 : String = txData["erc721Or1155"] as! String
        let messageData :String = txData["msgData"] as! String
        let is1559 : String = txData["is1559"] as! String

        var input = EthereumSigningInput.with{
            //Data(hexString: gasPrice)!
            //$0.txMode = TW_Ethereum_Proto_TransactionMode.enveloped
            $0.chainID = handHexData(from: chainId)!
            //$0.gasPrice = handHexData(from: gasPrice)!
            //$0.maxInclusionFeePerGas = handHexData(from: gasPrice2)!
            //$0.maxFeePerGas = handHexData(from: gasPrice)!
            $0.gasLimit = handHexData(from: gasLimit)!
            $0.nonce = handHexData(from: nonce)!
            $0.privateKey=pk.data
        }
        if is1559 == "true" {
            input.maxFeePerGas=handHexData(from: gasPrice)!
            input.maxInclusionFeePerGas = handHexData(from: gasPrice2)!
            input.txMode = TW_Ethereum_Proto_TransactionMode.enveloped
        }else{
            input.gasPrice=handHexData(from: gasPrice)!
            input.txMode = TW_Ethereum_Proto_TransactionMode.legacy
        }
        let contract: String = txData["contract"] as! String
        if contract == "" {
            input.toAddress=toAddress
            input.transaction=EthereumTransaction.with{
                $0.transfer = EthereumTransaction.Transfer.with {
//                    $0.amount = Data(hexString: amount)
                    $0.amount = handHexData(from: amount)!
                    $0.data = handHexData(from: messageData)!
                    //Data(from: String.Encoding.utf8 as! Decoder)！
                    //Data.init(messageData.Encoding.utf8)
                }
            }
        }else if erc721Or1155 == "721" {
            let fromAddress: String = coinType.deriveAddress(privateKey: pk)
            let tokenId: String = txData["tokenId"] as! String
            input.toAddress=contract
            input.transaction=EthereumTransaction.with{
                $0.erc721Transfer=EthereumTransaction.ERC721Transfer.with{
                    $0.from = fromAddress
                    $0.tokenID = handHexData(from: tokenId)!
                    $0.to=toAddress
                }
            }
        }else if erc721Or1155 == "1155" {
            let fromAddress: String = coinType.deriveAddress(privateKey: pk)
            let tokenId: String = txData["tokenId"] as! String
            let trValue: String = txData["trValue"] as! String
            input.toAddress=contract
            input.transaction=EthereumTransaction.with{
                $0.erc1155Transfer=EthereumTransaction.ERC1155Transfer.with{
                    $0.from = fromAddress
                    $0.tokenID = handHexData(from: tokenId)!
                    $0.to=toAddress
                    $0.value=handHexData(from: trValue)!
                }
            }
        }else if erc721Or1155 == "approve"{
            input.toAddress=contract
            input.transaction=EthereumTransaction.with{
                $0.erc20Approve=EthereumTransaction.ERC20Approve.with{
                    $0.amount=handHexData(from: amount)!
                    $0.spender=toAddress
                }
            }
        }
        else{
            input.toAddress=contract
            input.transaction=EthereumTransaction.with{
                $0.erc20Transfer=EthereumTransaction.ERC20Transfer.with{
//                    $0.amount=Data(hexString: amount)!
                    $0.amount = handHexData(from: amount)!
                    $0.to=toAddress
                }
            }
        }
        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: coinType)
        return output.encoded.hexString
      }

    func signSolanaTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],pk: PrivateKey?) -> String? {
        var privateKey : PrivateKey
        if pk == nil{
              privateKey=wallet!.getKey(coin: CoinType.solana, derivationPath: path)
        }else {
            privateKey=pk!
        }
        let type = txData["type"] as! String
        let encodeType = txData["encodeType"] as! String
        var txHash: String?
        if type == "token" {
            let transferTransaction = txData["tokenTransferTransaction"] as! [String:String]
            let amount : String = transferTransaction["amount"] as! String
            let tokenMintAddress = transferTransaction["tokenMintAddress"] as! String
            let recipient = SolanaAddress(string: transferTransaction["recipientMainAddress"] as! String)?.defaultTokenAddress(tokenMintAddress: tokenMintAddress)
            let senderTokenAddress = SolanaAddress(string: transferTransaction["senderTokenAddress"] as! String)?.defaultTokenAddress(tokenMintAddress: tokenMintAddress)
            let decimals : String = transferTransaction["decimals"] as! String
            let contract = SolanaTokenTransfer.with{
                $0.recipientTokenAddress = recipient!
                $0.amount = UInt64.init(amount)!
                $0.tokenMintAddress = tokenMintAddress
                $0.senderTokenAddress = senderTokenAddress!
                $0.decimals = UInt32.init(decimals)!
            }
            var input = SolanaSigningInput.init()
            input.privateKey = privateKey.data
            input.tokenTransferTransaction = contract
            input.recentBlockhash = txData["recentBlockhash"] as! String
            let output: SolanaSigningOutput = AnySigner.sign(input: input, coin: CoinType.solana)
            txHash = output.encoded
        }else if type == "tokenCreate" {
            let transferTransaction = txData["tokenTransferTransaction"] as! [String:String]
            var recipientTokenAddress : String = transferTransaction["recipientTokenAddress"] as! String
            let recipientMainAddress : String = transferTransaction["recipientMainAddress"] as! String
            let amount : String = transferTransaction["amount"] as! String
            let tokenMintAddress = transferTransaction["tokenMintAddress"] as! String
            let senderTokenAddress = SolanaAddress(string: transferTransaction["senderTokenAddress"] as! String)?.defaultTokenAddress(tokenMintAddress: tokenMintAddress)
            let decimals : String = transferTransaction["decimals"] as! String
            
            var input = SolanaSigningInput.init()
            input.privateKey = privateKey.data
            input.recentBlockhash = txData["recentBlockhash"] as! String
            if recipientTokenAddress == "" {
                recipientTokenAddress = (SolanaAddress(string: recipientMainAddress)?.defaultTokenAddress(tokenMintAddress: tokenMintAddress))!
                input.createAndTransferTokenTransaction=SolanaCreateAndTransferToken.with{
                    $0.amount = UInt64.init(amount)!
                    $0.tokenMintAddress = tokenMintAddress
                    $0.senderTokenAddress = senderTokenAddress!
                    $0.decimals = UInt32.init(decimals)!
                    $0.recipientTokenAddress=recipientTokenAddress
                    $0.recipientMainAddress=recipientMainAddress
                }
            }else {
                input.tokenTransferTransaction=SolanaTokenTransfer.with{
                    $0.recipientTokenAddress = recipientTokenAddress
                    $0.amount = UInt64.init(amount)!
                    $0.tokenMintAddress = tokenMintAddress
                    $0.senderTokenAddress = senderTokenAddress!
                    $0.decimals = UInt32.init(decimals)!
                }
            }
            let output: SolanaSigningOutput = AnySigner.sign(input: input, coin: CoinType.solana)
            txHash = output.encoded
        }
        else{
            let transferTransaction = txData["transferTransaction"] as! [String:String]
            let recipient = transferTransaction["recipient"] as! String
            let value : String = transferTransaction["value"] as! String
            let contract = SolanaTransfer.with {
                $0.value = UInt64(value)!
                $0.recipient = recipient
            }
            var input = SolanaSigningInput.init()
            input.recentBlockhash = txData["recentBlockhash"] as! String
            input.privateKey = privateKey.data
            input.transferTransaction = contract
            let output: SolanaSigningOutput = AnySigner.sign(input: input, coin: CoinType.solana)
            txHash = output.encoded
        }
        return txHash
        /*
        let opJson =  objToJson(from:txData)
        let result = AnySigner.signJSON(opJson!, key: privateKey.data, coin: CoinType.solana)
        return result
         */
      }
    
    func signTronTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],pk:PrivateKey?) -> String? {
       let cmd = txData["cmd"] as! String
        var txHash: String?
        var privateKey : PrivateKey
        if pk == nil{
              privateKey=wallet!.getKey(coin: CoinType.tron, derivationPath: path)
        }else {
            privateKey=pk!
        }
        switch cmd {
        case "TRC20":
                let contract = TronTransferTRC20Contract.with {
                    $0.ownerAddress = txData["ownerAddress"] as! String
                    $0.toAddress = txData["toAddress"] as! String
                    $0.contractAddress = txData["contractAddress"] as! String
                    //$0.amount = Data(count: txData["amount"] as! Int64)!
                    $0.amount = handHexData(from: txData["amount"] as! String)!
                    //Data(hexString: txData["amount"] as! String)!
                }
                
                let input = TronSigningInput.with {
                    $0.transaction = TronTransaction.with {
                        $0.feeLimit = txData["feeLimit"] as! Int64
                        $0.transferTrc20Contract = contract
                        $0.timestamp = txData["timestamp"] as! Int64
                        $0.blockHeader = TronBlockHeader.with {
                            $0.timestamp = txData["blockTime"] as! Int64
                            $0.number = txData["number"] as! Int64
                            $0.version = txData["version"] as! Int32
                            $0.txTrieRoot = Data(hexString: txData["txTrieRoot"] as! String)!
                            $0.parentHash = Data(hexString: txData["parentHash"] as! String)!
                            $0.witnessAddress = Data(hexString: txData["witnessAddress"] as! String)!
                        }
                    }
                    $0.privateKey = privateKey.data
                }
                let output: TronSigningOutput = AnySigner.sign(input: input, coin: CoinType.tron)
                txHash = output.json
        case "TRC10":
            let transferAsset = TronTransferAssetContract.with {
                $0.ownerAddress = txData["ownerAddress"] as! String
                $0.toAddress = txData["toAddress"] as! String
                $0.amount = txData["amount"] as! Int64
                $0.assetName = txData["assetName"] as! String
            }
            let input = TronSigningInput.with {
                $0.transaction = TronTransaction.with {
                    $0.transferAsset = transferAsset
                    $0.timestamp = txData["timestamp"] as! Int64
                    $0.blockHeader = TronBlockHeader.with {
                        $0.timestamp = txData["blockTime"] as! Int64
                        $0.number = txData["number"] as! Int64
                        $0.version = txData["version"] as! Int32
                        $0.txTrieRoot = Data(hexString: txData["txTrieRoot"] as! String)!
                        $0.parentHash = Data(hexString: txData["parentHash"] as! String)!
                        $0.witnessAddress = Data(hexString: txData["witnessAddress"] as! String)!
                    }
                }
                $0.privateKey = privateKey.data
            }
            let output: TronSigningOutput = AnySigner.sign(input: input, coin: CoinType.tron)
            txHash = output.json
        case "TRX":
            let transfer = TronTransferContract.with {
                $0.ownerAddress = txData["ownerAddress"] as! String
                $0.toAddress = txData["toAddress"] as! String
                $0.amount = txData["amount"] as! Int64
            }
            let input = TronSigningInput.with {
                $0.transaction = TronTransaction.with {
                    $0.transfer = transfer
                    $0.timestamp = txData["timestamp"] as! Int64
                    $0.blockHeader = TronBlockHeader.with {
                        $0.timestamp = txData["blockTime"] as! Int64
                        $0.number = txData["number"] as! Int64
                        $0.version = txData["version"] as! Int32
                        $0.txTrieRoot = Data(hexString: txData["txTrieRoot"] as! String)!
                        $0.parentHash = Data(hexString: txData["parentHash"] as! String)!
                        $0.witnessAddress = Data(hexString: txData["witnessAddress"] as! String)!
                    }
                }
                $0.privateKey = privateKey.data
            }
            let output: TronSigningOutput = AnySigner.sign(input: input, coin: CoinType.tron)
            txHash = output.json
        case "CONTRACT":
            txHash = ""
        case "FREEZE":
            let contract = TronFreezeBalanceContract.with {
                $0.frozenBalance = txData["frozenBalance"] as! Int64
                $0.frozenDuration = txData["frozenDuration"] as! Int64
                $0.ownerAddress = txData["ownerAddress"] as! String
                $0.resource = txData["resource"] as! String
            }
            let input = TronSigningInput.with {
                $0.transaction = TronTransaction.with {
                    $0.freezeBalance = contract
                    $0.timestamp = txData["timestamp"] as! Int64
                    $0.blockHeader = TronBlockHeader.with {
                        $0.timestamp = txData["blockTime"] as! Int64
                        $0.number = txData["number"] as! Int64
                        $0.version = txData["version"] as! Int32
                        $0.txTrieRoot = Data(hexString: txData["txTrieRoot"] as! String)!
                        $0.parentHash = Data(hexString: txData["parentHash"] as! String)!
                        $0.witnessAddress = Data(hexString: txData["witnessAddress"] as! String)!
                    }
                }
                $0.privateKey = privateKey.data
            }
            let output: TronSigningOutput = AnySigner.sign(input: input, coin: CoinType.tron)
            txHash = output.json
        default:
            txHash = nil
        }
        return txHash
    }

    func signBitcoinTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],coinType: CoinType,pk: PrivateKey?) -> String? {
        //if wallet == nil { return nil}
        //let privateKey = wallet!.getKey(coin: coinType, derivationPath: path)
        var privateKey : PrivateKey
        if pk == nil{
            privateKey=wallet!.getKey(coin: coinType, derivationPath: path)
        }else {
            privateKey=pk!
        }
        let utxos: [[String: Any]] = txData["utxo"] as! [[String: Any]]
        var unspent: [BitcoinUnspentTransaction] = []
        let max: Bool = txData["max"] as! Bool
        var input: BitcoinSigningInput = BitcoinSigningInput.with {
            $0.hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)//TWBitcoinSigHashTypeAll.rawValue
            //$0.amount = txData["amount"] as! Int64
            //$0.useMaxAmount=max
            $0.byteFee=txData["byteFee"] as! Int64
            $0.toAddress = txData["toAddress"] as! String
            $0.changeAddress = txData["changeAddress"] as! String // can be same sender address
            $0.coinType=coinType.rawValue
            $0.privateKey = [privateKey.data]
        }
        //var scripts = [String: Data]()
        if max==true{
            input.useMaxAmount=true;
        }else{
            input.amount=txData["amount"] as! Int64
        }
        for utx in utxos {
            let lockScript: Data = Data(hexString: utx["script"] as! String)!
            unspent.append(BitcoinUnspentTransaction.with {
                $0.outPoint.hash = Data.reverse(hexString: utx["txid"] as! String)
                //Data(Data(hexString: utx["txid"] as! String)!.reversed())
                $0.outPoint.index = utx["vout"] as! UInt32
                $0.outPoint.sequence = UINT32_MAX
                $0.amount = Int64.init(utx["value"] as! String)!
                $0.script = lockScript
                
            })
        }
        input.utxo=unspent
        var plan: BitcoinTransactionPlan = AnySigner.plan(input: input, coin: coinType)
        input.plan = plan
        input.amount=plan.amount
        

        var output: BitcoinSigningOutput = AnySigner.sign(input: input, coin: coinType)
        return output.encoded.hexString

    }
    func signBitcoinTransaction_p2wsh(wallet: HDWallet?, path: String, txData:  [String: Any],coinType: CoinType,pk: PrivateKey?) -> String? {
        //if wallet == nil { return nil}
        //let privateKey = wallet!.getKey(coin: coinType, derivationPath: path)
        var privateKey : PrivateKey
        if pk == nil{
            privateKey=wallet!.getKey(coin: coinType, derivationPath: path)
        }else {
            privateKey=pk!
        }
        let utxos: [[String: Any]] = txData["utxo"] as! [[String: Any]]
        var unspent: [BitcoinUnspentTransaction] = []
        let max: Bool = txData["max"] as! Bool
        var input: BitcoinSigningInput = BitcoinSigningInput.with {
            $0.hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)//TWBitcoinSigHashTypeAll.rawValue
            //$0.amount = txData["amount"] as! Int64
            //$0.useMaxAmount=max
            $0.byteFee=txData["byteFee"] as! Int64
            $0.toAddress = txData["toAddress"] as! String
            $0.changeAddress = txData["changeAddress"] as! String // can be same sender address
            $0.coinType=coinType.rawValue
            $0.lockTime=UInt32(utxos[0]["lockTime"] as! Int32)
            $0.privateKey = [privateKey.data]
        }
        //var scripts = [String: Data]()
        if max==true{
            input.useMaxAmount=true;
        }else{
            input.amount=txData["amount"] as! Int64
        }
        for utx in utxos {
            let witnessValue : String = utx["witnessValue"] as! String
            let witnessValueData = Data(hexString: witnessValue)
            let witnessValueSa256 = Hash.sha256(data: witnessValueData!)
            let witnessScript = BitcoinScript.buildPayToWitnessScriptHash(scriptHash: witnessValueSa256)
            let witnessScriptKey : String = Hash.ripemd(data: witnessValueSa256).hexString
            input.scripts[witnessScriptKey]=witnessScript.data
            //let lockScript: Data = Data(hexString: utx["script"] as! String)!
            unspent.append(BitcoinUnspentTransaction.with {
                $0.outPoint.hash = Data.reverse(hexString: utx["txid"] as! String)
                //Data(Data(hexString: utx["txid"] as! String)!.reversed())
                $0.outPoint.index = utx["vout"] as! UInt32
                $0.outPoint.sequence = UINT32_MAX
                $0.amount = Int64.init(utx["value"] as! String)!
                $0.script = witnessScript.data
            })
        }
        input.utxo=unspent
        let plan: BitcoinTransactionPlan = AnySigner.plan(input: input, coin: coinType)
        input.plan=plan
        let inputData = try? input.serializedData()
        let preImageHashes = (try? TransactionCompiler.preImageHashes(coinType: coinType, txInputData: inputData!))
        let preSigningOutput = try? BitcoinPreSigningOutput(serializedData: preImageHashes!)
        let signatureVec = DataVector()
        let pubkeyVec = DataVector()
        for h in preSigningOutput!.hashPublicKeys {
            let signature = privateKey.signAsDER(digest: h.dataHash)!
            let publicKey = privateKey.getPublicKeyNist256p1()
            
            signatureVec.add(data: signature)
            pubkeyVec.add(data: publicKey.data)
        }
        let finalTx = TransactionCompiler.compileWithSignatures(
            coinType: coinType,
            txInputData: preImageHashes!,
            signatures: signatureVec,
            publicKeys: pubkeyVec
        )
        return finalTx.hexString
    }
    func signBitcoinTransaction_maxValue(wallet: HDWallet?, path: String, txData:  [String: Any],coinType: CoinType,pk: PrivateKey?) -> String? {
        //if wallet == nil { return nil}
        //let privateKey = wallet!.getKey(coin: coinType, derivationPath: path)
        var privateKey : PrivateKey
        if pk == nil{
            privateKey=wallet!.getKey(coin: coinType, derivationPath: path)
        }else {
            privateKey=pk!
        }
        //let publicKey = privateKey.getPublicKeySecp256k1(compressed: true)
        //let address = coinType.deriveAddress(privateKey: privateKey)
                      
        //let lockScript = BitcoinScript.lockScriptForAddress(address: address, coin: coinType)
        //let scriptHash : Data = lockScript.matchPayToScriptHash() ?? Data()
        let utxos: [[String: Any]] = txData["utxo"] as! [[String: Any]]
        var unspent: [BitcoinUnspentTransaction] = []
        let max: Bool = txData["max"] as! Bool
            
        var input: BitcoinSigningInput = BitcoinSigningInput.with {
            $0.hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)//TWBitcoinSigHashTypeAll.rawValue
            $0.byteFee=txData["byteFee"] as! Int64
            $0.toAddress = txData["toAddress"] as! String
            $0.changeAddress = txData["changeAddress"] as! String // can be same sender address
            $0.coinType=coinType.rawValue
            $0.privateKey = [privateKey.data]
            //$0.scripts= [scriptHash.hexString:BitcoinScript.buildPayToWitnessPubkeyHash(hash:publicKey.bitcoinKeyHash).data]
        }
        if max==true{
            input.useMaxAmount=true;

        }else{
            input.amount=txData["amount"] as! Int64
        }
        
        
        for utx in utxos {
            let lockScript: Data = Data(hexString: utx["script"] as! String)!
            unspent.append(BitcoinUnspentTransaction.with {
                $0.outPoint.hash = Data.reverse(hexString: utx["txid"] as! String)
                //Data(Data(hexString: utx["txid"] as! String)!.reversed())
                $0.outPoint.index = utx["vout"] as! UInt32
                $0.outPoint.sequence = UINT32_MAX
                $0.amount = Int64.init(utx["value"] as! String)!
                $0.script = lockScript//.data
                
            })
        }
        //input.scripts=scripts
        input.utxo=unspent
        var plan: BitcoinTransactionPlan = AnySigner.plan(input: input, coin: coinType)
        input.plan = plan
        input.amount=plan.amount
        

        var output: BitcoinSigningOutput = AnySigner.sign(input: input, coin: coinType)
        return String.init(output.encoded.count)
        //return String.init(output.transaction.outputs[0].value)
        //return output.transaction.outputs[0].value
    }

      
    func signAlgorandTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],coinType:CoinType,privateKey: PrivateKey?) -> String? {

        var pk: PrivateKey
        if privateKey == nil{
            pk=wallet!.getKey(coin: coinType, derivationPath: path)
        }else{
            pk = privateKey!
        }
        
        let type : String = txData["type"] as! String
          let amount : UInt64 = UInt64.init(txData["amount"] as! String)!
        let genesisHash : Data = Data.init(base64Encoded: txData["genesisHash"] as! String)!
        let fee : UInt64 = txData["fee"] as! UInt64
        let round : UInt64 = txData["round"] as! UInt64
        let toAddress : String = txData["toAddress"] as! String
        
        
        var input : AlgorandSigningInput = AlgorandSigningInput.with{
            $0.privateKey = pk.data
            $0.genesisID=txData["genesisId"] as! String
            $0.genesisHash=genesisHash
            $0.fee=fee
            $0.firstRound=round
            $0.lastRound=round+fee
        }
        if type == "Asset"{
              let assetId : UInt64 = UInt64.init(txData["assetId"] as! String)!
            input.assetTransfer=AlgorandAssetTransfer.with{
                $0.amount=amount
                $0.assetID=assetId
                $0.toAddress=toAddress
            }
        }else if type == "Add"{
              let assetId : UInt64 = UInt64.init(txData["assetId"] as! String)!
            input.assetOptIn=AlgorandAssetOptIn.with{
                $0.assetID=assetId
            }
        }
        else{
            input.transfer=AlgorandTransfer.with{
                $0.amount=amount
                $0.toAddress=toAddress
            }
        }

        let output: AlgorandSigningOutput = AnySigner.sign(input: input, coin: coinType)
        let rValue :[String:Any]=["result":true,"signHash":output.encoded.hexString]
        return objToJson(from: rValue)
      }
    func signFilecoinTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],coinType:CoinType,privateKey: PrivateKey?) -> String? {

        var pk: PrivateKey
        if privateKey == nil{
            pk=wallet!.getKey(coin: coinType, derivationPath: path)
        }else{
            pk = privateKey!
        }
        
        let gasLimit : String = txData["gasLimit"] as! String
        let gasFeeCap : String = txData["gasFeeCap"] as! String
        let gasPremium : String = txData["gasPremium"] as! String
        let nonce : String = txData["nonce"] as! String
        let amount : String = txData["amount"] as! String
        let toAddress : String = txData["toAddress"] as! String
        
        
        var input : FilecoinSigningInput = FilecoinSigningInput.with{
            $0.privateKey = pk.data
            $0.to = toAddress
            $0.nonce = UInt64.init(nonce)!
            $0.value = amount.data(using: String.Encoding.utf8)!
            $0.gasLimit = Int64.init(gasLimit)!
            $0.gasFeeCap = gasFeeCap.data(using: String.Encoding.utf8)!
            $0.gasPremium = gasPremium.data(using: String.Encoding.utf8)!
        }

        let output: FilecoinSigningOutput = AnySigner.sign(input: input, coin: coinType)
        return output.json
      }
    func signPolkadotTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],coinType:CoinType,privateKey: PrivateKey?) -> String? {

        var pk: PrivateKey
        if privateKey == nil{
            pk=wallet!.getKey(coin: coinType, derivationPath: path)
        }else{
            pk = privateKey!
        }
        
        
        let amount : String = txData["amount"] as! String//转账金额
        let genesisHash : Data = Data.init(base64Encoded: txData["genesisHash"] as! String)!
        let blockHash : String = txData["blockHash"] as! String
        let fee : UInt64 = txData["fee"] as! UInt64
        let nonce : UInt64 = txData["nonce"] as! UInt64
        let specVersion : UInt32 = txData["specVersion"] as! UInt32
        let transactionVersion : UInt32 = txData["transactionVersion"] as! UInt32
        let toAddress : String = txData["toAddress"] as! String
        
        let input : PolkadotSigningInput = PolkadotSigningInput.with{
            $0.privateKey = pk.data
            $0.genesisHash = genesisHash
            $0.blockHash = Data(hexString: blockHash)!
            $0.nonce = nonce
            $0.specVersion = specVersion
            $0.transactionVersion = transactionVersion
            $0.network = coinType.ss58Prefix
            $0.multiAddress = true
            $0.balanceCall.transfer = PolkadotBalance.Transfer.with{
                $0.toAddress = toAddress
                $0.value = Data(hexString : amount)!
            }
        }

        let output: PolkadotSigningOutput = AnySigner.sign(input: input, coin: coinType)
        return output.encoded.hexString
      }
    func signAptosTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],privateKey: PrivateKey?) -> String? {

        var pk: PrivateKey
        if privateKey == nil{
            pk=wallet!.getKey(coin: CoinType.aptos, derivationPath: path)
        }else{
            pk = privateKey!
        }
        
        let gasUnitPrice : UInt64 = txData["gasUnitPrice"] as! UInt64
        let maxGasAmount : UInt64 = txData["maxGasAmount"] as! UInt64
        let expirationTimestampSecs : UInt64 = txData["expirationTimestampSecs"] as! UInt64
        let toAddress : String = txData["toAddress"] as! String
        let senderAddress : String = txData["fromAddress"] as! String
        let amount : UInt64 = txData["amount"] as! UInt64
        let chainId : UInt32 = txData["chainId"] as! UInt32
        let sequenceNumber : Int64 = txData["SequenceNumber"] as! Int64
        let contractAddress : String = txData["contractAddress"] as! String
        let contractModule : String = txData["contractModule"] as! String
        let contractName : String = txData["contractName"] as! String
        
        var input = AptosSigningInput.with {
            $0.chainID = chainId
            $0.sender = senderAddress
            $0.expirationTimestampSecs = expirationTimestampSecs
            $0.gasUnitPrice = gasUnitPrice
            $0.maxGasAmount = maxGasAmount
            $0.sequenceNumber = sequenceNumber
            $0.privateKey = privateKey!.data
        }
                
        if contractAddress == "" {
            let transferMsg = AptosTransferMessage.with {
                $0.to = toAddress
                $0.amount = amount
            }
            input.transfer = transferMsg
        }else{
            let structTag = AptosStructTag.with {
                $0.accountAddress = contractAddress
                $0.module = contractModule
                $0.name = contractName
            }
            let tokenTransferMessage = AptosTokenTransferMessage.with {
                $0.to = toAddress
                $0.amount = amount
                $0.function=structTag
            }
            input.tokenTransfer=tokenTransferMessage
            /*input.tokenTransferCoins=AptosTokenTransferCoinsMessage.with{
                $0.to = toAddress
                $0.amount = amount
                $0.function=structTag
            }*/
            
        }
        let output: AptosSigningOutput = AnySigner.sign(input: input, coin: CoinType.aptos)
        return output.encoded.hexString
      }
    func signSuiTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],privateKey: PrivateKey?) -> String? {

        var pk: PrivateKey
        if privateKey == nil{
            pk=wallet!.getKey(coin: CoinType.sui, derivationPath: path)
        }else{
            pk = privateKey!
        }
        
        let referenceGasPrice : UInt64 = txData["referenceGasPrice"] as! UInt64
        let gasBudget : UInt64 = txData["gasBudget"] as! UInt64
        let toAddress : String = txData["toAddress"] as! String
        let amount : UInt64 = txData["amount"] as! UInt64
        let chainId : UInt32 = txData["chainId"] as! UInt32
        let utxos: [[String: Any]] = txData["utxo"] as! [[String: Any]]
        
        var paySui = SuiPaySui.with{
            $0.amounts = [amount]
            $0.recipients = [toAddress]
        }
        var inputCoins : [SuiObjectRef] = []
        for utx in utxos {
            inputCoins.append(
                SuiObjectRef.with{
                    $0.objectID = utx["objectId"] as! String
                    $0.version = utx["version"] as! UInt64
                    $0.objectDigest = utx["objectDigest"] as! String
                }
            )
        }
        paySui.inputCoins=inputCoins
        let input = SuiSigningInput.with {
            $0.paySui = paySui
            $0.privateKey = privateKey!.data
            $0.gasBudget = gasBudget
            $0.referenceGasPrice = referenceGasPrice
        }
        
        let output: AptosSigningOutput = AnySigner.sign(input: input, coin: CoinType.sui)
        return output.encoded.hexString
      }
    func signTonTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],privateKey: PrivateKey?) -> String? {

        var pk: PrivateKey
        if privateKey == nil{
            pk=wallet!.getKey(coin: CoinType.ton, derivationPath: path)
        }else{
            pk = privateKey!
        }
        
        let expireAt : UInt32 = txData["expireAt"] as! UInt32
        let sequenceNumber : UInt32 = txData["sequenceNumber"] as! UInt32
        let toAddress : String = txData["toAddress"] as! String
        let fromAddress : String = txData["fromAddress"] as! String
        let amount : String = txData["amount"] as! String
        let contractAddress : String = txData["contractAddress"] as! String
        let maxGasAmount : String = txData["maxGasAmount"] as! String
        
        // Helper function to convert UInt64 to Data (big-endian)
        func uint64ToData(_ value: UInt64) -> Data {
            return withUnsafeBytes(of: value.bigEndian) { Data($0) }
        }

        if contractAddress==""{
            let transfer = TheOpenNetworkTransfer.with {
                $0.dest = toAddress
                $0.amount = uint64ToData(UInt64(amount)!)
                $0.mode = UInt32(TheOpenNetworkSendMode.payFeesSeparately.rawValue | TheOpenNetworkSendMode.ignoreActionPhaseErrors.rawValue)
                $0.bounceable = true
            }

            let input = TheOpenNetworkSigningInput.with {
                $0.messages = [transfer]
                $0.privateKey = pk.data
                $0.sequenceNumber = sequenceNumber
                $0.expireAt = expireAt
                $0.walletVersion = TheOpenNetworkWalletVersion.walletV4R2
            }

            let output: TheOpenNetworkSigningOutput = AnySigner.sign(input: input, coin: CoinType.ton)

            return output.encoded
        }else{
            let jettonTransfer = TheOpenNetworkJettonTransfer.with {
                $0.jettonAmount = uint64ToData(UInt64(amount)!)
                $0.toOwner = toAddress
                $0.responseAddress = fromAddress
                $0.forwardAmount = uint64ToData(UInt64(maxGasAmount)!)
            }

            let transfer = TheOpenNetworkTransfer.with {
                $0.dest = contractAddress
                $0.amount = uint64ToData(UInt64(amount)!)
                $0.mode = UInt32(TheOpenNetworkSendMode.payFeesSeparately.rawValue | TheOpenNetworkSendMode.ignoreActionPhaseErrors.rawValue)
                $0.comment = "test comment"
                $0.bounceable = true
                $0.jettonTransfer = jettonTransfer
            }

            let input = TheOpenNetworkSigningInput.with {
                $0.messages = [transfer]
                $0.privateKey = pk.data
                $0.sequenceNumber = sequenceNumber
                $0.expireAt = expireAt
                $0.walletVersion = TheOpenNetworkWalletVersion.walletV4R2
            }

            let output: TheOpenNetworkSigningOutput = AnySigner.sign(input: input, coin: CoinType.ton)
            return output.encoded
        }
        
      }
    func signZilTransaction(wallet: HDWallet?, path: String, txData:  [String: Any],privateKey: PrivateKey?) -> String? {

        var pk: PrivateKey
        if privateKey == nil{
            pk=wallet!.getKey(coin: CoinType.ton, derivationPath: path)
        }else{
            pk = privateKey!
        }
        let toAddress : String = txData["toAddress"] as! String
        let amount : String = txData["amount"] as! String
        let gasPrice : String = txData["gasPrice"] as! String
        
        let gasLimit : String = txData["gasLimit"] as! String
        let nonce : UInt64 = txData["nonce"] as! UInt64
        let version : UInt32 = txData["version"] as! UInt32
        
        
                //val amount: ByteArray = Numeric.hexStringToByteArray(txData["amount"] as String)
                //val gasPrice: ByteArray = Numeric.hexStringToByteArray(txData["gasPrice"] as String)
                //val gasLimit: Long = (txData["gasLimit"] as String).toLong()
                //val code: String = txData["code"] as String? ?: ""
                //val data: String = txData["data"] as String? ?: ""
        let input = ZilliqaSigningInput.with{
            $0.gasLimit=UInt64(gasLimit)!
            $0.gasPrice=Data.init(base64Encoded: gasPrice)!
            $0.nonce=nonce
            $0.privateKey=pk.data
            $0.to=toAddress
            $0.version=version
            $0.transaction=ZilliqaTransaction.with{
                $0.transfer=ZilliqaTransaction.Transfer.with{
                    $0.amount=Data.init(base64Encoded: amount)!
                }
            }
        }
        let output: ZilliqaSigningOutput = AnySigner.sign(input: input, coin: CoinType.zilliqa)
        return output.json
      }
    //获取CoinType 根据 coin symbol
    public func getCoinTypeWithCoinString(coin: String) -> CoinType?{
        var coinType: CoinType? = nil
        switch coin {
        case "BTC":
            coinType=CoinType.bitcoin
            break
        case "LTC":
            coinType=CoinType.litecoin
            break
        case "DOGE":
            coinType=CoinType.dogecoin
            break
        case "DASH":
            coinType=CoinType.dash
            break
        case "VIA":
            coinType=CoinType.viacoin
            break
        case "DGB":
            coinType=CoinType.digiByte
            break
        case "MONA":
            coinType=CoinType.monacoin
            break
        case "FIRO":
            coinType=CoinType.firo
            break
        case "BCH":
            coinType=CoinType.bitcoinCash
            break
        case "BTG":
            coinType=CoinType.bitcoinGold
            break
        case "RVN":
            coinType=CoinType.ravencoin
            break
        case "QTUM":
            coinType=CoinType.qtum
            break
        case "XEC":
            coinType=CoinType.bitcoin
            break
        case "ETH":
            coinType=CoinType.ethereum
            break
        case "ETC":
            coinType=CoinType.ethereumClassic
            break
        case "HT":
            coinType=CoinType.ethereum
            break
        case "XDAI":
            coinType=CoinType.ethereum
            break
        case "N":
            coinType=CoinType.ethereum
            break
        case "MATIC":
            coinType=CoinType.ethereum
            break
        case "AVAX":
            coinType=CoinType.ethereum
            break
        case "CELO":
            coinType=CoinType.ethereum
            break
        case "BNB":
            coinType=CoinType.ethereum
            break
        case "FTM":
            coinType=CoinType.ethereum
            break
        case "POA":
            coinType=CoinType.poanetwork
            break
        case "CLO":
            coinType=CoinType.callisto
            break
        case "VIC":
            coinType=CoinType.viction
            break
        case "TT":
            coinType=CoinType.thunderCore
            break
        case "GO":
            coinType=CoinType.goChain
            break
        case "WAN":
            coinType=CoinType.wanchain
            break
        case "OKT":
            coinType=CoinType.ethereum
            break
        case "MTR":
            coinType=CoinType.ethereum
            break
        case "KLAY":
            coinType=CoinType.ethereum
            break
        case "GLMR":
            coinType=CoinType.ethereum
            break
        case "MOVR":
            coinType=CoinType.ethereum
            break
        case "EVMOS":
            coinType=CoinType.ethereum
            break
        case "BOBA":
            coinType=CoinType.ethereum
            break
        case "KCS":
            coinType=CoinType.ethereum
            break
        case "KAVA":
            coinType=CoinType.ethereum
            break
        case "CRO":
            coinType=CoinType.ethereum
            break
        case "OP":
            coinType=CoinType.ethereum
            break
        case "ARB":
            coinType=CoinType.ethereum
            break
        case "AURORA":
            coinType=CoinType.ethereum
            break
        case "METIS":
            coinType=CoinType.ethereum
            break
        case "XTZ":
            coinType=CoinType.tezos
            break
        case "TRX":
            coinType=CoinType.tron
            break
        case "SOL":
            coinType=CoinType.solana
            break
        case "ALGO":
            coinType=CoinType.algorand
            break
        case "XRP":
            coinType=CoinType.xrp
            break
        case "ATOM":
            coinType=CoinType.cosmos
            break
        case "ZETA":
            coinType=CoinType.ethereum
            break
        case "BASE":
            coinType=CoinType.base
            break
        case "FIL":
            coinType=CoinType.filecoin
            break
        case "DOT":
            coinType=CoinType.polkadot
            break
        case "ACA":
            coinType=CoinType.acala
            break
        case "KSM":
            coinType=CoinType.kusama
            break
        case "APT":
            coinType=CoinType.aptos
            break
        case "SUI":
            coinType=CoinType.sui
            break
        case "TON":
            coinType=CoinType.ton
            break
        case "ZIL":
            coinType=CoinType.zilliqa
            break
        default:
            coinType = nil
        }
        return coinType
    }
    //获取chainType 根据 coin symbol
    public func getChainTypeWithCoinString(coin: String) -> String{
        var chainType: String = ""
        switch coin {
        case "BTC":
            chainType="Bitcoin"
            break
        case "LTC":
            chainType="Bitcoin"
            break
        case "DOGE":
            chainType="Bitcoin"
            break
        case "DASH":
            chainType="Bitcoin"
            break
        case "VIA":
            chainType="Bitcoin"
            break
        case "DGB":
            chainType="Bitcoin"
            break
        case "MONA":
            chainType="Bitcoin"
            break
        case "FIRO":
            chainType="Bitcoin"
            break
        case "BCH":
            chainType="Bitcoin"
            break
        case "BTG":
            chainType="Bitcoin"
            break
        case "RVN":
            chainType="Bitcoin"
            break
        case "QTUM":
            chainType="Bitcoin"
            break
        case "XEC":
            chainType="Bitcoin"
            break
        case "ETH":
            chainType="Ethereum"
            break
        case "ETC":
            chainType="Ethereum"
            break
        case "HT":
            chainType="Ethereum"
            break
        case "XDAI":
            chainType="Ethereum"
            break
        case "N":
            chainType="Ethereum"
            break
        case "MATIC":
            chainType="Ethereum"
            break
        case "AVAX":
            chainType="Ethereum"
            break
        case "CELO":
            chainType="Ethereum"
            break
        case "BNB":
            chainType="Ethereum"
            break
        case "FTM":
            chainType="Ethereum"
            break
        case "POA":
            chainType="Ethereum"
            break
        case "CLO":
            chainType="Ethereum"
            break
        case "TOMO":
            chainType="Ethereum"
            break
        case "TT":
            chainType="Ethereum"
            break
        case "GO":
            chainType="Ethereum"
            break
        case "WAN":
            chainType="Ethereum"
            break
        case "OKT":
            chainType="Ethereum"
            break
        case "MTR":
            chainType="Ethereum"
            break
        case "KLAY":
            chainType="Ethereum"
            break
        case "GLMR":
            chainType="Ethereum"
            break
        case "MOVR":
            chainType="Ethereum"
            break
        case "EVMOS":
            chainType="Ethereum"
            break
        case "BOBA":
            chainType="Ethereum"
            break
        case "ARB":
            chainType="Ethereum"
            break
        case "KCS":
            chainType="Ethereum"
            break
        case "KAVA":
            chainType="Ethereum"
            break
        case "CRO":
            chainType="Ethereum"
            break
        case "OP":
            chainType="Ethereum"
            break
        case "AURORA":
            chainType="Ethereum"
            break
        case "METIS":
            chainType="Ethereum"
            break
        case "XTZ":
            chainType="Tezos"
            break
        case "TRX":
            chainType="Tron"
            break
        case "SOL":
            chainType="Solana"
            break
        case "ALGO":
            chainType="Algorand"
            break
        case "XRP":
            chainType="Ripple"
            break
        case "ATOM":
            chainType="Cosmos"
            break
        case "ZETA":
            chainType="Ethereum"
            break
        case "BASE":
            chainType="Ethereum"
            break
        case "FIL":
            chainType="Filecoin"
            break
        case "DOT":
            chainType="Polkadot"
            break
        case "ACA":
            chainType="Acala"
            break
        case "KSM":
            chainType="Kusama"
            break
        case "APT":
            chainType="Aptos"
            break
        case "SUI":
            chainType="Sui"
            break
        case "TON":
            chainType="Ton"
            break
        case "ZIL":
            chainType="Zilliqa"
        default:
            chainType = "Ethereum"
        }
        return chainType
    }
    //将十六进制字符奇数 补齐
    func handHexData(from hexStr: String) -> Data? {
        var hexStr1 = ""
        if hexStr.count % 2 != 0 {
            hexStr1 = "0" + hexStr
        }else {
            hexStr1 = hexStr
        }
        return Data(hexString: hexStr1)
    }
}


//
//  WalletCorePlugin+KeyManagement.swift
//  Runner
//
//  Key management functions: address generation, validation, key derivation, keystore.
//

import Flutter
import UIKit
import WalletCore

extension WalletCorePlugin {

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

    func objToJson(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
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
        case "XLM":
            coinType=CoinType.stellar
            break
        case "VET":
            coinType=CoinType.veChain
            break
        case "NEAR":
            coinType=CoinType.near
            break
        case "THETA":
            coinType=CoinType.theta
            break
        case "ADA":
            coinType=CoinType.cardano
            break
        case "EGLD":
            coinType=CoinType.multiversX
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
            break
        case "XLM":
            chainType="Stellar"
            break
        case "VET":
            chainType="VeChain"
            break
        case "NEAR":
            chainType="Near"
            break
        case "THETA":
            chainType="Theta"
            break
        case "ADA":
            chainType="Cardano"
            break
        case "EGLD":
            chainType="MultiversX"
            break
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

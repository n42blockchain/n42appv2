//
//  WalletCorePlugin+Signing.swift
//  Runner
//
//  Transaction signing functions for all supported chains.
//

import Flutter
import UIKit
import WalletCore

extension WalletCorePlugin {

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
        case "Stellar":
            txHash = signStellarTransaction(wallet: wallet, path: path, txData: txData, pk: pk)
            break
        case "VeChain":
            txHash = signVeChainTransaction(wallet: wallet, path: path, txData: txData, pk: pk)
            break
        case "Near":
            txHash = signNearTransaction(wallet: wallet, path: path, txData: txData, pk: pk)
            break
        case "Theta":
            txHash = signThetaTransaction(wallet: wallet, path: path, txData: txData, pk: pk)
            break
        case "Cardano":
            txHash = signCardanoTransaction(wallet: wallet, path: path, txData: txData, pk: pk)
            break
        case "MultiversX":
            txHash = signMultiversXTransaction(wallet: wallet, path: path, txData: txData, pk: pk)
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

    // MARK: - 新增链签名（对齐 Android TransactionSignerHandler；由 Windows 侧翻译，
    //         须在 Mac + 真机验证签名结果与 Android/广播地址一致）

    /// 将可能带 0x 前缀、奇数长度的十六进制字符串转 Data，对齐 Android
    /// `Numeric.hexStringToByteArray` 的宽松语义（handHexData 不剥离 0x，故另设）。
    private func hexStrToData(_ hex: String) -> Data {
        var h = (hex.hasPrefix("0x") || hex.hasPrefix("0X")) ? String(hex.dropFirst(2)) : hex
        if h.isEmpty { return Data() }
        if h.count % 2 != 0 { h = "0" + h }
        return Data(hexString: h) ?? Data()
    }

    func signStellarTransaction(wallet: HDWallet?, path: String, txData: [String: Any], pk: PrivateKey?) -> String? {
        let privateKey: PrivateKey = pk ?? wallet!.getKey(coin: CoinType.stellar, derivationPath: path)
        let toAddress: String = txData["toAddress"] as! String
        let amount: Int64 = Int64(txData["amount"] as! String)!
        let fee: Int32 = Int32(txData["fee"] as! String)!
        let sequence: Int64 = Int64(txData["sequence"] as! String)!
        let memo: String? = txData["memo"] as? String
        let passphrase: String = (txData["passphrase"] as? String) ?? "Public Global Stellar Network ; September 2015"

        var input = StellarSigningInput.with {
            $0.passphrase = passphrase
            $0.fee = fee
            $0.sequence = sequence
            $0.privateKey = privateKey.data
            $0.opPayment = StellarOperationPayment.with {
                $0.destination = toAddress
                $0.amount = amount
            }
        }
        if let memo = memo, !memo.isEmpty {
            input.memoText = StellarMemoText.with { $0.text = memo }
        }
        let output: StellarSigningOutput = AnySigner.sign(input: input, coin: CoinType.stellar)
        return output.signature
    }

    func signVeChainTransaction(wallet: HDWallet?, path: String, txData: [String: Any], pk: PrivateKey?) -> String? {
        let privateKey: PrivateKey = pk ?? wallet!.getKey(coin: CoinType.veChain, derivationPath: path)
        let toAddress: String = txData["toAddress"] as! String
        let amount: Data = hexStrToData(txData["amount"] as! String)
        let chainTag: UInt32 = UInt32(txData["chainTag"] as! String)!
        let blockRef: UInt64 = UInt64(txData["blockRef"] as! String)!
        let expiration: UInt32 = UInt32(txData["expiration"] as! String)!
        let gas: UInt64 = UInt64(txData["gas"] as! String)!
        let nonce: UInt64 = UInt64(txData["nonce"] as! String)!
        let data: String = (txData["data"] as? String) ?? ""

        let clause = VeChainClause.with {
            $0.to = toAddress
            $0.value = amount
            $0.data = hexStrToData(data)
        }
        let input = VeChainSigningInput.with {
            $0.chainTag = chainTag
            $0.blockRef = blockRef
            $0.expiration = expiration
            $0.clauses = [clause]
            $0.gas = gas
            $0.nonce = nonce
            $0.privateKey = privateKey.data
        }
        let output: VeChainSigningOutput = AnySigner.sign(input: input, coin: CoinType.veChain)
        return "0x" + output.encoded.hexString
    }

    func signNearTransaction(wallet: HDWallet?, path: String, txData: [String: Any], pk: PrivateKey?) -> String? {
        let privateKey: PrivateKey = pk ?? wallet!.getKey(coin: CoinType.near, derivationPath: path)
        let signerId: String = txData["signerId"] as! String
        let receiverId: String = txData["receiverId"] as! String
        let nonce: UInt64 = UInt64(txData["nonce"] as! String)!
        let blockHash: String = txData["blockHash"] as! String
        let amount: String = txData["amount"] as! String

        let transfer = NEARTransfer.with {
            $0.deposit = hexStrToData(amount)
        }
        let action = NEARAction.with {
            $0.transfer = transfer
        }
        let input = NEARSigningInput.with {
            $0.signerID = signerId
            $0.receiverID = receiverId
            $0.nonce = nonce
            $0.blockHash = hexStrToData(blockHash)
            $0.actions = [action]
            $0.privateKey = privateKey.data
        }
        let output: NEARSigningOutput = AnySigner.sign(input: input, coin: CoinType.near)
        return output.signedTransaction.base64EncodedString()
    }

    func signThetaTransaction(wallet: HDWallet?, path: String, txData: [String: Any], pk: PrivateKey?) -> String? {
        let privateKey: PrivateKey = pk ?? wallet!.getKey(coin: CoinType.theta, derivationPath: path)
        let toAddress: String = txData["toAddress"] as! String
        let thetaAmount: Data = hexStrToData((txData["thetaAmount"] as? String) ?? "0x0")
        let tfuelAmount: Data = hexStrToData(txData["tfuelAmount"] as! String)
        let sequence: UInt64 = UInt64(txData["sequence"] as! String)!
        let fee: Data = hexStrToData(txData["fee"] as! String)

        let input = ThetaSigningInput.with {
            $0.toAddress = toAddress
            $0.thetaAmount = thetaAmount
            $0.tfuelAmount = tfuelAmount
            $0.sequence = sequence
            $0.fee = fee
            $0.privateKey = privateKey.data
        }
        let output: ThetaSigningOutput = AnySigner.sign(input: input, coin: CoinType.theta)
        return "0x" + output.encoded.hexString
    }

    func signCardanoTransaction(wallet: HDWallet?, path: String, txData: [String: Any], pk: PrivateKey?) -> String? {
        let privateKey: PrivateKey = pk ?? wallet!.getKey(coin: CoinType.cardano, derivationPath: path)
        let toAddress: String = txData["toAddress"] as! String
        let amount: UInt64 = UInt64(txData["amount"] as! String)!
        let ttl: UInt64 = UInt64(txData["ttl"] as! String)!
        let utxos: [[String: Any]] = txData["utxos"] as! [[String: Any]]

        var utxoList: [CardanoTxInput] = []
        for utxo in utxos {
            let txHash: String = utxo["txHash"] as! String
            let outputIndex: UInt64 = UInt64(utxo["outputIndex"] as! Int)
            let utxoAmount: UInt64 = UInt64(utxo["amount"] as! String)!
            let utxoAddress: String = utxo["address"] as! String
            utxoList.append(CardanoTxInput.with {
                $0.outPoint = CardanoOutPoint.with {
                    $0.txHash = hexStrToData(txHash)
                    $0.outputIndex = outputIndex
                }
                $0.address = utxoAddress
                $0.amount = utxoAmount
            })
        }

        var input = CardanoSigningInput.with {
            $0.ttl = ttl
            $0.privateKey = [privateKey.data]
            $0.utxos = utxoList
            $0.transferMessage = CardanoTransfer.with {
                $0.toAddress = toAddress
                $0.changeAddress = CoinType.cardano.deriveAddress(privateKey: privateKey)
                $0.amount = amount
                $0.useMaxAmount = false
            }
        }
        let output: CardanoSigningOutput = AnySigner.sign(input: input, coin: CoinType.cardano)
        if !output.errorMessage.isEmpty {
            return nil
        }
        return "0x" + output.encoded.hexString
    }

    func signMultiversXTransaction(wallet: HDWallet?, path: String, txData: [String: Any], pk: PrivateKey?) -> String? {
        let privateKey: PrivateKey = pk ?? wallet!.getKey(coin: CoinType.multiversX, derivationPath: path)
        let toAddress: String = txData["toAddress"] as! String
        let amount: String = txData["amount"] as! String
        let nonce: UInt64 = UInt64(txData["nonce"] as! String)!
        let gasPrice: UInt64 = UInt64(txData["gasPrice"] as! String)!
        let gasLimit: UInt64 = UInt64(txData["gasLimit"] as! String)!
        let data: String = (txData["data"] as? String) ?? ""
        let chainId: String = (txData["chainId"] as? String) ?? "1"
        let version: UInt32 = UInt32((txData["version"] as? String) ?? "1")!
        let sender: String = CoinType.multiversX.deriveAddress(privateKey: privateKey)

        let input = MultiversXSigningInput.with {
            $0.privateKey = privateKey.data
            $0.gasPrice = gasPrice
            $0.gasLimit = gasLimit
            $0.chainID = chainId
            $0.genericAction = MultiversXGenericAction.with {
                $0.accounts = MultiversXAccounts.with {
                    $0.senderNonce = nonce
                    $0.sender = sender
                    $0.receiver = toAddress
                }
                $0.value = amount
                $0.data = data
                $0.version = version
            }
        }
        let output: MultiversXSigningOutput = AnySigner.sign(input: input, coin: CoinType.multiversX)
        return output.encoded
    }
}

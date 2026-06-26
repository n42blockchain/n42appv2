import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:wallet/wallet.dart' show EthereumAddress, EtherAmount;
import 'package:web3dart/web3dart.dart';

// ast挖矿质押
const astMining =
    '[{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint64","name":"limit","type":"uint64"}],"name":"addDepositLimit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes","name":"pubkey","type":"bytes"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"deposit","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint64","name":"_depositLockingTime","type":"uint64"},{"internalType":"uint64","name":"_fiftyDepositLimit","type":"uint64"},{"internalType":"uint64","name":"_oneHundredDepositLimit","type":"uint64"},{"internalType":"uint64","name":"_fiveHundredDepositLimit","type":"uint64"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bytes","name":"pubkey","type":"bytes"},{"indexed":false,"internalType":"uint256","name":"weiAmount","type":"uint256"},{"indexed":false,"internalType":"bytes","name":"signature","type":"bytes"}],"name":"DepositEvent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"withdraw","outputs":[],"stateMutability":"payable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"weiAmount","type":"uint256"}],"name":"WithdrawnEvent","type":"event"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"depositAllowed","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"payee","type":"address"}],"name":"depositsOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"payee","type":"address"}],"name":"depositUnlockingTimestamp","outputs":[{"internalType":"uint64","name":"","type":"uint64"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getDepositCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"getDepositLimit","outputs":[{"internalType":"uint64","name":"","type":"uint64"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getDepositRemain","outputs":[{"internalType":"uint64","name":"","type":"uint64"},{"internalType":"uint64","name":"","type":"uint64"},{"internalType":"uint64","name":"","type":"uint64"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint64","name":"timestamp","type":"uint64"}],"name":"withdrawalAllowed","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"}]';

class MiningToken extends GeneratedContract {
  ///Token 初始化
  MiningToken.init({
    required EthereumAddress address,
    required Web3Client client,
    int? chainId,
    String abiString = astMining,
  }) : super(
         DeployedContract(ContractAbi.fromJson(abiString, 'Token'), address),
         client,
         chainId,
       );

  /// 质押 deposit
  Future deposit(
    String pubKey,
    String signature,
    BigInt value, {
    required Credentials credentials,
    Transaction? transaction,
  }) async {
    final function = self.function('deposit');
    BigInt astNum = ethToWeiString('$value', 18);
    //HexUtils hexUtils=HexUtils();
    final pk = hexToBytes(pubKey);
    //hexUtils.toUnitList(pubKey);
    final signStr = hexToBytes(signature);
    //hexUtils.toUnitList(signature);
    final params = [pk, signStr];
    var tx = Transaction(value: EtherAmount.inWei(astNum));
    return await write(credentials, tx, function, params);
  }

  /// 获取是否允许质押 depositAllowed
  Future depositAllowed(
    BigInt value, {
    required Credentials credentials,
    Transaction? transaction,
  }) async {
    final function = self.function('depositAllowed');
    BigInt astNum = ethToWeiString('$value', 18);
    final params = [astNum];
    return await read(function, params, null);
  }
  /*
  ///获取可以质押的金额数组
  ///50 剩余  100 剩余  500 剩余
  Future getDepositRemain(
      {required Credentials credentials,
        Transaction? transaction}) async {
    final function = self.function('getDepositRemain');
    final params = [];
    return await read(
      function,
      params,
      null,
    );
  }*/

  ///depositsOf
  ///获取当前地址质押数量
  Future depositsOf(
    String address, {
    required Credentials credentials,
    Transaction? transaction,
  }) async {
    final function = self.function('depositsOf');
    final params = [EthereumAddress.fromHex(address)];
    return await read(function, params, null);
  }
  /*
  ///获取全网总计的质押的AST数量
  Future depositCount(
      {required Credentials credentials,
        Transaction? transaction}) async {
    final function = self.function('getDepositCount');
    final params = [];
    return await read(
      function,
      params,
      null,
    );
  }*/

  ///获取质押之后锁仓时间
  Future lockTime(
    String address, {
    required Credentials credentials,
    Transaction? transaction,
  }) async {
    final function = self.function('depositUnlockingTimestamp');
    final params = [EthereumAddress.fromHex(address)];
    return await read(function, params, null);
  }

  ///解质押
  Future unlock({
    required Credentials credentials,
    Transaction? transaction,
  }) async {
    final function = self.function('withdraw');
    return await write(credentials, null, function, []);
  }
}

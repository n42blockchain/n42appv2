import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:web3dart/web3dart.dart' as web3dart;
const String redeemAbi = '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"allowance","type":"uint256"},{"internalType":"uint256","name":"needed","type":"uint256"}],"name":"ERC20InsufficientAllowance","type":"error"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint256","name":"balance","type":"uint256"},{"internalType":"uint256","name":"needed","type":"uint256"}],"name":"ERC20InsufficientBalance","type":"error"},{"inputs":[{"internalType":"address","name":"approver","type":"address"}],"name":"ERC20InvalidApprover","type":"error"},{"inputs":[{"internalType":"address","name":"receiver","type":"address"}],"name":"ERC20InvalidReceiver","type":"error"},{"inputs":[{"internalType":"address","name":"sender","type":"address"}],"name":"ERC20InvalidSender","type":"error"},{"inputs":[{"internalType":"address","name":"spender","type":"address"}],"name":"ERC20InvalidSpender","type":"error"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"OwnableInvalidOwner","type":"error"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"OwnableUnauthorizedAccount","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":true,"internalType":"string","name":"lockAddress","type":"string"}],"name":"DepositedVBTC","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"lockAddress","type":"string"}],"name":"getDepositAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"lockAddress","type":"string"}],"name":"getMintAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"","type":"string"}],"name":"lockAddressToDepositAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"","type":"string"}],"name":"lockAddressToMintAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"string","name":"lockAddress","type":"string"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"mint","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"lockAddress","type":"string"}],"name":"reedem","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"}]';

class RedeemToken extends web3dart.GeneratedContract {

  ///Token 初始化
  RedeemToken.init(
      {required web3dart.EthereumAddress address,
        required web3dart.Web3Client client,
        int? chainId,})
      : super(
      web3dart.DeployedContract(
          web3dart.ContractAbi.fromJson(redeemAbi, 'Token'), address),
      client,
      chainId);

  /// 质押 deposit
  Future getDepositAmount(String lockAddress,
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.function('getDepositAmount');
    final params = [lockAddress];
    return await read(
      function,
      params,
      null,
    );
  }

  /// 获取是否允许质押 depositAllowed
  Future depositAllowed(BigInt value,
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.function('depositAllowed');
    BigInt astNum = ethToWeiString('$value', 18);
    final params = [astNum];
    return await read(
      function,
      params,
      null,
    );
  }
/*
  ///获取可以质押的金额数组
  ///50 剩余  100 剩余  500 剩余
  Future getDepositRemain(
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
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
  Future depositsOf(String address,
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.function('depositsOf');
    final params = [web3dart.EthereumAddress.fromHex(address)];
    return await read(function, params, null);
  }
/*
  ///获取全网总计的质押的N数量
  Future depositCount(
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.function('getDepositCount');
    final params = [];
    return await read(
      function,
      params,
      null,
    );
  }*/

  ///获取质押之后锁仓时间
  Future lockTime(String address,
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.function('depositUnlockingTimestamp');
    final params = [web3dart.EthereumAddress.fromHex(address)];
    return await read(
      function,
      params,
      null,
    );
  }

  ///解质押
  Future reedem(String p2wshAddress,
      {required web3dart.Credentials credentials,
        web3dart.Transaction? transaction}) async {
    final function = self.function('reedem');
    final params = [p2wshAddress];
    return await write(credentials, null, function, params);
  }
}

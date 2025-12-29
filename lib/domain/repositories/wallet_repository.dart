import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/wallet.dart';

/// 钱包仓库接口
/// 
/// 定义所有钱包相关的操作
abstract class WalletRepository {
  /// 获取所有钱包
  Future<Either<Failure, List<Wallet>>> getWallets();

  /// 根据地址获取钱包
  Future<Either<Failure, Wallet>> getWalletByAddress(String address);

  /// 创建新钱包
  Future<Either<Failure, Wallet>> createWallet({
    required String name,
    required String password,
    ChainType chainType = ChainType.ethereum,
  });

  /// 从助记词导入钱包
  Future<Either<Failure, Wallet>> importFromMnemonic({
    required String name,
    required String mnemonic,
    required String password,
    ChainType chainType = ChainType.ethereum,
    String? derivationPath,
  });

  /// 从私钥导入钱包
  Future<Either<Failure, Wallet>> importFromPrivateKey({
    required String name,
    required String privateKey,
    required String password,
    ChainType chainType = ChainType.ethereum,
  });

  /// 从 Keystore 导入钱包
  Future<Either<Failure, Wallet>> importFromKeystore({
    required String name,
    required String keystore,
    required String keystorePassword,
    required String newPassword,
    ChainType chainType = ChainType.ethereum,
  });

  /// 删除钱包
  Future<Either<Failure, void>> deleteWallet({
    required String address,
    required String password,
  });

  /// 重命名钱包
  Future<Either<Failure, Wallet>> renameWallet({
    required String address,
    required String newName,
  });

  /// 获取助记词
  Future<Either<Failure, String>> getMnemonic({
    required String walletId,
    required String password,
  });

  /// 获取私钥
  Future<Either<Failure, String>> getPrivateKey({
    required String address,
    required String password,
  });

  /// 导出 Keystore
  Future<Either<Failure, String>> exportKeystore({
    required String address,
    required String password,
    required String keystorePassword,
  });

  /// 验证钱包密码
  Future<Either<Failure, bool>> verifyPassword({
    required String address,
    required String password,
  });

  /// 获取钱包资产
  Future<Either<Failure, List<WalletAsset>>> getAssets({
    required String address,
    ChainType? chainType,
  });

  /// 获取单个资产余额
  Future<Either<Failure, WalletAsset>> getAssetBalance({
    required String walletAddress,
    required String assetSymbol,
    String? contractAddress,
  });

  /// 添加自定义代币
  Future<Either<Failure, WalletAsset>> addCustomToken({
    required String walletAddress,
    required String contractAddress,
    ChainType chainType = ChainType.ethereum,
  });

  /// 移除代币
  Future<Either<Failure, void>> removeToken({
    required String walletAddress,
    required String contractAddress,
  });

  /// 刷新资产余额
  Future<Either<Failure, List<WalletAsset>>> refreshAssets({
    required String address,
  });
}

/// 创建钱包参数
class CreateWalletParams {
  final String name;
  final String password;
  final ChainType chainType;

  const CreateWalletParams({
    required this.name,
    required this.password,
    this.chainType = ChainType.ethereum,
  });
}

/// 导入钱包参数
class ImportWalletParams {
  final String name;
  final String password;
  final ChainType chainType;
  final ImportMethod method;
  final String source; // 助记词、私钥或 Keystore
  final String? derivationPath;
  final String? keystorePassword;

  const ImportWalletParams({
    required this.name,
    required this.password,
    required this.method,
    required this.source,
    this.chainType = ChainType.ethereum,
    this.derivationPath,
    this.keystorePassword,
  });
}

/// 导入方式
enum ImportMethod {
  mnemonic,
  privateKey,
  keystore,
}


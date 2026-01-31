// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/api/nft_burn_api.dart';
import 'package:n42appv2/src/wallet/models/wallet_info.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// NFT 销毁页面
class WalletNftBurnPage extends StatefulWidget {
  final NftBurnRequest burnRequest;
  final WalletInfo walletInfo;

  const WalletNftBurnPage({
    super.key,
    required this.burnRequest,
    required this.walletInfo,
  });

  @override
  State<WalletNftBurnPage> createState() => _WalletNftBurnPageState();
}

class _WalletNftBurnPageState extends State<WalletNftBurnPage> {
  final NftBurnApi _burnApi = NftBurnApi();
  final Trustdart _trustdart = Trustdart();

  bool _isLoading = false;
  bool _isEstimatingGas = true;
  bool _confirmed = false;

  BigInt _gasLimit = BigInt.from(100000);
  BigInt _gasPrice = BigInt.from(5000000000); // 5 Gwei
  String _estimatedFee = '0';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _estimateGas();
  }

  Future<void> _estimateGas() async {
    setState(() => _isEstimatingGas = true);

    try {
      final rpcUrl = _getRpcUrl();
      if (rpcUrl.isEmpty) {
        setState(() {
          _errorMessage = 'RPC not configured';
          _isEstimatingGas = false;
        });
        return;
      }

      // 获取 gas 价格
      _gasPrice = await _burnApi.getGasPrice(rpcUrl);

      // 估算 gas limit
      MessageModel gasResult;
      if (widget.burnRequest.type == NftBurnType.erc721) {
        gasResult = await _burnApi.estimateErc721BurnGas(
          rpcUrl: rpcUrl,
          contractAddress: widget.burnRequest.contractAddress,
          ownerAddress: widget.burnRequest.ownerAddress,
          tokenId: widget.burnRequest.tokenId,
        );
      } else {
        gasResult = await _burnApi.estimateErc1155BurnGas(
          rpcUrl: rpcUrl,
          contractAddress: widget.burnRequest.contractAddress,
          ownerAddress: widget.burnRequest.ownerAddress,
          tokenId: widget.burnRequest.tokenId,
          amount: widget.burnRequest.amount ?? BigInt.one,
        );
      }

      if (!gasResult.error && gasResult.data != null) {
        _gasLimit = gasResult.data as BigInt;
      }

      // 计算预估费用
      final feeWei = _gasLimit * _gasPrice;
      final feeEth = feeWei.toDouble() / 1e18;
      _estimatedFee = feeEth.toStringAsFixed(6);

      setState(() => _isEstimatingGas = false);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isEstimatingGas = false;
      });
    }
  }

  String _getRpcUrl() {
    final chainConfig = chainUrlMap[widget.burnRequest.chainSymbol];
    if (chainConfig != null && chainConfig['baseInfo'] != null) {
      return chainConfig['baseInfo']['service'] ?? '';
    }
    return '';
  }

  int _getChainId() {
    final chainConfig = chainUrlMap[widget.burnRequest.chainSymbol];
    if (chainConfig != null && chainConfig['baseInfo'] != null) {
      return chainConfig['baseInfo']['chainId'] ?? 1;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: 'Burn NFT',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 警告卡片
                    _buildWarningCard(context),

                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // NFT 信息
                    _buildNftInfoCard(context),

                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // 交易详情
                    _buildTransactionDetails(context),

                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // 确认复选框
                    _buildConfirmationCheckbox(context),

                    // 错误提示
                    if (_errorMessage != null) ...[
                      SizedBox(height: ScreenUtil().setWidth(16)),
                      _buildErrorMessage(context),
                    ],
                  ],
                ),
              ),
            ),

            // 底部按钮
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: Border.all(color: Colors.red.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: ScreenUtil().setWidth(40),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warning: Irreversible Action',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(8)),
                Text(
                  'Burning an NFT is permanent and cannot be undone. The NFT will be sent to a dead address and you will lose all ownership rights.',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNftInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          // NFT 图片
          ClipRRect(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            child: widget.burnRequest.tokenImage != null &&
                    widget.burnRequest.tokenImage!.isNotEmpty
                ? Image.network(
                    widget.burnRequest.tokenImage!,
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setWidth(100),
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) => _buildDefaultNftImage(context),
                  )
                : _buildDefaultNftImage(context),
          ),

          SizedBox(width: ScreenUtil().setWidth(20)),

          // NFT 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.burnRequest.tokenName ?? 'NFT #${widget.burnRequest.tokenId}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.bold,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(8)),
                _buildInfoRow(
                  context,
                  'Token ID',
                  '#${widget.burnRequest.tokenId}',
                ),
                _buildInfoRow(
                  context,
                  'Type',
                  widget.burnRequest.type == NftBurnType.erc721 ? 'ERC-721' : 'ERC-1155',
                ),
                if (widget.burnRequest.type == NftBurnType.erc1155 &&
                    widget.burnRequest.amount != null)
                  _buildInfoRow(
                    context,
                    'Amount',
                    widget.burnRequest.amount.toString(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultNftImage(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(100),
      height: ScreenUtil().setWidth(100),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
            .withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Icon(
        Icons.image,
        size: ScreenUtil().setWidth(50),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setWidth(4)),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w500,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),

          _buildDetailRow(context, 'Network', widget.burnRequest.chainSymbol),
          _buildDetailRow(
            context,
            'Send to',
            '${NftBurnApi.deadAddress.substring(0, 10)}...${NftBurnApi.deadAddress.substring(NftBurnApi.deadAddress.length - 8)}',
          ),
          _buildDetailRow(context, 'Method', 'Burn (Transfer to Dead Address)'),

          Divider(height: ScreenUtil().setWidth(32)),

          // Gas 费用
          if (_isEstimatingGas)
            Center(
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(24),
                      height: ScreenUtil().setWidth(24),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(12)),
                    Text(
                      'Estimating gas...',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _buildDetailRow(
              context,
              'Estimated Gas',
              _gasLimit.toString(),
            ),
            _buildDetailRow(
              context,
              'Gas Price',
              '${(_gasPrice.toDouble() / 1e9).toStringAsFixed(2)} Gwei',
            ),
            SizedBox(height: ScreenUtil().setWidth(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Network Fee',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                Text(
                  '$_estimatedFee ${_getNativeSymbol()}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.bold,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _confirmed = !_confirmed),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: _confirmed
              ? Colors.red.withAlpha(10)
              : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: _confirmed ? Border.all(color: Colors.red.withAlpha(50)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setWidth(36),
              decoration: BoxDecoration(
                color: _confirmed ? Colors.red : Colors.transparent,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                border: Border.all(
                  color: _confirmed
                      ? Colors.red
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                  width: 2,
                ),
              ),
              child: _confirmed
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: ScreenUtil().setWidth(24),
                    )
                  : null,
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: Text(
                'I understand that burning this NFT is permanent and irreversible',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: ScreenUtil().setSp(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final canBurn = _confirmed && !_isEstimatingGas && _errorMessage == null;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canBurn && !_isLoading ? _executeBurn : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canBurn ? Colors.red : Colors.grey,
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: ScreenUtil().setWidth(32),
                  height: ScreenUtil().setWidth(32),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: ScreenUtil().setWidth(32),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Text(
                      'Burn NFT',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _getNativeSymbol() {
    final chainConfig = chainUrlMap[widget.burnRequest.chainSymbol];
    if (chainConfig != null && chainConfig['baseInfo'] != null) {
      return chainConfig['baseInfo']['symbol'] ?? widget.burnRequest.chainSymbol;
    }
    return widget.burnRequest.chainSymbol;
  }

  Future<void> _executeBurn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rpcUrl = _getRpcUrl();
      final chainId = _getChainId();

      // 获取 nonce
      final nonce = await _burnApi.getNonce(rpcUrl, widget.burnRequest.ownerAddress);

      // 构建交易
      MessageModel txResult;
      if (widget.burnRequest.type == NftBurnType.erc721) {
        txResult = await _burnApi.buildErc721BurnTransaction(
          chainSymbol: widget.burnRequest.chainSymbol,
          contractAddress: widget.burnRequest.contractAddress,
          ownerAddress: widget.burnRequest.ownerAddress,
          tokenId: widget.burnRequest.tokenId,
          gasPrice: _gasPrice,
          gasLimit: _gasLimit,
          nonce: nonce,
          chainId: chainId,
        );
      } else {
        txResult = await _burnApi.buildErc1155BurnTransaction(
          chainSymbol: widget.burnRequest.chainSymbol,
          contractAddress: widget.burnRequest.contractAddress,
          ownerAddress: widget.burnRequest.ownerAddress,
          tokenId: widget.burnRequest.tokenId,
          amount: widget.burnRequest.amount ?? BigInt.one,
          gasPrice: _gasPrice,
          gasLimit: _gasLimit,
          nonce: nonce,
          chainId: chainId,
        );
      }

      if (txResult.error) {
        throw Exception(txResult.data?.toString() ?? 'Failed to build transaction');
      }

      final txData = txResult.data as Map<String, dynamic>;

      // 获取派生路径
      final path = _getDerivationPath();

      // 签名交易
      final signedTx = await _trustdart.signTransaction(
        widget.burnRequest.chainSymbol,
        path,
        txData['txData'],
        mnemonic: widget.walletInfo.mnemonic ?? '',
        pk: widget.walletInfo.privateKey ?? '',
      );

      if (signedTx.isEmpty) {
        throw Exception('Failed to sign transaction');
      }

      // 广播交易
      final broadcastResult = await _burnApi.broadcastTransaction(rpcUrl, signedTx);

      if (broadcastResult.error) {
        throw Exception(broadcastResult.data?.toString() ?? 'Failed to broadcast');
      }

      final txHash = broadcastResult.data as String;

      // 显示成功
      if (mounted) {
        _showSuccessDialog(context, txHash);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getDerivationPath() {
    final chainConfig = chainUrlMap[widget.burnRequest.chainSymbol];
    if (chainConfig != null && chainConfig['baseInfo'] != null) {
      final pathConfig = chainConfig['baseInfo']['path'];
      if (pathConfig is String) {
        return pathConfig;
      } else if (pathConfig is Map) {
        return pathConfig['default'] ?? "m/44'/60'/0'/0/0";
      }
    }
    return "m/44'/60'/0'/0/0";
  }

  void _showSuccessDialog(BuildContext context, String txHash) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('NFT Burned'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your NFT has been successfully burned.'),
            SizedBox(height: 16),
            Text(
              'Transaction Hash:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            SelectableText(
              txHash,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context, NftBurnResult.success(txHash)); // 返回上一页
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}

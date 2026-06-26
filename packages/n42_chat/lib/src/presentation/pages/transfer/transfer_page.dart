import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../integration/wallet_bridge.dart';
import '../../blocs/transfer/transfer_bloc.dart';
import '../../blocs/transfer/transfer_event.dart';
import '../../blocs/transfer/transfer_state.dart';
import '../../helpers/bloc_message_helper.dart';
import '../../widgets/common/common_widgets.dart';
import '../qrcode/scan_qr_page.dart';

/// 转账页面
class TransferPage extends StatefulWidget {
  final String roomId;
  final String? recipientAddress;
  final String? recipientName;
  final PaymentRequest? paymentRequest;

  const TransferPage({
    super.key,
    required this.roomId,
    this.recipientAddress,
    this.recipientName,
    this.paymentRequest,
  });

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  TokenInfo? _selectedToken;
  bool _isAddressValid = false;
  WalletUserInfo? _recipientInfo;

  bool get _isPaymentRequestMode => widget.paymentRequest != null;

  @override
  void initState() {
    super.initState();
    context.read<TransferBloc>().add(const LoadWalletInfo());

    final initialAddress =
        widget.paymentRequest?.receiverAddress ?? widget.recipientAddress;
    if (initialAddress != null && initialAddress.isNotEmpty) {
      _addressController.text = initialAddress;
      _validateAddress(initialAddress);
    }

    if (_isPaymentRequestMode) {
      _amountController.text = widget.paymentRequest!.amount;
      _memoController.text = widget.paymentRequest!.memo ?? '';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _validateAddress(String address) {
    if (address.isNotEmpty) {
      context.read<TransferBloc>().add(ValidateAddress(address));
    } else {
      setState(() {
        _isAddressValid = false;
        _recipientInfo = null;
      });
    }
  }

  void _submitTransfer() {
    final address = _addressController.text.trim();
    final amount = _amountController.text.trim();
    final memo = _memoController.text.trim();

    if (_isPaymentRequestMode) {
      final expiresAt = widget.paymentRequest?.expiresAt;
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)?.commonExpired ?? 'Expired')),
        );
        return;
      }
    }

    if (!_isAddressValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.transferEnterValidAddress ??
                'Please enter a valid address',
          ),
        ),
      );
      return;
    }

    if (amount.isEmpty || double.tryParse(amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.transferEnterValidAmount ??
                'Please enter a valid amount',
          ),
        ),
      );
      return;
    }

    if (_selectedToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.transferPleaseSelectToken ?? 'Please select a token',
          ),
        ),
      );
      return;
    }

    if (_isPaymentRequestMode) {
      final request = widget.paymentRequest!;
      context.read<TransferBloc>().add(
        FulfillPaymentRequest(
          roomId: widget.roomId,
          requestId: request.requestId,
          receiverAddress: request.receiverAddress,
          amount: request.amount,
          token: request.token,
        ),
      );
      return;
    }

    context.read<TransferBloc>().add(
      InitiateTransfer(
        roomId: widget.roomId,
        receiverAddress: address,
        amount: amount,
        token: _selectedToken!.symbol,
        memo: memo.isNotEmpty ? memo : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocConsumer<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state.status == TransferBlocStatus.addressValidated) {
          setState(() {
            _isAddressValid = state.isAddressValid!;
            _recipientInfo = state.userInfo;
          });
        } else if (state.status == TransferBlocStatus.success) {
          Navigator.pop(context, state.lastTransfer!);
        } else if (state.status == TransferBlocStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resolveBlocMessage(context, state.errorMessage!)),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.pageBackground,
          appBar: N42AppBar(
            title: _isPaymentRequestMode
                ? (S.of(context)?.commonPayment ?? 'Payment')
                : (S.of(context)?.transferTitle ?? 'Transfer'),
            leading: IconButton(
              icon: const Icon(AppIcons.close, size: 22),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _buildBody(state, isDark),
        );
      },
    );
  }

  Widget _buildBody(TransferState state, bool isDark) {
    if (state.isProcessing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Builder(
              builder: (ctx) => Text(
                state.processingMessage != null
                    ? resolveBlocMessage(ctx, state.processingMessage!)
                    : '...',
              ),
            ),
          ],
        ),
      );
    }

    final tokens = state.tokens;
    final balances = state.balances;

    if (tokens.isNotEmpty) {
      if (_isPaymentRequestMode) {
        final requestToken = widget.paymentRequest!.token;
        TokenInfo? matchedToken;
        for (final token in tokens) {
          if (token.symbol == requestToken) {
            matchedToken = token;
            break;
          }
        }
        _selectedToken = matchedToken;
      }
      if (!_isPaymentRequestMode) {
        _selectedToken ??= tokens.first;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 收款地址
          _buildSectionTitle(
            S.of(context)?.transferReceiverAddressLabel ?? 'Receiver Address',
            isDark,
          ),
          const SizedBox(height: 8),
          _buildAddressInput(isDark),

          // 收款人信息
          if (_recipientInfo != null || widget.recipientName != null)
            _buildRecipientInfo(isDark),

          const SizedBox(height: 24),

          // 代币选择
          _buildSectionTitle(
            S.of(context)?.transferSelectTokenLabel ?? 'Select Token',
            isDark,
          ),
          const SizedBox(height: 8),
          _buildTokenSelector(tokens, balances, isDark),

          const SizedBox(height: 24),

          // 转账金额
          _buildSectionTitle(
            S.of(context)?.transferAmountLabel ?? 'Transfer Amount',
            isDark,
          ),
          const SizedBox(height: 8),
          _buildAmountInput(balances, isDark),

          const SizedBox(height: 24),

          // 备注
          _buildSectionTitle(
            S.of(context)?.transferMemoLabel ?? 'Memo (Optional)',
            isDark,
          ),
          const SizedBox(height: 8),
          _buildMemoInput(isDark),

          const SizedBox(height: 32),

          // 转账按钮
          _buildSubmitButton(isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: context.textSecondary,
      ),
    );
  }

  Widget _buildAddressInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isAddressValid
              ? AppColors.success
              : (_addressController.text.isNotEmpty
                    ? AppColors.error
                    : context.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _addressController,
              readOnly: _isPaymentRequestMode,
              decoration: InputDecoration(
                hintText:
                    S.of(context)?.transferEnterOrPasteAddress ??
                    'Enter or paste wallet address',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintStyle: TextStyle(
                  color: context.textSecondary,
                ),
              ),
              style: TextStyle(
                fontSize: 14,
                color: context.textPrimary,
              ),
              onChanged: (value) {
                _validateAddress(value.trim());
              },
            ),
          ),
          if (!_isPaymentRequestMode) ...[
            IconButton(
              icon: const Icon(Icons.content_paste_rounded, size: 20),
              tooltip: 'Paste',
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (!mounted) return;
                if (data?.text != null) {
                  _addressController.text = data!.text!;
                  _validateAddress(data.text!.trim());
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              tooltip: S.of(context)?.commonScan ?? 'Scan',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ScanQRPage()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipientInfo(bool isDark) {
    final name = _recipientInfo?.displayName ?? widget.recipientName;
    final avatar = _recipientInfo?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          N42Avatar(imageUrl: avatar, name: name ?? '', size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? (S.of(context)?.commonUnknownUser ?? 'Unknown User'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
                if (_isAddressValid)
                  Text(
                    S.of(context)?.transferAddressVerified ?? 'Address verified',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenSelector(
    List<TokenInfo> tokens,
    Map<String, String> balances,
    bool isDark,
  ) {
    final visibleTokens = _isPaymentRequestMode && _selectedToken != null
        ? tokens
              .where((token) => token.symbol == _selectedToken!.symbol)
              .toList()
        : tokens;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: visibleTokens.map((token) {
          final isSelected = _selectedToken?.symbol == token.symbol;
          final balance = balances[token.symbol] ?? '0';

          return InkWell(
            onTap: _isPaymentRequestMode
                ? null
                : () {
                    setState(() {
                      _selectedToken = token;
                    });
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: context.dividerColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 代币图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.pageBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        token.symbol.substring(
                          0,
                          token.symbol.length.clamp(0, 2),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 代币信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          token.symbol,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                        ),
                        Text(
                          token.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 余额
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        balance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        S.of(context)?.transferAvailable ?? 'Available',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // 选中标记
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountInput(Map<String, String> balances, bool isDark) {
    final balance = _selectedToken != null
        ? balances[_selectedToken!.symbol] ?? '0'
        : '0';

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  readOnly: _isPaymentRequestMode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: S.of(context)?.transferAmountHintZero ?? '0.00',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 32,
                      color: context.textSecondary,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
              Text(
                _selectedToken?.symbol ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${S.of(context)?.transferAvailableBalance ?? 'Available balance'}: $balance ${_selectedToken?.symbol ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
              ),
              if (!_isPaymentRequestMode) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    _amountController.text = balance;
                  },
                  child: Text(S.of(context)?.commonAll ?? 'All'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemoInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _memoController,
        readOnly: _isPaymentRequestMode,
        decoration: InputDecoration(
          hintText: S.of(context)?.transferAddMemoHint ?? 'Add memo',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintStyle: TextStyle(
            color: context.textSecondary,
          ),
        ),
        style: TextStyle(
          fontSize: 14,
          color: context.textPrimary,
        ),
        maxLines: 2,
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: N42Button(
        text: _isPaymentRequestMode
            ? (S.of(context)?.commonPayment ?? 'Payment')
            : (S.of(context)?.transferConfirmTransfer ?? 'Confirm Transfer'),
        onPressed: _submitTransfer,
      ),
    );
  }
}

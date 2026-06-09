import 'package:flutter/material.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_form_widgets.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_token_select.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// 限价单表单组件
class DexLimitOrderForm extends StatefulWidget {
  final String chain;
  const DexLimitOrderForm({super.key, required this.chain});

  @override
  State<DexLimitOrderForm> createState() => _DexLimitOrderFormState();
}

class _DexLimitOrderFormState extends State<DexLimitOrderForm> {
  final DexSwapApi _dexApi = DexSwapApi();
  final _amountCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  DexTokenModel? _tokenIn;
  DexTokenModel? _tokenOut;
  Load _submitLoad = Load.finish;
  String _errorMsg = '';

  // 过期时间选项（秒）
  static const _expiryOptions = {
    '1h': 3600,
    '24h': 86400,
    '7d': 604800,
    '30d': 2592000,
  };
  int _expiresIn = 86400;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectTokenIn() async {
    final result = await Navigator.push<DexTokenModel>(
      context,
      MaterialPageRoute(builder: (_) => DexTokenSelect(chain: widget.chain)),
    );
    if (result != null && mounted) {
      setState(() => _tokenIn = result);
    }
  }

  Future<void> _selectTokenOut() async {
    final result = await Navigator.push<DexTokenModel>(
      context,
      MaterialPageRoute(builder: (_) => DexTokenSelect(chain: widget.chain)),
    );
    if (result != null && mounted) {
      setState(() => _tokenOut = result);
    }
  }

  bool get _canSubmit =>
      _tokenIn != null &&
      _tokenOut != null &&
      _amountCtrl.text.trim().isNotEmpty &&
      _priceCtrl.text.trim().isNotEmpty &&
      _submitLoad != Load.loading;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _submitLoad = Load.loading;
      _errorMsg = '';
    });

    final result = await _dexApi.createLimitOrder(
      uuid: AppGlobals.userInfo?.uuid ?? '',
      chain: widget.chain,
      tokenIn: _tokenIn!.address,
      tokenOut: _tokenOut!.address,
      symbolIn: _tokenIn!.symbol,
      symbolOut: _tokenOut!.symbol,
      amountIn: _amountCtrl.text.trim(),
      limitPrice: _priceCtrl.text.trim(),
      expiresIn: _expiresIn,
    );

    if (!mounted) return;

    if (result.error) {
      setState(() {
        _submitLoad = Load.finish;
        _errorMsg = result.data?.toString() ?? 'Failed';
      });
      return;
    }

    setState(() => _submitLoad = Load.finish);
    _amountCtrl.clear();
    _priceCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Limit order created'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Token In
          _buildTokenRow(
            label: s.g_swap_key_3,
            token: _tokenIn,
            onTap: _selectTokenIn,
          ),
          SizedBox(height: AppSpacing.space4),

          // Amount input
          _buildInput(
            controller: _amountCtrl,
            label: 'Amount',
            hint: '0.0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: AppSpacing.space4),

          // Token Out
          _buildTokenRow(
            label: s.g_swap_key_4,
            token: _tokenOut,
            onTap: _selectTokenOut,
          ),
          SizedBox(height: AppSpacing.space4),

          // Limit price input
          _buildInput(
            controller: _priceCtrl,
            label:
                'Limit Price (${_tokenOut?.symbol ?? "?"} per ${_tokenIn?.symbol ?? "?"})',
            hint: '0.0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: AppSpacing.space4),

          // Expiry selector
          _buildExpiryRow(),
          SizedBox(height: AppSpacing.space6),

          // Error
          if (_errorMsg.isNotEmpty) ...[
            DexErrorBanner(message: _errorMsg),
            SizedBox(height: AppSpacing.space4),
          ],

          // Submit button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorTokens.of(context).brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitLoad == Load.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Place Limit Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenRow({
    required String label,
    required DexTokenModel? token,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColorTokens.of(context).textSubtitle,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              token?.symbol ?? 'Select',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 16,
        color: AppColorTokens.of(context).textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSpacing.space4,
        ),
      ),
    );
  }

  Widget _buildExpiryRow() {
    return Row(
      children: [
        Text(
          'Expires in: ',
          style: TextStyle(
            color: AppColorTokens.of(context).textSubtitle,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        ..._expiryOptions.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ChoiceChip(
              label: Text(
                e.key,
                style: AppTypography.caption,
              ),
              selected: _expiresIn == e.value,
              onSelected: (_) => setState(() => _expiresIn = e.value),
              selectedColor: AppColorTokens.of(context).brand,
              labelStyle: AppTypography.caption.copyWith(color: _expiresIn == e.value ? Colors.white : null),
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }
}

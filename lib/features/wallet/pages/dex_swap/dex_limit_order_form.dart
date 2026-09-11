import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'dex_swap_constants.dart';
import 'dex_execution_guard.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_token_model.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_form_widgets.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_token_select.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// 限价单表单组件
class DexLimitOrderForm extends ConsumerWidget {
  final String chain;
  final DexSwapApi? api;
  const DexLimitOrderForm({super.key, required this.chain, this.api});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.uuid ?? '';
    return _LimitOrderForm(
      key: ValueKey((chain, userId)),
      chain: chain,
      userId: userId,
      api: api,
    );
  }
}

class _LimitOrderForm extends StatefulWidget {
  final String chain;
  final String userId;
  final DexSwapApi? api;
  const _LimitOrderForm({
    super.key,
    required this.chain,
    required this.userId,
    this.api,
  });
  @override
  State<_LimitOrderForm> createState() => _DexLimitOrderFormState();
}

class _DexLimitOrderFormState extends State<_LimitOrderForm> {
  late final DexSwapApi _dexApi = widget.api ?? DexSwapApi();
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
  void initState() {
    super.initState();
    _amountCtrl.addListener(_inputChanged);
    _priceCtrl.addListener(_inputChanged);
  }

  void _inputChanged() {
    if (mounted) setState(() {});
  }

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

  bool _positiveDecimal(String value) =>
      RegExp(r'^(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)$').hasMatch(value) &&
      RegExp(r'[1-9]').hasMatch(value);

  bool get _canSubmit {
    final input = _tokenIn;
    final output = _tokenOut;
    if (widget.userId.isEmpty ||
        input == null ||
        output == null ||
        input.chain != widget.chain ||
        output.chain != widget.chain ||
        input.address.toLowerCase() == output.address.toLowerCase() ||
        (isDexNativeToken(input.address) && isDexNativeToken(output.address))) {
      return false;
    }
    final amount = _amountCtrl.text.trim();
    final fraction = amount.contains('.') ? amount.split('.').last.length : 0;
    return _positiveDecimal(amount) &&
        fraction <= input.decimals &&
        dexToWei(amount, input.decimals) > BigInt.zero &&
        _positiveDecimal(_priceCtrl.text.trim()) &&
        _submitLoad != Load.loading;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitLoad = Load.loading;
      _errorMsg = '';
    });
    try {
      final result = await _dexApi.createLimitOrder(
        uuid: widget.userId,
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
        setState(
          () => _errorMsg =
              result.data?.toString() ?? S.of(context).g_ui_order_create_failed,
        );
        return;
      }
      _amountCtrl.clear();
      _priceCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_ui_order_created),
          backgroundColor: AppColorTokens.of(context).success,
        ),
      );
    } catch (_) {
      if (mounted)
        setState(() => _errorMsg = S.of(context).g_ui_order_create_failed);
    } finally {
      if (mounted) setState(() => _submitLoad = Load.finish);
    }
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
            label: S.of(context).g_key_44,
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
            label: S
                .of(context)
                .g_ui_limit_price_pair(
                  _tokenOut?.symbol ?? '?',
                  _tokenIn?.symbol ?? '?',
                ),
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
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
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
                  : Text(
                      S.of(context).g_ui_order_place,
                      style: AppTypography.headline.copyWith(
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
      onTap: _submitLoad == Load.loading ? null : onTap,
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
            Expanded(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.of(context).textSubtitle,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                token?.symbol ?? S.of(context).g_key_bridge_select,
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
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
      enabled: _submitLoad != Load.loading,
      keyboardType: keyboardType,
      style: AppTypography.headline.copyWith(
        fontWeight: FontWeight.w400,
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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          S.of(context).g_ui_expires_in,
          style: AppTypography.caption.copyWith(
            color: AppColorTokens.of(context).textSubtitle,
            fontWeight: FontWeight.w400,
          ),
        ),
        ..._expiryOptions.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ChoiceChip(
              label: Text(
                e.value >= 604800
                    ? S.of(context).g_ui_days('${e.value ~/ 86400}')
                    : S.of(context).g_ui_hours('${e.value ~/ 3600}'),
                style: AppTypography.caption,
              ),
              selected: _expiresIn == e.value,
              onSelected: _submitLoad == Load.loading
                  ? null
                  : (_) => setState(() => _expiresIn = e.value),
              selectedColor: AppColorTokens.of(context).brand,
              labelStyle: AppTypography.caption.copyWith(
                color: _expiresIn == e.value ? Colors.white : null,
              ),
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

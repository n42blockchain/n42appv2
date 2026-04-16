import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../domain/entities/token_gate_entity.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../helpers/bloc_message_helper.dart';

/// 代币门控设置页面
class TokenGateSettingsPage extends StatefulWidget {
  final String roomId;
  final TokenGateConfig? currentConfig;

  const TokenGateSettingsPage({
    super.key,
    required this.roomId,
    this.currentConfig,
  });

  @override
  State<TokenGateSettingsPage> createState() => _TokenGateSettingsPageState();
}

class _TokenGateSettingsPageState extends State<TokenGateSettingsPage> {
  late bool _enabled;
  late GateOperator _operator;
  late List<TokenGateRule> _rules;
  late TextEditingController _denialMessageController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final config = widget.currentConfig;
    _enabled = config?.enabled ?? false;
    _operator = config?.operator ?? GateOperator.and;
    _rules = List.from(config?.rules ?? []);
    _denialMessageController = TextEditingController(
      text: config?.denialMessage ?? '',
    );
  }

  @override
  void dispose() {
    _denialMessageController.dispose();
    super.dispose();
  }

  void _addRule() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddRuleSheet(
        onAdd: (rule) {
          setState(() => _rules.add(rule));
        },
      ),
    );
  }

  void _removeRule(int index) {
    setState(() => _rules.removeAt(index));
  }

  void _save() {
    setState(() => _isSaving = true);

    final config = TokenGateConfig(
      enabled: _enabled,
      rules: _rules,
      operator: _operator,
      denialMessage: _denialMessageController.text.trim().isNotEmpty
          ? _denialMessageController.text.trim()
          : null,
      setAt: DateTime.now(),
    );

    context.read<GroupBloc>().add(SetTokenGate(widget.roomId, config));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state.status == GroupStatus.success) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s?.tokenGateSaved ?? 'Token gate saved')),
          );
          Navigator.of(context).pop(true);
        } else if (state.status == GroupStatus.error && state.errorMessage != null) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resolveBlocMessage(context, state.errorMessage!)), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(s?.tokenGateTitle ?? 'Token Gate'),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s?.commonSave ?? 'Save'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 启用开关
            SwitchListTile(
              title: Text(s?.tokenGateEnable ?? 'Enable Token Gate'),
              subtitle: Text(s?.tokenGateEnableDescription ??
                  'Require members to hold tokens to join'),
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
            ),

            if (_enabled) ...[
              const SizedBox(height: 16),

              // 逻辑运算符
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s?.tokenGateOperator ?? 'Rule Logic',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<GateOperator>(
                        segments: [
                          ButtonSegment(
                            value: GateOperator.and,
                            label: Text(s?.tokenGateOperatorAnd ?? 'All (AND)'),
                          ),
                          ButtonSegment(
                            value: GateOperator.or,
                            label: Text(s?.tokenGateOperatorOr ?? 'Any (OR)'),
                          ),
                        ],
                        selected: {_operator},
                        onSelectionChanged: (selected) {
                          setState(() => _operator = selected.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 规则列表
              Text(
                s?.tokenGateRules ?? 'Rules',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              ..._rules.asMap().entries.map((entry) {
                final index = entry.key;
                final rule = entry.value;
                return _TokenGateRuleCard(
                  rule: rule,
                  onRemove: () => _removeRule(index),
                );
              }),

              // 添加规则按钮
              OutlinedButton.icon(
                onPressed: _addRule,
                icon: const Icon(Icons.add),
                label: Text(s?.tokenGateAddRule ?? 'Add Rule'),
              ),

              const SizedBox(height: 16),

              // 拒绝消息
              TextField(
                controller: _denialMessageController,
                decoration: InputDecoration(
                  labelText: s?.tokenGateDenialMessage ?? 'Denial Message',
                  hintText: s?.tokenGateDenialMessageHint ??
                      'Message shown when verification fails',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 代币门控规则卡片
class _TokenGateRuleCard extends StatelessWidget {
  final TokenGateRule rule;
  final VoidCallback onRemove;

  const _TokenGateRuleCard({
    required this.rule,
    required this.onRemove,
  });

  String _getTokenStandardLabel(TokenStandard standard) {
    switch (standard) {
      case TokenStandard.erc20:
        return 'ERC-20';
      case TokenStandard.erc721:
        return 'ERC-721 (NFT)';
      case TokenStandard.erc1155:
        return 'ERC-1155';
      case TokenStandard.native:
        return 'Native';
    }
  }

  String _getChainName(int chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum';
      case 137:
        return 'Polygon';
      case 56:
        return 'BSC';
      case 42161:
        return 'Arbitrum';
      case 10:
        return 'Optimism';
      default:
        return 'Chain $chainId';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF5298FF).withValues(alpha: 0.1),
          child: Icon(
            rule.tokenStandard == TokenStandard.erc721
                ? Icons.image
                : Icons.token,
            color: const Color(0xFF5298FF),
          ),
        ),
        title: Text(
          rule.symbol ?? _getTokenStandardLabel(rule.tokenStandard),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${s?.tokenGateMinBalance ?? 'Min'}: ${rule.minBalance}'),
            Text('${_getChainName(rule.chainId)} · ${_getTokenStandardLabel(rule.tokenStandard)}'),
            if (rule.contractAddress != null)
              Text(
                '${rule.contractAddress!.substring(0, 6)}...${rule.contractAddress!.substring(rule.contractAddress!.length - 4)}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onRemove,
        ),
        isThreeLine: true,
      ),
    );
  }
}

/// 添加规则底部表单
class _AddRuleSheet extends StatefulWidget {
  final void Function(TokenGateRule rule) onAdd;

  const _AddRuleSheet({required this.onAdd});

  @override
  State<_AddRuleSheet> createState() => _AddRuleSheetState();
}

class _AddRuleSheetState extends State<_AddRuleSheet> {
  TokenStandard _tokenStandard = TokenStandard.erc20;
  int _chainId = 1;
  final _contractController = TextEditingController();
  final _minBalanceController = TextEditingController(text: '1');
  final _symbolController = TextEditingController();
  final _tokenIdController = TextEditingController();

  @override
  void dispose() {
    _contractController.dispose();
    _minBalanceController.dispose();
    _symbolController.dispose();
    _tokenIdController.dispose();
    super.dispose();
  }

  void _submit() {
    final rule = TokenGateRule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tokenStandard: _tokenStandard,
      chainId: _chainId,
      contractAddress: _contractController.text.trim().isNotEmpty
          ? _contractController.text.trim()
          : null,
      minBalance: BigInt.tryParse(_minBalanceController.text.trim()) ?? BigInt.one,
      symbol: _symbolController.text.trim().isNotEmpty
          ? _symbolController.text.trim()
          : null,
      tokenId: _tokenStandard == TokenStandard.erc1155 &&
              _tokenIdController.text.trim().isNotEmpty
          ? BigInt.tryParse(_tokenIdController.text.trim())
          : null,
    );

    widget.onAdd(rule);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s?.tokenGateAddRule ?? 'Add Rule',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Token Standard
            DropdownButtonFormField<TokenStandard>(
              initialValue: _tokenStandard,
              decoration: InputDecoration(
                labelText: s?.tokenGateTokenStandard ?? 'Token Standard',
                border: const OutlineInputBorder(),
              ),
              items: TokenStandard.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s == TokenStandard.erc20
                      ? 'ERC-20'
                      : s == TokenStandard.erc721
                          ? 'ERC-721 (NFT)'
                          : s == TokenStandard.erc1155
                              ? 'ERC-1155'
                              : 'Native'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _tokenStandard = v!),
            ),
            const SizedBox(height: 12),

            // Chain
            DropdownButtonFormField<int>(
              initialValue: _chainId,
              decoration: InputDecoration(
                labelText: s?.tokenGateChain ?? 'Chain',
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Ethereum')),
                DropdownMenuItem(value: 137, child: Text('Polygon')),
                DropdownMenuItem(value: 56, child: Text('BSC')),
                DropdownMenuItem(value: 42161, child: Text('Arbitrum')),
                DropdownMenuItem(value: 10, child: Text('Optimism')),
              ],
              onChanged: (v) => setState(() => _chainId = v!),
            ),
            const SizedBox(height: 12),

            // Contract Address
            if (_tokenStandard != TokenStandard.native)
              TextField(
                controller: _contractController,
                decoration: InputDecoration(
                  labelText: s?.tokenGateContractAddress ?? 'Contract Address',
                  hintText: '0x...',
                  border: const OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 12),

            // Symbol
            TextField(
              controller: _symbolController,
              decoration: InputDecoration(
                labelText: s?.tokenGateSymbol ?? 'Symbol (optional)',
                hintText: 'e.g. USDT, BAYC',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Min Balance
            TextField(
              controller: _minBalanceController,
              decoration: InputDecoration(
                labelText: s?.tokenGateMinBalance ?? 'Minimum Balance',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Token ID (ERC-1155)
            if (_tokenStandard == TokenStandard.erc1155) ...[
              TextField(
                controller: _tokenIdController,
                decoration: InputDecoration(
                  labelText: s?.tokenGateTokenId ?? 'Token ID',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
            ],

            // Submit
            FilledButton(
              onPressed: _submit,
              child: Text(s?.commonConfirm ?? 'Confirm'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

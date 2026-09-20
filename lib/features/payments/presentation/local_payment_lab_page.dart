import 'dart:math';

import 'package:flutter/material.dart';

import '../data/local_payment_client.dart';

/// Debug-only synthetic payment UI; the caller owns [client] and its transport.
/// This page clears its active client session on departure, but never closes it.
class LocalPaymentLabPage extends StatefulWidget {
  const LocalPaymentLabPage({super.key, required this.client});

  final LocalPaymentClient client;

  @override
  State<LocalPaymentLabPage> createState() => _LocalPaymentLabPageState();
}

final class _TransferAttempt {
  const _TransferAttempt(this.key, this.asset, this.recipient, this.amount);
  final String key;
  final String asset;
  final String recipient;
  final BigInt amount;
}

class _LocalPaymentLabPageState extends State<LocalPaymentLabPage> {
  final _token = TextEditingController();
  final _asset = TextEditingController();
  final _recipient = TextEditingController();
  final _amount = TextEditingController();
  int _generation = 0;
  bool _active = false;
  bool _busy = false;
  String? _error;
  BigInt? _balance;
  String? _balanceAsset;
  Map<String, dynamic>? _receipt;
  String? _activeToken;
  final Map<String, _TransferAttempt> _pending = {};
  _TransferAttempt? get _attempt => _pending[_activeToken];

  @override
  void initState() {
    super.initState();
    // Never inherit a session activated by another surface.
    widget.client.clearAccount();
  }

  @override
  void didUpdateWidget(covariant LocalPaymentLabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.client != widget.client) {
      oldWidget.client.clearAccount();
      widget.client.clearAccount();
      _pending.clear();
      _token.clear();
      _asset.clear();
      _recipient.clear();
      _amount.clear();
      _clearSession();
    }
  }

  void _clearSession() {
    _generation++;
    _active = false;
    _busy = false;
    _error = null;
    _balance = null;
    _balanceAsset = null;
    _receipt = null;
    _activeToken = null;
  }

  @override
  void dispose() {
    _generation++;
    _pending.clear();
    widget.client.clearAccount();
    for (final controller in [_token, _asset, _recipient, _amount]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isCurrent(int generation) => mounted && generation == _generation;

  Future<void> _activate() async {
    widget.client.clearAccount();
    setState(_clearSession);
    try {
      final token = _token.text.trim();
      widget.client.activateTestAccount(token);
      setState(() {
        _active = true;
        _activeToken = token;
        final attempt = _attempt;
        _recipient.text = attempt?.recipient ?? '';
        _amount.text = attempt?.amount.toString() ?? '';
        if (attempt != null) _asset.text = attempt.asset;
      });
      if (_asset.text.trim().isNotEmpty) await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = _explain(error));
    }
  }

  Future<void> _refresh() async {
    if (!_active || _busy) return;
    final asset = _asset.text.trim();
    if (asset.isEmpty) {
      setState(() => _error = 'Enter a synthetic asset identifier.');
      return;
    }
    final generation = _generation;
    setState(() {
      _busy = true;
      _error = null;
      _balance = null;
      _balanceAsset = null;
    });
    try {
      final balance = await widget.client.balance(asset);
      if (!_isCurrent(generation)) return;
      setState(() {
        _balance = balance;
        _balanceAsset = asset;
      });
    } catch (error) {
      if (_isCurrent(generation)) setState(() => _error = _explain(error));
    } finally {
      if (_isCurrent(generation)) setState(() => _busy = false);
    }
  }

  Future<void> _transfer() async {
    if (!_active || _busy) return;
    final asset = _asset.text.trim();
    final recipient = _recipient.text.trim();
    final rawAmount = _amount.text.trim();
    final amount = RegExp(r'^[1-9][0-9]*$').hasMatch(rawAmount)
        ? BigInt.tryParse(rawAmount)
        : null;
    if (asset.isEmpty || recipient.isEmpty) {
      setState(() => _error = 'Enter a synthetic asset and recipient.');
      return;
    }
    if (amount == null ||
        amount <= BigInt.zero ||
        amount > LocalPaymentClient.maxLocalUnits) {
      setState(() {
        _error =
            'Enter whole base units from 1 to ${LocalPaymentClient.maxLocalUnits}.';
      });
      return;
    }
    final token = _activeToken!;
    final attempt =
        _attempt ??
        _TransferAttempt(
          List.generate(
            16,
            (_) =>
                Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
          ).join(),
          asset,
          recipient,
          amount,
        );
    _pending[token] = attempt;
    final generation = _generation;
    setState(() {
      _busy = true;
      _error = null;
      _receipt = null;
      _balance = null;
      _balanceAsset = null;
    });
    try {
      final receipt = await widget.client.transfer(
        recipient: attempt.recipient,
        asset: attempt.asset,
        amount: attempt.amount,
        key: attempt.key,
      );
      if (!_isCurrent(generation)) return;
      setState(() {
        _receipt = receipt;
        _pending.remove(token);
      });
      // The receipt remains visible if the subsequent balance refresh fails.
      final balance = await widget.client.balance(asset);
      if (!_isCurrent(generation)) return;
      setState(() {
        _balance = balance;
        _balanceAsset = asset;
      });
    } catch (error) {
      if (_isCurrent(generation)) {
        setState(() {
          _error = _receipt == null
              ? _explain(error)
              : 'Simulated transfer completed; balance refresh failed. Use Refresh synthetic balance.';
        });
      }
    } finally {
      if (_isCurrent(generation)) setState(() => _busy = false);
    }
  }

  Future<void> _recover() async {
    final attempt = _attempt;
    if (!_active || _busy || attempt == null) return;
    final generation = _generation;
    final token = _activeToken!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.client.recoverRequest(attempt.key);
      if (!_isCurrent(generation)) return;
      final receipt = result.receipt;
      if (receipt == null) {
        setState(
          () => _error =
              'Original result is still unknown. Keep the original request key.',
        );
        return;
      }
      if (receipt['id'] is! String ||
          !(receipt['id'] as String).startsWith('transfer_') ||
          receipt['recipient'] != attempt.recipient ||
          receipt['asset'] != attempt.asset ||
          receipt['amount'] != attempt.amount.toString()) {
        throw const LocalPaymentException('invalid_response');
      }
      setState(() {
        _receipt = receipt;
        _pending.remove(token);
      });
      final balance = await widget.client.balance(attempt.asset);
      if (!_isCurrent(generation)) return;
      setState(() {
        _balance = balance;
        _balanceAsset = attempt.asset;
      });
    } catch (error) {
      if (!_isCurrent(generation)) return;
      setState(() {
        _error = _receipt != null
            ? 'Simulated transfer completed; balance refresh failed. Use Refresh synthetic balance.'
            : error is LocalPaymentException && error.code == 'not_found'
            ? 'Original request is not visible yet. Its result is unknown; keep the original request key.'
            : _explain(error);
      });
    } finally {
      if (_isCurrent(generation)) setState(() => _busy = false);
    }
  }

  String _explain(Object error) {
    if (error is ArgumentError) return 'Use a synthetic-test account token.';
    if (error is LocalPaymentException) {
      return switch (error.code) {
        'disabled' => 'The local payment lab is disabled.',
        'account_required' ||
        'account_changed' => 'Activate a synthetic account again.',
        'unauthorized' => 'The synthetic account was not accepted.',
        'invalid_request' => 'Check the synthetic transfer inputs and balance.',
        'conflict' => 'The local operation conflicts with an existing request.',
        'not_found' =>
          'The synthetic account, asset or recipient was not found.',
        'invalid_response' =>
          'The local service returned an invalid simulation response.',
        _ =>
          'The local service could not complete the request. Retry with the same inputs.',
      };
    }
    return 'The local request failed. Retry with the same inputs.';
  }

  @override
  Widget build(BuildContext context) {
    final canOperate = _active && !_busy;
    final canEdit = canOperate && _attempt == null;
    return Scaffold(
      appBar: AppBar(title: const Text('Local payment lab')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text(
              'Local simulation / synthetic funds',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Test accounts only. No real money or wallet connection.',
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('lab_token'),
              controller: _token,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Synthetic account token',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const ValueKey('lab_activate'),
              onPressed: _activate,
              child: Text(
                _active
                    ? 'Switch synthetic account'
                    : 'Activate synthetic account',
              ),
            ),
            Text(
              _active
                  ? 'Synthetic account active'
                  : 'No synthetic account active',
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('lab_asset'),
              controller: _asset,
              enabled: canEdit,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Synthetic asset identifier',
              ),
              onChanged: (_) => setState(() {
                _balance = null;
                _balanceAsset = null;
              }),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const ValueKey('lab_refresh'),
              onPressed: canOperate ? _refresh : null,
              child: const Text('Refresh synthetic balance'),
            ),
            Text(
              _balance == null
                  ? 'Synthetic balance: not loaded'
                  : 'Synthetic balance: $_balance base units ($_balanceAsset)',
              key: const ValueKey('lab_balance'),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('lab_recipient'),
              controller: _recipient,
              enabled: canEdit,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Synthetic recipient',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('lab_amount'),
              controller: _amount,
              enabled: canEdit,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount in whole base units',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const ValueKey('lab_transfer'),
              onPressed: canOperate ? _transfer : null,
              child: Text(
                _busy
                    ? 'Working…'
                    : _attempt != null
                    ? 'Retry original transfer'
                    : 'Send simulated transfer',
              ),
            ),
            if (_attempt != null) ...[
              const Text(
                'Original result may be unknown. Inputs are locked to preserve the original request.',
              ),
              OutlinedButton(
                key: const ValueKey('lab_recover'),
                onPressed: canOperate ? _recover : null,
                child: const Text('Check original result'),
              ),
            ],
            const Text(
              'Pending requests are kept only while this page remains open. Leaving or restarting discards recovery keys; verify the original request before sending again.',
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _error!,
                    key: const ValueKey('lab_error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            if (_receipt != null)
              Semantics(
                liveRegion: true,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Simulated transfer receipt — synthetic funds only',
                        ),
                        Text('Recipient: ${_receipt!['recipient']}'),
                        Text('Asset: ${_receipt!['asset']}'),
                        Text('Amount: ${_receipt!['amount']} base units'),
                        SelectableText('Receipt: ${_receipt!['id']}'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
  String? _attemptKey;
  List<String>? _attemptFields;

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
    _attemptKey = null;
    _attemptFields = null;
  }

  @override
  void dispose() {
    _generation++;
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
      widget.client.activateTestAccount(_token.text.trim());
      setState(() => _active = true);
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
    final fields = [asset, recipient, amount.toString()];
    if (_attemptFields == null ||
        List.generate(
          3,
          (index) => _attemptFields![index] != fields[index],
        ).any((changed) => changed)) {
      final random = Random.secure();
      _attemptKey = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      _attemptFields = fields;
    }
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
        recipient: recipient,
        asset: asset,
        amount: amount,
        key: _attemptKey!,
      );
      if (!_isCurrent(generation)) return;
      setState(() {
        _receipt = receipt;
        _attemptKey = null;
        _attemptFields = null;
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
    final canEdit = _active && !_busy;
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
              onPressed: canEdit ? _refresh : null,
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
              onPressed: canEdit ? _transfer : null,
              child: Text(_busy ? 'Working…' : 'Send simulated transfer'),
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

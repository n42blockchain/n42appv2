import 'dart:math';

import 'package:flutter/material.dart';

import '../data/local_payment_client.dart';

enum _Operation { create, claim, refund }

class _Attempt {
  const _Attempt({
    required this.operation,
    required this.key,
    this.room,
    this.asset,
    this.total,
    this.slots,
    this.expiresAt,
    this.packet,
  });

  final _Operation operation;
  final String key;
  final String? room;
  final String? asset;
  final BigInt? total;
  final int? slots;
  final DateTime? expiresAt;
  final String? packet;

  String get summary => operation == _Operation.create
      ? 'Create: $total base units of $asset, $slots slots, room $room, expiry ${expiresAt!.toIso8601String()}'
      : '${operation.name}: $packet';
}

/// Synthetic local packet experiments only. The caller owns client/transport.
/// Uses a dedicated client session and clears it on disposal, without closing it.
class LocalPacketLabPage extends StatefulWidget {
  const LocalPacketLabPage({super.key, required this.client});

  final LocalPaymentClient client;

  @override
  State<LocalPacketLabPage> createState() => _LocalPacketLabPageState();
}

class _LocalPacketLabPageState extends State<LocalPacketLabPage> {
  final _token = TextEditingController();
  final _room = TextEditingController();
  final _asset = TextEditingController();
  final _total = TextEditingController();
  final _slots = TextEditingController();
  final _minutes = TextEditingController(text: '60');
  final _packet = TextEditingController();
  // Retain uncertain requests when switching away and back during this page's
  // lifetime. No balances or receipts are cached by account.
  final _attempts = <String, _Attempt>{};
  String? _account;
  int _generation = 0;
  bool _busy = false;
  String? _error;
  String? _balance;
  Map<String, dynamic>? _receipt;
  _Operation? _receiptOperation;
  String? _receiptPacket;

  _Attempt? get _pending => _attempts[_account];
  bool get _canStart => _account != null && !_busy && _pending == null;

  @override
  void initState() {
    super.initState();
    widget.client.clearAccount();
  }

  @override
  void didUpdateWidget(covariant LocalPacketLabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.client != widget.client) {
      oldWidget.client.clearAccount();
      widget.client.clearAccount();
      _clearDisplay();
      // Uncertain operation snapshots remain blocked/retryable for this page.
    }
  }

  void _clearDisplay() {
    _generation++;
    _account = null;
    _busy = false;
    _error = null;
    _balance = null;
    _receipt = null;
    _receiptOperation = null;
    _receiptPacket = null;
    _packet.clear();
  }

  @override
  void dispose() {
    _generation++;
    widget.client.clearAccount();
    for (final controller in [
      _token,
      _room,
      _asset,
      _total,
      _slots,
      _minutes,
      _packet,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _current(int generation) => mounted && generation == _generation;

  void _activate() {
    widget.client.clearAccount();
    setState(_clearDisplay);
    try {
      final token = _token.text.trim();
      widget.client.activateTestAccount(token);
      setState(() => _account = token);
    } catch (_) {
      setState(
        () => _error =
            'Activate an enabled local client with a synthetic-test account token.',
      );
    }
  }

  String _key() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  BigInt? _positive(String input) {
    if (!RegExp(r'^[1-9][0-9]{0,15}$').hasMatch(input)) return null;
    final value = BigInt.parse(input);
    return value <= LocalPaymentClient.maxLocalUnits ? value : null;
  }

  void _create() {
    if (!_canStart) return;
    final total = _positive(_total.text.trim());
    final slots = _positive(_slots.text.trim());
    final minutes = int.tryParse(_minutes.text.trim());
    if (_room.text.trim().isEmpty ||
        _asset.text.trim().isEmpty ||
        total == null ||
        slots == null ||
        slots > total ||
        total % slots != BigInt.zero ||
        minutes == null ||
        minutes < 1 ||
        minutes > 10080) {
      setState(
        () => _error =
            'Enter room/asset, positive whole base units and slots dividing the total, and 1–10080 expiry minutes.',
      );
      return;
    }
    _run(
      _Attempt(
        operation: _Operation.create,
        key: _key(),
        room: _room.text.trim(),
        asset: _asset.text.trim(),
        total: total,
        slots: slots.toInt(),
        expiresAt: DateTime.now().toUtc().add(Duration(minutes: minutes)),
      ),
    );
  }

  void _packetAction(_Operation operation) {
    if (!_canStart) return;
    final packet = _packet.text.trim();
    if (!RegExp(r'^packet_[a-f0-9]{64}$').hasMatch(packet)) {
      setState(
        () => _error =
            'Paste a local packet ID: packet_ followed by 64 lowercase hex characters.',
      );
      return;
    }
    _run(_Attempt(operation: operation, key: _key(), packet: packet));
  }

  Future<void> _run(_Attempt attempt) async {
    if (_account == null || _busy) return;
    final account = _account!;
    final generation = _generation;
    setState(() {
      _attempts[account] = attempt;
      _busy = true;
      _error = null;
      _balance = null;
      _receipt = null;
      _receiptOperation = null;
      _receiptPacket = null;
    });
    try {
      final receipt = await switch (attempt.operation) {
        _Operation.create => widget.client.createPacket(
          room: attempt.room!,
          asset: attempt.asset!,
          total: attempt.total!,
          slots: attempt.slots!,
          expiresAt: attempt.expiresAt!,
          key: attempt.key,
        ),
        _Operation.claim => widget.client.claim(
          attempt.packet!,
          key: attempt.key,
        ),
        _Operation.refund => widget.client.refund(
          attempt.packet!,
          key: attempt.key,
        ),
      };
      if (!_current(generation)) return;
      await _complete(account, generation, attempt, receipt);
    } catch (_) {
      if (!_current(generation)) return;
      setState(() {
        _error = _receipt != null
            ? 'Simulation operation confirmed; balance refresh failed. Use Refresh synthetic balance.'
            : 'No confirmed simulation receipt. Retry the same operation; its inputs and request key are retained.';
      });
    } finally {
      if (_current(generation)) setState(() => _busy = false);
    }
  }

  Future<void> _complete(
    String account,
    int generation,
    _Attempt attempt,
    Map<String, dynamic> receipt,
  ) async {
    if (!_current(generation)) return;
    setState(() {
      _attempts.remove(account);
      _receipt = receipt;
      _receiptOperation = attempt.operation;
      _receiptPacket = attempt.operation == _Operation.create
          ? receipt['id'] as String
          : attempt.packet;
      _asset.text = receipt['asset'] as String;
      if (attempt.operation == _Operation.create) {
        _packet.text = receipt['id'] as String;
      }
    });
    final asset = receipt['asset'] as String;
    final balance = await widget.client.balance(asset);
    if (_current(generation)) {
      setState(() => _balance = '$balance base units ($asset)');
    }
  }

  bool _matchesAttempt(_Attempt attempt, Map<String, dynamic> receipt) {
    final id = receipt['id'];
    return switch (attempt.operation) {
      _Operation.create =>
        id is String &&
            id.startsWith('packet_') &&
            receipt['asset'] == attempt.asset &&
            receipt['total'] == attempt.total.toString() &&
            receipt['slots'] == attempt.slots.toString() &&
            receipt['expiresAt'] ==
                (attempt.expiresAt!.millisecondsSinceEpoch ~/ 1000)
                    .toString() &&
            (!receipt.containsKey('room') || receipt['room'] == attempt.room),
      _Operation.claim =>
        !receipt.containsKey('id') && receipt['packet'] == attempt.packet,
      // Refund receipts have no packet field in the local protocol. The
      // authenticated original request key supplies that association.
      _Operation.refund =>
        id is String &&
            id.startsWith('refund_') &&
            (!receipt.containsKey('packet') ||
                receipt['packet'] == attempt.packet),
    };
  }

  Future<void> _checkOriginal() async {
    final attempt = _pending;
    if (_account == null || _busy || attempt == null) return;
    final account = _account!;
    final generation = _generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.client.recoverRequest(attempt.key);
      if (!_current(generation)) return;
      if (!result.isCompleted) {
        setState(
          () => _error =
              'Original result is unresolved. The saved request and key are unchanged.',
        );
        return;
      }
      final receipt = result.receipt!;
      if (!_matchesAttempt(attempt, receipt)) {
        setState(
          () => _error =
              'Original receipt does not match the saved operation. The request remains pending.',
        );
        return;
      }
      await _complete(account, generation, attempt, receipt);
    } catch (_) {
      if (!_current(generation)) return;
      setState(() {
        _error = _receipt != null
            ? 'Simulation operation confirmed; balance refresh failed. Use Refresh synthetic balance.'
            : 'Original result is not confirmed. The saved request and key are unchanged.';
      });
    } finally {
      if (_current(generation)) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    if (_account == null || _busy) return;
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
    });
    try {
      final balance = await widget.client.balance(asset);
      if (_current(generation)) {
        setState(() => _balance = '$balance base units ($asset)');
      }
    } catch (_) {
      if (_current(generation)) {
        setState(
          () => _error =
              'Synthetic balance refresh failed. Retry Refresh synthetic balance.',
        );
      }
    } finally {
      if (_current(generation)) setState(() => _busy = false);
    }
  }

  Widget _field(
    String name,
    String label,
    TextEditingController controller, {
    bool numeric = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      key: ValueKey('packet_$name'),
      controller: controller,
      enabled: _canStart,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      autocorrect: false,
      decoration: InputDecoration(labelText: label),
      onChanged: name == 'asset'
          ? (_) => setState(() => _balance = null)
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Local packet lab')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text(
            'Local simulation / synthetic funds',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'No real money, wallet or chain connection. Refund eligibility and expiry are checked by the local service.',
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('packet_token'),
            controller: _token,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'Synthetic account token',
            ),
          ),
          FilledButton(
            key: const ValueKey('packet_activate'),
            onPressed: _activate,
            child: Text(
              _account == null
                  ? 'Activate synthetic account'
                  : 'Switch synthetic account',
            ),
          ),
          Text(
            _account == null
                ? 'No synthetic account active'
                : 'Synthetic account active',
          ),
          if (_pending != null) ...[
            Text(
              'Unconfirmed operation: ${_pending!.summary}',
              key: const ValueKey('packet_pending'),
            ),
            const Text(
              'Only the exact saved request can be retried. Other money actions are locked until a confirmed receipt.',
            ),
            OutlinedButton(
              key: const ValueKey('packet_lookup'),
              onPressed: _busy ? null : _checkOriginal,
              child: const Text('Check original result'),
            ),
            FilledButton(
              key: const ValueKey('packet_retry'),
              onPressed: _busy ? null : () => _run(_pending!),
              child: const Text('Retry same operation'),
            ),
          ],
          const SizedBox(height: 16),
          _field('asset', 'Synthetic asset identifier', _asset),
          OutlinedButton(
            key: const ValueKey('packet_refresh'),
            onPressed: _account != null && !_busy ? _refresh : null,
            child: const Text('Refresh synthetic balance'),
          ),
          Text(
            'Synthetic balance: ${_balance ?? 'not loaded'}',
            key: const ValueKey('packet_balance'),
          ),
          const SizedBox(height: 16),
          Text(
            'Create an equal-share simulation packet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          _field('room', 'Synthetic room', _room),
          _field('total', 'Total in whole base units', _total, numeric: true),
          _field('slots', 'Number of equal shares', _slots, numeric: true),
          _field(
            'minutes',
            'Expires in minutes (1–10080)',
            _minutes,
            numeric: true,
          ),
          FilledButton(
            key: const ValueKey('packet_create'),
            onPressed: _canStart ? _create : null,
            child: const Text('Create simulated packet'),
          ),
          const SizedBox(height: 16),
          _field('id', 'Local packet ID to claim or refund', _packet),
          FilledButton(
            key: const ValueKey('packet_claim'),
            onPressed: _canStart ? () => _packetAction(_Operation.claim) : null,
            child: const Text('Claim simulated packet'),
          ),
          OutlinedButton(
            key: const ValueKey('packet_refund'),
            onPressed: _canStart
                ? () => _packetAction(_Operation.refund)
                : null,
            child: const Text('Request expired-packet refund'),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                key: const ValueKey('packet_error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_receipt != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulated ${_receiptOperation!.name} receipt — synthetic funds only',
                    ),
                    SelectableText('Packet: $_receiptPacket'),
                    if (_receipt!['id'] != null)
                      SelectableText('Receipt: ${_receipt!['id']}'),
                    Text('Asset: ${_receipt!['asset']}'),
                    Text(
                      'Amount: ${_receipt!['amount'] ?? _receipt!['total']} base units',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

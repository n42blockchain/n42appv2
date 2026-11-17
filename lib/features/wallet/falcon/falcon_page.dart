import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:web3dart/web3dart.dart' show bytesToHex, keccak256;

import 'falcon_crypto.dart';
import 'falcon_network.dart';
import 'falcon_transaction.dart';
import 'falcon_vault.dart';

/// Independent, offline Falcon account. Never routes a PQ signature through EVM.
class FalconPage extends StatefulWidget {
  const FalconPage({
    super.key,
    required this.walletScope,
    required this.isOwnerCurrent,
    this.vaultFactory,
  });
  final String walletScope;
  final FalconVault Function(String scope)? vaultFactory;
  final bool Function() isOwnerCurrent;
  @override
  State<FalconPage> createState() => _FalconPageState();
}

class _FalconPageState extends State<FalconPage> {
  FalconVault? vault;
  Uint8List? publicKey;
  String? status;
  bool libraryUnavailable = false;
  bool busy = false;
  final fields = <String, TextEditingController>{
    for (final entry in {
      'rpc': 'https://rpc.n42.world',
      'chainId': '94',
      'recipient': '',
      'valueWei': '',
      'nonce': '',
      'gas': '21000',
      'tipCap': '',
      'feeCap': '',
      'backupPassword': '',
      'backupBlob': '',
    }.entries)
      entry.key: TextEditingController(text: entry.value),
  };
  String? output;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      vault =
          widget.vaultFactory?.call(widget.walletScope) ??
          FalconVault(FalconCrypto.mobile(), widget.walletScope);
      final key = await vault!.publicKey();
      if (mounted && widget.isOwnerCurrent()) {
        setState(() => publicKey = key);
      }
    } catch (_) {
      // Localized at build time: this can run before initState completes.
      if (mounted) setState(() => libraryUnavailable = true);
    }
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> run(Future<void> Function() work) async {
    if (busy || vault == null || !widget.isOwnerCurrent()) return;
    setState(() {
      busy = true;
      status = null;
      libraryUnavailable = false;
      output = null;
    });
    try {
      // OS device credentials or biometrics, even if the normal wallet disables it.
      final allowed = await LocalAuthentication().authenticate(
        localizedReason: S.of(context).g_ui3_falcon_auth_reason,
        biometricOnly: false,
      );
      if (!allowed || !mounted || !widget.isOwnerCurrent()) return;
      await work();
    } catch (error) {
      if (mounted && widget.isOwnerCurrent()) {
        if (error is FalconNetworkNotEnabled) {
          setState(
            () => status = S.of(context).g_ui3_falcon_network_not_enabled,
          );
          return;
        }
        if (error is FalconSubmissionPending) {
          setState(
            () => status = S.of(context).g_ui3_falcon_query_previous_first,
          );
          return;
        }
        setState(() => status = S.of(context).g_ui3_falcon_operation_failed);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> sign({bool send = false, bool recover = false}) async {
    final key = publicKey;
    if (key == null) return;
    BigInt number(String name) {
      final s = fields[name]!.text;
      if (!RegExp(r'^[0-9]{1,78}$').hasMatch(s)) {
        throw FormatException('Invalid integer');
      }
      return BigInt.parse(s);
    }

    if (recover) {
      final network = FalconNetwork.endpoint(fields['rpc']!.text);
      final sender = bytesToHex(keccak256(key).sublist(12), include0x: true);
      final state = await network.reconcileAccount(number('chainId'), sender);
      if (mounted && widget.isOwnerCurrent()) {
        setState(() => output = state);
      }
      return;
    }
    final tx = FalconTransaction(
      chainId: number('chainId'),
      nonce: number('nonce'),
      recipient: fields['recipient']!.text,
      value: number('valueWei'),
      gas: number('gas'),
      tipCap: number('tipCap'),
      feeCap: number('feeCap'),
      publicKey: key,
    );
    final network = send ? FalconNetwork.endpoint(fields['rpc']!.text) : null;
    if (send) {
      if (!await vault!.backupVerified()) {
        throw StateError('Verify the encrypted backup first');
      }
      await network!.validate(tx);
    }
    if (!mounted || !widget.isOwnerCurrent()) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          send
              ? S.of(ctx).g_ui3_falcon_confirm_transaction
              : S.of(ctx).g_ui3_falcon_confirm_offline_signature,
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            const JsonEncoder.withIndent(
              '  ',
            ).convert({...tx.review(), if (send) 'rpc': fields['rpc']!.text}),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).g_key_79),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              send
                  ? S.of(ctx).g_ui3_falcon_sign_and_send
                  : S.of(ctx).g_key_msgsign_btn,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || !widget.isOwnerCurrent()) return;
    if (send) {
      await network!.validate(tx);
    }
    if (!mounted || !widget.isOwnerCurrent()) return;
    final signature = await vault!.sign(tx.digest);
    if (send) {
      if (!mounted || !widget.isOwnerCurrent()) return;
      final hash = await network!.submit(
        tx,
        signature,
        vault!.crypto,
        isOwnerCurrent: widget.isOwnerCurrent,
      );
      if (mounted && widget.isOwnerCurrent()) {
        setState(() => output = hash);
      }
      return;
    }
    if (mounted && widget.isOwnerCurrent()) {
      setState(
        () => output = jsonEncode({
          'format': 'n42-pq-offline-signature-v1',
          ...tx.review(),
          'signature': bytesToHex(signature, include0x: true),
          'rawTransaction': bytesToHex(
            tx.encodeSigned(signature),
            include0x: true,
          ),
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) => !widget.isOwnerCurrent()
      ? Scaffold(
          appBar: AppBar(title: const Text('Falcon-512')),
          body: Center(child: Text(S.of(context).g_ui3_falcon_owner_changed)),
        )
      : Scaffold(
          appBar: AppBar(title: const Text('Falcon-512')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(S.of(context).g_ui3_falcon_notice),
              if (libraryUnavailable)
                Text(S.of(context).g_ui3_falcon_library_unavailable),
              if (status != null) Text(status!),
              if (publicKey == null)
                FilledButton(
                  onPressed: busy || vault == null
                      ? null
                      : () => run(() async {
                          await vault!.create();
                          final p = await vault!.publicKey();
                          if (mounted && widget.isOwnerCurrent()) {
                            setState(() => publicKey = p);
                          }
                        }),
                  child: Text(S.of(context).g_ui3_falcon_create_account),
                ),
              if (publicKey != null)
                SelectableText(
                  S
                      .of(context)
                      .g_ui3_falcon_public_key(
                        bytesToHex(publicKey!, include0x: true),
                      ),
                ),
              for (final name in [
                'rpc',
                'chainId',
                'recipient',
                'valueWei',
                'nonce',
                'gas',
                'tipCap',
                'feeCap',
              ])
                TextField(
                  controller: fields[name],
                  decoration: InputDecoration(labelText: name),
                  enabled: !busy,
                ),
              FilledButton(
                onPressed: busy || publicKey == null
                    ? null
                    : () => run(() => sign()),
                child: Text(S.of(context).g_ui3_falcon_review_sign_offline),
              ),
              FilledButton(
                onPressed: busy || publicKey == null
                    ? null
                    : () => run(() => sign(send: true)),
                child: Text(S.of(context).g_ui3_falcon_review_send),
              ),
              TextButton(
                onPressed: busy || publicKey == null
                    ? null
                    : () => run(() => sign(recover: true)),
                child: Text(S.of(context).g_ui3_falcon_query_previous),
              ),
              TextField(
                controller: fields['backupPassword'],
                obscureText: true,
                decoration: InputDecoration(
                  labelText: S.of(context).g_ui3_falcon_backup_password,
                ),
                enabled: !busy,
              ),
              TextButton(
                onPressed: busy || publicKey == null
                    ? null
                    : () => run(() async {
                        final blob = await vault!.backup(
                          fields['backupPassword']!.text,
                        );
                        if (mounted && widget.isOwnerCurrent()) {
                          setState(() => output = blob);
                        }
                      }),
                child: Text(S.of(context).g_ui3_falcon_export_backup),
              ),
              TextField(
                controller: fields['backupBlob'],
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: S.of(context).g_ui3_falcon_backup_to_restore,
                ),
                enabled: !busy,
              ),
              TextButton(
                onPressed: busy || publicKey != null
                    ? null
                    : () => run(() async {
                        await vault!.restore(
                          fields['backupBlob']!.text,
                          fields['backupPassword']!.text,
                        );
                        final p = await vault!.publicKey();
                        if (mounted && widget.isOwnerCurrent()) {
                          setState(() => publicKey = p);
                        }
                      }),
                child: Text(S.of(context).g_ui3_falcon_restore_account),
              ),
              TextButton(
                onPressed: busy || publicKey == null
                    ? null
                    : () => run(() async {
                        await vault!.verifyBackup(
                          fields['backupBlob']!.text,
                          fields['backupPassword']!.text,
                        );
                        if (mounted && widget.isOwnerCurrent()) {
                          setState(
                            () => status = S
                                .of(context)
                                .g_ui3_falcon_backup_verified,
                          );
                        }
                      }),
                child: Text(S.of(context).g_ui3_falcon_verify_backup),
              ),
              if (output != null) ...[
                SelectableText(output!),
                TextButton(
                  onPressed: () {
                    if (busy || !widget.isOwnerCurrent()) return;
                    final result = output;
                    if (result != null) {
                      Clipboard.setData(ClipboardData(text: result));
                    }
                  },
                  child: Text(S.of(context).g_ui3_falcon_copy_result),
                ),
              ],
            ],
          ),
        );
}

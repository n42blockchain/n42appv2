import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
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
  });
  final String walletScope;
  final bool Function() isOwnerCurrent;
  @override
  State<FalconPage> createState() => _FalconPageState();
}

class _FalconPageState extends State<FalconPage> {
  FalconVault? vault;
  Uint8List? publicKey;
  String? status;
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
  bool get zh => Localizations.localeOf(context).languageCode == 'zh';
  String t(String en, String cn) => zh ? cn : en;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      vault = FalconVault(FalconCrypto.mobile(), widget.walletScope);
      final key = await vault!.publicKey();
      if (mounted) setState(() => publicKey = key);
    } catch (_) {
      if (mounted) setState(() => status = 'Falcon native library unavailable');
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
      output = null;
    });
    try {
      // OS device credentials or biometrics, even if the normal wallet disables it.
      final allowed = await LocalAuthentication().authenticate(
        localizedReason: t(
          'Authorize Falcon wallet operation',
          '授权 Falcon 钱包操作',
        ),
        biometricOnly: false,
      );
      if (!allowed || !mounted || !widget.isOwnerCurrent()) return;
      await work();
    } catch (error) {
      if (mounted && widget.isOwnerCurrent()) {
        if (error is FalconNetworkNotEnabled) {
          setState(
            () => status = t(
              'This network has not enabled Falcon-512 transactions. Offline signing is available.',
              '该网络尚未启用 Falcon-512 交易，可先使用离线签名。',
            ),
          );
          return;
        }
        if (error is FalconSubmissionPending) {
          setState(
            () => status = t(
              'Query the previous submission before another payment.',
              '请先查询上一笔发送结果，再进行新的支付。',
            ),
          );
          return;
        }
        setState(
          () => status = t(
            'Operation failed. Check inputs, backup password and device authentication. If sending was attempted, query the previous submission before retrying.',
            '操作失败，请检查输入、备份密码及设备认证。如已尝试发送，请先查询上一笔结果，勿重复支付。',
          ),
        );
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
    final network = FalconNetwork.endpoint(fields['rpc']!.text);
    if (send) {
      if (!await vault!.backupVerified()) {
        throw StateError('Verify the encrypted backup first');
      }
      await network.validate(tx);
    }
    if (!mounted || !widget.isOwnerCurrent()) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          send
              ? t('Confirm Falcon transaction', '确认 Falcon 交易')
              : t('Confirm offline signature', '确认离线签名'),
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
            child: Text(t('Cancel', '取消')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(send ? t('Sign and send', '签名并发送') : t('Sign', '签名')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || !widget.isOwnerCurrent()) return;
    if (send) {
      await network.validate(tx);
    }
    if (!mounted || !widget.isOwnerCurrent()) return;
    final signature = await vault!.sign(tx.digest);
    if (send) {
      if (!mounted || !widget.isOwnerCurrent()) return;
      final hash = await network.submit(
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
          body: Center(child: Text(t('Wallet owner changed', '账户已切换'))),
        )
      : Scaffold(
          appBar: AppBar(title: const Text('Falcon-512')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                t(
                  'Use only a network that explicitly supports Falcon-512 transactions. Verify the RPC and backup before funding. Falcon keys require a separate encrypted backup; your EVM recovery phrase cannot restore them. If submission is uncertain, query its status before another payment.',
                  '仅使用明确支持 Falcon-512 交易的网络。转入资产前请核对 RPC 并验证备份。Falcon 密钥须独立加密备份，不能通过原 EVM 助记词恢复。发送结果不明时，请先查询状态，勿重复支付。',
                ),
              ),
              if (status != null) Text(status!),
              if (publicKey == null)
                FilledButton(
                  onPressed: busy || vault == null
                      ? null
                      : () => run(() async {
                          await vault!.create();
                          final p = await vault!.publicKey();
                          if (mounted) setState(() => publicKey = p);
                        }),
                  child: Text(t('Create Falcon account', '创建 Falcon 账户')),
                ),
              if (publicKey != null)
                SelectableText(
                  'Public key: ${bytesToHex(publicKey!, include0x: true)}',
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
                child: Text(t('Review and sign offline', '预览并离线签名')),
              ),
              FilledButton(
                onPressed: busy || publicKey == null
                    ? null
                    : () => run(() => sign(send: true)),
                child: Text(t('Review and send', '预览并发送')),
              ),
              TextButton(
                onPressed: busy || publicKey == null
                    ? null
                    : () => run(() => sign(recover: true)),
                child: Text(t('Query previous submission', '查询上一笔发送状态')),
              ),
              TextField(
                controller: fields['backupPassword'],
                obscureText: true,
                decoration: InputDecoration(
                  labelText: t(
                    'Backup password (12+ characters)',
                    '备份密码（至少 12 字符）',
                  ),
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
                        if (mounted) setState(() => output = blob);
                      }),
                child: Text(t('Export encrypted backup', '导出加密备份')),
              ),
              TextField(
                controller: fields['backupBlob'],
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: t('Encrypted backup to restore', '待恢复的加密备份'),
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
                        if (mounted) setState(() => publicKey = p);
                      }),
                child: Text(t('Restore Falcon account', '恢复 Falcon 账户')),
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
                            () => status = t(
                              'Encrypted backup verified',
                              '加密备份已验证',
                            ),
                          );
                        }
                      }),
                child: Text(t('Verify saved backup', '验证已保存的备份')),
              ),
              if (output != null) ...[
                SelectableText(output!),
                TextButton(
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: output!)),
                  child: Text(t('Copy result', '复制结果')),
                ),
              ],
            ],
          ),
        );
}

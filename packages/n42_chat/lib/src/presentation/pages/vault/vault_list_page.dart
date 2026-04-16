import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/vault_service.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../blocs/conversation/conversation_bloc.dart';
import '../../blocs/conversation/conversation_state.dart';
import '../conversation/conversation_tile.dart';

/// 消息金库 - 仅展示已加入金库的会话。
///
/// 进入本页前，调用方需确认 [VaultService.unlock] 成功。
class VaultListPage extends StatefulWidget {
  const VaultListPage({super.key, this.onConversationTap});

  final void Function(ConversationEntity conversation)? onConversationTap;

  @override
  State<VaultListPage> createState() => _VaultListPageState();
}

class _VaultListPageState extends State<VaultListPage> {
  final VaultService _vault = getIt<VaultService>();
  Set<String> _vaultIds = const <String>{};
  StreamSubscription<Set<String>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _vault.watchVaultRoomIds().listen((ids) {
      if (mounted) setState(() => _vaultIds = ids);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息金库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '金库说明',
            onPressed: _showHelp,
          ),
        ],
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          final items = state.conversations
              .where((c) => _vaultIds.contains(c.id))
              .toList();
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '金库为空。\n\n在会话列表中长按任意会话 → 「加入金库」以将其迁入此处。',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = items[index];
              return ConversationTile(
                conversation: c,
                isLocked: true,
                onTap: () => widget.onConversationTap?.call(c),
                onLongPress: () => _confirmRemove(c),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmRemove(ConversationEntity c) async {
    final alsoUnlock = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('从金库移出？'),
          content: const Text(
            '会话会回到主列表。是否同时解除聊天锁（下次进入时不再要求验证）？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('保留聊天锁'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('同时解锁'),
            ),
          ],
        );
      },
    );
    if (alsoUnlock == null) return;
    await _vault.removeFromVault(c.id, alsoUnlock: alsoUnlock);
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('关于消息金库'),
        content: const Text(
          '• 金库中的会话从主列表隐藏，仅在此页面可见。\n'
          '• 进入金库需通过生物识别 / PIN 验证。\n'
          '• 迁入时自动启用聊天锁；移出时可选保留或解锁。\n'
          '• 金库数据仅存在本地，不会同步到服务器。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

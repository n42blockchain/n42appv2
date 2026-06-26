import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/token_gate_entity.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';

/// 代币门控验证页面
///
/// 用户尝试加入带有代币门控的群时显示此页面。
class TokenGateVerifyPage extends StatefulWidget {
  final String roomId;
  final TokenGateConfig config;

  const TokenGateVerifyPage({
    super.key,
    required this.roomId,
    required this.config,
  });

  @override
  State<TokenGateVerifyPage> createState() => _TokenGateVerifyPageState();
}

class _TokenGateVerifyPageState extends State<TokenGateVerifyPage> {
  @override
  void initState() {
    super.initState();
    // 自动开始验证
    context.read<GroupBloc>().add(VerifyTokenGate(widget.roomId));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(s?.tokenGateVerifyTitle ?? 'Token Verification'),
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state.status == GroupStatus.tokenGateVerified && state.tokenGateResult!.passed) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return _buildVerifying(s);
          }

          if (state.status == GroupStatus.tokenGateVerified) {
            return _buildResult(state.tokenGateResult!, s, isDark);
          }

          if (state.status == GroupStatus.error) {
            return _buildError(state.errorMessage!, s);
          }

          return _buildVerifying(s);
        },
      ),
    );
  }

  Widget _buildVerifying(S? s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            s?.tokenGateVerifying ?? 'Verifying token holdings...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(TokenGateVerificationResult result, S? s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 结果图标
          Icon(
            result.passed ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: result.passed ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            result.passed
                ? (s?.tokenGateVerifyPassed ?? 'Verification Passed')
                : (s?.tokenGateVerifyFailed ?? 'Verification Failed'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: result.passed ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          if (!result.passed && widget.config.denialMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.config.denialMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // 逐条规则结果
          Expanded(
            child: ListView.builder(
              itemCount: result.ruleResults.length,
              itemBuilder: (context, index) {
                final ruleResult = result.ruleResults[index];
                return _RuleResultCard(ruleResult: ruleResult);
              },
            ),
          ),

          // 操作按钮
          if (!result.passed) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<GroupBloc>().add(VerifyTokenGate(widget.roomId));
                },
                child: Text(s?.tokenGateRetryVerify ?? 'Retry'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(String message, S? s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              context.read<GroupBloc>().add(VerifyTokenGate(widget.roomId));
            },
            child: Text(s?.tokenGateRetryVerify ?? 'Retry'),
          ),
        ],
      ),
    );
  }
}

/// 单条规则验证结果卡片
class _RuleResultCard extends StatelessWidget {
  final TokenGateRuleResult ruleResult;

  const _RuleResultCard({required this.ruleResult});

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

  @override
  Widget build(BuildContext context) {
    final rule = ruleResult.rule;
    final s = S.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          ruleResult.passed ? Icons.check_circle : Icons.cancel,
          color: ruleResult.passed ? AppColors.success : AppColors.error,
        ),
        title: Text(
          rule.symbol ?? _getTokenStandardLabel(rule.tokenStandard),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${s?.tokenGateRequired ?? 'Required'}: ${rule.minBalance}',
            ),
            Text(
              '${s?.tokenGateYourBalance ?? 'Your balance'}: ${ruleResult.actualBalance}',
              style: TextStyle(
                color: ruleResult.passed ? AppColors.success : AppColors.error,
              ),
            ),
            if (ruleResult.errorMessage != null)
              Text(
                ruleResult.errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

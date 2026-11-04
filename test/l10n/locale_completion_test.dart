import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'every generated locale loads completed mining labels and parameters',
    () async {
      for (final locale in S.delegate.supportedLocales) {
        final s = await S.load(locale);
        final labels = <String>[
          s.miningV3Title,
          s.miningV3Duration,
          s.miningV3Ready,
          s.miningV3Active,
          s.miningV3Connecting,
          s.miningV3Registering,
          s.miningV3Retrying,
          s.miningV3Paused,
          s.miningV3Start,
          s.miningV3Pause,
          s.miningV3Setup,
          s.miningV3Verified,
          s.miningV3Certified,
          s.miningV3CertifiedStatus,
          s.miningV3SuccessRate,
          s.miningV3AverageTime,
          s.miningV3Rewards,
          s.miningV3RewardsUnavailable,
          s.miningV3RewardsHint,
          s.miningV3RewardsInfo,
          s.miningV3RecentBlocks,
          s.miningV3RecentHint,
          s.miningV3All,
          s.miningV3Pending,
          s.miningV3Uncertified,
          s.miningV3Failed,
          s.miningV3Attention,
          s.miningV3EmptyTitle,
          s.miningV3EmptyBody,
          s.miningV3FilterEmpty,
          s.miningV3LoadMore,
          s.miningV3Node,
          s.miningV3Configure,
          s.miningV3Settings,
          s.miningV3NodeAddress,
          s.miningV3NodeHint,
          s.miningV3NodeInvalid,
          s.miningV3PauseForSettings,
          s.miningV3Save,
          s.miningV3ConnectionIssue,
          s.miningV3RetryHint,
          s.miningV3StartIssueHint,
          s.miningV3Time,
          s.miningV3TransactionsLabel,
          s.miningV3Latency,
          s.miningV3Signers,
          s.miningV3BlockHash,
          s.miningV3ReceiptsRoot,
          s.miningV3CopyHash,
          s.miningV3Copied,
          s.miningV3ErrorDetails,
          s.miningV3SaveFailed,
          s.g_setting_mining_v3_label,
          s.miningV3IOSForegroundHint,
          s.miningV3BackgroundPaused,
          s.miningV3LocalTestnet,
          s.miningV3UseLocalTestnet,
          s.miningV3LocalTestnetHint,
        ];
        for (final label in labels) {
          expect(label.trim(), isNotEmpty, reason: '$locale');
        }
        expect(s.miningV3Block('7'), contains('7'));
        expect(s.miningV3Transactions('7'), contains('7'));
        expect(s.miningV3Milliseconds('7'), contains('7'));
        expect(s.miningV3Device('7'), contains('7'));
        expect(s.g_key_earn_ledger, isNotEmpty);
      }
    },
  );
}

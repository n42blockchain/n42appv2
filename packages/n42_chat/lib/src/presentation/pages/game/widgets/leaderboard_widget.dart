import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../models/game_score.dart';
import '../services/game_score_service.dart';

class LeaderboardWidget extends StatelessWidget {
  final String gameId;
  final GameScoreService scoreService;
  final int? currentScore;

  const LeaderboardWidget({
    super.key,
    required this.gameId,
    required this.scoreService,
    this.currentScore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return FutureBuilder<List<GameScore>>(
      future: scoreService.getTopScores(gameId),
      builder: (context, snapshot) {
        final scores = snapshot.data ?? [];

        if (scores.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n?.gameNoScores ?? 'No scores yet',
                style: TextStyle(fontSize: 16, color: context.textTertiary),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n?.gameLeaderboard ?? 'Leaderboard',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...List.generate(scores.length, (i) {
              final s = scores[i];
              final isHighlight = currentScore != null && s.score == currentScore;

              return Container(
                color: isHighlight ? Colors.amber.withValues(alpha: 0.1) : null,
                child: ListTile(
                  leading: _buildRankIcon(i),
                  title: Text(
                    '${s.score}',
                    style: TextStyle(
                      fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Text(
                    _formatDate(s.playedAt),
                    style: TextStyle(fontSize: 12, color: context.textTertiary),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildRankIcon(int index) {
    switch (index) {
      case 0:
        return const Text('🥇', style: TextStyle(fontSize: 24));
      case 1:
        return const Text('🥈', style: TextStyle(fontSize: 24));
      case 2:
        return const Text('🥉', style: TextStyle(fontSize: 24));
      default:
        return SizedBox(
          width: 24,
          child: Text(
            '${index + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

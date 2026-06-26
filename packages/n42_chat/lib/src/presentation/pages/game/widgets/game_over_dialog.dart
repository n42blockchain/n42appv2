import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../services/game_score_service.dart';

class GameOverDialog extends StatefulWidget {
  final String gameId;
  final int score;
  final VoidCallback onPlayAgain;
  final VoidCallback? onViewLeaderboard;
  final GameScoreService scoreService;
  final bool lowerIsBetter;

  const GameOverDialog({
    super.key,
    required this.gameId,
    required this.score,
    required this.onPlayAgain,
    this.onViewLeaderboard,
    required this.scoreService,
    this.lowerIsBetter = false,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> {
  late final Future<int?> _saveFuture;

  @override
  void initState() {
    super.initState();
    _saveFuture = _saveAndGetHigh();
  }

  Future<int?> _saveAndGetHigh() async {
    await widget.scoreService.saveScore(widget.gameId, widget.score);
    return widget.scoreService.getHighScore(widget.gameId);
  }

  bool _isNewRecord(int highScore) {
    if (widget.lowerIsBetter) {
      return widget.score <= highScore;
    }
    return widget.score >= highScore;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return FutureBuilder<int?>(
      future: _saveFuture,
      builder: (context, snapshot) {
        final highScore = snapshot.data;

        return AlertDialog(
          title: Text(
            l10n?.gameOver ?? 'Game Over',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l10n?.gameScore ?? 'Score'}: ${widget.score}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              if (highScore != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n?.gameHighScore ?? 'Best'}: $highScore',
                  style: TextStyle(fontSize: 16, color: context.textTertiary),
                ),
              ],
              if (highScore != null && _isNewRecord(highScore)) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🏆 ${l10n?.gameNewRecord ?? 'New Record!'}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.commonClose ?? 'Close'),
            ),
            if (widget.onViewLeaderboard != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onViewLeaderboard!();
                },
                child: Text(l10n?.gameLeaderboard ?? 'Leaderboard'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onPlayAgain();
              },
              child: Text(l10n?.gamePlayAgain ?? 'Play Again'),
            ),
          ],
        );
      },
    );
  }
}

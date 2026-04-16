import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../services/game_score_service.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/leaderboard_widget.dart';
import 'game_2048_board.dart';
import 'game_2048_logic.dart';

class Game2048Page extends StatefulWidget {
  const Game2048Page({super.key});

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page> {
  final _logic = Game2048Logic();
  final _scoreService = getIt<GameScoreService>();
  bool _gameOver = false;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return GameScaffold(
      title: l10n?.game2048 ?? '2048',
      score: _logic.score,
      onRestart: _restart,
      child: Game2048Board(
        logic: _logic,
        onSwipe: _onSwipe,
      ),
    );
  }

  void _onSwipe(Direction dir) {
    if (_gameOver) return;
    setState(() {
      _logic.swipe(dir);
    });

    if (_logic.isGameOver) {
      _gameOver = true;
      _showGameOver();
    }
  }

  void _restart() {
    setState(() {
      _logic.reset();
      _gameOver = false;
    });
  }

  void _showGameOver() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        gameId: 'game_2048',
        score: _logic.score,
        scoreService: _scoreService,
        onPlayAgain: _restart,
        onViewLeaderboard: _showLeaderboard,
      ),
    );
  }

  void _showLeaderboard() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => LeaderboardWidget(
        gameId: 'game_2048',
        scoreService: _scoreService,
        currentScore: _logic.score,
      ),
    );
  }
}

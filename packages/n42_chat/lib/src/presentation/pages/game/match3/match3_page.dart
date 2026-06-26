import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../services/game_score_service.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/leaderboard_widget.dart';
import 'match3_board.dart';
import 'match3_logic.dart';

class Match3Page extends StatefulWidget {
  const Match3Page({super.key});

  @override
  State<Match3Page> createState() => _Match3PageState();
}

class _Match3PageState extends State<Match3Page> {
  final _logic = Match3Logic();
  final _scoreService = getIt<GameScoreService>();
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused) return;
      setState(() => _logic.tick());
      if (_logic.isGameOver) {
        _timer?.cancel();
        _showGameOver();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return GameScaffold(
      title: l10n?.gameMatch3 ?? 'Match 3',
      score: _logic.score,
      onRestart: _restart,
      onPause: _togglePause,
      isPaused: _isPaused,
      topWidget: _buildTimerBar(l10n),
      child: Match3Board(
        logic: _logic,
        onTap: _onTap,
        onSwipe: _onSwipe,
      ),
    );
  }

  Widget _buildTimerBar(S? l10n) {
    final progress = _logic.timeLeft / Match3Logic.gameDuration;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n?.gameTimeLeft ?? 'Time'}: ${_logic.timeLeft}s',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _logic.timeLeft <= 10 ? AppColors.error : null,
                ),
              ),
              Text(
                '${l10n?.gameScore ?? 'Score'}: ${_logic.score}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(
              _logic.timeLeft <= 10 ? AppColors.error : AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(int r, int c) {
    if (_isPaused || _logic.isGameOver) return;
    setState(() => _logic.select(r, c));
  }

  void _onSwipe(int r1, int c1, int r2, int c2) {
    if (_isPaused || _logic.isGameOver) return;
    _logic.selectedRow = null;
    _logic.selectedCol = null;
    setState(() => _logic.trySwap(r1, c1, r2, c2));
    _checkNoMoves();
  }

  void _checkNoMoves() {
    if (!_logic.isGameOver && !_logic.hasValidMoves) {
      _logic.isGameOver = true;
      _timer?.cancel();
      _showGameOver();
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      _logic.reset();
      _isPaused = false;
    });
    _startTimer();
  }

  void _showGameOver() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        gameId: 'match3',
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
        gameId: 'match3',
        scoreService: _scoreService,
        currentScore: _logic.score,
      ),
    );
  }
}

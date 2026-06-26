import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../services/game_score_service.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/leaderboard_widget.dart';
import 'minesweeper_board.dart';
import 'minesweeper_logic.dart';

class MinesweeperPage extends StatefulWidget {
  const MinesweeperPage({super.key});

  @override
  State<MinesweeperPage> createState() => _MinesweeperPageState();
}

class _MinesweeperPageState extends State<MinesweeperPage> {
  final _logic = MinesweeperLogic();
  final _scoreService = getIt<GameScoreService>();
  Timer? _timer;
  bool _timerStarted = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timerStarted) return;
    _timerStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _logic.isGameOver) return;
      setState(() => _logic.elapsedSeconds++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return GameScaffold(
      title: l10n?.gameMinesweeper ?? 'Minesweeper',
      score: _logic.elapsedSeconds,
      onRestart: _restart,
      topWidget: _buildTopBar(l10n),
      child: MinesweeperBoard(
        logic: _logic,
        onTap: _onTap,
        onLongPress: _onLongPress,
      ),
    );
  }

  Widget _buildTopBar(S? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mines left
          Row(
            children: [
              const Text('💣', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                '${_logic.remainingMines}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // Difficulty toggle
          SegmentedButton<Difficulty>(
            segments: [
              ButtonSegment(
                value: Difficulty.easy,
                label: Text(l10n?.gameMinesweeperEasy ?? 'Easy', style: const TextStyle(fontSize: 12)),
              ),
              ButtonSegment(
                value: Difficulty.medium,
                label: Text(l10n?.gameMinesweeperMedium ?? 'Medium', style: const TextStyle(fontSize: 12)),
              ),
            ],
            selected: {_logic.difficulty},
            onSelectionChanged: (s) {
              _logic.changeDifficulty(s.first);
              _timer?.cancel();
              _timerStarted = false;
              setState(() {});
            },
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          // Timer
          Row(
            children: [
              const Icon(Icons.timer, size: 18),
              const SizedBox(width: 4),
              Text(
                '${_logic.elapsedSeconds}s',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTap(int r, int c) {
    _startTimer();
    setState(() {
      _logic.reveal(r, c);
    });
    if (_logic.isGameOver) {
      _timer?.cancel();
      _showGameOver();
    }
  }

  void _onLongPress(int r, int c) {
    setState(() {
      _logic.toggleFlag(r, c);
    });
    if (_logic.isGameOver && _logic.isWin) {
      _timer?.cancel();
      _showGameOver();
    }
  }

  void _restart() {
    _timer?.cancel();
    _timerStarted = false;
    setState(() => _logic.reset());
  }

  void _showGameOver() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        gameId: 'minesweeper',
        score: _logic.elapsedSeconds,
        scoreService: _scoreService,
        lowerIsBetter: true,
        onPlayAgain: _restart,
        onViewLeaderboard: _showLeaderboard,
      ),
    );
  }

  void _showLeaderboard() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => LeaderboardWidget(
        gameId: 'minesweeper',
        scoreService: _scoreService,
        currentScore: _logic.elapsedSeconds,
      ),
    );
  }
}

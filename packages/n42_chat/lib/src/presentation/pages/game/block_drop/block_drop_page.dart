import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../services/game_score_service.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/leaderboard_widget.dart';
import 'block_drop_board.dart';
import 'block_drop_logic.dart';

class BlockDropPage extends StatefulWidget {
  const BlockDropPage({super.key});

  @override
  State<BlockDropPage> createState() => _BlockDropPageState();
}

class _BlockDropPageState extends State<BlockDropPage> {
  final _logic = BlockDropLogic();
  final _scoreService = getIt<GameScoreService>();
  Timer? _dropTimer;
  bool _isPaused = false;
  int _lastDropInterval = 0;

  @override
  void initState() {
    super.initState();
    _lastDropInterval = _logic.dropInterval;
    _startTimer();
  }

  @override
  void dispose() {
    _dropTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _dropTimer?.cancel();
    _lastDropInterval = _logic.dropInterval;
    _dropTimer = Timer.periodic(
      Duration(milliseconds: _lastDropInterval),
      (_) => _tick(),
    );
  }

  void _tick() {
    if (!mounted || _isPaused || _logic.isGameOver) {
      _dropTimer?.cancel();
      return;
    }
    setState(() {
      _logic.softDrop();
    });
    if (_logic.isGameOver) {
      _dropTimer?.cancel();
      _showGameOver();
      return;
    }
    // 速度变化时，在下一帧重启 Timer（避免在回调中直接重启）
    if (_logic.dropInterval != _lastDropInterval) {
      _dropTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isPaused && !_logic.isGameOver) {
          _startTimer();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return GameScaffold(
      title: l10n?.gameBlockDrop ?? 'Block Drop',
      score: _logic.score,
      onRestart: _restart,
      onPause: _togglePause,
      isPaused: _isPaused,
      topWidget: _buildInfoBar(l10n),
      child: GestureDetector(
        onHorizontalDragEnd: (d) {
          if (_isPaused || _logic.isGameOver) return;
          if (d.primaryVelocity == null) return;
          setState(() {
            if (d.primaryVelocity! > 0) {
              _logic.moveRight();
            } else {
              _logic.moveLeft();
            }
          });
        },
        onVerticalDragEnd: (d) {
          if (_isPaused || _logic.isGameOver) return;
          if (d.primaryVelocity == null) return;
          if (d.primaryVelocity! > 100) {
            setState(() => _logic.hardDrop());
            if (_logic.isGameOver) {
              _dropTimer?.cancel();
              _showGameOver();
            }
          } else if (d.primaryVelocity! < -100) {
            setState(() => _logic.rotate());
          }
        },
        onTap: () {
          if (_isPaused || _logic.isGameOver) return;
          setState(() => _logic.rotate());
        },
        child: BlockDropBoard(logic: _logic),
      ),
    );
  }

  Widget _buildInfoBar(S? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(l10n?.gameLevel ?? 'Level',
                  style: TextStyle(fontSize: 12, color: context.textTertiary)),
              Text('${_logic.level}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              Text(l10n?.gameNext ?? 'Next',
                  style: TextStyle(fontSize: 12, color: context.textTertiary)),
              const SizedBox(height: 4),
              NextPieceWidget(piece: _logic.nextPiece),
            ],
          ),
          Column(
            children: [
              Text(l10n?.gameLines ?? 'Lines',
                  style: TextStyle(fontSize: 12, color: context.textTertiary)),
              Text('${_logic.totalLines}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _restart() {
    _dropTimer?.cancel();
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
        gameId: 'block_drop',
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
        gameId: 'block_drop',
        scoreService: _scoreService,
        currentScore: _logic.score,
      ),
    );
  }
}

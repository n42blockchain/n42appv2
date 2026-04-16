import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// 联系人字母索引条
class ContactIndexBar extends StatefulWidget {
  final List<String> letters;
  final ValueChanged<String> onLetterTap;

  const ContactIndexBar({
    super.key,
    required this.letters,
    required this.onLetterTap,
  });

  @override
  State<ContactIndexBar> createState() => _ContactIndexBarState();
}

class _ContactIndexBarState extends State<ContactIndexBar> {
  String? _currentLetter;
  bool _isDragging = false;

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _updateLetter(details.localPosition);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _updateLetter(details.localPosition);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _currentLetter = null;
    });
  }

  void _updateLetter(Offset position) {
    if (widget.letters.isEmpty) return;

    final box = context.findRenderObject() as RenderBox;
    final itemHeight = box.size.height / widget.letters.length;
    final index = (position.dy / itemHeight).floor();

    if (index >= 0 && index < widget.letters.length) {
      final letter = widget.letters[index];
      if (letter != _currentLetter) {
        setState(() {
          _currentLetter = letter;
        });
        widget.onLetterTap(letter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (widget.letters.isEmpty) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 字母指示器气泡
        if (_isDragging && _currentLetter != null)
          Positioned(
            right: 40,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _currentLetter!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        // 索引条
        GestureDetector(
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Container(
            width: 20,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _isDragging
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.letters.map((letter) {
                final isActive = letter == _currentLetter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onLetterTap(letter),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          color: isActive
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}


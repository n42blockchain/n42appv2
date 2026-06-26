import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/search/search_event.dart';
import '../../blocs/search/search_state.dart';

/// 聊天内搜索栏
class ChatSearchBar extends StatefulWidget {
  final String roomId;
  final VoidCallback? onClose;
  final void Function(String eventId)? onNavigateToMessage;

  const ChatSearchBar({
    super.key,
    required this.roomId,
    this.onClose,
    this.onNavigateToMessage,
  });

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<SearchBloc>().add(SearchInChat(widget.roomId, query));
  }

  void _onPrevious() {
    context.read<SearchBloc>().add(const NavigateToPreviousResult());
  }

  void _onNext() {
    context.read<SearchBloc>().add(const NavigateToNextResult());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state is ChatSearchState) {
          final message = state.results.currentMessage;
          if (message != null && widget.onNavigateToMessage != null) {
            widget.onNavigateToMessage!(message.id);
          }
        }
      },
      builder: (context, state) {
        int currentIndex = 0;
        int totalCount = 0;
        bool hasPrevious = false;
        bool hasNext = false;
        bool isSearching = false;

        if (state is ChatSearchState) {
          currentIndex = state.results.currentIndex + 1;
          totalCount = state.results.totalCount;
          hasPrevious = state.results.hasPrevious;
          hasNext = state.results.hasNext;
          isSearching = state.isSearching;
        }

        return Container(
          height: 48,
          color: context.surfaceColor,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // 搜索输入框
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.pageBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: S.of(context)?.searchInChat ?? 'Search in chat',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: context.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textPrimary,
                    ),
                    onChanged: _onSearch,
                  ),
                ),
              ),

              // 结果计数
              if (totalCount > 0 || isSearching) ...[
                const SizedBox(width: 8),
                if (isSearching)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '$currentIndex/$totalCount',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
              ],

              // 上一个/下一个按钮
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up, size: 24),
                onPressed: hasPrevious ? _onPrevious : null,
                color: hasPrevious
                    ? context.textPrimary
                    : context.textSecondary,
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, size: 24),
                onPressed: hasNext ? _onNext : null,
                color: hasNext
                    ? context.textPrimary
                    : context.textSecondary,
              ),

              // 关闭按钮
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: widget.onClose,
                color: context.textPrimary,
              ),
            ],
          ),
        );
      },
    );
  }
}

